---
layout: post
title: "Playing Smash Bros. with a Steam Controller: implementation"
permalink: smash-bros-steam-controller-implementation/
series:
  prev: smash-bros-steam-controller-design/
  next: smash-bros-steam-controller-touch-detection/
tags:
  - gaming
  - hardware
  - smash-bros
  - software-engineering
---

I was able to implement my own firmware and [custom control scheme]({% permalink smash-bros-steam-controller-design %}) to [play *Super Smash Bros. Ultimate* with a Steam Controller]({% permalink smash-bros-steam-controller %}).

I implemented it on top of the [OpenSteamController firmware](https://github.com/greggersaurus/OpenSteamController) and fixed several issues, then added my control scheme. My version of the firmware is available on [my `smash-bros` branch of my OpenSteamController repository fork](https://github.com/arxanas/OpenSteamController/tree/smash-bros).

{% noteblock note-warning %}
<span class="note-tag note-warning">However:</span> Touch detection ultimately turned out to be a difficult problem, and I was unable to resolve it with a degree of reliability that I considered suitable for competitive gameplay. See [*Playing Smash Bros. with a Steam Controller: touch detection*]({% permalink smash-bros-steam-controller-touch-detection %}) for more information.

If you have any ideas on how to resolve this issue, I'd love to hear them! Comment on the article or email me at <me@waleedkhan.name>
{% endnoteblock %}

{% include toc.md %}

## Firmware

The normal input methods rely on Steam (TODO link) to be running on the PC and interpret the inputs in software, so it can't be directly used with a gaming console such as the Nintendo Switch.

<span class="note-tag note-info">However:</span> The firmware is delightfully easy to reprogram: <span class="note-braces">simply hold R2 while connecting the Steam Controller to a computer by USB, <span class="note-conj">and then</span> copy the new `firmware.bin` file onto the device as if it were a normal mounted filesystem</span>.

<span class="note-tag">Thus:</span> If we can somehow write our own Switch-compatible firmware, we can easily load it for use on the Steam Controller.

I ran this terminal command to <span class="note-braces">wait for the Steam Controller to be connected <span class="note-conj">and then</span> automatically load the latest firmware onto it</span>:

```console
sudo bash -c 'while true; do if [[ -f /Volumes/CRP\ DISABLD/firmware.bin ]]; then echo "Updating firmware $(date)" && cat /Users/waleed/Workspace/OpenSteamController/Firmware/OpenSteamController/Debug/OpenSteamController.bin >/Volumes/CRP\ DISABLD/firmware.bin && sudo /sbin/umount /Volumes/CRP\ DISABLD && printf "Done updating\a\n"; fi; sleep 1; done'
```

## The OpenSteamController project

The [OpenSteamController project](https://github.com/greggersaurus/OpenSteamController) is a reverse-engineering effort which already figured out how to reprogram the Steam Controller's firmware. I was able to use the instructions directly to build my own firmware.

<span class="note-tag note-info">Incredibly:</span> The original intention of the OpenSteamController project was [just to reprogram the "jingles" that play on the device](https://github.com/greggersaurus/OpenSteamController?tab=readme-ov-file#the-open-steam-controller-project):

> Next we come to what was originally the sole intention of this project. That is, the goal of being able to have full control of the songs (Jingles) that the Steam Controller plays (via the Trackpad Haptics) on power up and shut down. Due to some discoveries via the Reverse Engineering effort, this project allows for Jingles to be fully customized and for these customizations to persist while still running Valve's official firmware.

But the ultimate scope is quite expansive, including a full implementation of ["PowerA"](https://en.wikipedia.org/wiki/PowerA)-style Nintendo Pro Controller firmware! I just had to fix a few bugs and usability issues.

## Upstream issues

### Touch detection

When I tried to define a control scheme using the touchpad, I immediately encountered [an issue where "Hovering my finger over the right pad registers an input"](https://github.com/greggersaurus/OpenSteamController/issues/7).

The reporter demonstrated the issue in this video, where touches are registered even ~1cm above the touchpad:

<div class="iframe-container">
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/kDKSPASbD7A?si=oDX6dBsB0ADyUOvJ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
</div>

[I fixed this in a pull request](https://github.com/greggersaurus/OpenSteamController/pull/32) by checking the amplitude of the touchpad signal and only registering a touch at a certain empirically-determined threshold.

The underlying cause is quite interesting:

- <span class="note-tag note-info">It turns out that:</span> The touchpad... is incapable of detecting touches!
- The hardware appears to provide no direct indication that the user is making contact with the touchpad.
- <span class="note-tag">Instead:</span> The firmware needs to calculate how far the finger is from the sensors *underneath* the touchpad. When the finger is close enough to those sensors, then the firmware can infer that it must be making contact with the touchpad.

While my approach is simple and reasonably effective, it quickly loses accuracy when processing touches distant from the touchpad center, due to <span class="note-braces"><span class="note-conj">both</span> the curvature of the touchpad increasing the physical distance from the sensors <span class="note-conj">and</span> the specific placement and shape of the sensor array</span>.

TODO: link to touch detection

### Dead zones

The touchpad surfaces are actually *curved* rather than flat. The curvature is greatest at the outer edges of the touchpad, the curvature is greatest. At the top edge, it seems like the touchpad often doesn't register touches.

<span class="note-tag">Originally:</span> I was going to try to model the curvature of the touchpad as an ellipsoid in 3D space and adjust the touch detection amplitude threshold accordingly, but that sounded quite complicated.

<span class="note-tag">Fortunately:</span> One user opened a [pull request](https://github.com/greggersaurus/OpenSteamController/pull/33) with a much simpler approach where they detect a failure to read the y-position of the touchpad coordinate and replace it with the y-position for the top of the touchpad.

<span class="note-tag">In practice:</span> That approach seems to work fairly well, so I adopted it in my own firmware.

### Angle offset

The hardware seems to offset touchpad measurements by about 15° inward.

- <span class="note-tag">To illustrate:</span> Check the angling on the virtual notch axes in the [control scheme diagram](#control-scheme) and see how the axes align with the grip of the controller rather than rectangular body of the controller.
- <span class="note-tag">For example:</span> If you place your thumb at the top of the right touchpad, then the actual input will be slightly to the right of the top-most position.
- <span class="note-tag">Interestingly:</span> The left touchpad has tactile grooves in the shape of a directional pad, but they don't align with the 15° offset!

I suspect that this is a deliberate design decision so that the touchpad is aligned with the natural direction of the thumb at rest.

- With this design, natural movements of the thumb directly correspond to movements along the hardware axes.
  - <span class="note-tag">In contrast:</span> When using a Pro Controller, I have to manually adjust my thumb movement to be parallel to the controller body, which is diagonal to my thumb's natural movement axis.
- I never noticed the offset when using the Steam Controller for PC gaming. <span class="note-braces"><span class="note-conj">Either</span> the offset is not present in the official firmware, <span class="note-conj">or</span> it's natural and intuitive and therefore not noticeable for casual use.</span>

I elected to keep the angle offset as-is, as it seems like it might have both ergonomic and competitive advantages. <span class="note-tag">However:</span> One user opened a [pull request](https://github.com/greggersaurus/OpenSteamController/pull/33) with an example of how to undo the offset.

### Vibration support

When using the Pro Controller, I rely on [haptic feedback](https://en.wikipedia.org/wiki/Haptic_technology) for gameplay purposes, along with other sensory cues.

- <span class="note-tag">Generally speaking:</span> Vision is a much "slower" sense than touch or hearing, so it's a competitive advantage to leverage faster senses where possible.
- <span class="note-tag">Furthermore:</span> Vision usually has to be directed to the *opponent's* character, rather than one's own character, to leverage [smooth pursuit](https://en.wikipedia.org/wiki/Smooth_pursuit) and react in a timely manner. Non-visual cues for one's own character can therefore provide useful feedback when visual cues are unavailable.

TODO: check all instances of "vibration" vs "haptic" in this document?

Some specific examples of haptic cues:

- When my character walks or runs, the controller produces small haptic patterns resembling footsteps.
  - After my character has been airborne, I can determine when they've landed by the footsteps, and switch to grounded movement inputs.
  - I can determine when my character has unexpectedly *not* landed (which is an important signal because it likely means that they're about to fall off-stage and die).
  - Occasionally, I'll have my character run off a platform. The exact timing of the footsteps stopping can be convenient in order to time inputs that need to happen only after leaving the platform, such as off-stage attacks.
- When my character attacks or hits the opponent, a certain vibration is produced.
  - This helps me determine when to perform the next input in an attack sequence, or determine that I didn't actually hit the opponent and need to abort the sequence.
  - Auditory cues are also used here.
- When my character is hit by the opponent, a certain vibration is produced.
  - This lets me know to abort my existing movement or attack inputs and start a reactive sequence.
  - Auditory cues are also used here.

I had hoped that it would be straightforward to implement haptic feedback support in the existing OpenSteamController firmware.

<span class="note-tag note-warning">But instead:</span> I discovered why most third-party controllers only support wired connections without haptic feedback. They only support <span class="note-braces">a simpler unidirectional protocol without haptic feedback support <span class="note-conj">rather than</span> a more complex bidirectional protocol with haptic feedback support</span>. I don't know if there's a specific reason for this, other than engineering cost.

{% noteblock note-info %}
<span class="note-tag note-info">It turns out that:</span> There's two main communication protocols for Nintendo Switch controllers:

- **Bidirectional**: The console and controller send each other messages according to a specific protocol.
  - This is the protocol implemented by the first-party Pro Controller.
  - Inputs are sent by the controller to the console as they're produced by the player.
  - Haptic feedback is sent from the console to the controller as they're produced by the game.
  - Some information about the protocol can be found in the [dekuNukem/Nintendo_Switch_Reverse_Engineering repository](https://github.com/dekuNukem/Nintendo_Switch_Reverse_Engineering/blob/master/README.md).
  - <span class="note-tag">Interestingly:</span> The wired and wireless protocols are essentially the same. A wired connection can upgrade to a wireless connection by sending a specific message, but otherwise continue speaking the same protocol.
- **Unidirectional**: The controller continuously notifies the console about the status of its buttons, without a complicated bidirectional message protocol.
  - This is the protocol implemented by the existing OpenSteamController firmware.
  - This is essentially stateless and much simpler to implement than the bidirectional protocol. <span class="note-tag">In particular:</span> There is no need to perform synchronization or calculate timing information, which are probably required for haptic feedback.
  - Since there is no communication from the console to the controller, it's not possible to receive haptic feedback at all. Only the bidirectional protocol supports haptic feedback.
{% endnoteblock %}

As a software engineer with limited hardware experience, I decided that it would be too time-consuming for me to correctly implement the bidirectional protocol from scratch.

<span class="note-tag note-warning">Instead:</span> I worked directly on top of the existing OpenSteamController firmware, which implements the unidirectional protocol, and gave up haptic feedback for gameplay.

<span class="note-tag note-info">However:</span> Since I wasn't using haptic feedback for gameplay, I was instead free to use it to implement [virtual notches](#virtual-notches) for the touchpads.

{% noteblock note-info %}
<span class="note-tag note-info">In practice:</span> Many pro players use GameCube Controllers, which only have one possible setting for vibration intensity. After having tried a GameCube Controller myself, I agree with their assessment that it's unusably disruptive and provides limited value compared to the Pro Controller's fine-grained haptic feedback.

<span class="note-tag">Therefore:</span> Having effective haptic feedback is better than not having it, but even the highest levels of play can be achieved without it (and I am nowhere close).
{% endnoteblock %}

## My issues

For fun, here's some bugs that I inflicted upon myself during firmware development:

### Elliptical neutral zones

I had intended the center neutral zone to be a circle with 50% of the radius of the entire touchpad, but I accidentally made it an ellipse at first.
  - **Symptom**: It was weirdly difficult to perform neutral inputs in one axis, but not the other.
  - **Cause**: The coordinates for the touchpad axes aren't measured on the same scale. The x-values range from 0 to 1200, while the y-values range from 0 to 700. (I don't know why this is.) My calculation didn't accommodate for this; possibly it used one of the ranges for both axes.
  - **Fix**: I first normalized the distances on each axis from the center to be a percentage of the maximum distance on that axis, then checked if the coordinate was contained within a circle of radius 50.

### Denoising failure

I tried two different systems for denoising measurements: taking the <span class="note-braces">minimum <span class="note-conj">and</span> average</span> of the last few measurements.
  - **Symptom**: Spurious inputs were being registered with one denoising system but not the other. This ruined the results of certain experiments when I couldn't understand the results compared to the raw measurements.
  - **Cause**: I had copied-and-pasted the minimum calculation loop to start writing the average calculation loop, but forgot to change the initial average amplitude to zero (from `historicalTrackpadAmplitudes[trackpad][0]`). This resulted in the calculated average amplitude being a factor of 1/3 greater than it should have been (since I had set `n = 3` historical amplitudes).
  - **Fix**: I set the initial average amplitude to zero.

### Dead zone misinputs

When a touch is registered in one axis but not the other, it's assumed that the other axis's measurement was caught in a "dead zone". The last-known position of the finger in that axis is used instead as a heuristic, with the idea that most finger positions will be not be far from their immediately subsequent positions.
  - **Symptom**: Certain inputs would have the wrong direction altogether in one of the axes. Concretely, many of my up-aerials were coming out as down-aerials.
  - **Cause**: The last-known position of the finger would be retained even when the finger had left the touchpad, in which case the next position might be somewhere completely different. When the next position happened to be distant from the previous position, it would manifest in an egregious manner, such as switching the direction of the input in one axis entirely.
  - **Fix**: I transitioned the last-known position of the finger to an "invalid" state when the finger was no longer detected on the touchpad.

## Conclusion

TODO: conclude?

{% include end_matter.md %}

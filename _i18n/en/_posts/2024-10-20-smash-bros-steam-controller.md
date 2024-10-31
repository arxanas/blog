---
layout: post
title: "Playing Smash Bros with a Steam Controller"
permalink: smash-bros-steam-controller/
tags:
  - gaming
  - hardware
  - smash-bros
---


<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Software/hardware developers with a passing interest in video games or ergonomics.</li>
        <li>Competive Smash players interested in alternative input methods.</li>
      </ul>
      </td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>The <a href="https://github.com/greggersaurus/OpenSteamController">OpenSteamController project</a>.</li>
        <li>My own research and development, resulting in my <a href="https://github.com/arxanas/OpenSteamController/tree/smash-bros">custom fork</a>.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td><ul>
        <li>Inventive</li>
        <li>Curious</li>
        <li>Lamenting that it ultimately wasn't reliable enough</li>
      </ul></td>
    </tr>
  </table>
</div>

* toc
{:toc}

## What to skip

Depending on your interests, you'll prefer to skip one or more of these sections:

- [Rationale](#rationale): Explaining why I wanted to use a Steam Controller, including ergonomics and precision.
- [Design](#design): How the controller scheme is designed for *Smash Bros.* to exploit the unique hardware.
- [Implementation](#implementation): Technical details about the Coding and Algorithms&trade;.

<p class="note-block note-warning"><span class="note-tag note-warning">My apologies:</span> I hate documents with a "how to read this document" foreword, so I'm sorry to have sujected you to one.</p>

## Summary

I play *[Super Smash Bros. Ultimate](https://en.wikipedia.org/wiki/Super_Smash_Bros._Ultimate)* competitively. Players usually use one of these controllers:

- [Nintendo Switch Pro Controller](https://en.wikipedia.org/wiki/Nintendo_Switch_Pro_Controller)
- [Nintendo GameCube Controller](https://en.wikipedia.org/wiki/GameCube_controller)

I usually use a Pro Controller, but I've been experimenting with using a [Steam Controller](#the-steam-controller) instead, for [reasons discussed later](@nocommit: link reasons).

Challenges:
- The [Nintendo Switch](https://en.wikipedia.org/wiki/Nintendo_Switch) does not natively support Steam Controllers.
- There are several design considerations for a tournament-legal custom controller that makes full use of the Steam Controller's unique hardware capabilities.

Results:

- The Steam Controller is delightful when it works!
  - <span class="note-tag note-warning">Unfortunately:</span> It's not yet reliable enough for tournament usage. If you're a hardware enthusiast, maybe you could improve it?
  - <span class="note-tag">In particular:</span> In order to implement touch detection, I had to fit a 3D curve to experimentally-gathered data, but my techniques produced either too many false positives or false negatives.
- I had to write a [small amount of firmware code](https://github.com/greggersaurus/OpenSteamController/compare/master...arxanas:OpenSteamController:smash-bros)
  - <span class="note-tag">Unfortunately:</span> I have very little hardware experience. (<span class="note-tag note-error">Regrettably:</span> Most hardware I tinker with mysteriously malfunctions or dies shortly afterwards 😬.)
  - <span class="note-tag">Fortunately:</span> Somebody else had already reverse-engineered the Steam Controller's firmware _and_ wrote a Nintendo-Switch-compatible emulation layer.
- I had to conduct a ton of experimentation.
  - <span class="note-tag">To contrast:</span> It's like I'm a real engineer, not a software engineer! I had to [take measurements and put them in a spreadsheet][steam-controller-measurements] and everything.
- My custom controller button scheme is pretty cool (in my opinion).
  - <span class="note-tag">For example:</span> You never have to move your thumbs off the touchpad.

[steam-controller-measurements]: https://docs.google.com/spreadsheets/d/1OsZ_8aARLt2CsAgTYeFL9fWcoAd76ydiDuHzA4Uyvms/edit?usp=sharing

## The Steam Controller

### Hardware

The [Steam Controller](https://en.wikipedia.org/wiki/Steam_Controller) was a video game controller created by [Valve](https://en.wikipedia.org/wiki/Valve_Corporation):

- Now discontinued. 🪦 RIP (Nov 2015–Nov 2019)
- Part of the [Steam Machine](https://en.wikipedia.org/wiki/Steam_Machine_(computer)#Steam_Controller) suite to support PC gaming in the living room.

It looks like this:

{% image steam-controller-in-package.jpg
  "Picture of a Steam Controller in its original packaging."
  "Steam Controller (2015). Credit: [Wikipedia](https://en.wikipedia.org/wiki/File:Steam_Controller_in_package.jpg)" %}

Features:

* <span class="note-tag">Notably:</span> Where joysticks would be on a traditional game controller, there are instead two touchpads.
* Each touchpad has an associated [haptic feedback generator](https://en.wikipedia.org/wiki/Haptic_technology).
    * Used for per-touchpad vibration during gameplay.
    * <span class="note-tag">But also:</span> It can play normal sound if you use a high enough frequency (pitch), which is how the Steam Controller's "startup [jingles](https://en.wikipedia.org/wiki/Jingle)" are implemented.
* <span class="note-tag">Notably:</span> There are buttons on the back of the controller ("paddles" or "grips") in addition to the normal buttons on the face and shoulder of the controller.
    * This is nice since you can now recruit an additional finger from each hand into gameplay.
    * <span class="note-tag">Lately:</span> Mainstream controllers have been adopting buttons on the back.
* The hardware features have been inherited by Valve's [Steam Deck](https://en.wikipedia.org/wiki/Steam_Deck), which has:
  * two touchpads,
  * two joysticks,
  * four paddles,
  * a normal complement of controller "face" buttons (<kbd>A</kbd>/<kbd>B</kbd>/<kbd>X</kbd>/<kbd>Y</kbd>).

Community:

* Surprisingly active, such as [/r/SteamController](https://www.reddit.com/r/SteamController/).
* Some users remark that the design and flexibility of the Steam Controller is uniquely accessible among game controllers.
  * <span class="note-tag">Such as:</span> Those with [tendonitis](https://www.reddit.com/r/SteamController/comments/1979eze/comment/kiw9neo/?utm_source=reddit&utm_medium=web2x&context=3) or [EEC syndrome](https://en.wikipedia.org/wiki/Ectrodactyly%E2%80%93ectodermal_dysplasia%E2%80%93cleft_syndrome).
  * <span class="note-tag">In fact:</span> Some people report that the Steam Controller is the *only* controller that they can use.


## Rationale


### Larger grips

The most notable problem with the Pro Controller for me is this:

[TODO: insert picture holding Pro controller, comparing hand size to controller size]

My hands are too large to use a Pro controller comfortably, as I need to support its weight primarily with my fingers rather than my palms. To accommodate my hands, I've bought aftermarket grips:

[TODO: insert picture of Pro controller with grips]

The Steam Controller more comfortably fits my hand:

[TODO: insert picture holding Steam Controller similar to the Pro controller picture before]

Although I've gotten feedback from friends that the Steam Controller grips are too big to be comfortably held by them!


### Less force

Before this, I had used a Steam Controller for PC gaming, after which I realized that pushing around joysticks is much less comfortable than sliding your finger across a touchpad:

<p class="note-block"><span class="note-tag">Casual:</span> When you push deeply into the joystick... the joystick pushes also into you! Ouch!</p>

<p class="note-block"><span class="note-tag">Technical:</span>

As you push the joystick, it exerts a proportional counteracting <a href="https://en.wikipedia.org/wiki/Hooke%27s_law">spring force</a> on your finger. In contrast, sliding your finger across a touchpad does not require you to counteract spring force as you move your finger, nor do you have to exert continued force just to maintain your finger in place at a certain position.

</p>

I didn't realize just how much effort I spent pushing around joysticks, and I find that transitioning back from touchpads to joysticks is jarring.

There's a potential competitive advantage as well:

<p class="note-block"><span class="note-tag">Casual:</span> Tapping a position on the touchpad is faster than pushing the joystick to that position.</p>

<aside class="note-block">
<p><span class="note-tag">Technical:</span>

You can perform certain inputs faster. You can position your finger physically <em>above</em> the touchpad (suspended in the air) without triggering an input, and drop your finger onto the touchpad at the appropriate time.</p>

<ul><li>Your finger therefore has much less travel distance, and doesn't need to fight the joystick counter-force along the whole path.</li>
<li>From the perspective of the game engine, the joystick moves instantaneously from neutral to the target position.</li>
<li>This is useful for many input sequences with precise timing windows.</li></ul>

<p><span class="note">In particular:</span> In <i>Smash Bros</i>., after having completed the previous input, there's a meaningful difference between</p>

<ul><li>leaving the joystick in its current position, versus</li>
<li>resetting the joystick to neutral and pushing it to that position again.</li></ul>

<p>With the touchpad, it becomes trivial to do the latter: just raise and lower your thumb.</p>

</aside>

<span class="note-tag">Amusingly:</span> I had mild trouble adjusting to the instant inputs. <span class="note-tag">For example:</span> When timing fast-falls, I would fail because I would tap the touchpad too early, because I was subconsciously adjusting for the non-existent joystick travel time.

<span class="note-tag note-error">However:</span> As I discovered later, the joystick's spring force is actually quite important!

<p class="note-block"><span class="note-tag">Casual:</span> When the joystick pushes against your finger, you can intuitively estimate where your finger is with respect to the joystick's neutral position.</p>

<aside class="note-block">
<p><span class="note-tag">Technical:</span>

The joystick counter-force provides critical <a href="https://en.wikipedia.org/wiki/Proprioception">proprioceptive feedback</a>. [TODO: point out that the force you apply is equal and opposite to the counter-force to hold it at rest.] The magnitude of the counteracting spring force indicates the distance from neutral, while the direction indicates the direction.</p>

<p>
The touchpad is mostly smooth. In order to determine where your finger is resting, or where it's just moved, it would perhaps require an array of tactile markings that you can feel as you drag your thumb.
</p>

<p>
<span class="note-tag">As an alternative:</span>
We can replace proprioceptive feedback with haptic feedback (see <a href="#virtual-notches">virtual notches</a>) &mdash; and arguably produce a better-than-physical experience.
</p>

</aside>


* TODO: Smash Bros not technical
* TODO: fast fall, b-reverse timing issues
* TODO: link to design where left touchpad taps but right touchpad clicks.
* TODO: not a big deal since Smashbox is allowed.


### Fewer moving parts

[I've complained in the past about the unreliability of Pro controller joysticks](https://blog.waleedkhan.name/pro-controller-stick-drift/). Hopefully, touchpads won't suffer from the same mechanical issues because they don't use moving parts.

TODO: link [https://www.reddit.com/r/SmashBrosUltimate/comments/19eizw3/i_probably_lost_so_many_sets_because_of_this/](https://www.reddit.com/r/SmashBrosUltimate/comments/19eizw3/i_probably_lost_so_many_sets_because_of_this/) ?

<div class="note-block note-warning">
<p><span class="note-tag note-warning">However</span>: The other mechanical components on the Steam Controller might break with extended usage. Reports from users on Steam Controller longevity vary.</p>

<p>If mechanical reliability were my only criterion, I would consider buying an alternative controller that uses <a href="https://en.wikipedia.org/wiki/Hall_effect">Hall effect</a> sensors for joysticks.</p>
</div>

### Custom  precise controls

One common class of misinput for me is when I shift my right thumb from the joystick to press a face button. I often fail by

- pressing the wrong button;
- pressing with delayed timing;
- failing to press at all.

With the clickable touchpads along with the two additional "paddle" buttons on the back of the controller, I'll demonstrate a control scheme that doesn't require moving my fingers between controls at all. TODO: link to custom controls.

<p class="note-block"><span class="note-tag">Note:</span> Most game controllers support clicking the joysticks as an input, but it usually requires a lot of force, and can be difficult to do while also pressing the joystick in a direction.</p>

## Design


### Tournament legality

If we're going to use a custom controller in tournaments, it's of course critical to ensure that it doesn't confer an unfair advantage. Fortunately, there is precedent for weird and customizable controllers at tournaments! For example, the [Smash Box](https://www.hitboxarcade.com/products/smash-box) is an "all-button arcade controller" that's been approved for several high-profile tournaments.

For local tournaments, it's sufficient to get permission from the tournament organizer. (I asked and received permission for mine.)

The main principle for a "fair" controller is that "macros" are generally forbidden. These are special physical inputs to the controller that produce multiple logical outputs, either simultaneously or successively.



* Generally, it seems fair to require 1:1 mappings from controller inputs to outputs.
* Binding a single button to press both the jump and attack buttons to produce an "aerial" attack would not be permissible.
* Binding some set of buttons to produce several "combo" outputs in sequence would not be permissible.
* For *Smash Ultimate*, I use the "short-hop button macro", where you input two jump buttons at once to do a short variation of a jump. To comply with this principle, I have actually bound two buttons on the Steam Controller, to be "jump", and I have to press both simultaneously.

In *Smash Ultimate*, some of the built-in inputs are actually macros interpreted by the game itself.



* "Grab" is the same as "regular attack" plus "shield". In these cases, we consider it fair to perform the "grab" input using one rather than two buttons, as you could input it with one button on a stock controller normally.
* There are some interesting consequences of game-interpreted macros. The "attack joystick" when pressed in a direction is usually a macro for the "regular attack" button plus the "movement joystick" being pressed in that direction. But what if you're also pressing the real movement joystick in a different direction? The game defines deterministic behavior in such cases. Players can exploit this to perform certain inputs for only one "frame" (the smallest unit of time for game simulation), which might otherwise be difficult to perform by hand.


### Button bindings

For *Smash Bros*, here are the inputs that I want to bind:



* Regular attack.
* Special attack.
* Shield.
* Grab.
    * This isn't strictly necessary, as you can also input shield+regular attack to perform a grab, but I find it convenient as a separate input. Note that *Smash Ultimate* itself lets you bind "grab" with a single button using the in-game configuration, so it's fine to also bind this as TODO
* Movement joystick
* Attack joystick (corresponding to either "tilt" or "smash" attacks, as configured in-game).
    * This isn't strictly necessary as you can also input tilt/smash attacks with the movement joystick+regular attack button, but virtually everyone uses the attack joystick for something.
* Jump.
    * This isn't strictly necessary, as you can also input a jump using the movement joystick ("stick jump"), but it's more difficult to control, and a majority of *Smash Ultimate* players seem to have disabled stick jump in-game.
* Second jump.
    * This is only necessary for people like me who use the "short-hop jump macro", which requires pressing two jump inputs at once.

In general, we require a minimum of three buttons and one joystick. In my listing above, I want to bind six buttons (regular attack, special attack, shield, grab, jump 1, jump 2) and two joysticks.

 \
With the Pro controller, I often have to move my right thumb between the attack joystick and various face buttons. This leads to frustrating misinputs where, in my haste, I press the wrong button, fail to press the button in time, or fail to press a button at all. So ideally we would define a control scheme where I never have to move my thumbs away from the touchpads.



* The alternative is, of course, to get better at performing inputs, which most players do instead.

In terms of my physical capacity, for each hand, I find it comfortable to bind shoulder button⇔index finger and paddle button⇔third finger. For two hands, this is a total of four button bindings, but leaves us two bindings short of the desired six.



* In the past, I've tried assigning an additional finger⇔additional shoulder button on each side, but I was unable to support the weight of the controller with my remaining fourth+fifth fingers. Thus, there's no chance of me assigning shoulder+shoulder+paddle per hand.

However! The touchpads on the Steam Controller are easily *clickable*, unlike the joysticks of most game controllers, so we can assign the missing two button inputs to my two thumbs — assuming that my brain can process my thumbs being responsible for both movement and button presses.



* It's important to distinguish that the touchpads can be both tapped and clicked! This is similar to the touchpads of many laptops. "Clicking" means to apply enough force that the actual surface of the touchpad depresses, while "tapping" means to simply make contact with the touchpad, without necessarily applying force.

In the end, I assigned shield+grab⇔left-hand buttons, jump+jump⇔right-hand buttons, and regular+special attacks⇔touchpad+touchpad.



* Since I have to press both jump buttons at the same time to do the short-hop macro, it's worth considering whether it's more reliable to put the two buttons on the same hand/different fingers or different hands/same finger (assuming that different hands/different fingers is worse than both of those two). Piano and [stenography experience](https://blog.waleedkhan.name/my-steno-system/) indicates that assigning to different fingers on the same hand is more reliable.
* Thus, the remaining two buttons go on the other side. If I am already pressing the shield button, I can press "grab" on the same hand, or I can perform the in-game macro by pressing the attack button, which happens to be on the other hand.


### Touchpad bindings



* TODO: mention how to do neutral A/B inputs on the touchpads.
* About
    * [Steam Controller](https://en.wikipedia.org/wiki/Steam_Controller) is hardware created by Valve, now discontinued (Nov 2015–Nov 2019).
    * Notable features:
        * Buttons on the back of the controller ("paddles"), in addition to typical controllers having buttons on the front and top.
        * Two touchpads where a traditional controller would instead have a joystick and directional pad.
        * Highly customizable haptic feedback.
        * Delightfully easy to reprogram.
    * Many of the features later appeared in the [Steam Deck](https://en.wikipedia.org/wiki/Steam_Deck) (Feb 2022), such as Ка раламодtouchpads and back buttons.
* Why use?
    * Ergonomics: larger grips — so large that other people can't even use them. [insert picture]
    * Ergonomics: the touchpads require significantly less force to use than joysticks. It requires no additional force to keep the touchpad pointing in a certain direction.
    * Reliability: Pro Controller develops stick drift (most recent one, not mentioned in post, has developed "snapback") [https://blog.waleedkhan.name/pro-controller-stick-drift/](https://blog.waleedkhan.name/pro-controller-stick-drift/). Steam Controller touchpads don't use moving parts to detect finger movement, so hopefully more reliable.
    * Precision: custom control scheme means that we can avoid moving fingers to different buttons at all.
* Legality
    * Discuss macros; 1 button in to 1 button out.
    * Secured permission from tournament organizer.
    * Discuss mashing
    * Smash is not that technical in comparison to traditional fighting games. Most inputs are highly dependent on opponent spacing and timing, while the inputs themselves tend to be refined and non-compound (e.g. move the joystick precisely forward, rather than input a six-move combo). Some characters are more technical than others. There are several guest characters from traditional fighting game series with the most technical inputs (Kazuya, Terry, Ken/Ryu).
    * Simple macro: press two jump buttons to "short-hop", instead of inputting a jump button for &lt;=3 frames. (I have already learned the two-jump-button macro, so not a problem to preserve it.)
* Building custom firmware
    * Firmware repository: [https://github.com/greggersaurus/OpenSteamController/](https://github.com/greggersaurus/OpenSteamController/). Good introduction and discussion there.
    * This person reverse-engineered the Steam Control and built custom firmware?
    * Ostensibly so that they could play custom music? \
	> Next we come to what was originally the sole intention of this project. That is, the goal of being able to have full control of the songs (Jingles) that the Steam Controller plays (via the Trackpad Haptics) on power up and shut down
    * And they also built a PowerA Nintendo Pro Controller firmware?
* Firmware problems
    * Touchpads actuate without physical contact! Need to adjust sensitivity.
        * Touchpad raw data is available as sine wave. Zero crossing represents position of finger. Amplitude represents relative distance of finger. Note that the sine wave only represents one axis; x- and y-axes are different measurements.
        * My solution at [https://github.com/greggersaurus/OpenSteamController/pull/32](https://github.com/greggersaurus/OpenSteamController/pull/32) (including custom firmware builds)
    * Large dead zone at the top of the touchpad due to 3D curvature of surface. (Also, a smaller dead zone at the left side for the same reason, but less noticeable in practice.)
        * Could have calculated virtual sphere/ellipsoid and used distance from center to determine if the finger is touching the pad.
        * But much simpler solution in [https://github.com/greggersaurus/OpenSteamController/pull/33](https://github.com/greggersaurus/OpenSteamController/pull/33)
    * ~15-degree offset
        * Arguably not a problem from an ergonomic perspective, as the thumbs will move along their natural axes, but requires getting used to.
        * Except that the physical directional pad grooves do *not* follow the 15-degree offset...
        * Resolved in [https://github.com/greggersaurus/OpenSteamController/pull/33](https://github.com/greggersaurus/OpenSteamController/pull/33).
    * No vibration.
        * Quite complicated to resolve.
        * PowerA controller constantly sends the status of the controller buttons. [Not sure about details.]
        * Nintendo controllers use a 2-way protocol (the same between wired and Bluetooth connections); see [https://github.com/dekuNukem/Nintendo_Switch_Reverse_Engineering/blob/master/bluetooth_hid_notes.md](https://github.com/dekuNukem/Nintendo_Switch_Reverse_Engineering/blob/master/bluetooth_hid_notes.md). It also supports various other features, such as other-the-air firmware upgrades.
        * I did not resolve this.
* Custom controls
    * Left touchpad used for directional stick. Triggers whenever the finger touches, not just clicks the pad. [TODO: explain that the pad can be clicked in addition to being touched?].) Click corresponds to B button.
    * Right touchpad used for right joystick. Only trigger when clicked, not just touching. Click corresponds to the A button.
    * Left shoulder (index finger): shield.
    * Left bumper (middle finger): grab.
    * Right shoulder (index finger): jump.
    * Right bumper (middle finger): second jump (note that pressing both jump buttons at the same time will input a "short hop" rather than a "full hop").
* Problems
    * Difficult to determine where finger is on touchpad. Solution: use haptic feedback to vibrate when entering the central zone. Possible enhancement: simulate "notches" to indicate when passing certain angles.
    * Fast-fall timing is wrong now (too early), ostensibly because I was previously accounting for the time it takes to physically pull the joystick down. And possibly dead zones?
    * No vibration when hitting opponent or touching ground.
    * Misinputs where I click A or B on the touchpad during frantic movement attempts.
    * Dead zones (fixed in various ways).
    * Orientation and 15-degree offset (fixed with notches). Particularly noteable when trying to turn around (or not turn around).
    * TODO: try last-known good input for dead zones?

### Virtual notches


## Implementation

### Firmware

The normal input methods rely on Steam (TODO link) to be running on the PC and interpret the inputs in software, so it can't be directly used with a gaming console such as the Nintendo Switch.

<span class="note">However:</span> The firmware is delightfully easy to reprogram: simply hold R2 and connect the Steam Controller to a computer by USB, and then drag a new `firmware.bin` file onto the device as if it were a normal mounted filesystem. Thus, if we can write our own Switch-compatible firmware, we can easily load it for use on the Steam Controller.

TODO:


* center ring is not circular since coordinates are not circular
* Last-known good dead zone needs to reset when finger no longer touching (otherwise bug when tapping top dead zone and it triggers bottom)

TODO: update script:

```

sudo bash -c 'while true; do if [[ -f /Volumes/CRP\ DISABLD/firmware.bin ]]; then echo "Updating firmware $(date)" && cat /Users/waleed/Workspace/OpenSteamController/Firmware/OpenSteamController/Debug/OpenSteamController.bin >/Volumes/CRP\ DISABLD/firmware.bin && sudo /sbin/umount /Volumes/CRP\ DISABLD && printf "Done updating\a\n"; fi; sleep 1; done'


{% include end_matter.md %}

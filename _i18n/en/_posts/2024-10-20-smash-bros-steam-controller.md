---
layout: post
title: "Playing Smash Bros. with a Steam Controller"
permalink: smash-bros-steam-controller/
series:
  next: smash-bros-steam-controller-rationale/
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
        <li>Competitive Smash players interested in alternative input methods.</li>
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
        <li>Inventive;</li>
        <li>Curious;</li>
        <li>Lamenting that it ultimately wasn't reliable enough 😭.</li>
      </ul></td>
    </tr>
  </table>
</div>

I play [*Super Smash Bros. Ultimate*](https://en.wikipedia.org/wiki/Super_Smash_Bros._Ultimate) competitively. Players usually use either a [Nintendo Switch Pro Controller](https://en.wikipedia.org/wiki/Nintendo_Switch_Pro_Controller) or [Nintendo GameCube Controller](https://en.wikipedia.org/wiki/GameCube_controller) at the competitive level.

I usually use a Pro Controller, but I've been experimenting with using a [Steam Controller](#the-steam-controller) instead.

{% image steam-controller-control-scheme-front.png "Some of the features in my custom Steam Controller control scheme for *Smash Bros.*" %}

{% include toc.md %}

## Overview

Depending on your interests, you'll prefer to read one or more of the following posts:

- [Rationale]({% permalink smash-bros-steam-controller-rationale %}): Explaining why I wanted to use a Steam Controller, including ergonomics and precision.
- [Design]({% permalink smash-bros-steam-controller-design %}): How the controller scheme is designed for *Smash Bros.* to exploit the unique hardware.
- [Implementation]({% permalink smash-bros-steam-controller-implementation %}): Technical details about the Coding and Algorithms&trade;.
- [Touch detection]({% permalink smash-bros-steam-controller-touch-detection %}): More technical details about my machine learning approach to the touch detection problem, which unfortunately remains unsolved.

## The Steam Controller

### Hardware

The [Steam Controller](https://en.wikipedia.org/wiki/Steam_Controller) was a novel video game controller created by [Valve](https://en.wikipedia.org/wiki/Valve_Corporation):

- Now discontinued. 🪦 RIP (Nov 2015–Nov 2019)
- Part of the [Steam Machine](https://en.wikipedia.org/wiki/Steam_Machine_(computer)#Steam_Controller) suite to support PC gaming in the living room.

It looks like this:

{% image steam-controller-in-package.jpg
  "Picture of a Steam Controller in its original packaging."
  "Steam Controller in its box (2015).<br />Credit: [Wikipedia user Eike sauer (CC-BY-SA-4.0)](https://commons.wikimedia.org/wiki/File:Steam_Controller_in_package.jpg)" %}

### Features

The Steam Controller supports a number of unique features:

- <span class="note-tag">Notably:</span> It has two touchpads!
  - Strategically, the touchpads were likely designed to support mouse-oriented gameplay in PC gaming.
  - Each touchpad has an associated [haptic feedback generator](https://en.wikipedia.org/wiki/Haptic_technology).
    - These can be used to produce vibration for gameplay and user-interface purposes.
    - <span class="note-tag">But also:</span> They're not restricted to "vibrations". If the implementer configures them to vibrate with a high enough frequency, then it can generate pitches in typical melodic ranges.
    - That's how the Steam Controller's "startup [jingles](https://en.wikipedia.org/wiki/Jingle)" are implemented... or [entire songs](https://www.reddit.com/r/steamcontrollermusic/).
- <span class="note-tag">Notably:</span> There are buttons on the back of the controller ("paddles" or "grips") in addition to the normal buttons on the face and shoulder of the controller.
  - This is nice since you can now recruit an additional finger from each hand into gameplay.
  - <span class="note-tag">Lately:</span> Mainstream controllers have been adopting buttons on the back as well.
- The ideas were inherited by Valve's [Steam Deck](https://en.wikipedia.org/wiki/Steam_Deck), which also has touchpads and paddles.

### Community

The Steam Controller has a small but dedicated community:

- It's surprisingly active for a discontinued product! Check out [/r/SteamController](https://www.reddit.com/r/SteamController/).
- Some users remark that the design and flexibility of the Steam Controller is uniquely accessible among game controllers.
  - <span class="note-tag">Such as:</span> Those with [tendonitis](https://www.reddit.com/r/SteamController/comments/1979eze/comment/kiw9neo/?utm_source=reddit&utm_medium=web2x&context=3) or [EEC syndrome](https://en.wikipedia.org/wiki/Ectrodactyly%E2%80%93ectodermal_dysplasia%E2%80%93cleft_syndrome).
  - <span class="note-tag">In fact:</span> Some people report that the Steam Controller is the *only* controller that they can use.

The Steam Controller is also fairly "hackable" by power users, which means that [people have already invested effort into building and provisioning custom firmware]({% permalink smash-bros-steam-controller-implementation %}).

## Customization for *Smash Bros.*

### Challenges

- **Design**: The Steam Controller features hardware capabilities which are unique among game controllers.
  - It requires some thought to design an optimal control scheme to fully exploit the hardware.
  - <span class="note-tag note-warning">Furthermore:</span> The control scheme [needs to be tournament-legal]({% permalink smash-bros-steam-controller-design %}).
- **Implementation**: The [Nintendo Switch](https://en.wikipedia.org/wiki/Nintendo_Switch) does not natively support Steam Controllers.
  - It requires implementing [custom firmware]({% permalink smash-bros-steam-controller-implementation %}).
  - Even then, there are [unresolved technical issues regarding touch detection]({% permalink smash-bros-steam-controller-touch-detection %}).

### Results

- The Steam Controller is delightful when it works!
  - It's much more comfortable:
    - See [Playing Smash Bros. with a Steam Controller: rationale]({% permalink smash-bros-steam-controller-rationale %}).
    - My large hands can grip it more comfortably.
    - The touchpads don't require constant force like joysticks do.
  - It's more precise:
    - See [Playing Smash Bros. with a Steam Controller: design]({% permalink smash-bros-steam-controller-design %}).
    - My custom control scheme eliminates an entire class of misinputs.
    - "Virtual notches" are great for precise control.
  - <span class="note-tag note-warning">Unfortunately:</span> It's still not reliable enough for tournament usage.
    - See [Playing Smash Bros. with a Steam Controller: touch detection]({% permalink smash-bros-steam-controller-touch-detection %}).
    - If you're a hardware enthusiast, maybe you could improve it?
    - <span class="note-tag">In particular:</span> In order to implement touch detection, I had to fit a 3D curve to experimentally-gathered data, but my techniques produced either too many false positives or false negatives.
- I had to write a [small amount of firmware code](https://github.com/greggersaurus/OpenSteamController/compare/master...arxanas:OpenSteamController:smash-bros).
  - See [Playing Smash Bros. with a Steam Controller: implementation]({% permalink smash-bros-steam-controller-implementation %}).
  - <span class="note-tag note-info">Fortunately:</span> Somebody else had already reverse-engineered the Steam Controller's firmware _and_ wrote a Nintendo-Switch-compatible emulation layer.
- I had to conduct a ton of experimentation.
  - <span class="note-tag">To contrast:</span> It's like I'm a real engineer, not a software engineer! I had to [take measurements and put them in a spreadsheet][steam-controller-measurements] and everything.

[steam-controller-measurements]: https://docs.google.com/spreadsheets/d/1OsZ_8aARLt2CsAgTYeFL9fWcoAd76ydiDuHzA4Uyvms/edit?usp=sharing

## Conclusion

TODO: conclude? with links to the other posts?

TODO: update date of posts in series before publishing
TODO: check all links in blog posts, because they may have been broken after splitting posts

TODO:

* center ring is not circular since coordinates are not circular

* About
    * [Steam Controller](https://en.wikipedia.org/wiki/Steam_Controller) is hardware created by Valve, now discontinued (Nov 2015–Nov 2019).
    * Notable features:
        * Buttons on the back of the controller ("paddles"), in addition to typical controllers having buttons on the front and top.
        * Two touchpads where a traditional controller would instead have a joystick and directional pad.
        * Highly customizable haptic feedback.
        * Delightfully easy to reprogram.
    * Many of the features later appeared in the [Steam Deck](https://en.wikipedia.org/wiki/Steam_Deck) (Feb 2022), such as touchpads and back buttons.
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
    * Orientation and 15-degree offset (fixed with notches). Particularly notable when trying to turn around (or not turn around).
    * TODO: try last-known good input for dead zones?


{% include end_matter.md %}

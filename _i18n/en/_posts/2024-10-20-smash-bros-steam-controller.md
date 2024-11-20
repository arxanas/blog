---
layout: post
title: "Playing Smash Bros with a Steam Controller"
permalink: smash-bros-steam-controller/
series:
  next: smash-bros-steam-controller-rationale/
tags:
  - gaming
  - hardware
  - smash-bros
---

<style type="text/css">
kbd {
  color: blue;
  font-stretch: condensed;
}
</style>

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
        <li>Inventive;</li>
        <li>Curious;</li>
        <li>Lamenting that it ultimately wasn't reliable enough 😭.</li>
      </ul></td>
    </tr>
  </table>
</div>

{% include toc.md %}

## Summary

I play *[Super Smash Bros. Ultimate](https://en.wikipedia.org/wiki/Super_Smash_Bros._Ultimate)* competitively. Players usually use either a <span class="note-braces">[Nintendo Switch Pro Controller](https://en.wikipedia.org/wiki/Nintendo_Switch_Pro_Controller) <span class="note-conj">or</span> [Nintendo GameCube Controller](https://en.wikipedia.org/wiki/GameCube_controller)</span>.

I usually use a Pro Controller, but I've been experimenting with using a [Steam Controller](#the-steam-controller) instead, for [a few reasons discussed below](#rationale).

### Overview

Depending on your interests, you'll prefer to focus on one or more of these sections:

- [Rationale](#rationale): Explaining why I wanted to use a Steam Controller, including ergonomics and precision.
- [Design](#design): How the controller scheme is designed for *Smash Bros.* to exploit the unique hardware.
- [Implementation](#implementation): Technical details about the Coding and Algorithms&trade;.
- [Machine learning for touch detection](#machine-learning-for-touch-detection): More technical details about the touch detection problem, which unfortunately remains unsolved.

### Challenges

- **Design**: The Steam Controller features hardware capabilities which are unique among game controllers.
  - It requires some thought to design an optimal control scheme to fully exploit the hardware.
  - <span class="note-tag note-warning">Furthermore:</span> The control scheme [needs to be tournament-legal](#tournament-legality).
- **Implementation**: The [Nintendo Switch](https://en.wikipedia.org/wiki/Nintendo_Switch) does not natively support Steam Controllers.
  - It requires implementing [custom firmware](#firmware).
  - Even then, there are [unresolved technical issues regarding touch detection](#machine-learning-for-touch-detection).

### Results

- The Steam Controller is delightful when it works!
  - It's much more comfortable:
    - My large hands can grip it more comfortably. TODO: link
    - The touchpads don't require constant force like joysticks do. TODO: link
  - My custom control scheme eliminates an entire class of misinputs. TODO: link
  - Virtual notches are great for precise control. TODO: link
  - <span class="note-tag note-warning">Unfortunately:</span> It's still not reliable enough for tournament usage.
    - If you're a hardware enthusiast, maybe you could improve it?
    - <span class="note-tag">In particular:</span> In order to implement touch detection, I had to fit a 3D curve to experimentally-gathered data, but my techniques produced either too many false positives or false negatives.
- I had to write a [small amount of firmware code](https://github.com/greggersaurus/OpenSteamController/compare/master...arxanas:OpenSteamController:smash-bros)
  - TODO: change above link to link to another section in this document, and add the above link there
  - <span class="note-tag note-info">Fortunately:</span> Somebody else had already reverse-engineered the Steam Controller's firmware _and_ wrote a Nintendo-Switch-compatible emulation layer.
- I had to conduct a ton of experimentation.
  - <span class="note-tag">To contrast:</span> It's like I'm a real engineer, not a software engineer! I had to [take measurements and put them in a spreadsheet][steam-controller-measurements] and everything.

[steam-controller-measurements]: https://docs.google.com/spreadsheets/d/1OsZ_8aARLt2CsAgTYeFL9fWcoAd76ydiDuHzA4Uyvms/edit?usp=sharing

## The Steam Controller

### Hardware

The [Steam Controller](https://en.wikipedia.org/wiki/Steam_Controller) was a video game controller created by [Valve](https://en.wikipedia.org/wiki/Valve_Corporation):

- Now discontinued. 🪦 RIP (Nov 2015–Nov 2019)
- Part of the [Steam Machine](https://en.wikipedia.org/wiki/Steam_Machine_(computer)#Steam_Controller) suite to support PC gaming in the living room.

It looks like this:

{% image steam-controller-in-package.jpg
  "Picture of a Steam Controller in its original packaging."
  "Steam Controller in its box (2015). Credit: [Wikipedia](https://en.wikipedia.org/wiki/File:Steam_Controller_in_package.jpg)" %}

### Features

The Steam Controller supports a number of unique features:

- <span class="note-tag">Notably:</span> It has <span class="note-braces">two touchpads and one joystick <span class="note-conj">instead of</span> two joysticks and one directional pad, like many traditional game controllers do</span>.
  - Strategically, the touchpads were likely designed to support PC-oriented gameplay.
  - Each touchpad has an associated [haptic feedback generator](https://en.wikipedia.org/wiki/Haptic_technology).
    - These can be used to produce vibration for gameplay and user-interface purposes.
    - <span class="note-tag">But also:</span> They're not restricted to "vibrations". If the implementer configures them to vibrate with a high enough frequency, then it can generate pitches in typical melodic ranges. This is how the Steam Controller's "startup [jingles](https://en.wikipedia.org/wiki/Jingle)" are implemented. TODO: link to a jingle section in this document?
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

The Steam Controller is also fairly "hackable" by power users, which means that [people have already invested effort into building and provisioning custom firmware](#firmware).

## Rationale

### Summary

There's a few main reasons why I wanted to use a Steam Controller for *Smash Bros.*:

- Ergonomics and comfort.
- Reliability of the hardware.
- Precision for competitive purposes.

### Larger grips

The most notable problem with the Pro Controller for me is this:

[TODO: insert picture holding Pro controller, comparing hand size to controller size]

My hands are too large to use a Pro controller comfortably!

- I need to support the weight of the controller primarily with my fingers rather than my palms.
- Since half my hand is always gripping tightly, rather than holding gently, it's even possible that it affects the dexterity of my free fingers.

To accommodate my hands, I've bought aftermarket grips:

[TODO: insert picture of Pro controller with grips]

<span class="note-tag">In contrast:</span> The Steam Controller more comfortably fits my hand:

[TODO: insert picture holding Steam Controller similar to the Pro controller picture before]

{% noteblock note-warning %}
<span class="note-tag note-warning">However:</span> My friends have remarked that the Steam Controller is too big for them to comfortably hold!

<span class="note-tag">For comparison:</span> The Xbox and PlayStation standard controllers seem to have gotten bigger over time, whereas the Nintendo Switch controller has not.

I wonder if it's a result of Nintendo primarily targeting a casual demographic, including a greater proportion of women and children with smaller hands on average. The issue certainly arises even within my own friend group.
{% endnoteblock %}

### Less force

Before this, I had used a Steam Controller for PC gaming, after which I realized that pushing around joysticks is much less comfortable than sliding your finger across a touchpad: <span class="note-see-next"></span>

<!-- TODO: add detailed commentary for note CSS -->
{% noteblock note-info %}
<span class="note-tag note-info">Overview:</span> When you push deeply into the joystick... the joystick pushes also into you! Ouch!
{% endnoteblock %}

{% noteblock note-info %}
<span class="note-tag note-info">Details:</span> As you push the joystick, it exerts a proportional counteracting [spring force](https://en.wikipedia.org/wiki/Hooke%27s_law) on your finger. In contrast, sliding your finger across a touchpad does not require you to counteract spring force as you move your finger, nor do you have to exert continued force just to maintain your finger in place at a certain position.
{% endnoteblock %}

I didn't realize just how much effort I spent pushing around joysticks, and I find that transitioning back from touchpads to joysticks is jarring.

### Competitive advantage

Besides the ergonomics, there's a potential competitive advantage to using touchpads instead of joysticks: <span class="note-see-next"></span>

{% noteblock note-info %}
<span class="note-tag note-info">Overview:</span> Tapping a position on the touchpad is faster than pushing the joystick to that position.
{% endnoteblock %}

{% noteblock note-info %}
<span class="note-tag note-info">Details:</span> You can perform certain inputs faster. You can position your finger physically *above* the touchpad — that is, suspended in the air and not making contact with the touchpad — to avoid triggering an input, and drop your finger onto the touchpad at the appropriate time.

- Your finger therefore has much less travel distance, and doesn't need to fight against the joystick counter-force along the whole path.
- From the perspective of the game engine, the joystick moves instantaneously from "neutral" to the target position.
- This is useful for many input sequences with precise timing windows.

<span class="note-tag">In particular:</span> In <i>Smash Bros</i>., if you're just completed a certain action, there's a meaningful difference between
<span class="note-braces">continuing to hold the joystick in its current position <span class="note-conj">versus</span> resetting the joystick to neutral, then pushing it to that position again</span>, even if the final position of the joystick is the same. <span class="note-tag">In contrast:</span> With the touchpad, it becomes trivial to reset to neutral: just raise and lower your thumb.
{% endnoteblock %}

<span class="note-tag">Amusingly:</span> I had mild trouble adjusting to the instant inputs. <span class="note-tag">For example:</span> When timing fast-falls, I would fail because I would tap the touchpad too early, because I was subconsciously adjusting for the non-existent joystick travel time.

<span class="note-tag note-warning">Of course:</span> It's important to ensure that custom hardware doesn't confer an unfair competitive advantage. See [Tournament legality](#tournament-legality) for the details.

### Custom precise controls

One common class of misinput for me is when I shift my right thumb from the joystick to press a face button. I often fail by <span class="note-braces">pressing the wrong button <span class="note-conj">or</span> pressing with delayed timing <span class="note-conj">or</span> failing to press at all</span>.

With the clickable touchpads along with the two additional "paddle" buttons on the back of the controller, I'll [demonstrate a control scheme](#control-scheme) that doesn't require moving my fingers between controls at all!

{% noteblock note-info %}
<span class="note-tag note-info">Note:</span> Most game controllers, including the Pro Controller, support clicking the joysticks, but it usually requires a lot of force. It can be unrealistic to do while simultaneously pressing the joystick in a direction.
{% endnoteblock %}

### Proprioception

<span class="note-tag note-warning">Unfortunately:</span> As I discovered later, while the touchpad requires less force than a joystick, the joystick's spring force is actually quite important for gameplay purposes: <span class="note-see-next"></span>

{% noteblock note-info %}
<span class="note-tag note-info">Overview:</span> When the joystick pushes against your finger, you can intuitively estimate where your finger is with respect to the joystick's neutral position. Not so with the touchpad!
{% endnoteblock %}

{% noteblock note-info %}
<span class="note-tag note-info">Details:</span> The joystick counter-force provides critical [proprioceptive feedback](https://en.wikipedia.org/wiki/Proprioception). The magnitude of the counteracting spring force indicates the distance from neutral, while its direction indicates the direction from neutral.

<span class="note-tag">In contrast:</span> Since the touchpad does not apply force to your finger at rest, you can't use the same proprioceptive feedback to determine where your finger is. This ended up being a problem once I tried using the touchpad for real gameplay.

<span class="note-tag">As an alternative:</span> It might be possible to add an array of tactile markings to the touchpad to serve as indication of your finger's position. I didn't see a simple way to implement this:

- I didn't want to make any permanent alterations to the touchpad.
- I didn't have a method to fabricate small and precise bumps or etchings.
- I was slightly concerned that repeatedly rubbing my finger over physical markings would cause <span class="note-braces">my finger to blister or bruise <span class="note-conj">while also</span> wearing away the markings themselves</span>. This has happened to me even with standard joysticks.

<span class="note-tag note-info">As an alternative:</span> We can replace proprioceptive feedback with [haptic feedback via "virtual notches"](#virtual-notches). I miss them when using normal joysticks!
{% endnoteblock %}

### More reliable parts

[I've complained in the past about the unreliability of Pro Controller joysticks](https://blog.waleedkhan.name/pro-controller-stick-drift/), and [others have complained about the same](https://www.reddit.com/r/SmashBrosUltimate/comments/19eizw3/i_probably_lost_so_many_sets_because_of_this/). It would be great if I could stop replacing my Pro Controller every year!

Any device with moving parts is subject to degradation over time. Hopefully, the Steam Controller's touchpads won't suffer from the same mechanical issues as joysticks because they don't use moving parts to register touches.

{% noteblock note-warning %}
<span class="note-tag note-warning">However</span>: The other mechanical components on the Steam Controller might break with extended usage. Reports from users on Steam Controller longevity vary; some have reported that the shoulder buttons are prone to failure.

If mechanical reliability were my only criterion, I would consider buying an alternative controller that uses [Hall effect](https://en.wikipedia.org/wiki/Hall_effect) sensors for joysticks.
{% endnoteblock %}

## Design

### Control scheme

Here's the control scheme I decided on.

{% image steam-controller-control-scheme-front.png "Diagrams of the bindings for the front of the Steam controllers, discussed below." "" %}

#### Front control scheme

For the front of the controller, the touchpad controls are carefully designed so that the thumbs never have to leave the touchpads:

- Left touchpad:
  - Left joystick (movement): via touch.
  - <kbd>special</kbd>: via click.
- Right touchpad:
  - Right joystick ("tilt" stick): via click.
  - <kbd>attack</kbd>: also via click.
- Clicking in the center of a touchpad produces a neutral <kbd>attack</kbd> or <kbd>special</kbd> input.
- The touchpads offer "virtual notches" for proprioceptive feedback with a center ring and eight axes. Haptic feedback is played when crossing a zone boundary:
  - When passing across an axis: small vibration.
  - When entering the center ring: large vibration.
  - When exiting the center ring: small vibration.
- The axes are offset by approximately 15 degrees to align with the direction of the thumb on the touchpad (for ergonomic reasons; optional).

{% image steam-controller-control-scheme-back.png "Diagram of the bindings for the back of the Steam controller, discussed below." "" %}

#### Back control scheme

For the back of the controller, the controls are more arbitrary, and just need to fill in the remainder of the necessary inputs:

- Left trigger: <kbd>shield</kbd>.
- Left paddle: <kbd>grab</kbd>. <span class="note-tag note-warning">Note:</span> A physical button must be bound to <kbd>grab</kbd> in the in-game settings to comply with macro rules; see [Tournament legality](#tournament-legality).
- Right trigger: <kbd>jump</kbd>.
- Right paddle: also <kbd>jump</kbd>, to enable the "short-hop" jump macro. <span class="note-tag note-warning">Note:</span> Two physical buttons must be pressed to comply with macro rules; see [Tournament legality](#tournament-legality).

### Tournament legality

If we're going to use a custom controller in tournaments, it's of course critical to ensure that it doesn't confer an unfair advantage.

- <span class="note-tag">Fortunately:</span> There is precedent for weird, customizable controllers at tournaments!
- <span class="note-tag">For example:</span> The [Smash Box](https://www.hitboxarcade.com/products/smash-box) is an "all-button arcade controller" that's been approved for several high-profile tournaments. It has no analog controls (joysticks) at all!

For local tournaments, it's sufficient to get permission from the tournament organizer. (I asked and received permission for mine.)

#### Macro rules

A **macro** is a special physical input to the controller that translates to multiple logical game inputs:

- <span class="note-tag">For example:</span> If you configured your controller so that when you pressed a single button, it produced both a jump and an attack input, that would be a macro.
- A complicated macro could perform a sequence of inputs over a short period of time, such as a "combo" input.

 The main rule for designing a "fair" controller is that macros are generally forbidden. Some examples:

- **Permissible**: Generally, a 1:1 mapping from physical controller inputs to logical game inputs is required.
- **Permissible**: Modifications to the physical orientation of the buttons on the controller seem to be allowed.
- **Permissible**: Modifications to how the buttons are physically pressed, such as reducing the travel depth or actuation force, seem to be allowed.
- **Not permissible**: Binding a single button to press both the jump and attack buttons simultaneously (producing an "aerial" attack).
- **Not permissible**: Binding some set of buttons to produce several "combo" outputs in sequence.

{% noteblock note-info %}
<span class="note-tag note-info">To complicate matters:</span> In *Smash Bros.*, some of the built-in inputs are actually macros interpreted by the game itself:

- There's a built-in <kbd>grab</kbd> button, but the game internally translates it to the combination of <kbd>shield</kbd> + <kbd>attack</kbd>
  - <span class="note-tag">In this case:</span> We consider it fair to perform the <kbd>grab</kbd> input as if it required a single input rather than multiple inputs, as you could input it with one button on a standard controller.
- For *Smash Ultimate*: I use the "short-hop" jump macro both on the Pro Controller and the Steam Controller.
  - <span class="note-tag">That is:</span> If you bind <kbd>jump</kbd> to two separate buttons, and then press them simultaneously, the game interprets it as a "short hop" instead of a "full hop".
  - To comply with the macro design principle, I have actually bound two buttons on the Steam Controller to be <kbd>jump</kbd>,
    - and I actually press both simultaneously,
    - even though it would be possible to configure the Steam Controller to press both buttons for me with a single input.

There are some interesting technical consequences of game-interpreted macros:
- <span class="note-tag">For example:</span> The "attack joystick" when pressed in a direction is usually a macro for the <kbd>attack</kbd> button plus a directional input for the attack.
- But what if you're also providing a conflicting directional input with the other physical joystick?
  - The game defines deterministic behavior in such cases.
  - Players can exploit this to perform certain inputs for only one "frame" (the smallest unit of time for game simulation), which might otherwise be difficult to perform by hand.
{% endnoteblock %}

### Button bindings

For *Smash Bros.*, here are the inputs that I need to bind:

- Regular attack.
- Special attack.
- Shield.
- Grab.
  - <span class="note-tag">Not strictly necessary:</span> You can also input <kbd>shield</kbd>+<kbd>attack</kbd> to perform a grab, but I find it convenient as a separate input.
  - <span class="note-tag">Note:</span> *Smash Ultimate* itself lets you bind <kbd>grab</kbd> to a single button using the in-game configuration, rather than requiring <kbd>shield</kbd>+<kbd>attack</kbd>. So binding a single physical button to the single in-game <kbd>grab</kbd> button is allowed, as long as you actually go and configure it in-game.
- Movement joystick.
- Attack joystick.
  - Corresponds to either <kbd>tilt</kbd> or <kbd>smash</kbd> attacks, as configured in the player's settings.
  - <span class="note-tag">Not strictly necessary:</span> You can also input <kbd>tilt</kbd>/<kbd>smash</kbd> attacks with the movement joystick combined with the <kbd>attack</kbd> or <kbd>special</kbd> button, but virtually everyone uses the attack joystick for one or the other.
- Jump.
  - <span class="note-tag">Not strictly necessary:</span> You can also input <kbd>jump</kbd> using the movement joystick ("stick jump").
  - <span class="note-tag">But:</span> Stick jump is more difficult to control, and a majority of *Smash Ultimate* players seem to have disabled it in their settings.
- Second <kbd>jump</kbd>.
  - <span class="note-tag">Not strictly necessary:</span> This is only necessary for people like me who use the "short-hop" jump macro, which requires pressing two <kbd>jump</kbd> inputs at once.

{% noteblock note-info %}
<span class="note-tag note-info">At a minimum:</span> A player requires three buttons and one joystick.
{% endnoteblock %}

In my listing above, I want to bind six buttons (<kbd>attack</kbd>, <kbd>special</kbd>, <kbd>shield</kbd>, <kbd>grab</kbd>, <kbd>jump</kbd> 1, <kbd>jump</kbd> 2) and two joysticks, with some additional constraints. <span class="note-see-next"></span>

{% noteblock note-info %}
<span class="note-tag note-info">Problem:</span> With the Pro controller, I often have to move my right thumb between <span class="note-braces">the attack joystick <span class="note-conj">and</span> the various face buttons</span>. This leads to frustrating misinputs where, in my haste, I <span class="note-braces">press the wrong button <span class="note-conj">or</span> fail to press the button in time <span class="note-conj">or</span> fail to press a button at all</span>.

<span class="note-tag note-info">Solution:</span> Ideally, we define a control scheme where I never have to move my thumbs away from the touchpads.

<span class="note-tag note-warning">As an alternative:</span> Of course, I could simply get better at performing inputs, which most players do instead. Not me, though 😎.
{% endnoteblock %}

{% noteblock note-info %}
<span class="note-tag note-info">Problem:</span> Experimentation has determined that I need at least two fingers from each hand to hold the controller and support its weight, which limits how many fingers remain to be assigned to buttons.

<span class="note-tag">Note:</span> Despite the paddles being on the back of the controller, it requires too much dexterity for me to assign certain fingers to both operate the paddles *and* support the controller weight.

With <span class="note-braces">my thumbs being assigned to the touchpads (and assuming that we don't want them to leave the touchpads, to satisfy the previous constraint) <span class="note-conj">and</span> my fourth and fifth fingers being used to support the controller</span>, only my first and second fingers remain to be assigned to buttons. But that means there's only four free fingers to assign to six buttons. What to do?

<span class="note-tag note-info">Solution:</span> It's quite easy to *click* the touchpads on the Steam Controller, so we can assign the missing two button inputs to my two thumbs clicking the touchpads.

- <span class="note-tag">Note:</span> It's possible to click most game controller joysticks, but it requires much more force and isn't feasible as a frequent input.
- <span class="note-tag">Assuming that:</span> My brain can handle my thumbs being responsible for both movement and button presses. So far, it seems like it can!
- <span class="note-tag note-info">It's important to distinguish:</span> The Steam Controller touchpads can be both tapped and clicked!
  - This is similar to the touchpads of many laptops.
  - "Clicking" means to apply enough force that the actual surface of the touchpad depresses.
  - "Tapping" means to simply make contact with the touchpad, without necessarily applying force.
  - TODO: link to something about touch detection and remark the the touchpads can't be tapped?
{% endnoteblock %}

In the end, I assigned:

- <kbd>jump</kbd>+<kbd>jump</kbd>⇔right-hand buttons
  - <span class="note-tag">Question:</span> I'm pressing the two separate <kbd>jump</kbd> buttons at the same time to perform the "short-hop" jump macro. Should the two buttons be assigned to the same or different hands? 
  - <span class="note-tag">Answer:</span> Piano and [stenography experience](https://blog.waleedkhan.name/my-steno-system/) indicates that assigning to the same hand is more reliable.
  - I assigned one of the <kbd>jump</kbd> buttons to the right paddle and the other <kbd>jump</kbd> button to the right trigger.
  - <span class="note-tag">In the past:</span> I once tried putting them both on the bumper and trigger buttons on the shoulder of the controller, but I found it taxing and stressful for my fingers. Using the paddle is much less stressful.
- <kbd>shield</kbd>+<kbd>grab</kbd>⇔left-hand buttons
  - <span class="note-tag">By elimination:</span> The remaining two buttons go on the other side. If I am already pressing the shield button, I can choose to either <span class="note-braces">press "grab" on the same hand, <span class="note-conj">or</span> I can perform the in-game macro by pressing the <kbd>attack</kbd> button, which happens to be on the other hand</span>.
  - I assigned the <kbd>grab</kbd> button to the left paddle and the <kbd>shield</kbd> button to the left trigger, somewhat arbitrarily.
- <kbd>regular</kbd>+<kbd>special</kbd>⇔touchpad+touchpad as discussed in [Touchpad bindings](#touchpad-bindings).

### Touchpad bindings

TODO: point out that A button is on opposite touchpad as movement so that you can reverse certain attacks easily (like backward aerials).

TODO: mention how to do neutral A/B inputs on the touchpads.

TODO

### Virtual notches

TODO

## Implementation

### Summary

My version of the firmware is available on [my `smash-bros` branch of my OpenSteamController repository fork](https://github.com/arxanas/OpenSteamController/tree/smash-bros).

I implemented my own firmware on top of the [OpenSteamController firmware](https://github.com/greggersaurus/OpenSteamController) and fixed several issues. Then I implemented my custom control scheme on top of it. TODO: link to control scheme section

{% noteblock note-warning %}
<span class="note-tag note-warning">However:</span> Touch detection ultimately turned out to be a difficult problem, and I was unable to resolve it with a degree of reliability that I considered suitable for competitive gameplay. TODO: link to machine learning section

If you have any ideas on how to resolve this issue, I'd love to hear them!
{% endnoteblock %}

### Firmware

The normal input methods rely on Steam (TODO link) to be running on the PC and interpret the inputs in software, so it can't be directly used with a gaming console such as the Nintendo Switch.

<span class="note-tag note-info">However:</span> The firmware is delightfully easy to reprogram: <span class="note-braces">simply hold R2 while connecting the Steam Controller to a computer by USB, <span class="note-conj">and then</span> copy the new `firmware.bin` file onto the device as if it were a normal mounted filesystem</span>.

<span class="note-tag">Thus:</span> If we can somehow write our own Switch-compatible firmware, we can easily load it for use on the Steam Controller.

I ran this terminal command to <span class="note-braces">wait for the Steam Controller to be connected <span class="note-conj">and then</span> automatically load the latest firmware onto it</span>:

```console
sudo bash -c 'while true; do if [[ -f /Volumes/CRP\ DISABLD/firmware.bin ]]; then echo "Updating firmware $(date)" && cat /Users/waleed/Workspace/OpenSteamController/Firmware/OpenSteamController/Debug/OpenSteamController.bin >/Volumes/CRP\ DISABLD/firmware.bin && sudo /sbin/umount /Volumes/CRP\ DISABLD && printf "Done updating\a\n"; fi; sleep 1; done'
```

### The OpenSteamController project

The [OpenSteamController project](https://github.com/greggersaurus/OpenSteamController) is a reverse-engineering effort which already figured out how to reprogram the Steam Controller's firmware. I was able to use the instructions directly to build my own firmware.

<span class="note-tag note-info">Incredibly:</span> The original intention of the OpenSteamController project was [just to reprogram the "jingles" that play on the device](https://github.com/greggersaurus/OpenSteamController?tab=readme-ov-file#the-open-steam-controller-project):

> Next we come to what was originally the sole intention of this project. That is, the goal of being able to have full control of the songs (Jingles) that the Steam Controller plays (via the Trackpad Haptics) on power up and shut down. Due to some discoveries via the Reverse Engineering effort, this project allows for Jingles to be fully customized and for these customizations to persist while still running Valve's official firmware.

But the ultimate scope is quite expansive, including a full implementation of ["PowerA"](https://en.wikipedia.org/wiki/PowerA)-style Nintendo Pro Controller firmware! I just had to fix a few bugs and usability issues.

### Upstream issues

#### Touch detection

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

#### Dead zones

The touchpad surfaces are actually *curved* rather than flat. The curvature is greatest at the outer edges of the touchpad, the curvature is greatest. At the top edge, it seems like the touchpad often doesn't register touches.

<span class="note-tag">Originally:</span> I was going to try to model the curvature of the touchpad as an ellipsoid in 3D space and adjust the touch detection amplitude threshold accordingly, but that sounded quite complicated.

<span class="note-tag">Fortunately:</span> One user opened a [pull request](https://github.com/greggersaurus/OpenSteamController/pull/33) with a much simpler approach where they detect a failure to read the y-position of the touchpad coordinate and replace it with the y-position for the top of the touchpad.

<span class="note-tag">In practice:</span> That approach seems to work fairly well, so I adopted it in my own firmware.

#### Angle offset

The hardware seems to offset touchpad measurements by about 15° inward.

- <span class="note-tag">To illustrate:</span> Check the angling on the virtual notch axes in the [control scheme diagram](#control-scheme) and see how the axes align with the grip of the controller rather than rectangular body of the controller.
- <span class="note-tag">For example:</span> If you place your thumb at the top of the right touchpad, then the actual input will be slightly to the right of the top-most position.
- <span class="note-tag">Interestingly:</span> The left touchpad has tactile grooves in the shape of a directional pad, but they don't align with the 15° offset!

I suspect that this is a deliberate design decision so that the touchpad is aligned with the natural direction of the thumb at rest.

- With this design, natural movements of the thumb directly correspond to movements along the hardware axes.
  - <span class="note-tag">In contrast:</span> When using a Pro Controller, I have to manually adjust my thumb movement to be parallel to the controller body, which is diagonal to my thumb's natural movement axis.
- I never noticed the offset when using the Steam Controller for PC gaming. <span class="note-braces"><span class="note-conj">Either</span> the offset is not present in the official firmware, <span class="note-conj">or</span> it's natural and intuitive and therefore not noticeable for casual use.</span>

I elected to keep the angle offset as-is, as it seems like it might have both ergonomic and competitive advantages. <span class="note-tag">However:</span> One user opened a [pull request](https://github.com/greggersaurus/OpenSteamController/pull/33) with an example of how to undo the offset.

#### Vibration support

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
<span class="note-tag note-info">In practice:</span> Many pro players use GameCube Controllers, which only have one possible setting for vibration intensity. After having tried a GameCube Controller myself, I agree with their assessment that it's unusably disruptive and provides limited value compared to the Pro Controler's fine-grained haptic feedback.

<span class="note-tag">Therefore:</span> Having effective haptic feedback is better than not having it, but even the highest levels of play can be achieved without it (and I am nowhere close).
{% endnoteblock %}

### My issues

For fun, here's some bugs that I inflicted upon myself during firmware development:

- **Elliptical neutral zone**: I had intended the center neutral zone to be a circle with 50% of the radius of the entire touchpad, but I accidentally made it an ellipse at first.
  - **Symptom**: It was weirdly difficult to perform neutral inputs in one axis, but not the other.
  - **Cause**: The coordinates for the touchpad axes aren't measured on the same scale. The x-values range from 0 to 1200, while the y-values range from 0 to 700. (I don't know why this is.) My calculation didn't accommodate for this; possibly it used one of the ranges for both axes.
  - **Fix**: I first normalized the distances on each axis from the center to be a percentage of the maximum distance on that axis, then checked if the coordinate was contained within a circle of radius 50.
- **Denoising failure**: I tried two different systems for denoising measurements: taking the <span class="note-braces">minimum <span class="note-conj">and</span> average</span> of the last few measurements.
  - **Symptom**: Spurious inputs were being registered with one denoising system but not the other. This ruined the results of certain experiments when I couldn't understand the results compared to the raw measurements.
  - **Cause**: I had copied-and-pasted the minimum calculation loop to start writing the average calculation loop, but forgot to change the initial average amplitude to zero (from `historicalTrackpadAmplitudes[trackpad][0]`). This resulted in the calculated average amplitude being a factor of 1/3 greater than it should have been (since I had set `n = 3` historical amplitudes).
  - **Fix**: I set the initial average amplitude to zero.
- **Dead zone misinputs**: When a touch is registered in one axis but not the other, it's assumed that the other axis's measurement was caught in a "dead zone". The last-known position of the finger in that axis is used instead as a heuristic, with the idea that most finger positions will be not be far from their immediately subsequent positions.
  - **Symptom**: Certain inputs would have the wrong direction altogether in one of the axes. Concretely, many of my up-aerials were coming out as down-aerials.
  - **Cause**: The last-known position of the finger would be retained even when the finger had left the touchpad, in which case the next position might be somewhere completely different. When the next position happened to be distant from the previous position, it would manifest in an egregious manner, such as switching the direction of the input in one axis entirely.
  - **Fix**: I transitioned the last-known position of the finger to an "invalid" state when the finger was no longer detected on the touchpad.

### TODO

TODO:

* center ring is not circular since coordinates are not circular

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

## Machine learning for touch detection

TODO: likely not a fundamental issue because the stock firmware seems to work fine with PC gaming (as far as I could tell).

TODO

{% include end_matter.md %}

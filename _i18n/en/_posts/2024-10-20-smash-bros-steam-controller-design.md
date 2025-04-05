---
layout: post
title: "Playing Smash Bros. with a Steam Controller: design"
permalink: smash-bros-steam-controller-design/
series:
  prev: smash-bros-steam-controller-rationale/
  next: smash-bros-steam-controller-implementation/
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

TODO: Include short blurb before TOC; make sure to link back to main post

{% include toc.md %}

## Control scheme

Here's the control scheme I decided on. See [Assigning the bindings](#assigning-the-bindings) for the details of how I arrived at this scheme.

### Front control scheme

{% image steam-controller-control-scheme-front.png "Diagrams of the bindings for the front of the Steam controllers, discussed below." "" %}

For the front of the controller, the touchpad controls are carefully designed so that the thumbs never have to leave the touchpads:

- Left touchpad:
  - Left joystick (movement): via touch.
  - <kbd>special</kbd>: via click.
- Right touchpad:
  - Right joystick ("tilt" stick): via click.
  - <kbd>attack</kbd>: also via click.
- Clicking in the center of a touchpad produces a neutral <kbd>attack</kbd> or <kbd>special</kbd> input.
- The touchpads offer ["virtual notches"](#virtual-notches) for proprioceptive feedback with a center ring and eight axes. Haptic feedback is played when crossing a zone boundary:
  - When passing across an axis: small vibration.
  - When entering the center ring: large vibration.
  - When exiting the center ring: small vibration.
- The axes are offset by approximately 15 degrees to align with the direction of the thumb on the touchpad (for ergonomic reasons; optional).

### Back control scheme

{% image steam-controller-control-scheme-back.png "Diagram of the bindings for the back of the Steam controller, discussed below." "" %}

For the back of the controller, the controls are more arbitrary, and just need to fill in the remainder of the necessary inputs:

- Left trigger: <kbd>shield</kbd>.
- Left paddle: <kbd>grab</kbd>. <span class="note-tag note-warning">Note:</span> A physical button must be bound to <kbd>grab</kbd> in the in-game settings to comply with macro rules; see [Tournament legality](#tournament-legality).
- Right trigger: <kbd>jump</kbd>.
- Right paddle: also <kbd>jump</kbd>, to enable the "short-hop" jump macro. <span class="note-tag note-warning">Note:</span> Two physical buttons must be pressed to comply with macro rules; see [Tournament legality](#tournament-legality).

## Tournament legality

If we're going to use a custom controller in tournaments, it's of course critical to ensure that it doesn't confer an unfair advantage.

- <span class="note-tag">Fortunately:</span> There is precedent for weird, customizable controllers at tournaments!
- <span class="note-tag">For example:</span> The [Smash Box](https://www.hitboxarcade.com/products/smash-box) is an "all-button arcade controller" that's been approved for several high-profile tournaments. It has no analog controls (joysticks) at all!

For local tournaments, it's sufficient to get permission from the tournament organizer. (I asked and received permission for mine.)

### Macro rules

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

## Assigning the bindings

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

## Virtual notches

The GameCube Controller design includes an octagonal "gate" around each joystick to provide tactile feedback for the eight cardinal directions.

{% image gamecube-controller.png "Picture of a Nintendo GameCube Controller." "GameCube controller. Notice the octagonal shapes around the joysticks.<br />Credit: [Wikipedia user Evan-amos (CC BY-SA 3.0)](https://commons.wikimedia.org/w/index.php?curid=11422462)" %}

This is especially useful for *Smash Bros.*, where precise directional inputs are required for competitive play.

The octagonal gates are not present in the Pro Controller design. <span class="note-tag">In fact:</span> Some users even mod their Pro Controllers to add the octagonal gates!

TODO: explain further significance and implementation

{% include end_matter.md %}

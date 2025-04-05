---
layout: post
title: "Playing Smash Bros. with a Steam Controller: rationale"
permalink: smash-bros-steam-controller-rationale/
series:
  prev: smash-bros-steam-controller/
  next: smash-bros-steam-controller-design/
tags:
  - gaming
  - hardware
  - health
  - smash-bros
---

There's a few main reasons why I wanted to [use a Steam Controller to play *Super Smash Bros. Ultimate*]({% permalink smash-bros-steam-controller %}):

- Ergonomics and comfort.
- Precision for competitive purposes.
- Reliability of the hardware.

{% include toc.md %}

## Ergonomics

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

## Precision

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

<span class="note-tag">In particular:</span> In <i>Smash Bros.</i>, if you're just completed a certain action, there's a meaningful difference between
<span class="note-braces">continuing to hold the joystick in its current position <span class="note-conj">versus</span> resetting the joystick to neutral, then pushing it to that position again</span>, even if the final position of the joystick is the same. <span class="note-tag">In contrast:</span> With the touchpad, it becomes trivial to reset to neutral: just raise and lower your thumb.
{% endnoteblock %}

<span class="note-tag">Amusingly:</span> I had mild trouble adjusting to the instant inputs. <span class="note-tag">For example:</span> When timing fast-falls, I would fail because I would tap the touchpad too early, because I was subconsciously adjusting for the non-existent joystick travel time.

<span class="note-tag note-warning">Of course:</span> It's important to ensure that custom hardware doesn't confer an unfair competitive advantage. See [*Playing Smash Bros. with a Steam Controller: design*]({% permalink smash-bros-steam-controller-design %}) for the details.

### Custom precise controls

One common class of misinput for me is when I shift my right thumb from the joystick to press a face button. I often fail by <span class="note-braces">pressing the wrong button <span class="note-conj">or</span> pressing with delayed timing <span class="note-conj">or</span> failing to press at all</span>.

With the clickable touchpads along with the two additional "paddle" buttons on the back of the controller, I'll [demonstrate a control scheme]({% permalink smash-bros-steam-controller-design %}) that doesn't require moving my fingers between controls at all!

{% noteblock note-info %}
<span class="note-tag note-info">Note:</span> Most game controllers, including the Pro Controller, support clicking the joysticks, but it usually requires a lot of force. It can be unrealistic to do while simultaneously pushing the joystick in a direction.
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
{% endnoteblock %}

<span class="note-tag note-info">As an alternative:</span> We can replace proprioceptive feedback with [haptic feedback via "virtual notches"]({% permalink smash-bros-steam-controller-design %}). I miss them when using normal joysticks!

## Reliability

### More reliable parts

[I've complained in the past about the unreliability of Pro Controller joysticks](https://blog.waleedkhan.name/pro-controller-stick-drift/), and [others have complained about the same](https://www.reddit.com/r/SmashBrosUltimate/comments/19eizw3/i_probably_lost_so_many_sets_because_of_this/). It would be great if I could stop replacing my Pro Controller every year!

Any device with moving parts is subject to degradation over time. Hopefully, the Steam Controller's touchpads won't suffer from the same mechanical issues as joysticks because they don't use moving parts to register touches.

{% noteblock note-warning %}
<span class="note-tag note-warning">However</span>: The other mechanical components on the Steam Controller might break with extended usage. Reports from users on Steam Controller longevity vary; some have reported that the shoulder buttons are prone to failure.

If mechanical reliability were my only criterion, I would consider buying an alternative controller that uses [Hall effect](https://en.wikipedia.org/wiki/Hall_effect) sensors for joysticks.
{% endnoteblock %}

## Conclusion

There's a lot of compelling reasons for me to prefer a Steam Controller. TODO

{% include end_matter.md %}

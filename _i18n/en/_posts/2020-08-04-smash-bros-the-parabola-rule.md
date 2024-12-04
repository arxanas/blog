---
layout: post
title: "Smash Bros.: the parabola rule"
permalink: smash-bros-parabola-rule/
tags:
  - gaming
  - smash-bros
---

{% include toc.md %}

This is a simple mistake that I used to make as a beginner. It took surprisingly long to realize the precise nature of the mistake, so I'm posting about it here.

Suppose you're landing and trying to avoid an opponent. You want to avoid their "threat bubble" while landing: the maximum range that their attacks can reach in the time it takes you to land.

{% image 1-threat-bubble.png
   "The red player is in the air, while the blue player is on the ground, projecting a threat bubble." %}

So naturally, you drift to the side to avoid their threat bubble.

{% image 2-landing-arc.png
   "Red player's planned trajectory, drifting to the side to avoid the blue player." %}

The ideal landing position would be as close to center stage as possible, while still staying outside of their threat bubble.

{% image 3-threat-bubble-and-circular-arc.png
   "The red player's expected trajectory is tangent to the blue player's threat bubble. The trajectory does not pass through the threat bubble, meaning that it's a safe landing: the blue player cannot reach the red player and hit them as they land." %}

So what's wrong with this image? It's hard to tell, but the problem is that it depicts a **circular landing arc**. But characters in *Smash Bros.* don't typically travel in circular arcs. At the top of the arc, your velocity will be close to zero horizontally, and you'll be increasing it as gravity pulls you downward. With a circle, your velocity stays the same, but your direction changes the entire way down.

The actual trajectory of the player is closer to a parabola. Let's look at what a parabolic arc might look like.

{% image 4-threat-bubble-and-parabolic-arc.png
   "The red player's *actual* trajectory is a wider arc. Notice that the landing position is farther away from the blue player than in the previous diagram." %}

There's a constant downward force provided by gravity, accelerating you to a maximum downward velocity. However, your horizontal velocity increases as you go farther down. Furthermore, as you pass the point where your trajectory intersects the threat bubble, you'll want to reverse your acceleration to be *towards* center stage, so that you give up as little space as possible to the opponent.

If we thought that our trajectory was circular, not parabolic, and tried to aim towards the same "safe" spot on the ground as in the previous circular arc diagram, we would actually slightly enter the opponent's threat bubble:

{% image 5-threat-bubble-and-real-circular-arc.png
   "If the red player aims towards the circular arc's landing position, but actually has a parabolic arc, then they'll slightly pass through the blue player's threat bubble." %}

This difference is so minute, it's easy to not realize what's going on with your player's trajectory, and get hit while landing.

To fix this problem, we need to apply **the parabola rule**:

* Aim for a spot farther away on the ground than you think is appropriate (until you've internalized how far away is actually appropriate).
* DI outwards all the way down, until you reach the tangent point between your arc and your opponent's threat bubble. Then you are free to start DI-ing inwards.
* Do not fast-fall until you've cleared the tangent point! Otherwise, you may accidentally fall through the threat bubble earlier than expected.
  * This issue is something I'm still working on. Fast-falling gets you to the ground faster, so it intuitively feels safer (particularly considering that I main a fast-falling character). But it can actually be a worse choice than drifting as far as possible away from the opponent, and not fast-falling at all.

{% include end_matter.md %}

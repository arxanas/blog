---
layout: post
title: 'On Pro Controller stick drift'
permalink: pro-controller-stick-drift/
tags:
  - gaming
  - smash-bros
reddit: https://www.reddit.com/r/CrazyHand/comments/m2599t/on_pro_controller_stick_drift/
---

The Nintendo Switch Pro Controller is one of the main controllers used for competitive *Smash Bros.* play. Most players use either the Pro Controller or a GameCube controller.

These controllers are prone to *stick drift*: a phenomenon where inputs are registered for a control stick in a certain direction, despite the control stick being pressed in a different direction or not at all. As one can expect, this would significantly impair gameplay at the competitive level, and is frustrating at even the casual level.

This post is a brief summary of stick drift problems, which may be relevant to those interested in playing *Smash Bros.* (particularly *Ultimate*) competitively.

{% include toc.md %}

## Reputation

Original GameCube controllers, produced contemporaneously with the original GameCube, have a reputation of rock-solid reliability. Many players use their old GameCube controllers to this day. At the time of this writing, such controllers sell for USD ~70 used or USD ~200 new on eBay and Amazon, which is significantly more than their original MSRP.

Unfortunately, both modern Pro Controllers and GameCube controllers are plagued with reliability issues. The build quality in Nintendo's controller manufacturing processes seems to have dropped significantly since the time of the original GameCube controller.

[Anecdotal experiences with Pro Controller stick drift](https://www.reddit.com/r/NintendoSwitch/comments/cj0au7/has_anyone_experienced_drift_on_the_pro_controller/) vary from "no issues after several hundred hours of use" to "several of my pro controllers have drift". Generally, issues arise with the left control stick, which sees more use. See also [My experience](#my-experience).

One could try a third-party controller. However, they are generally cheaper and have a reputation of inferior build quality, battery life, etc. They also tend to feel different than first-party Pro Controllers, so it may take a while to adjust when switching between them.

## Warranty

In the US, the Pro Controller's warrant period is only 30 days. This is a shameful support period time for a device that should last several years.

[Complaints have been filed in the EU][eu-complaints] about Nintendo's shoddy controllers, suggesting that controllers should last approximately the lifetime of the console itself:

> Nintendo is thus artificially creating an aftermarket in a sector in which this should not be the case, in a sector in which the average consumer should not expect the lifespan for the game controllers to be more limited than that of the console and does in any event not take into account the eventual cost of repair or replacement of game controllers when buying the console.

  [eu-complaints]: https://www.beuc.eu/publications/beuc-x-2021-002_nintendo_-_premature_obsolescence_complaint_to_the_ec.pdf

You can opt to have Nintendo repair a malfunctioning Pro Controller for around USD 30, or half the MSRP. Some players report that the problems persist even after sending their controller to Nintendo. At these prices, it may not make sense to risk a repair that might not fix the problem.

Some vendors sell additional insurance for a small fee on top of the controller. Walmart offers up to 3 years of insurance for USD 7, which is a significantly better price than Nintendo's offered repair price. I recently purchased a new Pro Controller from Target with the same insurance plan, but I have not yet filed a claim with it. This may be more economical than suffering through the official repair process. At my controller failure rates, this should be a good investment (see [My experience](#my-experience)).

## My experience

I have now purchased three Pro controllers, all of which have started exhibiting downward drifting of the left control stick by the 900-hour mark in *Smash Ultimate*. So I go through them at a rate of about one controller (USD 60) per 300 hours.

By now, they are all in various states of usability. One is completely unusable (the stick drifts down at all times), one has frequent stick drift (which makes it only reasonable for casual play), and one has mild stick drift (which I can use to practice, but which sometimes causes premature deaths anyways).

## Possible causes

There are two main theories for stick drift in the Pro controller:

1. The analog stick sensor wheel component used in modern controllers is simply not durable compared to older controllers.
2. The grinding of the stick against the enclosure, particularly during mashing, causes an accumulation of white dust which impairs the sensor.

Both are consistent with the left control stick being particularly vulnerable, since it sees significantly more use than the right control stick during normal play.

## Prevention

To prevent the first issue, one could in principle replace the analog sensor immediately with a more reliable one, but I had difficulty doing this (see [Manual repair](#manual-repair)).

To prevent the second issue, one can wrap the left control stick with a piece of tape, so that it doesn't produce dust when grinding against its enclosure.

I have also taken to labeling my controllers and using only a certain controller for competitive play. This ensures that load is primarily focused on one controller so as to diagnose stick drift more easily, as it starts out sporadically at first. It also leaves a maximum number of functioning controllers available for multiplayer casual play.

One could also use one of the known-good controllers for tournaments to ensure there's no stick drift at the least opportune time, while using one of the heavily-loaded controllers for practice, when it's less of an issue.

## Manual repair

To resolve the first issue by replacing the analog stick sensor wheel, I followed the guide at [Nintendo Switch Pro Controller PERMANENT Fix](https://www.reddit.com/r/NintendoSwitch/comments/bscoz9/nintendo_switch_pro_controller_analog_stick/), but it **did not** work for me. It claimed that the analog stick sensor wheel would not be soldered into place, and could be easily replaced. However, when I opened up my Pro Controller, I found that it was indeed soldered into place, so I couldn't remove it.

Nonetheless, the above document is still a good reference for Pro Controller internals and repair, as it includes instructions to open the Pro Controller and a discussion of the relevant components, with many pictures.

To resolve the second issue, one can clean out dust and debris using electric contact cleaner or compressed air. This is a relatively cheap and simple fix to carry out, and many people have reported that it fixes their stick drift for a reasonable length of time.

{% include end_matter.md %}

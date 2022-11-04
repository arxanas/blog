---
layout: post
title: Playing Elden Ring in the cloud
permalink: playing-elden-ring-in-the-cloud/
tags:
  - gaming
---

## Playing Elden Ring in the cloud

_[Elden Ring](https://en.wikipedia.org/wiki/Elden_Ring)_ was recently released for Windows, Playstation, and Xbox. I don’t own any of those platforms (and don’t want to buy one), but I still wanted to play, so I decided to run the game remotely and stream it to my household.

{% aside What about the latency? %}
There's necessarily more latency when streaming games than when playing locally. I can expect an additional ~50ms round-trip to my nearest AWS datacenter (us-west-2). Elden Ring doesn't require much in terms of low latency: during combat, most attacks have long startup animations during which you can react, for which 50ms is not noticeable. But various other real-time games are sensitive to that amount of latency to the point where it would not be reasonable to play competitively via stream.
{% endaside %}


### Managed gaming services

I evaluated a number of managed services for on-demand gaming. I would prefer to buy Elden Ring for PC since that’s most likely to let me retain ownership even across devices or platforms, but I would play on a console or rent the game if the experience was good.



* [Xbox Game Pass](https://www.xbox.com/en-US/xbox-game-pass)
    * The game selection is limited, and it doesn't support Elden Ring.
* [Playstation Now](https://www.playstation.com/en-us/ps-now/)
    * The game selection is limited, and it doesn't support Elden Ring.
    * I had also previously tried it for a PS2 game and the experience was laggy and buggy.
* [Amazon Luna](https://www.amazon.com/luna/landing-page)
    * The game selection is limited, and it doesn't support Elden Ring.
* [Google Stadia](https://stadia.google.com/)
    * The game selection is limited, and it doesn't support Elden Ring.
    * Google has since announced that Stadia is shutting down.
* [Nvidia GeForce Now](https://www.nvidia.com/en-us/geforce-now/)
    * The game selection is limited. Despite supporting many PC games, it doesn't support Elden Ring.

So none of these options were suitable, which was disappointing. The latest summary of cloud availability can be found at [https://cloudbase.gg/g/elden-ring/](https://cloudbase.gg/g/elden-ring/).


### Renting directly from cloud providers

I’d probably have to use general-purpose computing to play specific PC games I owned. You can rent GPUs and Windows machines on-demand, so surely you can use them to play video games, too?

I found the [CloudyGamer](https://www.reddit.com/r/cloudygamer/) community focused on tackling the same problem. One solution was [cloudygamer.com](https://cloudygamer.com/): a self-service app to start and stop a gaming [virtual machine](https://en.wikipedia.org/wiki/Virtual_machine) on [AWS](https://en.wikipedia.org/wiki/Amazon_Web_Services). This looked promising, and I spent a considerable amount of time trying to provision a virtual machine using it. But in the end, I wasn’t able to provision a suitable VM even directly from the AWS web interface — I have no idea why. I wrote up details at [https://github.com/lg/cloudy-gamer/issues/35](https://github.com/lg/cloudy-gamer/issues/35).


### Managed cloud PC services

Instead, I ended up trying several cloud PC services:



* [Shadow](https://shadow.tech/)
    * Pricing: $30/month for unlimited usage.
    * However, your connection times out after 30 minutes of inactivity, as measured by the custom streaming client. Thus, using an alternate client such as Steam Remote Play will cause you to get disconnected unless you periodically perform manual inputs at your computer.
    * Most recently, forwarding my [Nintendo Switch Pro Controller](https://www.nintendo.com/store/products/pro-controller/) over USB via the streaming client doesn’t work; however, I can use Steam Remote Play to successfully forward the controller inputs. That means that I have two concurrent streams to my computer while playing.
* [Shrine](https://shrine.app/)
    * Usage pricing: Between $0.65/hour and $1.90/hour (depending on machine specs). Storage pricing: $0.01/100 GB/hour (~$7.30/100 GB/month).
    * The pricing and usage model has changed several times since I started using it.
    * Most recently, it had somewhat poor latency from US-West Las Vegas (to Seattle).
* [Airgpu](https://airgpu.com/)
    * Usage pricing: Between $0.65/hour and $1.15/hour (depending on machine specs). Storage pricing: $3.50/50 GB/month ($7.00/100 GB/month).
    * Most recently, audio doesn’t work when used with Steam Remote Play.

All of these services have been problematic in one way or another. Software solutions that used to work tend to later break. Shadow has been the most reliable overall, but it’s also the most limited since you have to use their streaming client.


### Playing in the living room

Next, I wanted to stream to my living room TV. I had a [Steam Link](https://en.wikipedia.org/wiki/Steam_Link) device which I purchased a long time ago, which I connected to my Steam account. I paired my Pro Controller and used Steam Remote Play to connect to the remote machine, which worked reasonably well.

Overall, it takes 1-2 minutes to boot the cloud PC, and perhaps a minute more to launch Steam Remote Play. This is longer than with a dedicated console or PC, but overall acceptable given that typical gaming session time would be 1-2 hours.

Cloud gaming has a long way to go before it's convenient! 

{% include end_matter.md %}

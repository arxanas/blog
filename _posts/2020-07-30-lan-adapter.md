---
layout: post
title: A LAN adapter isn't everything
permalink: lan-adapter/
tags:
  - smash-bros
---

 * toc
{:toc}

## On online mode

I’ve been getting into _Super Smash Bros. Ultimate_, and I want to play competitively once COVID-19 is over.

The best I can do for now is to play online. However, _Ultimate_’s online play is notoriously bad:

* [The input lag is around 98 ms (~6 frames)](https://www.polygon.com/2018/12/14/18140814/super-smash-bros-ultimate-input-lag-latency-feel), which is on the high end for a fighting game ([the highest listed in this article](http://shoryuken.com/2018/10/19/soulcalibur-vi-input-lag-tested-and-its-comparable-to-street-fighter-v/) is _Samurai Showdown_ with 94ms input lag).
* The game uses delay-based netcode instead of rollback-based netcode, which means that inputs are delayed until all participants have acknowledged them, rather than speculatively executed.
* The game uses peer-to-peer connections rather than centralized servers, which means that all parties are punished for a single party’s lag. This is a problem in both one-on-one play and in the Battle Arena format, where many participants may join, and the quality of the game is determined by the worst internet connection. (NB: a peer-to-peer connection can also have theoretically better performance if the route between players is shorter than a given player’s route to the server.)

## Playing on Wi-Fi

There’s two main arrangements recommended to combat lag:

* Use a LAN adapter for the Nintendo Switch, rather than relying on Wi-Fi.
* Use a low-latency display (particularly one set to “Game Mode”, if available).

I used to play with a LAN adapter on my living room TV, under the assumption that having a wired connection was more important than having a low-latency display. Then I tried playing with my Switch on a small monitor at my work setup over Wi-Fi. What I discovered is that the opposite was true in my case: **having a low-latency display produced better gameplay than having a wired internet connection**.

Wi-Fi can be deployed in one or both of two bands: 2.4 GHz and 5 GHz. [In this article by Parsec](https://blog.parsecgaming.com/how-your-wifi-band-impacts-low-latency-connections-9f1e538a63dd), they demonstrate that 5 GHz actually has quite low latency:

{% image wifi-latency.jpeg
         "Graph comparing latencies of 2.4 GHz Wi-Fi, 5 GHz Wi-Fi, and wired connection."
         "" %}

This diagram indicates the following:

* As a baseline, a wired connection has around 1 ms latency.
* 2.4 GHz Wi-Fi can have huge spikes in latency, routinely hitting 30 ms in their testing.
* 5 GHz reliably stays at around 5 ms latency, and in the worst case, only hits
* about 8 ms latency.

So 5 GHz Wi-Fi is definitely worse than a wired connection, but not by much. For context, 8 ms is about half a frame, so it would be barely noticeable in practice.

The display you use also can make a big difference. [Gaming monitors might have on the order of 10 ms lag](https://www.rtings.com/monitor/tests/inputs/input-lag). My living room TV is an awful 70-inch Samsung smart TV, and I have nothing but bad things to say about it. Besides smart TVs being inherently bad, this particular TV was not marketed as a gaming display, and it seems to have a huge amount of latency, even with Game Mode enabled.

The difference became noticeable only now that I’m playing at a higher level than before. [elitegsp.com](https://www.elitegsp.com/) currently estimates me at the 98th percentile of online players. (My guess is that this would be around the 40th or 50th percentile for in-person players).

After switching to a better monitor, I find I can suddenly react to things I was unable to before. I can catch ledge get-up options more reliably; I’ve started being able to jump over to Samus’s fully-charged charge shots, etc., on reaction, which has never happened before; some of my tight combos even seem more reliable.

So Wi-Fi online play needn’t be that bad!

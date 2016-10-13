---
layout: post
title: "Stenography adventures with Plover and the Ergodox EZ, part 1"
permalink: steno-adventures-part-1/
tags:
  - c
  - steno
---

 * toc
{:toc}

## Overview

{% capture ergodox-ez %}Ergodox&nbsp;EZ{% endcapture %}

In this article I explain my switch to [typing with Plover][plover], an
open-source [stenography] program, to help with ergonomics and incidentally my
typing speed. This resulted in me getting a cool keyboard: the
[{{ ergodox-ez }}][ergodox-ez].

  [ergodox-ez]: https://ergodox-ez.com/
  [plover]: http://www.openstenoproject.org/plover/
  [stenography]: https://en.wikipedia.org/wiki/Shorthand

Next, I detail my journey of setting up the {{ ergodox-ez }} for use with Plover.
The reader may find this interesting if they like hacking on keyboard firmware,
or useful if they want to set up their own {{ ergodox-ez }} with Plover.

This post is split up into two parts. The first part (below) details my
motivations, the stenography system, and the {{ ergodox-ez }} itself. [Part
2][part-2] details the process of installing and modifying the firmware to be
useful for stenography.

  [part-2]: {% permalink steno-adventures-part-2 %}

## Ergonomics is important

One night, during my final semester at university, I was coding a class project.
Lately, my fingers had been aching and my forearms had been twinging, which is a
sure sign that one should look into the ergonomics of their keyboarding. But I
was in the flow that night and I did not stop coding.

That night, I was beset with more severe forearm pain, to the point that I had
trouble falling asleep. I had to acknowledge my problem, and scheduled an
appointment with an occupational therapist. They recommended some stretches,
which I took into consideration, but I did not imagine that they would be
sufficient to prevent a future repetitive-stress injury. Consequently, I took
matters into my own hands.

{% aside Stretches actually work %}

Later that summer, while typing at work, I found my fingers had been throbbing
somewhat for the last few hours. At first glance, I had thought the stretches
recommended by ergonomics professionals would help with my wrists or maybe the
base of my fingers, but not with the middle bits of my fingers where my
throbbing occurred.

But I went ahead and tried some of the stretches anyways. Within minutes I
experienced relief, despite my previous skepticism. I was very naive to dismiss
the advice of experts, and perhaps more ignorant than the average person about
the utility of stretches. Do not repeat my mistake.

I do these stretches semi-regularly now when I feel my fingers are a bit stiff,
and certainly before they start hurting. I don't know if my prescribed set of
stretches can prevent future repetitive-stress injuries on its own, but I do not
intend to tax my hands enough to find out.

{% endaside %}

### What is stenography, and how is it ergonomic?

I had heard about an open-source stenography program called "Plover" a few times
in the past on Hacker News. Stenography refers to [the practice of transcribing
in shorthand][stenography]. Court reporters can use stenography machines to
transcribe the court proceedings in real-time.

{% aside Not to be confused with steganography %}

*Stenography* is the act of transcribing quickly.

*Steganography* is the practice of concealing messages such that it's not
apparent that there is even a message at all.

These are two very different things. I mixed these words up until I began
actually practicing stenography.

{% endaside %}

I for one am a reasonably accomplished typist, at 120 words per minute with
Dvorak. But human speech is about 180 words per minute, so I would be left in
the dust fairly quickly. How do court reporters do it?

Their stenography system is designed so that they press multiple keys at once to
stroke an entire syllable or word. They have special keyboards (called
["stenotype machines"][stenotype]) that are designed to accommodate English
phonetic patterns.

  [stenotype]: https://en.wikipedia.org/wiki/Stenotype

{% aside How do the phonetics work? %}

For example, the word "stretches" can be typed in one stroke: `STREFPS` on the
keyboard below. Most of the letters are pronounced normally, but some
combinations will produce different sounds. For example, the 'n' sound is formed
with `TPH`. In "stretches", the `FP` combination forms the 'ch' sound.

Roughly, the letters are pronounced from left to right. The S on the left spans
two keys; either works.

{% image stretches.gif
         "The steno keyboard layout, typing the word \"stretches\"."
         "The steno keyboard layout, typing the word \"stretches\". Adapted from
          [qwertysteno.com](http://qwertysteno.com/Basics/Introduction.php)" %}

Sometimes, the operator has to type two keys with one finger. The word
"different" can be stroked as `TKEUFRPBT`, which involves four sets of keys that
need two fingers to strike: `TK`, `EU`, `FR`, and `PB`.

The phonetic translations are as follows:

  * `TK` is the 'd' sound.
  * `EU` is the short 'i' sound.
  * `F` and `R` are just 'f' and 'r'.
  * `PB` is the 'n' sound.
  * `T` is just the 't' sound.

Essentially, this is an elaborate macro system that uses chording and a
mnemonically laid-out keyboard.

{% endaside %}

Not only are they faster than conventional typists, but they type on the order
of five times fewer keystrokes as well, reducing muscle strain dramatically. The
downsides are that one requires specialized hardware (ameliorated by Plover, as
I discuss below) and must invest the time to learn this system. Mirabai Knight,
founder of the [Open Steno Project], has [a comprehensive list of
reasons][plover-reasons] why you might want to use Plover.

  [Open Steno Project]: http://www.openstenoproject.org/
  [plover-reasons]: http://plover.stenoknight.com/2010/03/how-to-speak-with-your-fingers.html

## What does Plover do?

Conventional stenographers use a specialized stenography machine for their
transcription. The lowest-end of these machines start at around $500 — in used
condition, no less — and they also require proprietary steno software.

Plover is a program that...

 1. Interfaces with these steno machines directly by implementing their
    protocols, cutting out the proprietary software.

 2. Allows an individual to use their keyboard as a steno machine instead. One
    just positions their hands in a certain way and pretends that they are
typing on a steno keyboard.

  3. Types into any window. Traditional steno software has you type into a
     buffer window and then paste it into an application later. With Plover, you
can write documents, emails, and chat messages directly.

### The tragic keyboard situation

If one is to use their keyboard as a steno machine, it must have [N-key rollover
(NKRO)][nkro], which most do not. With a reasonably nice mechanical keyboard,
one can press no more than six keys or so and have them all register (which we
would call 6-key rollover, or 6KRO). Most commodity keyboards support far fewer
simultaneous presses.

  [nkro]: https://en.wikipedia.org/wiki/Rollover_(key)#n-key_rollover

The stenographer often presses more than 10 keys simultaneously, so these
commodity keyboards simply can't be used effectively for stenography. Therefore
we need a keyboard that can support any number of simultaneous presses ("N-key",
with N meaning it supports any number), or one with a high value of N (there are
22 keys on a steno keyboard, so a number around there would be good).

Even many high-end keyboards do not support an arbitrary number of keys at once
due to [manufacturers not implementing a more complex USB profile][usb-profile].
One can opt to use a PS/2 cable (which my laptop doesn't have a port for), or
get a keyboard with firmware that does support NKRO.

  [usb-profile]: https://gist.github.com/nelstrom/11232558#gistcomment-1422490

{% aside Why do keyboards suck at typing keys? %}

You would think that keyboards would at least be good at the very thing they're
designed to do! Most keyboards don't handle very many keys at once because it is
expensive to do so, and frankly, most users don't need to type that many keys
simultaneously.

A simplified design of a keyboard is to line wires in rows and columns
underneath the keys. When a key is pressed, it completes the circuits of the two
wires below it (one going horizontally and one going vertically). The firmware
can look up the row-column pair in a table and determine the key being pressed.

{% image unambiguous-keys.png
         "Pressing a key triggers wires that can be
          used to look up the key." %}

If one were to actually design a keyboard like this, it would have ambiguous
inputs. Look at the 'A' and 'W' keys on a Qwerty keyboard. Pressing these both
at once would result in a configuration of wires that is the same as the pattern
when pressing 'Q' and 'S' at once.

{% image ambiguous-keys.png
         "If too many wires are pressed at once, multiple keys being pressed
          would be ambiguous." %}

Actual keyboards don't do exactly this, considering that one can type two
characters at once on most keyboards. But they still don't handle arbitrary
numbers of simultaneous keypresses.

High-end keyboards can support arbitrary numbers of keypresses by attaching
expensive diodes to each individual key. But then the USB protocol doesn't
immediately support the high number of keys, as linked above.

{% endaside %}

### So how does one find a compatible keyboard?

One will have to check for "NKRO over USB" in the product description if they
intend to use USB; "NKRO" by itself usually means over PS/2. [There are several
known-to-work NKRO options][nkro-keyboards], starting from about $40. At the
extreme opposite end of the price spectrum, I ordered my {{ ergodox-ez }} for
$325.

  [nkro-keyboards]: http://stenoknight.com/wiki/N-key_rollover#Known_supported_keyboards

{% aside How could one be so reckless as to drop $325 on a keyboard? %}

My own keyboard came with all of the optional knick-knacks: the wrist rests and
tilt/tent kit. Additionally, I ordered it on-demand; many will order it on
Massdrop in groups, which results in a lower unit price.

Even if I couldn't use this keyboard for stenography, I would probably still use
the keyboard daily for ergonomic reasons:

  * It is a split keyboard layout. I would recommend it heartily: letting the
    hands maintain their own comfortable distance from each other is quite nice.
  * The firmware is entirely customizable. I have Dvorak set up at the firmware
    level, which is convenient.
  * The firmware supports mouse keys (also media keys, etc.). When I can't use a
    keyboarding extension like [Pentadactyl][pentadactyl] or
[Shortcat][shortcat] in a program, I still don't have to reach for an accursed
mouse.
  * Unexpectedly, the keyboard is nice for using my laptop while lying in bed.
    I can lay back and have my hands comfortably at my sides, rather than tilted
upward and resting on the edge of the laptop (which is probably terrible for the
nerves).

  [pentadactyl]: http://5digits.org/pentadactyl/
  [shortcat]: https://shortcatapp.com/

(Or I could be rationalizing. I sure hope not.)

{% endaside %}

The {{ ergodox-ez }} is a split keyboard with thumb clusters on each half
instead of a single space bar. There are two long, vertical keys in each
cluster. If one looks at the stenographer's keyboard layout, they will notice
that it has a set of four vowel keys — two for each thumb. So if one were to set
up the {{ ergodox-ez }} appropriately, they would have an almost-steno-machine
that doubles as a regular keyboard.

{% image ergodox-ez.jpg
         "The Ergodox EZ keyboard. Notice the thumb clusters."
         "The Ergodox&nbsp;EZ keyboard [on somebody else's desk](https://twitter.com/ergodoxez/status/681630158512500736). Notice the thumb clusters." %}

### Before you buy

If you're going to buy an {{ ergodox-ez }}, here's a couple of things that I
discovered only after joining the Plover chat room:

  * The blank keycap and non-blank keycap versions are actually shaped
    differently! The blank version is more arched, which could potentially
    cause problems trying to hit adjacent keys at once, although I haven't tried it.

  * The keyswitches control how much force you need to use to press a key.
    Steno machines typically require on the order of 15g to actuate. I got the
    Gateron Brown switches, which are recommended as general-purpose switches,
    but they have a 55g actuation force. (Stenography is anything but
    general-purpose.)

    The lightest switches available for the {{ ergodox-ez }} are the Gateron
    Whites, at 35g. If you intend to steno a lot on the {{ ergodox-ez }} (that
    is, you don't intend to get a student or professional steno machine after
    using the {{ ergodox-ez }} as a learning device), then you probably ought
    to get those instead.

## Now, on to part 2...

...in which I get frustrated at the sorry state of firmware and build my own.
[Click here for part 2][part-2].

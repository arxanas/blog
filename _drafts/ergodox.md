---
layout: post
title: "Stenography adventures with Plover and the Ergodox EZ"
tags:
  - C
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

## Firmware features

Besides the silly-looking keyboard structure, the {{ ergodox-ez }}'s other
selling point is that its firmware is fully modifiable. This means that the user
can write arbitrary code to handle input keystrokes.

The {{ ergodox-ez }} uses the [QMK firmware][qmk] (which also supports several
other keyboards (such as [the Planck][planck]). Beyond controlling the behavior
of keypresses, the framework has support for "layers" and macros, and has
keyboard-specific support to control the three LEDs on the {{ ergodox-ez }}
(which are red, green, and blue).

  [planck]: http://olkb.com/planck/
  [qmk]: https://github.com/jackhumbert/qmk_firmware

Suppose that my work computer is locked down and only supports Qwerty, but I am
a snob who wants to use Dvorak. I can modify the firmware so that it sends
different keycodes when I press the keys, corresponding to the Dvorak keyboard
layout. Thus it will work on every computer, without needing to delve into
obscure settings. I could even make up my own keyboard layout altogether if I so
desired, which I understand many do.

{% aside Is it better to use Dvorak in software or hardware? %}

For this case, it is better to implement Dvorak in hardware. The problem with
setting up one's {{ ergodox-ez }} to use Dvorak at the software level is in the
symbol keys.  For example, `[` on a Qwerty keyboard maps to `/` if interpreted
as Dvorak.

On a Qwerty keyboard, I deal with this just by means of muscle memory. But on
the {{ ergodox-ez }}, when defining the keymap, one would have to reverse-lookup
all of the keycodes to ensure that the symbols are in the right places. When
writing their code, they would have to place `KC_LBRC` (`[`) where they intend
`KC_SLSH` (`/`) to go, and so on for every symbol.

And what happens when you connect your keyboard to a Qwerty computer, but your
keymap is expecting a Dvorak computer? Unless one wants to memorize the
Qwerty-Dvorak symbol correspondence for their keyboard, they will likely
encounter difficulties typing many special characters. There are no such
problems at the hardware level.

{% endaside %}

The firmware also has support for "layers". Each layer defines key mappings, and
the layers can be enabled or disabled individually. If a layer doesn't handle a
certain key at all, it delegates to a layer below it; thus, one can have
multiple active layers, each providing a different set of keys.

Below is the default layout:

{% image ergodox-keymap.png
         "The default Ergodox EZ layout. TODO: Maybe
attribute with link. If so, add an explicit alt text.
          Notice that one can press a key to activate layers." %}

## Installing the firmware

To change the keyboard layout, one has to get a version of the firmware (a
`.hex` file) that maps all the keys appropriately. For the pragmatic or the less
technically-inclined, there are [online tools][configurator] that provide a GUI
to define a basic keymap, although this isn't sufficient for the tweaks I make
later in this article. Then they can download its `.hex` and flash it onto the
{{ ergodox-ez }}.

In order to install the firmware, one uses the [Teensy Loader][teensy-loader]
GUI application. (It can be installed with `brew cask install teensy` on OS X.
There is also a command-line version, but I haven't used it.)

  [teensy-loader]: https://www.pjrc.com/teensy/loader.html

{% image teensy-loader.png
         "The Teensy loader application. I think it's the microcontroller
          in the keyboard which is \"teensy\", but this app is also
          pretty minimal." %}

To set the `.hex` file to load, one can drag it onto the Teensy window, or open
it using the button in the upper-left corner.

{% image load-onto-teensy.png
         "You can drag the file onto the Teensy loader on OS X." %}

Now, to flash the keyboard, you must put it into *reset mode*. You can do this
by putting a very thin rod down the hole in the back of the keyboard to tap the
reset button. (I used several mechanical pencil leads and much patience.)

{% aside How to rapidly hack on the firmware, without fiddling with the reset button %}

Pressing the physical reset button every time is a pain. One can bind a key on
the {{ ergodox-ez }} itself to enter reset mode (a so-called "Teensy key"),
(TODO: link to the article that coined the term "teensy key"?) rather than
manually fiddle with the reset button. Use the TODO: what key? I have this bound
on a non-topmost-layer so that I don't accidentally hit it.

If you make changes to the firmware and recompile it, Teensy will respect the
`.hex` file changing on disk, and would flash the new version of the firmware if
you were to load it again. Thus, it is safe to recompile, reset the keyboard,
and click "load" immediately after recompiling, without selecting the `.hex`
file again

If one clicks the "auto" button, Teensy enters a mode where it will flash the
keyboard as soon as it is connected and in reset mode. Then one no longer needs
to click "load" every time they want to re-deploy the firmware; they can
recompile and press the Teensy key.

{% endaside %}

Once the keyboard is in reset mode, press the "Program" button to flash it. This
loads the firmware onto the keyboard and restarts it. By default, my {{
ergodox-ez }} flashes its three LEDs in sequence on startup, so that one can
tell when it has restarted.

{% image teensy-program.png
         "Click the outlined button to program the keyboard."
         "Click the outlined button to program it. Ignore the picture of the
          button on a circuit board: you will not easily find it in hardware or
          software for the Ergodox&nbsp;EZ, so do not spend time looking for it.
          
Ha-ha, who would spend time trying to click a picture of a button, and get
          confused when it didn't work? Not me, that's for sure." %}

## Building the firmware

  [configurator]: https://keyboard-configurator.massdrop.com/ext/ergodox

As it turns out, the QMK firmware is already bundled [with a Plover
layout][plover-layout]! The vowel keys for Plover are ordinarily struck with the
thumbs; this keymap assigns the vowel keys to the thumb clusters and moves the
rest of the keys closer. Below is the ASCII art comment included in the layout
code. You'll notice that the rows of the Qwerty keyboard are shifted down one
position, and most of the bottom row is missing, only including the four keys in
the thumb clusters.

  [plover-layout]: https://github.com/jackhumbert/qmk_firmware/blob/master/keyboards/ergodox_ez/keymaps/plover/keymap.c

```
,--------------------------------------------------.           ,--------------------------------------------------.
|        |      |      |      |      |      |      |           |      |      |      |      |      |      |        |
|--------+------+------+------+------+-------------|           |------+------+------+------+------+------+--------|
|        |   1  |   2  |   3  |   4  |   5  |      |           |      |  6   |  7   |   8  |   9  |  0   |        |
|--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
|        |   q  |   w  |   e  |   r  |   t  |------|           |------|  y   |  u   |   i  |   o  |  p   |   [    |
|--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
|        |   a  |   s  |   d  |   f  |   g  |      |           |      |  h   |  j   |   k  |   l  |  ;   |   '    |
`--------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
  |      |      |      |      |      |                                       |      |      |      |      |      |
  `----------------------------------'                                       `----------------------------------'
                                       ,-------------.       ,-------------.
                                       |      |      |       |      |      |
                                ,------|------|------|       |------+------+------.
                                |      |      |      |       |      |      |      |
                                |   c  |   v  |------|       |------|  n   |  m   |
                                |      |      |      |       |      |      |      |
                                `--------------------'       `--------------------'
```

But to use this layout one must first build it. First, install the dependencies
(on OS X; you can find your OS in the QMK documentation):

```sh
$ brew tap osx-cross/avr
$ brew install avr-libc
$ brew install dfu-programmer
```

This takes quite a while, as it is setting up a cross-compiler toolchain and has
to build GCC from source.

{% aside Warning: the following version of the build doesn't actually work %}

Before you try to install the firmware after building it as below, be warned
that the Plover layout has a few problems. You can read on to see how I fixed
it, or just build off of [my firmware][arxanas-plover]. (It is likely not a good
idea to use it exactly as it is, since the default layer is set to Dvorak.)

  [arxanas-plover]: TODO. This should link directly to the directory!

While I was writing this, somebody else came out with [firmware that pretends to
be a steno machine][serial-firmware] instead of using macros to toggle Plover.
This is probably superior to my firmware, because then the keyboard and Plover's
status can never get out of sync. I can't vouch for it personally, but you
should consider trying it out.

  [serial-firmware]: https://groups.google.com/forum/#!topic/ploversteno/4RCOL_HhKw0

For either of these, you will probably want to modify the keymaps to your liking
for the non-Plover parts.

{% endaside %}

When I'm done, I build it by running the `make` command shown below. It is shown
with an example of the successful output. The build process is surprisingly
nice: one can specify the keyboard type and layout very succinctly.

```
~/Workspace/qmk_firmware $ make keyboard=ergodox_ez keymap=plover
Size before:
avr-gcc (GCC) 4.9.3
Copyright (C) 2015 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

   text	   data	    bss	    dec	    hex	filename
      0	  18300	      0	  18300	   477c	ergodox_ez_plover.hex

WARNING:
 Some git sub-modules are out of date or modified, please consider runnning:[1m
 git submodule sync --recursive
 git submodule update --init --recursive

 You can ignore this warning if you are not compiling any ChibiOS keyboards,
 or if you have modified the ChibiOS libraries yourself. 

Compiling: ./keyboards/ergodox_ez/twimaster.c                                                      Compiling: keyboards/ergodox_ez/ergodox_ez.c                                                       Compiling: ./keyboards/ergodox_ez/matrix.c                                                         Compiling: keyboards/ergodox_ez/keymaps/plover/keymap.c                                            Compiling: quantum/quantum.c                                                                        [OK]
Compiling: quantum/keymap_common.c                                                                  [OK]
 [OK]
Compiling: quantum/keycode_config.c                                                                Compiling: quantum/process_keycode/process_leader.c                                                 [OK]
Compiling: quantum/process_keycode/process_unicode.c                                                [OK]
Compiling: ./tmk_core/common/host.c                                                                 [OK]
Compiling: ./tmk_core/common/keyboard.c                                                             [OK]
Compiling: ./tmk_core/common/action.c                                                               [OK]
Compiling: ./tmk_core/common/action_tapping.c                                                       [OK]
 [OK]
Compiling: ./tmk_core/common/action_macro.c                                                        Compiling: ./tmk_core/common/action_layer.c                                                         [OK]
Compiling: ./tmk_core/common/action_util.c                                                          [OK]
 [OK]
 [OK]
Compiling: ./tmk_core/common/print.c                                                               Compiling: ./tmk_core/common/debug.c                                                               Compiling: ./tmk_core/common/util.c                                                                 [OK]
 [OK]
 [OK]
Compiling: ./tmk_core/common/eeconfig.c                                                            Compiling: ./tmk_core/common/avr/timer.c                                                           Compiling: ./tmk_core/common/avr/suspend.c                                                          [OK]
 [OK]
Compiling: ./tmk_core/common/avr/bootloader.c                                                       [OK]
Assembling: ./tmk_core/common/avr/xprintf.S                                                         [OK]
Compiling: ./tmk_core/common/magic.c                                                               Compiling: ./tmk_core/common/mousekey.c                                                             [OK]
 [OK]
Compiling: ./tmk_core/common/command.c                                                             Compiling: ./tmk_core/common/avr/sleep_led.c                                                        [OK]
Compiling: ./tmk_core/protocol/lufa/lufa.c                                                          [OK]
Compiling: ./tmk_core/protocol/lufa/descriptor.c                                                    [OK]
Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Class/Common/HIDParser.c              [OK]
Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/AVR8/Device_AVR8.c               [OK]
 [OK]
Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/AVR8/EndpointStream_AVR8.c      Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/AVR8/Endpoint_AVR8.c             [OK]
Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/AVR8/Host_AVR8.c                 [OK]
Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/AVR8/PipeStream_AVR8.c           [OK]
 [OK]
Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/AVR8/Pipe_AVR8.c                Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/AVR8/USBController_AVR8.c        [OK]
 [OK]
Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/AVR8/USBInterrupt_AVR8.c        Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/ConfigDescriptors.c              [OK]
Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/DeviceStandardReq.c              [OK]
Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/Events.c                         [OK]
 [OK]
Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/HostStandardReq.c               Compiling: ./tmk_core/protocol/lufa/LUFA-git/LUFA/Drivers/USB/Core/USBTask.c                        [OK]
 [OK]
 [OK]
 [OK]
 [OK]
Linking: .build/ergodox_ez_plover.elf                                                               [OK]
Creating load file for Flash: .build/ergodox_ez_plover.hex                                          [OK]

Size after:
   text	   data	    bss	    dec	    hex	filename
      0	  18300	      0	  18300	   477c	ergodox_ez_plover.hex
```

The `.hex` file can be found in the directory that the `make` command was run
in, likely the root directory of the `qmk_firmware` project.

The moment of truth! I install the firmware, restart the keyboard, and press the
toggle Plover key...

{% image ergodox-ez.jpg
         "The unchanged Ergodox keyboard."
         "Depicted: the wholly unchanged state of the keyboard." %}

Nothing happens. There is no indication that Plover mode has been enabled. In
comparison, when entering the symbol layer from the default layout, the red LED
turns on. It turns out that Plover mode is working; it's just impossible to
tell.

Later, I press the key to return to the regular layer... and it doesn't do
anything.  The keyboard is still thoroughly in Plover mode. I mash several other
keys, but to no avail. Something is wrong with the layout which is preventing it
from behaving well.

{% aside The harsh realization sets in %}

Once you go Plover, you never come back over.

{% endaside %}

## Fixing the firmware

After trying out the firmware, I also find a few other usability problems. In
sum, they are:

  * There is nothing to indicate when the user in Plover mode.
  * The user can't switch back into the regular layout.
  * Manually enabling Plover mode after toggling the keyboard is tedious.
  * It doesn't appear to actually be using NKRO; it fails at around 6 keys.

I did not like these, so I dug into the firmware code and fixed it myself. It
wasn't that bad! I opened up the Plover layout in
`keyboards/ergodox_ez/keymaps/plover/keymap.c` and start looking...

{% aside You too can make a keyboard layout %}

The values `ergodox_ez` and `plover` in the command `make keyboard=ergodox_ez
keymap=plover` directly corresponds to the directory structure above.

When you make your own layout, you can start by copying some other `keymap.c`
and putting it in `keyboards/ergodox_ez/keymaps/my-layout` and build it with
`make keyboard=ergodox_ez keymap=my-layout`.

{% endaside %}

### Toggling the LED

I looked around a bit and found these snippets:

```c
#define BASE 0 // default layer
#define SYMB 1 // symbols
#define MDIA 2 // media keys
#define PLVR 3 // Plover layer

...

switch (layer) {
    case 1:
        ergodox_right_led_1_on();
        break;
    case 2:
        ergodox_right_led_2_on();
        break;
    default:
        // none
        break;
}
```

The default layer doesn't have an LED and it's not in the `switch` statement.
The next two layers, which have LEDs, are the same as the one bundled in the
default {{ ergodox-ez }} layout, and they are listed here.

Plover is a new layer, but it doesn't have an entry here. Could it really be as
simple as adding the missing entry? I add a `case 3:`:

```
switch (layer) {
    case 1:
        ergodox_right_led_1_on();
        break;
    case 2:
        ergodox_right_led_2_on();
        break;

    // My brilliant addition:
    case 3:
        ergodox_right_led_3_on();
        break;

    default:
        // none
        break;
}
```

And it works!

TODO: Insert picture of blue LED

### Adding a toggle key

The regular layers toggle back and forth by pressing the same key, so there is
already some code somewhere that handles it. If I can find it, surely I can just
adapt it.

Part of the `keymap.c` file is a huge array definition that defines the keymap.
Each entry corresponds to a physical key, and there are a lot of keys. I've
abbreviated it here so you can see where to look. I find where the default
toggle key for the symbol layer is:

```c
[BASE] = KEYMAP(  // layer 0 : default
        // left hand
        KC_EQL,  ...,  KC_LGUI,
        KC_TAB,  ...,  TG(1) /* <- here */,
        KC_ESC,  ...,  KC_G,
        ...
```

The `TG(1)` expression toggles into layer one. With my unrivalled abilities of
deduction, I surmise that `TG` stands for toggle. Now that I know how to toggle
layers, I find the keymap for Plover mode:

```c
// right hand
              KC_TRNS,  KC_NO, ...
/* here -> */ KC_NO,    KC_6, ...
```

The `KC_NO` key in the first column seems to line up with where the Plover
toggle key is ordinarily, so I change it to `TG(3)` and it works!

TODO: Video?

{% aside The original author was closer to the mark than I initially realized %}

`KC_NO` means "do nothing when this key is pressed." On the other hand,
`KC_TRNS` means "do nothing, but allow another layer to handle this key". The
original author just put `KC_TRNS` on the wrong row. If it were one row lower,
pressing the key would delegate to the existing toggle-Plover key in the base
layer, and it would work correctly.

{% endaside %}

### Adding N-key rollover

The firmware supports NKRO, but it is disabled by default. One has to enable it
by setting the configuration for the layout. Before doing this, the layout
worked correctly except that it didn't handle pressing a large number of keys
simultaneously.

I looked it up the documentation and added this `config.h` file to the `plover`
directory, alongside `keymap.c`. Pretty painless!

```c
#ifndef CONFIG_USER_H
#define CONFIG_USER_H

#define FORCE_NKRO

#endif
```

### Toggling Plover in software

I've successfully set up the keyboard to toggle Plover mode. But the Plover
software itself needs to know whether you are typing normally or
stenographically, to decide whether it should be translating your keystrokes or
not.

The most straightforward way to go about this is to define a Plover stroke that
enables and disables Plover. Before getting the {{ ergodox-ez }}, I would switch
in and out by typing the strokes PHROPB and PHROF (phonetically translating to
Pl-On and Pl-Off, short for Plover-On and Plover-Off). But this is annoying to
do manually and sometimes I get confused about which mode I'm in.

TODO: Link to the article explaining this command.

Since the firmware supports macros, it would be nice if it could also send these
keystrokes for me when toggling in and out of Plover mode. After some spelunking
for other macros and examining the documentation, I figure out roughly what to
do.

First, I define the macros at the top of the file. The first set of definitions
is integer identifiers for the macros; the second set is actually a keycode to
enable the macro, as I understand it.

```c
#define MACRO_PLOVER_ON  0
#define MACRO_PLOVER_OFF 1

#define M_PLON M(MACRO_PLOVER_ON)
#define M_PLOF M(MACRO_PLOVER_OFF)
```

Now I have to bind keys to these macros. Since I want these to happen in
addition to changing the layer, I decide to put the macro key in my keymap and
change the layer in the macro code itself (rather than with the convenient `TG`
shortcut). I just add these entries to my keymap:


```c
[BASE] = KEYMAP(  // layer 0 : default

...

// right hand
         KC_RGHT,  KC_6,  KC_7,
/* -> */ M_PLON,   KC_F,  KC_G,
                   KC_D,  KC_H,

),

...

[PLVR] = KEYMAP(  // layout: layer 3: Steno for Plover

...

// right hand
         KC_TRNS,  KC_NO,  KC_NO,
/* -> */ M_PLOF,   KC_6,   KC_7,
                   KC_Y,   KC_U 
```

Finally, I have to write the actual code that handles the macro. I add the
following function, mostly stealing the structure from an existing layout
elsewhere.

```c
const macro_t *action_get_macro(keyrecord_t *record, uint8_t id, uint8_t opt)
{
    switch (id) {
    case MACRO_PLOVER_ON:
        // `.pressed` refers to whether we're pressing or releasing the
        // triggering key.
        if (record->event.pressed) {
            // Enable the layer.
            layer_on(PLVR);

            // Send the PHROPB stroke to enable Plover.
            // (Note that you must have this command in your dictionary for it
            // to actually do anything.)
            // 
            // 'D' means 'down' and 'U' means up, referring to pressing and
            // releasing keystrokes.
            //
            // 'D(E)' means 'press down the E key.'. When using the Qwerty
            // keyboard layout in software, the sequence ERFVIK corresponds to
            // the steno keys PHROPB.
            return MACRO(D(E), D(R), D(F), D(V), D(I), D(K),
                         // Wait for 50 milliseconds to make sure the keypresses
                         // are detected. I haven't seen evidence that this is
                         // necessary, but it doesn't hurt.
                         WAIT(50),
                         U(E), U(R), U(F), U(V), U(I), U(K),
                         END);
        }
        break;

    case MACRO_PLOVER_OFF:
        if (record->event.pressed) {
            // Disable the layer.
            layer_off(PLVR);

            // Send the PHROF stroke to disable Plover.
            return MACRO(D(E), D(R), D(F), D(V), D(U),
                         WAIT(50),
                         U(E), U(R), U(F), U(V), U(U),
                         END);
        }

        break;
    }

    // Don't do anything if we didn't press an appropriate key.
    return MACRO_NONE;
};
```

TODO: Video?

## "So after all that, how is steno going?"

That's very considerate of you to ask, thanks.

I'm currently up to 50 words per minute on newspaper-caliber text after about 12
weeks of practice. For less vocabulary-intensive applications, such as instant
messaging, I can reach 80–90 wpm. I intend to post a more detailed journal about
my progress later.

Overall, steno is showing to be much easier on the fingers, and I miss it when I
have to return to my laptop keyboard. If you are concerned about the strain on
your hands, want to type faster, or are curiously infatuated with esoteric
keyboard firmware, I can recommend the {{ ergodox-ez }} + Plover combination.

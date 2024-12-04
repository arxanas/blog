---
layout: post
title: "Playing Smash Bros. with a Steam Controller: touch detection"
permalink: smash-bros-steam-controller-touch-detection/
series:
  prev: smash-bros-steam-controller-implementation/
tags:
  - gaming
  - hardware
  - machine-learning
  - smash-bros
---

The touchpads are one of the main reasons I wanted to [play *Smash Bros.* with a Steam Controller]({% permalink smash-bros-steam-controller %}), but there's a lot of necessary firmware work to make it reliable enough for tournament play. In this article, I discuss the technical details of touch detection, the practical problems, and the strategies I considered.

{% noteblock note-warning %}
<span class="note-tag note-warning">Ultimately:</span> Reliable touch detection turned out to be a difficult problem, and I wonder if there's an underlying hardware issue or concept that I'm not accounting for.

If you have any ideas on how to resolve this issue, I'd love to hear them! Comment on the article or email me at <me@waleedkhan.name>.
{% endnoteblock %}

{% include toc.md %}

TODO: likely not a fundamental issue because the stock firmware seems to work fine with PC gaming (as far as I could tell).

## Issues

### Touch detection at a distance

As reported in ["Hovering my finger over the right pad registers an input"](https://github.com/greggersaurus/OpenSteamController/issues/7), touches are registered even ~1cm above the touchpad, as demonstrated in the reporter's video:

<div class="iframe-container">
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/kDKSPASbD7A?si=oDX6dBsB0ADyUOvJ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
</div>

[I partially addressed this in a pull request](https://github.com/greggersaurus/OpenSteamController/pull/32) where I checked the amplitude of the touchpad signal, and only registered a touch at a certain empirically-determined threshold.

However, it turns out that this approach loses accuracy near the edges of the touchpad, likely due to the touchpad curvature and the corresponding distance from the sensor array.

TODO: delete below (copied)
The underlying cause is quite interesting:

- <span class="note-tag note-info">It turns out that:</span> The touchpad... is incapable of detecting touches!
- The hardware appears to provide no direct indication that the user is making contact with the touchpad.
- <span class="note-tag">Instead:</span> The firmware needs to calculate how far the finger is from the sensors *underneath* the touchpad. When the finger is close enough to those sensors, then the firmware can infer that it must be making contact with the touchpad.

While my approach is simple and reasonably effective, it quickly loses accuracy when processing touches distant from the touchpad center, due to <span class="note-braces"><span class="note-conj">both</span> the curvature of the touchpad increasing the physical distance from the sensors <span class="note-conj">and</span> the specific placement and shape of the sensor array</span>.

### Official firmware

The official firmware doesn't seem to have touch detection issues when I used a Steam Controller for PC gaming. I assume one of the following must be true:

- **The issue does not occur**: There is no issue in the official firmware, which suggests that the problem can be resolved entirely in firmware.
- **The issue is not triggered**: The issue does not tend to occur with the input patterns I use in PC gaming.
  - <span class="note-tag">Such as:</span> In competitive *Smash Bros.*, I rely on precise touches near the edge of the touchpad with specific angles from the center.
- **The issue is not noticeable**: The issue was occurring, but I simply didn't notice on account of not relying on a significant degree of accuracy.
  - <span class="note-tag">For example:</span> I was playing *Elden Ring* (casually), which needs *deliberate* movement and attack timing, but not necessarily *precise* movement and attack timing. In comparison to competitive *Smash Bros.*, the timing windows are quite generous.

## Concepts

### Hardware

As discussed in the [OpenSteamController firmware README](https://github.com/greggersaurus/OpenSteamController/blob/master/Firmware/README.md), the microcontroller is an LPC11U37 processor ([spec sheet](https://www.nxp.com/docs/en/data-sheet/LPC11U3X.pdf)):

> The LPC11U3x are an ARM Cortex-M0 based, low-cost 32-bit MCU family, designed for 8/16-bit microcontroller applications, offering performance, low power, simple instruction set and memory addressing together with reduced code size compared to existing 8/16-bit architectures.

[This GitHub comment](https://github.com/greggersaurus/OpenSteamController/issues/7#issuecomment-611338766) suggests that the touchpad is a Cirque Pinnacle device ([spec sheet](pinnacle-spec-sheet)):

  [pinnacle-spec-sheet]: https://www.dropbox.com/scl/fi/3lzggpbjlffsdet0ug77i/IC-DS-150408-Pinnacle-Specification.pdf?rlkey=wpdi0nfra1y119gz90d1r8cp0&e=1&dl=0

> The Pinnacle ASIC monitors a capacitive touch sensor. When a finger (or a stylus) is placed on the surface of the sensor Pinnacle will determine the location of the object (user's finger or stylus). The position data is reported to the host as X and Y coordinates. The strength of the signal is reported as the Z coordinate.

### Capacitive touch detection

From the [Pinnacle spec sheet][pinnacle-spec-sheet]:

> The Z level is a measure of how much the capacitive field has changed. When no finger is near, the Z level will be at or near zero (0).The Z level will start increasing as a finger approaches. The Z level continues to increase as more of the surface area of the finger touches the surface of the sensor. Position data is generated for any Z level greater than zero (0). Overlay types (glass vs. plastic) on the sensor and application requirements are factors that the developer needs to consider when setting Z level thresholds for a touch and a release. With absolute data mode enabled, Z-level values are reported in Bits [0:5] of the Z-level Packet Byte (see Table 11 on page 14).

My mental model is that there's a sensor array below the touchpad with the electrodes on each axis positioned in a line.

- **Compute X-value** (or respectively Y-value): Determined by comparing relative strengths of signals of each electrode for the appropriate axis.
- **Compute Z-value**: Determined by checking the absolute strengths of the signals for each electrode and calibrating against some known quantity.
  - The spec sheet mentions that the Pinnacle device performs an initial calibration on startup.

TODO: discuss implications

TODO: discuss AnyMeas mode

### Signal format

TODO: draw picture?

<!-- @nocommit: can use https://tikzjax-demo.glitch.me/ as a live demo -->
<!-- @nocommit: vendor scripts and styles: -->
<link rel="stylesheet" type="text/css" href="http://tikzjax.com/v1/fonts.css">
<script src="https://tikzjax.com/v1/tikzjax.js"></script>

<!-- @nocommit: add TikZ block -->
<style type="text/css">
.tikz-diagram {
}
.tikz-diagram div {
  margin-left: auto;
  margin-right: auto;
}
.tikz-loading-text {
  display: none;
}
script[type="text/tikz"] + .tikz-loading-text {
  display: block;
}
</style>
<div class="tikz-diagram">
<script type="text/tikz">
\begin{tikzpicture}[scale=1.5]
\draw[gray] (-2, -2) grid (2, 2);
\draw[blue] (-2, 0) sin (-1, 1) cos (0, 0) sin (1, -1) cos (2, 0);
\begin{scope}[shift={(5,0)}]
\draw[gray] (-2, -2) grid (2, 2);
\draw[blue,rotate=90] (-2, 0) sin (-1, 1) cos (0, 0) sin (1, -1) cos (2, 0);
\end{scope}
\end{tikzpicture}
</script>
<p class="tikz-loading-text">Loading diagram (TikZ format)...</p>
</div>
<noscript>Diagrams (TikZ format) require Javascript to be enabled in your browser to render.</noscript>

### Signal strength

TODO: talk about quadratic scaling of signal

{% include end_matter.md %}

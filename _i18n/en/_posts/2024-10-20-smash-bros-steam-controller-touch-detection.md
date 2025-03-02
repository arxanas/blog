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
TODO: offer payment/contract?
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
- **The issue is not noticeable**: The issue was occurring, but I simply didn't notice it because I wasn't relying on a significant degree of precision.
  - <span class="note-tag">For example:</span> I was playing *Elden Ring* (casually), which needs *deliberate* movement and attack timing, but not necessarily *precise* movement and attack timing. The timing windows for *Elden Ring* are quite generous in comparison to competitive *Smash Bros.*.

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

- **Compute X-value** (or respectively **Y-value**): Determined by comparing relative strengths of signals of each electrode for the appropriate axis.
- **Compute Z-value**: Determined by checking the absolute strengths of the signals for each electrode and calibrating against some known quantity.
  - The spec sheet mentions that the Pinnacle device performs an initial calibration on startup.

TODO: discuss implications

TODO: discuss AnyMeas mode

### Signal format

TODO: discuss how the signal turns into a sine wave and how to interpret; discuss potential Fourier analysis for multi-touch support

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
\tikzset{axis line style/.style={thin, gray, -stealth}}

\newcommand*{\TickSize}{2pt}%

\begin{tikzpicture}
\draw[very thick,blue] (3,-4) ellipse ({4} and {3});

\draw [axis line style] (-2.5,0) -- (8.5,0);% x-axis
\draw [axis line style] (0,-8.5) -- (0,2.5);% y-axis

\foreach \x in {-1,1,...,8} {\draw ($(\x,0) + (0,-\TickSize)$) -- ($(\x,0) + (0,\TickSize)$)
        node [above] {$\x$};
}

\foreach \y in {-7,-5,...,2} { \draw ($(0,\y) + (-\TickSize,0)$) -- ($(0,\y) + (\TickSize,0)$)
        node [right] {$\y$};
}
\end{tikzpicture}
</script>
<p class="tikz-loading-text">Loading diagram (TikZ format)...</p>
</div>
<noscript>Diagrams (TikZ format) require Javascript to be enabled in your browser to render.</noscript>

### Signal strength

TODO: talk about quadratic scaling of signal

### Signal compensation

TODO: discuss compensation in original source code: https://github.com/greggersaurus/OpenSteamController/blob/325801542fcb762d19a91addd801f0630c825966/Firmware/OpenSteamController/src/trackpad.c#L877-L1036


```c
    // This is based on simulation of official firmware. Cannot say I
    //  understand it...
    int32_t compensated_val = tpadAdcDatas[trackpad][0] - tpadAdcComps[trackpad][0];
    adc_vals_x[0] = compensated_val;
    adc_vals_x[1] = compensated_val;
    adc_vals_x[2] = -compensated_val;
    adc_vals_x[3] = compensated_val;
    adc_vals_x[4] = compensated_val;
    adc_vals_x[5] = compensated_val;
    adc_vals_x[6] = -compensated_val;
    adc_vals_x[7] = -compensated_val;
    adc_vals_x[8] = -compensated_val;
    adc_vals_x[9] = compensated_val;
    adc_vals_x[10] = -compensated_val;
    adc_vals_x[11] = -compensated_val;

    // ... 100+ lines of similar code ...
```

TODO: and also https://github.com/greggersaurus/OpenSteamController/blob/325801542fcb762d19a91addd801f0630c825966/Firmware/OpenSteamController/src/trackpad.c#L1351-L1366:

```c
    // Load Compensation Matrix Data (I think...):
    //  According to datasheet: A compensation matrix of 92 values (each 
    //  value is 16 bits signed) is stored sequentially in Pinnacle RAM, 
    //  with the first value being stored at 0x01DF. 
    uint8_t era_data[8];

    // Comensation Matrix Data for AnyMeas ADCs for Y axis location?
    era_data[0] = 0x00;
    era_data[1] = 0x00;
    era_data[2] = 0x07;
    era_data[3] = 0xf8;
    era_data[4] = 0x00;
    era_data[5] = 0x00;
    era_data[6] = 0x05;
    era_data[7] = 0x50;
    writeTpadExtRegs(trackpad, 0x015b, 8, era_data);

    // ... 100+ lines of similar code ...
```

## Modeling

TODO: link to logbook at https://docs.google.com/document/d/14TnsZ2K7c_PGhVDgSLViv2tUAwimnl9Ms_7b9Skf3xA/edit?usp=sharing

### Denoising

TODO: discuss measurement spikes

### Fitting parabolas

TODO: discuss approach, link to Google Sheets (maybe: <https://docs.google.com/spreadsheets/d/1OsZ_8aARLt2CsAgTYeFL9fWcoAd76ydiDuHzA4Uyvms/edit?gid=1130248548#gid=1130248548>), discuss how it wasn't very accurate outside of the axes

### Fitting paraboloids

TODO: Link to "Interpolate second-degree polynomial for touch detection" at https://github.com/arxanas/OpenSteamController/commit/d23e2fb90556683016c6f9f2fa075484287c8d50

TODO: which optimizes the following:

```python
def func(xy, a, b, c, d, e, f):
    x, y = xy
    return a + b * x + c * y + d * x**2 + e * y**2 + f * x * y

(x_popt, x_pcov) = sp.optimize.curve_fit(func, (x_coord, y_coord), x_ampl)
(y_popt, y_pcov) = sp.optimize.curve_fit(func, (x_coord, y_coord), y_ampl)
```

### Nearest-neighbor interpolation

TODO: Link to "Nearest-neighbor model for touch detection, and use 1000 as the threshold" at https://github.com/arxanas/OpenSteamController/commit/fff499bfafd8b66e1d75407248a6908c4b6327c2#diff-07832111422b71a33a357e037cdd1b46827d9b8617b60219fd379a4fb5123507L14

{% include end_matter.md %}

---
layout: post
title: "Incremental processing with Watchman — don't daemonize that build!"
permalink: incremental-watchman/
tags:
  - build-systems
  - reprint
  - software-engineering
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Build system developers and enthusiasts</li>
        <li>Developers of tooling that doesn't fit into the build system</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Lessons synthesized from 8-year career in incremental computation and build systems</li>
        <li>Originally presented at <a href="https://groups.io/g/Seattle-Build-Enthusiasts/topic/seattle_build_enthusiast/108248211">Seattle Build Enthusiasts Meetup (Fall 2024)</a></li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td><ul>
        <li>Instructive</li>
        <li>Passionate that people should avoid my mistakes</li>
      </ul></td>
    </tr>
  </table>
</div>

 * toc
{:toc}

## Slides

This talk was given at the [Seattle Build Enthusiasts Fall 2024 meetup](https://groups.io/g/Seattle-Build-Enthusiasts/topic/seattle_build_enthusiast/108248211) (2024-10-02).

- Speaker notes correspond to the intended transcript.
- Deleted slides with extra information are available at the end.
- Direct Google Slides link: <https://docs.google.com/presentation/d/1geE7rGTCpIk5UTjH-sw9aL_Zszi1ncCRnFi55t0CDlk/>

<div class="iframe-container">
<iframe src="https://docs.google.com/presentation/d/e/2PACX-1vRSwp0EbldxIkD72bzEoKDHzLzah95w2ABa1doSwqeKTMneSz1_O1DqNNb7qJCi4xXbPdp1A7Blk5PV/embed?start=false&loop=false&delayms=3000" frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
</div>

{% include end_matter.md %}

---
layout: post
title: "Commit graph data structures"
permalink: commit-graph-data-structures/
tags:
  - git
  - reprint
  - rant
  - software-engineering
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Software engineers working on large source-controlled repositories, particularly Git.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Originally presented at <a href="Build Meetup Seattle">Build Meetup Seattle (July 2026)</a></li>
        <li>Experience working with <a href="https://git-scm.com/">Git</a>, <a href="https://github.com/arxanas/git-branchless/">git-branchless</a>, and <a href="https://sapling-scm.com/">Sapling</a>.</li>
        <li>Experience optimizing operations on large monorepos.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td><ul>
        <li>Determined.</li>
        <li>Hoping to inspire people to rethink the status quo.</li>
      </ul></td>
    </tr>
  </table>
</div>

{% include toc.md %}

## Slides

Unfortunately, I don't have a transcript or presentation notes.

<div class="iframe-container">
<iframe src="https://docs.google.com/presentation/d/e/2PACX-1vQhrh43nHyuDYhFnZ0Asv_kl77NeuMaCG7oojRC4VFtohyvkqMsXp7rm23kgG0TUA5BPEwnyvUiWbqp/pubembed?start=false&loop=false&delayms=3000" frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
</div>

## Links

- <https://devblogs.microsoft.com/devops/supercharging-the-git-commit-graph-ii-file-format/>
- <https://github.com/facebook/sapling/blob/d6e69d93b69d265bbaa811784ace62b112690ac4/eden/scm/slides/201904-segmented-changelog/segmented-changelog.pdf>
- <https://sapling-scm.com/docs/dev/internals/indexedlog/>

{% include end_matter.md %}

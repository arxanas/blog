---
layout: post
title: "Yandex's Arc source control system"
permalink: yandex-arc/
translations:
  pl: "/pl/yandex-arc/"
tags:
  - git
  - software-engineering
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td>Developers of source control systems like Git or Mercurial.</td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li><a href="https://discord.com/channels/1042895022950994071/1042907270473850890/1068630001240514691">My notes on Discord</a>.</li>
        <li>My experience developing for source control systems.</li>
        <li><a href="https://habr.com/ru/company/yandex/blog/482926/">The official Yandex blog</a>.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td>Mildly interested.</td>
    </tr>
  </table>
</div>

There was a recent [source code leak](https://arseniyshestakov.com/2023/01/26/yandex-services-source-code-leak/) from [Yandex](https://en.wikipedia.org/wiki/Yandex). I haven't examined any of the files, but the topic itself reminds us that Yandex maintains a large [monorepo](https://monorepo.tools/), and has even built their own source control system to handle it, called Arc.

Original article from Yandex (2020): <https://habr.com/ru/company/yandex/blog/482926/>

Brief notes ([originally posted to Discord](https://discord.com/channels/1042895022950994071/1042907270473850890/1068630001240514691)):

- Seems to be based on [SVN](https://subversion.apache.org/) for the back-end
- Trunk-based development
- 6M commits, 2M files, 2TB repo size
- Tried [Mercurial](https://www.mercurial-scm.org/) but didn't solve performance problems
- Uses generation numbers for merge-base calculation
  - This is now available in Git via the [commit-graph mechanism](https://git-scm.com/docs/commit-graph).
- Probably based on Git for the front-end UI, but they complain about Git's UI being bad, so they're improving it
- Used by 20% of developers internally at the time of writing
- Uses a [virtual filesystem](https://en.wikipedia.org/wiki/Virtual_file_system) (VFS) heavily ([FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace) on macOS, possibly they've changed since then?)
  - VFS support on macOS is fairly flaky these days.
- Uses Yandex Database (YDB) for the back-end database, with some kind of conversion tool from SVN
- As part of the code review system, Arc commits are eventually converted to SVN commits, including some additional Arc metadata
- Implicitly uses a working copy commit for some internal algorithms, which includes untracked files since they're providing a VFS
  - I mentioned this in the context of [Jujutsu VCS](https://github.com/martinvonz/jj).

Overall, it doesn't seem like there's a whole lot to advance the state-of-the-art in monorepo management compared to large tech companies like Google and Meta.

{% include end_matter.md %}

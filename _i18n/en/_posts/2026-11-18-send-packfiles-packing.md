---
layout: post
title: "Send packfiles packing"
permalink: send-packfiles-packing/
tags:
  - git
  - programming-languages
  - software-engineering
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Software engineers working on large-scale source control systems.</li>
        <li>Individuals evaluating so-called "neoforges" for code hosting.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Colleagues asking for my thoughts on neoforge launches.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td><ul>
        <li>Disappointed.</li>
        <li>Shaking my head, even.</li>
      </ul></td>
    </tr>
  </table>
</div>

{% include toc.md %}

Now that I work on source control professionally, colleagues sometimes ask for my opinion on engineering reports published by so-called "neoforges".

At my work, our GitHub Enterprise Server instance struggles greatly with its 'maintenance' step which repacks the repo. At a certain scale, this approach doesn't work anymore.

I'm automatically suspicious of any approach which seems to depend on [packfiles](https://git-scm.com/book/en/v2/Git-Internals-Packfiles) --- or, more generally, any approach which appears to implement a concurrent garbage collector.

## Why packfiles?

Packfiles are necessary when a single machine needs to

- store the whole commit history
- store the repo on local disk

Git leveraged packfiles admirably for laptop-scale development. But these assumptions have to be broken once you have AI agents regularly committing to a massive monorepo.

## Why not packfiles?

Concurrent garbage collection is _hard_. If your source control architecture [involves frequent compactions and collections](https://github.blog/engineering/architecture-optimization/inside-githubs-new-git-storage-architecture/#decoupling-storage-from-compute-compaction-at-thousands-of-writes-per-second), then you'd better have a damn good reason.
- <span class="note-tag">As a point of reference:</span> The Java ecosystem has probably spent USD 100M on the development of concurrent garbage collectors. Can you do the same?
- <span class="note-tag">As a point of reference:</span> Python didn't garbage-collect cyclic references until the 2.0 release. Swift [strongly encourages](https://docs.swift.org/latest/documentation/the-swift-programming-language/automaticreferencecounting/) the reference-counting approach.

Once we model source control object storage as a memory management problem, it's easy to assess the strengths/weaknesses of garbage collection vs other approaches, such as [reference-counting](https://en.wikipedia.org/wiki/Reference_counting) or [region-based memory management](https://en.wikipedia.org/wiki/Region-based_memory_management).

Some characteristics to note:

- Git-style Merkle-tree-oriented source control essentially precludes reference cycles! That simplifies things considerably, such as by permitting a naive reference-counting strategy.
- There's usually one or more long-lived branches whose objects are never collected. Yet the garbage collector must walk the entire chain for every collection, even though it'll never be invalidated.
- If you keep code review branches around forever, then the generational hypothesis doesn't hold: even objects which don't make it into a long-lived branch have to be kept forever.
- In the packfile scheme, there is limited temporal or spatial locality of data.
  - <span class="note-tag">For example:</span> If you want to download only the objects that affect a certain sparse checkout cone, you have to first locate every individual object. You'd have to build a separate index if you wanted to efficiently serve objects by directory.
  - Git uses a [subpar heuristic](https://www.jonathancreamer.com/how-we-shrunk-our-git-repo-size-by-94-percent/) for delta-encoding at times, even though it has relevant information at hand.
  - <span class="note-tag">In contrast:</span> Mercurial's revlog data structure (or Sapling's [IndexedLog](https://sapling-scm.com/docs/dev/internals/indexedlog)) tends to store e.g. data about the same file in roughly the same area.
- Practically speaking, source files are relatively small, and storage is cheap. It's not such a bad thing to store some duplicate data, if it simplifies the rest of the architecture.

One recent concern is "what if an agent uploads billions of junk objects to our code hosting platform?" You could try to purge the objects with a garbage collection approach, but it would be nicer if the objects were allocated in a user- or branch-specific arena to begin with, and then promoted later. Then you could easily discard the arena without a global traversal.

## What else do neoforges get wrong?

Briefly, I'm wary of:

- Overly-strict consistency guarantees for refs/branches
- Rejecting the use of centralized state for object negotiation between servers and clients

Notice how both the [Anthropic](https://www.anthropic.com/research/redesigning-source-control) and [OpenAI](https://openai.com/index/scaling-git-at-openai/) approaches relax these assumptions.

{% include end_matter.md %}

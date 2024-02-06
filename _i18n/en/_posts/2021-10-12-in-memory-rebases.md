---
layout: post
title: "Lightning-fast rebases with git-move"
permalink: in-memory-rebases/
tags:
  - git
  - rust
  - software-engineering
lobsters: https://lobste.rs/s/tk8s2h/lightning_fast_rebases_with_git_move
---

You can use `git move` as a drop-in 10x faster replacement for `git rebase` (see [the demo](#timing)). The basic syntax is

```
$ git move -b <branch> -d <dest>
```

**How do I install it?** The `git move` command is part of the [git-branchless](https://github.com/arxanas/git-branchless) suite of tools. See the [installation instructions](https://github.com/arxanas/git-branchless/wiki/Installation).

**What does "rebase" mean?** In Git, to "rebase" a commit means to apply a commit's diff against its parent commit as a patch to another target commit. Essentially, it "moves" the commit from one place to another.

**How much faster is it?** See [Timing](#timing). If the branch is currently checked out, then 10x is a reasonable estimate. If the branch is not checked out, then it's even faster.

**Is performance the only added feature?** `git move` also offers several other quality-of-life improvements over `git rebase`. For example, it can move entire subtrees, not just branches. See [the `git move` documentation](https://github.com/arxanas/git-branchless/wiki/Command:-git-move) for more information.

---

 * toc
{:toc}

## Timing

I tested on the Git mirror of Mozilla's [gecko-dev](https://github.com/mozilla/gecko-dev) repository. This is a large repository with ~750k commits and ~250k working copy files, so it's good for stress tests.

It takes about 10 seconds to rebase 20 commits with `git rebase`:

<script id="asciicast-437913" src="https://asciinema.org/a/437913.js" async></script>
<noscript><a href="https://asciinema.org/a/437913" target="_blank"><img src="https://asciinema.org/a/437913.svg" /></a></noscript>

Versus about 1 second with `git move`:

<script id="asciicast-437914" src="https://asciinema.org/a/437914.js" async></script>
<noscript><a href="https://asciinema.org/a/437914" target="_blank"><img src="https://asciinema.org/a/437914.svg" /></a></noscript>

These timings are not scientific, and there are optimizations that can be applied to both, but the order of magnitude is roughly correct in my experience.

Since `git move` can operate entirely in-memory, it can also rebase branches which aren't checked out. This is much faster than using `git rebase`, because it doesn't have to touch the working copy at all.

## Why is it faster?

There are two main problems with the Git rebase process:

- It touches disk.
- It uses the index data structure to create tree objects.

With a stock Git rebase, you have to check out to the target commit, and then apply each of the commits' contents individually to disk. After each commit's application to disk, Git will implicitly check the status of files on disk again. This isn't strictly necessary for many rebases, and can be quite slow on sizable repos.

When Git is ready to apply one of the commits, it first populates the "index" data structure, which is essentially a sorted list of all of the files in the working copy. It can be expensive for Git to convert the index into a "tree" object, which is used to store commits internally, as it has to insert or re-insert many already-existing entries into the object database. (There are some optimizations that can improve this, such as the [cache tree extension](https://git-scm.com/docs/index-format#_cache_tree)).

Work is already well underway on upstream Git to support the features which would make in-memory rebases feasible, so hopefully we'll see mainstream Git enjoy similar performance gains in the future.

## What about merge conflicts?

If an in-memory rebase produces a merge conflict, `git move` will cancel it and restart it as an on-disk rebase, so that the user can resolve merge conflicts. Since in-memory rebases are typically very fast, this doesn't usually impede the developer experience.

Of course, it's possible in principle to resolve merge conflicts in-memory as well.

## Related work

In-memory rebases are not a new idea:

- [GitUp](https://github.com/git-up/GitUp) (2015), a GUI client for Git with a focus on manipulating the commit graph.
  - Unfortunately, in my experience, it doesn't perform too well on large repositories.
  - To my knowledge, no other Git GUI client offers in-memory rebases. Please let me know of others, so that I can update this comment.
- [git-revise](https://github.com/mystor/git-revise) (2019), a command-line utility which allows various in-memory edits to commits.
  - git-revise is a replacement for `git rebase -i`, not `git rebase`. It can reorder commits, but it isn't intended to move commits from one base to another. See [Interactive rebase](#interactive-rebase).
- Other source control systems have in-memory rebases, such as [Mercurial](https://www.mercurial-scm.org/) and [Jujutsu](https://github.com/martinvonz/jj).

The goal of the [git-branchless](https://github.com/arxanas/git-branchless) project is to improve developer velocity with various features that can be incrementally adopted by users, such as in-memory rebases. Performance is an explicit feature: it's designed to work with monorepo-scale codebases.

## Interactive rebase

Interactive rebase (`git rebase -i`) is a feature which can be used to modify, reorder, combine, etc. several commits in sequence. `git move` does not do this at present, but this functionality is planned for a future git-branchless release. Watch [the Github repository](https://github.com/arxanas/git-branchless) to be notified of new releases.

In the meantime, you can use [git-revise](https://github.com/mystor/git-revise). Unfortunately, git-branchless and git-revise do not interoperate well due to git-revise's lack of support for the `post-rewrite` hook (see [this issue](https://github.com/mystor/git-revise/issues/35#issuecomment-523237380)).

{% include end_matter.md %}

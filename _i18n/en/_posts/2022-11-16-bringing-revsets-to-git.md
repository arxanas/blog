---
layout: post
title: Bringing revsets to Git
permalink: bringing-revsets-to-git/
tags:
  - git
hn: https://news.ycombinator.com/item?id=33641952
lobsters: https://lobste.rs/s/4lp2pz/bringing_revsets_git
reddit: https://www.reddit.com/r/programming/comments/yxvoy1/bringing_revsets_to_git/
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Intermediate to advanced Git users.</li>
        <li>Developers of version control systems.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Experience with <a href="https://www.mercurial-scm.org">Mercurial</a> at present-day Meta.</li>
        <li>My work on <a href="https://github.com/arxanas/git-branchless">git-branchless</a>.</li>
      </ul></td>
    </tr>
  </table>
</div>

[Revsets are a declarative language from the Mercurial version control system](https://www.mercurial-scm.org/repo/hg/help/revsets). Most commands in Mercurial that accept a commit can instead accept a revset expression to specify one or more commits meeting certain criteria. The [git-branchless](https://github.com/arxanas/git-branchless) suite of tools introduces its own revset language which can be used with Git.

* toc
{:toc}

## Try it out

To try out revsets, [install git-branchless](https://github.com/arxanas/git-branchless#installation), or see [Prior work](#prior-work) for alternatives.

{% aside Sapling SCM %}

While this post was still in draft, [Sapling SCM](https://sapling-scm.com/) was announced, which git-branchless is descended from in spirit. It's discussed in Prior work as well.

{% endaside %}

## Existing Git syntax

Git already supports its own revision specification language (see [`gitrevisions(7)`](https://git-scm.com/docs/gitrevisions)). You may have already written e.g. `HEAD~` to mean the immediate parent of `HEAD`.

However, Git's revision specification language doesn't integrate well with the rest of Git. You can write `git log foo..bar` to list the commits between `foo` and `bar`, but you can't write `git rebase foo..bar` to rebase that same range of commits.

It can also be difficult to express certain sets of commits:

* You can only express contiguous ranges of the commits, not arbitrary sets.
* You can't directly query for the children of a given commit.

git-branchless introduces a revset language which can be used directly via its `git query` or with its other commands, such as `git smartlog`, `git move`, and `git test`.

The rest of this article shows a few things you can do with revsets. You can also read the [Revset recipes](https://github.com/arxanas/git-branchless/discussions/496) thread on the git-branchless discussion board.

## Better scripting

Revsets can _compose_ to form complex queries in ways that Git can't express natively.

In `git log`, you could write this to filter commits by a certain author:

```sh
$ git log --author="Foo"
```

But negating this pattern is quite difficult; see Stack Overflow question [equivalence of: git log --exclude-author?](https://stackoverflow.com/q/6889830/344643).

With revsets, the same search can be straightforwardly negated with `not`:

```sh
$ git query 'not(author.name(Foo))'
```

It's easy to add more filters to refine your query. To additionally limit to files which match a certain pattern and commit messages which contain a certain string, you could write this:

```sh
$ git query 'not(author.name(Foo)) & paths.changed(path/to/file) & message(Ticket-123)'
```

You can express complicated ad-hoc queries in this way without having to write a custom script.

## Better graph view

Git has a graph view available with `git log --graph`, which is a useful way to orient yourself in the commit graph. However, it's somewhat limited in what it can render. There's no way to filter commits to only those matching a certain condition.

git-branchless offers a "smartlog" command which attempts to show you only relevant commits. By default, it includes all of your local work up until the main branch, but not other people's commits. Mine looks like this right now:

{% image smartlog-default.png "Image of the smartlog view with a few draft commits and branches." %}

But you can also filter commits using revsets. To show only my draft work which touches the `git-branchless-lib/src/git` directory, I can issue this command:

{% image smartlog-with-omitted-commits.png "Image of the smartlog view as before, but with only two draft commits visible (excluding those on the main branch)." %}

Another common use-case might be to render the relative topology of branches in just this stack:

{% image smartlog-branch-topology.png "Image of a different smartlog view as before, showing branch-1 and branch-3 with an omitted commit between them." %}

You can also render commits which have already been checked into the main branch, if so desired.

## Better rebasing

Not only can you render the commit graph with revsets, but you can also modify it. Revsets are quite useful when used with "patch-stack" workflows, such as those used for the Git and Linux projects, or at certain tech companies practicing [trunk-based development](https://trunkbaseddevelopment.com/).

For example, suppose you have some refactoring changes to the file `foo` on your current branch, and you want to separate them into a new branch for review:

{% image drawn-smartlog.png "Image of a feature branch with four commits. Each commit shows two touched files underneath it." %}

You can use revsets to select just the commits touching `foo` in the current branch:

{% image drawn-smartlog-filtered-commits.png "Image of the same feature branch as before, but with the first and third commits outlined in red and the touched file 'foo' in red." %}


Then use `git move` to pull them out:

```sh
$ git move --exact 'stack() & paths.changed(foo)' --dest 'main'
```

{% image drawn-smartlog-extract-commits.png "Image of the same feature branch as before, but the first and third commits are shown to be missing from the original feature branch, with dotted outlines indicating their former positions. They have been moved to a new feature branch, still preserving their relative order." %}


If you want to reorder the commits so that they're at the base of the current branch, you can just add `--insert`:

```sh
$ git move --exact 'stack() & paths.changed(foo)' --dest 'main' --insert
```

{% image drawn-smartlog-reordered-commits.png "Image of the same feature branch as before, but the first and third commits are shown to be missing from their original positions in the feature branch, with dotted outlines indicating their former positions. They have been moved to the beginning of that same feature branch, still preserving their relative order, now before the second and fourth commits, also preserving their relative order." %}

Of course, you can use a number of different predicates to specify the commits to move. See the full [revset reference](https://github.com/arxanas/git-branchless/wiki/Reference:-Revsets).

## Better testing

You can use revsets with git-branchless's `git test` command to help you run (or re-run) tests on various commits. For example, to run `pytest` on all of your branches in parallel and cache the results, you can run:

```sh
$ git test run --exec 'pytest' --jobs 4 'branches()'
```

You can also use revsets to aid the investigation of a bug with `git test`. If you know that a bug was introduced between commits A and B, and has to be in a commit touching file `foo`, then you can use `git test` like this to find the first commit which introduced the bug:

```sh
$ git test run --exec 'cargo test' 'A:B & paths.changed(foo)'
```

This can be an easy way to skip commits which you know aren't relevant to the change.

{% aside Versus git bisect %}

You can use `git bisect` and filter by paths, of course, but it may be more tedious. Note that, unlike `git bisect`, `git test` currently conducts a linear search, so it's not the best choice for all cases. This will hopefully change in the future.

`git test` has several features which `git bisect` doesn't offer, such as parallel testing, out-of-tree testing, and caching of test results.

{% endaside %}

{% aside Caching test results %}

`git test` will cache the results of the test command, so if you decide to expand the search set later, you don't have to re-run the test command on commits you've already tested.

{% endaside %}
## Prior work

This isn't the first introduction of revsets to version control. Prior work:

* Of course, Mercurial itself introduced revsets. See the documentation here: [https://www.mercurial-scm.org/repo/hg/help/revsets](https://www.mercurial-scm.org/repo/hg/help/revsets)
* [https://github.com/quark-zju/gitrevset](https://github.com/quark-zju/gitrevset): the immediate predecessor of this work. git-branchless uses the same back-end "segmented changelog" library (from [Sapling SCM](https://github.com/facebookexperimental/eden), then called Eden SCM) to manage the commit graph. The advantage of using revsets with git-branchless is that it integrates with several other commands in the git-branchless suite of tools.
* [https://sapling-scm.com/](https://sapling-scm.com/): also an immediate predecessor of this work, as it originally published the segmented changelog library which `gitrevset` and git-branchless use. git-branchless was inspired by Sapling's design, and has similar but non-overlapping functionality. See [https://github.com/arxanas/git-branchless/discussions/654](https://github.com/arxanas/git-branchless/discussions/654) for more details.
* [https://github.com/martinvonz/jj](https://github.com/martinvonz/jj): Jujutsu is a Git-compatible VCS which also offers revsets. git-branchless and jj have similar but non-overlapping functionality. It's worth checking out if you want to use a more principled version control system but still seamlessly interoperate with Git repositories. I expect git-branchless's unique features to make their way into Jujutsu over time.

{% include end_matter.md %}

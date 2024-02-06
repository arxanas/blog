---
layout: post
title: "Quickly formatting a stack of commits"
permalink: formatting-a-commit-stack/
translations:
  pl: "/pl/formatowanie-stosu-zatwierdzeń/"
tags:
  - git
  - software-engineering
lobsters: https://lobste.rs/s/rpdt88/quickly_formatting_stack_commits
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Software engineers working with Git who use "patch stacks"/"stacked diffs", such as how Git is used for the Git and Linux projects, as well as for many companies practicing <a href="https://trunkbaseddevelopment.com/">trunk-based development</a>.</li>
        <li><em>Not</em> Git users who think the Git commit graph should reflect the actual development process.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td>My work on <a href="https://github.com/arxanas/git-branchless">git-branchless</a>.</td>
    </tr>
    <tr>
      <td>Mood</td>
      <td>Unheeded by most.</td>
    </tr>
  </table>
</div>

A certain category of developer uses Git with a "patch stack" workflow, in which they accumulate a sequence of small, individually-reviewable commits that together implement a large change. In these cases, it's oftentimes useful to run linters or formatters on each commit in the stack and apply the results. However, this can be tedious, and a naive approach can cause needless merge conflicts. (One workaround is to run formatters on each commit in the stack *backwards*.)

[git-branchless](https://github.com/arxanas/git-branchless)'s `git test` command offers a solution to quickly run formatters, etc., on an entire stack of commits without causing merge conflicts. Additionally, it can be performed in parallel, and it caches results so that reformats of the same commits are skipped. You can see the [announcement post](https://github.com/arxanas/git-branchless/discussions/803) or [the documentation for `git test`](https://github.com/arxanas/git-branchless/wiki/Command:-git-test).

Here's a demo of formatting the commits in a stack (skip to 0:35 to see just the demonstration of `git test fix`):

<video src="https://user-images.githubusercontent.com/454057/219904589-79657aed-9356-4f87-a0e4-bdcfbe691621.mov" controls="controls" muted="muted"></video>

I usually set `git fmt` to an alias for something like

```
git test run --exec 'cargo fmt --all' --strategy worktree --jobs 8
```

{% include end_matter.md %}

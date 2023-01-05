---
layout: post
title: Where are my Git UI features from the future?
permalink: git-ui-features/
tags:
  - git
  - rant
  - software-engineering
---

 * toc
{:toc}

## Git sucks

The [Git version control system](https://git-scm.com/) has been causing us misery for 15+ years. Since its inception, a thousand people have tried to make new clients for Git to improve usability.

But practically everyone has focused on providing a pretty facade to do more or less the same operations as Git on the command-line --- as if Git's command-line interface were already the pinnacle of usability.

No one bothers to consider: what are the *workflows* that people actually want to do? What are the *features* that would make those workflows easier? So instead we get clients which think that `git rebase -i` as the best possible way to reword a commit message, or edit an old commit, or split a commit, or even worth exposing in the UI.

## Rubric

I thought about some of the workflows I carry out frequently, and examined several Git clients (some of which are [GUIs](https://en.wikipedia.org/wiki/Graphical_user_interface) and some of which are [TUIs](https://en.wikipedia.org/wiki/Text-based_user_interface)) to see how well they supported these workflows.

Many of my readers won't care for these workflows, but it's not just about the workflows themselves; it's about the resolve to improve workflows by not using the faulty set of primitives offered by Git. I do not care to argue about which workflows are best or should be supported.

Workflows:
- **`reword`**: It should be possible to update the commit message of a commit which isn't currently checked out.
  - It should also be possible to reword a commit which is the ancestor of multiple branches without abandoning some of those branches, but let's not get our hopes up...
- **`sync`**: It should be possible to sync *all* of my branches (or some subset) via merge or rebase, in a single operation.
  - I do this all the time! Practically the first thing every morning when coming into work.
- **`split`**: There should be a specific command to split a commit into two or more commits, including commits which aren't currently checked out.
  - Splitting a commit is guaranteed to not cause a merge conflict, so requiring that the commit be checked out is unnecessary.
  - Not accepting `git rebase -i` solutions, as it's very confusing to examine the state of the repository during a rebase.
- **`preview`**: Before carrying out a merge or rebase, it should be possible to preview the result, including any conflicts that would arise.
  - That way, I don't have to start the merge/rebase operation in order to see if it will succeed or whether it will be hard to resolve conflicts.
  - Merge conflicts are perhaps the worst part about using Git, so it should be much easier to work with them (and avoid dealing with them!).
  - The only people who seem to want this feature are people who come from other version control systems.
- **`undo`**: I should be able to undo arbitrary operations, ideally including tracked but uncommitted changes.
- **`large-load`**: The UI should load large repositories quickly.
  - The program is allowed to be slow on the first invocation to build any caches, but must be responsive on subsequent invocations. The UI shouldn't hang at any point, although it may take a while to show useful information.
- **`large-ops`**: The UI should be responsive when carring out various operations, such as examining commits and branches, or merging or rebasing.

Honor:

- I will award **honorary negative points** for any client which dares to treat `git rebase -i` as if it were a fundamental primitive.
- I will award **honorary bonus points** for any client which seems to respect the empirical usability research for Git (or other VCSes). Examples:
  - Gitless: <https://gitless.com/>
  - IASGE: <https://investigating-archiving-git.gitlab.io/>

Since I didn't note down the honor scoring in this article, these are just so that any vendors of these clients can know whether I am impressed or disappointed by them.

## Clients

I picked some clients arbitrarily from [this list of clients](https://git-scm.com/downloads/guis). I am surely wrong about some of these points (or they've changed since I last looked), so leave a comment or inline comment (hover/tap and click "comment") to correct me.

### Git CLI

[Git CLI](https://git-scm.com/):
- `reword`: no
  - You can do it via `git rebase -i`, but it's not ergonomic, and it only works for commits reachable from `HEAD` instead of from other branches.
- `sync`: no
- `split`: no
- `preview`: no
- `undo`: no
- `large-load`: we'll consider this the baseline for operations on large repositories, even though Git itself struggles at present with some operations.
- `large-ops`: likewise.

### GitKraken

[GitKraken](https://www.gitkraken.com/):
- `reword`: no
- `sync`: no
- `split`: no
- `preview`: no
- `undo`: yes
- `large-load`: no
- `large-ops`: no

### Fork

[Fork](https://git-fork.com/):
- `reword`: no
- `sync`: no
- `split`: no
- `preview`: partial
  - Shows if merge is fast-forward or not.
- `undo`: ?
- `large-load`: no
- `large-ops`: no

### Sourcetree

[Sourcetree](https://www.sourcetreeapp.com/):
- `reword`: no
- `sync`: no
- `split`: no
- `preview`: no
- `undo`: yes
- `large-load`: no
- `large-ops`: yes

### Sublime Merge

[Sublime Merge](https://www.sublimemerge.com/):
- `reword`: no
- `sync`: no
- `split`: no
- `preview`: partial
  - Shows if merge is fast-forward or not.
- `undo`: yes
- `large-load`: yes
- `large-ops`: yes

### SmartGit

[SmartGit](https://www.syntevo.com/smartgit/):
- `reword`: no  
- `sync`: no
- `split`: no
- `preview`: no
- `large-load`: no
- `large-ops`: no

### GitUp

[GitUp](https://gitup.co/):
- `reword`: yes
- `sync`: no
- `split`: yes
- `preview`: no
- `undo`: yes
- `large-load`: no
- `large-ops`: yes

### Magit

[Magit](https://magit.vc/)
- `reword`: no
- `sync`: no
- `split`: no
- `preview`: yes
  - Via magit-merge-preview.
- `undo`: no
- `large-load`: probably baseline
- `large-ops`: probably baseline

### Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit):
- `reword`: no
- `sync`: no
- `split`: no
- `preview`: no
- `undo`: yes
  - experimental, via reflog
- `large-load`: yes
- `large-ops`: yes

### Gitui

[Gitui](https://github.com/extrawurst/gitui):
- `reword`: no
- `sync`: no
- `split`: no
- `preview`: no
- `undo`: no
- `large-load`: yes
- `large-ops`: yes

### git-branchless

This is my own project, so it doesn't really count as an example of innovation in the industry. I'm including it to demonstrate that many of these workflows are very much possible.

[git-branchless](https://github.com/arxanas/git-branchless)
- `reword`: yes
- `sync`: yes
- `split`: no
  - One day...
- `preview`: partial
  - If an operation would cause a merge conflict, and `--merge` was not passed, instead aborts and shows which files were conflicting.
- `undo`: yes
- `large-load`: yes
- `large-ops`: yes

## Commendations

Commendations:

- GitUp: the most innovative Git GUI of the above.
- GitKraken: innovating in some spaces, such as improved support for centralized workflows via warning about concurrently-edited files.
- Sublime Merge: incredibly responsive, as to be expected from the folks responsible for [Sublime Text](https://www.sublimetext.com/).

{% include end_matter.md %}

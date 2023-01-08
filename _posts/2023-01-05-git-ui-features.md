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
  - Rewording a commit is guaranteed to not cause a merge conflict, so requiring that the commit be checked out is unnecessary.
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
  - This is *not* the same as reverting a commit. Reverting a commit creates an altogether new commit with the inverse changes, whereas undoing an operation should restore the repository to the state it was in before the operation was carried out, so there would be no original commit to revert.
- **`large-load`**: The UI should load large repositories quickly.
  - The UI shouldn't hang at any point, and should show useful information as soon as it's loaded. You shouldn't have to wait for the entire repository to load before you can examine commits or branches.
  - The program is allowed to be slow on the first invocation to build any necessary caches, but must be responsive on subsequent invocations.
- **`large-ops`**: The UI should be responsive when carring out various operations, such as examining commits and branches, or merging or rebasing.

Extra points:

- I will award **honorary negative points** for any client which dares to treat `git rebase -i` as if it were a fundamental primitive.
- I will award **honorary bonus points** for any client which seems to respect the empirical usability research for Git (or other VCSes). Examples:
  - Gitless: <https://gitless.com/>
  - IASGE: <https://investigating-archiving-git.gitlab.io/>

Since I didn't actually note down any of this, these criteria are just so that any vendors of these clients can know whether I am impressed or disappointed by them.

## Clients

I picked some clients arbitrarily from [this list of clients](https://git-scm.com/downloads/guis). I am surely wrong about some of these points (or they've changed since I last looked), so leave a comment.

I included my own project [git-branchless](https://github.com/arxanas/git-branchless), so it doesn't really count as an example of innovation in the industry. I'm including it to demonstrate that many of these workflows are very much possible.

<style type="text/css">
th.rotate {
  /* Something you can count on */
  height: 140px;
  white-space: nowrap;
}

th.rotate > div {
  transform: 
    /* Magic Numbers */
    translate(25px, 51px)
    /* 45 is really 360 - 45 */
    rotate(315deg);
  width: 30px;
}
th.rotate > div > span {
  border-bottom: 1px solid #eee;
  padding: 5px 10px;
}

#data th:nth-child(even) > div > span {
  border-bottom: 3px solid #eee;
}

#data td:nth-child(even) {
  background-color: #eee;
}

</style>

<table id="data">
<thead>
  <tr>
    <th></th>
    <th class="rotate"><div><span><a href="https://git-scm.com/">Git CLI</a></span></div></th>
    <th class="rotate"><div><span><a href="https://www.gitkraken.com/">GitKraken</a></span></div></th>
    <th class="rotate"><div><span><a href="https://git-fork.com/">Fork</a></span></div></th>
    <th class="rotate"><div><span><a href="https://www.sourcetreeapp.com/">Sourcetree</a></span></div></th>
    <th class="rotate"><div><span><a href="https://www.sublimemerge.com/">Sublime Merge</a></span></div></th>
    <th class="rotate"><div><span><a href="https://www.syntevo.com/smartgit/">SmartGit</a></span></div></th>
    <th class="rotate"><div><span><a href="https://gitup.co/">GitUp</a></span></div></th>
    <th class="rotate"><div><span><a href="https://magit.vc/">Magit</a></span></div></th>
    <th class="rotate"><div><span><a href="https://github.com/jesseduffield/lazygit">Lazygit</a></span></div></th>
    <th class="rotate"><div><span><a href="https://github.com/extrawurst/gitui">Gitui</a></span></div></th>
    <th class="rotate"><div><span><a href="https://github.com/arxanas/git-branchless">git-branchless</a></span></div></th>
    <th class="rotate"><div><span><a href="https://github.com/martinvonz/jj">Jujutsu</a></span></div></th>
  </tr>
</thead>

<tbody>
  <tr>
    <th><code>reword</code></th>
    <td>❌ <sup>1</sup></td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>❌</td> <!-- Fork -->
    <td>❌</td> <!-- Sourcetree -->
    <td>❌</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>✅</td> <!-- GitUp -->
    <td>❌</td> <!-- Magit -->
    <td>❌</td> <!-- Lazygit -->
    <td>❌</td> <!-- Gitui -->
    <td>✅</td> <!-- git-branchless -->
    <td>✅</td> <!-- jj -->
  </tr>
  
  <tr>
    <th><code>sync</code></th>
    <td>❌</td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>❌</td> <!-- Fork -->
    <td>❌</td> <!-- Sourcetree -->
    <td>❌</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>❌</td> <!-- GitUp -->
    <td>❌</td> <!-- Magit -->
    <td>❌</td> <!-- Lazygit -->
    <td>❌</td> <!-- Gitui -->
    <td>✅</td> <!-- git-branchless -->
    <td>❌</td> <!-- jj -->
  </tr>
  
  <tr>
    <th><code>split</code></th>
    <td>❌ <sup>1</sup></td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>❌</td> <!-- Fork -->
    <td>❌</td> <!-- Sourcetree -->
    <td>❌</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>✅</td> <!-- GitUp -->
    <td>❌</td> <!-- Magit -->
    <td>❌</td> <!-- Lazygit -->
    <td>❌</td> <!-- Gitui -->
    <td>❌</td> <!-- git-branchless -->
    <td>✅</td> <!-- jj -->
  </tr>
  
  <tr>
    <th><code>preview</code></th>
    <td>❌</td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>⚠️ <sup>2</sup></td> <!-- Fork -->
    <td>❌</td> <!-- Sourcetree -->
    <td>⚠️ <sup>2</sup></td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>❌</td> <!-- GitUp -->
    <td>✅ <sup>3</sup></td> <!-- Magit -->
    <td>❌</td> <!-- Lazygit -->
    <td>❌</td> <!-- Gitui -->
    <td>⚠️ <sup>4</sup></td> <!-- git-branchless -->
    <td>✅ <sup>5</sup></td> <!-- jj -->
  </tr>

  <tr>
    <th><code>undo</code></th>
    <td>❌</td> <!-- Git CLI -->
    <td>✅</td> <!-- GitKraken -->
    <td>❓</td> <!-- Fork -->
    <td>✅</td> <!-- Sourcetree -->
    <td>✅</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>✅</td> <!-- GitUp -->
    <td>✅</td> <!-- Magit -->
    <td>⚠️ <sup>6</sup></td> <!-- Lazygit -->
    <td>❌</td> <!-- Gitui -->
    <td>✅</td> <!-- git-branchless -->
    <td>✅</td> <!-- jj -->
  </tr>

  <tr>
    <th><code>large-load</code></th>
    <td>✅ <sup>7</sup></td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>❌</td> <!-- Fork -->
    <td>❌</td> <!-- Sourcetree -->
    <td>✅</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>❌</td> <!-- GitUp -->
    <td>✅ <sup>8</sup></td> <!-- Magit -->
    <td>✅</td> <!-- Lazygit -->
    <td>✅</td> <!-- Gitui -->
    <td>✅</td> <!-- git-branchless -->
    <td>❌</td> <!-- jj -->
  </tr>
  
  <tr>
    <th><code>large-ops</code></th>
    <td>✅ <sup>7</sup></td> <!-- Git CLI -->
    <td>❌</td> <!-- GitKraken -->
    <td>❌</td> <!-- Fork -->
    <td>✅</td> <!-- Sourcetree -->
    <td>✅</td> <!-- Sublime Merge -->
    <td>❌</td> <!-- SmartGit -->
    <td>✅</td> <!-- GitUp -->
    <td>✅ <sup>8</sup></td> <!-- Magit -->
    <td>✅</td> <!-- Lazygit -->
    <td>✅</td> <!-- Gitui -->
    <td>✅</td> <!-- git-branchless -->
    <td>❌</td> <!-- jj -->
  </tr>
</tbody>
</table>

Notes:

* <sup>1</sup> It can be done via `git rebase -i` or equivalent, but it's not ergonomic, and it only works for commits reachable from `HEAD` instead of from other branches.
* <sup>2</sup> Partial support; it can show whether the merge is fast-forward or not, but no additional details.
* <sup>3</sup> Can be done via `magit-merge-preview`.
* <sup>4</sup> Partial support; if an operation would cause a merge conflict and `--merge` wasn't passed, then instead aborts and shows the number of files that would conflict.
* <sup>5</sup> Jujutsu doesn't let you preview merge conflicts *per se*, but merges and rebases always succeed and the conflicts are stored in the commit, and then you can undo the operation if you don't want to deal with the merge conflicts. You can even restore the old version of the commit well after you carried out the merge/rebase, if desired. This avoids interrupting your workflow, which is the ultimate goal of this feature, so I'm scoring it as a pass for this category.
* <sup>6</sup> Undo support is experimental and based on the reflog, [which can't undo all types of operations](https://github.com/arxanas/git-branchless/wiki/Architecture#comparison-with-the-reflog).
* <sup>7</sup> Git struggles with some operations on large repositories and can be improved upon, but we'll consider this to be the baseline performance for large repositories.
* <sup>8</sup> Presumably Magit has the same performance as Git, but I didn't check because I don't use Emacs.

## Awards

Commendations:

- GitUp: the most innovative Git GUI of the above.
- GitKraken: innovating in some spaces, such as improved support for centralized workflows by warning about concurrently-edited files. These areas aren't reflected above; I just noticed them on other occasions.
- Sublime Merge: incredibly responsive, as to be expected from the folks responsible for [Sublime Text](https://www.sublimetext.com/).

Demerits:

- Fork: for making it really hard to search for documentation ("git fork undo" mostly produces results for undoing forking in general, not for the Fork client).
- SmartGit: for being deficient in every category tested.

{% include end_matter.md %}

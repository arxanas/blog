---
layout: post
title: "Patch terminology"
permalink: patch-terminology/
tags:
  - git
  - reprint
  - software-engineering
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Developers of version control systems, specifically <a href="https://github.com/martinvonz/jj">jj</a>.</li>
        <li>Those interested in the version control pedagogy.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Reprint of <a href="https://docs.google.com/document/d/1qrv8I_IqRz8CdohZw6VcMssBEetoGmQj33vPz1_XlYI/edit?usp=sharing">research originally published on Google Docs</a>.</li>
        <li>Surveyed five participants from various "big tech" companies (>$1B valuation).</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td>Investigative.</td>
    </tr>
  </table>
</div>

 * toc
{:toc}



## Methodology

Q: I am doing research for a source control project, can you answer what the following nouns mean to you in the context of source control, if anything? (Ordered alphabetically)



* a "change"
* a "commit"
* a "patch"
* a "revision"


## Results

P1 (Google, uses Piper + CLs):



* Change: a difference in code. What isn't committed yet.
* Commit: a cl. Code that is ready to push and has a description along with it
* Patch: a commit number that that someone made that may or may not be pushed yet [...] A change that's not yours
* Revision: a change to a commit?

P2 (big tech, uses GitLab + MRs):



* Change: added/removed/updated files
* Commit: a group of related changes with a description
* Patch: a textual representation of changes between two versions
* Revision: a version of the repository, like the state of all files after a set of commits

P3 (Google, uses Fig + CLs):



* Change: A change to me is any difference in code. Uncommitted to pushed. I've heard people say I've pushed the change.
* Commit: A commit is a saved code diff with a description.
* Patch: A patch is a diff between any two commits how to turn commit a into into b.
* Revision: Revisions idk. I think at work they are snapshots of a code base so all changes at a point in time.

P4 (Microsoft, uses GitHub + PRs):



* Change: the entire change I want to check into the codebase this can be multiple commits but it’s what I’m putting up for review
* Commit: a portion of my change  
* Patch: a group of commits or a change I want to use on another repo/branch
* Revision: An id for a group of commits or a single commit

P5 (big tech, uses GitHub + PRs):



* Change: your update to source files in a repository
* Commit: description of change
* Patch: I don’t really use this but I would think a quick fix (image, imports, other small changes etc)
* Revision: some number or set of numbers corresponding to change


## Remarks

Take-aways:



* Change: People largely don't think of a "change" as an physical object, rather just a diff or abstract object.
    * It can potentially range from uncommitted to committed to pushed (P1–P5).
    * Unlike others, P4 thinks of it as a _larger_ unit than a commit (more like a "review"), probably due to the GitHub PR workflow.
* Commit: Universally, commits are considered to have messages. However, the interpretation of a commit as a _snapshot_ vs _diff_ appears to be implicit (compare P2's "commit" vs "revision").
* Patch: Split between interpretations:
    * Either it represents a _diff_ between two versions of the code (P2, P3).
    * Or it's a higher-level interpretation of a patch as a _transmissible change_. Particularly for getting a change from someone else (P1), but can also refer to a change that you want to use on a different branch (P4).
    * P5 merely considers a "patch" to be a "small fix", which is also a generally accepted meaning, although a little imprecise in terms of source control (refers to the _intention_ of the patch, rather than the mechanics of the patch itself).
* Revision: This is really interesting. The underlying mental models are very different, but the semantic implications end up aligning, more so than for the term "commit"!
    * P1: Not a specific source control term, just "the effect of revising".
    * P2, P3: Effect of "applying all commits". This implies that they consider "commits" as _diffs_ and "revisions" as _snapshots_.
    * P4, P5, Some notions that it's specifically the _identifier_ of a change/commit. It's something that you can reference or send to others.
    * Surprisingly to me, P2–P5 actually all essentially agree that "revision" means a _snapshot_ of the codebase. The mental models are quite different ("accumulation of diffs" vs "stable identifier") but they refer to the same ultimate result: a specific state of the codebase (...or a way to refer to it — what's in a name?). This is essentially the opposite of "commit", where everyone _thinks_ that they agree on what they are, but they're actually split — roughly evenly? — into _snapshot_ vs _diff_ mental models.


## Conclusions

Conclusions for [jj]:


  [jj]: https://github.com/martinvonz/jj


* We already knew that "change" is a difficult term, syntactically speaking. It's also now apparent that it's semantically unclear. Only P4 thought of it as a "reviewable unit", which would probably most closely match the jj interpretation. We should switch away from this term.
* People are largely settled on what "commits" are in the ways that we thought.
    * There are two main mental models, where participants appear to implicitly consider them to be either snapshots or diffs, as we know.
    * They _have_ to have messages according to participants (unlike in jj, where a commit/change may not yet have a message).
        * It's possible this is an artifact of the Git mental model, rather than fundamental. We don't see a lot of confusion when we tell people "your commits can have empty messages".
        * I think the real implication is that the set of changes is packaged/finalized into _one unit_, as opposed to "changes", which might be in flux or not properly packaged into one unit for publishing/sharing.
* Half of respondents think that "patch" primarily refers to a _diff_, while half think that it refers to a _transmissible change_.
    * In my opinion, the "transmissible change" interpretation aligns most closely with jj changes at present. In particular, you put those up for review and people can download them.
    * I also think the "diff" interpretation aligns with jj interpretation (as you can rebase patches around, and the semantic content of the patch doesn't change); however, there is a [great deal of discussion on Discord](https://discord.com/channels/968932220549103686/1187096737639321742) suggesting that people think of "patches" as immutable, and this doesn't match the jj semantics where you can rebase them around (IIUC).
    * Overall, I think "patch" is still the best term we have as a replacement for jj "changes" (unless somebody can propose a better one), and it's clear that we should move away from "change" as a term.
* "Revision" is much more semantically clear than I thought it was. This means that we can adopt/coopt the existing term and ascribe the specific "snapshot" meaning that we do today.
    * We already _do_ use "revision" in many places, most notably "revsets". For consistency, we likely want to standardize "revision" instead of "commit" as a term.

{% include end_matter.md %}

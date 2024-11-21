---
layout: post
title: Writing brittle code
permalink: writing-brittle-code/
tags:
  - software-engineering
  - software-verification
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td>Software engineers, particularly those at large companies or organizations.</td>
    </tr>
    <tr>
      <td>Origin</td>
      <td>General software engineering experience.</td>
    </tr>
    <tr>
      <td>Mood</td>
      <td>Cautionary.</td>
    </tr>
  </table>
</div>

{% include toc.md %}

I particularly like this characterization from [*Leaving Haskell behind* (2023)](https://journal.infinitenegativeutility.com/leaving-haskell-behind):

> I would describe good Haskell code as “brittle”, and I mean that as a compliment. People tend to casually use “brittle” to mean “prone to breakage”, but in materials science what “brittle” means is that something breaks without bending: when a brittle material reaches the limits of its strength, it fractures instead of deforming. Haskell is a language where abstractions do not “bend” (or permit invalid programs) but rather “break” (fail to compile) in the face of problems.

In my career so far, a great deal of the code and systems I've written has had to be maintained by generalists who work across a variety of domains and have no idea what's going on (including *future me*). Writing *brittle* code has been the best approach to ensure maintainability.

At work, right now, I am writing an internal web app to expose some of our tooling nicely. Nobody on our team, me included, is a front-end engineer!

In [*Smash Training retrospective*]({% permalink smash-training-retrospective %}), I remark that I regretted using Vue for various reasons. The lack of static checking has made it difficult for *future me* to make small bugfixes. Implicit dependency tracking as a framework decision, as in Vue, turns out to be quite difficult for *future me* to manage mentally. (For example, there are [caveats with arrays](https://v2.vuejs.org/v2/guide/reactivity.html#For-Arrays) that I encountered during maintenance.)

Even though React's alternative approach of explicitly declaring dependencies is rather heavy-handed, it ends up being more tractable for *future me*, and probably for my coworkers as well. My technology choices were *insufficiently brittle* to accomodate future maintenance.

{% aside Don't tell me about reactivity %}

I don't care if the preceding example is entirely wrong from a factual or subjective perspective, so don't tell me. It's an ultimately individually-unimportant example of the larger point that I'm trying to make.

{% endaside %}

The situation is quite different for specialists, who can make the investment of *becoming familiar with a system* to gain productivity with it. Someone accustomed to implicit dependency tracking will benefit from not having to write the dependencies explicitly. Due to my work domain, I am usually not one of those people!

{% include end_matter.md %}

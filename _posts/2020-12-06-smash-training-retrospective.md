---
layout: post
title: 'Smash Training retrospective'
permalink: smash-training-retrospective/
hn: https://news.ycombinator.com/item?id=25387356
tags:
  - smash-bros
  - software-engineering
---

[*Smash Training*](https://ssb.fit) is a spaced-repetition training web-app I created to help my progression with *Super Smash Bros. Ultimate*. I released it on May 16, 2020 [on Reddit](https://www.reddit.com/r/CrazyHand/comments/gkybpe/trying_to_get_into_elite_smash_this_quarantine/?utm_source=share&utm_medium=web2x&context=3) to warm reception. As of December 2020, it receives 150-200 monthly users. I'd rank it as my most successful project!

In this article, I discuss the choices I made for this project. The source code is available at [https://github.com/arxanas/smashtraining](https://github.com/arxanas/smashtraining).

* toc
{:toc}

## Project requirements

I decided that I wanted to build a spaced-repetition training app, rather than reuse a general-purpose spaced-repetition flash-card system such as Anki, because the project would benefit from domain-specific knowledge. For example:

* Exercises have large numbers of variants, such as "short-hop" vs "full-hop", or "facing left" vs "facing right", which should be tracked separately.
* Many of the exercises have natural dependencies on others: they shouldn't be attempted unless a certain underlying fundamental skill has been mastered.
* Exercises to train one character don't necessarily confer the same skill for other characters. Some exercises may only be applicable to some characters.

I decided to make an app to automate the spaced repetition regimen I was attempting to follow by hand, which I could then share with others.

Here were my engineering requirements:

* Should be mobile-first, but preferably also available on desktop.
* Should be local-first, or at least not require creating an account to use.
* Should be architected to support sync between devices, although the sync itself was not a requirement for the first iteration.
* Should have approximately zero hosting costs.
* Should be hosted on of a stable platform which doesn't require monitoring (e.g. not my home computer).

## Domain name

I wanted to choose between a permutation like the following for the domain name:

* smashtraining.com
* ssbtraining.com
* smash.training
* ssb.training
* smash.fit
* ssb.fit

In the end, I used `ssb.fit` because 1) `smash.training` got taken (!) and 2) I wanted to optimize for typing it in on a mobile device, even though the name is less memorable. This lack of memorability unfortunately manifested in [this Reddit thread titled "WTF was that smash training website called?"](https://www.reddit.com/r/CrazyHand/comments/gp9sem/wtf_was_that_smash_training_website_called/frkscwe/?context=3). However, another commenter writes "ssb.fit is better, short for mobile", perhaps vindicating the original choice.

It's unfortunate that the domain name and the website title don't exactly match up. Many people seemed to address it as "ssb.fit" hence, so maybe that's what the project should have been called too (rather than "Smash Training").

## User studies and UI

I conducted several user studies with friends and family, including some people who had played Smash before and some who hadn't.

### UI

The first main thing I iterated on was the design of the exercise tracker widget. I originally based it off of the *Stronglifts* app:

{% image stronglifts.png "Advertisement screenshot of the Stronglifts workout app." %}

*Stronglifts* has you note down how many repetitions of the exercise you succeeded at (out of five). However, the *Smash Training* paradigm is different, and has you repeat the exercise for a length of time and rate your accuracy.

I experimented with a "smiley-face" UI rather than a rep-count UI, as in Stronglifts, along with a few other options. After a lot of feedback from friends, I arrived at a slider-based widget like this:

{% image smash-training-exercise-widget.png "Screenshot of the Smash Training exercise widget." %}

This uses a slider approach (with five possible notches), and renders a description of what each notch corresponds to, i.e. "all or nearly all reps correct".

### Documentation

The second main thing was the ordering of the elements in the "Learn exercise" page. Each exercise has a step-by-step description of how to do the exercise, what controller inputs must be performed, background on the technique and its importance, a video tutorial, etc.

My assumption was that most people would read very little of it, so I should put the most important items first. However, various users disagreed on which item was the most important. There was no strong consensus, but the end result was this ordering:

* Step-by-step exercise description.
* Controller inputs.
* Technique overview.
* The rest of the documentation elements (not as important).

There were also hints on these steps such as how to enter the Training Stage to perform the exercises. Some users missed these steps altogether, and were left confused on how to perform the exercise. Unfortunately, I was unable to design a UI that mitigated this problem.

## Tech stack

I chose to write a web-app, since they are cross-platform and I already had some familiarity with the area. In particular, I didn't want to spend money on an iOS developer license, but I also didn't want to exclude iOS users. (Post-hoc analytics indicate that the ratio of Android-to-iOS users is about 2:1, which consitutes a significant cohort for iOS.)

### Build system

All Javascript web-app bundling solutions are fundamentally terrible, and Webpack is no exception. But it works.

[I encountered one mysterious bug in Babel during development](https://github.com/arxanas/smashtraining/commit/f621f02af95da697435cb720563b590d57f38b87), which I was unable to isolate. I worked around it by targeting only newer browsers, after which the problem disappeared.

I used `vue-cli-service` as a wrapper around the build, test, and lint actions, as recommended by Vue. But I found it hard to configure and debug. When I had an issue with tests not properly compiling an imported module, [I gave up and reimplemented the function I needed myself](https://github.com/arxanas/smashtraining/blame/d0c31a33ab880e8c58824c0f58247c8bd8f38485/src/utils.ts#L38-L44).

### TypeScript

I also used [TypeScript](https://www.typescriptlang.org/), since I find its static typing system useful for maintenance purposes.

TypeScript support for Vue was not ideal. Many Vue patterns are not easy to express in TypeScript. Libraries like [`vuex-typescript`](https://github.com/istrib/vuex-typescript) exist, but require a lot of boilerplate in order to get static typing support. The [`direct-vuex`](https://github.com/paroi-tech/direct-vuex) library had less boilerplate, but [I couldn't figure out how to test it](https://github.com/arxanas/smashtraining/commit/9a8c0c0baf05d048a564b11f62afdfafc9f66a62).

TypeScript was generally pleasant to work with, although in the project, I pushed it to its extremes and it was unable to keep pace. In my case, it was unable to track associated/mapped types adequately. It's perhaps exemplified by this `@ts-ignore` comment:

```ts
export type TechVariantOf<T extends TechId> = {
  // @ts-ignore "Type 'x' cannot be used to index type 'AllTechVariants'."
  // Strangely, the correct type is calculated here anyways, and can be used for
  // exhaustiveness-checking later.
  [x in keyof AllTechMetadata[T]["variants"]]: AllTechVariants[x];
};
```

I also ran into [this issue](https://github.com/microsoft/TypeScript/issues/13215#issuecomment-531632919) when working on the same thing.

Given that this is reasonably advanced type-level hackery, I was generally happy with TypeScript's ability to describe the data domain.

### Vue

I chose to use [Vue](https://vuejs.org/) as the front-end web framework, since I had heard good things about it from [Hacker News](https://news.ycombinator.com/). In particular, I wanted an opinionated framework, so as to spend less time configuring things myself.

When I used it, Vue promoted the ["single-file component"](https://vuejs.org/v2/guide/single-file-components.html) system, in which HTML, CSS, and Javascript are mixed into the same file. It was not a great experience:

* This complicates the build process, as something has to convert these single-file components into assets consumable by the browser.
* The mental model is an extra layer of indirection, as these single-file components are themselves compiled into Javascript classes, but also contain Javascript classes in the script portion of the file.
* The tooling support was poor. For example, go-to-definition doesn't work on the HTML components, despite the fact that they're ultimately backed by Javascript classes.
* TypeScript does not check the HTML components.

I would have preferred to use a [JSX](https://www.typescriptlang.org/docs/handbook/jsx.html) solution, as it removes some of the indirection and has better tooling support.

I wish Vue had fewer ways to do things. For example, attributes on HTML elements can be set with the normal `=` syntax, but also with a leading `:` (expression evaluation) or a leading `@` (callback) for brevity. In comparison, React with JSX only has `=` for all of these situations.

### Vuetify

[Vuetify](https://vuetifyjs.com/) is a library to provide Material Design UI for Vue. The presence of a solid, all-in-one Material Design library was one other reason why I chose to use Vue. The library and documentation are both very good, and I was able to prototype my app (from a UI perspective) effectively. I would strongly recommend it if you're using Vue.

[I opened one pull request](https://github.com/vuetifyjs/vuetify/pull/8877) for the documentation, which was merged promptly, [and +1'd one documentation issue](https://github.com/vuetifyjs/vuetify/issues/10140), which has a workaround but unfortunately remains unresolved.

### Netlify for hosting

I used [Netlify](https://www.netlify.com/) to host the front-end of the website using its free tier, and stored data locally for the user. This worked well, as Netlify knew how to build and deploy my Vue project, and had good Github integrations.

Another option would have been Github Pages, which would have made the project dependent on fewer underlying services, but also would have required me to write a build step of my own.

### Custom database

I stored data locally on the client using the [`localStorage` APIs](https://developer.mozilla.org/docs/Web/API/Window/localStorage). I was careful to design the data schema such that it was append-only and such that each record had a unique ID, the idea being to make it easy to merge changes from multiple clients. However, this alone makes it difficult to delete records without some more thought.

I later discovered [CouchDB](https://couchdb.apache.org/) as a distributed document-store in exactly the manner I had already architected my application, but including sync and delete capabilities. I also discovered the [PouchDB](https://pouchdb.com/) library, which exposes a CouchDB interface and allows you to store your data locally or sync it remotely. It also supports more backends than just `localStorage`.

I wish I had used PouchDB from the beginning! Now I'm stuck with an inefficient, feature-lacking implementation of it, which would require some migration effort to move onto PouchDB.

### Github as a static data-store

I scraped a public service called [Elite GSP](https://www.elitegsp.com/) to accumulate historical ranking data (called "Global Smash Power" or GSP), so that the user could track their ranking progress over time compared to others.

To avoid having to host a database somewhere, I decided to check in the records directly into source control, which would then be distributed by Netlify. I set up a job on my personal webserver to do so. In the worst case, if the webserver goes down and stops updating the Git repository, the stale data would still be reasonably useful, and the job could be started again at any time. Currently, the job runs once a day.

I wish I had known that it were possible to commit to the repo in question using Github Actions, as described in the post [*Git scraping: track changes over time by scraping to a Git repository*](https://simonwillison.net/2020/Oct/9/git-scraping/). I definitely would have done so rather than rely on my own webserver's availability to do so.

All these automated commits caused the commit history to become rather polluted. I then made the choice to amend the most recent commit if it was a database-update commit, rather than make a new one.

This is rewriting public history and technically frowned upon, as it requires all downstream developers to rebase their changes onto master if the scraping job has run recently. But the rebases are typically conflict-free, as the rewritten commit only changes a machine-generated file, so this wasn't a problem in practice.

## Conclusions

The zero-hosting web-app is pretty feasible for local-first web applications. I imagine it would be harder if your app required users to be able to interact with each other, and therefore support authentication/authorization for data access.

Most of my friction was around attempting to describe things statically:

* Vue didn't have good support for TypeScript.
* A couple pieces of Vuetify documentation were missing important information.
* Using automated hooks to run deployment services instead of my own webserver is a much more convenient and declarative approach, in that I don't have to manage any machines myself.

User studies proved invaluable. Thanks to all my friends who participated.

This project was a success for me, because 1) I solved a problem I had; 2) I solved a problem that others had; and 3) I reduced my maintenance burden to the absolute minimum --- I haven't had any deployment issues since launching it.

{% include end_matter.md %}

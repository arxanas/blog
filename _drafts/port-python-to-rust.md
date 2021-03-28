---
layout: post
title: 'Incrementally porting a small Python project to Rust'
permalink: port-python-to-rust/
tags:
  - python
  - rust
  - software-engineering
---

I've been working on [git-branchless](https://github.com/arxanas/git-branchless), a Git workflow similar to the Mercurial workflows used at Google and Facebook. I originally wrote it in Python, but later ported it to Rust. This post details various aspects of the porting process.

{% aside About git-branchless %}
Here's the introduction to git-branchless, copied from the [project page on Github](https://github.com/arxanas/git-branchless):

---

### Demo

[See the demo at asciinema](https://asciinema.org/a/ZHdMDW9997wzctW1T7QsUFe9G):

[![asciicast](https://asciinema.org/a/ZHdMDW9997wzctW1T7QsUFe9G.svg)](https://asciinema.org/a/ZHdMDW9997wzctW1T7QsUFe9G)

### Why?

Most Git workflows involve heavy use of branches to track commit work that is underway. However, branches require that you "name" every commit you're interested in tracking. If you spend a lot of time doing any of the following:

  * Switching between work tasks.
  * Separating minor cleanups/refactorings into their own commits, for ease of
    reviewability.
  * Extensively rewriting local history before submitting code for review.
  * Performing speculative work which may not be ultimately committed.
  * Working on top of work that you or a collaborator produced, which is not
    yet checked in.
  * Losing track of `git stash`es you made previously.

Then the branchless workflow may be for you instead.

The branchless workflow is designed for use at monorepo-scale, where the repository has a single main branch that all commits are applied to. It's based off the Mercurial workflows at large companies such as Google and Facebook. You can use it for smaller repositories as well, as long as you have a single main branch.

The branchless workflow is perfectly compatible with local branches if you choose to use them — they're just not necessary anymore.
{% endaside %}

* toc
{:toc}

## Introduction

### Motivation

I successfully prototyped a working version of git-branchless using Python. The architecture of git-branchless is that it's a short-lived script which is invoked either interactively by the user or automatically by Git hooks.

Some Git operations, such as a rebase of a stack of several commits, this can result in many Git hook invocations, and therefore Python invocations. The Python interpreter takes tens or hundreds of milliseconds to start up, which degrades performance in the situation where we invoke it many times serially.

I considered adding some kind of long-running background daemon to the Python codebase, but I hate the amount of additional complexity and edge-cases associated with such an approach.

I decided to rewrite the project in Rust to address the startup time issue.

### Why Rust?

The amount of code in the project is still small enough that I could conceiveably rewrite it all in one go. But I figured it would take a long time to iron out all the bugs if I did it that way. I wanted the end result to be stable once I finished, rather than having to deal with occasional bugs as they came up, so I preferred to do an incremental approach and port the project one module at a time.

The requirements for my choice of language:

* Fast startup time.
* Bindings to SQLite, libgit2 (or equivalent), and some kind of [TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) library.
* Python interop.

There are a lot of languages which may meet these constraints. I chose Rust because I had some prior experience with it, and I liked the ML-style type system. The Python codebase was already written in an ML style, so it was largely a line-by-line port.

### Previous Rust experience

I used OCaml professionally for four years. Rust is descended from OCaml, so it's quite similar. During that time, my team was rewriting various components from OCaml into Rust for performance reasons. I personally wrote one of the  smaller modules, which was called from OCaml.

Since we were a team working on a programming language, we also happened to have had read a couple of papers on linear types, so the underlying theory guiding the borrow checker was familiar to me.

Essentially, I had as much Rust experience as one can have without actually having written any large amount of code in it. Overall, the language did not surprise me very much. A couple of points that did surprise me:

* I already knew about the `Deref` trait, which allows references to be automatically dereferenced (in the style of a smart pointer), but didn't know about the `Borrow` trait, which allows values to be borrowed as a different type. The exact relationship between `String` and `str` wasn't clear to me until then.
* The `'static` lifetime includes not only statically-allocated data, but also any owned data. Since the data is owned, the user of that data can ensure that it lives for any length of time. Realizing this made the lifetime annotations on closures make a lot more sense.

## Porting

TODO

## Results

### Language comparison

#### Rust vs Python

TODO

#### Rust vs OCaml

TODO

### Lines of code

TODO

### Time comparison

TODO

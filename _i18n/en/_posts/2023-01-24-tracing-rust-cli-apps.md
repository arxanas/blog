---
layout: post
title: Using `tracing` with Rust CLI applications
permalink: tracing-rust-cli-apps/
translations:
  pl: "/pl/śledzenie-aplikacji-rust-cli/"
tags:
  - rust
  - software-engineering
  - reprint
lobsters: https://lobste.rs/s/ox9je5/using_tracing_with_rust_cli_applications
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td>Rust users.</td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li><a href="https://github.com/arxanas/git-branchless/discussions/732">My post on GitHub</a>.</li>
        <li>My experience with Rust.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td>Informative.</td>
    </tr>
  </table>
</div>

[@epage](https://github.com/epage) in <https://github.com/arxanas/git-branchless/discussions/732> asked:

> I see talk of tracing but mostly from a web perspective and I'm curious how the experience translates to a CLI. I am looking to adopt it in some smaller CLIs to get some experience to understand how it could possibly help cargo.

I'm republishing my answer here, in [bullet point form][on-bullet-points].

  [on-bullet-points]: {% permalink on-bullet-points %}

{% include toc.md %}

## For Cargo

For Cargo, I would emphasize these points:

- It encourages doing the right thing via the structured logging macros. Extra computation isn't carried out if it wouldn't be used by a subscriber, which could otherwise cause a performance regression.
- Tracking spantraces for profiling is annoying, because you have to manually annotate each function that you want to sample. I'm not sure if this can be improved via using backtraces instead.
- You can easily output to a number of different subscribers, including custom ones (...if you know what functions to call). For example, `tracing_subscriber::fmt_layer::Layer::with_writer` will let you construct a layer which consumes formatted logging information and write it to somewhere arbitrary.
  - You can use off-the-shelf components, like the Chrome tracing subscriber.
- Somebody can configure it once and others don't have to worry about it much.
- It has been very effective for profiling for me.

## Full notes

- Using `eyre`/`color_eyre`, you can include function parameters in spantraces. This is quite valuable during debugging, since I can see e.g. a commit OID in the spantrace for a commit which is causing problems, without having to manually extract it by adding more logging.
- Configuring tracing for the first time is a pain, but you largely don't have to touch it after that.
  - Here's my function which does that: <https://github.com/arxanas/git-branchless/blob/4b76af669258e80a6f6eb4ddf45bbb358da80248/git-branchless/src/commands/mod.rs#L437>
  - I successfully configured logging statements to be printed via my own type (`Effects`), rather than being printed directly to stdout/stderr, because it may clobber progress meters or other interactive output.
  - I configured it so that subprocesses are not included in the parent trace; they get their own output files. To be honest, I don't think I've needed to examine subprocess tracing.
  - It used to be less ergonomic, but they improved things around the composition of layers at some point recently, like filtering one layer based on another layer; see <https://github.com/arxanas/git-branchless/commit/5428f1b9dbed356accf854774cad053c22d19b1f>
  - Some of the error messages for layer composition can be inscrutable because of the use of static polymorphism by default. For example, it's hard to conditionally construct a layer for inclusion. The types become very long chains of nested generic type parameters.
    - Fortunately, an `Option<Layer>` is also a `Layer`, so you can pass `Some(layer)` or `None` depending on your condition, rather than attempt to call methods on the registry directly.
- The `#[instrument]` macro is the only realistic way of including functions in spantraces for `eyre`/`color_eyre`.
  - This ruins autofixes (probably should be considered a bug in rust-analyzer).
  - This can ruin error locations, as sometimes the error is attributed to the function as a whole, instead of the specific line.
  - This can increase compilation times, since it's a procedural macro. As you might be aware, procedural macro stuff like `syn` tends to be on the critical path for crate compilation, but if you commit to not using procedural macros at all, then you can skip it.
- Profiling via dumping to the Chrome tracing layer is effective.
  - See <https://github.com/arxanas/git-branchless/wiki/Runbook#profiling> for details on profiling procedures.
  - I've used this system to debug performance issues/regressions a number of times. The existing Chrome tracing visualizers are quite usable for analyzing the breakdown of time spent.
  - Including function parameters has been amazingly useful, because I've been able to directly see a slice in the profiling output which was taking too long and check the corresponding commit OID, so that I could examine and test that specific commit.
- I tried to use `tracing` as an input to my own progress-reporting system (so that function calls are directly tied to progress bars which appear on the screen). It was possible, but, in the end, I gave up on this approach, because logical operations didn't correspond exactly one-to-one with function calls, and it was too easy to forget to annotate an instrumented method correctly.
- Haven't tried `tracing` with `async`/`.await` at all.
- Haven't tried <https://github.com/tokio-rs/console> at all, but I would be interested to know if it's useful for you.
- Structured logging is great.
  - Just using the structured logging macros with debugging representations (i.e. `warn(?var, "Message")`) is substantially more ergonomic than interpolating values into strings manually.
  - It also handles things like rendering unprintable characters, where before I would have to be careful to include string values in quotes., etc.
  - In principle, you can see these events and their values in the profiling output, although I haven't needed to profile based on individual events, only based on spans.
  - It's more efficient, since we won't construct the strings if the values are not consumed by any subscriber at runtime.
- There's a weird incompatibility between the `tracing_subscriber` version used by my code and by `color_eyre`, which means that I've locked it at a known-good version here: <https://github.com/arxanas/git-branchless/pull/533/commits/e97954a9a9fab4039ad269d6b8982bb8bd95b133>.
  - In principle, I think `color_eyre` just needs to upgrade their version of `tracing-subscriber`, but I haven't looked into it since then.

{% include end_matter.md %}

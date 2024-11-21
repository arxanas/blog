---
layout: post
title: "Improving incremental test times in Rust"
permalink: rust-incremental-test-times/
translations:
  pl: "/pl/rust-przyrostowe-czasy-testowania/"
tags:
  - rust
  - software-engineering
lobsters: https://lobste.rs/s/ktyp2q/improving_incremental_test_times_rust
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Prospective-to-intermediate Rust developers who worry about slow compilation times, the scale thereof, and preventative practices.</li>
        <li>Advanced Rust developers who can help me improve my own compilation times.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td>My experience with Rust.</td>
    </tr>
    <tr>
      <td>Mood</td>
      <td>Somewhat successful; somewhat disappointed.</td>
    </tr>
  </table>
</div>

Rust is known for slow compilation times. I spent a long time trying to improve incremental test build times for my project [git-branchless](https://github.com/arxanas/git-branchless) in [https://github.com/arxanas/git-branchless/pull/650](https://github.com/arxanas/git-branchless/pull/650). This is a discussion of the results.

{% include toc.md %}

## Executive summary



* Incremental testing refers only to changing the _integration test code_ and rebuilding. The source code remains unchanged.
* In the end, I was able to reduce incremental test time from ~6.9sec to ~1.7sec (~4x). Other techniques to improve compilation time produced marginal or no improvements.

For your reference, here’s the best articles for conceptual understanding of the Rust build model and improving compilation time:



* [Fast Rust Builds](https://matklad.github.io/2021/09/04/fast-rust-builds.html) ([matklad.github.io](https://matklad.github.io), 2021)
* [How to Test](https://matklad.github.io/2021/05/31/how-to-test.html) ([matklad.github.io](https://matklad.github.io), 2021)
* [Why is my Rust build so slow?](https://fasterthanli.me/articles/why-is-my-rust-build-so-slow) ([fasterthanli.me](https://fasterthanli.me/), 2021)
* [Tips for Faster Rust Builds](https://endler.dev/2020/rust-compile-times/) ([endler.dev](https://endler.dev), 2020-2022)
    * Actually, I didn’t review this article at the time, but I did at the time of this writing.


## Project details

Here’s how big my project [git-branchless](https://github.com/arxanas/git-branchless) was before the pull request:



* `git-branchless/src`: 12060 lines.
* `git-branchless/tests`: 12897 lines.
    * Note that it relies heavily on snapshot testing, so most of these lines of code are multiline string literals.
* `git-branchless-lib/src`: 12406 lines.

It’s permissible that compilation and linking time should be slow, but in order to optimize my development feedback loop, I need test times to be fast. Specifically, I want to be able to iterate on the development of a single certain test. (IntelliJ has a nice feature to automatically re-run a given test when there are source changes, but the utility is diminished when it takes too long to recompile the test.)

To start, building the `test_amend` binary (which tests the `amend` subcommand) after a single comment addition to the test file itself (no library changes!) takes ~6.9sec:

```bash
$ hyperfine --warmup 3 --prepare 'echo "// @nocommit test" >>git-branchless/tests/command/test_amend.rs' 'cargo test --test mod --no-run'   
Benchmark 1: cargo test --test mod --no-run
  Time (mean ± σ):      6.927 s ±  0.123 s    [User: 7.652 s, System: 1.738 s]
  Range (min … max):    6.754 s …  7.161 s    10 runs
```

Staggering! This is not a large project, and we’re only making changes to the _tests_, so it shouldn’t require so much iteration time.


## Splitting into more crates

[In the pull request](https://github.com/arxanas/git-branchless/pull/650), I extract code into an additional nine crates, resulting in an incremental test build time of ~1.7sec (~4x improvement):

```bash
$ hyperfine --warmup 3 --prepare 'echo "// @nocommit test" >>git-branchless/tests/test_amend.rs' 'cargo test --test test_amend --no-run'   
Benchmark 1: cargo test --test test_amend --no-run
  Time (mean ± σ):      1.771 s ±  0.012 s    [User: 1.471 s, System: 0.330 s]
  Range (min … max):    1.750 s …  1.793 s    10 runs
```

In relative terms, this is a significant improvement, but in absolute terms, this is rather poor, in my opinion. I would expect 100-200ms to parse, expand macros, typecheck, and generate code (with no optimizations) for a file of this size (~1k lines, mostly long string values).

Furthermore, splitting into multiple crates makes it harder to distribute my project via [`crates.io`](https://crates.io/):



* Each crate must individually be published to `crates.io` (you cannot publish a crate with `git` dependencies to `crates.io`)
    * So I have to manage versioning and licensing of each crate.
* According to my user survey, the majority of my users install via `cargo`. For the question “How did you install git-branchless?”, the responses are as follows (as of 2023-02-07):
    * 7/18 (38.9%): via `cargo install git-branchless`
    * 4/18 (22.2%): via traditional system package manager
    * 4/18 (22.2%): via Nix or NixOS
    * 2/18 (11.1%): via cloning the repository and manually building and installing
    * 1/18 (5.6%): via GitHub Actions build artifact

It’s unfortunate that I have to expose internal modules publicly on `crates.io` just to get reasonable compilation times.


## No-op timing

At this point, I measure the no-op time to be ~350ms for a smaller test crate with few dependencies:

```bash
$ hyperfine --warmup 3 'cargo test -p git-branchless-test --no-run'      	 
Benchmark 1: cargo test -p git-branchless-test --no-run
  Time (mean ± σ): 	344.2 ms ±   3.5 ms	[User: 246.2 ms, System: 91.9 ms]
  Range (min … max):   340.4 ms … 351.0 ms	10 runs
 ```

This is surprising. I would expect the overhead for a no-op build to be similar to `git status`, maybe 15ms:

```bash
$ hyperfine --warmup 3 'git status'
Benchmark 1: git status
  Time (mean ± σ):  	13.5 ms ±   2.5 ms	[User: 4.9 ms, System: 6.1 ms]
  Range (min … max):	11.1 ms …  24.7 ms	197 runs
```

There might be some kind of deeper issue here. [The `cargo nextest` documentation](https://nexte.st/book/antivirus-gatekeeper.html) warns that some anti-malware systems can introduce artificial startup latency when checking executables:

> A typical sign of this happening is even the simplest of tests in cargo nextest run taking more than 0.2 seconds.

As per the documentation, I marked my terminal software as “Developer Tools” under macOS, but couldn’t reduce the no-op compilation time.


## No more profiling?

I tried with a subcommand crate that I made recently which should still have few dependencies:

```bash
$ hyperfine --warmup 3 --prepare 'echo "// @nocommit test" >>git-branchless-test/tests/test_test.rs' 'cargo test -p git-branchless-test --no-run'
Benchmark 1: cargo test -p git-branchless-test --no-run
  Time (mean ± σ):  	1.855 s ±  0.034 s	[User: 1.476 s, System: 0.335 s]
  Range (min … max):	1.831 s …  1.939 s	10 runs
```

The cargo build timings for the incremental build doesn’t help. It just shows that the test I’m building takes 100% of the spent time.

{% image cargo-timings-git-branchless-test-crate.png "The timing graph for building the `git-branchless-test` crate." %}

## No more ideas?

Some ideas that didn’t work:



* Combining integration tests into a single binary. (I’m happy to run individual binaries as necessary, anyways.)
* Reducing the top monomorphization sites them (`AsRef` calls, etc. appeared in `cargo llvm-lines`, but reducing them didn’t seem to improve compilation times).
* Using [`sccache`](https://github.com/mozilla/sccache).
* Using [`cargo-nextest`](https://nexte.st/).
* Using [`zld`](https://github.com/michaeleisel/zld)/[`mold`](https://github.com/rui314/mold)/[`sold`](https://github.com/bluewhalesystems/sold) as the linker.
* Setting `profile.dev.split-debuginfo = “unpacked”` (for macOS).
* Setting `profile.dev.build-override.opt-level = 3`.
  * Unfortunately, there are lots of procedural macros, particularly [`tracing`](https://docs.rs/tracing/latest/tracing/)’s `#[instrument]`.
* Setting `profile.dev.debug = 0`. This actually does save ~20ms, but it’s not enough of an improvement by itself.

So now I’m stuck. That’s the most I can improve Rust incremental test times. Let me know if you have any other ideas.

{% include end_matter.md %}

---
layout: post
title: "Datalog DSL detects defective dependency declarations, defanging dodgy development discipline"
permalink: what-if-sql-were-good/
tags:
  - bazel
  - build-systems
  - programming-languages
  - reprint
  - rust
  - software-engineering
  - software-verification
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Software engineers interested in logic programming or static analysis, and actually using it in production.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Originally presented at <a href="https://groups.io/g/Seattle-Build-Enthusiasts/topic/115859647">Seattle Build Enthusiasts Meetup (Autumn 2025)</a></li>
        <li>Frustration at work due to not having a hermetic build system.</li>
        <li>Prior experience with static analysis techniques.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td><ul>
        <li>Excited to share a useful tool with like-minded colleagues.</li>
      </ul></td>
    </tr>
  </table>
</div>

{% include toc.md %}

## Slides

This talk was given at the [Seattle Build Enthusiasts Autumn meetup](https://groups.io/g/Seattle-Build-Enthusiasts/topic/115859647) (<time datetime="2025-10-30">2025-10-30</time>).

{% noteblock %}
<span class="note-tag">Main goal:</span> Show some use-cases where Datalog shines, and try to convince the audience to use it.
{% endnoteblock %}

Resources:

- [Direct Google Slides link](https://docs.google.com/presentation/d/17LmyLkBt_RtLBhKpOY7IFoun9V2rRIsJTD4fXleagBc/edit?usp=sharing)
- [Ascent homepage](https://s-arash.github.io/ascent/)
- I've included rough speaker notes below, and also transcribed a few of the interesting Ascent code snippets directly inline.

<div class="iframe-container">
<iframe src="https://docs.google.com/presentation/d/e/2PACX-1vRNY7x7D2H0WO_3eKszgJtmj6_2I4Dx6ZvMtJabSb81DKLLCNrWvqi2DLtq0N6aB1PpqtFkqYtQYoX3/pubembed?start=false&loop=false&delayms=3000" frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
</div>

## Speaker notes

(1) Hi everyone, my name is Waleed Khan. I work at my company not on the Bazel team. Therefore, I'm going to show you how not to migrate Bazel.

Instead, I'm going to try to sell you on a cool tool, which is a library for Datalog, to rapidly build certain kinds of analyses, especially graph-oriented ones. And I'll show you how I used it in our repository to statically detect entire classes of misconfigured CI jobs, and fix them before they broke the build.

The context for this is that, recently, we had a "Quality Week" at work. I took the initiative to enable a few rules for ESLint in our monorepo. (If you're not familiar, ESLint is a linter for JavaScript and Typescript).

I just turned on the rules in the global config file, opened a pull request, and saw a bunch of new lint violations in CI, as expected. Then I either fixed or suppressed each of them, got CI green, and finally committed my change.

Naturally, this immediately broke a bunch of builds. That's because our CI tries to run only relevant jobs, and, in this case, it was wrong about which ones were "relevant".

(2) How could this possibly happen? Well, here's what our CI job definitions look like. There's a set of globs that match changed files, and they trigger the corresponding build and test commands.

As Build System Enthusiasts, you'll probably spot two problems here.

The first one is that this is a hellish custom YAML-based configuration language, which is its own entirely separate issue.

The second is that there is no guarantee that this set of globs is necessary or sufficient to trigger the associated command. Notably, if my/package has a dependency on some other directory in the codebase, then changes to that code won't automatically cause this job to trigger.

(3) So what can we do about it?

The best option is probably to use a hermetic build system like Bazel. Then this kind of stuff just can't happen.

And I specifically asked Dan if he could please spend a week or two on it, and just quickly migrate the entire codebase to Bazel, but I guess he's busy with something else, because it kind of looks like the codebase has not yet been migrated to Bazel? I'm sure he'll get around to it.

So what can I do in the meantime to kind of stop the bleeding, as a kind of band-aid solution?
 
Well, If we look back at this job definition, we could probably make a guess about the necessary dependencies here. Like, if the script is called "lint", then it probably depends on linting configuration files.

And you know what's really good at making unsubstantiated guesses? That's right. AI. But I didn't want to wade through a bunch of noisy, non-deterministic AI output to flag the real issues.

So, instead, I turned to a different approach, which is: AI. By which I mean "abstract interpretation". We'll discuss exactly what that means, but it's basically a form of static analysis.

(4) Diagram: <https://excalidraw.com/#json=DVyPsfKEa1RYdy62i5DW9,dVPy7Cm8QLVeEyaUcNuCwQ>

So I wrote a static analysis tool using Datalog, and I'll just show you an example of an actual trace that the tool managed to produce.

In this case, the CI job calls the npm script called "test" inside the my/package directory. And if we look at the package.json file in that directory, we can see that "test" is defined to call some tools.

But, misleadingly, it's not just running tests. It's also calling "npm run lint". And if we go look at the "lint" script, then we see, "oh, it's calling eslint in this directory".

Now I know from the documentation that eslint always looks for configuration files named in certain patterns. And if we look for the associated configuration file, we can follow the imports and see that it extends from a different configuration file.

And that configuration file is not matched by the job's globs. Notably, it's not even the configuration file in the root of the monorepo, and I don't even know why that was the case, but it is what it is.

The point is that, by a series of simple logical steps, we can automatically conclude that the globs must be missing a pattern to match this parent configuration file.

(5) So I looked at this and asked myself, "how can I quickly prototype a cross-language analysis that can detect these kinds of issues?" I decided to use Datalog for this.

Has anyone used Datalog or Prolog before?

Datalog is basically like: what if SQL didn't suck? Datalog uses the relation model, like SQL. But it's much better than SQL, and many standard programming languages, at expressing specific kinds of problems.

For example, this is how you express transitive closure in Datalog. There's two "relations", which are kinds of "facts" that the Datalog engine infers as it runs. In this case, we're provided a "ground" set of "edges". And we infer that a node is reachable from another node via some sequence of edges when either:
as the base case, there's a direct edge between them,
or, as the recursive case, if there's a transitive sequence of edges between them. That is, if x can reach y, and y is a neighbor of z, then x can reach z.

The syntax is a little backwards because the conclusion comes before the premises, but you get used to it.

You can see that the SQL version of this is pretty awful to write in comparison.

(6) So what kinds of things is Datalog good at? I have a few things listed here.

Recursive algorithms. That also includes situations where there might be "non-determinism", in the sense that the algorithm might choose one of many possible futures. Datalog engines can also parallelize this stuff pretty easily.
Graph analysis, including dependency graphs and transitive closures.
Static analysis, including control flow and data flow analysis.
"Rules" engines. When you want to express a bunch of "rules" succinctly and declaratively, and not focus so much on the implementation. Datalog is especially good if you find yourself needing to have multi-directional indexes or "joins", or if you have rules from several domains that you want to combine, which is what my analysis did.

(7) I would typically not want to use a domain-specific language unless it granted me an order of magnitude more expressiveness. But Datalog delivers. Here's an example from a blog post that one of my colleagues wrote, where he was working on some compiler analyses, and I challenged him to write it in Datalog instead.

So we did, and you can see the result here; the stuff on the left translates to two statements of Datalog. And, actually, that was the cleaned up version, because, originally, we only had one statement that we later broke into two statements for readability.

(8) So how do we actually use Datalog? I used a library called "Ascent", which is a Datalog DSL for Rust. The fact that the tool is just a library is pretty important because it means that you don't have to introduce some weird academic binary into your toolchain.

It's also important because you can still just drop into Rust for various things. Like if you want to just use a Vec or a HashMap, you don't have to fight with the language to get things done.

You can also use this library to compile to WASM, which is useful if you need to deploy it to other platforms.

(9) Here's an excerpt from the original paper, where they implement the core of the Rust borrow checker in 46 lines of code. I, personally, couldn't describe the Rust borrow checker in 46 lines of prose.

(10) So here's a full example. You can see that we populate the initial "edges" relation with this expression using the "edges" parameter. The ascent_run macro will then run the program and return all of the relations, and we just access the "reachable" relation and convert it into a sorted set and return it.

(11) So, given these edges, the output would look like this. We can see that there's an entry for (0, 3) because it's reachable by visiting all the edges.

(12) Another great feature is that you can parallelize your analysis pretty easily by just adding "par" to your invocation. When you structure your analysis as a Datalog program, it also becomes pretty easy to parallelize it.


(13) Here's a simple example which finds any local development services that run Bazel binaries, but which aren't tested in CI. The "tdep" here stands for "transitive dependency.

Code listing:

```rust
// Check: Bazel targets referenced by services that aren't tested in CI.
relation service_untested_target(String, BazelLabel);
service_untested_target(service, label) <--
    dep(?Node::Service { name: service }, ?target @ Node::BazelTarget { label }),
    !is_ci_job_tdep(target);
```

(14) GitHub issue: https://github.com/bazelbuild/bazel/issues/27496

It turns out that, when using `bzlmod`, there's no way to determine that a `go_library` target depends on the repo's `go.mod`. In that case, we can argument the dependency graph to add this dependency. Note that we're modifying the existing `dep` relation to add new inferred dependencies.

Code listing:

```rust
// Rule: All `go_*` targets depend on `go.mod`. (Actually, there should be
// more dependencies; I don't see how to query the bzlmod graph for them, so
// just hardcode this rule for now.)
dep(target, Node::BazelSourceFile { path: PathBuf::from("go.mod") }) <--
    bazel_target_is_kind(?target @ Node::BazelTarget { label }, kind),
    if kind.starts_with("go_");
```

(15) (remark on how we can express the semantics of Bazel ellipsis (`/...`) in just two fairly-straightforward rules: one to pretend that `...` is a target that depends on its siblings, and one to pretend that subpackages are a type of target)

Code listing:

```rust
// Rule: Bazel label '//pkg:...' depends on all sibling '//pkg: target's.
// Note that sibling subpackages are represented as sibling targets, so this
// recursively includes all subpackage targets.
dep (
    Node::BazelTarget(repo.clone(), package.clone(), "...".to_string()),
    Node::BazelTarget(repo.clone(), package.clone(), target.clone()),
<——
    dep(?Node::BazelTarget(repo, package, target), _),
    if label.target != "...";
```

```rust
// Rule: For every package (represented as a target named '//:pkg of
// made-up type 'package), create a synthetic target named '//pkg:...'.
dep (
  Node::BazelTarget (repo.clone(), package.clone(), subpackage.clone()),
  Node::BazelTarget (repo.clone(), format! ("{package}/{subpackage}"), "...".to_string()),
) <--
    dep(
        ?Node::BazelTarget(repo, package, subpackage),
        Node::BazelTargetKind("package". to_string()),
    );
```

(16) So getting into the meat of it, here's an actual rule. This detects the general case of "CI jobs that call Bazel somewhere, but whose globs don't include all of the Bazel dependencies".

It's a lattice instead of a relation for technical reasons. In this case, it helps us produce the shortest trace, instead of all traces.

- So, if we inferred any transitive dependency path between a CI job, and a file that we know is a source file for a Bazel target, via this trace,
- and if we successfully processed that CI job, because I didn't implement everything, so I just left some of them as "unimplemented",
- and if we look up the globs for this CI job, and none of them match that source file's path,
- then we fetch the glob matcher object, which basically just contains the list of globs so that I can present it to the user later,
- and we fetch the source file that defines the CI job, which is expressed as a dependency too, because that information was actually resolved in another rule,
- then we record the result for this job and source file pair (and you can ignore the fact that I store both the node and the path here, that was just for convenience).

Code listing:

```rust
lattice bazel_glob_miss(String, Node, PathBuf, ascent::Dual<GlobMiss>);
bazel_glob_miss(job, node.clone(), path.clone(), ascent::Dual(glob_miss)) <--
    ci_tdep(
        ?ci_job @ Node::CiJob { job },
        ?node @ Node::BazelSourceFile { path },
        ?ascent::Dual(trace),
    ),
    !ci_job_has_error(job),
    !ci_job_glob_matches_path(ci_job.clone(), path.clone()),
    ci_job_glob_matcher(ci_job.clone(), glob_matcher),
    dep(ci_job, ?Node::SourcePath { path: source }),
    let glob_miss = GlobMiss {
        job: job.clone(),
        source: source.clone(),
        path: path.clone(),
        trace: trace.clone(),
        glob_matcher: Arc::clone(glob_matcher),
    };
```

(17) (remark that "facts" are just a big enum which I serialize/deserialize with `serde`)

(18) (explain how I just dumped the Bazel dependency graph into a list of "facts")

(19) (show how we can handle these 9 data sources in the same system and track cross-language control-/data-flow; remark that `strace` is different from all the rest, since it's dynamic instrumentation, but it works compositionally anyways)

(20) Diagram: <https://excalidraw.com/#json=DVyPsfKEa1RYdy62i5DW9,dVPy7Cm8QLVeEyaUcNuCwQ>

(remark on how the original trace crossed between YAML, shell, package.json, and Javascript languages compositionally)

(21) (brief explanation of abstract interpretation)

(22) (explanation of simple shell abstract interpretation:

- simple abstract interpretation: split on statement separators and pretend all commands run in sequence; not correct, but works in practice
- track calls to cd and set internal state
- track calls to bazel, npm, etc.

)

(23) (snippet of CESK machine from the Ascent paper, and remark that you can basically copy the rules, Greek letters and all)

(24) (links to resources)

{% include end_matter.md %}

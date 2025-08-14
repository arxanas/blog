---
layout: post
title: "Searching source control graphs"
permalink: searching-source-control-graphs/
tags:
  - build-systems
  - git
  - reprint
  - software-engineering
  - software-verification
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Build system developers and enthusiasts</li>
        <li>Source control developers and enthusiasts</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Attempts to generalize the library behind <a href="https://github.com/arxanas/git-branchless/wiki/Command:-git-test"><code>git test</code></a></li>
        <li>Originally presented at <a href="https://groups.io/g/Seattle-Build-Enthusiasts/message/12">Seattle Build Enthusiasts Meetup (Summer 2025)</a></li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td><ul>
        <li>Instructive</li>
        <li>Enlightened</li>
      </ul></td>
    </tr>
  </table>
</div>

{% include toc.md %}

## Slides

This talk was given at the [Seattle Build Enthusiasts Summer 2025 meetup](https://groups.io/g/Seattle-Build-Enthusiasts/message/12) (<time datetime="2025-07-22">2025-07-22</time>).

{% noteblock %}
<span class="note-tag">In essence:</span> The main idea is implementing parallelizable "generalized binary search" via a structure similar to a comonad, although the talk is not presented that way.
{% endnoteblock %}

Resources:

- Deleted slides with extra information are available at the end.
- [Direct Google Slides link](https://docs.google.com/presentation/d/1RRm-H8PwgSLaY5ng1YL2_DmtIPiI41P-SJTL_CKTO3o/edit?usp=sharing)
- [Documentation for `git test`](https://github.com/arxanas/git-branchless/wiki/Command:-git-test)
- The alluded-to library is [`scm-bisect`](https://crates.io/crates/scm-bisect),
  - but it's not production-ready,
  - and needs to be updated with e.g. my work on minimization.

<div class="iframe-container">
<!-- <iframe src="https://docs.google.com/presentation/d/e/2PACX-1vRSwp0EbldxIkD72bzEoKDHzLzah95w2ABa1doSwqeKTMneSz1_O1DqNNb7qJCi4xXbPdp1A7Blk5PV/embed?start=false&loop=false&delayms=3000" frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe> -->
<iframe src="https://docs.google.com/presentation/d/e/2PACX-1vRzfn2qPvsjZ9gWMHsM7ERN540r-5VPbDsVi4Q4u0CXDY-5wzt9ha3J5927bMOmiflUfoO_sIjccMFj/pubembed?start=false&loop=false&delayms=3000" frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
</div>

## Speaker notes

There are some speaker notes in Google Slides. They didn't correspond to what I actually said.

(1–2) Hi, everyone. My name is Waleed Khan. I'm going to be talking about something that I do every day at work, which is:

(3) Writing buggy code.

(3) I love it. Can't get enough of it, and the great thing is, since the last time I was here, my ability to churn out buggy code has increased by an order of magnitude, thanks to the power of AI.

(4) So, naturally, I use git bisect a lot. For those of you who aren't familiar: git bisect is a command that lets you basically binary search for the commit that introduced a certain bug.

(4) Show of hands: how many of you have used git bisect (or equivalent) before?

(4) And have any of you used the 'automatic' mode of git bisect run, where you pass a command, and it runs the entire bisection automatically?

(5) I love git bisect because we practice trunk-based development at work, so I have these massive stacks of commits that I'm constantly running tests on. But I had to make it faster.

(6) So I made a tool called git test, which is, confusingly, inspired by Spotify's tool of the same name. It's like git bisect, but way cooler. Let's take a look.

(7) It's hard to see, but I'm running git test run with cargo fmt to check the codebase formatting, with 8 jobs, and using binary search.

- It's running on 46 commits, and it flags 3 failing commits.

- It concludes that the formatting was broken by this buggy commit I inserted into the middle of the stack.

- It also checked three different branches, shown here.

(8) So I kept wanting to add more features. And I realized a few things.

- Firstly: I've invented my own mini-continuous-integration system.
- Secondly: Those features look different, but are actually instances of the same problem.
- Thirdly: I would really love it if my work's CI had those features.

(9) How many of you have at least one system in your organization that can automatically bisect build breakages, test failures, or anything else?

(9) Now here's some slightly different questions.

(9) How many of you have a "merge queue" system to run your continuous integration system on a "pipeline" of commits?

(9) And does anyone have a system that automatically detects and triages flaky tests?

(9) And how about for performance regressions?

(9) Today, I'm going to talk about how to design a library for generalized binary search. My hope is that you can sprinkle some careful abstractions into your CI system and add support for like 400% more new and substantially different workflows with maybe 50% more effort.

(10) The basic idea behind git bisect, and the search problems we'll see, is the "monotonic assumption".

(11) Formally, it preserves some ordering relation when you apply a predicate. If element X has a certain property, and element Y comes after X, then Y also has that property.

(11) In practice, this is often true. Thinking of commits, once you commit a bug, it's usually present in subsequent commits, at least until it's fixed. So our commit graphs are monotonic with respect to the property of whether a commit has a certain bug.

(11) And the point of this is basically that you can stop your search early. Binary search relies on this in order to guarantee that it finds the first element with a certain property.

(12) I have invented a convenient mnemonic to help you remember this: "Once you begin to fail your predicate, to later pass would be poor etiquette."

(13–20) (missing: list/discussion of search, minimization, noisy search, and optimization problems that occur in practice)

(21) When I was in elementary school, I learned binary search as "that thing you do in the phone book".

(22) When I got to college, I learned that binary search is an algorithm operating over a sorted array with worst-case logarithmic time complexity.

(23) After I started working, I learned that binary search is an algorithm operating on monotone predicates over a lattice structure.

(24) Now that I'm older and wiser, I realize that I was overcomplicating things. Binary search is really as simple as 1-2-3!

(25) It's just the problem of "determining a one-dimensional binary-valued threshold function from a finite class of such functions based on queries taking the form of point samples of the function", what's the problem?

(26) Have any of you read Build Systems a la Carte?

(26) It's a paper that tries to break down various build systems into a bunch of orthogonal axes, then recombine them to create a new build system with various properties.

(26) That's what I'm going to try to do here. We'll break down binary search into a bunch of components, and recombine them to solve different problems.

(26) I'm not guaranteeing that this is the perfect design — but hopefully you'll be able to adapt it to fit your needs.

(27) As an exercise, let's start by trying to generalize linear search and binary search and abstract out the common details.

(27) So here's linear search.

(27) And here's binary search.

(28) (missing: abstracted search algorithm)

(29) Does anyone know how Git selects the next commit to test in this case?

(29) For each commit in the search range, it computes the number of ancestor and non-ancestor commits in that range. It takes the absolute value of the difference, and picks the minimal such commit. That way, it maximizes the information gained in the worst case, just like traditional binary search.

(29) Actually, Git makes the assumption that there's exactly one buggy commit in the range. If you don't make that assumption, then it's technically better to compute the number of ancestors minus descendants. But it's approximately the same.

(30–31) (missing: generalizing bounds to multiple nodes)

(32) Now, in practice, not every test returns true or false. Sometimes, maybe there's a compilation error in the codebase, and you can't run the test at all. In those cases, we want to include an "indeterminate" result.

(33) For linear search, I think it's pretty clear how to continue searching when you get an indeterminate result. You just skip over that index and continue.

(33) But what do we do for binary search? Does anyone know what Git does?

(33) One reasonable approach is to just remove the commit from the range and pretend it doesn't exist. The main problem is this heuristic: we'd probably select the parent or child of that commit instead. But there's a good chance that the build is also broken for that commit. So ideally, we'd pick a commit that's a little farther away, to maximize the chance that we find a testable commit.

(33) So Git just does the simple and obvious thing here. Which is...

(34) ...it generates a pseudorandom number biased according to the square root of the size of the range and uses that offset to select the next commit. Perfectly sane and reasonable, right?

(34) I hope this isn't contentious, but I'd prefer my search algorithm to be deterministic. We'll come back to this point with a better solution.

(35) Now, if we wanted to run a bisection system in production, we'd have to scale it up. So, any ideas: how can we run binary search in parallel?

(35) One approach is, at each step, instead of bisection to split the search range into two chunks of approximately equal size, instead we could do n-section to split it into n chunks.

(35) Does anyone see any downsides to this approach?

(35) One problem is that it's not adaptive. You want to respond to results immediately as you get them; you don't want to have to wait for all workers to complete. And the amount of parallelism available to you at runtime might fluctuate.

(36) Let's look at an example:

(36) If we start testing three commits in parallel, and we learn that the first one failed...

(37) ...then we want to cancel the other two and start working on the search range to the left of the first one, as soon as any parallelism becomes available.

(38) On the other hand, if the first commit passes, then the new n-section boundaries don't necessarily overlap with the old ones. If there's a lot of build overhead to start testing a new commit, then we don't want to cancel the pending workers and throw away their work, because it's still useful information, and they're probably almost done at this point. But we might still want to direct our newly-freed worker to start testing another commit, anyways, so which commit would we pick in that case?

(38) And the other problem is just an engineering problem. The implementation for parallel linear search on a directed acyclic graph is non-trivial, and we'd have to implement it separately from binary search. And we're actually going to see a bunch of other search procedures in this talk, and it would be painful to have to parallelize each of them individually.

(38) And like I told you, my typical workday looks like this: I head into work, I bang out an incorrect implementation of binary search, and I call it good and then I head home.

(38) It's a miracle I passed the coding interview.

(38) And it's not just me. You might have heard that the first published implementations of binary search were wrong for several years, due to unhandled overflow issues. Nobody can write correct code, especially not correct concurrent code, so let's minimize the surface area here and do this *once*.

(39) So what's the trick? Speculation. We're going to write our code using primitive for non-determinism, and speculate on multiple possible futures at once.

(39) We're going to distinguish two things:

* The Traversal strategy,
* and the Search algorithm

(39) and we're going to put all the speculation logic into the Search in such a way that it's independent of the Traversal.

(39) Here's the idea: whenever the Traversal would have us test a certain commit, we're going to speculate on both the Pass and Fail outcomes, and figure out what we would test next in each future. [slide: speculation tree for binary search]

(39) To parallelize this, all we have to do is take the first n nodes in this speculation tree and start testing them in parallel.

(39) And what's cool is that, for binary search, this reduces to recursive bisection instead of n-section, which, for powers of two, is equivalent, and for other values, it's still asymptotically O(log(n)).

(39) And for linear search, this ends up speculating the first n nodes in the range, because the Fail outcomes will terminate the speculation tree immediately, and the Pass outcomes will continue.

(40) The search returns a lazy sequence corresponding to the speculation tree. Internally, it'll clone the traversal object and speculate on the pass-fail outcomes to produce nodes deeper in the tree.

(41) Each instance of this traversal represents a node in the speculation tree. The speculative search notifies the traversal about a test result, and it updates its internal state, and prunes any unnecessary search nodes and so on, and it returns the updated Bounds for the benefit of the caller.

(41) Then the search queries the "midpoints" of the remaining range. For linear search, those are the next nodes in a breadth-first search in the DAG. For binary search, we compute the ancestor depth to select the midpoints.

(41) Any questions so far? This is one of the main abstractions.

(42) Thinking back to the question of indeterminate commits, we also get a solution for free. Whenever the traversal returns a node that was previously marked as indeterminate, then we can just speculate both pass and fail cases.

(42) For linear search, this again just does the right thing and "skips over" the indeterminate nodes.

(42) And for binary search, we get the ability to select an asymptotically-optimal commit that's far away from the broken commit, but in a fully deterministic manner. So I think that's pretty elegant.

(43) Why is it so elegant? Well, let's look back at the traversal interface. You can duplicate instances of this type; you can extract the current search nodes from the instance; and you can extend the instance into the future by speculating on the search node outcomes...

(43) Eh? I know what you're thinking. "Wow, that sounds a lot like a comonad!"

(43) Okay, not really, and if any of you were thinking that, then I don't know if any search algorithm can find relief for your tortured soul.

(44) (missing; re merge queueing)

(45) You can consider normal bisection to be a special case where you can only select sets of adjacent nodes in the graph.

(45) The idea here is to lift the graph such that it operates on combinations of commits, extracted and applied independently, instead of individual commits with all of their ancestors.

(45) Formally speaking, we want to operate over the power set of the search range, which is the set of all subsets of the search range.

(45) The great thing is: the power set naturally forms a directed acyclic graph, where there's an edge between a parent and a child when the parent is a strict subset of the child. And we just described a scheme to do fancy search on DAGs.

(45) Easy, right?

(46) Okay, so what's the problem with running the search on this graph?

(46) Normal source control graphs are pretty linear, and have relatively low branching factor. But this graph is maximally dense, with a high branching factor — and it contains an exponential number of nodes.

(46) How do we resolve that?

* Avoid materializing entire graph
* Make assumptions about search space
* Accept a local minimum

(47) (missing: discussion of how to implement conflict analyzer and weighted probabilistic speculation in the same system)

(48–50) (missing: discussion of implementing "delta-debugging" in the same system)

(51) (missing: discussion of minimizing order-sensitive failures)

(52) (missing: discussion of "flake-aware culprit finding"; discussion of weighted-median approach to running multiple tests on the same graph)

(53–55) (missing: going from "generalized binary search" to "noisy generalized binary search" via Bayesian inference)

(56–60) (missing: numerically-incorrect example of updating posterior probabilities, which needs to be fixed)

(61–63) (missing: conclusion and remark on AI-accelerated development increasing the need for clever search systems)

(64–78) (deleted slides with various bullet points)

{% include end_matter.md %}

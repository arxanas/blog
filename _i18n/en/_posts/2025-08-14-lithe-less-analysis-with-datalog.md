---
layout: post
title: "Lithe, less analysis with Datalog"
permalink: lithe-less-analysis-with-datalog/
tags:
  - programming-languages
  - reprint
  - software-engineering
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Static analysis enthusiasts</li>
        <li>Logic programming enthusiasts</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Recent experience with <a href="https://souffle-lang.github.io/">Soufflé</a> Datalog.</li>
        <li>Discussion with Max Bernstein about his blog post <a href="https://bernsteinbear.com/blog/linear-scan/"><i>Linear scan register allocation on SSA</i></a>, resulting in his blog post <a href="https://bernsteinbear.com/blog/liveness-datalog/"><i>Liveness analysis with Datalog</i></a>.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td><ul>
        <li>Liberated</li>
      </ul></td>
    </tr>
  </table>
</div>

{% include toc.md %}

## Soufflé

I recently experimented with [Soufflé][souffle] [Datalog][datalog] for a certain work problem: comparing CI jobs' declared dependencies with dependencies inferred via abstract interpretation (which is worth a separate post).

[souffle]: https://souffle-lang.github.io/
[datalog]: https://en.wikipedia.org/wiki/Datalog

Recently, I saw the blog post [*Linear scan register allocation on SSA*](https://bernsteinbear.com/blog/linear-scan/) and noted that there was quite a lot of imperative implementation code, to the point where it might obstruct experimentating with the underlying ideas.

I suggested that the author could use Datalog instead to simplify the analyses, and we worked through the example of rewriting the [liveness analysis](https://en.wikipedia.org/wiki/Live-variable_analysis) in Soufflé, resulting in the blog post [*Liveness analysis with Datalog*](https://bernsteinbear.com/blog/liveness-datalog/).

## Rapid prototyping

As per its homepage, Soufflé promises to enable "rapid prototyping":

> Rapid-prototyping for your analysis problems with logic; enabling deep design-space explorations; designed for large-scale static analysis; e.g., points-to analysis for Java, taint-analysis, security checks.

And from my recent experience, I found that it delivered!

{% noteblock note-info %}
<span class="note-tag note-info">For example:</span> When I wanted to implement the rule that, in [Bazel][bazel], the target
`foo/...` expands to all targets under `foo`, I just had to add one rule:

[bazel]: https://bazel.build/

```datalog
BazelLDep(repo, package, "...", $BazelTarget(repo, package, target)) :-
  BazelLDep(repo, package, target, _),
  target != "...".
```

It can be read as:

> A target of the form `<package>/...` has a dependency on every target of the form `<package>/<target>`, as long as that target is not `...`.

And then this rule automatically combines with all the other rules about dependencies that I'd written in the analysis.

Who originally created the nodes of the form `foo/...`? Where are all the places that might consume them? I don't know! I don't care! I just let the Datalog engine figure it out.
{% endnoteblock %}

## The curse of brevity

In that [blog post](https://bernsteinbear.com/blog/liveness-datalog/), the demonstration seems more blithe than lithe, because we end up showcasing basically two lines of Datalog:

```datalog
live_out(b, v) :- block_succ(s, b), live_in(s, v).
live_in(b, v) :- (live_out(b, v) ; block_use(b, v)), !block_def(b, v).
```

{% noteblock %}
<span class="note-tag">Not even that:</span> Our original formulation used only a single rule! We split it into two rules for clarity.
{% endnoteblock %}

So what's the big deal? Well, it's an order-of-magnitude reduction compared to the original code!

```ruby
def analyze_liveness
  order = post_order
  gen, kill = compute_initial_liveness_sets(order)
  live_in = Hash.new 0
  changed = true
  while changed
    changed = false
    for block in order
      block_live = block.successors.map { |succ| live_in[succ] }.reduce(0, :|)
      block_live |= gen[block]
      block_live &= ~kill[block]
      if live_in[block] != block_live
        changed = true
        live_in[block] = block_live
      end
    end
  end
  live_in
end
```



The Soufflé [examples page](https://souffle-lang.github.io/examples) has the same problem. They look trivial. Does this look like a substantial program to you?

```datalog
.decl alias( a:var, b:var )
.output alias
alias(X,X) :- assign(X,_).
alias(X,X) :- assign(_,X).
alias(X,Y) :- assign(X,Y).
alias(X,Y) :- ld(X,A,F), alias(A,B), st(B,F,Y).

.decl pointsTo( a:var, o:obj )
.output pointsTo
pointsTo(X,Y) :- new(X,Y).
pointsTo(X,Y) :- alias(X,Z), pointsTo(Z,Y).
```

But when I first read that page, I was blown away — only because I already knew how much code it would take in a traditional programming language.

{% include end_matter.md %}

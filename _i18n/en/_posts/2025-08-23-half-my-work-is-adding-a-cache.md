---
layout: post
title: "Half my work is adding a cache"
permalink: half-my-work-is-adding-a-cache/
tags:
  - build-systems
  - rant
  - reprint
  - software-engineering
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Back-end software engineers, particularly in big tech.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Experience in big tech working on highly-scalable developer tooling.</li>
        <li>Sophie Alpert's blog post <i><a href="https://sophiebits.com/2025/08/22/materialized-views-are-obviously-useful">Materialized views are obviously useful</a></i>.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td><ul>
        <li>Frustrated.</li>
        <li>Determined that we should do better as an industry.</li>
      </ul></td>
    </tr>
  </table>
</div>

{% include toc.md %}

When I was a kid, I wrote a [little social networking site for my school](https://github.com/arxanas/schmacebook). Back then, *in 2010*, I was surprised to learn that MySQL didn't seem to support "materialized views". Of course, I didn't even know the name for the concept back then; but I understood that the concept should *exist*.

In their blog post *[Materialized views are obviously useful](https://sophiebits.com/2025/08/22/materialized-views-are-obviously-useful)*, Sophie Alpert points out that incremental view maintenance is still unreasonably difficult for trivial applications. And *it's 2025*. In those 15 intervening years, we've barely accomplished anything as an industry to make incremental computation more tractable for the masses.

At best, we have *[DBSP: Automatic Incremental View Maintenance for Rich Query Languages](https://arxiv.org/abs/2203.16684)* (2022), which is a great paper and formalization, but was also probably realizable in 2010. We have a few startups ([Materialize](https://materialize.com/), [Feldera](https://www.feldera.com/)) who offer incremental view maintenance as a service. More expansive efforts like [Skiplang](https://skiplang.com/) petered out. This is sad.

I've reproduced my [Lobste.rs comment on the aforementioned blog post](https://lobste.rs/c/oalnwv) below.

---

This has been my thesis for a while:
- Half of my work in big tech has just been "adding cache" or "removing a cache" in response to scaling latency/throughput requirements.
- We absolutely need higher-level primitives for developing incremental systems, particularly in distributed contexts.
- Somehow, our best alternative at each point has been to just build another ad-hoc, informally specified, bug-ridden, slow implementation of a build system.

I'm excited for efforts like Feldera (DBSP) to help provide
1. concretely, a specific implementation of a "build system as a library", but also
2. abstractly, a reliable pattern that can be reimplemented across multiple environments where it's unavailable (kind of like ReactiveX).

I think the main missing piece is that it's hard to reconcile "persistent state" across many different environments/runtimes in a well-patterned way:
- DBSP gives you a formula for effective incremental computation, but I don't yet know how hard it is to wire it up to arbitrary data sources for input and output.
- More specifically, the pattern seems to require that the underlying data source has a linear notion of "time", which is not how most people have been designing their databases in practice.
  - I can't go take an arbitrary database at work that somebody implemented five years ago and easily ask Postgres for the delta stream.
   - I mean, I'm sure it's possible, but if it's not dead simple, then I as a random developer am not going to be equipped to do it.

{% include end_matter.md %}

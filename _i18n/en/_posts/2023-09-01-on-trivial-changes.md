---
layout: post
title: On trivial changes
permalink: on-trivial-changes/
tags:
  - software-engineering
---

_Intended audience: software engineers; anyone with checklists as part of their workflows or routines._

One day, perhaps three years into my career, I had a very small, one-line code change to make. I don't remember exactly what it was, but I think it involved computing a value and interpolating it into a string. I considered committing it directly, but submitted it for code review despite how small of a change it was.

My reviewers pointed out three different bugs, which makes it perhaps the buggiest commit I've ever written (by density of bugs per lines of code). Since that day, I always submit code for review and I always wait for builds and tests to finish, even for changes which "obviously" don't affect anything.

{% include end_matter.md %}

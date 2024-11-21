---
layout: post
title: '"Will I ever use this in the real world?"'
permalink: will-i-ever-use-this/
tags:
  - cs-education
  - software-engineering
---

Sometimes people argue on the internet about whether a formal CS education is
necessary to be an effective software engineer. I won't say that it is
necessary, but I present an anecdote from an internship of mine, in which I have
an unexpected encounter of certain esoteric computer science topics.

{% include toc.md %}

## An anecdote

*May 24, 2016 —* It is the second week of my internship at `$BIG_COMPANY`. I
have been assigned to the internal code review tool. As is good practice, the
developers here break up their code into small, self-contained commits for ease
of review, so that their peers might review each commit individually and avoid
cognitive overload.

For each commit, the code review tool displays a list of commits which this
commit is based on, and a list of commits which are based on this commit. Alas,
it only displays them one level deep, so developers spend a great deal of time
traversing this chain of dependencies finding the commits that haven't been
reviewed. My job is to display the entire chain in a single tidy graphic,
emphasizing these commits.

A dependency graph is, of course, a data structure of theoretical note. I have
to apply a graph traversal algorithm to construct the graph in memory from the
database. Then I have to apply a topological sort to give a linear, consistent
ordering in which the commits should be reviewed. Had I not been taken my
algorithms and data structures course, I would have been rather unprepared for
this task.

"But graph traversal is a single, trifling topic," you exclaim, "which any
competent software engineer can pick up!" And rightfully so; a graph traversal
does not a CS education make.

### You have been led astray, for this anecdote is not about graph traversals, which constitute a relevant but not critical tangent

*May 25, 2016 —* I sit beside the team working on the internal calendar and
meeting tools, and immediately to my right sits Dave. One day I notice a booklet
of papers lying on his desk, ostensibly of academic nature.

I peek at the paper when he is not at his desk: [*Linear Scan Register
Allocation*][linear-scan]. It was not that long ago that I had taken my
compilers course, so I recall that the algorithm was used in the HotSpot JVM
with good performance. This surprises me, as no one mentioned that we ran our
front-end Javascript on the JVM.

[linear-scan]: http://web.cs.ucla.edu/~palsberg/course/cs132/linearscan.pdf

I look up his internal employee profile to confirm that he is, in fact, a
front-end engineer. Is he working on something for one of the compiler teams? I
am envious: I had wanted to work on the
`$COMPANY_BACKED_BUT_OPEN_SOURCE_LANGUAGE` team here.

*May 26, 2016 —* Dave is at his computer, unsuspecting. I have prepared a flow
of conversation so as to broach the topic of being relocated to this compiler
team.

"Hey, what's up with the paper on your desk?" I ask. "Are you working on a
compiler team?" My subtlety knows no bounds.

"Haha, no," he starts, "no — I'm working on the meeting tool. It assigns the
meeting rooms to the meetings automatically, but it's been performing way too
slow lately. It turns out that the problem of scheduling the rooms is identical
to the problem of register allocation..."

I recall how register allocation is modeled as a graph-coloring problem. The
meetings and meeting rooms here are analogues of variables and registers.
Meeting rooms (registers) can only be used by one meeting (variable) at a time;
two meetings (variables) cannot use the same meeting room (register) if they are
being conducted at the same time (in use at the same time in the program). From
the timing information, one can construct an interference graph and attempt to
color it, hopefully producing a good coloring, which corresponds to a good
meeting room allocation.

If I had not taken my theoretical computer science course and my compilers
course, would I have been nearly as well-equipped to understand the algorithm?
Were I in his position, would I ever have thought to seek it out?

One doesn't need a degree to wrestle a graph-coloring problem, but having
exposure to a breadth of computer science topics indeed pays its dividends. In
practice, knowing what it is that you don't know is very valuable.

Some say that to implement a CRUD app one does not need any understanding of
theoretical computer science whatsoever. For those who hold that opinion — I
wish you luck implementing your next meeting tool.

{% include end_matter.md %}

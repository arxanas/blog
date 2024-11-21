---
layout: post
title: How to get a job in programming languages
permalink: getting-a-job-in-pl/
tags:
  - career
  - programming-languages
reddit: https://www.reddit.com/r/ProgrammingLanguages/comments/9ffiky/how_to_get_a_job_in_programming_languages/
---

## Introduction

I recently saw this posted to Twitter:

{% twitter https://twitter.com/graydon_pub/status/1039597413936160768 %}

It's true! Developer tooling is a great space to be in, since you're in the
target audience for the products you're building, so it's easy to feel invested
in your work. And the deterministic testing is great.

But how do you actually *get* a job in programming languages specifically? The
sad truth is that there are not a lot of opportunities to work in programming
languages professionally: it has to be your institution's core competency, or
your institution has to be so large that it's economical for them to spend
multiple developer-years on a programming language project.

I had figured out after having taken my compilers course in college that I
wanted to go into programming languages as a full-time profession. This article
is the guide I wish I had when I was searching for jobs.

{% include toc.md %}

## Academia

The simplest way (but I won't claim it's the easiest way) to get into
programming languages is to pursue a position in academia. You get to choose
your institution and advisor to make sure that you find a position where you'll
be able to work on programming languages full-time. The downside is that you're
not compensated very well, relatively-speaking.

At my alma mater, the University of Michigan, we had no programming language
faculty whatsoever. Apparently Carnegie Mellon University had taken them all.
The state of programming language research seems to be a bit better in Europe
than in the US, with institutions like Cambridge and INRIA. Many of my
formally-trained coworkers reside in our London office.

## Large tech companies

Large tech companies have so many developers that it starts to make sense to
build tooling specifically for those developers. One minute saved per developer
across 10,000 developers per day would pay for your yearly salary a few times
over.

Some large tech companies with programming language teams:

* Microsoft (C++, C♯, VB, TypeScript, Chakra).
* Google (Go, Dart, V8).
* Facebook (Hack, Flow, Pyre).
* Apple (Swift, LLVM).

The good news is that you're well-compensated for working at these companies.
The bad news is that it's hard to get such a job.

## Financial institutions

It surprised me when I was looking for jobs how many financial institutions had
their feet wet in programming languages. This is mostly for two reasons:
reliability by means of safer programming languages, and performance for
handling massive data streams.

Some examples of banks with programming language projects:

* Morgan Stanley (Hobbes).
* Goldman Sachs (Slang).
* Standard Chartered. I had a coworker once who talked about their eager
  spreadsheet-based variant of Haskell designed for parallel computing.

Some examples of trading firms with programming language projects:

* Jane Street (OCaml).
* Jump Trading. One of my classmates joined there full-time out of college and
  mentioned that they had people working on eking out performance from their C++
  compiler. They also sponsored his H1B, so trading firms could be a good fit
  for international candidates.

## Companies with developer-facing products

The only other way a company can afford to spend time on a programming language
is if it's one of its core competencies. JetBrains makes the Kotlin language as
well as excellent developer tooling. (It also has the advantage of being
headquartered in Saint Petersburg, where presumably the developer salaries are
lower than in the US). Mozilla develops Rust in the course of improving Firefox.
(They are in a bit of a unique situation given how their income works.)

## How did I do it?

I received a Bachelor's degree in computer science from the University of
Michigan. Once there, I heavily optimized towards getting a job at a large tech
company. I got a job as an undergraduate teaching assistant, then interned at
Amazon, and then interned again at Facebook, and ultimately joined Facebook
full-time in Seattle out of college working on the Hack programming language.

{% aside Two internships? %}

One internship, usually in the summer between one's junior and senior years is
typical. I had two internships instead of one because I originally intended to
return to university for my Master's degree and to do an internship in between,
a common practice for Master's students. I decided halfway through my internship
that I want to go into industry instead, and got my return internship offer
converted into a return full-time offer.

The effects of getting a second internship were profound. The internship
interview process is substantially easier than the full-time interview process,
and the compensation package turned out to be very competitive, even compared to
non-internship-return offers for Facebook new grad hires. (If you want to know
the details of the compensation package I got, you can email me or leave a
comment.)

And overall it was much easier to get the second internship offer at all because
I had the first internship on my résumé!

If you have the resources to do so, it may make sense to apply for a Master's
degree somewhere or even delay graduation by a semester to arrange for this sort
of double-internship.

I actually had two friends who, like me, were undergraduate teaching assistants,
completed first internships at various places, then second internships at
Amazon, and then got and accepted full-time offers from Google and Microsoft,
respectively. So there is a cohort of people who do this sort of thing with
excellent results. If you are set on working at a large tech company, it's best
to start grinding this route as soon as possible.

{% endaside %}

New hires at Facebook go through a 6-week "bootcamp" process where you browse
teams and try to find one that's a good fit for you. Even though I interned at
Facebook, I foolishly didn't take the time to get a good sense of what teams
were hiring. Nonetheless, I took a gamble and joined Facebook anyways out of
college and did find a spot on the Hack programming language team, which had
just started expanding in its Seattle office. (Fun fact: for a couple of weeks,
my only coworker in the Seattle office was Eric Lippert, known for his work on
C♯ at Microsoft.)

I didn't consider academia at all when I was in college, thinking that I wasn't
cut out for it. I should have at least considered it given that I wanted to go
into programming languages, possibly by participating in research as an
undergrad.

I seriously looked at Microsoft and Google, both of which have top-notch
programming language teams. While I was interviewing at Microsoft, I asked a
hiring manager if it would be a problem for someone with only a Bachelor's
degree to get into programming languages. He reassured me that
programming language teams needed entry-level developers just like most other
teams, and that, indeed, PhD hires oftentimes just wanted to continue their PhD
work, which only aligned with the company's business needs perhaps three months
out of the year.

I didn't accept an offer with Microsoft because the pay was less and because I
liked the culture at Facebook, although they did guarantee me a position
somewhere in their developer division. I didn't accept an offer with Google
because they only got back to me about my interview results one week after the
deadline of my Facebook full-time offer elapsed (!).

{% aside The résumé black hole %}

Big tech companies have a "résumé black hole": you can submit your résumé to an
online portal, but it's unlikely that they'll even set you up for a phone screen
unless you have some impressive experience. But how do you get the impressive
experience necessary if you can't get an interview at a big tech company? And
even if you do have the experience, the technical interviews have a reputation
for being grueling and overly focused on computer science rather than software
engineering.

I first managed to secure an undergraduate teaching assistant position for our
Data Structures and Algorithms class, which looked great on my résumé. This
position was available because the University of Michigan has large enough class
sizes in the computer science department that they have no choice but to hire
some number of undergraduate teaching assistants to handle the load. I did well
in the course and made an impression on the professor teaching it by answering a
lot of questions on the class forum, and then cold-emailed them asking for a
job. (I did have to send them a couple of reminder emails throughout the
semester since I didn't get a response... professors are busy people.)

I submitted my improved résumé into the black hole for various large tech
companies. The only one I heard back from was Amazon. They had an easy interview
pipeline in that they just made me do a single online coding assessment and then
extended me an internship offer — no need to get an actual human to spend time
on me!

Amazon was a stepping-stone to getting interviews at large tech companies, such
as Google, Facebook, and Microsoft. For example, right after my Amazon
internship ended, I submitted my updated résumé to the Google résumé black hole,
and got a response back from a recruiter within a week. My experience teaching
data structures and algorithms for many semesters in a row then prepared me for
the ensuing technical interviews.

If you don't have the requisite experience on your résumé, the other thing you
can do is to get someone who works at the company to refer you, which is how a
large percentage of their openings end up filled.

Both of these routes are pretty awful on the whole, but it's hard to do anything
other than play by the large tech companies' rules.

{% endaside %}

I'll admit: I had a privileged upbringing which afforded me the resources and
the confidence to jump through the set of hoops necessary to secure my current
position. Frankly, the technical hiring process for these large companies is
ridiculous, and not everyone has the resources to spend years aiming for one.

I'm writing about my experience because I believe putting the information out
there is better than not putting it out there. Regardless of your situation, I
hope that this article helps you make a concrete plan about how to get your
desired job in programming languages as well.

{% include end_matter.md %}

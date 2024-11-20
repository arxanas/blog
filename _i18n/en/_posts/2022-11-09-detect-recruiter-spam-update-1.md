---
layout: post
title: "Update #1: Automatically detecting and replying to recruiter spam"
permalink: detect-recruiter-spam-update-1/
series:
  prev: detect-recruiter-spam/
tags:
  - career
  - machine-learning
  - python
---

{% include toc.md %}

In [*Automatically detecting and replying to recruiter spam*][detect-recruiter-spam], I discussed an approach to automatically classifying and detecting unsolicited recruiter messages. Since then:

  [detect-recruiter-spam]: {% permalink detect-recruiter-spam %}

- I received a message from a recruiter, which was automatically replied to by my recruiter bot. This led me to leave my old job and accept a new offer at around twice the total compensation.
- In [`Support responding via Gmail`](https://github.com/arxanas/detect-recruiter-spam/commit/47f4106cac9067958c3e2679c486a052f9794f25), I got the bot to successfully reply to LinkedIn emails, and therefore send replies on my behalf on LinkedIn.
    - However, I believe this to be counterproductive. In my understanding, LinkedIn keeps an activity/response timeliness score for users to determine if a given user is likely to be open to new opportunities on LinkedIn. Automatically responding to LinkedIn messages would raise this score. As a consequence, this positive feedback loop has caused me to receive *more* LinkedIn messages than ever before! So I disabled auto-replies to LinkedIn emails.

{% include end_matter.md %}

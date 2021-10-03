---
layout: post
title: "Is having a '.name' email address a good idea?"
permalink: dot-name-email-address/
hn: https://news.ycombinator.com/item?id=12535428
tags:
  - career
  - software-engineering
---

 * toc
{:toc}

## Why would one get such a silly URL?

For me, the biggest problem was that waleedkhan.com was taken! It's not a very
common name in the US, but I understand it's reasonably common in Asia.
Additionally, having a memorable TLD can help with branding, [as I discuss
below](#branding).

One of the problems with the new TLDs (such as `.ninja` or `.coffee`) is that
the average consumer may not even realize that a given address refers to a URL!
As you see, my website's URL is a `.name` address, and consequently so is my
email address. Whether or not it's okay depends on your audience.

## When it's a pain

### People may think it's a mistake

Once, when booking travel for an interview, the travel agent asked me to
confirm my email address as a matter of course. Upon reading it aloud, they said
something like "me@waleedkhan.name? That can't be right..." to which I had to
respond that it was in fact correct.

Having an unusual email address may raise flags, but for the most part I imagine
that it's fairly benign.

### Computers may think it's a mistake

I got this frustrating error from American Airlines recently, which is actually
what motivated this post:

{% image dot-name-american-airlines.png
         "American Airlines refusing my perfectly good .name email address when
          trying to check out." %}

Now, `.name` isn't one of the "new" TLDs: it's existed since 2001, so it's
pretty disappointing that it still isn't supported in 2016. It used to be that
one could enumerate all of the currently active TLDs and put them all into one
great big regex to attempt validation. It was dubious back then at best, and
nowadays is considered completely wrong.

{% aside How should one validate email addresses? %}

Many, many articles have been written about how not to validate email addresses;
you can find them quickly with a Google search. [Here's an example
post.](https://elliot.land/validating-an-email-address)

In short, one should not do much more than check if the email has an `@` sign in
it. As far as client-side validation, the `email` input type is surely a good
way to go. **The only way to truly verify an email address is to send it an
activation email**.

{% endaside %}

### Somebody else can get your more desirable URL

In my case, somebody else already had waleedkhan.com, so it wasn't something I
could have prevented. I've been trying to reclaim my name's spot in Google's
search rankings lately, but other people's blogs and news posts take up a good
bit of the first few results (at the time of this writing).

To avoid this, it's probably worth getting the traditional form of the URL on
top of your desired URL as insurance. Additionally, you can set up your email to
work with both domains, in case you encounter a system that doesn't accept your
preferred email address.

## When it works out

### Certain custom websites

I run a website to draft Magic: the Gathering online. On this website, players
construct decks by passing around virtual booster packs. Then, they export the
decks to an unrelated desktop program and play using that. The website's URL is
[drafts.ninja](http://drafts.ninja).

In this case, I don't believe that it's been a problem to have an unusual URL.
The target audience is already reasonably tech-savvy, as they had to set up a
desktop client on their own. The typical age is likely to be on the younger end.
Thus, they are likely to understand that new, weird TLDs exist.

### Branding {#branding}

An interviewer once commented on my email address. If one is trying to build up
a brand as a software developer, then the target audience is other software
developers, who will more likely understand, appreciate, and remember the URL.

In this case, I happened to be talking to the person in charge of the Google
Domains team (which, incidentally, can be visited at
[https://domains.google](http://domains.google)). I like to think that the
encounter formed a positive impression of me!

## I don't think my URL was a mistake

Overall, the harm done has been relatively minor --- I do have a regular email
address to sign up for services with, after all. My intention in getting this
domain was for branding purposes. Given that it's been remarked upon at least
once to my face, I think that my goal has been achieved. But I'll be on the
look-out for waleedkhan.com, when it becomes available...

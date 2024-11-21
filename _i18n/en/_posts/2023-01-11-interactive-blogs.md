---
layout: post
title: Interactive blogs
permalink: interactive-blogs/
translations:
  pl: "/pl/interaktywne-blogi/"
tags:
  - rant
  - writing
---

{% include toc.md %}

My ideal blogging platform is [Google Docs](https://www.google.com/docs), because it supports the following:

- Live collaboration.
- Leaving inline comments on the text, rather than in a separate area.
- Suggesting inline edits. What a low-friction way to apply incremental improvements!
    - For this reason, I also prefer Wikis to Git when it comes to writing documentation, because the barrier to entry is much lower.

Unfortunately, Google Docs isn't particularly accessible:

- It seems to not be indexable by search engines?
- Requires Javascript.
- Requires Google, which some people are opposed to, for privacy reasons.

So I don't publish my blog posts that way.

<style type="text/css">
@keyframes hypermedia {
  0%, 100% {
    left: -1em;
    top: 0.4em;
    z-index: 1;
    font-size: normal;
  }
  
  25% {
    font-size: 1.3em;
  }
  
  75% {
    font-size: 0.7em;
  }

  50% {
    left: 97%;
    top: -0.6em;
    z-index: 1;
    font-size: normal;
  }
  
  51%, 99% {
    z-index: -1;
  }
}

.hypermedia {
  letter-spacing: 0.1em;
  position: relative;
  font-variant: small-caps;
}

.hypermedia::before {
  content: "✨";
  position: absolute;
  animation-name: hypermedia;
  animation-duration: 6s;
  animation-iteration-count: infinite;
  animation-timing-function: ease-in-out;
}
</style>

But in the era of <span class="hypermedia">hypermedia</span>, these features ought to be standard! We ought to <span class="hypermedia">have&nbsp;discussions</span>, not fling articles into <span class="hypermedia">the&nbsp;void</span>!

Medium used to show inline comments, [but doesn't anymore](https://medium.com/@jashan/how-to-make-the-best-of-a-broken-commenting-system-113c8cc1fe71) (not that I am particularly keen to publish on Medium). I haven't seen many other blogs that invite discussion via interactive features.

I was once reading [*Real World OCaml*](https://dev.realworldocaml.org/) while its second edition was in draft. After each *sentence*, it had a link to leave a comment. Now that's a way to write a book! Why should a literal book be more interactive than our blogs?

## Perish not this blog

As of recently, you can leave inline comments on paragraphs on my blog by hovering/tapping and clicking the "Comment" link that appears.

- Other solutions:
  - <https://utteranc.es>
  - [Disqus](https://disqus.com/)
    - Already used for comments on this blog, although it's a little shady with respect to cookie usage.
  - These alternatives require spawning a comment thread for each commentable paragraph.
    - The UIs are not designed to be compact, so they didn't fit into the flow of the blog well. You'd have a massive comment form for each paragraph.
    - This would induce unnecessary load on the commenting servers, which is a little rude to them.
    - This would make the page load more slowly as it queries *n* comment threads.
  - You could take inspiration from a project like [SideComments.js](https://aroc.github.io/side-comments-demo/).
- My implementation unfortunately relies on GitHub as the authentication provider and database. I'm sure many readers won't have GitHub accounts.
  - That was the easiest way for me to implement it.
  - The GitHub API is expressive enough to query all of the comments for a document in a single request.
  - The GitHub API doesn't need authentication or an API key to make requests!
    - Presumably you'll be rate-limited more aggressively than if you were authenticated.
  - Opening a new GitHub Issues page to leave your comment is clumsy.
  - In retrospect, perhaps I should have used GitHub discussions instead of GitHub Issues as the backing store, since they're... discussions.
- Paragraphs are identified using the post permalink/"slug" and by taking the first few normalized bytes of data in the paragraph and encoding as base64.
  - In theory, paragraph IDs therefore aren't stable if the content changes later, but it seems like a minor problem.
- Here's the implementation at the time of this writing (137 lines of code): [github-comment-links.js](https://github.com/arxanas/blog/blob/c34f0e18b81ed1d1b22636eaef2cabe7b6afd77e/scripts/github-comment-links.js).
  - Modern browser APIs make querying the GitHub API quite simple.

{% include end_matter.md %}

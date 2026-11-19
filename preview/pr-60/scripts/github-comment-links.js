(() => {
  const STRINGS = {
    en: {
      write_comment_here:
        "Write your comment here. Markdown will NOT be rendered in the preview.",
      original_paragraph_content: "Original paragraph content",
      reply_singular: "reply",
      reply_plural: "replies",
      comment_link: "Comment",
    },
    pl: {
      write_comment_here: "Napisz komentarz tutaj. Markdown NIE zostanie wyrenderowany w podglądzie.",
      original_paragraph_content: "Oryginalny tekst akapitu",
      reply_singular: "odpowiedź",
      reply_plural: "odpowiedzi",
      comment_link: "Skomentuj",
    }
  };
  const lang = document.documentElement.lang;

  const nbsp = "\xa0";

  const postSlug = window.location.pathname.replace(/\//g, "");
  const postId = `post:${postSlug}`;

  const affectedTags = ["p", "ul > li", "figure", "aside p"];
  const allParagraphs = new Map();
  document
    .querySelectorAll(affectedTags.map((tag) => `.post-content > ${tag}`))
    .forEach((item) => {
      if (item.closest("#markdown-toc")) {
        return;
      }

      // Calculate text content and paragraph ID before we add any text nodes below.
      const paragraphRawContent = item.textContent;
      const paragraphId = btoa(
        paragraphRawContent.toLowerCase().replace(/[^a-zA-Z0-9]/g, "")
      ).substring(0, 16);
      allParagraphs.set(`${postId},par:${paragraphId}`, item);

      // Create link target (to GitHub issues).
      const githubIssuesUrl = new URL(
        "arxanas/blog/issues/new",
        "https://github.com"
      );
      githubIssuesUrl.searchParams.append(
        "title",
        `${postId},par:${paragraphId}`
      );
      const bodyText = `
${STRINGS[lang].write_comment_here}

<!-- ${STRINGS[lang].original_paragraph_content}:

${paragraphRawContent}

-->
`;
      githubIssuesUrl.searchParams.append("body", bodyText);

      // Create "Comment" link.
      const parentNode = item.appendChild(document.createElement("a"));
      parentNode.href = githubIssuesUrl;
      parentNode.classList = "github-comment-link";
      parentNode.appendChild(document.createTextNode(STRINGS[lang].comment_link));

      item.prepend(parentNode);
    });

  const renderCommentsForParagraph = (paragraph, issues) => {
    const commentContainer = document.createElement("div");
    commentContainer.classList = "github-comment-container";

    for (const issue of issues) {
      // Create author link.
      const authorLink = document.createElement("a");
      authorLink.href = issue.user.html_url;
      authorLink.textContent = `@${issue.user.login}`;
      authorLink.classList = "github-comment-author";

      // Create comment text.
      const comment = document.createElement("div");
      comment.classList = "github-comment-body";
      comment.appendChild(authorLink);
      comment.appendChild(document.createTextNode(` — `));

      const commentBody = document.createElement("i");
      const bodyText = issue.body.replace(/<!--.*?-->/gms, "").trim();
      commentBody.appendChild(document.createTextNode(bodyText));
      comment.appendChild(commentBody);

      // Create replies link.
      const numRepliesText =
        issue.comments === 1 ? `1 ${STRINGS[lang].reply_singular}` : `${issue.comments} ${STRINGS[lang].reply_plural}`;
      const numRepliesLink = document.createElement("a");
      numRepliesLink.classList = "github-comment-num-replies";
      numRepliesLink.href = issue.html_url;
      numRepliesLink.appendChild(
        document.createTextNode(`➥${nbsp}${numRepliesText}`)
      );
      comment.appendChild(numRepliesLink);

      commentContainer.appendChild(comment);
    }

    paragraph.appendChild(commentContainer);
  };

  // Query for open issues, corresponding to comments on this post.
  const apiUrl = new URL("repos/arxanas/blog/issues", "https://api.github.com");
  apiUrl.searchParams.append("title", postId);
  apiUrl.searchParams.append("state", "open");
  fetch(apiUrl).then((response) => {
    response.json().then((data) => {
      // Group issues by the paragraph they're commenting on.
      const allIssues = new Map();
      for (const issue of data) {
        if (!allIssues.has(issue.title)) {
          allIssues.set(issue.title, []);
        }
        allIssues.get(issue.title).push(issue);
      }

      for (const [title, issues] of allIssues) {
        const paragraph = allParagraphs.get(title);
        if (!paragraph) {
          continue;
        }
        issues.sort((a, b) => {
          return new Date(a.created_at) - new Date(b.created_at);
        });
        renderCommentsForParagraph(paragraph, issues);
      }
    });
  });
})();

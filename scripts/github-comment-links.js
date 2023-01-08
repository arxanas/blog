(() => {
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
<!-- Original paragraph content:

${paragraphRawContent}

-->

Write your comment here. Markdown will NOT be rendered.`;
      githubIssuesUrl.searchParams.append("body", bodyText);

      // Create "Comment" link.
      const parentNode = item.appendChild(document.createElement("a"));
      parentNode.href = githubIssuesUrl;
      parentNode.classList = "github-comment-link";
      parentNode.appendChild(document.createTextNode(`🗨${nbsp}Comment`));

      item.prepend(parentNode);
    });

  const renderCommentsForParagraph = (paragraph, issues) => {
    const commentContainer = document.createElement("div");
    commentContainer.classList = "github-comments";

    for (const issue of issues) {
      // Create author link.
      const authorLink = document.createElement("a");
      authorLink.href = issue.user.html_url;
      authorLink.textContent = `@${issue.user.login}`;

      // Create comment text.
      const comment = document.createElement("div");
      comment.appendChild(authorLink);
      const bodyText = issue.body.replace(/<!--.*?-->/gms, "").trim();
      comment.appendChild(document.createTextNode(`: ${bodyText}`));

      // Create replies link.
      const numRepliesText =
        issue.comments === 1 ? "1 reply" : `${issue.comments} replies`;
      const numRepliesLink = document.createElement("a");
      numRepliesLink.classList = "github-comments-num-replies";
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

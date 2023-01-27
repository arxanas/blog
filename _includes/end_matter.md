{% if page.related_posts %}
{% if site.lang == "pl" %}
## Powiązane posty

Poniżej znajduje się kilka ręcznie wybranych postów, które mogą Cię zainteresować.
{% else %}
## Related posts

The following are hand-curated posts which you might find interesting.
{% endif %}

<table class="related-posts">
<thead>
  <tr>
    <th>Date</th>
    <th></th>
    <th>Title</th>
  </tr>
</thead>

<tbody>
{% for related_post in page.related_posts %}
  <tr>
    <td>{{ related_post.date | date: "%d&nbsp;%b&nbsp;%Y" }}</td>
    <td class="this-post">
      {% if related_post.permalink == page.permalink %}
      (this&nbsp;post)
      {% endif %}
      </td>
    <td><a href="{{ site.base_url }}/{{ related_post.permalink }}">{{ related_post.title }}</a>
    </td>
  </tr>
{% endfor %}
</tbody>
</table>

{% if site.lang == "pl" %}
Chcesz zobaczyć więcej moich postów? Obserwuj mnie <a href="https://twitter.com/arxanas">na Twitterze</a> albo subskrybuj <a href="{{ "/feed.xml" | prepend: site.baseurl }}">za pomocą RSS</a>.
{% else %}
Want to see more of my posts? Follow me <a href="https://twitter.com/arxanas">on Twitter</a> or subscribe <a href="{{ "/feed.xml" | prepend: site.baseurl }}">via RSS</a>.
{% endif %}

{% endif %}

{% if site.lang == "pl" %}
## Komentarze
{% else %}
## Comments
{% endif %}

<ul>
{% if page.hn %}
<li><a class="icon-hacker-news" href="{{ page.hn }} ">Discussion on Hacker News</a></li>
{% endif %}
{% if page.lobsters %}
<li><a class="icon-lobsters" href="{{ page.lobsters }} ">Discussion on Lobsters</a></li>
{% endif %}
{% if page.reddit %}
<li><a class="icon-reddit" href="{{ page.reddit }} ">Discussion on Reddit</a></li>
{% endif %}
</ul>

{% if page.typeset_math %}
<link rel="stylesheet" href="{{ "/css/katex.min.css" | prepend: site.baseurl_root }}" />
{% endif %}

<script type="text/javascript" src="{{ "/scripts/github-comment-links.js" | prepend: site.baseurl_root }}"></script>

{% include comments.html %}

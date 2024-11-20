
<div markdown="1" class="series-and-toc">

<!-- TODO: update everywhere to include `toc.md`? -->

{% if page.series.posts.size > 1 %}
<p class="series-header">Posts in series:</p>

<ol>
{% for post in page.series.posts %}
<li><a href="{{ post.url | prepend: site.baseurl_root }}">{{ post.title }}</a></li>
{% endfor %}
</ol>
{% endif %}

<p class="toc-header">Table of contents:</p>

* toc
{:toc}

</div>

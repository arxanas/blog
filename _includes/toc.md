
<div markdown="1" class="series-and-toc">

{% if page.series.posts.size > 1 %}
{% if site.lang == "pl" %}
<p class="series-header">Posty w tej serii:</p>
{% else %}
<p class="series-header">Posts in series:</p>
{% endif %}

<ol>
{% for post in page.series.posts %}
<li><a href="{{ post.url | prepend: site.baseurl_root }}">{{ post.title }}</a></li>
{% endfor %}
</ol>
{% endif %}

{% if site.lang == "pl" %}
<p class="toc-header">Spis treści:</p>
{% else %}
<p class="toc-header">Table of contents:</p>
{% endif %}

* toc
{:toc}

</div>

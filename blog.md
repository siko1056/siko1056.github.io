---
layout: page
title: Blog
---

Subscribe via [[RSS]]({{ "/feed.xml" | relative_url }}).

{% for post in site.posts %}
- <a class="post-link" href="{{ post.url | relative_url }}">{{ post.title | escape }}</a>
  <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>

  {{ post.excerpt | strip_html }}
{% endfor %}

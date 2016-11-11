---
# Edit theme's home layout instead if you wanna make some changes
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: default
---

# [Blog]({{ "/blog.html" | relative_url }}) [{% octicon rss height:32 %}]({{ "/feed.xml" | relative_url }})

{% for post in site.posts limit:3 %}
- <a class="post-link" href="{{ post.url | relative_url }}">{{ post.title | escape }}</a>
  <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>

  {{ post.excerpt | strip_html }}
{% endfor %}



# Files published with [GNU Octave](http://www.octave.org)

{% for doc in site.octave_publish %}
- <a class="post-link" href="{{ doc.url | relative_url }}">{{ doc.title | escape }}</a>
  <span class="post-meta">{{ doc.date | date: "%b %-d, %Y" }}</span>

      grabcode ("{{ doc.path | replace: '_octave_publish', 'src/octave/html' | replace: '.markdown', '.html' | absolute_url }}")

{% endfor %}

> Use the [grabcode](https://www.gnu.org/software/octave/doc/interpreter/XREFgrabcode.html)
  command from the Octave command line to get the code directly into the editor.

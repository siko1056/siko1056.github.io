---
# Edit theme's home layout instead if you wanna make some changes
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: default
---

# [Blog]({{ "/blog.html" | relative_url }}) [<!--{ octicon rss height:32 }--><svg height="32" class="octicon octicon-rss" viewBox="0 0 10 16" version="1.1" width="20" aria-hidden="true"><path fill-rule="evenodd" d="M2 13H0v-2c1.11 0 2 .89 2 2zM0 3v1a9 9 0 0 1 9 9h1C10 7.48 5.52 3 0 3zm0 4v1c2.75 0 5 2.25 5 5h1c0-3.31-2.69-6-6-6z"></path></svg>]({{ "/feed.xml" | relative_url }})

{% for post in site.posts limit:3 %}
- <a class="post-link" href="{{ post.url | relative_url }}">{{ post.title | escape }}</a>
  <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>

  {{ post.excerpt | strip_html }}
{% endfor %}



# Files published with [GNU Octave](http://www.octave.org)

{% for doc in site.octave_publish %}
- <a class="post-link" href="{{ doc.url | relative_url }}">{{ doc.title | escape }}</a>
  <span class="post-meta">{{ doc.date | date: "%b %-d, %Y" }}</span>

      grabcode ("https://siko1056.github.io/{{ doc.path | replace: '_octave_publish', 'src/octave/html' | replace: '.markdown', '.html' }}")

{% endfor %}

> Use the [grabcode](https://www.gnu.org/software/octave/doc/interpreter/XREFgrabcode.html)
  command from the Octave command line to get the code directly into the editor.

---
layout: post
title:  "Some drawbacks with GitHub pages"
date:   2016-11-13
categories: blog
---

The lovely idea to reproduce the easy static site building with GitHub pages
revealed some drawbacks, I really have to work around them to keep the
features I was used to.

1. The nice filters of Jekyll 3.3 `absolute_url` and `relative_url`
   [announced by GitHub][1] I don't get to work on their machines,
   while on mine everything works as expected.

[1]: https://github.com/blog/2277-what-s-new-in-github-pages-with-jekyll-3-3

2. The nice little [GitHub Octicons][2] plugin is currently not supported
   at [GitHub pages-gem][3]. I tried to inline the generated SVG-files
   by hand, but this is a very bad user experience.

[2]: https://octicons.github.com/
[3]: https://github.com/github/pages-gem

3. I cannot highlight Octave Code with the default highlighter [rouge][4].
   GitHub pages [will not switch back][5] to [pygments][6], so I decided to
   create a [pull request][7] for adding this feature for the future.

[4]: https://github.com/jneen/rouge
[5]: https://help.github.com/articles/using-syntax-highlighting-on-github-pages/
[6]: http://pygments.org/
[7]: https://github.com/jneen/rouge/pull/568

So my plan is now to develop on a `dev` branch, generate the page really
"at home" and just upload the static page to the `master` branch until
my features are supported.

---
layout: post
title:  "Initial commit"
date:   2016-11-11
categories: blog
---

While working with {% include icon-github.html username="alexkrolick" %} on the [new GNU Octave website][1],
I got aware of [Jekyll][2] and do really like the idea of generating
all webpages "at home" to avoid the overhead of dynamic pages,
where the content is not likely to change that frequent.

[1]: http://hg.octave.org/web-octave/
[2]: https://jekyllrb.com/

I am looking for "more beautiful" ways to document things
I do with and for the [GNU Octave][3] project.
The current ways of documenting Octave code
will be addressed within another post.
Anyway,
as noncompetitive summer of code project of mine
the [publish function][4] was created and merged within the Octave core
for the approaching 4.2 release.
Here will be my playground to display the "published" documents
and maybe some other things I don't want to forget.

[3]: http://www.octave.org
[4]: https://github.com/siko1056/octave-publish

To create those "published" pages,
listed on the main page of this blog,
one can use [`publish_jekyll_md_output.m`][5] and some minor
hacking into the code of the publish function.

1. Type from the octave command line `edit publish`
2. Create a new `options.format` in the main function.
3. Assign the `publish_jekyll_md_output.m` to that new format
   in the subfunction `create_output`.

[5]: {{ "/src/octave/publish_jekyll_md_output.m" | absolute_url }}

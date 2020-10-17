---
layout: post
title:  "Fresh brewed Octave - every day!"
date: 2020-10-16
modified_date: 2020-10-17
categories: blog
image: /assets/blog/2020-10-16_buildbot_octave_space_icon.png
tags:
  - octave
---

The [octave-buildbot](https://github.com/gnu-octave/octave-buildbot/)
Server and Worker matured a lot in the past two months since
[I wrote about them in August]({% post_url 2020-08-17-octave-buildbot %}).
Finally, the system is capable of delivering **once per day** a "fresh brewed"
stable Octave release (tarballs, all flavors of MS Windows installers, and the
Doxygen documentation).  See it yourself on <https://octave.space>.

Automated
[Continuous delivery (CD)](https://en.wikipedia.org/wiki/Continuous_delivery)
is my hope to ease the tedious task of creating and publishing Octave releases
and release candidates.  As said before, now **every day** a stable release
happens (if there were changes to the Octave stable branch) with no manpower
needed at all.


## Everything in view

When releases happen that frequently, users and developers must be able to
judge themselves, if an automatically built set of release files is
"good" and complete.

After a Buildbot Worker finishes his duty, the relevant build artifacts are
copied to the Buildbot Master, stored with the Octave Mercurial (hg) ID,
as shown in the screenshot below.

<a href="/assets/blog/2020-10-16_buildbot_octave_space_folder.png">
  <img src="/assets/blog/2020-10-16_buildbot_octave_space_folder.png"
       alt="png" width="200">
</a>

This looks unattractive and this folder view lacks any information about
the corresponding build processes done by the Buildbot Workers.

Fortunately,
[Buildbot allows to create custom dashboards](https://docs.buildbot.net/latest/manual/customization.html#writing-dashboards-with-flask-or-bottle).
The result can now be seen on the landing page of <https://octave.space>
or on the screenshot below.

<a href="/assets/blog/2020-10-16_buildbot_octave_space.png">
  <img src="/assets/blog/2020-10-16_buildbot_octave_space.png"
       alt="png" width="200">
</a>

In this dashboard the build artifacts are connected to the respective
build processes including their status.
The arrangement of those many MS Windows installers is based on the
well-known Octave website <https://octave.org/download#ms-windows>.
Furthermore,
each Octave build entry clearly states the version label, hg id, and build date.
Another feature is,
that the GNU Octave user manual and Doxygen documentation
can directly be viewed online to find potential flaws in them.


## Trust me, I'm a Buildbot Worker

Especially, when automation and many systems are in the game,
there should be a way to make sure, that the final installer downloaded from
octave-buildbot is indeed that one "brewed" on the Worker.

To achieve this, before copying the files to the Buildbot Master,
the [SHA-256](https://en.wikipedia.org/wiki/SHA-2) hash sum of each file
is displayed in the Buildbot Workers build log.

<a href="/assets/blog/2020-10-16_buildbot_octave_space_sha256.png">
  <img src="/assets/blog/2020-10-16_buildbot_octave_space_sha256.png"
       alt="png" width="200">
</a>

Admittedly, it is a little clumsy to find those hashes.
Their main purpose can be seen as check for damaged
or incompletely copied installer files to exclude sources of errors.

Speaking of errors,
for the heavy weighting mxe-octave builds,
even in the event of a build error the valuable log files are compressed
and copied to the Buildbot Master.
Because of this, there might sometimes be more than only one build log
for a particular mxe-octave build available.
They can be distinguished by the build number suffix.
The installer files themselves have a timestamp in their file name.


## The bill please

Running octave-buildbot binds a certain amount of computational resources.
The numbers given in the following table can slightly change in the future,
but didn't change significantly in the last weeks.

### Table 1: Buildbot Worker resources

In the current setup
[[note 1]](https://github.com/gnu-octave/octave-buildbot/blob/41f6c1dfbec1d2511c99ca7a889f647b60d4391a/master/defaults/master.cfg#L190)
[[note 2]](https://github.com/gnu-octave/octave-buildbot/blob/41f6c1dfbec1d2511c99ca7a889f647b60d4391a/master/defaults/master.cfg#L351),
each Worker is expected to provide 4 CPUs.
This value can of course be adjusted.


Builder name | build time | upload time | build space [1] | artifact size
| --- |
[octave-stable](https://buildbot.octave.space/#/builders/5)            | 10-15 minutes [2][3] | 20-25 minutes |  5 GB |  85 MB
[octave-doxygen](https://buildbot.octave.space/#/builders/3)           |  6-15 minutes [4]    | 10   hours    |  5 GB | 2.2 GB
[octave-mxe-stable-w32](https://buildbot.octave.space/#/builders/1)    |  5-8  hours   [2][5] |  5   hours    | 14 GB | 1.3 GB
[octave-mxe-stable-w64](https://buildbot.octave.space/#/builders/2)    |  5-8  hours   [2][5] |  5   hours    | 14 GB | 1.3 GB
[octave-mxe-stable-w64-64](https://buildbot.octave.space/#/builders/4) |  5-8  hours   [2][5] |  5   hours    | 14 GB | 1.3 GB
sum (worst case)                                                       |  24.5 hours          | 25.5 hours    | 52 GB | 6.2 GB

Table 1 footnotes:
1. Additional disk space is needed for ccache,
   which currently uses 13 GB of 20 GB,
   and 1.5 GB for the mxe-octave installer files, which are cached to avoid
   unnecessary downloads.
2. All builds are performed in an empty build folder.
3. `make check` takes most time.
4. Includes a minimal Octave build.
5. Might improve, ccache enabled for the mxe-octave builds since this week
   (thanks to Markus).


The GNU Octave stable release tasks are dived into five
["Builders"](https://docs.buildbot.net/latest/manual/concepts.html)
(Buildbot slang).
The Builder "octave-stable" has to run first and the remaining four Builders
can run in parallel after "octave-stable" finished successfully.

> This way the **worst case time** can be reduced to **about 14 hours**,
> if four Workers work on them in parallel.

A single Worker would need 50 hours for all Octave release tasks
and the goal of one release per day would be out of reach.

According to Table 1 and footnote [1],
each Buildbot Worker must provide in worst case **about 75 GB** of disk space.

### Buildbot Master resources

In contrast to the Workers, the Master only has to serve the build artifacts
and coordinate the tasks run by the Workers.
This does not require much "computational power".

Nevertheless,
storing all build artifacts requires **9 GB** per GNU Octave stable release.
Note that the Doxygen documentation is unpacked for online inspection,
for example.

The current setup of <https://octave.space> assigns 65 GB in total to store
Octave releases.
This means roughly the last seven Octave releases are available
and get automatically deleted once a new Octave release build starts.

## Open issues, if you want to jump in

As of today (2020-10-16) there are four open issues about
[octave-buildbot](https://github.com/gnu-octave/octave-buildbot/)
on GitHub.
It would be nice if they are fixed,
but those do not disturb the release process significantly (workarounds exist).

- [More efficient use of ccache.](https://github.com/gnu-octave/octave-buildbot/issues/2)
- [Speed up the file transfers.](https://github.com/gnu-octave/octave-buildbot/issues/5)
  - Fun fact: Because of my limited resources (money)
    the server is located in Germany, while the great Workers are in Japan.
- [Library issue with two of four Workers.](https://github.com/gnu-octave/octave-buildbot/issues/6)
- [Podman related deletion problem.](https://github.com/gnu-octave/octave-buildbot/issues/7)


## Summary

All in all I am very happy to enjoy a "fresh brewed Octave" every day
and hope to be able to run the system for a long time on little own expenses.

Thanks to the use of (Docker) containers,
this system can reliably release Octave on
[almost](https://github.com/gnu-octave/octave-buildbot/issues/6)
arbitrary machines with little setup and maintenance effort.
On the other hand, the computational resources and storage requirements
(4 CPUs and 75 GB per Worker and 70 GB for the Master) are not negligible
and can hopefully be tuned a little in the future by binding a certain
Worker to a particular task
([see the small discussion with Markus](https://github.com/gnu-octave/octave-buildbot/issues/2#issuecomment-708592746)).

Please contact me on [GitHub](https://github.com/gnu-octave/octave-buildbot/)
if you have suggestions for improvements
or you find any issues with this system.

Happy brewing.

# rsync boosted Buildbots

> Created: 2020-11-08

Using [rsync](https://rsync.samba.org/) instead of Buildbot's own
[file transfers](https://docs.buildbot.net/latest/manual/configuration/steps/file_transfer.html),
which [are known to be slow](https://github.com/buildbot/buildbot/issues/3709),
significantly reduced the file transfer time between the Buildbot Workers
and the Buildbot Master from 25.5 hours to about 18 minutes **(-98%)**.
This improvement, and a few others,
enables a single "strong" Worker to build and publish Octave and all
MS Windows installers
within 24 hours or with four parallel Workers within 6 hours.

> EDIT: 2024-04-10 Project moved <https://octave.space> &rarr; <https://nightly.octave.org>.

## octave-buildbot: the final picture?

[![png](./octave_buildbot.png)](./octave_buildbot.png)

The [initial project design from August](../../../2020/08/17/octave-buildbot.md)
has "matured" in the following aspects:
1. The Buildbot Master container can now be accessed from the Workers by SSH.
   This enables rsync file transfers with significant speed improvements.
   On the other hand, additional authentication is necessary.
   SSH key-based authentication was favored over plain username/password
   authentication via
   [`Secret`](https://docs.buildbot.net/latest/manual/secretsmanagement.html).
   This gives the Buildbot Master more control about the Workers
   which can access the Docker container.
   The SSH port is publicly visible and not only Buildbot Workers might try to
   get access.
2. The storage location of the build artifacts on the Buildbot Master was moved
   inside a Docker Volume and is shared with a
   [Nginx web server container](https://hub.docker.com/_/nginx).
   Testing on a local machine is now no different from the production system
   on <https://octave.space> and one does not need to worry about the Buildbot
   Master to mess up the server's file system directly.
   The system's native Apache web server now only serves as proxy
   and delegates requests from the world wide web to the respective container
   to serve the requested content.


## The bill revisited

[In a previous post](../../../2020/10/16/octave-buildbot-app) the
computational costs for the Buildbot Workers are listed in Table 1 there.
This table has been revisited below.
For the Buildbot Master there were no big changes.

Like in the previous table,
a Buildbot Worker is expected to provide 4 CPU cores and 75 GB of disk storage.

The heterogeneity among the Workers is the reason for significantly
different build times for the MS Windows installers (Octave-MXE).
"Stronger" Workers, equipped with a modern server CPU,
outperform those with a consumer CPU by hours of build time.

Builder name | build time (hours) [1] | upload time (minutes) | build space (GB) [2] | artifact size (GB)
| --- |
[octave](https://buildbot.octave.space/#/builders/8)             |    0.5   |    6   |   10   |   2.3
[octave-mxe-w32](https://buildbot.octave.space/#/builders/7)     |    5-8   |    4   |   14   |   1.3
[octave-mxe-w64](https://buildbot.octave.space/#/builders/9)     |    5-8   |    4   |   14   |   1.3
[octave-mxe-w64-64](https://buildbot.octave.space/#/builders/10) |    5-8   |    4   |   14   |   1.3
sum (worst case)                                                 | **24.5** | **18** | **52** | **6.2**

Table footnotes:
1. All builds are performed in a clean empty build folder.
2. Additional disk space is needed for ccache,
   which currently uses 13 GB of 20 GB,
   and 1.5 GB for the mxe-octave installer files, which are cached to avoid
   unnecessary downloads.

Despite the file transfer time reduction,
there were two further minor improvements:
1. The ["Builders"](https://docs.buildbot.net/latest/manual/concepts.html)
   for Octave and the Doxygen documentation have been merged.
   This reduces the build time of both tasks by about 20%,
   as no additional build of Octave for the Doxygen documentation is necessary.
   Compared to the Octave-MXE build times, this reduction is not significant.
2. The usage of `ccache` for the Octave-MXE had some measurable improvement,
   which is shown by three examples for different types of Workers:
   - [5.3 hours](https://buildbot.octave.space/#/builders/7/builds/1)
     down to
     [4.5 hours](https://buildbot.octave.space/#/builders/7/builds/7)
     (-15%) for "strong" *worker-03*  after 2 repetitions.
   - [5.25 hours](https://buildbot.octave.space/#/builders/9/builds/1)
     down to
     [4.75 hours](https://buildbot.octave.space/#/builders/9/builds/8)
     (-10%) for "strong" *worker-04* after 4 repetitions.
   - [8.3 hours](https://buildbot.octave.space/#/builders/10/builds/1)
     down to
     [7.5 hours](https://buildbot.octave.space/#/builders/10/builds/8)
     (-10%) for "weak" *worker-01* after 3 repetitions.

## Summary

The usage of `rsync` to copy the files from the Buildbot Workers to the Master
is without doubt a huge step forward for the project and it's very heterogeneous
and (over continents) distributed infrastructure.
Valuable machine hours are no longer wasted for unnecessarily slow file
transfers.

Furthermore, the thorough usage of `ccache` for the Octave-MXE builds has
a measurable impact for all types of Buildbot Workers and saves build time
for repetitive compilation tasks without sacrificing "clean" release builds.

Currently the last outstanding issue of octave-buildbot is probably
a library issue with modern CPUs.  The progress on this issue is tracked on
[GitHub](https://github.com/gnu-octave/octave-buildbot/issues/6)
and hopefully it will be solved soon.

Happy brewing.

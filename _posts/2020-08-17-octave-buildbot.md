---
layout: post
title:  "octave-buildbot: Less painful Octave releases?"
date: 2020-08-17
categories: blog
image: /assets/blog/2020-08-17_octave_buildbot.png
tags:
  - octave
---

Since the minor
[Octave 5.2 release this January](https://wiki.octave.org/Release_History),
I experienced that building and especially releasing Octave is still a
difficult task.
Even worse, due to
[some nasty bugs](https://wiki.octave.org/Online_Developer_Meeting_(2020-07-28))
and the lack of a voluntary, skilled, and motivated release manager,
the next major
[Octave 6.1 release](https://wiki.octave.org/6.1_Release_Checklist)
got stuck for eight months now.

## 1 How was Octave released in the past?

The basic workflow for the last major Octave 5.1 release was as follows:

1. Some Octave maintainer thinks it is time for a release
   and starts a topic on the
   [maintainers mailing-list](https://lists.gnu.org/archive/html/octave-maintainers/2018-12/msg00000.html)
   about it.
   This happened usually about once per year.
2. Another Octave maintainer (very often Rik, *many thanks!*) coordinated the
   release process by creating a
   [wiki checklist](https://wiki.octave.org/5.0.0_Release_Checklist)
   and sometimes a
   [wiki bug fix list](https://wiki.octave.org/Bug_Fix_List_-_5.0_Release)
   to coordinate important open bug reports.
3. Finally, mostly jwe created
   [release candidates](https://alpha.gnu.org/gnu/octave/),
   the final [release tarballs](https://ftp.gnu.org/gnu/octave),
   and MS Windows [mxe builds](https://wiki.octave.org/MXE) on his machines.

## 2 Why not just continue like this?

As mentioned before, the
[Octave 6.1 release](https://wiki.octave.org/6.1_Release_Checklist) got stuck
and I tried to summarize some problems of the current release process
from the perspective of a totally uninvolved volunteer trying to release Octave
on his own for the first time.

### 2.1 Lack of knowledge

A volunteer who wants to release Octave must be able to
[build Octave](https://wiki.octave.org/Building), release tarballs,
and the MS Windows [mxe builds](https://wiki.octave.org/MXE) on the machine.
This requires the build machine to be setup correctly.

On the first glance, this sounds like an easy task.
All steps are documented.
Unfortunately, there are implicit unnecessary build dependencies,
which only apply for releases.
For example for the Octave 5.2 release all of my work was useless,
because I did not know that the
[documentation has to be build using an X environment](https://lists.gnu.org/archive/html/octave-maintainers/2020-01/msg00310.html)...

Even though there exists lots of documentation,
there is no complete documentation of how jwe creates the releases.

### 2.2 Lack of permission

Following the current release process, not any volunteer can just step in
to become release manager.
Despite the knowledge of what to do, the volunteer must possess or negotiate
for the following permissions:

- Push rights on the
  [Octave main repository](https://hg.savannah.gnu.org/hgweb/octave/)
  (apply bug fixes, updating dates, library version numbers, etc.).
- Push rights on the
  [mxe-octave repository](https://hg.octave.org/mxe-octave)
  (updating
  [`src/release-octave.mk`](https://hg.octave.org/mxe-octave/file/7b15672f8679/src/release-octave.mk)).
- Push rights to the
  [Octave website repository](https://hg.octave.org/web-octave)
  to announce the release.
- Must be able to upload files to <https://alpha.gnu.org/gnu/octave/> and
  <https://ftp.gnu.org/gnu/octave>.
- Needs to add new versions to the
  [Octave bug tracker at savannah](https://savannah.gnu.org/bugs/?group=octave).
  
### 2.3 Lack of transparency

If the volunteer (or even jwe) succeeds to create the release tarballs,
etc., and might be able to upload his work to the respective locations,
**how can we know everything was done correctly?**

Mistakes happen.  To find out that something went wrong,
some kind of reliable build logs should be publicly accessible
alongside with the releases.

## 3 Octave-buildbot

In the past months,
I thought about a system to address some of the weaknesses identified above.
The key ideas are far from new:

1. **Save the output** (tarballs, logs, ...) from the existing
   [Octave Buildbots](https://wiki.octave.org/Continuous_Build).
2. **Use a reproducible build environment**.

[![png](/assets/blog/2020-08-17_octave_buildbot.png)](/assets/blog/2020-08-14_octave_buildbot.png)

### 3.1 What is the difference to the existing Octave Buildbots?

- The configuration of the Buildbot Master is
  [public available](https://hg.octave.org/octave-buildbot/),
  but is intended to run on a single server machine only
  and to build any commit to the Octave repository to find errors.
- Most of the current Buildbot Workers are configured and managed by jwe.
  Copying those "real" machines is difficult,
  not everybody runs Debian, for example.

### 3.2 What is the difference to the current Octave release process?

The key idea here is to get rid of the **permission problem**
to increase the frequency of building release candidates (RC) before a release.
The Buildbot Master to defines the release infrastructure:

- The Octave repository to release from can be altered by the Buildbot Master
  and is documented in the build logs.
- No need to store the release tarballs on <https://alpha.gnu.org/gnu/octave/>.
- The **Mercurial ID becomes the major Octave release identifier**,
  not some artificial manual applied version (e.g. Octave 6.0.1).

> **The idea is not to get rid of Octave versions entirely.**
> The observation is that adapting those numbers manually is tedious
> (updating the Octave and mxe-octave repository is involved)
> and leads to more confusion compared to an unique Mercurial ID.

In the current Buildbot example setup a tarball will be published like this
<https://www.octave.space/data/stable/bdc53d9affb2/octave-6.0.1.tar.gz>.
There it is clear from the URL that
[`bdc53d9affb2`](https://hg.savannah.gnu.org/hgweb/octave/rev/bdc53d9affb2)
was build, even though the release is labeled `6.0.1` for eight months.

### 3.3 Why Buildbot?

For the Octave 5.2.0 release, I used
[some bash scripts](https://github.com/siko1056/OctaveCD)
to create the desired Octave builds and to preserve the logs for my
[octave.space](https://octave.space) website.
That was too troublesome at some point (the complexity grew fast)
and didn't look "good" compared to Buildbot.
Thus, why painfully reinventing the wheel,
if Buildbot offers all demanded features in a good looking environment?

### 3.4 Why Docker?

> Having Docker installed, **EVERYBODY can help testing/releasing Octave**
> by running a
> [Buildbot worker](https://github.com/siko1056/octave-buildbot/tree/master/worker)
> on his (unused) machine!

Ever tried to compile Octave on CentOS 7 naively?
It is possible, but compared to a recent Ubuntu or Debian,
you have to manually provide many tools and libraries yourself.
Especially, if the machine is not run by you,
or a compute server shared with other users,
you are happy if nobody ever touches your self-compiled Octave once it succeeds.

This is of course far from reproducible or reliable.
Using Docker,
your virtual system (for building Octave) is defined by a
[single Dockerfile](https://github.com/siko1056/octave-buildbot/blob/70266b8c46a87c80c46aad0676f8e60675d0a60e/worker/Dockerfile)
and started with a few commands.

## 4 Summary and outlook

The project goal of
[*octave-buildbot*](https://github.com/siko1056/octave-buildbot/)
is that everybody should be able to build/release Octave
using a fully documented, reproducible Docker environment running Buildbot.

The current state of the project is:

- Buildbot Master and Server can be run on
  [a single local machine](https://github.com/siko1056/octave-buildbot/tree/master/test)
  or distributed to a webserver and several PCs
  (see <https://buildbot.octave.space>).
- The Octave release tarballs and documentation are build
  and sent to the Master.

What is missing?

- Building Doxygen: Ideas how to faster send the 2 GB of Doxygen
  to the Buildbot Master.
- Implementing the MXE builds, lack of time so far.
- Interested developers supporting my efforts.

The final suggestion from section 3.2 is to make the Mercurial ID the only
necessary release candidate identifier.
For mxe-octave this means that only 
[`stable-octave.mk`](https://hg.octave.org/mxe-octave/file/9b74815e8337/src/stable-octave.mk)
will be used, not
[`release-octave.mk`](https://hg.octave.org/mxe-octave/file/9b74815e8337/src/release-octave.mk).

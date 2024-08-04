---
layout: post
title:  "Can git and Mercurial work together?"
date: 2020-06-17
categories: blog
image: /assets/blog/2020-06-17_gitlab_export_patch.png
tags:
  - octave
---

Many popular source code hosting services do not support
[Mercurial](https://www.mercurial-scm.org/)
(in short "hg").
After
[Bitbucket](https://bitbucket.org/blog/sunsetting-mercurial-support-in-bitbucket)
announced the "sunsetting" of Mercurial repositories in April 2020,
only good old
[SourceForge](https://sourceforge.net/)
and
[GNU Savannah](https://savannah.gnu.org/)
still support hg.

Anyways,
[GNU Octave](https://wiki.octave.org/Mercurial)
still uses Mercurial and due to
[my GSoC mentoring](https://summerofcode.withgoogle.com/projects/#6263027378159616)
for Octave this year,
I was curious how well git and Mercurial work together.
The **big idea** I have in mind is:
- to find a nice addition (replacement?) for the rusty
  [Octave patch tracker](https://savannah.gnu.org/patch/?group=octave)
  on GNU Savannah.
- Contributors can make usual "merge requests" in a nice and modern web
  interface or via git commands.
  Then Octave maintainers can easily pick them up
  to convert them to hg patches for application to the main repository.

I'll show how to archive this.

## Converting hg to git repositories

> No worries, this step can be omitted.

*mtmiller*, the maintainer of two unofficial Octave forks on
[GitLab](https://gitlab.com/mtmiller/octave)
end
[GitHub](https://github.com/mtmiller/octave),
[explained to me](https://lists.gnu.org/archive/html/octave-maintainers/2020-05/msg00050.html)
that he uses
[git-cinnabar](https://github.com/glandium/git-cinnabar)
to create and update these forks from the
[official GNU Octave Mercurial repository](https://www.octave.org/hg/octave).

In the
[`README.md` of git-cinnabar](https://github.com/glandium/git-cinnabar/blob/master/README.md)
and by own research on the web,
I found that there are many tools for this purpose.

I gave it a short try myself after installing *git-cinnabar*:

```bash
hg  clone https://www.octave.org/hg/octave octave-hg
# The following is a git-cinnabar extension
git clone hg::octave-hg octave-git
```
But I continue to use the solution from *mtmiller* as upstream
to not duplicate efforts.


## Applying GitLab "merge requests"<sup>(*)</sup> to Mercurial

> <sup>(*)</sup>For those who are more familiar with GitHub, GitLab
> ["merge requests" are "pull requests"](https://stackoverflow.com/a/29951658/3778706)
> in GitHub slang.

First, I created a fork `https://gitlab.com/siko1056/octave` of
[*mtmiller*'s upstream repository](https://gitlab.com/mtmiller/octave)
on GitLab.

In my fork, I used the online editor from GitLab, to make a meaningless change
on the "master" branch and created a
[merge request](https://gitlab.com/mtmiller/octave/-/merge_requests/2)
to *mtmiller*'s upstream repository at GitLab.

This "merge requests" or
[individual commits](https://docs.gitlab.com/ee/user/project/merge_requests/cherry_pick_changes.html)
can be conveniently exported to patches from GitLab,
without cloning the whole Octave fork, adding other remotes, etc.
See the picture below showing the "merge request" view
and how to download the associated patch.

![gitlab export patch](/assets/blog/2020-06-17_gitlab_export_patch.png)

Unfortunately, this export button does not exist in GitHub.
A nice trick that works for GitLab and GitHub is to append `.patch`
the commit ID in the URL, e.g.
```
https://gitlab.com/siko1056/octave/-/commit/4d43501fc2a442b179b2327ad8379a19d224323c.patch
```
This automatically generates a git patch
and this feature can nicely be exploited by tools like `wget` or `curl`
or be **posted on Octave's patch tracker**.

Finally, I saved the exported git patch as `bug-42424-git.patch` on my machine.

> **Applying git patches to Mercurial works almost perfect!**

Only the second blank line in the commit message gets stripped,
which is part of
[Octave's guidelines](https://wiki.octave.org/Commit_message_guidelines).
Thus for importing git patches it is recommended to add `--edit` option
```
hg import --edit bug-42424-git.patch
```
to directly fix the commit message,
or to call `hg commit --amend` after the import succeeded.

Basically, that is it.


# Can the conversion be better/easier?

>*The short answer is: Not really.*

In case a genuine Mercurial patch is needed,
I did not find a great tool to convert git to hg patches.
I succeeded using
[moz-git-tools](https://github.com/mozilla/moz-git-tools/)
and shortly explain what I did.
But for me this is not the "easy way" to go.

One can either obtain the git patch as described above,
or by cloning the GitLab fork:
```bash
git clone https://gitlab.com/siko1056/octave.git octave-git
cd octave-git
git format-patch -1 HEAD --stdout > ../bug-42424-git.patch
cd ..
cp bug-42424-git.patch bug-42424-hg.patch
git-patch-to-hg-patch  bug-42424-hg.patch  # moz-git-tools
```

Going to the Octave Mercurial clone to apply the converted patch preserves
the newline in the commit message.
```bash
hg clone https://www.octave.org/hg/octave octave-hg
cd octave-hg
hg patch ../bug-42424-hg.patch
```

Finally, I exported the imported patch again to get an impression about the
"quality" of the conversion.
```bash
hg export > ../bug-42424-real-hg.patch
```
The differences between all patches can be seen in
[this large picture](/assets/blog/2020-06-17_git_hg_patch.png).

## Summary

- Octave development using GitLab/GitHub is possible.
- Sending Octave developers git patches is perfectly fine.
  Their application is as easy as genuine hg patches
  (except for the blank second line).
- Using an intermediate conversion from git to hg patches is not worth the pain.

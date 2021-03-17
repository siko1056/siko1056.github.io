---
layout: post
title:  "SavannahAPI - A more systematic overview about bugs and patches"
date: 2021-03-17
categories: blog
image: /assets/blog/2021-03-17-SavannahAPI_client.png
tags:
  - octave
---

The [GNU Octave](https://octave.org) project is registered on the code hosting
platform [GNU Savannah](https://savannah.gnu.org/) since April 2002.
With about 10,000 of 60,000 bugs,
Octave is one of its biggest and most active users.
However, the issue tracker interface has some limitations
and valuable information is not as accessible as it can be.
A [data scraping](https://en.wikipedia.org/wiki/Web_scraping) approach
[SavannahAPI](https://github.com/gnu-octave/SavannahAPI)
overcomes some of these limitations
and offers interesting new insights and overviews.


## The SavannahAPI interface

First and most important: SavannahAPI is **not** a new GNU Savannah.
SavannahAPI only provides improved **read access** to the issues
(bugs and patches) for a particular GNU Savannah project.
There is no possibility to edit or modify issues,
neither it has a user or account management.

For an interface description, see the
[project README.md on GitHub](https://github.com/gnu-octave/SavannahAPI).

[![JavaScript client](/assets/blog/2021-03-17-SavannahAPI_client.png)](https://octave.space/savannah/)

While working on the Octave project with GNU Savannah for a few years,
I often felt a **lack of overview** about the ever growing number of bugs.
Now (March 2021) there are more than 10,000 issues (bugs and patches)
accumulated in a time span of more than 10 years.

Some specific points that I missed with GNU Savannah are:


### 1. Search over all issues (bugs and patches)

The Savannah issue trackers are divided into bugs, patches, and tasks.
The latter tracker is not really used by the Octave project.
Thus searching for a keyword (e.g. "fminsearch")
involves at least two separate searches
[on the bugs](https://savannah.gnu.org/search/?Search=Search&words=fminsearch&type_of_search=bugs&only_group_id=1925&exact=1&max_rows=25#options)
and
[on the patch](https://savannah.gnu.org/search/?Search=Search&words=fminsearch&type_of_search=patch&only_group_id=1925&exact=1&max_rows=25#options)
tracker.

> **SavannahAPI** does not distinguish between bugs or patches.
> [A single search is enough.](https://octave.space/savannah/?Action=get&Format=HTMLCSS&OrderBy=TrackerID,!ItemID&Keywords=fminsearch)


### 2. Search - Is it already fixed?

The first point almost leads to this one.
Even if your search for a keyword succeeded, for example
["fminsearch" on the bugs tracker](https://savannah.gnu.org/search/?Search=Search&words=fminsearch&type_of_search=bugs&only_group_id=1925&exact=1&max_rows=25#options),
how should one know (except for clicking on each and every search hit)
that this issue is open or closed?

This seemingly unnecessary information (open or closed) is often interesting
when touching an Octave function for changes, because:
- one gets to know something else is wrong with "fminsearch", for example,
  and some unexpected results are not necessarily my fault.
- one can simultaneously incorporate smaller changes or patches into own changes.

> **SavannahAPI**
> [shows (almost) all bug information by default](https://octave.space/savannah/?Action=get&Format=HTMLCSS&OrderBy=TrackerID,!ItemID&Keywords=fminsearch),
> especially green and red color indicators.
> Unnecessary information can be filtered out and search results
> further narrowed down.

### 3. Browse - Getting issues by categories (predicates)

Despite keyword searches Savannah offers "browsing" issues.
That is selecting a single or multiple predicates from some predicate groups

- status (none, fixed, patch submitted, ...)
- item group (none, regression, build failure, ...)
- ...

to narrow down the set of displayed issues.

Getting a useful combination of those predicates is an art.
For example, to find
[all Octave bugs related to the release 6 (6.1.0, 6.2.0)](https://savannah.gnu.org/bugs/index.php?go_report=Apply&group=octave&func=browse&set=custom&msort=0&report_id=221&advsrch=1&resolution_id%5B%5D=0&bug_group_id%5B%5D=0&status_id%5B%5D=1&priority%5B%5D=0&severity%5B%5D=0&category_id%5B%5D=100&category_id%5B%5D=110&category_id%5B%5D=101&category_id%5B%5D=102&category_id%5B%5D=104&category_id%5B%5D=105&category_id%5B%5D=106&category_id%5B%5D=107&category_id%5B%5D=103&category_id%5B%5D=114&category_id%5B%5D=112&category_id%5B%5D=109&category_id%5B%5D=113&release_id%5B%5D=173&release_id%5B%5D=174&platform_version_id%5B%5D=0&history_search=0&history_field=0&history_event=modified&history_date_dayfd=25&history_date_monthfd=2&history_date_yearfd=2021&chunksz=100&spamscore=5&boxoptionwanted=1#options).

After several trials and errors clicking through the combo boxes,
excluding Octave Forge and Website related bugs,
you get presented some naked bug IDs.
There should be a [workaround](https://savannah.nongnu.org/support/?110340),
but this type of by admin customized searches do likely not satisfy the needs
of another user.

> **SavannahAPI** uses a
> [query language](https://github.com/gnu-octave/SavannahAPI#api-parameter-syntax-and-grammar)
> that is editable and readable from the URL query string,
> e.g. "all Octave bugs related to the release 6.x":
> [`Action=get&Format=HTMLCSS&OpenClosed=open&TrackerID=bugs` `&Category!=Forge,website&Release=6`](https://octave.space/savannah/?Action=get&Format=HTMLCSS&OpenClosed=open&TrackerID=bugs&Category!=Forge,website&Release=6)


### 4. Sharing information - a longer short history

The biggest motivation of creating SavannahAPI was probably the lack of
sharing information.

In the advent of an **Octave release**,
the most vital information is if there are important bugs to fix,
i.e. **"Severity >= 4"**.

Not long ago for Octave 5, the release manager used to create for this purpose
a wiki "Bug Fix List" <https://wiki.octave.org/Bug_Fix_List_-_5.0_Release>.
Needless to say, that maintaining highly dynamic bug information
without any automatic synchronization is very tedious duplicated work.
It almost leads the use of Savannah itself to absurdity.
(Why not posting the bugs directly to the wiki?)
But this information given on this wiki page was **easy to find, understand,**
**and share** with other Octave developers.
Three lessons that can be learned from this old habit:

> 1. Do things **automatically**.
> 2. Getting an **overview on a single page**.
> 3. Make information (permanently) **shareable** with other developers.

For the following painful long Octave 6 release (starting in December 2019),
I first thought about getting rid of this double listing habit (lesson [1])
by creating URLs pointing to the desired information using
the Savannah "browsing" feature:
<https://wiki.octave.org/6.1_Release_Checklist#Current_state_at_Savannah>
The result was a list of about nine links to Savannah
with horrible long and unreadable "magic" URLs,
e.g. for
["Severity >= 4"](https://savannah.gnu.org/bugs/index.php?go_report=Apply&group=octave&func=browse&set=custom&msort=0&report_id=101&advsrch=1&status_id%5B%5D=1&resolution_id%5B%5D=100&resolution_id%5B%5D=1&resolution_id%5B%5D=102&resolution_id%5B%5D=103&resolution_id%5B%5D=10&resolution_id%5B%5D=9&resolution_id%5B%5D=4&resolution_id%5B%5D=11&resolution_id%5B%5D=8&resolution_id%5B%5D=6&resolution_id%5B%5D=7&resolution_id%5B%5D=2&submitted_by%5B%5D=0&assigned_to%5B%5D=0&category_id%5B%5D=100&category_id%5B%5D=110&category_id%5B%5D=101&category_id%5B%5D=102&category_id%5B%5D=104&category_id%5B%5D=105&category_id%5B%5D=106&category_id%5B%5D=107&category_id%5B%5D=103&category_id%5B%5D=114&category_id%5B%5D=112&category_id%5B%5D=109&bug_group_id%5B%5D=0&severity%5B%5D=7&severity%5B%5D=8&severity%5B%5D=9&priority%5B%5D=0&summary=&details=&sumORdet=0&history_search=0&history_field=0&history_event=modified&history_date_dayfd=10&history_date_monthfd=12&history_date_yearfd=2019&chunksz=100&spamscore=5&boxoptionwanted=1#options)
```
https://savannah.gnu.org/bugs/index.php?go_report=Apply&group=octave
  &func=browse&set=custom&msort=0&report_id=221&advsrch=1
  &resolution_id%5B%5D=0&bug_group_id%5B%5D=0&status_id%5B%5D=1
  &priority%5B%5D=0&severity%5B%5D=0&category_id%5B%5D=100
  &category_id%5B%5D=110&category_id%5B%5D=101&category_id%5B%5D=102
  &category_id%5B%5D=104&category_id%5B%5D=105&category_id%5B%5D=106
  &category_id%5B%5D=107&category_id%5B%5D=103&category_id%5B%5D=114
  &category_id%5B%5D=112&category_id%5B%5D=109&category_id%5B%5D=113
  &release_id%5B%5D=173&release_id%5B%5D=174
  &platform_version_id%5B%5D=0&history_search=0&history_field=0
  &history_event=modified&history_date_dayfd=25
  &history_date_monthfd=2&history_date_yearfd=2021&chunksz=100
  &spamscore=5&boxoptionwanted=1#options
```

> For comparison,
> the same query URL for **SavannahAPI** is shorter, more readable,
> and more handy to share
> (["Severity >= 4"](https://octave.space/savannah/?Action=get&Format=HTMLCSS&OpenClosed=open&TrackerID=bugs&Category!=Forge,website&Severity=4,5,6&Status!=Wont)):
> ```
> https://octave.space/savannah/?Action=get&Format=HTMLCSS
>   &OpenClosed=open&TrackerID=bugs&Category!=Forge,website
>   &Severity=4,5,6&Status!=Wont
> ```

But hidden behind a readable label, nobody has to worry about long URLs.
Still yet the "overview on a single page" problem (lesson [2])
was still present.
Nine clicks were still needed to obtain the desired overview
and I sometimes manually updated the bug count in the wiki
to avoid those clicks.

In October 2020,
while the painful long Octave 6 release was still pending,
I created a quick & dirty php tool called
["Release Burn Down Chart"](https://octave.discourse.group/t/remaining-items-for-the-6-1-release/350)
which completed lesson [2] by querying and combining
those Savannah browsing link results.
A big leap forward.

Finally, I polished up this tool by changing the way it synchronizes with
GNU Savannah (see next section) and introduced a
[query language](https://github.com/gnu-octave/SavannahAPI#api-parameter-syntax-and-grammar)
(see also the example in this and the previous section) to fulfill lesson [3].

In addition to this, a JavaScript web application allows to
flexibly save, edit, and sort an arbitrary number of "saved queries"
individually for the needs of a user.


## The project in detail

[![project overview](/assets/blog/2021-03-17-project_overview_thumb.jpg)](https://raw.githubusercontent.com/gnu-octave/SavannahAPI/main/doc/project_overview.jpg)

### Client-server model

A key idea to make this project flexible in its usage is to introduce a server,
which is able to process queries using a web API

- <https://octave.space/savannah/api.php>

and a JavaScript client which uses the API to present the query results
to the user

- <https://octave.space/savannah/>(index.html)

GNU Savannah does not have this server API layer.
It can only
[export all data](https://savannah.gnu.org/bugs/export.php?group=octave)
(70 MB) to a custom HTML-like format
or present a subset of the data as php generated HTML website
as described above.


### Synchronization with GNU Savannah

To stay in sync with GNU Savannah,
the server periodically [scrapes](https://en.wikipedia.org/wiki/Web_scraping)
the data from GNU Savannah and stores it in a **SQLite database**.
New items are scraped from the
["browse all items" view](https://savannah.gnu.org/bugs/?group=octave),
while updated items are found with the help of the
[mailing-list archive](https://lists.gnu.org/archive/html/octave-bug-tracker/).


## Summary - Many new possibilities

Having a copy of all issue tracker data,
it is very straight forward to create custom queries to obtain
a desired subset (or all) of this data in **various data formats** (HTML,
[JSON](https://en.wikipedia.org/wiki/JSON),
[CSV](https://en.wikipedia.org/wiki/Comma-separated_values)).

Thus SavannahAPI is also a **backup** of GNU Savannah
and enables a possible **exit strategy**,
once the GNU Octave project decides for another code hosting service.

Despite existing JavaScript web application,
the web API can be used by any **arbitrary client**,
e.g. from a GUI programmed in Octave language itself.

**Octave Forge** developers do not have to monitor the whole bug tracker,
they can query a subset of interest in the JavaScript web application,
or embed the table in their own website, e.g.

- io-package (all bugs):
  - <https://octave.space/savannah/?[octave%20forge]%20(io)>
  - <https://octave.space/savannah/api.php?Action=get&Format=HTMLCSS&Title=[octave%20forge]%20(io)>
- io-package (all open bugs):
  - <https://octave.space/savannah/?Action=get&Format=HTMLCSS&Title=[octave%20forge]%20(io)&OpenClosed=open>
  - <https://octave.space/savannah/api.php?Action=get&Format=HTMLCSS&Title=[octave%20forge]%20(io)&OpenClosed=open>

Similarly, all other kind of **permalinks** to dynamic content can be created
and shared.
For example do you want to join a code-sprint on three particular bugs?
- <https://octave.space/savannah/?Action=get&Format=HTMLCSS&ItemID=60245,60237,60236>

Any feedback on [GitHub](https://github.com/gnu-octave/SavannahAPI) or
[Octave Discourse](https://octave.discourse.group/) is very welcome.

Enjoy using SavannahAPI.

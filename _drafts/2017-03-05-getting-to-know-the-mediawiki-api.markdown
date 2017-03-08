---
layout: post
title:  "Getting to know the MediaWiki API"
date:   2017-03-05
categories: blog
---

This article is a short introduction to the
[MediaWiki action API](https://www.mediawiki.org/wiki/API:Main_page),
in the following just called *API*.
The *API* enables one to edit and upload content to a MediaWiki
without using the web interface by simple
[HTTP *GET* and *POST* requests](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods),
for example issued by the command-line tool
[cURL](https://en.wikipedia.org/wiki/CURL).


# Prerequisites and preparation

It is assumed,
that a successful
[MediaWiki installation](https://www.mediawiki.org/wiki/Manual:Installation_guide)
is deployed at some location,
say `/public/http/wiki`,
on your server and is available online
via some address like `https://www.your-url.com/wiki`.
The subdirectory `/wiki` is called *WIKI* here.
Online or server access becomes clear from the context.
To activate the *API*,
just add the line
[`$wgEnableAPI = true;`](https://www.mediawiki.org/wiki/Special:MyLanguage/Manual:$wgEnableAPI)
in your Wiki's
[`WIKI/LocalSettings.php`](https://www.mediawiki.org/wiki/Special:MyLanguage/Manual:LocalSettings.php).
By doing this,
online access to `WIKI/api.php` becomes active
and target #1 is about to happen.


# Target #1: login

The login process consists of two steps:

* get a login token and
* sent login data and get a session cookie.

As cookies are involved in this process,
*cURL* needs to read and write then to a *COOKIE_JAR*,
an arbitrary temporary file,
see [--cookie](https://curl.haxx.se/docs/manpage.html#-c)
and [--cookie-jar](https://curl.haxx.se/docs/manpage.html#-c)
for details.

The first step can be performed by a simple
[login token](https://www.mediawiki.org/wiki/API:Tokens) GET request:

```
curl --cookie COOKIE_JAR \
     --cookie-jar COOKIE_JAR \
     WIKI/api.php?action=query&meta=tokens&type=login&format=json
```

The triple of GET parameters `action=query`, `meta=tokens`, and `type=login`
tells the *API* that a login token is requested and `format=json` specifies
the [output format](https://www.mediawiki.org/wiki/API:Data_formats#Output)
for the request,
in this case [JSON](https://en.wikipedia.org/wiki/JSON),
but other formats are possible as well.

The ([jq](https://stedolan.github.io/jq) formatted) output looks like:

```
{
  "batchcomplete": "",
  "query": {
    "tokens": {
      "logintoken": "d4d36d04151295044920ee32179ea9b558bfcf35+\\"
    }
  }
}
```

and one has to filter out the login token,
for example with the regular expression
`sed -n 's/.*"logintoken":"\(\S\+\)\+\\".*/\1/p'`

# Target #2: page update


csrf (cross-site request forgery) token

```
Login (1/2): Get login token...
    SUCCESS: token is: 9b3edab39b6f42dd08ad00c7c502cb5858bfbf79+\
Login (2/2): Logging in...
    SUCCESS: logged in as Siko1056

Edit (1/3): Get edit token...
    SUCCESS: token is: 5d7ab82c0359e60b675184ad6709fcf458bfbfba+\
```

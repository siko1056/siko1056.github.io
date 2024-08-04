# Getting to know the MediaWiki API

> Created: 2017-03-10

This article is a short introduction to the
[MediaWiki action API](https://www.mediawiki.org/wiki/API:Main_page),
in the following just called *API*.
The *API* enables to edit and upload content to a MediaWiki by simple
[HTTP *GET* and *POST* requests](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods),
for example issued by the command-line tool
[cURL](https://en.wikipedia.org/wiki/CURL),
without using the standard web interface.


## Prerequisites and preparation

It is assumed,
that a successful
[MediaWiki installation](https://www.mediawiki.org/wiki/Manual:Installation_guide)
is deployed at some location,
say `/public/http/wiki`,
on a server and is available online
via some address like `https://www.your-url.com/wiki`.
By *WIKI* the subdirectory `/wiki` is addressed,
accessed via either mentioned method that becomes clear from the context.
To activate the *API*,
the line
[`$wgEnableAPI = true;`](https://www.mediawiki.org/wiki/Special:MyLanguage/Manual:$wgEnableAPI)
has to be added to
[`WIKI/LocalSettings.php`](https://www.mediawiki.org/wiki/Special:MyLanguage/Manual:LocalSettings.php).
By doing this,
online access to `WIKI/api.php` becomes active
and Target #1 is about to happen.


## Target #1: Login

The login process consists of two steps:

1. get a login token and
2. perform a *clientlogin* to get session cookies.

As cookies are involved in this process,
*cURL* needs to read and write them to a *COOKIE_JAR*,
an arbitrary temporary file,
see [--cookie](https://curl.haxx.se/docs/manpage.html#-c)
and [--cookie-jar](https://curl.haxx.se/docs/manpage.html#-c)
for details.

The first step can be performed by a simple
[login token](https://www.mediawiki.org/wiki/API:Tokens) *GET* request:

```
curl --cookie COOKIE_JAR \
     --cookie-jar COOKIE_JAR \
     WIKI/api.php?action=query&meta=tokens&type=login&format=json
```

The triple of *GET* parameters `action=query`, `meta=tokens`, and `type=login`
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

From the received output one has to filter out the login token.
This can be done for example by using
[sed](https://www.gnu.org/software/sed/manual/sed.html)
with a regular expression:

```
sed -n 's/.*"logintoken":"\(\S\+\)\+\\".*/\1/p'
```

Note that a token consists of 40 alphanumeric characters
and the suffix `+\` (also `+\\` is returned).
In the example above the login token is
`d4d36d04151295044920ee32179ea9b558bfcf35+\`.

Now with the cookie and the login token,
one is able to perform a
[clientlogin action](https://www.mediawiki.org/wiki/API:Login#The_clientlogin_action).
For example using the following *cURL* command with a mix of
*GET* and *POST* parameters:

```
curl --cookie COOKIE_JAR \
     --cookie-jar COOKIE_JAR \
     --data-urlencode "username=User1" \
     --data-urlencode "password=TopSecret" \
     --data-urlencode "rememberMe=1" \
     --data-urlencode "logintoken=d4d36d04151295044920ee32179ea9b558bfcf35+\" \
     --data-urlencode "loginreturnurl=WIKI" \
     WIKI/api.php?action=clientlogin&format=json
```

In the command above,
special characters in the `name=content` data pairs can be handled by using
[--data-urlencode](https://curl.haxx.se/docs/manpage.html#--data-urlencode).
Those pairs are sent as *POST* data.
The successful ([jq](https://stedolan.github.io/jq) formatted) output is:

```
{
  "clientlogin": {
    "status": "PASS",
    "username": "User1"
  }
}
```

And in case of a typo,
one would receive instead:

```
{
  "clientlogin": {
    "status": "FAIL",
    "message": "The supplied credentials could not be authenticated."
  }
}
```

The session cookies are now properly set and Target #2 is within reach.



## Target #2: Page updates and file uploads

Again two steps are required:

1. get a [csrf](https://www.mediawiki.org/wiki/API:Tokens)
   (cross-site request forgery) token and
2. update page content or upload files.

The first step can be performed by another simple *GET* request.
Actually it is almost the same request as in Target #1,
but `type=login` is omitted and all session cookies are properly set:

```
curl --cookie COOKIE_JAR \
     --cookie-jar COOKIE_JAR \
     WIKI/api.php?action=query&meta=tokens&format=json
```

Again the *csrf* token can be filtered out by using
[sed](https://www.gnu.org/software/sed/manual/sed.html)
and a regular expression:

```
sed -n 's/.*"csrftoken":"\(\S\+\)\+\\".*/\1/p'
```

Say the received *csrf* token is `06cd0d427c1192fd13b20462018d768358c2a3c2+\`.



### Target #2.1: Page update

With the *csrf* token it is possible to update the content of a page.
For example to create a new page with title *"My first page"*
the *cURL* command looks like:

```
curl --cookie COOKIE_JAR \
     --cookie-jar COOKIE_JAR \
     --data-urlencode "title=My first page" \
     --data-urlencode "text=Hello world!" \
     --data-urlencode "token=06cd0d427c1192fd13b20462018d768358c2a3c2+\" \
     WIKI/api.php?action=edit&format=json
```

The successful ([jq](https://stedolan.github.io/jq) formatted) output is:

```
{
  "edit": {
    "new": "",
    "result": "Success",
    "pageid": 1,
    "title": "My first page",
    "contentmodel": "wikitext",
    "oldrevid": 0,
    "newrevid": 1,
    "newtimestamp": "2017-03-10T13:37:00Z"
  }
}
```

Issuing the same commands on an existing page of the MediaWiki,
the page content will be updated
and all changes are logged inside the history,
as if the user had used the standard edit web interface.



### Target #2.2: File upload

With the *csrf* token it is also possible to upload files.
A possible *cURL* command to upload the file `test-img.jpg`,
located at `/home/user1/test-img.jpg`,
is:

```
curl --cookie COOKIE_JAR \
     --cookie-jar COOKIE_JAR \
     --form "filename=test-img.jpg" \
     --form "file=@/home/user1/test-img.jpg" \
     --form "ignorewarnings=1" \
     --form "token=06cd0d427c1192fd13b20462018d768358c2a3c2+\" \
     WIKI/api.php?action=edit&format=json
```

To upload files to a MediaWiki,
*cURL* has to

> [...] emulate a filled-in form in which a user has pressed the submit button.
> This causes curl to POST data using the Content-Type multipart/form-data [...]

what can be done using [--form](https://curl.haxx.se/docs/manpage.html#-F).
The abbreviated ([jq](https://stedolan.github.io/jq) formatted) output
of a successful upload is:

```
{
  "upload": {
    "result": "Success",
    "filename": "Test-img.jpg",
  ...
}
```

Read more at https://www.mediawiki.org/wiki/API:Main_page.
The used *cURL* commands of this introduction are greatly inspired by
https://www.mediawiki.org/wiki/API:Client_code/Bash.

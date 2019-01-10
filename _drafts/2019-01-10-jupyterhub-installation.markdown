---
layout: post
title:  "Setting up JupyterHub on openSUSE Leap 15.0"
date: 2019-01-10
categories: blog
---

In a previous [blog post]({{ site.baseurl }}{% post_url 2018-06-25-apache2-leap-15-0 %}) the setup of the Apache2 webserver including [TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security) was explained.
Based upon that effort,
this blog post deals with the setup of [JupyterHub](https://github.com/jupyterhub),
a multi-user server for the single-user [Jupyter server](https://jupyter.org/).
The goal of using Jupyter is to create fancy looking interactive notebooks,
that are a great for explaining software
as they have builtin support for syntax-highlighing and,
thanks to [MathJax](https://www.mathjax.org/),
mathematics.

---
layout: post
title:  "Setting up JupyterHub on openSUSE Leap 15.0"
date: 2019-01-10
categories: blog
---

In a [previous blog post]({{ site.baseurl }}{% post_url 2018-06-25-apache2-leap-15-0 %})
the setup of the Apache2 webserver including
[TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security) was explained.
Based upon that effort,
this blog post deals with the setup of [JupyterHub](https://jupyter.org/hub).
The goal is to create fancy looking interactive
[GNU Octave](https://www.octave.org) notebooks,
that are a great for explaining software
as they have builtin support for syntax-highlighting and,
thanks to [MathJax](https://www.mathjax.org/),
mathematics.

Before we start, lets shortly review three
["Jupyter-terms"](https://jupyter.org/documentation)
often mentioned in this blog post:

- **Jupyter**:
  - A single-user [Jupyter server](https://jupyter.org/) that can also be
    [installed](https://jupyter.readthedocs.io/en/latest/install.html)
    and run locally on your own machine.
  - The [classical](https://jupyter-notebook.readthedocs.io/en/stable/notebook.html)
    user (notebook) interface (a.k.a. `/tree` see later why).

- Jupyter**Lab**:
  - The [modern](https://jupyterlab.readthedocs.io/) user (notebook) interface
    (a.k.a. `/lab`).

- Jupyter**Hub**:
  - A multi-user [Jupyter server](https://jupyterhub.readthedocs.io/).

In one sentence,
the goal is to setup a public JupyterHub-Server to run for authenticated users
a Jupyter instance with the modern JupyterLab interface.


## Install required Python-software

The installation might require admin (`sudo`) privileges:

```bash
pip3 install --upgrade pip jupyterlab \
                           jupyterhub \
                           oauthenticator \
                           octave_kernel
```

Finally,
one can check the installation by starting a local Jupyter server
with the JupyterLab interface:

```python
jupyter lab
```


## Configuring the public JupyterHub server

In the intended setup all configuration files for the server are located at
`/srv/www/jupyterhub` and the server will be publicly reachable
via `https://www.domain.org:8888` as explained in a
[previous blog post]({{ site.baseurl }}{% post_url 2018-06-25-apache2-leap-15-0 %}).

A good starting point is to create a default configuration file
that can be modified:
```bash
cd /srv/www/jupyterhub
jupyterhub --generate-config -f jupyterhub_config.py
```

The following options must be changed in `jupyterhub_config.py` to achieve
the desired Jupyter-server:
- the port `c.JupyterHub.port = 8888`,
- the location of the TLS-keys which are already established for the
  Apache2 webserver
  ```python
  c.JupyterHub.ssl_cert = '/etc/certbot/live/domain.org/fullchain.pem'
  c.JupyterHub.ssl_key = '/etc/certbot/live/domain.org/privkey.pem'
  ```
- and the usage of the modern JupyterLab interface
  ```python
  c.Spawner.cmd = ['jupyter-labhub']
  c.Spawner.default_url = '/lab'
  ```

Now one can test the public installation by starting JupyterHub with the
custom configuration:
```bash
jupyterhub --config=/srv/www/jupyterhub/jupyterhub_config.py
```


## Authenticate users

By default JupyterHub uses the access control mechanism by the operating system.
The used authentication mechanism is handled by the `authenticator_class`.
The default is the [PAMAuthenticator](https://jupyterhub.readthedocs.io/en/stable/api/auth.html):
```python
c.JupyterHub.authenticator_class = 'jupyterhub.auth.PAMAuthenticator'
```

```python
c.Authenticator.admin_users = {'localUser'}
c.Authenticator.whitelist = {'localUser'}
```

The problem here is that I don't want users to login on my server,
e.g. in JupyterHub, via password.
Fortunately, there a different authentication mechanisms via OAuth2 available:

For GitHub OAuth Authentication

```python
from oauthenticator.github import GitHubOAuthenticator
c.JupyterHub.authenticator_class = GitHubOAuthenticator
c.GitHubOAuthenticator.oauth_callback_url = 'https://domain.org:8888/hub/oauth_callback'
c.GitHubOAuthenticator.client_id = 'xxxxxxxxxxxxxxxxxxxxxx'
c.GitHubOAuthenticator.client_secret = 'xxxxxxxxxxxxxxxxxx'
```

For Google OAuth Authentication

```python
from oauthenticator.google import GoogleOAuthenticator
c.JupyterHub.authenticator_class = GoogleOAuthenticator
c.GoogleOAuthenticator.oauth_callback_url = 'https://domain.org:8888/hub/oauth_callback'
c.GoogleOAuthenticator.client_id = 'xxxxxxxxxxxxxxxxxxxxxx'
c.GoogleOAuthenticator.client_secret = 'xxxxxxxxxxxxxxxxxx'
```

```python
c.Authenticator.username_map = {'local.user@gmail.com': 'localUser'}
```

## Making JupyterHub a system service

The final target is to make the JupyterHub server run,
even if you are logged out from your remote server.

There are other options such as running JupyterHub in a
[screen](https://www.gnu.org/software/screen/)-session
that does not shutdown when the connection to the server is terminated.
But personally I prefer the solution of creating a system service:

1. A service starts after each reboot when enabled.
2. A service can be logged by `syslog`.
3. A service runs in the background and cannot accidentally be shutdown
   while maintaining the system.

To create a service, just create a file `/srv/www/jupyterhub/jupyterhub.service`
with the following content:

```
[Unit]
Description=JupyterHub
After=network.target nss-lookup.target

[Service]
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=jupyterhub
ExecStart=/usr/bin/jupyterhub --config=/srv/www/jupyterhub/jupyterhub_config.py
WorkingDirectory=/srv/www/jupyterhub

[Install]
WantedBy=multi-user.target
```

The service has to be linked to the standard location and the file
should be owned by `root`:
```bash
sudo chown root:root /srv/www/jupyterhub/jupyterhub.service
cd /etc/systemd/system/
sudo ln -s /srv/www/jupyterhub/jupyterhub.service
```

Now one can use the standard mechanisms to start and stop JupyterHub
as system service:
```bash
sudo systemctl enable jupyterhub  # Start service at system boot.
sudo systemctl start  jupyterhub
sudo systemctl stop   jupyterhub
```
and the log can be inspected by
```bash
sudo journalctl -u jupyterhub
```


## Further reading

This blog post was greatly inspired by
<https://pythonforundergradengineers.com/add-google-oauth-and-system-service-to-jupyterhub.html>

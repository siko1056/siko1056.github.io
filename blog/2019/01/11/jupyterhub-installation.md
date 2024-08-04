# Setting up JupyterHub on openSUSE Leap 15.0

> Created: 2019-01-11

In a [previous blog post](../../../2018/06/25/apache2-leap-15-0.md)
the setup of the Apache2 webserver including
[TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security) was explained.
Based upon that effort,
this blog post deals with the setup of [JupyterHub](https://jupyter.org/hub).
The goal is to create an online development environment for fancy looking
interactive [GNU Octave](https://www.octave.org) notebooks.
Those are a great tool for explaining mathematical code and software
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
    user (notebook) interface (a.k.a. `/tree`, see later why).

- Jupyter**Lab**:
  - The [modern](https://jupyterlab.readthedocs.io/) user (notebook) interface
    (a.k.a. `/lab`).

- Jupyter**Hub**:
  - A multi-user [Jupyter server](https://jupyterhub.readthedocs.io/).

In one sentence,
the goal is to setup a public JupyterHub-Server
to run for certain predefined small group of users
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
one can check the installation by starting a local single-user Jupyter server
with the JupyterLab interface:
```bash
jupyter lab
```


## Configuring the public JupyterHub server

In the desired setup all configuration files for the server are located at
`/srv/www/jupyterhub` and the server should be accessible by the public
via `https://www.domain.org:8888` as explained in a
[previous blog post](../../../2018/06/25/apache2-leap-15-0.md).

A good starting point is to create a default configuration file
that can be modified:
```bash
cd /srv/www/jupyterhub
jupyterhub --generate-config -f jupyterhub_config.py
```

The following options must be changed in `jupyterhub_config.py` to achieve
the desired JupyterHub-server setup:
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

If you want to give the classical notebook interface a try,
just replace `/lab` by `/tree`:
```
https://domain.org:8888/user/localUser/lab?
                                      /tree?
```


## Authenticate users

In general JupyterHub delegates the user authentication to some `authenticator_class`.
By default this is the
[PAMAuthenticator](https://jupyterhub.readthedocs.io/en/stable/api/auth.html),
that just makes use of the authentication mechanism
of the underlying server operating system:
```python
c.JupyterHub.authenticator_class = 'jupyterhub.auth.PAMAuthenticator'
```
This has a serious impact:
One does not only login to some sandboxed PHP-application (like a MediaWiki),
one literally logs into the server!
From Jupyter you can start a terminal window
and can do any damage you could do from a ssh-login with your given user permissions.
Keep this in mind.

If the desired setup demands more security,
one should run Jupyter within some virtualization environment.
But for my purpose using Docker, Kubernetes, or alike seems too bloated
for a couple of predefined users.

To further control and restrict the user authentication,
JupyterHub offers features such as a whitelist and a list of admin users:
```python
c.Authenticator.admin_users = {'localUser'}
c.Authenticator.whitelist = {'localUser', 'localUser2'}
```
For more options, see <https://jupyterhub.readthedocs.io/en/stable/api/auth.html>.
Unfortunately, those lists
[cannot be altered at runtime](https://github.com/jupyterhub/jupyterhub/issues/1920).
Of course one can create custom Python-classes, if needed.

Another problem is that I don't want users to login on my server via password at all.
Fortunately, [OAuthenticator](https://github.com/jupyterhub/oauthenticator)
provides several OAuth 2.0 based `authenticator_class`es.
Among them:

- GitHub
  ```python
  from oauthenticator.github import GitHubOAuthenticator
  c.JupyterHub.authenticator_class = GitHubOAuthenticator
  c.GitHubOAuthenticator.oauth_callback_url = 'https://domain.org:8888/hub/oauth_callback'
  c.GitHubOAuthenticator.client_id = 'xxxxxxxxxxxxxxxxxxxxxx'
  c.GitHubOAuthenticator.client_secret = 'xxxxxxxxxxxxxxxxxx'
  ```

- Google
  ```python
  from oauthenticator.google import GoogleOAuthenticator
  c.JupyterHub.authenticator_class = GoogleOAuthenticator
  c.GoogleOAuthenticator.oauth_callback_url = 'https://domain.org:8888/hub/oauth_callback'
  c.GoogleOAuthenticator.client_id = 'xxxxxxxxxxxxxxxxxxxxxx'
  c.GoogleOAuthenticator.client_secret = 'xxxxxxxxxxxxxxxxxx'
  ```

Especially for Google it makes sense to map the authenticated user
to a local server account:
```python
c.Authenticator.username_map = {'local.user@gmail.com': 'localUser'}
```
But again,
this map cannot be altered without restarting the JupyterHub server.

To sum up:
New users (for example new colleagues) cannot be created on the fly
by using the here described setup.
This requires:

1. Creating a new local user account on the server
   ```bash
   useradd --create-home --gid jupyterhub <new colleague>
   ```
2. whitelist that local user account `c.Authenticator.whitelist`.
3. Map that local user account to the OAuth 2.0 authenticated user name
   `c.Authenticator.username_map`.
4. Restart JupytherHub.

On the other hand,
not every user with a valid GitHub or Google account can log in the server.


## Making JupyterHub a system service

The final target is to make the JupyterHub server run,
even if you are logged out from your remote server.

There are other options such as running JupyterHub inside a
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
After=apache2.target

[Service]
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=jupyterhub
ExecStart=/usr/bin/jupyterhub --config=/srv/www/jupyterhub/jupyterhub_config.py
WorkingDirectory=/srv/www/jupyterhub

[Install]
WantedBy=multi-user.target
```

The service file has to be copied to the standard location
and the file should be owned by `root`:
```bash
sudo chown root:root /srv/www/jupyterhub/jupyterhub.service
sudo cp /srv/www/jupyterhub/jupyterhub.service /etc/systemd/system/jupyterhub.service
```

Now one can use the standard mechanisms to start and stop JupyterHub
as system service:
```bash
sudo systemctl enable jupyterhub  # Start service at system boot.
sudo systemctl start  jupyterhub
sudo systemctl stop   jupyterhub
```
and the server log can be inspected by
```bash
sudo journalctl -u jupyterhub
```


## Further reading

This blog post was greatly inspired by
<https://pythonforundergradengineers.com/add-google-oauth-and-system-service-to-jupyterhub.html>


## Update 2019-01-13

- In the file `/srv/www/jupyterhub/jupyterhub.service`
  ```diff
  [Unit]
  -After=network.target nss-lookup.target
  +After=apache2.target
  ```
  and rather copy that file to `/etc/systemd/system/` instead of just linking it.
  Occasionally I noticed that JupyterHub did not start automatically,
  as the location `/srv/www/jupyterhub/` was not available to systemd on time.

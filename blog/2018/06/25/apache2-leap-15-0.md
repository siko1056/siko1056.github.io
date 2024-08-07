# Setting up an apache2 webserver on openSUSE Leap 15.0

> Created: 2018-06-25

The goal of this blog post is to properly remember what I did to create my root-server setup using [openSUSE Leap 15.0](https://software.opensuse.org/distributions/leap):

- [Apache web server](https://httpd.apache.org/) with HTTPS support, running
  - Static websites
    - [MkDocs](https://www.mkdocs.org/)
  - Dynamic websites (PHP, mySQL)
    - [MediaWiki](https://www.mediawiki.org/)
- [Jupyterlab](https://jupyterlab.readthedocs.io/en/stable/)

Two detailed and very useful references for a start are:

- <https://en.opensuse.org/SDB:LAMP_setup>
- <https://en.opensuse.org/Let%E2%80%99s_Encrypt>
- <https://doc.opensuse.org/documentation/leap/reference/html/book.opensuse.reference/cha.apache2.html>

Here there are just the bare commands without verbose explanation given.
All of them should be run with root privileges.

## Basic webserver setup

- Install the required packages:

      zypper install apache2 \
                     php7 php7-mysql apache2-mod_php7 \
                     mariadb mariadb-tools \
                     phpMyAdmin

- Enable Apache modules:

      a2enmod php7 rewrite

- Open the necessary ports in the Firewall (`firewalld`):

      firewall-cmd --permanent --zone=public --add-service=http --add-service=https
      firewall-cmd --permanent --zone=public --add-port=8888/tcp  # For Jupyter only!
      firewall-cmd --reload

- Start and enable (on each restart) all services:

      systemctl start  apache2 mysql
      systemctl enable apache2 mysql

- Configure the mySQL database and follow the instructions given:

      mysql_secure_installation



## Setting up the directories

The used directory structure for the websites and services is as follows:

    /srv/www/myMkDocsSite  (https://www.domain.org/)
            /myMediaWiki   (https://wiki.domain.org/)
            /jupyter       (https://www.domain.org:8888)

As Jupyter comes with it's own web server, one only has to add Apache2 configurations for `myMkDocsSite` and `myMediaWiki`.
Those configuration files are located in the

    /etc/apache2/vhosts.d

directory and have the `*.conf` extension.
The `myMkDocsSite.conf` may look like this:

```
<VirtualHost *:80>
    DocumentRoot "/srv/www/myMkDocsSite"
    ServerName www.domain.org
    ServerAlias domain.org
    ServerAdmin joe@mail.com
    ErrorLog /var/log/apache2/error_log
    TransferLog /var/log/apache2/access_log
    HostnameLookups Off
    UseCanonicalName Off
    ServerSignature Off
    <Directory "/srv/www/octave.space">
        Options Indexes FollowSymLinks
        AllowOverride None
        <IfModule !mod_access_compat.c>
            Require all granted
        </IfModule>
        <IfModule mod_access_compat.c>
            Order allow,deny
            Allow from all
        </IfModule>
    </Directory>
</VirtualHost>
```

Remember, that for dynamic websites the Apache2 server process might need write privileges.
Therefore the owner of the respective directories should be `wwwrun` and can be set with:

    chown -R wwwrun:www <directory>

Now the content of a file `index.html` should be displayed when typing "http://www.domain.org/" (note: HTTPS comes later!).



## Webserver HTTPS setup

Fortunately, these days one has not to pay to be able to use the HTTPS protocol, one can easily make use of services like the [Let's encrypt](https://letsencrypt.org/) project.

- Install the required packages:

      zypper install certbot python-certbot python-certbot-apache

- Enable the SSL module and ensure the correct server flags:

      a2enmod ssl
      a2enflag SSL

- Get the certificate by following the output of:

      certbot --apache

  This command usually updates the Apache2 configuration file, e.g. `myMkDocsSite.conf` above.
  If there are more websites, just call the `certbot` command above again to extend the certificate.

- Update the certificate regulary by establishing a cronjob:

      crontab -e

  and add the lines:

      # renew all certificates methode: renew
      10 5 1 * *  root    /usr/bin/certbot renew

## Mediawiki setup

To setup a [Mediawiki](https://www.mediawiki.org/) one can basically follow the [installation guide](https://www.mediawiki.org/wiki/Installation).
Additionally, the following extensions should be installed:

- <https://www.mediawiki.org/wiki/Extension:MobileFrontend>
- <https://www.mediawiki.org/wiki/Extension:Math>

With openSUSE Leap, the following extra packages are useful to be installed for all the above:

    zypper install git ImageMagick make \
                   php7-APCu php7-fileinfo php7-imagick php7-intl php7-mbstring

After that run

    php myMediaWiki/maintenance/update.php

to update the MediaWiki database for that extension.

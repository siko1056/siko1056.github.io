---
layout: post
title:  "Protect your server using fail2ban"
date: 2019-02-07
categories: blog
tags:
  - software
---

While reading the
[system journal](https://doc.opensuse.org/documentation/leap/reference/html/book.opensuse.reference/cha.journalctl.html)
of my server,
I noticed a bunch of evil looking entries
and finally found in the Python tool [fail2ban](https://www.fail2ban.org/)
a satisfying but not an overall answer to the problem.

The system journal can be inspected by:

```
$ sudo journalctl -r

Feb 07 14:29:45 dummy sshd[763]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=XXX.XX.X.XXX  user=root
Feb 07 14:29:45 dummy sshd[764]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=YY.YYY.YY.YY  user=root
Feb 07 14:29:47 dummy sshd[760]: error: PAM: Authentication failure for root from XXX.XX.X.XXX
Feb 07 14:29:47 dummy sshd[758]: error: PAM: Authentication failure for root from YY.YYY.YY.YY
Feb 07 14:29:48 dummy sshd[765]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=YY.YYY.YY.YY  user=root
Feb 07 14:29:48 dummy sshd[766]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=XXX.XX.X.XXX  user=root
Feb 07 14:29:50 dummy sshd[758]: error: PAM: Authentication failure for root from YY.YYY.YY.YY
Feb 07 14:29:50 dummy sshd[760]: error: PAM: Authentication failure for root from XXX.XX.X.XXX
Feb 07 14:29:50 dummy sshd[767]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=YY.YYY.YY.YY  user=root
Feb 07 14:29:51 dummy sshd[768]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=XXX.XX.X.XXX  user=root
Feb 07 14:29:52 dummy sshd[758]: error: PAM: Authentication failure for root from YY.YYY.YY.YY
Feb 07 14:29:52 dummy sshd[758]: Received disconnect from YY.YYY.YY.YY port 58773:11:  [preauth]
Feb 07 14:29:52 dummy sshd[758]: Disconnected from authenticating user root YY.YYY.YY.YY port 58773 [preauth]
Feb 07 14:29:52 dummy sshd[760]: error: PAM: Authentication failure for root from XXX.XX.X.XXX
Feb 07 14:29:53 dummy sshd[760]: Postponed keyboard-interactive for root from XXX.XX.X.XXX port 19193 ssh2 [preauth]
Feb 07 14:29:53 dummy sshd[769]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=XXX.XX.X.XXX  user=root
Feb 07 14:29:56 dummy sshd[760]: error: PAM: Authentication failure for root from XXX.XX.X.XXX
Feb 07 14:29:56 dummy sshd[760]: Failed keyboard-interactive/pam for root from XXX.XX.X.XXX port 19193 ssh2
Feb 07 14:29:56 dummy sshd[760]: Postponed keyboard-interactive for root from XXX.XX.X.XXX port 19193 ssh2 [preauth]
```

Two hosts (later I noticed a few more),
lets call them `XXX.XX.X.XXX` and `YY.YYY.YY.YY` for now,
are permanently trying to log in to my server as root.

Using an arbitrary
[IP-Address lookup service](https://www.whatismyip.com/ip-address-lookup/),
I was told be attacked from hosts in Asia.
The country was reported as well,
but it does not matter for this blog post.
In my opinion the worth of this information is doubtful anyways.


But for now,
I write about what I did and what prevented greater damage so far:

A good decision at server setup was to only permit logins via
[public-key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography)
and not passwords.
Especially `root` should **never** be able to login by a plain `ssh` command!
To achieve this,
the following entries are set in `/etc/ssh/sshd_config`:

```
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
```

This is in my opinion the most important layer of defense
against brute force attacks.
But as my system journal reveals,
this is by far not enough.
I don't want my server to waste time with brute force attacks.
It should simply ignore any communication with them.

A promising approach without writing black- or whitelists on my own
is the Python software [fail2ban](https://www.fail2ban.org/).
Like the name suggests,
too many failed login attempts (= brute force attacks) automatically
result in a permanent ban from my server.
In general I consulted three sources for the *fail2ban* setup:

* <https://www.2daygeek.com/how-to-install-setup-configure-fail2ban-on-linux/>
* <https://www.fail2ban.org/wiki/index.php/HOWTOs>
* <https://www.fail2ban.org/wiki/index.php/MANUAL_0_8>

First one has to install the software.
*openSUSE* makes this task pretty comfortable by typing


```
sudo zypper in fail2ban
```

Then I edited as `root` the configuration file `/etc/fail2ban/jail.local`:

```
# Do all your modifications to the jail's configuration in jail.local!

[DEFAULT]
bantime = 1d

# SSH servers
[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
```

and finally started the already available service:

```
sudo systemctl start fail2ban.service
```

Now each suspicious login behavior will result in a one day `1d` ban.
To verify this theory,
there are several ways to check.
The first method is to read the *fail2ban* log:

```
$ sudo cat /var/log/fail2ban.log

2019-02-04 16:39:40,379 fail2ban.server         [2885]: INFO    --------------------------------------------------
2019-02-04 16:39:40,379 fail2ban.server         [2885]: INFO    Starting Fail2ban v0.10.3.fix1
2019-02-04 16:39:40,385 fail2ban.database       [2885]: INFO    Connected to fail2ban persistent database '/var/lib/fail2ban/fail2ban.sqlite3'
2019-02-04 16:39:40,386 fail2ban.database       [2885]: WARNING New database created. Version '2'
2019-02-07 14:31:02,652 fail2ban.server         [2885]: INFO    Shutdown in progress...
2019-02-07 14:31:02,652 fail2ban.server         [2885]: INFO    Stopping all jails
2019-02-07 14:31:02,652 fail2ban.database       [2885]: INFO    Connection to database closed.
2019-02-07 14:31:02,652 fail2ban.server         [2885]: INFO    Exiting Fail2ban
2019-02-07 14:31:02,737 fail2ban.server         [907]: INFO    --------------------------------------------------
2019-02-07 14:31:02,737 fail2ban.server         [907]: INFO    Starting Fail2ban v0.10.3.fix1
2019-02-07 14:31:02,739 fail2ban.database       [907]: INFO    Connected to fail2ban persistent database '/var/lib/fail2ban/fail2ban.sqlite3'
2019-02-07 14:31:02,740 fail2ban.jail           [907]: INFO    Creating new jail 'sshd'
2019-02-07 14:31:02,747 fail2ban.jail           [907]: INFO    Jail 'sshd' uses systemd {}
2019-02-07 14:31:02,748 fail2ban.jail           [907]: INFO    Initiated 'systemd' backend
2019-02-07 14:31:02,748 fail2ban.filter         [907]: INFO      maxLines: 1
2019-02-07 14:31:02,773 fail2ban.filtersystemd  [907]: INFO    [sshd] Added journal match for: '_SYSTEMD_UNIT=sshd.service + _COMM=sshd'
2019-02-07 14:31:02,773 fail2ban.filter         [907]: INFO      maxRetry: 5
2019-02-07 14:31:02,774 fail2ban.filter         [907]: INFO      encoding: UTF-8
2019-02-07 14:31:02,774 fail2ban.actions        [907]: INFO      banTime: 86400
2019-02-07 14:31:02,774 fail2ban.filter         [907]: INFO      findtime: 600
2019-02-07 14:31:02,776 fail2ban.jail           [907]: INFO    Jail 'sshd' started
2019-02-07 14:31:02,796 fail2ban.filter         [907]: INFO    [sshd] Found YY.YYY.YY.YY - 2019-02-07 14:21:03
2019-02-07 14:31:02,797 fail2ban.filter         [907]: INFO    [sshd] Found XXX.XX.X.XXX - 2019-02-07 14:21:04
... many many lines like this ...
2019-02-07 14:31:02,976 fail2ban.actions        [907]: NOTICE  [sshd] Ban YY.YYY.YY.YY
2019-02-07 14:31:03,016 fail2ban.actions        [907]: NOTICE  [sshd] Ban XXX.XX.X.XXX
2019-02-07 14:31:03,022 fail2ban.actions        [907]: WARNING [sshd] YY.YYY.YY.YY already banned
2019-02-07 14:31:03,022 fail2ban.actions        [907]: WARNING [sshd] XXX.XX.X.XXX already banned
...
```

Et voilà,
`XXX.XX.X.XXX` and `YY.YYY.YY.YY` misbehaved and were banned! :smile:
To get even more trust and understanding in the *fail2ban* mechanism,
one can take a look at
[iptables](https://doc.opensuse.org/documentation/leap/security/html/book.security/cha.security.firewall.html#sec.security.firewall.iptables),
the system tool,
where *fail2ban* adds appropriate entries:

```
$ sudo iptables -L

...
Chain f2b-sshd (1 references)
target  prot  opt  source        destination
REJECT  all   --   YY.YYY.YY.YY  anywhere    reject-with icmp-port-unreachable
REJECT  all   --   XXX.XX.X.XXX  anywhere    reject-with icmp-port-unreachable
...
```

My system is of no such importance,
that I dare write about this attack to learn from it.
Maybe (and in case of critical systems hopefully) other system administrators
know better
and can teach me how to cope with such a delicate and mean situation.

All in all I hope not to be part of a botnet or similar right now
and that attackers no longer find my sever to be a patient listener :wink:

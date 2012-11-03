From: Jacek Konieczny <jajcus@jajcus.net>
Date: Sat,  3 Nov 2012 19:38:39 +0100
Subject: sd_notify support for clvmd
Message-ID: <1351967920-14881-1-git-send-email-jajcus@jajcus.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

The following patch adds sd_notify support to clvmd. I needed this because
systemd doesn't handle re-execing forking daemons well ('clvmd -S' would cause
systemd to kill the clvmd.service) and just using the '-f' option to clvmd
to run in foreground would mean loosing any startup notification.

Even if not this re-exec problem, running clvmd in the foreground and reporting
via sd_notify still is probably the preferable way to run it under systemd.

The sd_notify support will be enabled whenever libsystemd-daemon library is
available, unless explicitly disabled via '--disable-sd-notify' configure
option.

To use this feature, use the following in the clvmd.service file:

[Service]
Type=notify
NotifyAccess=main
ExecStart=/usr/sbin/clvmd -f $CLVMDOPTS

There is one limitation: the -T<secs> (startup timeout) function is not
effective when clvmd runs in foreground. I was thinking about re-implementing
it with a thread calling sd_notify() after sleep(), but this would complicate
the patch a lot.

Greets
	Jacek



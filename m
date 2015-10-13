From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:54 +0000 (UTC)
Subject: master - man: dmeventd update
Message-ID: <20151013140354.9A72A61207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f03d46fc13be2274b3c29d4fc97a3306bc33eda
Commit:        3f03d46fc13be2274b3c29d4fc97a3306bc33eda
Parent:        0e2721030857088803bc71ccc27644b7b95241ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 12 11:35:53 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:15:43 2015 +0200

man: dmeventd update

---
 man/dmeventd.8.in |   92 +++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 65 insertions(+), 27 deletions(-)

diff --git a/man/dmeventd.8.in b/man/dmeventd.8.in
index 77bbafb..15e003b 100644
--- a/man/dmeventd.8.in
+++ b/man/dmeventd.8.in
@@ -1,7 +1,11 @@
 .TH DMEVENTD 8 "DM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.
 .SH NAME
+.
 dmeventd \(em Device-mapper event daemon
+.
 .SH SYNOPSIS
+.
 .B dmeventd
 .RB [ \-d
 .RB [ \-d
@@ -11,33 +15,53 @@ dmeventd \(em Device-mapper event daemon
 .RB [ \-R ]
 .RB [ \-V ]
 .RB [ \-? ]
+.
 .SH DESCRIPTION
+.
 dmeventd is the event monitoring daemon for device-mapper devices.
 Library plugins can register and carry out actions triggered when
 particular events occur.
-.SH
-LVM PLUGINS
-.TP
-.I Mirror
-Attempts to handle device failure automatically.  See \fBlvm.conf\fP(5).
-.TP
-.I Raid
-Attempts to handle device failure automatically.  See \fBlvm.conf\fP(5).
-.TP
-.I Snapshot
+.
+.SH LVM PLUGINS
+.
+.HP
+.IR Mirror
+.br
+Attempts to handle device failure automatically. See
+.BR lvm.conf (5).
+.
+.HP
+.IR Raid
+.br
+Attempts to handle device failure automatically. See
+.BR lvm.conf (5).
+.
+.HP
+.IR Snapshot
+.br
 Monitors how full a snapshot is becoming and emits a warning to
 syslog when it exceeds 80% full.
 The warning is repeated when 85%, 90% and 95% of the snapshot is filled.
-See \fBlvm.conf\fP(5).
-.TP
-.I Thin
-Monitors how full a thin pool is becoming and emits a warning to
-syslog when it exceeds 80% full.
+See
+.BR lvm.conf (5).
+Snapshot which runs out of space gets invalid and when it is mounted,
+it gets umounted if possible.
+.
+.HP
+.IR Thin
+.br
+Monitors how full a thin pool data and metadata is becoming and emits
+a warning to syslog when it exceeds 80% full.
 The warning is repeated when 85%, 90% and 95% of the thin pool is filled.
-See \fBlvm.conf\fP(5).
+See
+.BR lvm.conf (5).
+If the thin-pool runs out of space, thin volumes are umounted if possible.
+.
 .SH OPTIONS
-.TP
-.B \-d
+.
+.HP
+.BR \-d
+.br
 Repeat from 1 to 3 times (
 .BR \-d ,
 .BR \-dd ,
@@ -45,21 +69,35 @@ Repeat from 1 to 3 times (
 ) to increase the detail of
 debug messages sent to syslog.
 Each extra d adds more debugging information.
-.TP
-.B \-f
+.
+.HP
+.BR \-f
+.br
 Don't fork, run in the foreground.
-.TP
-.BR \-h ", " \-?
+.
+.HP
+.BR \-h
+.br
 Show help information.
-.TP
-.B \-R
+.
+.HP
+.BR \-?
+.br
+Show help information on stderr.
+.
+.HP
+.BR \-R
+.br
 Replace a running dmeventd instance. The running dmeventd must be version
 2.02.77 or newer. The new dmeventd instance will obtain a list of devices and
 events to monitor from the currently running daemon.
-.TP
-.B \-V
+.
+.HP
+.BR \-V
+.br
 Show version of dmeventd.
-
+.
 .SH SEE ALSO
+.
 .BR lvm (8),
 .BR lvm.conf (5)



From: saulery@free.fr <saulery@free.fr>
Date: Thu, 27 Nov 2014 02:32:39 +0100
Subject: Improve dmeventd.8 manpage
In-Reply-To: <1417051960-2920-1-git-send-email-saulery@free.fr>
References: <1417051960-2920-1-git-send-email-saulery@free.fr>
Message-ID: <1417051960-2920-3-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

- Keywords in bold
- Add syslog ref.
- Sort see also sections
- Adapt -d example
- Group -h and -?

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 daemons/dmeventd/dmeventd.c |  4 ++--
 man/dmeventd.8.in           | 28 +++++++++++++---------------
 2 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index e8d1e3b..c7ceeea 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -2119,10 +2119,10 @@ bad:
 static void usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-d [-d [-d]]] [-f] [-h] [-R] [-V] [-?]\n\n"
+		"%s [-d[d[d]]] [-f] [-h|-?] [-R] [-V]\n\n"
 		"   -d       Log debug messages to syslog (-d, -dd, -ddd)\n"
 		"   -f       Don't fork, run in the foreground\n"
-		"   -h -?    Show this help information\n"
+		"   -h, -?   Show this help information\n"
 		"   -R       Restart dmeventd\n"
 		"   -V       Show version of dmeventd\n\n", prog);
 }
diff --git a/man/dmeventd.8.in b/man/dmeventd.8.in
index 77bbafb..7b18f92 100644
--- a/man/dmeventd.8.in
+++ b/man/dmeventd.8.in
@@ -3,16 +3,13 @@
 dmeventd \(em Device-mapper event daemon
 .SH SYNOPSIS
 .B dmeventd
-.RB [ \-d
-.RB [ \-d
-.RB [ \-d ]]]
+.RB [ \-d "[" "d" "[" "d" "]]]"
 .RB [ \-f ]
-.RB [ \-h ]
+.RB [ \-h|\-? ]
 .RB [ \-R ]
 .RB [ \-V ]
-.RB [ \-? ]
 .SH DESCRIPTION
-dmeventd is the event monitoring daemon for device-mapper devices.
+\fBdmeventd\fP is the event monitoring daemon for device-mapper devices.
 Library plugins can register and carry out actions triggered when
 particular events occur.
 .SH
@@ -26,13 +23,13 @@ Attempts to handle device failure automatically.  See \fBlvm.conf\fP(5).
 .TP
 .I Snapshot
 Monitors how full a snapshot is becoming and emits a warning to
-syslog when it exceeds 80% full.
+\fBsyslog\fP(3) when it exceeds 80% full.
 The warning is repeated when 85%, 90% and 95% of the snapshot is filled.
 See \fBlvm.conf\fP(5).
 .TP
 .I Thin
 Monitors how full a thin pool is becoming and emits a warning to
-syslog when it exceeds 80% full.
+\fBsyslog\fP(3) when it exceeds 80% full.
 The warning is repeated when 85%, 90% and 95% of the thin pool is filled.
 See \fBlvm.conf\fP(5).
 .SH OPTIONS
@@ -43,8 +40,8 @@ Repeat from 1 to 3 times (
 .BR \-dd ,
 .BR \-ddd
 ) to increase the detail of
-debug messages sent to syslog.
-Each extra d adds more debugging information.
+debug messages sent to \fBsyslog\fP(3).
+Each extra \fBd\fP adds more debugging information.
 .TP
 .B \-f
 Don't fork, run in the foreground.
@@ -53,13 +50,14 @@ Don't fork, run in the foreground.
 Show help information.
 .TP
 .B \-R
-Replace a running dmeventd instance. The running dmeventd must be version
-2.02.77 or newer. The new dmeventd instance will obtain a list of devices and
+Replace a running \fBdmeventd\fP instance. The running \fBdmeventd\fP must be version
+2.02.77 or newer. The new \fBdmeventd\fP instance will obtain a list of devices and
 events to monitor from the currently running daemon.
 .TP
 .B \-V
-Show version of dmeventd.
+Show version of \fBdmeventd\fP.
 
 .SH SEE ALSO
-.BR lvm (8),
-.BR lvm.conf (5)
+.BR syslog (3),
+.BR lvm.conf (5),
+.BR lvm (8)
-- 
2.1.3



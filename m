From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2011 15:50:42 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/dmeventd.c m ...
Message-ID: <20111222155042.8249.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-22 15:50:40

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: dmeventd.c 
	man            : dmeventd.8.in 

Log message:
	Updated documentation for dmeventd.
	
	Update man page style.
	Mention raid and thin plugins.
	Update help text printed by command to match man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2213&r2=1.2214
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmeventd.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2011/12/21 13:24:24	1.2213
+++ LVM2/WHATS_NEW	2011/12/22 15:50:38	1.2214
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Updated documentation for dmeventd.
   Drop extra stat call before opening device.
   Reduce number of lstat calls when selecting device alias.
   Add function to inialize common structure device members.
--- LVM2/daemons/dmeventd/dmeventd.c	2011/12/21 13:03:07	1.85
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/12/22 15:50:39	1.86
@@ -1872,11 +1872,12 @@
 static void usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-V] [-h] [-d] [-d] [-d] [-f]\n\n"
-		"   -V       Show version of dmeventd\n"
-		"   -h       Show this help information\n"
+		"%s [-d [-d [-d]]] [-f] [-h] [-R] [-V] [-?]\n\n"
 		"   -d       Log debug messages to syslog (-d, -dd, -ddd)\n"
-		"   -f       Don't fork, run in the foreground\n\n", prog);
+		"   -f       Don't fork, run in the foreground\n"
+		"   -h -?    Show this help information\n"
+		"   -R       Restart dmeventd\n"
+		"   -V       Show version of dmeventd\n\n", prog);
 }
 
 int main(int argc, char *argv[])
--- LVM2/man/dmeventd.8.in	2011/03/02 12:49:13	1.4
+++ LVM2/man/dmeventd.8.in	2011/12/22 15:50:40	1.5
@@ -3,12 +3,12 @@
 dmeventd \- Device-mapper event daemon
 .SH SYNOPSIS
 .B dmeventd
-[\-d]
-[\-f]
-[\-R]
-[\-h]
-[\-V]
-[\-?]
+.RB [ \-d " [" -d " [" -d ]]]
+.RB [ \-f ]
+.RB [ \-h ]
+.RB [ \-R ]
+.RB [ \-V ]
+.RB [ \-? ]
 .SH DESCRIPTION
 dmeventd is the event monitoring daemon for device-mapper devices.
 Library plugins can register and carry out actions triggered when
@@ -19,30 +19,39 @@
 .I Mirror
 Attempts to handle device failure automatically.  See \fBlvm.conf\fP(5).
 .TP
+.I Raid
+Attempts to handle device failure automatically.  See \fBlvm.conf\fP(5).
+.TP
 .I Snapshot
 Monitors how full a snapshot is becoming and emits a warning to
 syslog when it exceeds 80% full.
 The warning is repeated when 85%, 90% and 95% of the snapshot is filled.
 See \fBlvm.conf\fP(5).
+.TP
+.I Thin
+Monitors how full a thin pool is becoming and emits a warning to
+syslog when it exceeds 80% full.
+The warning is repeated when 85%, 90% and 95% of the thin pool is filled.
+See \fBlvm.conf\fP(5).
 .SH OPTIONS
 .TP
-.I \-d
+.B \-d
 Repeat from 1 to 3 times (-d, -dd, -ddd) to increase the detail of
 debug messages sent to syslog.
 Each extra d adds more debugging information.
 .TP
-.I \-f
+.B \-f
 Don't fork, run in the foreground.
 .TP
-.I \-R
+.BR \-h ", " \-?
+Show help information.
+.TP
+.B \-R
 Replace a running dmeventd instance. The running dmeventd must be version
 2.02.77 or newer. The new dmeventd instance will obtain a list of devices and
 events to monitor from the currently running daemon.
 .TP
-.I \-h, \-?
-Show help information.
-.TP
-.I \-V
+.B \-V
 Show version of dmeventd.
 
 .SH SEE ALSO



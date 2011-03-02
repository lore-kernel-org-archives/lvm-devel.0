From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Mar 2011 12:49:14 -0000
Subject: LVM2 daemons/dmeventd/dmeventd.c man/dmeventd. ...
Message-ID: <20110302124914.5191.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-03-02 12:49:14

Modified files:
	daemons/dmeventd: dmeventd.c 
	man            : dmeventd.8.in 
	test           : t-dmeventd-restart.sh 

Log message:
	As requested in BZ 454618:
	- dmeventd -R will continue to start up even if no dmeventd is currently
	running + a test for this behaviour
	- add -R to dmeventd manpage

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmeventd.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-dmeventd-restart.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/daemons/dmeventd/dmeventd.c	2011/02/28 19:47:22	1.75
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/03/02 12:49:13	1.76
@@ -1708,13 +1708,14 @@
 	/* Get the list of registrations from the running daemon. */
 
 	if (!init_fifos(&fifos)) {
-		fprintf(stderr, "Could not initiate communication with existing dmeventd.\n");
-		exit(EXIT_FAILURE);
+		fprintf(stderr, "WARNING: Could not initiate communication with existing dmeventd.\n");
+		return;
 	}
 
 	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0)) {
-		fprintf(stderr, "Could not communicate with existing dmeventd.\n");
-		exit(EXIT_FAILURE);
+		fprintf(stderr, "WARNING: Could not communicate with existing dmeventd.\n");
+		fini_fifos(&fifos);
+		return;
 	}
 
 	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_STATUS, "-", "-", 0, 0)) {
--- LVM2/man/dmeventd.8.in	2010/06/22 07:34:34	1.3
+++ LVM2/man/dmeventd.8.in	2011/03/02 12:49:13	1.4
@@ -5,6 +5,7 @@
 .B dmeventd
 [\-d]
 [\-f]
+[\-R]
 [\-h]
 [\-V]
 [\-?]
@@ -33,6 +34,11 @@
 .I \-f
 Don't fork, run in the foreground.
 .TP
+.I \-R
+Replace a running dmeventd instance. The running dmeventd must be version
+2.02.77 or newer. The new dmeventd instance will obtain a list of devices and
+events to monitor from the currently running daemon.
+.TP
 .I \-h, \-?
 Show help information.
 .TP
--- LVM2/test/t-dmeventd-restart.sh	2011/01/05 00:16:20	1.2
+++ LVM2/test/t-dmeventd-restart.sh	2011/03/02 12:49:13	1.3
@@ -30,3 +30,11 @@
 grep 'already monitored' lvchange.out
 lvchange --monitor y --verbose $vg/4way 2>&1 | tee lvchange.out
 grep 'already monitored' lvchange.out
+
+# now try what happens if no dmeventd is running
+kill -9 `cat LOCAL_DMEVENTD`
+dmeventd -R -f &
+echo "$!" > LOCAL_DMEVENTD
+sleep 3
+lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
+not grep 'already monitored' lvchange.out



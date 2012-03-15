From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Mar 2012 08:45:56 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/dmeventd.c
Message-ID: <20120315084556.3092.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-15 08:45:56

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: dmeventd.c 

Log message:
	Remove dmeventd fifos on exit if they are not managed by systemd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.594&r2=1.595
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/WHATS_NEW_DM	2012/03/14 15:51:51	1.594
+++ LVM2/WHATS_NEW_DM	2012/03/15 08:45:55	1.595
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Remove dmeventd fifos on exit if they are not managed by systemd.
   Use SD_ACTIVATION env. var. in systemd units to better detect systemd in use.
   Do not run a new dmeventd instance on restart if there's no existing one.
   Make the time window for reading fifo longer 5sec (1.02.73).
--- LVM2/daemons/dmeventd/dmeventd.c	2012/03/14 15:51:51	1.98
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/03/15 08:45:55	1.99
@@ -1741,10 +1741,18 @@
 }
 #endif
 
-static void remove_lockfile(void)
+static void _remove_files_on_exit(void)
 {
 	if (unlink(DMEVENTD_PIDFILE))
 		perror(DMEVENTD_PIDFILE ": unlink failed");
+
+	if (!_systemd_activation) {
+		if (unlink(DM_EVENT_FIFO_CLIENT))
+			perror(DM_EVENT_FIFO_CLIENT " : unlink failed");
+
+		if (unlink(DM_EVENT_FIFO_SERVER))
+			perror(DM_EVENT_FIFO_SERVER " : unlink failed");
+	}
 }
 
 static void _daemonize(void)
@@ -1955,10 +1963,11 @@
 	if (dm_create_lockfile(DMEVENTD_PIDFILE) == 0)
 		exit(EXIT_FAILURE);
 
-	atexit(remove_lockfile);
+	atexit(_remove_files_on_exit);
 	(void) dm_prepare_selinux_context(NULL, 0);
 
 	/* Set the rest of the signals to cause '_exit_now' to be set */
+	signal(SIGTERM, &_exit_handler);
 	signal(SIGINT, &_exit_handler);
 	signal(SIGHUP, &_exit_handler);
 	signal(SIGQUIT, &_exit_handler);



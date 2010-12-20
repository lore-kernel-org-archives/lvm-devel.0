From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 14:08:46 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/dmeventd.c
Message-ID: <20101220140846.24389.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 14:08:46

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: dmeventd.c 

Log message:
	Add check for unlink errors

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1846&r2=1.1847
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/WHATS_NEW	2010/12/20 13:57:19	1.1846
+++ LVM2/WHATS_NEW	2010/12/20 14:08:46	1.1847
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Add check for unlink error result in remove_lockfile() (dmeventd).
   Use dm_free for dm_malloc-ed areas in _clog_ctr/_clog_dtr (cmirrord).
   Add checks for allocation errors in config node clonning.
   Fix error path if regex engine cannot be created in _build_matcher().
--- LVM2/daemons/dmeventd/dmeventd.c	2010/12/13 10:43:57	1.72
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/12/20 14:08:46	1.73
@@ -1642,7 +1642,8 @@
 
 static void remove_lockfile(void)
 {
-	unlink(DMEVENTD_PIDFILE);
+	if (unlink(DMEVENTD_PIDFILE))
+		perror(DMEVENTD_PIDFILE ": unlink failed");
 }
 
 static void _daemonize(void)



From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Sep 2009 10:37:25 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/mirr ...
Message-ID: <20090917103725.10678.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-17 10:37:24

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 

Log message:
	Fix dmeventd _temporary_log_fn parameters. (2.02.50)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1269&r2=1.1270
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2009/09/16 23:48:41	1.1269
+++ LVM2/WHATS_NEW	2009/09/17 10:37:23	1.1270
@@ -1,5 +1,6 @@
 Version 2.02.53 - 
 =====================================
+  Fix dmeventd _temporary_log_fn parameters. (2.02.50)
   Enable dmeventd monitoring section of config file by default.
   Update lvm2 monitoring script to lvm2_monitoring_init_red_hat.in.
   Fix lvm2app test to run under test/api subdirectory only when configured.
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/06/30 18:39:31	1.25
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/09/17 10:37:24	1.26
@@ -126,8 +126,10 @@
 	return ME_IGNORE;
 }
 
-static void _temporary_log_fn(int level, const char *file __attribute((unused)),
+static void _temporary_log_fn(int level,
+			      const char *file __attribute((unused)),
 			      int line __attribute((unused)),
+			      int dm_errno __attribute((unused)),
 			      const char *format)
 {
 	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2008/10/13 12:06:30	1.3
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2009/09/17 10:37:24	1.4
@@ -57,6 +57,7 @@
 static void _temporary_log_fn(int level,
 			      const char *file __attribute((unused)),
 			      int line __attribute((unused)),
+			      int dm_errno __attribute((unused)),
 			      const char *format)
 {
 	if (!strncmp(format, "WARNING: ", 9) && (level < 5))



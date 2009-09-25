From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Sep 2009 18:32:22 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090925183222.10150.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-25 18:32:22

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.209&r2=1.210
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1271&r2=1.1272
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.302&r2=1.303

--- LVM2/VERSION	2009/09/15 13:54:28	1.209
+++ LVM2/VERSION	2009/09/25 18:32:22	1.210
@@ -1 +1 @@
-2.02.53(1)-cvs (2009-09-15)
+2.02.53(1)-cvs (2009-09-25)
--- LVM2/VERSION_DM	2009/09/15 13:54:28	1.21
+++ LVM2/VERSION_DM	2009/09/25 18:32:22	1.22
@@ -1 +1 @@
-1.02.38-cvs (2009-09-15)
+1.02.38-cvs (2009-09-25)
--- LVM2/WHATS_NEW	2009/09/25 18:30:26	1.1271
+++ LVM2/WHATS_NEW	2009/09/25 18:32:22	1.1272
@@ -1,5 +1,6 @@
 Version 2.02.53 - 25th September 2009
 =====================================
+  Create any directories in /dev with DM_DEV_DIR_UMASK (022).
   Enable dmeventd monitoring section of config file by default.
   Update lvm2 monitoring script to lvm2_monitoring_init_red_hat.in.
   Fix lvm2app test to run under test/api subdirectory only when configured.
--- LVM2/WHATS_NEW_DM	2009/09/25 18:30:26	1.302
+++ LVM2/WHATS_NEW_DM	2009/09/25 18:32:22	1.303
@@ -1,5 +1,6 @@
 Version 1.02.38 - 25th September 2009
 =====================================
+  Export DM_DEV_DIR_UMASK, the default umask for /dev directories created.
   Handle any path supplied to dm_task_set_name by looking up in /dev/mapper.
   Add several examples to 12-dm-permissions.rules.
   Add splitname and --yes to dmsetup man page.



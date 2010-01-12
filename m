From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jan 2010 14:39:08 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100112143908.817.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-12 14:39:08

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.217&r2=1.218
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1380&r2=1.1381
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.332&r2=1.333

--- LVM2/VERSION	2009/11/24 19:04:23	1.217
+++ LVM2/VERSION	2010/01/12 14:39:07	1.218
@@ -1 +1 @@
-2.02.57(1)-cvs (2009-11-24)
+2.02.57(1)-cvs (2010-01-12)
--- LVM2/VERSION_DM	2009/11/24 19:04:23	1.29
+++ LVM2/VERSION_DM	2010/01/12 14:39:07	1.30
@@ -1 +1 @@
-1.02.41-cvs (2009-11-24)
+1.02.41-cvs (2010-01-12)
--- LVM2/WHATS_NEW	2010/01/12 14:00:51	1.1380
+++ LVM2/WHATS_NEW	2010/01/12 14:39:07	1.1381
@@ -1,5 +1,5 @@
-Version 2.02.57 -
-====================================
+Version 2.02.57 - 12th January 2010
+===================================
   Ensure exactly one process returns from poll_daemon(), never two.
   Reset _vgs_locked in lvmcache_init() in child after forking.
   Define {DM, LVM}_UDEV_DISABLE_CHECKING=1 environment variables during tests.
--- LVM2/WHATS_NEW_DM	2010/01/12 14:00:51	1.332
+++ LVM2/WHATS_NEW_DM	2010/01/12 14:39:07	1.333
@@ -1,5 +1,5 @@
-Version 1.02.41 -
-====================================
+Version 1.02.41 - 12th January 2010
+===================================
   If DM_UDEV_DISABLE_CHECKING is set in environment, disable udev warnings.
   Add dm_tree_add_dev_with_udev_flags to provide wider support for udev flags.
   Add --noudevrules option for dmsetup to disable /dev node management by udev.



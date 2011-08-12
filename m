From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Aug 2011 01:34:12 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20110812013412.20343.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-12 01:34:11

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.282&r2=1.283
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2070&r2=1.2071
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.490&r2=1.491

--- LVM2/VERSION	2011/07/08 19:57:32	1.282
+++ LVM2/VERSION	2011/08/12 01:34:11	1.283
@@ -1 +1 @@
-2.02.87(2)-cvs (2011-07-08)
+2.02.87(2)-cvs (2011-08-12)
--- LVM2/VERSION_DM	2011/07/08 19:57:33	1.87
+++ LVM2/VERSION_DM	2011/08/12 01:34:11	1.88
@@ -1 +1 @@
-1.02.66-cvs (2011-07-08)
+1.02.66-cvs (2011-08-12)
--- LVM2/WHATS_NEW	2011/08/11 19:18:18	1.2070
+++ LVM2/WHATS_NEW	2011/08/12 01:34:11	1.2071
@@ -1,32 +1,27 @@
-Version 2.02.87 - 
-===============================
-  Add ability to down-convert RAID1 arrays.
-  Update udev rules to skip DM flags decoding for removed devices.
-  Add detect_internal_vg_cache_corruption to lvm.conf, disabled by default.
+Version 2.02.87 - 12th August 2011
+==================================
+  Add global/detect_internal_vg_cache_corruption to lvm.conf.
   Use memory pool locking to check for corruption of internal VG structs.
   Cache and share generated VG structs.
   Fix possible format instance memory leaks and premature releases in _vg_read.
   Suppress locking error messages in monitoring init scripts.
-  If pipe in clvmd fails, return busy instead of using uninitialised descriptors.
-  Add dmeventd monitoring shared library for raid.
-  Add raid metadata devices to considered devices in _add_lv_to_dtree.
-  Fix renaming of RAID logical volumes.
+  If pipe in clvmd fails return busy instead of using uninitialised descriptors.
+  Add ability to reduce the number of mirrors in raid1 arrays to lvconvert.
+  Add dmeventd plugin for raid.
   Replace free_vg with release_vg and move it to vg.c.
   Remove INCONSISTENT_VG flag from the code.
-  Remove lock from cache even if unlock fails.
+  Remove lock from cache in _lock_vol even if unlock fails.
   Initialise clvmd locks before lvm context to avoid open descriptor leaks.
   Remove obsolete gulm clvmd cluster locking support.
   Suppress low-level locking errors and warnings while using --sysinit.
   Remove unused inconsistent_seqno variable in _vg_read().
   Remove meaningless const type qualifiers on cast type.
-  Fix memory leak in dmsetup _message() memory allocation error path.
   Add test for fcntl error in singlenode client code.
   Remove --force option from lvrename manpage.
-  Add missing new line in lvrename help text.
-  Add basic support for MD RAID 1/4/5/6 as new segment type called raid.
-  Change DEFAULT_UDEV_SYNC to 1 so udev_sync is used even without any config.
+  Add configure --with-raid for new segtype 'raid' for MD RAID 1/4/5/6 support.
+  Change DEFAULT_UDEV_SYNC to 1 so udev_sync is used if there is no config file.
   Add systemd unit file to provide lvm2 monitoring.
-  Compare also file size to detect changed config file.
+  Compare file size (as well as timestamp) to detect changed config file.
 
 Version 2.02.86 - 8th July 2011
 ===============================
--- LVM2/WHATS_NEW_DM	2011/08/11 20:49:33	1.490
+++ LVM2/WHATS_NEW_DM	2011/08/12 01:34:11	1.491
@@ -1,12 +1,14 @@
-Version 1.02.66 - 
-===============================
+Version 1.02.66 - 12th August 2011
+==================================
   Release geometry buffer in dm_task_destroy.
-  Add memory pool locking functions to aid debuging of shared VG structs.
-  Remove dev name prefix from dmsetup line output if major and minor is used.
+  Update udev rules to skip DM flags decoding for removed devices.
+  Add compile-time pool memory locking options (to debug shared VG structs).
+  Remove device name prefix from dmsetup line output if -j & -m or -u supplied.
   Remove support for the original version 1 dm ioctls.
   Add missing check for allocation failure _create_dir_recursive().
   Add support for systemd file descriptor handover in dmeventd.
-  Add support for new oom killer adjustment interface (oom_score_adj).
+  Fix memory leak in dmsetup _message() memory allocation error path.
+  Use new oom killer adjustment interface (oom_score_adj) when available.
   Add systemd unit files for dmeventd.
   Fix read-only identical table reload supression.
 



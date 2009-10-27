From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Oct 2009 00:52:46 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM
Message-ID: <20091027005246.28329.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-27 00:52:45

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1305&r2=1.1306
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.308&r2=1.309

--- LVM2/WHATS_NEW	2009/10/26 21:56:23	1.1305
+++ LVM2/WHATS_NEW	2009/10/27 00:52:45	1.1306
@@ -6,7 +6,7 @@
   Cleanup mimagetmp LV if allocation fails for new lvconvert mimage.
   Fix clvmd segfault when refresh_toolcontext fails.
   Remember to clear 'global lock held during cache refresh' state after use.
-  Use udev flags support in LVM.
+  Use udev flags support in LVM and apply various fixes to udev rules.
   Delay announcing mirror monitoring to syslog until initialisation succeeded.
   Handle metadata with unknown segment types more gracefully.
   Set default owner and group to null.
@@ -27,7 +27,7 @@
   Restart lvconverts in vgchange by sharing lv_spawn_background_polling.
   Generalise polldaemon code by changing mirror-specific variable names.
   Don't attempt to deactivate an LV if any of its snapshots are in use.
-  Return fail if lv_deactivate fails to remove device from kernel.
+  Return error if lv_deactivate fails to remove device from kernel.
   Provide alternative implementation of obsolete siginterrupt().
   Consolidate LV allocation into alloc_lv().
   Treat input units of both 's' and 'S' as 512-byte sectors.  (2.02.49)
--- LVM2/WHATS_NEW_DM	2009/10/26 21:56:23	1.308
+++ LVM2/WHATS_NEW_DM	2009/10/27 00:52:45	1.309
@@ -2,7 +2,7 @@
 ===================================
   Remove strict default permissions for DM devices from 95-dm-notify.rules.
   Add dmsetup udevflags command to decode udev flags in given cookie value.
-  Add udev flags support in libdevmapper.
+  Support udev flags in libdevmapper incl. dm_tree_add_new_dev_with_udev_flags.
   Make libdm ABI consistent when built with/without selinux support.
 
 Version 1.02.38 - 25th September 2009



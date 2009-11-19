From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Nov 2009 19:42:58 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM
Message-ID: <20091119194258.326.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-19 19:42:57

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1318&r2=1.1319
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.316&r2=1.317

--- LVM2/WHATS_NEW	2009/11/19 19:00:34	1.1318
+++ LVM2/WHATS_NEW	2009/11/19 19:42:57	1.1319
@@ -1,18 +1,18 @@
 Version 2.02.55 - 19th November 2009
 ====================================
-  Fix a possible deadlock in mirror code due to memlock refcount mismatch.
-  Enable dmeventd event handlers to properly scan devices.
-  Do not activate directly not visible volumes in vgchange.
-  Fix pvmove region_size oveflow for very large PVs.
-  Fix lvcreate and lvresize processing of %PVS argument.
+  Fix deadlock when changing mirrors due to unpaired memlock refcount changes.
+  Use separate memlock counter for dmeventd handlers to permit device scanning.
+  Directly restrict vgchange to activating visible LVs.
+  Fix pvmove region_size overflow for very large PVs.
+  Fix lvcreate and lvresize %PVS argument always to use sensible total size.
   Tidy some uses of arg_count and introduce arg_is_set.
   Export outnl and indent functions for modules.
   Flush stdout after yes/no prompt.
   Update vgsplit and vgcreate to use vg_set_clustered.
-  Add vg_mda_count and vg_set_clustered library function.
+  Add vg_mda_count and vg_set_clustered library functions.
   Add more vgcreate and vgsplit nightly tests.
   Insert some missing stack macros into activation code.
-  Recognise DRBD device part and handle it similar to MD devices.
+  Recognise DRBD devices and handle them like md devices.
 
 Version 2.02.54 - 26th October 2009
 ===================================
--- LVM2/WHATS_NEW_DM	2009/11/19 19:00:34	1.316
+++ LVM2/WHATS_NEW_DM	2009/11/19 19:42:57	1.317
@@ -2,7 +2,7 @@
 ====================================
   Fix install_device-mapper Makefile target to not build dmeventd plugins.
   Support udev flags even when udev_sync is disabled or not compiled in.
-  Remove 'last_rule' from udev rules: honor ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}.
+  Remove 'last_rule' from udev rules: honour DM_UDEV_DISABLE_OTHER_RULES_FLAG.
   Add dmsetup --inactive support.
   Add dm_task_query_inactive_table to libdevmapper for kernel driver >= 4.16.
   Fix hash lookup segfault when keys compared are different lengths.



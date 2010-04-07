From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Apr 2010 20:04:43 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdm-de ...
Message-ID: <20100407200443.26841.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-07 20:04:42

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	libdm          : libdm-deptree.c 
	lib/activate   : dev_manager.c 

Log message:
	Fix incorrect removal of symlinks after LV deactivation fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1504&r2=1.1505
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.353&r2=1.354
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.183&r2=1.184

--- LVM2/WHATS_NEW	2010/04/06 17:36:41	1.1504
+++ LVM2/WHATS_NEW	2010/04/07 20:04:41	1.1505
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Fix incorrect removal of symlinks after LV deactivation fails.
   Fix is_partitioned_dev not to attempt to reopen device.
   Fix another thread race in clvmd.
   Refactor management of vg->pvs list.
--- LVM2/WHATS_NEW_DM	2010/04/07 15:57:20	1.353
+++ LVM2/WHATS_NEW_DM	2010/04/07 20:04:42	1.354
@@ -1,6 +1,7 @@
 Version 1.02.46 - 
 ================================
-  Wipe memory buffers for dm-ioctl parameters before releaseing.
+  Change dm_tree_deactivate_children to fail if device is open.
+  Wipe memory buffers for dm-ioctl parameters before releasing.
   Strictly require libudev if udev_sync is used.
   Add support for ioctl's DM_UEVENT_GENERATED_FLAG.
 
--- LVM2/libdm/libdm-deptree.c	2010/03/25 18:22:04	1.72
+++ LVM2/libdm/libdm-deptree.c	2010/04/07 20:04:42	1.73
@@ -1047,9 +1047,14 @@
 
 		/* Refresh open_count */
 		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info) ||
-		    !info.exists || info.open_count)
+		    !info.exists)
 			continue;
 
+		if (info.open_count) {
+			r = 0;
+			continue;
+		}
+
 		if (!_deactivate_node(name, info.major, info.minor,
 				      &child->dtree->cookie, child->udev_flags)) {
 			log_error("Unable to deactivate %s (%" PRIu32
--- LVM2/lib/activate/dev_manager.c	2010/02/24 20:00:56	1.183
+++ LVM2/lib/activate/dev_manager.c	2010/04/07 20:04:42	1.184
@@ -1523,8 +1523,6 @@
 
 	r = _tree_action(dm, lv, DEACTIVATE);
 
-	fs_del_lv(lv);
-
 	return r;
 }
 



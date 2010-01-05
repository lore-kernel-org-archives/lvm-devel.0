From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Jan 2010 21:33:00 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM
Message-ID: <20100105213300.13336.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-05 21:33:00

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 

Log message:
	update WHATS_NEW and WHATS_NEW_DM with previous commits' changes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1363&r2=1.1364
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.322&r2=1.323

--- LVM2/WHATS_NEW	2010/01/05 21:14:04	1.1363
+++ LVM2/WHATS_NEW	2010/01/05 21:32:59	1.1364
@@ -1,6 +1,8 @@
 Version 2.02.57 -
 ====================================
   Use snapshot metadata usage to determine if a snapshot is empty.
+  Insert missing stack macros to all activate_lv and deactivate_lv callers.
+  Insert missing stack macros to all suspend_lv and resume_lv callers.
   Add --poll flag to vgchange and lvchange.
   Propagate commit and revert metadata notification to other nodes in cluster.
   Use proper mask for VG lock mode in clvmd.
--- LVM2/WHATS_NEW_DM	2009/12/11 13:11:56	1.322
+++ LVM2/WHATS_NEW_DM	2010/01/05 21:32:59	1.323
@@ -1,5 +1,8 @@
 Version 1.02.41 -
 ====================================
+  Return error from dm_tree_deactivate_children().
+  Return error from dm_tree_suspend_children().
+  Return error from dm_tree_preload_children() and dm_tree_activate_children().
   Fix coredump and memory leak for 'dmsetup help -c'.
   Disable udev rules for change events with DISK_RO set.
 



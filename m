From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Nov 2008 18:20:15 -0000
Subject: LVM2 ./WHATS_NEW man/lvremove.8.in tools/lvrem ...
Message-ID: <20081117182015.8703.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-11-17 18:20:14

Modified files:
	.              : WHATS_NEW 
	man            : lvremove.8.in 
	tools          : lvremove.c 

Log message:
	Fix "lvremove -f vgname" when vgname contains snapshots.
	
	Prior to this patch, "lvremove -f vgname" would fail if vgname contained
	one or more snapshot LVs.  Now this passes, but has a side-effect.
	If you issue "lvremove vgname" where vgname contains one or more snaps,
	you will get an extra "y/n" prompt to remove the same snapshot.
	Example:
	$ lvs
	LV     VG     Attr   LSize  Origin Snap%  Move Log Copy%  Convert
	lvsnap vgtest swi-a- 16.00M lvtest   0.05
	lvtest vgtest owi-a- 64.00M
	$ lvremove vgtest
	Do you really want to remove active logical volume "lvsnap"? [y/n]: n
	Logical volume "lvsnap" not removed
	Do you really want to remove active logical volume "lvsnap"? [y/n]: n
	Logical volume "lvsnap" not removed
	Command failed with status code 5.
	
	Fixing this will most likely require modification of the iterator
	function, process_each_lvs_in_vg() to iterate over snaps in some
	cases (e.g. lvs, vgdisplay -v) but not in others (lvremove).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.995&r2=1.996
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvremove.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2008/11/12 15:01:35	1.995
+++ LVM2/WHATS_NEW	2008/11/17 18:20:13	1.996
@@ -1,5 +1,6 @@
 Version 2.02.43 - 10th November 2008
 ====================================
+  Cope with snapshot dependencies when removing a whole VG with lvremove.
   Make man pages consistent with either-or options (use "|" everywhere).
   Merge device-mapper into the lvm2 tree.
   Correct prototype for --permission on lvchange and lvcreate man pages.
--- LVM2/man/lvremove.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/lvremove.8.in	2008/11/17 18:20:13	1.3
@@ -12,6 +12,7 @@
 Confirmation will be requested before deactivating any active logical
 volume prior to removal.  Logical volumes cannot be deactivated
 or removed while they are open (e.g. if they contain a mounted filesystem).
+Removing an origin logical volume will also remove all dependent snapshots.
 .sp
 If the logical volume is clustered then it must be deactivated on all
 nodes in the cluster before it can be removed. A single lvchange command
--- LVM2/tools/lvremove.c	2008/09/19 06:42:00	1.55
+++ LVM2/tools/lvremove.c	2008/11/17 18:20:14	1.56
@@ -18,7 +18,7 @@
 static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute((unused)))
 {
-	if (!lv_remove_single(cmd, lv, arg_count(cmd, force_ARG)))
+	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG)))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;



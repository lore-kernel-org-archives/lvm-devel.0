From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Feb 2011 01:24:48 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20110203012448.15847.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-03 01:24:47

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c fs.c 
	liblvm         : lvm_lv.c 
	tools          : lvconvert.c lvscan.c 

Log message:
	Do not check for open_count when not needed.
	
	Disable open_count checking in lv_info it it's not used.
	
	Fix previous commit (comment out unsable code for now).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1898&r2=1.1899
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW	2011/02/02 23:39:39	1.1898
+++ LVM2/WHATS_NEW	2011/02/03 01:24:46	1.1899
@@ -1,5 +1,7 @@
 Version 2.02.83 - 
 ===================================
+  Remove unneeded checks for open_count in lv_info().
+  Synchronize with udev before checking open_count in lv_info().
   Allow CLVMD_CMD_SYNC_NAMES to be propagated around the cluster if requested.
   Add "dmsetup ls --tree" output to lvmdump.
   Fix udev synchronization with no-locking --sysinit (2.02.80).
--- LVM2/lib/activate/activate.c	2011/02/03 01:16:35	1.187
+++ LVM2/lib/activate/activate.c	2011/02/03 01:24:46	1.188
@@ -469,7 +469,7 @@
 	if (with_open_count) {
 		if (locking_is_clustered())
 			sync_local_dev_names(cmd); /* Wait to have udev in sync */
-		else if (fs_has_non_delete_ops())
+		else //if (fs_has_non_delete_ops())
 			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
 	}
 
@@ -1219,7 +1219,7 @@
 	r = _lv_deactivate(lv);
 	memlock_dec(cmd);
 
-	if (!lv_info(cmd, lv, 0, &info, 1, 0) || info.exists)
+	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists)
 		r = 0;
 out:
 	if (lv) {
--- LVM2/lib/activate/fs.c	2011/02/03 01:16:35	1.57
+++ LVM2/lib/activate/fs.c	2011/02/03 01:24:46	1.58
@@ -423,7 +423,9 @@
 	_fs_cookie = cookie;
 }
 
+#if 0
 int fs_has_non_delete_ops(void)
 {
 	return _other_fs_ops(FS_DEL);
 }
+#endif
--- LVM2/liblvm/lvm_lv.c	2010/12/14 23:20:58	1.34
+++ LVM2/liblvm/lvm_lv.c	2011/02/03 01:24:46	1.35
@@ -62,7 +62,7 @@
 uint64_t lvm_lv_is_active(const lv_t lv)
 {
 	struct lvinfo info;
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) &&
 	    info.exists && info.live_table)
 		return 1;
 	return 0;
@@ -71,7 +71,7 @@
 uint64_t lvm_lv_is_suspended(const lv_t lv)
 {
 	struct lvinfo info;
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) &&
 	    info.exists && info.suspended)
 		return 1;
 	return 0;
--- LVM2/tools/lvconvert.c	2011/01/19 19:24:07	1.156
+++ LVM2/tools/lvconvert.c	2011/02/03 01:24:47	1.157
@@ -1637,7 +1637,7 @@
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, 0, &info, 1, 0) || !info.exists) {
+	if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists) {
 		log_print("Conversion starts after activation.");
 		return ECMD_PROCESSED;
 	}
--- LVM2/tools/lvscan.c	2010/12/22 12:06:54	1.44
+++ LVM2/tools/lvscan.c	2011/02/03 01:24:47	1.45
@@ -28,7 +28,7 @@
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
-	inkernel = lv_info(cmd, lv, 0, &info, 1, 0) && info.exists;
+	inkernel = lv_info(cmd, lv, 0, &info, 0, 0) && info.exists;
 	if (lv_is_origin(lv)) {
 		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
 				       origin_list) {



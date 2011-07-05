From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jul 2011 01:01:20 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20110705010120.26576.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-05 01:01:19

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Fix conditions using no_merging: only those using lv_is_merging_cow() should
	have been converted, not pure lv_is_cow ones.
	(Merging has no impact on how the pre-merged cow segment itself is loaded.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.223&r2=1.224

--- LVM2/lib/activate/dev_manager.c	2011/07/04 14:56:58	1.223
+++ LVM2/lib/activate/dev_manager.c	2011/07/05 01:01:19	1.224
@@ -1436,7 +1436,7 @@
 		}
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "real"))
 			return_0;
-	} else if (!laopts->no_merging && lv_is_cow(seg->lv) && !layer) {
+	} else if (lv_is_cow(seg->lv) && !layer) {
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
 	} else {
@@ -1457,7 +1457,7 @@
 			if (!_add_snapshot_merge_target_to_dtree(dm, dnode, seg->lv))
 				return_0;
 		}
-	} else if (!laopts->no_merging && lv_is_cow(seg->lv) && !layer) {
+	} else if (lv_is_cow(seg->lv) && !layer) {
 		if (!_add_snapshot_target_to_dtree(dm, dnode, seg->lv, laopts))
 			return_0;
 	} else if (!_add_target_to_dtree(dm, dnode, seg, laopts))



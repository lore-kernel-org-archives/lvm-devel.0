From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 23 Apr 2010 02:57:46 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.h lib/a ...
Message-ID: <20100423025746.5061.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-04-23 02:57:43

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.h dev_manager.c 
	lib/metadata   : snapshot_manip.c 
	test           : t-snapshot-merge.sh 

Log message:
	When removing a snapshot avoid preloading the origin if the
	snapshot-merge target is not active.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1534&r2=1.1535
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.185&r2=1.186
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2010/04/21 14:04:24	1.1534
+++ LVM2/WHATS_NEW	2010/04/23 02:57:39	1.1535
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Don't preload the origin when removing a snapshot whose merge is pending.
   Disallow the addition of mirror images while a conversion is happening.
   Disallow primary mirror image removal when mirror is not in-sync.
   Remove obsolete --name parameter from vgcfgrestore.
--- LVM2/lib/activate/activate.h	2010/02/24 20:01:41	1.65
+++ LVM2/lib/activate/activate.h	2010/04/23 02:57:41	1.66
@@ -95,6 +95,9 @@
 
 int lv_is_active(struct logical_volume *lv);
 
+int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
+		       const char *layer, const char *target_type);
+
 int monitor_dev_for_events(struct cmd_context *cmd,
 			    struct logical_volume *lv, int do_reg);
 
--- LVM2/lib/activate/dev_manager.c	2010/04/14 13:01:42	1.185
+++ LVM2/lib/activate/dev_manager.c	2010/04/23 02:57:41	1.186
@@ -329,10 +329,8 @@
 	return 0;
 }
 
-static int _lv_has_target_type(struct dev_manager *dm,
-			       struct logical_volume *lv,
-			       const char *layer,
-			       const char *target_type)
+int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
+		       const char *layer, const char *target_type)
 {
 	int r = 0;
 	char *dlid;
@@ -343,7 +341,7 @@
 	char *type = NULL;
 	char *params = NULL;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, layer)))
 		return_0;
 
 	if (!(dmt = _setup_task(NULL, dlid, 0,
@@ -1183,7 +1181,7 @@
 		    ((dinfo = _cached_info(dm->mem, find_merging_cow(lv)->cow,
 					   dtree)) && dinfo->open_count)) {
 			/* FIXME Is there anything simpler to check for instead? */
-			if (!_lv_has_target_type(dm, lv, NULL, "snapshot-merge"))
+			if (!lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
 				clear_snapshot_merge(lv);
 		}
 	}
--- LVM2/lib/metadata/snapshot_manip.c	2010/02/17 22:59:46	1.48
+++ LVM2/lib/metadata/snapshot_manip.c	2010/04/23 02:57:43	1.49
@@ -18,6 +18,7 @@
 #include "locking.h"
 #include "toolcontext.h"
 #include "lv_alloc.h"
+#include "activate.h"
 
 int lv_is_origin(const struct logical_volume *lv)
 {
@@ -176,16 +177,24 @@
 
 	dm_list_del(&cow->snapshot->origin_list);
 	origin->origin_count--;
+
 	if (find_merging_cow(origin) == find_cow(cow)) {
 		clear_snapshot_merge(origin);
 		/*
-		 * preload origin to:
-		 * - allow proper release of -cow
-		 * - avoid allocations with other devices suspended
-		 *   when transitioning from "snapshot-merge" to
-		 *   "snapshot-origin after a merge completes.
+		 * preload origin IFF "snapshot-merge" target is active
+		 * - IMPORTANT: avoids preload if onactivate merge is pending
 		 */
-		preload_origin = 1;
+		if (lv_has_target_type(origin->vg->cmd->mem, origin, NULL,
+				       "snapshot-merge")) {
+			/*
+			 * preload origin to:
+			 * - allow proper release of -cow
+			 * - avoid allocations with other devices suspended
+			 *   when transitioning from "snapshot-merge" to
+			 *   "snapshot-origin after a merge completes.
+			 */
+			preload_origin = 1;
+		}
 	}
 
 	if (!lv_remove(cow->snapshot->lv)) {
--- LVM2/test/t-snapshot-merge.sh	2010/04/19 22:44:42	1.4
+++ LVM2/test/t-snapshot-merge.sh	2010/04/23 02:57:43	1.5
@@ -76,6 +76,23 @@
 lvremove -f $vg/$lv1
 
 
+# "onactivate merge" test
+# -- deactivate/remove after disallowed merge attempt, tests
+#    to make sure preload of origin's metadata is _not_ performed
+setup_merge $vg $lv1
+lvs -a
+mkdir test_mnt
+mount $(lvdev_ $vg $lv1) test_mnt
+lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+# -- refresh LV while FS is still mounted (merge must not start),
+#    verify 'snapshot-origin' target is still being used
+lvchange --refresh $vg/$lv1
+umount test_mnt
+rm -r test_mnt
+dmsetup table ${vg}-${lv1} | grep -q " snapshot-origin "
+lvremove -f $vg/$lv1
+
+
 # test multiple snapshot merge; tests copy out that is driven by merge
 setup_merge $vg $lv1 1
 lvs -a



From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jul 2011 18:36:37 -0000
Subject: LVM2/lib/activate activate.c
Message-ID: <20110705183637.27966.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-05 18:36:37

Modified files:
	lib/activate   : activate.c 

Log message:
	Always perform preload logic before suspending - not only in the case when we
	have precommitted metadata.  (Necessary to avoid loading tables
	while suspend in lvchange --refresh.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.206&r2=1.207

--- LVM2/lib/activate/activate.c	2011/07/05 01:08:42	1.206
+++ LVM2/lib/activate/activate.c	2011/07/05 18:36:37	1.207
@@ -1168,49 +1168,47 @@
 	lv_calculate_readahead(lv, NULL);
 
 	/*
-	 * If VG was precommitted, preload devices for the LV.
+	 * Preload devices for the LV.
 	 * If the PVMOVE LV is being removed, it's only present in the old
 	 * metadata and not the new, so we must explicitly add the new
 	 * tables for all the changed LVs here, as the relationships
 	 * are not found by walking the new metadata.
 	 */
-	if ((lv_pre->vg->status & PRECOMMITTED)) {
-		if (!(lv_pre->status & LOCKED) &&
-		    (lv->status & LOCKED) &&
-		    (pvmove_lv = find_pvmove_lv_in_lv(lv))) {
-			/* Preload all the LVs above the PVMOVE LV */
-			dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
-				if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, sl->seg->lv->name))) {
-					/* FIXME Internal error? */
-					log_error("LV %s missing from preload metadata", sl->seg->lv->name);
-					goto out;
-				}
-				if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
-					goto_out;
-			}
-			/* Now preload the PVMOVE LV itself */
-			if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, pvmove_lv->name))) {
+	if (!(lv_pre->status & LOCKED) &&
+	    (lv->status & LOCKED) &&
+	    (pvmove_lv = find_pvmove_lv_in_lv(lv))) {
+		/* Preload all the LVs above the PVMOVE LV */
+		dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
+			if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, sl->seg->lv->name))) {
 				/* FIXME Internal error? */
-				log_error("LV %s missing from preload metadata", pvmove_lv->name);
+				log_error("LV %s missing from preload metadata", sl->seg->lv->name);
 				goto out;
 			}
 			if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
 				goto_out;
-		} else {
-			if (!_lv_preload(lv_pre, laopts, &flush_required))
-				/* FIXME Revert preloading */
-				goto_out;
+		}
+		/* Now preload the PVMOVE LV itself */
+		if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, pvmove_lv->name))) {
+			/* FIXME Internal error? */
+			log_error("LV %s missing from preload metadata", pvmove_lv->name);
+			goto out;
+		}
+		if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
+			goto_out;
+	} else {
+		if (!_lv_preload(lv_pre, laopts, &flush_required))
+			/* FIXME Revert preloading */
+			goto_out;
 
-			/*
-			 * Search for existing LVs that have become detached and preload them.
-			 */
-			detached.lv_pre = lv_pre;
-			detached.laopts = laopts;
-			detached.flush_required = &flush_required;
+		/*
+		 * Search for existing LVs that have become detached and preload them.
+		 */
+		detached.lv_pre = lv_pre;
+		detached.laopts = laopts;
+		detached.flush_required = &flush_required;
 
-			if (!for_each_sub_lv(cmd, lv, &_preload_detached_lv, &detached))
-				goto_out;
-		}
+		if (!for_each_sub_lv(cmd, lv, &_preload_detached_lv, &detached))
+			goto_out;
 	}
 
 	if (!monitor_dev_for_events(cmd, lv, laopts, 0))



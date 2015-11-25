From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 25 Nov 2015 10:44:18 +0000 (UTC)
Subject: master - cleanup: change ondisk committed
Message-ID: <20151125104418.BD4DC61042@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4312b096359b336d6f4ba52679a0f594854ba7ee
Commit:        4312b096359b336d6f4ba52679a0f594854ba7ee
Parent:        d9faf859871e0e862ded3cc08638847c9aaa6f1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 25 10:52:22 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 25 11:39:26 2015 +0100

cleanup: change ondisk committed

Patch has no functional change.
---
 lib/activate/activate.c |   86 +++++++++++++++++++++++-----------------------
 lib/activate/activate.h |    2 +-
 2 files changed, 44 insertions(+), 44 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c30a7ac..4bcfcd6 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -333,7 +333,7 @@ int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
 }
 *******/
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive,
-			 const struct logical_volume *ondisk_lv, const struct logical_volume *incore_lv)
+			 const struct logical_volume *lv, const struct logical_volume *lv_pre)
 {
 	return 1;
 }
@@ -1793,12 +1793,12 @@ static int _preload_detached_lv(struct logical_volume *lv, void *data)
 
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		       struct lv_activate_opts *laopts, int error_if_not_suspended,
-	               const struct logical_volume *ondisk_lv, const struct logical_volume *incore_lv)
+	               const struct logical_volume *lv, const struct logical_volume *lv_pre)
 {
 	const struct logical_volume *pvmove_lv = NULL;
-	const struct logical_volume *ondisk_lv_to_free = NULL;
-	const struct logical_volume *incore_lv_to_free = NULL;
-	struct logical_volume *lv_pre;
+	const struct logical_volume *lv_to_free = NULL;
+	const struct logical_volume *lv_pre_to_free = NULL;
+	struct logical_volume *lv_pre_tmp;
 	struct seg_list *sl;
         struct lv_segment *snap_seg;
 	struct lvinfo info;
@@ -1808,27 +1808,28 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (!activation())
 		return 1;
 
-	if (!ondisk_lv && !(ondisk_lv_to_free = ondisk_lv = lv_from_lvid(cmd, lvid_s, 0)))
+	/* lv comes from committed metadata */
+	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto_out;
 
 	/* Use precommitted metadata if present */
-	if (!incore_lv && !(incore_lv_to_free = incore_lv = lv_from_lvid(cmd, lvid_s, 1)))
+	if (!lv_pre && !(lv_pre_to_free = lv_pre = lv_from_lvid(cmd, lvid_s, 1)))
 		goto_out;
 
 	/* Ignore origin_only unless LV is origin in both old and new metadata */
 	/* or LV is thin or thin pool volume */
-	if (!lv_is_thin_volume(ondisk_lv) && !lv_is_thin_pool(ondisk_lv) &&
-	    !(lv_is_origin(ondisk_lv) && lv_is_origin(incore_lv)))
+	if (!lv_is_thin_volume(lv) && !lv_is_thin_pool(lv) &&
+	    !(lv_is_origin(lv) && lv_is_origin(lv_pre)))
 		laopts->origin_only = 0;
 
 	if (test_mode()) {
-		_skip("Suspending %s%s.", ondisk_lv->name,
+		_skip("Suspending %s%s.", display_lvname(lv),
 		      laopts->origin_only ? " origin without snapshots" : "");
 		r = 1;
 		goto out;
 	}
 
-	if (!lv_info(cmd, ondisk_lv, laopts->origin_only, &info, 0, 0))
+	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
 	if (!info.exists || info.suspended) {
@@ -1840,10 +1841,10 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
-	if (!lv_read_replicator_vgs(ondisk_lv))
+	if (!lv_read_replicator_vgs(lv))
 		goto_out;
 
-	lv_calculate_readahead(ondisk_lv, NULL);
+	lv_calculate_readahead(lv, NULL);
 
 	/*
 	 * Preload devices for the LV.
@@ -1852,58 +1853,57 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	 * tables for all the changed LVs here, as the relationships
 	 * are not found by walking the new metadata.
 	 */
-	if (!lv_is_locked(incore_lv) &&
-	    lv_is_locked(ondisk_lv) &&
-	    (pvmove_lv = find_pvmove_lv_in_lv(ondisk_lv))) {
+	if (lv_is_locked(lv) && !lv_is_locked(lv_pre) &&
+	    (pvmove_lv = find_pvmove_lv_in_lv(lv))) {
 		/* Preload all the LVs above the PVMOVE LV */
 		dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
-			if (!(lv_pre = find_lv(incore_lv->vg, sl->seg->lv->name))) {
+			if (!(lv_pre_tmp = find_lv(lv_pre->vg, sl->seg->lv->name))) {
 				log_error(INTERNAL_ERROR "LV %s missing from preload metadata", sl->seg->lv->name);
 				goto out;
 			}
-			if (!_lv_preload(lv_pre, laopts, &flush_required))
+			if (!_lv_preload(lv_pre_tmp, laopts, &flush_required))
 				goto_out;
 		}
 		/* Now preload the PVMOVE LV itself */
-		if (!(lv_pre = find_lv(incore_lv->vg, pvmove_lv->name))) {
+		if (!(lv_pre_tmp = find_lv(lv_pre->vg, pvmove_lv->name))) {
 			log_error(INTERNAL_ERROR "LV %s missing from preload metadata", pvmove_lv->name);
 			goto out;
 		}
-		if (!_lv_preload(lv_pre, laopts, &flush_required))
+		if (!_lv_preload(lv_pre_tmp, laopts, &flush_required))
 			goto_out;
 	} else {
-		if (!_lv_preload(incore_lv, laopts, &flush_required))
+		if (!_lv_preload(lv_pre, laopts, &flush_required))
 			/* FIXME Revert preloading */
 			goto_out;
 
 		/*
 		 * Search for existing LVs that have become detached and preload them.
 		 */
-		detached.lv_pre = incore_lv;
+		detached.lv_pre = lv_pre;
 		detached.laopts = laopts;
 		detached.flush_required = &flush_required;
 
-		if (!for_each_sub_lv((struct logical_volume *)ondisk_lv, &_preload_detached_lv, &detached))
+		if (!for_each_sub_lv((struct logical_volume *)lv, &_preload_detached_lv, &detached))
 			goto_out;
 
 		/*
 		 * Preload any snapshots that are being removed.
 		 */
-		if (!laopts->origin_only && lv_is_origin(ondisk_lv)) {
-        		dm_list_iterate_items_gen(snap_seg, &ondisk_lv->snapshot_segs, origin_list) {
-				if (!(lv_pre = find_lv_in_vg_by_lvid(incore_lv->vg, &snap_seg->cow->lvid))) {
+		if (!laopts->origin_only && lv_is_origin(lv)) {
+			dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list) {
+				if (!(lv_pre_tmp = find_lv_in_vg_by_lvid(lv_pre->vg, &snap_seg->cow->lvid))) {
 					log_error(INTERNAL_ERROR "LV %s (%s) missing from preload metadata",
 						  snap_seg->cow->name, snap_seg->cow->lvid.id[1].uuid);
 					goto out;
 				}
-				if (!lv_is_cow(lv_pre) &&
-				    !_lv_preload(lv_pre, laopts, &flush_required))
+				if (!lv_is_cow(lv_pre_tmp) &&
+				    !_lv_preload(lv_pre_tmp, laopts, &flush_required))
 					goto_out;
 			}
 		}
 	}
 
-	if (!monitor_dev_for_events(cmd, ondisk_lv, laopts, 0))
+	if (!monitor_dev_for_events(cmd, lv, laopts, 0))
 		/* FIXME Consider aborting here */
 		stack;
 
@@ -1912,14 +1912,14 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		critical_section_inc(cmd, "suspending pvmove LV");
 
 	if (!laopts->origin_only &&
-	    (lv_is_origin(incore_lv) || lv_is_cow(incore_lv)))
+	    (lv_is_origin(lv_pre) || lv_is_cow(lv_pre)))
 		lockfs = 1;
 
 	/* Converting non-thin LV to thin external origin ? */
-	if (!lv_is_thin_volume(ondisk_lv) && lv_is_thin_volume(incore_lv))
+	if (!lv_is_thin_volume(lv) && lv_is_thin_volume(lv_pre))
 		lockfs = 1; /* Sync before conversion */
 
-	if (laopts->origin_only && lv_is_thin_volume(ondisk_lv) && lv_is_thin_volume(incore_lv))
+	if (laopts->origin_only && lv_is_thin_volume(lv) && lv_is_thin_volume(lv_pre))
 		lockfs = 1;
 
 	/*
@@ -1930,9 +1930,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
  	 * inactive table to load or not instead so lv_suspend
  	 * can be called separately for each LV safely.
  	 */
-	if ((incore_lv->vg->status & PRECOMMITTED) &&
-	    lv_is_locked(incore_lv) && find_pvmove_lv_in_lv(incore_lv)) {
-		if (!_lv_suspend_lv(incore_lv, laopts, lockfs, flush_required)) {
+	if ((lv_pre->vg->status & PRECOMMITTED) &&
+	    lv_is_locked(lv_pre) && find_pvmove_lv_in_lv(lv_pre)) {
+		if (!_lv_suspend_lv(lv_pre, laopts, lockfs, flush_required)) {
 			critical_section_dec(cmd, "failed precommitted suspend");
 			if (pvmove_lv)
 				critical_section_dec(cmd, "failed precommitted suspend (pvmove)");
@@ -1940,7 +1940,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		}
 	} else {
 		/* Normal suspend */
-		if (!_lv_suspend_lv(ondisk_lv, laopts, lockfs, flush_required)) {
+		if (!_lv_suspend_lv(lv, laopts, lockfs, flush_required)) {
 			critical_section_dec(cmd, "failed suspend");
 			if (pvmove_lv)
 				critical_section_dec(cmd, "failed suspend (pvmove)");
@@ -1950,11 +1950,11 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 
 	r = 1;
 out:
-	if (incore_lv_to_free)
-		release_vg(incore_lv_to_free->vg);
-	if (ondisk_lv_to_free) {
-		lv_release_replicator_vgs(ondisk_lv_to_free);
-		release_vg(ondisk_lv_to_free->vg);
+	if (lv_pre_to_free)
+		release_vg(lv_pre_to_free->vg);
+	if (lv_to_free) {
+		lv_release_replicator_vgs(lv_to_free);
+		release_vg(lv_to_free->vg);
 	}
 
 	return r;
@@ -1967,14 +1967,14 @@ out:
  * Returns success if the device is not active
  */
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive,
-			 const struct logical_volume *ondisk_lv, const struct logical_volume *incore_lv)
+			 const struct logical_volume *lv, const struct logical_volume *lv_pre)
 {
 	struct lv_activate_opts laopts = {
 		.origin_only = origin_only,
 		.exclusive = exclusive
 	};
 
-	return _lv_suspend(cmd, lvid_s, &laopts, 0, ondisk_lv, incore_lv);
+	return _lv_suspend(cmd, lvid_s, &laopts, 0, lv, lv_pre);
 }
 
 /* No longer used */
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 01d6444..2c339c0 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -106,7 +106,7 @@ void activation_exit(void);
 
 /* int lv_suspend(struct cmd_context *cmd, const char *lvid_s); */
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive,
-			 const struct logical_volume *lv_ondisk, const struct logical_volume *lv_incore);
+			 const struct logical_volume *lv, const struct logical_volume *lv_pre);
 int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, const struct logical_volume *lv);
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned origin_only, unsigned exclusive, unsigned revert, const struct logical_volume *lv);



From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 10 Jun 2013 20:51:11 +0000 (UTC)
Subject: master - activation: Pass both ondisk and incore LV to suspend.
Message-ID: <20130610205111.0F14D60FB9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d644443e0f496f1cc34a5b2a9c66e96b3160b97
Commit:        7d644443e0f496f1cc34a5b2a9c66e96b3160b97
Parent:        2cce2f67abf488eaed94902d415dd6f106c84229
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Mar 20 00:00:11 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jun 10 17:26:38 2013 +0200

activation: Pass both ondisk and incore LV to suspend.

---
 daemons/clvmd/lvm-functions.c |    2 +-
 lib/activate/activate.c       |   71 +++++++++++++++++++++--------------------
 lib/activate/activate.h       |    2 +-
 lib/locking/file_locking.c    |    2 +-
 lib/locking/no_locking.c      |    4 +-
 5 files changed, 41 insertions(+), 40 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 99d2eb3..c7f3488 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -450,7 +450,7 @@ static int do_suspend_lv(char *resource, unsigned char command, unsigned char lo
 	exclusive = (oldmode == LCK_EXCL) ? 1 : 0;
 
 	/* Always call lv_suspend to read commited and precommited data */
-	if (!lv_suspend_if_active(cmd, resource, origin_only, exclusive, NULL))
+	if (!lv_suspend_if_active(cmd, resource, origin_only, exclusive, NULL, NULL))
 		return EIO;
 
 	return 0;
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 15e684a..a69b725 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1616,9 +1616,9 @@ static int _preload_detached_lv(struct cmd_context *cmd, struct logical_volume *
 
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		       struct lv_activate_opts *laopts, int error_if_not_suspended,
-	               struct logical_volume *lv)
+	               struct logical_volume *ondisk_lv, struct logical_volume *incore_lv)
 {
-	struct logical_volume *lv_pre = NULL, *pvmove_lv = NULL, *lv_to_free = NULL;
+	struct logical_volume *pvmove_lv = NULL, *ondisk_lv_to_free = NULL, *incore_lv_to_free = NULL;
 	struct lv_list *lvl_pre;
 	struct seg_list *sl;
         struct lv_segment *snap_seg;
@@ -1629,24 +1629,25 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (!activation())
 		return 1;
 
-	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
+	if (!ondisk_lv && !(ondisk_lv_to_free = ondisk_lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto_out;
 
 	/* Use precommitted metadata if present */
-	if (!(lv_pre = lv_from_lvid(cmd, lvid_s, 1)))
+	if (!incore_lv && !(incore_lv_to_free = incore_lv = lv_from_lvid(cmd, lvid_s, 1)))
 		goto_out;
 
 	/* Ignore origin_only unless LV is origin in both old and new metadata */
-	if (!lv_is_thin_volume(lv) && !(lv_is_origin(lv) && lv_is_origin(lv_pre)))
+	if (!lv_is_thin_volume(ondisk_lv) && !(lv_is_origin(ondisk_lv) && lv_is_origin(incore_lv)))
 		laopts->origin_only = 0;
 
 	if (test_mode()) {
-		_skip("Suspending %s%s.", lv->name, laopts->origin_only ? " origin without snapshots" : "");
+		_skip("Suspending %s%s.", ondisk_lv->name,
+		      laopts->origin_only ? " origin without snapshots" : "");
 		r = 1;
 		goto out;
 	}
 
-	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
+	if (!lv_info(cmd, ondisk_lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
 	if (!info.exists || info.suspended) {
@@ -1658,10 +1659,10 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
-	if (!lv_read_replicator_vgs(lv))
+	if (!lv_read_replicator_vgs(ondisk_lv))
 		goto_out;
 
-	lv_calculate_readahead(lv, NULL);
+	lv_calculate_readahead(ondisk_lv, NULL);
 
 	/*
 	 * Preload devices for the LV.
@@ -1670,12 +1671,12 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	 * tables for all the changed LVs here, as the relationships
 	 * are not found by walking the new metadata.
 	 */
-	if (!(lv_pre->status & LOCKED) &&
-	    (lv->status & LOCKED) &&
-	    (pvmove_lv = find_pvmove_lv_in_lv(lv))) {
+	if (!(incore_lv->status & LOCKED) &&
+	    (ondisk_lv->status & LOCKED) &&
+	    (pvmove_lv = find_pvmove_lv_in_lv(ondisk_lv))) {
 		/* Preload all the LVs above the PVMOVE LV */
 		dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
-			if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, sl->seg->lv->name))) {
+			if (!(lvl_pre = find_lv_in_vg(incore_lv->vg, sl->seg->lv->name))) {
 				log_error(INTERNAL_ERROR "LV %s missing from preload metadata", sl->seg->lv->name);
 				goto out;
 			}
@@ -1683,33 +1684,33 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 				goto_out;
 		}
 		/* Now preload the PVMOVE LV itself */
-		if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, pvmove_lv->name))) {
+		if (!(lvl_pre = find_lv_in_vg(incore_lv->vg, pvmove_lv->name))) {
 			log_error(INTERNAL_ERROR "LV %s missing from preload metadata", pvmove_lv->name);
 			goto out;
 		}
 		if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
 			goto_out;
 	} else {
-		if (!_lv_preload(lv_pre, laopts, &flush_required))
+		if (!_lv_preload(incore_lv, laopts, &flush_required))
 			/* FIXME Revert preloading */
 			goto_out;
 
 		/*
 		 * Search for existing LVs that have become detached and preload them.
 		 */
-		detached.lv_pre = lv_pre;
+		detached.lv_pre = incore_lv;
 		detached.laopts = laopts;
 		detached.flush_required = &flush_required;
 
-		if (!for_each_sub_lv(cmd, lv, &_preload_detached_lv, &detached))
+		if (!for_each_sub_lv(cmd, ondisk_lv, &_preload_detached_lv, &detached))
 			goto_out;
 
 		/*
 		 * Preload any snapshots that are being removed.
 		 */
-		if (!laopts->origin_only && lv_is_origin(lv)) {
-        		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list) {
-				if (!(lvl_pre = find_lv_in_vg_by_lvid(lv_pre->vg, &snap_seg->cow->lvid))) {
+		if (!laopts->origin_only && lv_is_origin(ondisk_lv)) {
+        		dm_list_iterate_items_gen(snap_seg, &ondisk_lv->snapshot_segs, origin_list) {
+				if (!(lvl_pre = find_lv_in_vg_by_lvid(incore_lv->vg, &snap_seg->cow->lvid))) {
 					log_error(INTERNAL_ERROR "LV %s (%s) missing from preload metadata",
 						  snap_seg->cow->name, snap_seg->cow->lvid.id[1].uuid);
 					goto out;
@@ -1721,7 +1722,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		}
 	}
 
-	if (!monitor_dev_for_events(cmd, lv, laopts, 0))
+	if (!monitor_dev_for_events(cmd, ondisk_lv, laopts, 0))
 		/* FIXME Consider aborting here */
 		stack;
 
@@ -1730,14 +1731,14 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		critical_section_inc(cmd, "suspending pvmove LV");
 
 	if (!laopts->origin_only &&
-	    (lv_is_origin(lv_pre) || lv_is_cow(lv_pre)))
+	    (lv_is_origin(incore_lv) || lv_is_cow(incore_lv)))
 		lockfs = 1;
 
 	/* Converting non-thin LV to thin external origin ? */
-	if (!lv_is_thin_volume(lv) && lv_is_thin_volume(lv_pre))
+	if (!lv_is_thin_volume(ondisk_lv) && lv_is_thin_volume(incore_lv))
 		lockfs = 1; /* Sync before conversion */
 
-	if (laopts->origin_only && lv_is_thin_volume(lv) && lv_is_thin_volume(lv_pre))
+	if (laopts->origin_only && lv_is_thin_volume(ondisk_lv) && lv_is_thin_volume(incore_lv))
 		lockfs = 1;
 
 	/*
@@ -1748,9 +1749,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
  	 * inactive table to load or not instead so lv_suspend
  	 * can be called separately for each LV safely.
  	 */
-	if ((lv_pre->vg->status & PRECOMMITTED) &&
-	    (lv_pre->status & LOCKED) && find_pvmove_lv_in_lv(lv_pre)) {
-		if (!_lv_suspend_lv(lv_pre, laopts, lockfs, flush_required)) {
+	if ((incore_lv->vg->status & PRECOMMITTED) &&
+	    (incore_lv->status & LOCKED) && find_pvmove_lv_in_lv(incore_lv)) {
+		if (!_lv_suspend_lv(incore_lv, laopts, lockfs, flush_required)) {
 			critical_section_dec(cmd, "failed precommitted suspend");
 			if (pvmove_lv)
 				critical_section_dec(cmd, "failed precommitted suspend (pvmove)");
@@ -1758,7 +1759,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		}
 	} else {
 		/* Normal suspend */
-		if (!_lv_suspend_lv(lv, laopts, lockfs, flush_required)) {
+		if (!_lv_suspend_lv(ondisk_lv, laopts, lockfs, flush_required)) {
 			critical_section_dec(cmd, "failed suspend");
 			if (pvmove_lv)
 				critical_section_dec(cmd, "failed suspend (pvmove)");
@@ -1768,11 +1769,11 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 
 	r = 1;
 out:
-	if (lv_pre)
-		release_vg(lv_pre->vg);
-	if (lv_to_free) {
-		lv_release_replicator_vgs(lv_to_free);
-		release_vg(lv_to_free->vg);
+	if (incore_lv_to_free)
+		release_vg(incore_lv_to_free->vg);
+	if (ondisk_lv_to_free) {
+		lv_release_replicator_vgs(ondisk_lv_to_free);
+		release_vg(ondisk_lv_to_free->vg);
 	}
 
 	return r;
@@ -1784,14 +1785,14 @@ out:
  *
  * Returns success if the device is not active
  */
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive, struct logical_volume *lv)
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive, struct logical_volume *ondisk_lv, struct logical_volume *incore_lv)
 {
 	struct lv_activate_opts laopts = {
 		.origin_only = origin_only,
 		.exclusive = exclusive
 	};
 
-	return _lv_suspend(cmd, lvid_s, &laopts, 0, lv);
+	return _lv_suspend(cmd, lvid_s, &laopts, 0, ondisk_lv, incore_lv);
 }
 
 /* No longer used */
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 7446bec..1cbb67f 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -75,7 +75,7 @@ void activation_release(void);
 void activation_exit(void);
 
 /* int lv_suspend(struct cmd_context *cmd, const char *lvid_s); */
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive, struct logical_volume *lv);
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive, struct logical_volume *lv_ondisk, struct logical_volume *lv_incore);
 int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, struct logical_volume *lv);
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned origin_only, unsigned exclusive, unsigned revert, struct logical_volume *lv);
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 2854015..934bfe2 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -313,7 +313,7 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			break;
 		case LCK_WRITE:
 			log_very_verbose("Locking LV %s (W)%s", resource, origin_only ? " without snapshots" : "");
-			if (!lv_suspend_if_active(cmd, resource, origin_only, 0, lv_ondisk(lv)))
+			if (!lv_suspend_if_active(cmd, resource, origin_only, 0, lv_ondisk(lv), lv))
 				return 0;
 			break;
 		case LCK_EXCL:
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index f6f76cf..b1b235c 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -46,11 +46,11 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 		case LCK_NULL:
 			return lv_deactivate(cmd, resource, lv_ondisk(lv));
 		case LCK_UNLOCK:
-			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0, (flags & LCK_REVERT) ? 1 : 0, NULL);
+			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0, (flags & LCK_REVERT) ? 1 : 0, lv_ondisk(lv));
 		case LCK_READ:
 			return lv_activate_with_filter(cmd, resource, 0, lv_ondisk(lv));
 		case LCK_WRITE:
-			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0, 0, lv);
+			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0, 0, lv_ondisk(lv), lv);
 		case LCK_EXCL:
 			return lv_activate_with_filter(cmd, resource, 1, lv_ondisk(lv));
 		default:



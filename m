From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue, 16 Sep 2014 15:35:05 +0000 (UTC)
Subject: dev-mcsontos-clvmd-stack-overflow - cleanup: Use lv_is_ macros.
Message-ID: <20140916153505.E7A846027D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2360ce3551f2989f1cc2af06c3d3a0a0f1429bce
Commit:        2360ce3551f2989f1cc2af06c3d3a0a0f1429bce
Parent:        10a448eb2fdc795d144f13ba4a7d83351eb8c9df
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 15 21:33:53 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 15 21:33:53 2014 +0100

cleanup: Use lv_is_ macros.

Use lv_is_* macros throughout the code base, introducing
lv_is_pvmove, lv_is_locked, lv_is_converting and lv_is_merging.

lv_is_mirror_type no longer includes pvmove.
---
 WHATS_NEW                        |    1 +
 lib/activate/activate.c          |   12 ++--
 lib/activate/dev_manager.c       |    9 +--
 lib/display/display.c            |    4 +-
 lib/format_text/export.c         |    4 +-
 lib/format_text/import_vsn1.c    |    2 +-
 lib/metadata/lv.c                |   36 +++++-----
 lib/metadata/lv_manip.c          |   40 ++++++------
 lib/metadata/merge.c             |   10 ++--
 lib/metadata/metadata-exported.h |  141 ++++++++++++++++++++-----------------
 lib/metadata/metadata.c          |    2 +-
 lib/metadata/mirror.c            |   20 +++---
 lib/metadata/snapshot_manip.c    |    3 +-
 lib/report/report.c              |   12 ++--
 lib/snapshot/snapshot.c          |    1 +
 liblvm/lvm_lv.c                  |    4 +-
 tools/lvchange.c                 |   20 +++---
 tools/lvconvert.c                |   40 ++++++------
 tools/lvrename.c                 |    4 +-
 tools/pvmove.c                   |   15 ++--
 tools/toollib.c                  |   10 ++--
 tools/vgchange.c                 |    6 +-
 tools/vgreduce.c                 |    4 +-
 tools/vgsplit.c                  |    4 +-
 24 files changed, 208 insertions(+), 196 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c48b979..3c02440 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Introduce lv_is_pvmove/locked/converting/merging macros.
   Avoid leaving linear logical volume when thin pool creation fails.
   Demote an error to a warning when devices known to lvmetad are filtered out.
   Re-order filter evaluation, making component filters global.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 9a4a1c3..2091fa1 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1273,7 +1273,7 @@ static int _lv_activate_lv(struct logical_volume *lv, struct lv_activate_opts *l
 	int r;
 	struct dev_manager *dm;
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, !lv_is_pvmove(lv))))
 		return_0;
 
 	if (!(r = dev_manager_activate(dm, lv, laopts)))
@@ -1290,7 +1290,7 @@ static int _lv_preload(struct logical_volume *lv, struct lv_activate_opts *laopt
 	struct dev_manager *dm;
 	int old_readonly = laopts->read_only;
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, !lv_is_pvmove(lv))))
 		goto_out;
 
 	laopts->read_only = _passes_readonly_filter(lv->vg->cmd, lv);
@@ -1332,7 +1332,7 @@ static int _lv_suspend_lv(struct logical_volume *lv, struct lv_activate_opts *la
 	 * When we are asked to manipulate (normally suspend/resume) the PVMOVE
 	 * device directly, we don't want to touch the devices that use it.
 	 */
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, !lv_is_pvmove(lv))))
 		return_0;
 
 	if (!(r = dev_manager_suspend(dm, lv, laopts, lockfs, flush_required)))
@@ -1872,8 +1872,8 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	 * tables for all the changed LVs here, as the relationships
 	 * are not found by walking the new metadata.
 	 */
-	if (!(incore_lv->status & LOCKED) &&
-	    (ondisk_lv->status & LOCKED) &&
+	if (!lv_is_locked(incore_lv) &&
+	    lv_is_locked(ondisk_lv) &&
 	    (pvmove_lv = find_pvmove_lv_in_lv(ondisk_lv))) {
 		/* Preload all the LVs above the PVMOVE LV */
 		dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
@@ -1951,7 +1951,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
  	 * can be called separately for each LV safely.
  	 */
 	if ((incore_lv->vg->status & PRECOMMITTED) &&
-	    (incore_lv->status & LOCKED) && find_pvmove_lv_in_lv(incore_lv)) {
+	    lv_is_locked(incore_lv) && find_pvmove_lv_in_lv(incore_lv)) {
 		if (!_lv_suspend_lv(incore_lv, laopts, lockfs, flush_required)) {
 			critical_section_dec(cmd, "failed precommitted suspend");
 			if (pvmove_lv)
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d336afc..c5581eb 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1150,7 +1150,7 @@ int dev_manager_raid_message(struct dev_manager *dm,
 	struct dm_task *dmt;
 	const char *layer = lv_layer(lv);
 
-	if (!(lv->status & RAID)) {
+	if (!lv_is_raid(lv)) {
 		log_error(INTERNAL_ERROR "%s/%s is not a RAID logical volume",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -1978,7 +1978,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	/* Add any LVs referencing a PVMOVE LV unless told not to. */
-	if (dm->track_pvmove_deps && lv->status & PVMOVE) {
+	if (dm->track_pvmove_deps && lv_is_pvmove(lv)) {
 		dm->track_pvmove_deps = 0;
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
 			if (!_add_lv_to_dtree(dm, dtree, sl->seg->lv, origin_only))
@@ -2729,7 +2729,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	dm_tree_node_set_read_ahead(dnode, read_ahead, read_ahead_flags);
 
 	/* Add any LVs referencing a PVMOVE LV unless told not to */
-	if (dm->track_pvmove_deps && (lv->status & PVMOVE))
+	if (dm->track_pvmove_deps && lv_is_pvmove(lv))
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
 			if (!_add_new_lv_to_dtree(dm, dtree, sl->seg->lv, laopts, NULL))
 				return_0;
@@ -2917,8 +2917,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
-		if (!dm->flush_required && !seg_is_raid(first_seg(lv)) &&
-		    (lv->status & MIRRORED) && !(lv->status & PVMOVE))
+		if (!dm->flush_required && !seg_is_raid(first_seg(lv)) && lv_is_mirrored(lv) && !lv_is_pvmove(lv))
 			dm_tree_use_no_flush_suspend(root);
 		/* Fall through */
 	case SUSPEND_WITH_LOCKFS:
diff --git a/lib/display/display.c b/lib/display/display.c
index 1b92b31..d12c393 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -587,10 +587,10 @@ int lvdisplay_full(struct cmd_context *cmd,
 			  display_size(cmd, (uint64_t) snap_seg->chunk_size));
 	}
 
-	if (lv->status & MIRRORED) {
+	if (lv_is_mirrored(lv)) {
 		mirror_seg = first_seg(lv);
 		log_print("Mirrored volumes       %" PRIu32, mirror_seg->area_count);
-		if (lv->status & CONVERTING)
+		if (lv_is_converting(lv))
 			log_print("LV type        Mirror undergoing conversion");
 	}
 
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index bea97de..7ffb4e3 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -563,8 +563,8 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 			}
 
 			/* RAID devices are laid-out in metadata/data pairs */
-			if (!(seg_lv(seg, s)->status & RAID_IMAGE) ||
-			    !(seg_metalv(seg, s)->status & RAID_META)) {
+			if (!lv_is_raid_image(seg_lv(seg, s)) ||
+			    !lv_is_raid_metadata(seg_metalv(seg, s))) {
 				log_error("RAID segment has non-RAID areas");
 				return 0;
 			}
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 7d4304e..9ddf99e 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -99,7 +99,7 @@ static int _is_converting(struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 
-	if (lv->status & MIRRORED) {
+	if (lv_is_mirrored(lv)) {
 		seg = first_seg(lv);
 		/* Can't use is_temporary_mirror() because the metadata for
 		 * seg_lv may not be read in and flags may not be set yet. */
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 0fbdfff..a8ad2d2 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -340,7 +340,7 @@ char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 
-	if (lv->status & (CONVERTING|MIRRORED)) {
+	if (lv_is_converting(lv) || lv_is_mirrored(lv)) {
 		seg = first_seg(lv);
 
 		/* Temporary mirror is always area_num == 0 */
@@ -361,7 +361,7 @@ char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		if (seg->status & PVMOVE) {
 			if (seg_type(seg, 0) == AREA_LV) { /* atomic pvmove */
 				mimage0_lv = seg_lv(seg, 0);
-				if (!lv_is_mirror_type(mimage0_lv)) {
+				if (!lv_is_mirrored(mimage0_lv)) {
 					log_error(INTERNAL_ERROR
 						  "Bad pvmove structure");
 					return NULL;
@@ -505,7 +505,7 @@ int lv_raid_image_in_sync(const struct logical_volume *lv)
 	if (!lv_is_active_locally(lv))
 		return 0;  /* Assume not in-sync */
 
-	if (!(lv->status & RAID_IMAGE)) {
+	if (!lv_is_raid_image(lv)) {
 		log_error(INTERNAL_ERROR "%s is not a RAID image", lv->name);
 		return 0;
 	}
@@ -573,7 +573,7 @@ int lv_raid_healthy(const struct logical_volume *lv)
 		return 0;
 	}
 
-	if (lv->status & RAID)
+	if (lv_is_raid(lv))
 		raid_seg = first_seg(lv);
 	else if ((seg = first_seg(lv)))
 		raid_seg = get_only_segment_using_this_lv(seg->lv);
@@ -592,7 +592,7 @@ int lv_raid_healthy(const struct logical_volume *lv)
 	if (!lv_raid_dev_health(raid_seg->lv, &raid_health))
 		return_0;
 
-	if (lv->status & RAID) {
+	if (lv_is_raid(lv)) {
 		if (strchr(raid_health, 'D'))
 			return 0;
 		else
@@ -601,8 +601,8 @@ int lv_raid_healthy(const struct logical_volume *lv)
 
 	/* Find out which sub-LV this is. */
 	for (s = 0; s < raid_seg->area_count; s++)
-		if (((lv->status & RAID_IMAGE) && (seg_lv(raid_seg, s) == lv)) ||
-		    ((lv->status & RAID_META) && (seg_metalv(raid_seg,s) == lv)))
+		if ((lv_is_raid_image(lv) && (seg_lv(raid_seg, s) == lv)) ||
+		    (lv_is_raid_metadata(lv) && (seg_metalv(raid_seg,s) == lv)))
 			break;
 	if (s == raid_seg->area_count) {
 		log_error(INTERNAL_ERROR
@@ -633,7 +633,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	if (!*lv->name)
 		goto out;
 
-	if (lv->status & PVMOVE)
+	if (lv_is_pvmove(lv))
 		repstr[0] = 'p';
 	else if (lv->status & CONVERTING)
 		repstr[0] = 'c';
@@ -646,22 +646,22 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		repstr[0] = 'e';
 	else if (lv_is_cache_type(lv))
 		repstr[0] = 'C';
-	else if (lv->status & RAID)
+	else if (lv_is_raid(lv))
 		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'R' : 'r';
-	else if (lv->status & MIRRORED)
+	else if (lv_is_mirrored(lv))
 		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'M' : 'm';
 	else if (lv_is_thin_volume(lv))
 		repstr[0] = lv_is_merging_origin(lv) ?
 			'O' : (lv_is_merging_thin_snapshot(lv) ? 'S' : 'V');
-	else if (lv->status & VIRTUAL)
+	else if (lv_is_virtual(lv))
 		repstr[0] = 'v';
 	else if (lv_is_thin_pool(lv))
 		repstr[0] = 't';
 	else if (lv_is_thin_pool_data(lv))
 		repstr[0] = 'T';
-	else if (lv->status & MIRROR_IMAGE)
+	else if (lv_is_mirror_image(lv))
 		repstr[0] = (lv_mirror_image_in_sync(lv)) ? 'i' : 'I';
-	else if (lv->status & RAID_IMAGE)
+	else if (lv_is_raid_image(lv))
 		/*
 		 * Visible RAID_IMAGES are sub-LVs that have been exposed for
 		 * top-level use by being split from the RAID array with
@@ -669,7 +669,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		 */
 		repstr[0] = (!lv_is_visible(lv) && lv_raid_image_in_sync(lv)) ?
 			'i' : 'I';
-	else if (lv->status & MIRROR_LOG)
+	else if (lv_is_mirror_log(lv))
 		repstr[0] = 'l';
 	else if (lv_is_cow(lv))
 		repstr[0] = (lv_is_merging_cow(lv)) ? 'S' : 's';
@@ -678,7 +678,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	else
 		repstr[0] = '-';
 
-	if (lv->status & PVMOVE)
+	if (lv_is_pvmove(lv))
 		repstr[1] = '-';
 	else if (lv->status & LVM_WRITE)
 		repstr[1] = 'w';
@@ -689,7 +689,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 	repstr[2] = alloc_policy_char(lv->alloc);
 
-	if (lv->status & LOCKED)
+	if (lv_is_locked(lv))
 		repstr[2] = toupper(repstr[2]);
 
 	repstr[3] = (lv->status & FIXED_MINOR) ? 'm' : '-';
@@ -743,7 +743,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		repstr[6] = 'C';
 	else if (lv_is_raid_type(lv))
 		repstr[6] = 'r';
-	else if (lv_is_mirror_type(lv))
+	else if (lv_is_mirror_type(lv) || lv_is_pvmove(lv))
 		repstr[6] = 'm';
 	else if (lv_is_cow(lv) || lv_is_origin(lv))
 		repstr[6] = 's';
@@ -770,7 +770,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 			repstr[8] = 'X';	/* Unknown */
 		else if (!lv_raid_healthy(lv))
 			repstr[8] = 'r';  /* RAID needs 'r'efresh */
-		else if (lv->status & RAID) {
+		else if (lv_is_raid(lv)) {
 			if (lv_raid_mismatch_count(lv, &n) && n)
 				repstr[8] = 'm';  /* RAID has 'm'ismatches */
 		} else if (lv->status & LV_WRITEMOSTLY)
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 12585ef..6d80dfb 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -191,7 +191,7 @@ static int _lv_layout_and_role_mirror(struct dm_pool *mem,
 		if (lv_is_mirrored(lv) &&
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_MIRROR]))
 			goto_bad;
-	} else if (lv->status & PVMOVE) {
+	} else if (lv_is_pvmove(lv)) {
 		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_PVMOVE]) ||
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_MIRROR]))
 			goto_bad;
@@ -464,7 +464,7 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 	}
 
 	/* Mirrors and related */
-	if (lv_is_mirror_type(lv) && !lv_is_raid(lv) &&
+	if ((lv_is_mirror_type(lv) || lv_is_pvmove(lv)) && !lv_is_raid(lv) &&
 	    !_lv_layout_and_role_mirror(mem, lv, *layout, *role, &public_lv))
 		goto_bad;
 
@@ -1035,9 +1035,9 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		return 1;
 	}
 
-	if ((seg_lv(seg, s)->status & MIRROR_IMAGE) ||
-	    (seg_lv(seg, s)->status & THIN_POOL_DATA) ||
-	    (seg_lv(seg, s)->status & CACHE_POOL_DATA)) {
+	if (lv_is_mirror_image(seg_lv(seg, s)) ||
+	    lv_is_thin_pool_data(seg_lv(seg, s)) ||
+	    lv_is_cache_pool_data(seg_lv(seg, s))) {
 		if (!lv_reduce(seg_lv(seg, s), area_reduction))
 			return_0; /* FIXME: any upper level reporting */
 		return 1;
@@ -1052,7 +1052,7 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 			return_0;
 	}
 
-	if (seg_lv(seg, s)->status & RAID_IMAGE) {
+	if (lv_is_raid_image(seg_lv(seg, s))) {
 		/*
 		 * FIXME: Use lv_reduce not lv_remove
 		 *  We use lv_remove for now, because I haven't figured out
@@ -3203,7 +3203,7 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 	struct segment_type *segtype;
 	struct logical_volume *orig_lv, *copy_lv;
 
-	if (!(lv->status & PVMOVE)) {
+	if (!lv_is_pvmove(lv)) {
 		log_error(INTERNAL_ERROR
 			  "Non-pvmove LV, %s, passed as argument", lv->name);
 		return 0;
@@ -3803,7 +3803,7 @@ static int _rename_single_lv(struct logical_volume *lv, char *new_name)
 		return 0;
 	}
 
-	if (lv->status & LOCKED) {
+	if (lv_is_locked(lv)) {
 		log_error("Cannot rename locked LV %s", lv->name);
 		return 0;
 	}
@@ -3954,7 +3954,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (lv->status & LOCKED) {
+	if (lv_is_locked(lv)) {
 		log_error("Cannot rename locked LV %s", lv->name);
 		return 0;
 	}
@@ -4316,7 +4316,7 @@ static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv
 		return 0;
 	}
 
-	if (lv->status & (RAID_IMAGE | RAID_META)) {
+	if (lv_is_raid_image(lv) || lv_is_raid_metadata(lv)) {
 		log_error("Cannot resize a RAID %s directly",
 			  (lv->status & RAID_IMAGE) ? "image" :
 			  "metadata area");
@@ -4356,12 +4356,12 @@ static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv
 		return 0;
 	}
 
-	if (lv->status & LOCKED) {
+	if (lv_is_locked(lv)) {
 		log_error("Can't resize locked LV %s", lv->name);
 		return 0;
 	}
 
-	if (lv->status & CONVERTING) {
+	if (lv_is_converting(lv)) {
 		log_error("Can't resize %s while lvconvert in progress", lv->name);
 		return 0;
 	}
@@ -5379,19 +5379,19 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (lv->status & MIRROR_IMAGE) {
+	if (lv_is_mirror_image(lv)) {
 		log_error("Can't remove logical volume %s used by a mirror",
 			  lv->name);
 		return 0;
 	}
 
-	if (lv->status & MIRROR_LOG) {
+	if (lv_is_mirror_log(lv)) {
 		log_error("Can't remove logical volume %s used as mirror log",
 			  lv->name);
 		return 0;
 	}
 
-	if (lv->status & (RAID_META | RAID_IMAGE)) {
+	if (lv_is_raid_metadata(lv) || lv_is_raid_image(lv)) {
 		log_error("Can't remove logical volume %s used as RAID device",
 			  lv->name);
 		return 0;
@@ -5405,7 +5405,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	} else if (lv_is_thin_volume(lv))
 		pool_lv = first_seg(lv)->pool_lv;
 
-	if (lv->status & LOCKED) {
+	if (lv_is_locked(lv)) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;
 	}
@@ -6615,7 +6615,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		if (pool_lv->status & LOCKED) {
+		if (lv_is_locked(pool_lv)) {
 			log_error("Caching locked devices is not supported.");
 			return NULL;
 		}
@@ -6641,7 +6641,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		if (org->status & LOCKED) {
+		if (lv_is_locked(org)) {
 			log_error("Caching locked devices is not supported.");
 			return NULL;
 		}
@@ -6670,7 +6670,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		if (org->status & LOCKED) {
+		if (lv_is_locked(org)) {
 			log_error("Snapshots of locked devices are not supported.");
 			return NULL;
 		}
@@ -6703,7 +6703,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 					  "supported yet.");
 				return NULL;
 			}
-			if (org->status & LOCKED) {
+			if (lv_is_locked(org)) {
 				log_error("Snapshots of locked devices are not "
 					  "supported yet");
 				return NULL;
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 5aa7d00..37026d1 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -45,12 +45,12 @@ int lv_merge_segments(struct logical_volume *lv)
 	 * having a matching segment structure.
 	 */
 
-	if (lv->status & LOCKED || lv->status & PVMOVE)
+	if (lv_is_locked(lv) || lv_is_pvmove(lv))
 		return 1;
 
-	if ((lv->status & MIRROR_IMAGE) &&
+	if (lv_is_mirror_image(lv) &&
 	    (seg = get_only_segment_using_this_lv(lv)) &&
-	    (seg->lv->status & LOCKED || seg->lv->status & PVMOVE))
+	    (lv_is_locked(seg->lv) || lv_is_pvmove(seg->lv)))
 		return 1;
 
 	dm_list_iterate_safe(segh, t, &lv->segments) {
@@ -159,7 +159,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		 * Check mirror log - which is attached to the mirrored seg
 		 */
 		if (complete_vg && seg->log_lv && seg_is_mirrored(seg)) {
-			if (!(seg->log_lv->status & MIRROR_LOG)) {
+			if (!lv_is_mirror_log(seg->log_lv)) {
 				log_error("LV %s: segment %u log LV %s is not "
 					  "a mirror log",
 					  lv->name, seg_count, seg->log_lv->name);
@@ -346,7 +346,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				}
 
 				if (complete_vg && seg_lv(seg, s) &&
-				    (seg_lv(seg, s)->status & MIRROR_IMAGE) &&
+				    lv_is_mirror_image(seg_lv(seg, s)) &&
 				    (!(seg2 = find_seg_by_le(seg_lv(seg, s),
 							    seg_le(seg, s))) ||
 				     find_mirror_seg(seg2) != seg)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b0ca632..0026ba9 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -42,62 +42,62 @@
 /* Various flags */
 /* Note that the bits no longer necessarily correspond to LVM1 disk format */
 
-#define PARTIAL_VG		UINT64_C(0x00000001)	/* VG */
-#define EXPORTED_VG		UINT64_C(0x00000002)	/* VG PV */
-#define RESIZEABLE_VG		UINT64_C(0x00000004)	/* VG */
+#define PARTIAL_VG		UINT64_C(0x0000000000000001)	/* VG */
+#define EXPORTED_VG		UINT64_C(0x0000000000000002)	/* VG PV */
+#define RESIZEABLE_VG		UINT64_C(0x0000000000000004)	/* VG */
 
 /* May any free extents on this PV be used or must they be left free? */
-#define ALLOCATABLE_PV		UINT64_C(0x00000008)	/* PV */
+#define ALLOCATABLE_PV		UINT64_C(0x0000000000000008)	/* PV */
 #define ARCHIVED_VG		ALLOCATABLE_PV		/* VG, reuse same bit */
 
-//#define SPINDOWN_LV		UINT64_C(0x00000010)	/* LV */
-//#define BADBLOCK_ON		UINT64_C(0x00000020)	/* LV */
-#define VISIBLE_LV		UINT64_C(0x00000040)	/* LV */
-#define FIXED_MINOR		UINT64_C(0x00000080)	/* LV */
+//#define SPINDOWN_LV		UINT64_C(0x0000000000000010)	/* LV */
+//#define BADBLOCK_ON		UINT64_C(0x0000000000000020)	/* LV */
+#define VISIBLE_LV		UINT64_C(0x0000000000000040)	/* LV */
+#define FIXED_MINOR		UINT64_C(0x0000000000000080)	/* LV */
 
-#define LVM_READ		UINT64_C(0x00000100)	/* LV, VG */
-#define LVM_WRITE		UINT64_C(0x00000200)	/* LV, VG */
+#define LVM_READ		UINT64_C(0x0000000000000100)	/* LV, VG */
+#define LVM_WRITE		UINT64_C(0x0000000000000200)	/* LV, VG */
 
-#define CLUSTERED		UINT64_C(0x00000400)	/* VG */
-//#define SHARED		UINT64_C(0x00000800)	/* VG */
+#define CLUSTERED		UINT64_C(0x0000000000000400)	/* VG */
+//#define SHARED		UINT64_C(0x0000000000000800)	/* VG */
 
 /* FIXME Remove when metadata restructuring is completed */
-#define SNAPSHOT		UINT64_C(0x00001000)	/* LV - internal use only */
-#define PVMOVE			UINT64_C(0x00002000)	/* VG LV SEG */
-#define LOCKED			UINT64_C(0x00004000)	/* LV */
-#define MIRRORED		UINT64_C(0x00008000)	/* LV - internal use only */
-//#define VIRTUAL		UINT64_C(0x00010000)	/* LV - internal use only */
-#define MIRROR_LOG		UINT64_C(0x00020000)	/* LV */
-#define MIRROR_IMAGE		UINT64_C(0x00040000)	/* LV */
-
-#define LV_NOTSYNCED		UINT64_C(0x00080000)	/* LV */
-#define LV_REBUILD		UINT64_C(0x00100000)	/* LV */
-//#define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
-#define CONVERTING		UINT64_C(0x00400000)	/* LV */
-
-#define MISSING_PV		UINT64_C(0x00800000)	/* PV */
-#define PARTIAL_LV		UINT64_C(0x01000000)	/* LV - derived flag, not
+#define SNAPSHOT		UINT64_C(0x0000000000001000)	/* LV - internal use only */
+#define PVMOVE			UINT64_C(0x0000000000002000)	/* VG LV SEG */
+#define LOCKED			UINT64_C(0x0000000000004000)	/* LV */
+#define MIRRORED		UINT64_C(0x0000000000008000)	/* LV - internal use only */
+//#define VIRTUAL		UINT64_C(0x0000000000010000)	/* LV - internal use only */
+#define MIRROR_LOG		UINT64_C(0x0000000000020000)	/* LV - Internal use only */
+#define MIRROR_IMAGE		UINT64_C(0x0000000000040000)	/* LV - Internal use only */
+
+#define LV_NOTSYNCED		UINT64_C(0x0000000000080000)	/* LV */
+#define LV_REBUILD		UINT64_C(0x0000000000100000)	/* LV */
+//#define PRECOMMITTED		UINT64_C(0x0000000000200000)	/* VG - internal use only */
+#define CONVERTING		UINT64_C(0x0000000000400000)	/* LV */
+
+#define MISSING_PV		UINT64_C(0x0000000000800000)	/* PV */
+#define PARTIAL_LV		UINT64_C(0x0000000001000000)	/* LV - derived flag, not
 							   written out in metadata*/
 
-//#define POSTORDER_FLAG	UINT64_C(0x02000000) /* Not real flags, reserved for
-//#define POSTORDER_OPEN_FLAG	UINT64_C(0x04000000)    temporary use inside vg_read_internal. */
-//#define VIRTUAL_ORIGIN	UINT64_C(0x08000000)	/* LV - internal use only */
+//#define POSTORDER_FLAG	UINT64_C(0x0000000002000000) /* Not real flags, reserved for
+//#define POSTORDER_OPEN_FLAG	UINT64_C(0x0000000004000000)    temporary use inside vg_read_internal. */
+//#define VIRTUAL_ORIGIN	UINT64_C(0x0000000008000000)	/* LV - internal use only */
 
-#define MERGING			UINT64_C(0x10000000)	/* LV SEG */
+#define MERGING			UINT64_C(0x0000000010000000)	/* LV SEG */
 
-#define REPLICATOR		UINT64_C(0x20000000)	/* LV -internal use only for replicator */
-#define REPLICATOR_LOG		UINT64_C(0x40000000)	/* LV -internal use only for replicator-dev */
-#define UNLABELLED_PV		UINT64_C(0x80000000)	/* PV -this PV had no label written yet */
+#define REPLICATOR		UINT64_C(0x0000000020000000)	/* LV -internal use only for replicator */
+#define REPLICATOR_LOG		UINT64_C(0x0000000040000000)	/* LV -internal use only for replicator-dev */
+#define UNLABELLED_PV		UINT64_C(0x0000000080000000)	/* PV -this PV had no label written yet */
 
-#define RAID			UINT64_C(0x0000000100000000)	/* LV */
-#define RAID_META		UINT64_C(0x0000000200000000)	/* LV */
-#define RAID_IMAGE		UINT64_C(0x0000000400000000)	/* LV */
+#define RAID			UINT64_C(0x0000000100000000)	/* LV - Internal use only */
+#define RAID_META		UINT64_C(0x0000000200000000)	/* LV - Internal use only */
+#define RAID_IMAGE		UINT64_C(0x0000000400000000)	/* LV - Internal use only */
 
-#define THIN_VOLUME		UINT64_C(0x0000001000000000)	/* LV */
-#define THIN_POOL		UINT64_C(0x0000002000000000)	/* LV */
-#define THIN_POOL_DATA		UINT64_C(0x0000004000000000)	/* LV */
-#define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV */
-#define POOL_METADATA_SPARE	UINT64_C(0x0000010000000000)	/* LV internal */
+#define THIN_VOLUME		UINT64_C(0x0000001000000000)	/* LV - Internal use only */
+#define THIN_POOL		UINT64_C(0x0000002000000000)	/* LV - Internal use only */
+#define THIN_POOL_DATA		UINT64_C(0x0000004000000000)	/* LV - Internal use only */
+#define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV - Internal use only */
+#define POOL_METADATA_SPARE	UINT64_C(0x0000010000000000)	/* LV - Internal use only */
 
 #define LV_WRITEMOSTLY		UINT64_C(0x0000020000000000)	/* LV (RAID1) */
 
@@ -110,10 +110,12 @@
 									this flag dropped during single
 									LVM command execution. */
 
-#define CACHE_POOL		UINT64_C(0x0000200000000000)    /* LV */
-#define CACHE_POOL_DATA		UINT64_C(0x0000400000000000)    /* LV */
-#define CACHE_POOL_METADATA	UINT64_C(0x0000800000000000)    /* LV */
-#define CACHE			UINT64_C(0x0001000000000000)    /* LV */
+#define CACHE_POOL		UINT64_C(0x0000200000000000)    /* LV - Internal use only */
+#define CACHE_POOL_DATA		UINT64_C(0x0000400000000000)    /* LV - Internal use only */
+#define CACHE_POOL_METADATA	UINT64_C(0x0000800000000000)    /* LV - Internal use only */
+#define CACHE			UINT64_C(0x0001000000000000)    /* LV - Internal use only */
+
+/* Next unused flag:		UINT64_C(0x0002000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -162,34 +164,43 @@
 
 #define vg_is_archived(vg)	(((vg)->status & ARCHIVED_VG) ? 1 : 0)
 
+#define lv_is_locked(lv)	(((lv)->status & LOCKED) ? 1 : 0)
+#define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
+#define lv_is_merging(lv)	(((lv)->status & MERGING) ? 1 : 0)
+#define lv_is_converting(lv)	(((lv)->status & CONVERTING) ? 1 : 0)
 #define lv_is_external_origin(lv)	(((lv)->external_count > 0) ? 1 : 0)
-#define lv_is_thin_volume(lv)	(((lv)->status & (THIN_VOLUME)) ? 1 : 0)
-#define lv_is_thin_pool(lv)	(((lv)->status & (THIN_POOL)) ? 1 : 0)
-#define lv_is_used_thin_pool(lv)	(lv_is_thin_pool(lv) && !dm_list_empty(&(lv)->segs_using_this_lv))
-#define lv_is_thin_pool_data(lv)	(((lv)->status & (THIN_POOL_DATA)) ? 1 : 0)
-#define lv_is_thin_pool_metadata(lv)	(((lv)->status & (THIN_POOL_METADATA)) ? 1 : 0)
-#define lv_is_mirrored(lv)	(((lv)->status & (MIRRORED)) ? 1 : 0)
-#define lv_is_rlog(lv)		(((lv)->status & (REPLICATOR_LOG)) ? 1 : 0)
 
+#define lv_is_thin_volume(lv)	(((lv)->status & THIN_VOLUME) ? 1 : 0)
+#define lv_is_thin_pool(lv)	(((lv)->status & THIN_POOL) ? 1 : 0)
+#define lv_is_used_thin_pool(lv)	(lv_is_thin_pool(lv) && !dm_list_empty(&(lv)->segs_using_this_lv))
+#define lv_is_thin_pool_data(lv)	(((lv)->status & THIN_POOL_DATA) ? 1 : 0)
+#define lv_is_thin_pool_metadata(lv)	(((lv)->status & THIN_POOL_METADATA) ? 1 : 0)
 #define lv_is_thin_type(lv)	(((lv)->status & (THIN_POOL | THIN_VOLUME | THIN_POOL_DATA | THIN_POOL_METADATA)) ? 1 : 0)
-#define lv_is_mirror_type(lv)	(((lv)->status & (MIRROR_LOG | MIRROR_IMAGE | MIRRORED | PVMOVE)) ? 1 : 0)
-#define lv_is_mirror_image(lv)	(((lv)->status & (MIRROR_IMAGE)) ? 1 : 0)
-#define lv_is_mirror_log(lv)	(((lv)->status & (MIRROR_LOG)) ? 1 : 0)
-#define lv_is_raid(lv)		(((lv)->status & (RAID)) ? 1 : 0)
-#define lv_is_raid_image(lv)	(((lv)->status & (RAID_IMAGE)) ? 1 : 0)
-#define lv_is_raid_metadata(lv)	(((lv)->status & (RAID_META)) ? 1 : 0)
+
+#define lv_is_mirrored(lv)	(((lv)->status & MIRRORED) ? 1 : 0)
+
+#define lv_is_mirror_image(lv)	(((lv)->status & MIRROR_IMAGE) ? 1 : 0)
+#define lv_is_mirror_log(lv)	(((lv)->status & MIRROR_LOG) ? 1 : 0)
+#define lv_is_mirror_type(lv)	(((lv)->status & (MIRROR_LOG | MIRROR_IMAGE | MIRRORED)) ? 1 : 0)
+
+#define lv_is_pvmove(lv)	(((lv)->status & PVMOVE) ? 1 : 0)
+
+#define lv_is_raid(lv)		(((lv)->status & RAID) ? 1 : 0)
+#define lv_is_raid_image(lv)	(((lv)->status & RAID_IMAGE) ? 1 : 0)
+#define lv_is_raid_metadata(lv)	(((lv)->status & RAID_META) ? 1 : 0)
 #define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
 
-#define lv_is_cache(lv)		(((lv)->status & (CACHE)) ? 1 : 0)
-#define lv_is_cache_pool(lv)	(((lv)->status & (CACHE_POOL)) ? 1 : 0)
-#define lv_is_cache_pool_data(lv)	(((lv)->status & (CACHE_POOL_DATA)) ? 1 : 0)
-#define lv_is_cache_pool_metadata(lv)	(((lv)->status & (CACHE_POOL_METADATA)) ? 1 : 0)
+#define lv_is_cache(lv)		(((lv)->status & CACHE) ? 1 : 0)
+#define lv_is_cache_pool(lv)	(((lv)->status & CACHE_POOL) ? 1 : 0)
+#define lv_is_cache_pool_data(lv)	(((lv)->status & CACHE_POOL_DATA) ? 1 : 0)
+#define lv_is_cache_pool_metadata(lv)	(((lv)->status & CACHE_POOL_METADATA) ? 1 : 0)
 #define lv_is_cache_type(lv)	(((lv)->status & (CACHE | CACHE_POOL | CACHE_POOL_DATA | CACHE_POOL_METADATA)) ? 1 : 0)
 
-#define lv_is_virtual(lv)	(((lv)->status & (VIRTUAL)) ? 1 : 0)
 #define lv_is_pool(lv)		(((lv)->status & (CACHE_POOL | THIN_POOL)) ? 1 : 0)
 #define lv_is_pool_metadata(lv)		(((lv)->status & (CACHE_POOL_METADATA | THIN_POOL_METADATA)) ? 1 : 0)
-#define lv_is_pool_metadata_spare(lv)	(((lv)->status & (POOL_METADATA_SPARE)) ? 1 : 0)
+#define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
+
+#define lv_is_rlog(lv)		(((lv)->status & REPLICATOR_LOG) ? 1 : 0)
 
 int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 		       struct dm_list **layout, struct dm_list **role);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f8ffe30..2900ccc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2586,7 +2586,7 @@ int vg_validate(struct volume_group *vg)
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (!(lvl->lv->status & PVMOVE))
+		if (!lv_is_pvmove(lvl->lv))
 			continue;
 		dm_list_iterate_items(seg, &lvl->lv->segments) {
 			if (seg_is_mirrored(seg)) {
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 985bde0..4505eb9 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -42,9 +42,7 @@
  */
 int is_temporary_mirror_layer(const struct logical_volume *lv)
 {
-	if (lv->status & MIRROR_IMAGE
-	    && lv->status & MIRRORED
-	    && !(lv->status & LOCKED))
+	if (lv_is_mirror_image(lv) && lv_is_mirrored(lv) && !lv_is_locked(lv))
 		return 1;
 
 	return 0;
@@ -58,7 +56,7 @@ struct logical_volume *find_temporary_mirror(const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 
-	if (!(lv->status & MIRRORED))
+	if (!lv_is_mirrored(lv))
 		return NULL;
 
 	seg = first_seg(lv);
@@ -109,7 +107,7 @@ uint32_t lv_mirror_count(const struct logical_volume *lv)
 	struct lv_segment *seg;
 	uint32_t s, mirrors;
 
-	if (!(lv->status & MIRRORED))
+	if (!lv_is_mirrored(lv))
 		return 1;
 
 	seg = first_seg(lv);
@@ -118,7 +116,7 @@ uint32_t lv_mirror_count(const struct logical_volume *lv)
 	if (!strcmp(seg->segtype->name, "raid10"))
 		return 2;
 
-	if (lv->status & PVMOVE)
+	if (lv_is_pvmove(lv))
 		return seg->area_count;
 
 	mirrors = 0;
@@ -612,7 +610,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 	struct lv_list *lvl;
 	struct cmd_context *cmd = lv->vg->cmd;
 
-	if (!(lv->status & MIRRORED)) {
+	if (!lv_is_mirrored(lv)) {
 		log_error("Unable to split non-mirrored LV, %s",
 			  lv->name);
 		return 0;
@@ -950,7 +948,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		if (remove_log && !detached_log_lv)
 			detached_log_lv = detach_mirror_log(mirrored_seg);
 
-		if (lv->status & PVMOVE)
+		if (lv_is_pvmove(lv))
 			dm_list_iterate_items(pvmove_seg, &lv->segments)
 				pvmove_seg->status |= PVMOVE;
 	} else if (new_area_count == 0) {
@@ -1524,7 +1522,7 @@ struct logical_volume *find_pvmove_lv_in_lv(struct logical_volume *lv)
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
-			if (seg_lv(seg, s)->status & PVMOVE)
+			if (lv_is_pvmove(seg_lv(seg, s)))
 				return seg_lv(seg, s);
 		}
 	}
@@ -2116,7 +2114,7 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 	if (vg_is_clustered(lv->vg)) {
 		/* FIXME: move this test out of this function */
 		/* Skip test for pvmove mirrors, it can use local mirror */
-		if (!(lv->status & (PVMOVE | LOCKED)) &&
+		if (!lv_is_pvmove(lv) && !lv_is_locked(lv) &&
 		    lv_is_active(lv) &&
 		    !lv_is_active_exclusive_locally(lv) && /* lv_is_active_remotely */
 		    !_cluster_mirror_is_available(lv)) {
@@ -2251,7 +2249,7 @@ int lv_remove_mirrors(struct cmd_context *cmd __attribute__((unused)),
 
 	/* MIRROR_BY_LV */
 	if (seg_type(seg, 0) == AREA_LV &&
-	    seg_lv(seg, 0)->status & MIRROR_IMAGE)
+	    lv_is_mirror_image(seg_lv(seg, 0)))
 		return remove_mirror_images(lv, new_mirrors + 1,
 					    is_removable, removable_baton,
 					    log_count ? 1U : 0);
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 278edc8..dfad615 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -136,12 +136,13 @@ int lv_is_virtual_origin(const struct logical_volume *lv)
 
 int lv_is_merging_origin(const struct logical_volume *origin)
 {
-	return (origin->status & MERGING) ? 1 : 0;
+	return lv_is_merging(origin);
 }
 
 int lv_is_merging_cow(const struct logical_volume *snapshot)
 {
 	struct lv_segment *snap_seg = find_snapshot(snapshot);
+
 	/* checks lv_segment's status to see if cow is merging */
 	return (snap_seg && (snap_seg->status & MERGING)) ? 1 : 0;
 }
diff --git a/lib/report/report.c b/lib/report/report.c
index f315df4..24bc437 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1042,9 +1042,8 @@ static int _copypercent_disp(struct dm_report *rh,
 	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	if (((lv_is_raid(lv) && lv_raid_percent(lv, &percent)) ||
-
-	    ((lv->status & (PVMOVE | MIRRORED)) &&
-	     lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
+	     ((lv_is_pvmove(lv) || lv_is_mirrored(lv)) &&
+	      lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
 	    (percent != DM_PERCENT_INVALID)) {
 		percent = copy_percent(lv);
 		return dm_report_field_percent(rh, field, &percent);
@@ -1406,7 +1405,8 @@ static int _lvconverting_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data, void *private)
 {
-	int converting = (((const struct logical_volume *) data)->status & CONVERTING) != 0;
+	int converting = lv_is_converting((const struct logical_volume *) data);
+
 	return _binary_disp(rh, mem, field, converting, "converting", private);
 }
 
@@ -1417,7 +1417,7 @@ static int _lvpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 	const char *perms = "";
 
-	if (!(lvi->lv->status & PVMOVE)) {
+	if (!lv_is_pvmove(lvi->lv)) {
 		if (lvi->lv->status & LVM_WRITE) {
 			if (!lvi->info->exists)
 				perms = _str_unknown;
@@ -1447,6 +1447,7 @@ static int _lvallocationlocked_disp(struct dm_report *rh, struct dm_pool *mem,
 				    const void *data, void *private)
 {
 	int alloc_locked = (((const struct logical_volume *) data)->status & LOCKED) != 0;
+
 	return _binary_disp(rh, mem, field, alloc_locked, FIRST_NAME(lv_allocation_locked_y), private);
 }
 
@@ -1455,6 +1456,7 @@ static int _lvfixedminor_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	int fixed_minor = (((const struct logical_volume *) data)->status & FIXED_MINOR) != 0;
+
 	return _binary_disp(rh, mem, field, fixed_minor, FIRST_NAME(lv_fixed_minor_y), private);
 }
 
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index afa1a90..0557f45 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -92,6 +92,7 @@ static int _snap_text_export(const struct lv_segment *seg, struct formatter *f)
 {
 	outf(f, "chunk_size = %u", seg->chunk_size);
 	outf(f, "origin = \"%s\"", seg->origin->name);
+
 	if (!(seg->status & MERGING))
 		outf(f, "cow_store = \"%s\"", seg->cow->name);
 	else
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 89d0e92..3af1f62 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -295,13 +295,13 @@ static int _lvm_lv_activate(lv_t lv)
 		return -1;
 
 	/* FIXME: handle pvmove stuff later */
-	if (lv->status & LOCKED) {
+	if (lv_is_locked(lv)) {
 		log_error("Unable to activate locked LV");
 		return -1;
 	}
 
 	/* FIXME: handle lvconvert stuff later */
-	if (lv->status & CONVERTING) {
+	if (lv_is_converting(lv)) {
 		log_error("Unable to activate LV with in-progress lvconvert");
 		return -1;
 	}
diff --git a/tools/lvchange.c b/tools/lvchange.c
index bbb030f..c3d0b6a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -41,7 +41,7 @@ static int lvchange_permission(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if ((lv->status & MIRRORED) && (vg_is_clustered(lv->vg)) &&
+	if (lv_is_mirrored(lv) && vg_is_clustered(lv->vg) &&
 	    lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
 		log_error("Cannot change permissions of mirror \"%s\" "
 			  "while active.", lv->name);
@@ -49,9 +49,9 @@ static int lvchange_permission(struct cmd_context *cmd,
 	}
 
 	/* Not allowed to change permissions on RAID sub-LVs directly */
-	if ((lv->status & RAID_META) || (lv->status & RAID_IMAGE)) {
+	if (lv_is_raid_metadata(lv) || lv_is_raid_image(lv)) {
 		log_error("Cannot change permissions of RAID %s \"%s\"",
-			  (lv->status & RAID_IMAGE) ? "image" :
+			  lv_is_raid_image(lv) ? "image" :
 			  "metadata area", lv->name);
 		return 0;
 	}
@@ -137,7 +137,7 @@ static int lvchange_monitoring(struct cmd_context *cmd,
 	}
 
 	/* do not monitor pvmove lv's */
-	if (lv->status & PVMOVE)
+	if (lv_is_pvmove(lv))
 		return 1;
 
 	if ((dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) &&
@@ -287,18 +287,18 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 	dm_list_init(&device_list);
 
-	if (!(lv->status & MIRRORED) && !seg_is_raid(seg)) {
+	if (lv_is_mirrored(lv) && !seg_is_raid(seg)) {
 		log_error("Unable to resync %s.  It is not RAID or mirrored.",
 			  lv->name);
 		return 0;
 	}
 
-	if (lv->status & PVMOVE) {
+	if (lv_is_pvmove(lv)) {
 		log_error("Unable to resync pvmove volume %s", lv->name);
 		return 0;
 	}
 
-	if (lv->status & LOCKED) {
+	if (lv_is_locked(lv)) {
 		log_error("Unable to resync locked volume %s", lv->name);
 		return 0;
 	}
@@ -859,19 +859,19 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (lv->status & PVMOVE) {
+	if (lv_is_pvmove(lv)) {
 		log_error("Unable to change pvmove LV %s", lv->name);
 		if (arg_count(cmd, activate_ARG))
 			log_error("Use 'pvmove --abort' to abandon a pvmove");
 		return ECMD_FAILED;
 	}
 
-	if (lv->status & MIRROR_LOG) {
+	if (lv_is_mirror_log(lv)) {
 		log_error("Unable to change mirror log LV %s directly", lv->name);
 		return ECMD_FAILED;
 	}
 
-	if (lv->status & MIRROR_IMAGE) {
+	if (lv_is_mirror_image(lv)) {
 		log_error("Unable to change mirror image LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a04a7fc..c252745 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -677,7 +677,7 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 				    struct logical_volume *lv,
 				    struct dm_list *lvs_changed __attribute__((unused)))
 {
-	if (!(lv->status & CONVERTING))
+	if (!lv_is_converting(lv))
 		return 1;
 
 	if (!collapse_mirrored_lv(lv)) {
@@ -968,7 +968,7 @@ static int _failed_logs_count(struct logical_volume *lv)
 	unsigned s;
 	struct logical_volume *log_lv = first_seg(lv)->log_lv;
 	if (log_lv && (log_lv->status & PARTIAL_LV)) {
-		if (log_lv->status & MIRRORED)
+		if (lv_is_mirrored(log_lv))
 			ret += _failed_mirrors_count(log_lv);
 		else
 			ret += 1;
@@ -1109,7 +1109,7 @@ static int _lv_update_mirrored_log(struct logical_volume *lv,
 		return 1;
 
 	log_lv = first_seg(_original_lv(lv))->log_lv;
-	if (!log_lv || !(log_lv->status & MIRRORED))
+	if (!log_lv || !lv_is_mirrored(log_lv))
 		return 1;
 
 	old_log_count = _get_log_count(lv);
@@ -1252,7 +1252,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 		*new_mimage_count = *old_mimage_count;
 		*new_log_count = *old_log_count;
 
-		if (find_temporary_mirror(lv) || (lv->status & CONVERTING))
+		if (find_temporary_mirror(lv) || lv_is_converting(lv))
 			lp->need_polling = 1;
 		return 1;
 	}
@@ -1337,7 +1337,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	/*
 	 * Region size must not change on existing mirrors
 	 */
-	if (arg_count(cmd, regionsize_ARG) && (lv->status & MIRRORED) &&
+	if (arg_count(cmd, regionsize_ARG) && lv_is_mirrored(lv) &&
 	    (lp->region_size != first_seg(lv)->region_size)) {
 		log_error("Mirror log region size cannot be changed on "
 			  "an existing mirror.");
@@ -1348,7 +1348,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	 * For the most part, we cannot handle multi-segment mirrors. Bail out
 	 * early if we have encountered one.
 	 */
-	if ((lv->status & MIRRORED) && dm_list_size(&lv->segments) != 1) {
+	if (lv_is_mirrored(lv) && dm_list_size(&lv->segments) != 1) {
 		log_error("Logical volume %s has multiple "
 			  "mirror segments.", lv->name);
 		return 0;
@@ -1378,7 +1378,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 	uint32_t old_mimage_count = lv_mirror_count(lv);
 	uint32_t old_log_count = _get_log_count(lv);
 
-	if ((lp->mirrors == 1) && !(lv->status & MIRRORED)) {
+	if ((lp->mirrors == 1) && !lv_is_mirrored(lv)) {
 		log_warn("Logical volume %s is already not mirrored.",
 			 lv->name);
 		return 1;
@@ -1396,7 +1396,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 	/*
 	 * Up-convert from linear to mirror
 	 */
-	if (!(lv->status & MIRRORED)) {
+	if (!lv_is_mirrored(lv)) {
 		/* FIXME Share code with lvcreate */
 
 		/*
@@ -1442,7 +1442,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		 * Is there already a convert in progress?  We do not
 		 * currently allow more than one.
 		 */
-		if (find_temporary_mirror(lv) || (lv->status & CONVERTING)) {
+		if (find_temporary_mirror(lv) || lv_is_converting(lv)) {
 			log_error("%s is already being converted.  Unable to start another conversion.",
 				  lv->name);
 			return 0;
@@ -1523,7 +1523,7 @@ out:
 	/*
 	 * Converting the log type
 	 */
-	if ((lv->status & MIRRORED) && (old_log_count != new_log_count)) {
+	if (lv_is_mirrored(lv) && (old_log_count != new_log_count)) {
 		if (!_lv_update_log_type(cmd, lp, lv,
 					 operable_pvs, new_log_count))
 			return_0;
@@ -1959,7 +1959,7 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	if (!vg_check_status(vg, LVM_WRITE))
 		return_ECMD_FAILED;
 
-	if (lv_is_mirror_type(cow) || lv_is_raid_type(cow) || lv_is_thin_type(cow)) {
+	if (lv_is_pvmove(cow) || lv_is_mirror_type(cow) || lv_is_raid_type(cow) || lv_is_thin_type(cow)) {
 		log_error("LV %s/%s type is unsupported with --splitsnapshot.", vg->name, cow->name);
 		return ECMD_FAILED;
 	}
@@ -2000,7 +2000,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 {
 	struct logical_volume *org;
 
-	if (lv->status & MIRRORED) {
+	if (lv_is_mirrored(lv)) {
 		log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
 		return 0;
 	}
@@ -2025,11 +2025,11 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	if (!cow_has_min_chunks(lv->vg, lv->le_count, lp->chunk_size))
 		return_0;
 
-	if (org->status & (LOCKED|PVMOVE|MIRRORED) || lv_is_cow(org)) {
+	if (lv_is_locked(org) || lv_is_pvmove(org) || lv_is_mirrored(org) || lv_is_cow(org)) {
 		log_error("Unable to convert an LV into a snapshot of a %s LV.",
-			  org->status & LOCKED ? "locked" :
-			  org->status & PVMOVE ? "pvmove" :
-			  org->status & MIRRORED ? "mirrored" :
+			  lv_is_locked(org) ? "locked" :
+			  lv_is_pvmove(org) ? "pvmove" :
+			  lv_is_mirrored(org) ? "mirrored" :
 			  "snapshot");
 		return 0;
 	}
@@ -2665,7 +2665,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			log_error("Try \"raid1\" segment type instead.");
 			return 0;
 		}
-		if (metadata_lv->status & LOCKED) {
+		if (lv_is_locked(metadata_lv)) {
 			log_error("Can't convert locked LV %s.",
 				  display_lvname(metadata_lv));
 			return 0;
@@ -3031,7 +3031,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct lvconvert_params *lp = handle;
 	struct dm_list *failed_pvs;
 
-	if (lv->status & LOCKED) {
+	if (lv_is_locked(lv)) {
 		log_error("Cannot convert locked LV %s", lv->name);
 		return ECMD_FAILED;
 	}
@@ -3042,7 +3042,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (lv->status & PVMOVE) {
+	if (lv_is_pvmove(lv)) {
 		log_error("Unable to convert pvmove LV %s", lv->name);
 		return ECMD_FAILED;
 	}
@@ -3112,7 +3112,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			_remove_missing_empty_pv(lv->vg, failed_pvs);
 	} else if (arg_count(cmd, mirrors_ARG) ||
 		   arg_count(cmd, splitmirrors_ARG) ||
-		   (lv->status & MIRRORED)) {
+		   lv_is_mirrored(lv)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 3bf4793..eeff76d 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -111,9 +111,9 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 		goto bad;
 	}
 
-	if (lvl->lv->status & (RAID_IMAGE | RAID_META)) {
+	if (lv_is_raid_image(lvl->lv) || lv_is_raid_metadata(lvl->lv)) {
 		log_error("Cannot rename a RAID %s directly",
-			  (lvl->lv->status & RAID_IMAGE) ? "image" :
+			  lv_is_raid_image(lvl->lv) ? "image" :
 			  "metadata area");
 		goto bad;
 	}
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 3448af4..5b458b1 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -322,19 +322,18 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		 * RAID, thin and snapshot-related LVs are not
 		 * processed in a cluster, so we don't have to
 		 * worry about avoiding certain PVs in that context.
+		 *
+		 * Allow clustered mirror, but not raid mirror.
 		 */
-		if (vg_is_clustered(lv->vg)) {
-			/* Allow clustered mirror, but not raid mirror. */
-			if (!lv_is_mirror_type(lv) || lv_is_raid(lv))
-				continue;
-		}
+		if (vg_is_clustered(lv->vg) && (!lv_is_mirror_type(lv) || lv_is_raid(lv)))
+			continue;
 
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;
 
-		if (lv->status & (CONVERTING | MERGING)) {
+		if (lv_is_converting(lv) || lv_is_merging(lv)) {
 			log_error("Unable to pvmove when %s volumes are present",
-				  (lv->status & CONVERTING) ?
+				  lv_is_converting(lv) ?
 				  "converting" : "merging");
 			return NULL;
 		}
@@ -423,7 +422,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 		}
 
-		if (lv->status & LOCKED) {
+		if (lv_is_locked(lv)) {
 			lv_skipped = 1;
 			log_print_unless_silent("Skipping locked LV %s", lv->name);
 			continue;
diff --git a/tools/toollib.c b/tools/toollib.c
index b160ead..7be5b5a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1440,7 +1440,7 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (background_polling() &&
 	    is_change_activating(activate) &&
-	    (lv->status & (PVMOVE|CONVERTING|MERGING)))
+	    (lv_is_pvmove(lv) || lv_is_converting(lv) || lv_is_merging(lv)))
 		lv_spawn_background_polling(cmd, lv);
 
 	return r;
@@ -1509,19 +1509,19 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
 {
 	const char *pvname;
 
-	if ((lv->status & PVMOVE) &&
+	if (lv_is_pvmove(lv) &&
 	    (pvname = get_pvmove_pvname_from_lv_mirr(lv))) {
 		log_verbose("Spawning background pvmove process for %s",
 			    pvname);
 		pvmove_poll(cmd, pvname, 1);
-	} else if ((lv->status & LOCKED) &&
-	    (pvname = get_pvmove_pvname_from_lv(lv))) {
+	} else if (lv_is_locked(lv) &&
+		   (pvname = get_pvmove_pvname_from_lv(lv))) {
 		log_verbose("Spawning background pvmove process for %s",
 			    pvname);
 		pvmove_poll(cmd, pvname, 1);
 	}
 
-	if (lv->status & (CONVERTING|MERGING)) {
+	if (lv_is_converting(lv) || lv_is_merging(lv)) {
 		log_verbose("Spawning background lvconvert process for %s",
 			lv->name);
 		lvconvert_poll(cmd, lv, 1);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 88dc180..29e2d8a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -36,7 +36,7 @@ static int _monitor_lvs_in_vg(struct cmd_context *cmd,
 		/*
 		 * FIXME: Need to consider all cases... PVMOVE, etc
 		 */
-		if (lv->status & PVMOVE)
+		if (lv_is_pvmove(lv))
 			continue;
 
 		if (!monitor_dev_for_events(cmd, lv, 0, reg)) {
@@ -67,7 +67,7 @@ static int _poll_lvs_in_vg(struct cmd_context *cmd,
 			lv_active = info.exists;
 
 		if (lv_active &&
-		    (lv->status & (PVMOVE|CONVERTING|MERGING))) {
+		    (lv_is_pvmove(lv) || lv_is_converting(lv) || lv_is_merging(lv))) {
 			lv_spawn_background_polling(cmd, lv);
 			count++;
 		}
@@ -121,7 +121,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		/* Can't deactivate a pvmove LV */
 		/* FIXME There needs to be a controlled way of doing this */
-		if ((lv->status & PVMOVE) && !is_change_activating(activate))
+		if (lv_is_pvmove(lv) && !is_change_activating(activate))
 			continue;
 
 		if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG)))
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 0ade4fa..62162af 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -95,13 +95,13 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 				goto restart;
 			}
 
-			if (lv->status & MIRRORED) {
+			if (lv_is_mirrored(lv)) {
 				if (!mirror_remove_missing(cmd, lv, 1))
 					return_0;
 				goto restart;
 			}
 
-			if (arg_count(cmd, mirrorsonly_ARG) &&!(lv->status & MIRRORED)) {
+			if (arg_count(cmd, mirrorsonly_ARG) && !lv_is_mirrored(lv)) {
 				log_error("Non-mirror-image LV %s found: can't remove.", lv->name);
 				continue;
 			}
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 1a8e237..ad2eb48 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -71,7 +71,7 @@ static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 		if (lv_is_raid(lv))
 			continue;
 
-		if ((lv->status & MIRRORED))
+		if (lv_is_mirrored(lv))
 			continue;
 
 		if (lv_is_thin_pool(lv) ||
@@ -192,7 +192,7 @@ static int _move_mirrors(struct volume_group *vg_from,
 		if (lv_is_raid(lv))
 			continue;
 
-		if (!(lv->status & MIRRORED))
+		if (!lv_is_mirrored(lv))
 			continue;
 
 		seg = first_seg(lv);



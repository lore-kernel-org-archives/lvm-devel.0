From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 22 Mar 2019 05:56:46 -0400
Subject: stable-2.02 - raid: fix (de)activation of RaidLVs with visible SubLVs
Message-ID: <201903220956.x2M9ukuA006892@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b04851fc574ce9cffd30a51d2b750955239f316
Commit:        9b04851fc574ce9cffd30a51d2b750955239f316
Parent:        dcf8f3111aea1179be1083ace772f3108b06c508
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Oct 31 23:05:08 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 21 08:05:23 2019 +0100

raid: fix (de)activation of RaidLVs with visible SubLVs

There's a small window during creation of a new RaidLV when
rmeta SubLVs are made visible to wipe them in order to prevent
erroneous discovery of stale RAID metadata.  In case a crash
prevents the SubLVs from being committed hidden after such
wiping, the RaidLV can still be activated with the SubLVs visible.
During deactivation though, a deadlock occurs because the visible
SubLVs are deactivated before the RaidLV.

The patch adds _check_raid_sublvs to the raid validation in merge.c,
an activation check to activate.c (paranoid, because the merge.c check
will prevent activation in case of visible SubLVs) and shares the
existing wiping function _clear_lvs in raid_manip.c moved to lv_manip.c
and renamed to activate_and_wipe_lvlist to remove code duplication.
Whilst on it, introduce activate_and_wipe_lv to share with
(lvconvert|lvchange).c.

Resolves: rhbz1633167
(cherry picked from commit dd5716ddf258c4a44819fa90d3356833ccf767b4)

Conflicts:
	WHATS_NEW
	lib/activate/activate.c
	lib/metadata/lv_manip.c
	lib/metadata/raid_manip.c
	tools/lvchange.c
	tools/lvconvert.c
---
 WHATS_NEW                        |    1 +
 lib/activate/activate.c          |    6 +
 lib/metadata/lv_manip.c          |  190 ++++++++++++++++++++++++++++----------
 lib/metadata/merge.c             |   30 ++++++
 lib/metadata/metadata-exported.h |    8 ++
 lib/metadata/raid_manip.c        |   91 ++++--------------
 tools/lvchange.c                 |   32 +------
 tools/lvconvert.c                |   22 +---
 8 files changed, 214 insertions(+), 166 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cbb5505..0488a50 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.184 - 
 =====================================
+  Fix (de)activation of RaidLVs with visible SubLVs
   Change scan_lvs default to 0 so LVs are not scanned for PVs.
   Add scan_lvs config setting to control if lvm scans LVs for PVs.
   Fix missing proper initialization of pv_list struct when adding pv.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2a85ef9..4c83231 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2789,6 +2789,12 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	if (lv_raid_has_visible_sublvs(lv)) {
+		log_error("Refusing activation of RAID LV %s with "
+			  "visible SubLVs.", display_lvname(lv));
+		goto out;
+	}
+
 	if (test_mode()) {
 		_skip("Activating %s.", display_lvname(lv));
 		r = 1;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d1389e7..d039686 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3958,6 +3958,25 @@ bad:
 	return 0;
 }
 
+/* Add all rmeta SubLVs for @seg to @lvs and return allocated @lvl to free by caller. */
+static struct lv_list *_raid_list_metalvs(struct lv_segment *seg, struct dm_list *lvs)
+{
+	uint32_t s;
+	struct lv_list *lvl;
+
+	dm_list_init(lvs);
+
+	if (!(lvl = dm_pool_alloc(seg->lv->vg->vgmem, sizeof(*lvl) * seg->area_count)))
+		return_NULL;
+
+	for (s = 0; s < seg->area_count; s++) {
+		lvl[s].lv = seg_metalv(seg, s);
+		dm_list_add(lvs, &lvl[s].list);
+	}
+
+	return lvl;
+}
+
 static int _lv_extend_layered_lv(struct alloc_handle *ah,
 				 struct logical_volume *lv,
 				 uint32_t extents, uint32_t first_area,
@@ -3969,7 +3988,6 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	uint32_t fa, s;
 	int clear_metadata = 0;
 	uint32_t area_multiple = 1;
-	int fail;
 
 	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
@@ -4047,74 +4065,50 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		return_0;
 
 	if (clear_metadata) {
+		struct volume_group *vg = lv->vg;
+
 		/*
 		 * We must clear the metadata areas upon creation.
 		 */
-		/* FIXME VG is not in a fully-consistent state here and should not be committed! */
-		if (!vg_write(lv->vg) || !vg_commit(lv->vg))
-			return_0;
-
-		if (test_mode())
-			log_verbose("Test mode: Skipping wiping of metadata areas.");
-		else {
-			fail = 0;
-			/* Activate all rmeta devices locally first (more efficient) */
-			for (s = 0; !fail && s < seg->area_count; s++) {
-				meta_lv = seg_metalv(seg, s);
-
-				if (!activate_lv_local(meta_lv->vg->cmd, meta_lv)) {
-					log_error("Failed to activate %s for clearing.",
-						  display_lvname(meta_lv));
-					fail = 1;
-				}
-			}
-
-			/* Clear all rmeta devices */
-			for (s = 0; !fail && s < seg->area_count; s++) {
-				meta_lv = seg_metalv(seg, s);
 
-				log_verbose("Clearing metadata area of %s.",
-					    display_lvname(meta_lv));
-				/*
-				 * Rather than wiping meta_lv->size, we can simply
-				 * wipe '1' to remove the superblock of any previous
-				 * RAID devices.  It is much quicker.
-				 */
-				if (!wipe_lv(meta_lv, (struct wipe_params)
-					     { .do_zero = 1, .zero_sectors = 1 })) {
-					stack;
-					fail = 1;
-				}
-			}
-
-			/* Deactivate all rmeta devices */
-			for (s = 0; s < seg->area_count; s++) {
-				meta_lv = seg_metalv(seg, s);
+		/*
+		 * Declare the new RaidLV as temporary to avoid visible SubLV
+		 * failures on activation until after we wiped them so that
+		 * we can avoid activating crashed, potentially partially
+		 * wiped RaidLVs.
+		 */
+		lv->status |= LV_ACTIVATION_SKIP;
 
-				if (!deactivate_lv(meta_lv->vg->cmd, meta_lv)) {
-					log_error("Failed to deactivate %s after clearing.",
-						  display_lvname(meta_lv));
-					fail = 1;
-				}
+		if (test_mode()) {
+			/* FIXME VG is not in a fully-consistent state here and should not be committed! */
+			if (!vg_write(vg) || !vg_commit(vg))
+				return_0;
 
-				/* Wipe any temporary tags required for activation. */
-				str_list_wipe(&meta_lv->tags);
-			}
+			log_verbose("Test mode: Skipping wiping of metadata areas.");
+		} else {
+			struct dm_list meta_lvs;
+			struct lv_list *lvl;
 
-			if (fail) {
-				/* Fail, after trying to deactivate all we could */
-				struct volume_group *vg = lv->vg;
+			if (!(lvl = _raid_list_metalvs(seg, &meta_lvs)))
+				return 0;
 
+			/* Wipe lv list committing metadata */
+			if (!activate_and_wipe_lvlist(&meta_lvs, 1)) {
+				/* If we failed clearing rmeta SubLVs, try removing the new RaidLV */
 				if (!lv_remove(lv))
 					log_error("Failed to remove LV");
 				else if (!vg_write(vg) || !vg_commit(vg))
 					log_error("Failed to commit VG %s", vg->name);
 				return_0;
 			}
+
+			dm_pool_free(vg->vgmem, lvl);
 		}
 
 		for (s = 0; s < seg->area_count; s++)
 			lv_set_hidden(seg_metalv(seg, s));
+
+		lv->status &= ~LV_ACTIVATION_SKIP;
 	}
 
 	return 1;
@@ -7200,6 +7194,100 @@ out:
 	return 1;
 }
 
+/*
+ * Optionally makes on-disk metadata changes if @commit
+ *
+ * If LV is active:
+ *	wipe any signatures and clear first sector of LVs listed on @lv_list
+ * otherwise:
+ *	activate, wipe (as above), deactivate
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+int activate_and_wipe_lvlist(struct dm_list *lv_list, int commit)
+{
+	struct lv_list *lvl;
+	struct volume_group *vg = NULL;
+	unsigned i = 0, sz = dm_list_size(lv_list);
+	char *was_active;
+	int r = 1;
+
+	if (!sz) {
+		log_debug_metadata(INTERNAL_ERROR "Empty list of LVs given for wiping.");
+		return 1;
+	}
+
+	dm_list_iterate_items(lvl, lv_list) {
+		if (!lv_is_visible(lvl->lv)) {
+			log_error(INTERNAL_ERROR
+				  "LVs must be set visible before wiping.");
+			return 0;
+		}
+		vg = lvl->lv->vg;
+	}
+
+	if (test_mode())
+		return 1;
+
+	/*
+	 * FIXME: only vg_[write|commit] if LVs are not already written
+	 * as visible in the LVM metadata (which is never the case yet).
+	 */
+	if (commit &&
+	    (!vg || !vg_write(vg) || !vg_commit(vg)))
+		return_0;
+
+	was_active = alloca(sz);
+
+	dm_list_iterate_items(lvl, lv_list)
+		if (!(was_active[i++] = lv_is_active(lvl->lv))) {
+			lvl->lv->status |= LV_TEMPORARY;
+			if (!activate_lv(vg->cmd, lvl->lv)) {
+				log_error("Failed to activate localy %s for wiping.",
+					  display_lvname(lvl->lv));
+				r = 0;
+				goto out;
+			}
+			lvl->lv->status &= ~LV_TEMPORARY;
+		}
+
+	dm_list_iterate_items(lvl, lv_list) {
+		log_verbose("Wiping metadata area %s.", display_lvname(lvl->lv));
+		/* Wipe any know signatures */
+		if (!wipe_lv(lvl->lv, (struct wipe_params) { .do_wipe_signatures = 1, .do_zero = 1, .zero_sectors = 1 })) {
+			log_error("Failed to wipe %s.", display_lvname(lvl->lv));
+			r = 0;
+			goto out;
+		}
+	}
+out:
+	/* TODO:   deactivation is only needed with clustered locking
+	 *         in normal case we should keep device active
+	 */
+	sz = 0;
+	dm_list_iterate_items(lvl, lv_list)
+		if ((i > sz) && !was_active[sz++] &&
+		    !deactivate_lv(vg->cmd, lvl->lv)) {
+			log_error("Failed to deactivate %s.", display_lvname(lvl->lv));
+			r = 0; /* Continue deactivating as many as possible. */
+		}
+
+	return r;
+}
+
+/* Wipe logical volume @lv, optionally with @commit of metadata */
+int activate_and_wipe_lv(struct logical_volume *lv, int commit)
+{
+	struct dm_list lv_list;
+	struct lv_list lvl;
+
+	lvl.lv = lv;
+	dm_list_init(&lv_list);
+	dm_list_add(&lv_list, &lvl.list);
+
+	return activate_and_wipe_lvlist(&lv_list, commit);
+}
+
 static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 						     struct volume_group *vg,
 						     const char *lv_name,
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 7299620..a024877 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -234,6 +234,30 @@ static void _check_non_raid_seg_members(struct lv_segment *seg, int *error_count
 	/* .... more members? */
 }
 
+static void _check_raid_sublvs(struct lv_segment *seg, int *error_count)
+{
+	unsigned s;
+
+	for (s = 0; s < seg->area_count; s++) {
+		if (seg_type(seg, s) != AREA_LV)
+			raid_seg_error("no raid image SubLV");
+
+		if ((seg_lv(seg, s)->status & LVM_WRITE) &&
+		    !(seg->lv->status & LV_ACTIVATION_SKIP) &&
+		    lv_is_visible(seg_lv(seg, s)))
+			raid_seg_error("visible raid image LV");
+
+		if (!seg_is_raid_with_meta(seg) || !seg->meta_areas)
+			continue;
+
+		if (seg_metatype(seg, s) != AREA_LV)
+			raid_seg_error("no raid meta SubLV");
+		else if (!(seg->lv->status & LV_ACTIVATION_SKIP) &&
+			 lv_is_visible(seg_metalv(seg, s)))
+			raid_seg_error("visible raid meta LV");
+	}
+}
+
 /*
  * Check RAID segment struct members of @seg for acceptable
  * properties and increment @error_count for any bogus ones.
@@ -287,10 +311,14 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 	/* Check for any MetaLV flaws like non-existing ones or size variations */
 	if (seg->meta_areas)
 		for (area_len = s = 0; s < seg->area_count; s++) {
+			if (seg_metatype(seg, s) == AREA_UNASSIGNED)
+				continue;
+
 			if (seg_metatype(seg, s) != AREA_LV) {
 				raid_seg_error("no MetaLV");
 				continue;
 			}
+
 			if (!lv_is_raid_metadata(seg_metalv(seg, s)))
 				raid_seg_error("MetaLV without RAID metadata flag");
 			if (area_len &&
@@ -314,6 +342,8 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 		_check_raid45610_seg(seg, error_count);
 	else
 		raid_seg_error("bogus RAID segment type");
+
+	_check_raid_sublvs(seg, error_count);
 }
 /* END: RAID segment property checks. */
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f4fb112..75caba1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -784,6 +784,12 @@ struct wipe_params {
 /* Zero out LV and/or wipe signatures */
 int wipe_lv(struct logical_volume *lv, struct wipe_params params);
 
+/* Wipe any signatures and zero first sector on @lv */
+int activate_and_wipe_lv(struct logical_volume *lv, int commit);
+
+/* Wipe any signatures and zero first sector of LVs listed on @lv_list */
+int activate_and_wipe_lvlist(struct dm_list *lv_list, int commit);
+
 int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag);
 
 /* Reduce the size of an LV by extents */
@@ -1213,6 +1219,8 @@ int lv_raid_change_region_size(struct logical_volume *lv,
 int lv_raid_in_sync(const struct logical_volume *lv);
 uint32_t lv_raid_data_copies(const struct segment_type *segtype, uint32_t area_count);
 int lv_raid_free_reshape_space(const struct logical_volume *lv);
+int lv_raid_clear_lv(struct logical_volume *lv, int commit);
+int lv_raid_has_visible_sublvs(const struct logical_volume *lv);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index cb7202a..bffae60 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -689,86 +689,33 @@ static int _lv_update_and_reload_list(struct logical_volume *lv, int origin_only
 	return r;
 }
 
-/* Makes on-disk metadata changes
- * If LV is active:
- *	clear first block of device
- * otherwise:
- *	activate, clear, deactivate
- *
- * Returns: 1 on success, 0 on failure
- */
+/* Wipe all LVs listsed on @lv_list committing lvm metadata */
 static int _clear_lvs(struct dm_list *lv_list)
 {
-	struct lv_list *lvl;
-	struct volume_group *vg = NULL;
-	unsigned i = 0, sz = dm_list_size(lv_list);
-	char *was_active;
-	int r = 1;
-
-	if (!sz) {
-		log_debug_metadata(INTERNAL_ERROR "Empty list of LVs given for clearing.");
-		return 1;
-	}
-
-	dm_list_iterate_items(lvl, lv_list) {
-		if (!lv_is_visible(lvl->lv)) {
-			log_error(INTERNAL_ERROR
-				  "LVs must be set visible before clearing.");
-			return 0;
-		}
-		vg = lvl->lv->vg;
-	}
-
-	if (test_mode())
-		return 1;
+	return activate_and_wipe_lvlist(lv_list, 1);
+}
 
-	/*
-	 * FIXME: only vg_[write|commit] if LVs are not already written
-	 * as visible in the LVM metadata (which is never the case yet).
-	 */
-	if (!vg || !vg_write(vg) || !vg_commit(vg))
-		return_0;
+/* External interface to clear logical volumes on @lv_list */
+int lv_raid_has_visible_sublvs(const struct logical_volume *lv)
+{
+	unsigned s;
+	struct lv_segment *seg = first_seg(lv);
 
-	was_active = alloca(sz);
+	if (!lv_is_raid(lv) || (lv->status & LV_TEMPORARY) || !seg)
+		return 0;
 
-	dm_list_iterate_items(lvl, lv_list)
-		if (!(was_active[i++] = lv_is_active_locally(lvl->lv))) {
-			lvl->lv->status |= LV_TEMPORARY;
-			if (!activate_lv_excl_local(vg->cmd, lvl->lv)) {
-				log_error("Failed to activate localy %s for clearing.",
-					  display_lvname(lvl->lv));
-				r = 0;
-				goto out;
-			}
-			lvl->lv->status &= ~LV_TEMPORARY;
-		}
+	if (lv_is_raid_image(lv) || lv_is_raid_metadata(lv))
+		return 0;
 
-	dm_list_iterate_items(lvl, lv_list) {
-		log_verbose("Clearing metadata area %s.", display_lvname(lvl->lv));
-		/*
-		 * Rather than wiping lv->size, we can simply
-		 * wipe the first sector to remove the superblock of any previous
-		 * RAID devices.  It is much quicker.
-		 */
-		if (!wipe_lv(lvl->lv, (struct wipe_params) { .do_zero = 1, .zero_sectors = 1 })) {
-			log_error("Failed to zero %s.", display_lvname(lvl->lv));
-			r = 0;
-			goto out;
-		}
+	for (s = 0; s < seg->area_count; s++) {
+		if ((seg_lv(seg, s)->status & LVM_WRITE) && /* Split off track changes raid1 leg */
+		    lv_is_visible(seg_lv(seg, s)))
+			return 1;
+		if (seg->meta_areas && lv_is_visible(seg_metalv(seg, s)))
+			return 1;
 	}
-out:
-	/* TODO:   deactivation is only needed with clustered locking
-	 *         in normal case we should keep device active
-	 */
-	sz = 0;
-	dm_list_iterate_items(lvl, lv_list)
-		if ((i > sz) && !was_active[sz++] &&
-		    !deactivate_lv(vg->cmd, lvl->lv)) {
-			log_error("Failed to deactivate %s.", display_lvname(lvl->lv));
-			r = 0; /* continue deactivating */
-		}
 
-	return r;
+	return 0;
 }
 
 /* raid0* <-> raid10_near area reorder helper: swap 2 LV segment areas @a1 and @a2 */
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 6144852..4195a80 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -321,7 +321,6 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	int monitored;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list device_list;
-	struct lv_list *lvl;
 
 	dm_list_init(&device_list);
 
@@ -405,6 +404,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	 * Now we handle mirrors with log devices
 	 */
 	lv->status &= ~LV_NOTSYNCED;
+	lv->status |= LV_ACTIVATION_SKIP;
 
 	/* Separate mirror log or metadata devices so we can clear them */
 	if (!_detach_metadata_devices(seg, &device_list)) {
@@ -423,32 +423,8 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	/* No backup for intermediate metadata, so just unlock memory */
 	memlock_unlock(lv->vg->cmd);
 
-	dm_list_iterate_items(lvl, &device_list) {
-		if (!activate_lv_excl_local(cmd, lvl->lv)) {
-			log_error("Unable to activate %s for %s clearing.",
-				  display_lvname(lvl->lv), (seg_is_raid(seg)) ?
-				  "metadata area" : "mirror log");
-			return 0;
-		}
-
-		if (!wipe_lv(lvl->lv, (struct wipe_params)
-			     { .do_zero = 1, .zero_sectors = lvl->lv->size })) {
-			log_error("Unable to reset sync status for %s.",
-				  display_lvname(lv));
-			if (!deactivate_lv(cmd, lvl->lv))
-				log_error("Failed to deactivate log LV after "
-					  "wiping failed");
-			return 0;
-		}
-
-		if (!deactivate_lv(cmd, lvl->lv)) {
-			log_error("Unable to deactivate %s LV %s "
-				  "after wiping for resync.",
-				  (seg_is_raid(seg)) ? "metadata" : "log",
-				  display_lvname(lvl->lv));
-			return 0;
-		}
-	}
+	if (!activate_and_wipe_lvlist(&device_list, 0))
+		return 0;
 
 	/* Wait until devices are away */
 	if (!sync_local_dev_names(lv->vg->cmd)) {
@@ -464,6 +440,8 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
+	lv->status &= ~LV_ACTIVATION_SKIP;
+
 	if (!_vg_write_commit(lv, NULL))
 		return 0;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 028781f..2b3c3ea 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2003,19 +2003,9 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 
 	if (!zero || !(lv->status & LVM_WRITE))
 		log_warn("WARNING: %s not zeroed.", snap_name);
-	else {
-		lv->status |= LV_TEMPORARY;
-		if (!activate_lv_excl_local(cmd, lv) ||
-		    !wipe_lv(lv, (struct wipe_params) { .do_zero = 1 })) {
-			log_error("Aborting. Failed to wipe snapshot exception store.");
-			return 0;
-		}
-		lv->status &= ~LV_TEMPORARY;
-		/* Deactivates cleared metadata LV */
-		if (!deactivate_lv(lv->vg->cmd, lv)) {
-			log_error("Failed to deactivate zeroed snapshot exception store.");
-			return 0;
-		}
+	else if (!activate_and_wipe_lv(lv, 0)) {
+		log_error("Aborting. Failed to wipe snapshot exception store.");
+		return 0;
 	}
 
 	if (!archive(lv->vg))
@@ -3176,12 +3166,12 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			goto_bad;
 
 		if (zero_metadata) {
-			metadata_lv->status |= LV_TEMPORARY;
-			if (!activate_lv_excl_local(cmd, metadata_lv)) {
+			metadata_lv->status |= LV_ACTIVATION_SKIP;
+			if (!activate_lv(cmd, metadata_lv)) {
 				log_error("Aborting. Failed to activate metadata lv.");
 				goto bad;
 			}
-			metadata_lv->status &= ~LV_TEMPORARY;
+			metadata_lv->status &= ~LV_ACTIVATION_SKIP;
 
 			if (!wipe_lv(metadata_lv, (struct wipe_params) { .do_zero = 1 })) {
 				log_error("Aborting. Failed to wipe metadata lv.");



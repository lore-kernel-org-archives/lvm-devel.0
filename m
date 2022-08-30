From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Aug 2022 11:57:40 +0000 (GMT)
Subject: main - thin: rename internal function
Message-ID: <20220830115740.04F3C3854801@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=60ca2ce20fef54b3441dda051beebbc1847db50d
Commit:        60ca2ce20fef54b3441dda051beebbc1847db50d
Parent:        8d70cfe6005165e173643954e6cd9eff745e4aa4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 24 15:02:07 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 30 13:54:19 2022 +0200

thin: rename internal function

Names matching internal code layout.
Functionc in thin_manip.c uses thin_pool in its name.
Keep 'pool' only for function working for both cache and thin pools.

No change of functionality.
---
 lib/activate/activate.c          |  2 +-
 lib/locking/lvmlockd.c           |  2 +-
 lib/metadata/lv_manip.c          | 32 ++++++++++++++++----------------
 lib/metadata/metadata-exported.h |  7 ++++---
 lib/metadata/metadata.h          | 39 +++++++++++++++++++++------------------
 lib/metadata/pool_manip.c        |  6 +++---
 lib/metadata/thin_manip.c        | 36 ++++++++++++++++++------------------
 lib/thin/thin.c                  |  4 ++--
 tools/lvchange.c                 |  2 +-
 tools/lvconvert.c                |  6 +++---
 10 files changed, 70 insertions(+), 66 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a92fbb8e1..2f3c231cc 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2764,7 +2764,7 @@ static int _component_cb(struct logical_volume *lv, void *data)
 
 	if (lv_is_locked(lv) || lv_is_pvmove(lv) ||/* ignoring */
 	    /* thin-pool is special and it's using layered device */
-	    (lv_is_thin_pool(lv) && pool_is_active(lv)))
+	    (lv_is_thin_pool(lv) && thin_pool_is_active(lv)))
 		return -1;
 
 	/* External origin is activated through thinLV and uses -real suffix.
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 60c80f1b1..f0183db3d 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2555,7 +2555,7 @@ static int _lockd_lv_thin(struct cmd_context *cmd, struct logical_volume *lv,
 	 * Unlock when the pool is no longer active.
 	 */
 
-	if (def_mode && !strcmp(def_mode, "un") && pool_is_active(pool_lv))
+	if (def_mode && !strcmp(def_mode, "un") && thin_pool_is_active(pool_lv))
 		return 1;
 
 	flags |= LDLV_MODE_NO_SH;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9523e3e66..a9057830d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5125,7 +5125,7 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 			goto_bad;
 
 		/* Resize below the minimal usable value */
-		min_threshold = pool_metadata_min_threshold(first_seg(lv)) / DM_PERCENT_1;
+		min_threshold = thin_pool_metadata_min_threshold(first_seg(lv)) / DM_PERCENT_1;
 		*meta_amount = _adjust_amount(thin_pool_status->metadata_usage,
 					      (min_threshold < policy_threshold) ?
 					      min_threshold : policy_threshold, policy_amount);
@@ -6179,13 +6179,13 @@ int lv_resize(struct logical_volume *lv,
 
 	if (lv_is_thin_pool(lock_lv)) {
 		/* Update lvm pool metadata (drop messages). */
-		if (!update_pool_lv(lock_lv, 1))
+		if (!update_thin_pool_lv(lock_lv, 1))
 			goto_bad;
 	}
 
 	/* Check for over provisioning when extended */
 	if ((lp->resize == LV_EXTEND) && lv_is_thin_type(lv))
-		pool_check_overprovisioning(lv);
+		thin_pool_check_overprovisioning(lv);
 
 out:
 	log_print_unless_silent("Logical volume %s successfully resized.",
@@ -6742,8 +6742,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* Clear thin pool stacked messages */
-	if (pool_lv && pool_has_message(first_seg(pool_lv), lv, 0) &&
-	    !update_pool_lv(pool_lv, 1)) {
+	if (pool_lv && thin_pool_has_message(first_seg(pool_lv), lv, 0) &&
+	    !update_thin_pool_lv(pool_lv, 1)) {
 		if (force < DONT_PROMPT_OVERRIDE) {
 			log_error("Failed to update pool %s.", display_lvname(pool_lv));
 			return 0;
@@ -6820,9 +6820,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* Release unneeded blocks in thin pool */
 	/* TODO: defer when multiple LVs relased@once */
-	if (pool_lv && !update_pool_lv(pool_lv, 1)) {
+	if (pool_lv && !update_thin_pool_lv(pool_lv, 1)) {
 		if (force < DONT_PROMPT_OVERRIDE) {
-			log_error("Failed to update pool %s.", display_lvname(pool_lv));
+			log_error("Failed to update thin pool %s.", display_lvname(pool_lv));
 			return 0;
 		}
 		log_print_unless_silent("Ignoring update failure of pool %s.",
@@ -8299,7 +8299,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 						  display_lvname(pool_lv));
 					return NULL;
 				}
-				if (!pool_below_threshold(first_seg(pool_lv))) {
+				if (!thin_pool_below_threshold(first_seg(pool_lv))) {
 					log_error("Cannot create new thin volume, free space in "
 						  "thin pool %s reached threshold.",
 						  display_lvname(pool_lv));
@@ -8386,7 +8386,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			 * within the same thin pool
 			 */
 			if (first_seg(origin_lv)->pool_lv != pool_lv) {
-				if (!pool_supports_external_origin(first_seg(pool_lv), origin_lv))
+				if (!thin_pool_supports_external_origin(first_seg(pool_lv), origin_lv))
 					return_NULL;
 				if (origin_lv->status & LVM_WRITE) {
 					log_error("Cannot use writable LV as the external origin.");
@@ -8448,8 +8448,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (pool_lv && segtype_is_thin_volume(create_segtype)) {
 		/* Ensure all stacked messages are submitted */
-		if ((pool_is_active(pool_lv) || is_change_activating(lp->activate)) &&
-		    !update_pool_lv(pool_lv, 1))
+		if ((thin_pool_is_active(pool_lv) || is_change_activating(lp->activate)) &&
+		    !update_thin_pool_lv(pool_lv, 1))
 			return_NULL;
 	}
 
@@ -8536,7 +8536,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		   (seg = first_seg(lv)) &&
 		   seg_is_thin(seg)) { /* going to be a thin volume */
 		pool_seg = first_seg(pool_lv);
-		if (!(seg->device_id = get_free_pool_device_id(pool_seg)))
+		if (!(seg->device_id = get_free_thin_pool_device_id(pool_seg)))
 			return_NULL;
 		seg->transaction_id = pool_seg->transaction_id;
 		if (origin_lv && lv_is_thin_volume(origin_lv) &&
@@ -8555,11 +8555,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				return_NULL;
 		}
 
-		if (!attach_pool_message(pool_seg, DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0))
+		if (!attach_thin_pool_message(pool_seg, DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0))
 			return_NULL;
 	}
 
-	if (!pool_check_overprovisioning(lv))
+	if (!thin_pool_check_overprovisioning(lv))
 		return_NULL;
 
 	/* FIXME Log allocation and attachment should have happened inside lv_extend. */
@@ -8677,7 +8677,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				goto revert_new_lv;
 			}
 			/* At this point remove pool messages, snapshot is active */
-			if (!update_pool_lv(pool_lv, 0)) {
+			if (!update_thin_pool_lv(pool_lv, 0)) {
 				stack;
 				goto revert_new_lv;
 			}
@@ -8699,7 +8699,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				}
 			}
 			/* Keep thin pool active until thin volume is activated */
-			if (!update_pool_lv(pool_lv, 1)) {
+			if (!update_thin_pool_lv(pool_lv, 1)) {
 				stack;
 				goto revert_new_lv;
 			}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6180ac88e..deaf3f30c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -880,15 +880,16 @@ uint32_t extents_from_percent_size(struct volume_group *vg, const struct dm_list
 				   percent_type_t percent, uint64_t size);
 
 struct logical_volume *find_pool_lv(const struct logical_volume *lv);
-int pool_is_active(const struct logical_volume *lv);
-int pool_supports_external_origin(const struct lv_segment *pool_seg, const struct logical_volume *external_lv);
+int thin_pool_is_active(const struct logical_volume *lv);
+int thin_pool_supports_external_origin(const struct lv_segment *pool_seg, const struct logical_volume *external_lv);
 int thin_pool_feature_supported(const struct logical_volume *lv, int feature);
+int update_thin_pool_lv(struct logical_volume *lv, int activate);
+
 int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 					       int chunk_size_calc_policy);
 int validate_cache_chunk_size(struct cmd_context *cmd, uint32_t chunk_size);
 int validate_thin_pool_chunk_size(struct cmd_context *cmd, uint32_t chunk_size);
 int validate_pool_chunk_size(struct cmd_context *cmd, const struct segment_type *segtype, uint32_t chunk_size);
-int update_pool_lv(struct logical_volume *lv, int activate);
 int get_default_allocation_thin_pool_chunk_size(struct cmd_context *cmd, struct profile *profile,
 						uint32_t *chunk_size, int *chunk_size_calc_method);
 int update_thin_pool_params(struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 6c39ff845..7f3cf9d29 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -408,7 +408,7 @@ struct lv_segment *find_seg_by_le(const struct logical_volume *lv, uint32_t le);
 struct lv_segment *find_pool_seg(const struct lv_segment *seg);
 
 /* Find some unused device_id for thin pool LV segment. */
-uint32_t get_free_pool_device_id(struct lv_segment *thin_pool_seg);
+uint32_t get_free_thin_pool_device_id(struct lv_segment *thin_pool_seg);
 
 /* Check if the new thin-pool could be used for lvm2 thin volumes */
 int check_new_thin_pool(const struct logical_volume *pool_lv);
@@ -490,31 +490,15 @@ struct volume_group *vg_from_config_tree(struct cmd_context *cmd, const struct d
 int fixup_imported_mirrors(struct volume_group *vg);
 
 /*
- * From thin_manip.c
+ * From pool_manip.c
  */
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
 		   struct logical_volume *origin,
 		   struct generic_logical_volume *indirect_origin,
 		   struct logical_volume *merge_lv);
 int detach_pool_lv(struct lv_segment *seg);
-int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
-			struct logical_volume *lv, uint32_t delete_id,
-			int no_update);
-int lv_is_merging_thin_snapshot(const struct logical_volume *lv);
-int pool_has_message(const struct lv_segment *seg,
-		     const struct logical_volume *lv, uint32_t device_id);
-int pool_metadata_min_threshold(const struct lv_segment *pool_seg);
-int pool_below_threshold(const struct lv_segment *pool_seg);
-int pool_check_overprovisioning(const struct logical_volume *lv);
 int create_pool(struct logical_volume *pool_lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
-uint64_t get_thin_pool_max_metadata_size(struct cmd_context *cmd, struct profile *profile,
-					 thin_crop_metadata_t *crop);
-thin_crop_metadata_t get_thin_pool_crop_metadata(struct cmd_context *cmd,
-						  thin_crop_metadata_t crop,
-						  uint64_t metadata_size);
-uint64_t estimate_thin_pool_metadata_size(uint32_t data_extents, uint32_t extent_size, uint32_t chunk_size);
-
 int update_pool_metadata_min_max(struct cmd_context *cmd,
 				 uint32_t extent_size,
 				 uint64_t min_metadata_size,		/* required min */
@@ -523,6 +507,25 @@ int update_pool_metadata_min_max(struct cmd_context *cmd,
 				 struct logical_volume *metadata_lv,	/* name of converted LV or NULL */
 				 uint32_t *metadata_extents);		/* resulting extent count */
 
+/*
+ * From thin_manip.c
+ */
+int attach_thin_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
+			     struct logical_volume *lv, uint32_t delete_id,
+			     int no_update);
+int lv_is_merging_thin_snapshot(const struct logical_volume *lv);
+int thin_pool_has_message(const struct lv_segment *seg,
+			  const struct logical_volume *lv, uint32_t device_id);
+int thin_pool_metadata_min_threshold(const struct lv_segment *pool_seg);
+int thin_pool_below_threshold(const struct lv_segment *pool_seg);
+int thin_pool_check_overprovisioning(const struct logical_volume *lv);
+uint64_t get_thin_pool_max_metadata_size(struct cmd_context *cmd, struct profile *profile,
+					 thin_crop_metadata_t *crop);
+thin_crop_metadata_t get_thin_pool_crop_metadata(struct cmd_context *cmd,
+						 thin_crop_metadata_t crop,
+						 uint64_t metadata_size);
+uint64_t estimate_thin_pool_metadata_size(uint32_t data_extents, uint32_t extent_size, uint32_t chunk_size);
+
 /*
  * Begin skeleton for external LVM library
  */
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index e451e92ae..bb4b5f115 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -310,9 +310,9 @@ int detach_pool_lv(struct lv_segment *seg)
 		return_0;
 
 	if (seg->device_id && /* Only thins with device_id > 0 can be deleted */
-	    !attach_pool_message(first_seg(seg->pool_lv),
-				 DM_THIN_MESSAGE_DELETE,
-				 NULL, seg->device_id, no_update))
+	    !attach_thin_pool_message(first_seg(seg->pool_lv),
+				      DM_THIN_MESSAGE_DELETE,
+				      NULL, seg->device_id, no_update))
 		return_0;
 
 	if (!remove_seg_from_segs_using_this_lv(seg->pool_lv, seg))
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 6ce88bd3d..14656ed3f 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -34,9 +34,9 @@ struct logical_volume *data_lv_from_thin_pool(struct logical_volume *pool_lv)
 }
 
 /* TODO: drop unused no_update */
-int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
-			struct logical_volume *lv, uint32_t delete_id,
-			int no_update)
+int attach_thin_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
+			     struct logical_volume *lv, uint32_t delete_id,
+			     int no_update)
 {
 	struct lv_thin_message *tmsg;
 
@@ -46,7 +46,7 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 		return 0;
 	}
 
-	if (pool_has_message(pool_seg, lv, delete_id)) {
+	if (thin_pool_has_message(pool_seg, lv, delete_id)) {
 		if (lv)
 			log_error("Message referring LV %s already queued in pool %s.",
 				  display_lvname(lv), display_lvname(pool_seg->lv));
@@ -151,13 +151,13 @@ int lv_is_merging_thin_snapshot(const struct logical_volume *lv)
  * Check whether pool has some message queued for LV or for device_id
  * When LV is NULL and device_id is 0 it just checks for any message.
  */
-int pool_has_message(const struct lv_segment *seg,
-		     const struct logical_volume *lv, uint32_t device_id)
+int thin_pool_has_message(const struct lv_segment *seg,
+			  const struct logical_volume *lv, uint32_t device_id)
 {
 	const struct lv_thin_message *tmsg;
 
 	if (!seg_is_thin_pool(seg)) {
-		log_error(INTERNAL_ERROR "LV %s is not pool.", display_lvname(seg->lv));
+		log_error(INTERNAL_ERROR "LV %s is not a thin pool.", display_lvname(seg->lv));
 		return 0;
 	}
 
@@ -183,13 +183,13 @@ int pool_has_message(const struct lv_segment *seg,
 	return 0;
 }
 
-int pool_is_active(const struct logical_volume *lv)
+int thin_pool_is_active(const struct logical_volume *lv)
 {
 	struct lvinfo info;
 	const struct seg_list *sl;
 
 	if (!lv_is_thin_pool(lv)) {
-		log_error(INTERNAL_ERROR "pool_is_active called with non-pool volume %s.",
+		log_error(INTERNAL_ERROR "thin_pool_is_active called with non thin pool volume %s.",
 			  display_lvname(lv));
 		return 0;
 	}
@@ -233,7 +233,7 @@ int thin_pool_feature_supported(const struct logical_volume *lv, int feature)
 	return (attr & feature) ? 1 : 0;
 }
 
-int pool_metadata_min_threshold(const struct lv_segment *pool_seg)
+int thin_pool_metadata_min_threshold(const struct lv_segment *pool_seg)
 {
 	/*
 	 * Hardcoded minimal requirement for thin pool target.
@@ -252,11 +252,11 @@ int pool_metadata_min_threshold(const struct lv_segment *pool_seg)
 	return DM_PERCENT_100 - meta_free;
 }
 
-int pool_below_threshold(const struct lv_segment *pool_seg)
+int thin_pool_below_threshold(const struct lv_segment *pool_seg)
 {
 	struct cmd_context *cmd = pool_seg->lv->vg->cmd;
 	struct lv_status_thin_pool *thin_pool_status = NULL;
-	dm_percent_t min_threshold = pool_metadata_min_threshold(pool_seg);
+	dm_percent_t min_threshold = thin_pool_metadata_min_threshold(pool_seg);
 	dm_percent_t threshold = DM_PERCENT_1 *
 		find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG,
 				     lv_config_profile(pool_seg->lv));
@@ -344,7 +344,7 @@ out:
  * Lots of test combined together.
  * Test is not detecting status of dmeventd, too complex for now...
  */
-int pool_check_overprovisioning(const struct logical_volume *lv)
+int thin_pool_check_overprovisioning(const struct logical_volume *lv)
 {
 	const struct lv_list *lvl;
 	const struct seg_list *sl;
@@ -433,7 +433,7 @@ int pool_check_overprovisioning(const struct logical_volume *lv)
 /*
  * Validate given external origin could be used with thin pool
  */
-int pool_supports_external_origin(const struct lv_segment *pool_seg, const struct logical_volume *external_lv)
+int thin_pool_supports_external_origin(const struct lv_segment *pool_seg, const struct logical_volume *external_lv)
 {
 	uint32_t csize = pool_seg->chunk_size;
 
@@ -474,7 +474,7 @@ struct logical_volume *find_pool_lv(const struct logical_volume *lv)
  * FIXME: Improve naive search and keep the value cached
  * and updated during VG lifetime (so no const for lv_segment)
  */
-uint32_t get_free_pool_device_id(struct lv_segment *thin_pool_seg)
+uint32_t get_free_thin_pool_device_id(struct lv_segment *thin_pool_seg)
 {
 	uint32_t max_id = 0;
 	struct seg_list *sl;
@@ -516,7 +516,7 @@ static int _check_pool_create(const struct logical_volume *lv)
 				  display_lvname(lv));
 			return 0;
 		}
-		if (!pool_below_threshold(first_seg(lv))) {
+		if (!thin_pool_below_threshold(first_seg(lv))) {
 			log_error("Free space in pool %s is above threshold, new volumes are not allowed.",
 				  display_lvname(lv));
 			return 0;
@@ -527,13 +527,13 @@ static int _check_pool_create(const struct logical_volume *lv)
 	return 1;
 }
 
-int update_pool_lv(struct logical_volume *lv, int activate)
+int update_thin_pool_lv(struct logical_volume *lv, int activate)
 {
 	int monitored;
 	int ret = 1;
 
 	if (!lv_is_thin_pool(lv)) {
-		log_error(INTERNAL_ERROR "Updated LV %s is not pool.", display_lvname(lv));
+		log_error(INTERNAL_ERROR "Updated LV %s is not thin pool.", display_lvname(lv));
 		return 0;
 	}
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 5f3015026..9ce04438d 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -72,7 +72,7 @@ static int _thin_pool_add_message(struct lv_segment *seg,
 	else
 		return SEG_LOG_ERROR("Unknown message in");
 
-	if (!attach_pool_message(seg, type, lv, delete_id, 1))
+	if (!attach_thin_pool_message(seg, type, lv, delete_id, 1))
 		return_0;
 
 	return 1;
@@ -585,7 +585,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 
 	/* Add external origin LV */
 	if (seg->external_lv) {
-		if (!pool_supports_external_origin(first_seg(seg->pool_lv), seg->external_lv))
+		if (!thin_pool_supports_external_origin(first_seg(seg->pool_lv), seg->external_lv))
 			return_0;
 		if (seg->external_lv->size < seg->lv->size) {
 			/* Validate target supports smaller external origin */
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 670a4ec3d..34c9e36fd 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -103,7 +103,7 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 		if (discards != first_seg(lv)->discards) {
 			if (((discards == THIN_DISCARDS_IGNORE) ||
 			     (first_seg(lv)->discards == THIN_DISCARDS_IGNORE)) &&
-			    pool_is_active(lv))
+			    thin_pool_is_active(lv))
 				log_error("Cannot change support for discards while pool volume %s is active.",
 					  display_lvname(lv));
 			else {
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 081b344d0..6e5d748cc 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2414,7 +2414,7 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 	argv[++args] = pms_path;
 	argv[++args] = NULL;
 
-	if (pool_is_active(pool_lv)) {
+	if (thin_pool_is_active(pool_lv)) {
 		log_error("Active pools cannot be repaired.  Use lvchange -an first.");
 		return 0;
 	}
@@ -2781,7 +2781,7 @@ static int _lvconvert_to_thin_with_external(struct cmd_context *cmd,
 
 	dm_list_init(&lvc.tags);
 
-	if (!pool_supports_external_origin(first_seg(thinpool_lv), lv))
+	if (!thin_pool_supports_external_origin(first_seg(thinpool_lv), lv))
 		return_0;
 
 	if (!(lvc.segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_THIN)))
@@ -2906,7 +2906,7 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 	}
 
 	/* FIXME cache pool */
-	if (is_thinpool && pool_is_active(lv)) {
+	if (is_thinpool && thin_pool_is_active(lv)) {
 		/* If any volume referencing pool active - abort here */
 		log_error("Cannot convert pool %s with active volumes.",
 			  display_lvname(lv));


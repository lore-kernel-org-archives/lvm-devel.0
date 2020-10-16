From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:56 +0000 (GMT)
Subject: stable-2.02 - thin: use lv_status_thin and lv_status_thin_pool
Message-ID: <20201016191156.A9E79396EC83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0a825734161d2c90a5dfea091bf5e94e7002382a
Commit:        0a825734161d2c90a5dfea091bf5e94e7002382a
Parent:        45121aafe9f7623b7ca26678a9fa8ff659aaf1b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 27 01:11:47 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:54 2020 +0200

thin: use lv_status_thin and lv_status_thin_pool

Introduce structures lv_status_thin_pool and
lv_status_thin  (pair to lv_status_cache, lv_status_vdo)

Convert lv_thin_percent() -> lv_thin_status()
and  lv_thin_pool_percent() + lv_thin_pool_transaction_id() ->
lv_thin_pool_status().

This way a function user can see not only percentages, but also
other important status info about thin-pool.

TODO:
This patch tries to not change too many other things,
but pool_below_threshold() now uses new thin-pool info to return
failure if thin-pool cannot be actually modified.
This should be handle separately in a better way.
---
 lib/activate/activate.c          |  83 ++++++++-------------------
 lib/activate/activate.h          |  10 ++--
 lib/activate/dev_manager.c       | 118 +++++++++++++++++++++++++--------------
 lib/activate/dev_manager.h       |  16 ++----
 lib/display/display.c            |  22 +++++---
 lib/metadata/lv_manip.c          |  38 ++++++++-----
 lib/metadata/metadata-exported.h |  14 +++++
 lib/metadata/thin_manip.c        |  75 +++++++++++++++++++------
 lib/report/properties.c          |  60 ++++++++++++--------
 9 files changed, 255 insertions(+), 181 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 0bd769cdc..97486ebf0 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -285,18 +285,13 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 {
 	return 0;
 }
-int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
-			 dm_percent_t *percent)
+int lv_thin_pool_status(const struct logical_volume *lv, int flush,
+			struct lv_status_thin_pool **thin_pool_status)
 {
 	return 0;
 }
-int lv_thin_percent(const struct logical_volume *lv, int mapped,
-		    dm_percent_t *percent)
-{
-	return 0;
-}
-int lv_thin_pool_transaction_id(const struct logical_volume *lv,
-				uint64_t *transaction_id)
+int lv_thin_status(const struct logical_volume *lv, int flush,
+		   struct lv_status_thin **thin_status)
 {
 	return 0;
 }
@@ -1256,86 +1251,52 @@ int lv_cache_status(const struct logical_volume *cache_lv,
 	return 1;
 }
 
-/*
- * Returns data or metadata percent usage, depends on metadata 0/1.
- * Returns 1 if percent set, else 0 on failure.
- */
-int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
-			 dm_percent_t *percent)
+int lv_thin_pool_status(const struct logical_volume *lv, int flush,
+			struct lv_status_thin_pool **thin_pool_status)
 {
-	int r;
 	struct dev_manager *dm;
 
 	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking thin %sdata percent for LV %s.",
-			     (metadata) ? "meta" : "", display_lvname(lv));
+	log_debug_activation("Checking thin pool status for LV %s.",
+			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
-	if (!(r = dev_manager_thin_pool_percent(dm, lv, metadata, percent)))
-		stack;
+	if (!dev_manager_thin_pool_status(dm, lv, flush, thin_pool_status)) {
+		dev_manager_destroy(dm);
+		return_0;
+	}
 
-	dev_manager_destroy(dm);
+	/* User has to call dm_pool_destroy(thin_pool_status->mem)! */
 
-	return r;
+	return 1;
 }
 
-/*
- * Returns 1 if percent set, else 0 on failure.
- */
-int lv_thin_percent(const struct logical_volume *lv,
-		    int mapped, dm_percent_t *percent)
+int lv_thin_status(const struct logical_volume *lv, int flush,
+		   struct lv_status_thin **thin_status)
 {
-	int r;
 	struct dev_manager *dm;
 
 	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking thin percent for LV %s.",
+	log_debug_activation("Checking thin status for LV %s.",
 			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
-	if (!(r = dev_manager_thin_percent(dm, lv, mapped, percent)))
-		stack;
-
-	dev_manager_destroy(dm);
-
-	return r;
-}
-
-/*
- * Returns 1 if transaction_id set, else 0 on failure.
- */
-int lv_thin_pool_transaction_id(const struct logical_volume *lv,
-				uint64_t *transaction_id)
-{
-	int r;
-	struct dev_manager *dm;
-	struct dm_status_thin_pool *status;
-
-	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
-		return 0;
-
-	log_debug_activation("Checking thin-pool transaction id for LV %s.",
-			     display_lvname(lv));
-
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+	if (!dev_manager_thin_status(dm, lv, flush, thin_status)) {
+		dev_manager_destroy(dm);
 		return_0;
+	}
 
-	if (!(r = dev_manager_thin_pool_status(dm, lv, &status, 0)))
-		stack;
-	else
-		*transaction_id = status->transaction_id;
-
-	dev_manager_destroy(dm);
+	/* User has to call dm_pool_destroy(thin_status->mem)! */
 
-	return r;
+	return 1;
 }
 
 int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id)
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 71392765b..6eecbde17 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -178,13 +178,11 @@ int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action);
 int lv_raid_message(const struct logical_volume *lv, const char *msg);
 int lv_cache_status(const struct logical_volume *cache_lv,
 		    struct lv_status_cache **status);
-int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
-			 dm_percent_t *percent);
-int lv_thin_percent(const struct logical_volume *lv, int mapped,
-		    dm_percent_t *percent);
-int lv_thin_pool_transaction_id(const struct logical_volume *lv,
-				uint64_t *transaction_id);
 int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id);
+int lv_thin_status(const struct logical_volume *lv, int flush,
+		   struct lv_status_thin **status);
+int lv_thin_pool_status(const struct logical_volume *lv, int flush,
+			struct lv_status_thin_pool **status);
 
 /*
  * Return number of LVs in the VG that are active.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 7acb3e9f7..7d9cb917e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1472,9 +1472,6 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
-	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_cache))))
-		return_0;
-
 	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, 0, 0)))
 		return_0;
 
@@ -1497,8 +1494,11 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	if (!dm_get_status_cache(dm->mem, params, &c))
 		goto_out;
 
-	(*status)->cache = c;
+	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_cache))))
+		goto_out;
+
 	(*status)->mem = dm->mem; /* User has to destroy this mem pool later */
+	(*status)->cache = c;
 	if (c->fail || c->error) {
 		(*status)->data_usage =
 			(*status)->metadata_usage =
@@ -1520,10 +1520,10 @@ out:
 }
 
 int dev_manager_thin_pool_status(struct dev_manager *dm,
-				 const struct logical_volume *lv,
-				 struct dm_status_thin_pool **status,
-				 int flush)
+				 const struct logical_volume *lv, int flush,
+				 struct lv_status_thin_pool **status)
 {
+	struct dm_status_thin_pool *dm_status;
 	const char *dlid;
 	struct dm_task *dmt;
 	struct dm_info info;
@@ -1544,11 +1544,31 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
-	/* FIXME Check for thin and check there's exactly one target */
+	if (!type || strcmp(type, TARGET_NAME_THIN_POOL)) {
+		log_error("Expected %s segment type but got %s instead.",
+			  TARGET_NAME_THIN_POOL, type ? type : "NULL");
+		goto out;
+	}
 
-	if (!dm_get_status_thin_pool(dm->mem, params, status))
+	if (!dm_get_status_thin_pool(dm->mem, params, &dm_status))
 		goto_out;
 
+	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_thin_pool))))
+		goto_out;
+
+	(*status)->mem = dm->mem;
+	(*status)->thin_pool = dm_status;
+
+	if (dm_status->fail || dm_status->error) {
+		(*status)->data_usage =
+			(*status)->metadata_usage = DM_PERCENT_INVALID;
+	} else {
+		(*status)->data_usage = dm_make_percent(dm_status->used_data_blocks,
+							dm_status->total_data_blocks);
+		(*status)->metadata_usage = dm_make_percent(dm_status->used_metadata_blocks,
+							    dm_status->total_metadata_blocks);
+	}
+
 	r = 1;
 out:
 	dm_task_destroy(dmt);
@@ -1556,52 +1576,68 @@ out:
 	return r;
 }
 
-int dev_manager_thin_pool_percent(struct dev_manager *dm,
-				  const struct logical_volume *lv,
-				  int metadata, dm_percent_t *percent)
+int dev_manager_thin_status(struct dev_manager *dm,
+			    const struct logical_volume *lv, int flush,
+			    struct lv_status_thin **status)
 {
-	char *name;
+	struct dm_status_thin *dm_status;
 	const char *dlid;
-	const char *layer = lv_layer(lv);
+	struct dm_task *dmt;
+	struct dm_info info;
+	uint64_t start, length;
+	char *type = NULL;
+	char *params = NULL;
+	uint64_t csize;
+	int r = 0;
 
-	/* Build a name for the top layer */
-	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
+	if (!(dmt = _setup_task_run(DM_DEVICE_STATUS, &info, NULL, dlid, 0, 0, 0, 0, flush, 0)))
 		return_0;
 
-	log_debug_activation("Getting device status percentage for %s.", name);
-
-	if (!(_percent(dm, name, dlid, TARGET_NAME_THIN_POOL, 0,
-		       (metadata) ? lv : NULL, percent, NULL, 1)))
-		return_0;
+	if (!info.exists)
+		goto_out;
 
-	return 1;
-}
+	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
-int dev_manager_thin_percent(struct dev_manager *dm,
-			     const struct logical_volume *lv,
-			     int mapped, dm_percent_t *percent)
-{
-	char *name;
-	const char *dlid;
-	const char *layer = lv_layer(lv);
+	if (!type || strcmp(type, TARGET_NAME_THIN)) {
+		log_error("Expected %s segment type but got %s instead.",
+			  TARGET_NAME_THIN, type ? type : "NULL");
+		goto out;
+	}
 
-	/* Build a name for the top layer */
-	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
-		return_0;
+	if (!dm_get_status_thin(dm->mem, params, &dm_status))
+		goto_out;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
-		return_0;
+	if (!(*status = dm_pool_zalloc(dm->mem, sizeof(struct lv_status_thin))))
+		goto_out;
 
-	log_debug_activation("Getting device status percentage for %s", name);
+	(*status)->mem = dm->mem;
+	(*status)->thin = dm_status;
+
+	if (dm_status->fail)
+		(*status)->usage = DM_PERCENT_INVALID;
+	else {
+		/* Pool allocates whole chunk so round-up to nearest one */
+		csize = first_seg(first_seg(lv)->pool_lv)->chunk_size;
+		csize = ((lv->size + csize - 1) / csize) * csize;
+		if (dm_status->mapped_sectors > csize) {
+			log_warn("WARNING: LV %s maps %s while the size is only %s.",
+				 display_lvname(lv),
+				 display_size(dm->cmd, dm_status->mapped_sectors),
+				 display_size(dm->cmd, csize));
+			/* Don't show nonsense numbers like i.e. 1000% full */
+			dm_status->mapped_sectors = csize;
+		}
+		(*status)->usage = dm_make_percent(dm_status->mapped_sectors, csize);
+	}
 
-	if (!(_percent(dm, name, dlid, TARGET_NAME_THIN, 0,
-		       (mapped) ? NULL : lv, percent, NULL, 1)))
-		return_0;
+	r = 1;
+out:
+	dm_task_destroy(dmt);
 
-	return 1;
+	return r;
 }
 
 /*
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 20b6a26d1..1a3d5f98c 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -66,19 +66,15 @@ int dev_manager_raid_message(struct dev_manager *dm,
 int dev_manager_cache_status(struct dev_manager *dm,
 			     const struct logical_volume *lv,
 			     struct lv_status_cache **status);
-int dev_manager_thin_pool_status(struct dev_manager *dm,
-				 const struct logical_volume *lv,
-				 struct dm_status_thin_pool **status,
-				 int flush);
-int dev_manager_thin_pool_percent(struct dev_manager *dm,
-				  const struct logical_volume *lv,
-				  int metadata, dm_percent_t *percent);
-int dev_manager_thin_percent(struct dev_manager *dm,
-			     const struct logical_volume *lv,
-			     int mapped, dm_percent_t *percent);
+int dev_manager_thin_status(struct dev_manager *dm,
+			    const struct logical_volume *lv, int flush,
+			    struct lv_status_thin **status);
 int dev_manager_thin_device_id(struct dev_manager *dm,
 			       const struct logical_volume *lv,
 			       uint32_t *device_id);
+int dev_manager_thin_pool_status(struct dev_manager *dm,
+				 const struct logical_volume *lv, int flush,
+				 struct lv_status_thin_pool **status);
 int dev_manager_suspend(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv,
diff --git a/lib/display/display.c b/lib/display/display.c
index 9b4be8833..d8220397b 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -406,10 +406,12 @@ int lvdisplay_full(struct cmd_context *cmd,
 	struct lv_segment *seg = NULL;
 	int lvm1compat;
 	dm_percent_t snap_percent;
-	int thin_data_active = 0, thin_metadata_active = 0;
+	int thin_pool_active = 0;
 	dm_percent_t thin_data_percent, thin_metadata_percent;
 	int thin_active = 0;
 	dm_percent_t thin_percent;
+	struct lv_status_thin *thin_status = NULL;
+	struct lv_status_thin_pool *thin_pool_status = NULL;
 	struct lv_status_cache *cache_status = NULL;
 
 	if (lv_is_historical(lv))
@@ -502,15 +504,18 @@ int lvdisplay_full(struct cmd_context *cmd,
 		if (seg->merge_lv)
 			log_print("LV merging to          %s",
 				  seg->merge_lv->name);
-		if (inkernel)
-			thin_active = lv_thin_percent(lv, 0, &thin_percent);
+		if (inkernel && (thin_active = lv_thin_status(lv, 0, &thin_status))) {
+			thin_percent = thin_status->usage;
+			dm_pool_destroy(thin_status->mem);
+		}
 		if (lv_is_merging_origin(lv))
 			log_print("LV merged with         %s",
 				  find_snapshot(lv)->lv->name);
 	} else if (lv_is_thin_pool(lv)) {
-		if (lv_info(cmd, lv, 1, &info, 1, 1) && info.exists) {
-			thin_data_active = lv_thin_pool_percent(lv, 0, &thin_data_percent);
-			thin_metadata_active = lv_thin_pool_percent(lv, 1, &thin_metadata_percent);
+		if ((thin_pool_active = lv_thin_pool_status(lv, 0, &thin_pool_status))) {
+			thin_data_percent = thin_pool_status->data_usage;
+			thin_metadata_percent = thin_pool_status->metadata_usage;
+			dm_pool_destroy(thin_pool_status->mem);
 		}
 		/* FIXME: display thin_pool targets transid for activated LV as well */
 		seg = first_seg(lv);
@@ -569,13 +574,12 @@ int lvdisplay_full(struct cmd_context *cmd,
 		dm_pool_destroy(cache_status->mem);
 	}
 
-	if (thin_data_active)
+	if (thin_pool_active) {
 		log_print("Allocated pool data    %s%%",
 			  display_percent(cmd, thin_data_percent));
-
-	if (thin_metadata_active)
 		log_print("Allocated metadata     %s%%",
 			  display_percent(cmd, thin_metadata_percent));
+	}
 
 	if (thin_active)
 		log_print("Mapped size            %s%%",
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 341cbbff4..399ac0774 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4674,6 +4674,7 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 	dm_percent_t percent;
 	dm_percent_t min_threshold;
 	int policy_threshold, policy_amount;
+	struct lv_status_thin_pool *thin_pool_status;
 
 	*amount = *meta_amount = 0;
 
@@ -4717,21 +4718,26 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 	}
 
 	if (lv_is_thin_pool(lv)) {
-		if (!lv_thin_pool_percent(lv, 1, &percent))
-			return_0;
+		if (!lv_thin_pool_status(lv, 0, &thin_pool_status))
+			goto_bad;
 
 		/* Resize below the minimal usable value */
 		min_threshold = pool_metadata_min_threshold(first_seg(lv)) / DM_PERCENT_1;
-		*meta_amount = _adjust_amount(percent, (min_threshold < policy_threshold) ?
+		*meta_amount = _adjust_amount(thin_pool_status->metadata_usage,
+					      (min_threshold < policy_threshold) ?
 					      min_threshold : policy_threshold, policy_amount);
 		if (*meta_amount)
 			/* Compensate possible extra space consumption by kernel on resize */
 			(*meta_amount)++;
-		if (!lv_thin_pool_percent(lv, 0, &percent))
-			return_0;
-	} else {
-		if (!lv_snapshot_percent(lv, &percent))
-			return_0;
+		percent = thin_pool_status->data_usage;
+		dm_pool_destroy(thin_pool_status->mem);
+	} else if (!lv_snapshot_percent(lv, &percent))
+			goto_bad;
+	else if (!lv_is_active(lv)) {
+	bad:
+		log_error("Can't read state of locally inactive LV %s.",
+			  display_lvname(lv));
+		return 0;
 	}
 
 	*amount = _adjust_amount(percent, policy_threshold, policy_amount);
@@ -7996,17 +8002,21 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				 * and needs to be restored to the state from this canceled segment.
 				 * TODO: there is low chance actual suspend has failed
 				 */
-				if (!lv_thin_pool_transaction_id(pool_lv, &transaction_id)) {
+				struct lv_status_thin_pool *tpstatus;
+				if (!lv_thin_pool_status(pool_lv, 1, &tpstatus))
 					log_error("Aborting. Failed to read transaction_id from thin pool %s.",
 						  display_lvname(pool_lv)); /* Can't even get thin pool transaction id ??? */
-				} else if (transaction_id != first_seg(pool_lv)->transaction_id) {
-					if (transaction_id == seg->transaction_id)
-						log_debug_metadata("Reverting back transaction_id " FMTu64 " for thin pool %s.",
-								   seg->transaction_id, display_lvname(pool_lv));
-					else
+				else {
+					transaction_id = tpstatus->thin_pool->transaction_id;
+					dm_pool_destroy(tpstatus->mem);
+
+					if ((transaction_id != first_seg(pool_lv)->transaction_id) &&
+					    (transaction_id != seg->transaction_id))
 						log_warn("WARNING: Metadata for thin pool %s have transaction_id " FMTu64
 							 ", but active pool has " FMTu64 ".",
 							 display_lvname(pool_lv), seg->transaction_id, transaction_id);
+					log_debug_metadata("Restoring previous transaction_id " FMTu64 " for thin pool %s.",
+							   seg->transaction_id, display_lvname(pool_lv));
 					first_seg(pool_lv)->transaction_id = seg->transaction_id;
 					first_seg(lv)->device_id = 0; /* no delete of never existing thin device */
 				}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index bd0eb6ca9..4833d59d1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -861,6 +861,20 @@ int update_thin_pool_params(struct cmd_context *cmd,
 			    uint32_t *pool_metadata_extents,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
 			    thin_discards_t *discards, thin_zero_t *zero_new_blocks);
+
+struct lv_status_thin_pool {
+	struct dm_pool *mem;
+	struct dm_status_thin_pool *thin_pool;
+	dm_percent_t data_usage;
+	dm_percent_t metadata_usage;
+};
+
+struct lv_status_thin {
+	struct dm_pool *mem;
+	struct dm_status_thin *thin;
+	dm_percent_t usage;
+};
+
 const char *get_pool_discards_name(thin_discards_t discards);
 int set_pool_discards(thin_discards_t *discards, const char *str);
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index db2644a05..9fb12cfa7 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -243,51 +243,86 @@ int pool_metadata_min_threshold(const struct lv_segment *pool_seg)
 int pool_below_threshold(const struct lv_segment *pool_seg)
 {
 	struct cmd_context *cmd = pool_seg->lv->vg->cmd;
-	dm_percent_t percent;
+	struct lv_status_thin_pool *thin_pool_status = NULL;
 	dm_percent_t min_threshold = pool_metadata_min_threshold(pool_seg);
 	dm_percent_t threshold = DM_PERCENT_1 *
 		find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG,
 				     lv_config_profile(pool_seg->lv));
+	int ret = 1;
 
-	/* Data */
-	if (!lv_thin_pool_percent(pool_seg->lv, 0, &percent))
+	if (threshold > DM_PERCENT_100)
+		threshold = DM_PERCENT_100;
+
+	/* FIXME: currently with FLUSH - this may block pool while holding VG lock
+	 * maybe try 2-phase version - 1st. check without commit
+	 * 2nd. quickly following with commit */
+	if (!lv_thin_pool_status(pool_seg->lv, 1, &thin_pool_status))
 		return_0;
 
-	if (percent > threshold || percent >= DM_PERCENT_100) {
+	if (thin_pool_status->thin_pool->fail |
+	    thin_pool_status->thin_pool->out_of_data_space |
+	    thin_pool_status->thin_pool->needs_check |
+	    thin_pool_status->thin_pool->error |
+	    thin_pool_status->thin_pool->read_only) {
+		log_warn("WARNING: Thin pool %s%s%s%s%s%s.",
+			 display_lvname(pool_seg->lv),
+			 thin_pool_status->thin_pool->fail ? " is failed" : "",
+			 thin_pool_status->thin_pool->out_of_data_space ? " is out of data space" : "",
+			 thin_pool_status->thin_pool->needs_check ? " needs check" : "",
+			 thin_pool_status->thin_pool->error ? " is erroring" : "",
+			 thin_pool_status->thin_pool->read_only ? " has read-only metadata" : "");
+		ret = 0;
+		if (thin_pool_status->thin_pool->fail)
+			goto out;
+	}
+
+	/* Data */
+
+	if (thin_pool_status->data_usage > threshold) {
 		log_debug("Threshold configured for free data space in "
 			  "thin pool %s has been reached (%s%% >= %s%%).",
 			  display_lvname(pool_seg->lv),
-			  display_percent(cmd, percent),
+			  display_percent(cmd, thin_pool_status->data_usage),
 			  display_percent(cmd, threshold));
-		return 0;
+		ret = 0;
 	}
 
 	/* Metadata */
-	if (!lv_thin_pool_percent(pool_seg->lv, 1, &percent))
-		return_0;
 
-
-	if (percent >= min_threshold) {
+	if (thin_pool_status->metadata_usage >= min_threshold) {
 		log_warn("WARNING: Remaining free space in metadata of thin pool %s "
 			 "is too low (%s%% >= %s%%). "
 			 "Resize is recommended.",
 			 display_lvname(pool_seg->lv),
-			 display_percent(cmd, percent),
+			 display_percent(cmd, thin_pool_status->metadata_usage),
 			 display_percent(cmd, min_threshold));
-		return 0;
+		ret = 0;
 	}
 
-
-	if (percent > threshold) {
+	if (thin_pool_status->metadata_usage > threshold) {
 		log_debug("Threshold configured for free metadata space in "
 			  "thin pool %s has been reached (%s%% > %s%%).",
 			  display_lvname(pool_seg->lv),
-			  display_percent(cmd, percent),
+			  display_percent(cmd, thin_pool_status->metadata_usage),
 			  display_percent(cmd, threshold));
-		return 0;
+		ret = 0;
 	}
 
-	return 1;
+	if ((thin_pool_status->thin_pool->transaction_id != pool_seg->transaction_id) &&
+	    (dm_list_empty(&pool_seg->thin_messages) ||
+	     ((thin_pool_status->thin_pool->transaction_id + 1) != pool_seg->transaction_id))) {
+		log_warn("WARNING: Thin pool %s has unexpected transaction id " FMTu64
+			 ", expecting " FMTu64 "%s.",
+			 display_lvname(pool_seg->lv),
+			 thin_pool_status->thin_pool->transaction_id,
+			 pool_seg->transaction_id,
+			 dm_list_empty(&pool_seg->thin_messages) ? "" : " or lower by 1");
+		ret = 0;
+	}
+out:
+	dm_pool_destroy(thin_pool_status->mem);
+
+	return ret;
 }
 
 /*
@@ -855,6 +890,7 @@ int check_new_thin_pool(const struct logical_volume *pool_lv)
 {
 	struct cmd_context *cmd = pool_lv->vg->cmd;
 	uint64_t transaction_id;
+	struct lv_status_thin_pool *status = NULL;
 
 	/* For transaction_id check LOCAL activation is required */
 	if (!activate_lv_excl_local(cmd, pool_lv)) {
@@ -864,12 +900,15 @@ int check_new_thin_pool(const struct logical_volume *pool_lv)
 	}
 
 	/* With volume lists, check pool really is locally active */
-	if (!lv_thin_pool_transaction_id(pool_lv, &transaction_id)) {
+	if (!lv_thin_pool_status(pool_lv, 1, &status)) {
 		log_error("Cannot read thin pool %s transaction id locally, perhaps skipped in lvm.conf volume_list?",
 			  display_lvname(pool_lv));
 		return 0;
 	}
 
+	transaction_id = status->thin_pool->transaction_id;
+	dm_pool_destroy(status->mem);
+
 	/* Require pool to have same transaction_id as new  */
 	if (first_seg(pool_lv)->transaction_id != transaction_id) {
 		log_error("Cannot use thin pool %s with transaction id "
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 72c8f3236..c37e97721 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -103,47 +103,63 @@ static dm_percent_t _snap_percent(const struct logical_volume *lv)
 
 static dm_percent_t _data_percent(const struct logical_volume *lv)
 {
-	dm_percent_t percent;
-	struct lv_status_cache *status;
+	dm_percent_t percent = DM_PERCENT_INVALID;
+	struct lv_status_cache *cache_status;
+	struct lv_status_thin *thin_status;
+	struct lv_status_thin_pool *thin_pool_status;
 
 	if (lv_is_cow(lv))
 		return _snap_percent(lv);
 
 	if (lv_is_cache(lv) || lv_is_used_cache_pool(lv)) {
-		if (!lv_cache_status(lv, &status)) {
+		if (!lv_cache_status(lv, &cache_status))
+			stack;
+		else {
+			percent = cache_status->data_usage;
+			dm_pool_destroy(cache_status->mem);
+		}
+	} else  if (lv_is_thin_volume(lv)) {
+		if (!lv_thin_status(lv, 0, &thin_status))
 			stack;
-			return DM_PERCENT_INVALID;
+		else {
+			percent = thin_status->usage;
+			dm_pool_destroy(thin_status->mem);
+		}
+	} else if (lv_is_thin_pool(lv)) {
+		if (!lv_thin_pool_status(lv, 0, &thin_pool_status))
+			stack;
+		else {
+			percent = thin_pool_status->data_usage;
+			dm_pool_destroy(thin_pool_status->mem);
 		}
-		percent = status->data_usage;
-		dm_pool_destroy(status->mem);
-		return percent;
 	}
 
-	if (lv_is_thin_volume(lv))
-		return lv_thin_percent(lv, 0, &percent) ? percent : DM_PERCENT_INVALID;
-
-	return lv_thin_pool_percent(lv, 0, &percent) ? percent : DM_PERCENT_INVALID;
+	return percent;
 }
 
 static dm_percent_t _metadata_percent(const struct logical_volume *lv)
 {
-	dm_percent_t percent;
-	struct lv_status_cache *status;
+	dm_percent_t percent = DM_PERCENT_INVALID;
+	struct lv_status_cache *cache_status;
+	struct lv_status_thin_pool *thin_pool_status;
 
 	if (lv_is_cache(lv) || lv_is_used_cache_pool(lv)) {
-		if (!lv_cache_status(lv, &status)) {
+		if (!lv_cache_status(lv, &cache_status))
+			stack;
+		else {
+			percent = cache_status->metadata_usage;
+			dm_pool_destroy(cache_status->mem);
+		}
+	} else if (lv_is_thin_pool(lv)) {
+		if (!lv_thin_pool_status(lv, 0, &thin_pool_status))
 			stack;
-			return DM_PERCENT_INVALID;
+		else {
+			percent = thin_pool_status->metadata_usage;
+			dm_pool_destroy(thin_pool_status->mem);
 		}
-		percent = status->metadata_usage;
-		dm_pool_destroy(status->mem);
-		return percent;
 	}
 
-	if (lv_is_thin_pool(lv))
-		return lv_thin_pool_percent(lv, 1, &percent) ? percent : DM_PERCENT_INVALID;
-
-	return DM_PERCENT_INVALID;
+	return percent;
 }
 
 /* PV */



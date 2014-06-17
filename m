From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:35 +0000 (UTC)
Subject: master - report: select: refactor: move percent handling code to libdm for reuse
Message-ID: <20140617143435.1C24260C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cfed0d09e8ef8f0f819420a15c9165d4fd49a890
Commit:        cfed0d09e8ef8f0f819420a15c9165d4fd49a890
Parent:        35c4e4489c9eef22691332b43e51b03055e4fe92
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 9 12:08:27 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:21 2014 +0200

report: select: refactor: move percent handling code to libdm for reuse

---
 lib/activate/activate.c          |   22 +++++-----
 lib/activate/activate.h          |   10 ++--
 lib/activate/dev_manager.c       |   40 ++++++++++----------
 lib/activate/dev_manager.h       |    8 ++--
 lib/display/display.c            |   18 ++++----
 lib/metadata/lv.c                |   14 +++---
 lib/metadata/lv_manip.c          |   34 ++++++++--------
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/mirror.c            |   12 +++---
 lib/metadata/raid_manip.c        |    4 +-
 lib/metadata/segtype.h           |    2 +-
 lib/metadata/thin_manip.c        |    4 +-
 lib/mirror/mirrored.c            |    4 +-
 lib/misc/lvm-percent.c           |   24 -----------
 lib/misc/lvm-percent.h           |   25 +-----------
 lib/raid/raid.c                  |    4 +-
 lib/replicator/replicator.c      |    4 +-
 lib/report/properties.c          |   26 ++++++------
 lib/report/report.c              |   79 +++++++++++++-------------------------
 lib/snapshot/snapshot.c          |   12 +++---
 lib/thin/thin.c                  |   16 ++++----
 libdm/libdevmapper.h             |   32 +++++++++++++++
 libdm/libdm-report.c             |   60 ++++++++++++++++++++++++++++
 liblvm/lvm2app.h                 |   25 +++---------
 liblvm/lvm_base.c                |    2 +-
 test/api/thin_percent.c          |    2 +-
 tools/lvconvert.c                |   20 +++++-----
 tools/lvcreate.c                 |    2 +-
 tools/lvscan.c                   |    4 +-
 tools/polldaemon.c               |   12 +++---
 30 files changed, 266 insertions(+), 257 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 41d74c7..adaff52 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -253,16 +253,16 @@ int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
 {
         return 0;
 }
-int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent)
+int lv_snapshot_percent(const struct logical_volume *lv, dm_percent_t *percent)
 {
 	return 0;
 }
 int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
-		      int wait, percent_t *percent, uint32_t *event_nr)
+		      int wait, dm_percent_t *percent, uint32_t *event_nr)
 {
 	return 0;
 }
-int lv_raid_percent(const struct logical_volume *lv, percent_t *percent)
+int lv_raid_percent(const struct logical_volume *lv, dm_percent_t *percent)
 {
 	return 0;
 }
@@ -295,12 +295,12 @@ int lv_cache_policy_info(struct logical_volume *lv,
 	return 0;
 }
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
-			 percent_t *percent)
+			 dm_percent_t *percent)
 {
 	return 0;
 }
 int lv_thin_percent(const struct logical_volume *lv, int mapped,
-		    percent_t *percent)
+		    dm_percent_t *percent)
 {
 	return 0;
 }
@@ -765,7 +765,7 @@ int lv_check_transient(struct logical_volume *lv)
 /*
  * Returns 1 if percent set, else 0 on failure.
  */
-int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent)
+int lv_snapshot_percent(const struct logical_volume *lv, dm_percent_t *percent)
 {
 	int r;
 	struct dev_manager *dm;
@@ -788,7 +788,7 @@ int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent)
 
 /* FIXME Merge with snapshot_percent */
 int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
-		      int wait, percent_t *percent, uint32_t *event_nr)
+		      int wait, dm_percent_t *percent, uint32_t *event_nr)
 {
 	int r;
 	struct dev_manager *dm;
@@ -796,7 +796,7 @@ int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 	/* If mirrored LV is temporarily shrinked to 1 area (= linear),
 	 * it should be considered in-sync. */
 	if (dm_list_size(&lv->segments) == 1 && first_seg(lv)->area_count == 1) {
-		*percent = PERCENT_100;
+		*percent = DM_PERCENT_100;
 		return 1;
 	}
 
@@ -817,7 +817,7 @@ int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 	return r;
 }
 
-int lv_raid_percent(const struct logical_volume *lv, percent_t *percent)
+int lv_raid_percent(const struct logical_volume *lv, dm_percent_t *percent)
 {
 	return lv_mirror_percent(lv->vg->cmd, lv, 0, percent, NULL);
 }
@@ -1145,7 +1145,7 @@ int lv_cache_policy_info(struct logical_volume *lv,
  * Returns 1 if percent set, else 0 on failure.
  */
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
-			 percent_t *percent)
+			 dm_percent_t *percent)
 {
 	int r;
 	struct dev_manager *dm;
@@ -1171,7 +1171,7 @@ int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
  * Returns 1 if percent set, else 0 on failure.
  */
 int lv_thin_percent(const struct logical_volume *lv,
-		    int mapped, percent_t *percent)
+		    int mapped, dm_percent_t *percent)
 {
 	int r;
 	struct dev_manager *dm;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 946494e..b6cf474 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -112,10 +112,10 @@ int lv_check_transient(struct logical_volume *lv);
 /*
  * Returns 1 if percent has been set, else 0.
  */
-int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent);
+int lv_snapshot_percent(const struct logical_volume *lv, dm_percent_t *percent);
 int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
-		      int wait, percent_t *percent, uint32_t *event_nr);
-int lv_raid_percent(const struct logical_volume *lv, percent_t *percent);
+		      int wait, dm_percent_t *percent, uint32_t *event_nr);
+int lv_raid_percent(const struct logical_volume *lv, dm_percent_t *percent);
 int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt);
 int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action);
@@ -127,9 +127,9 @@ int lv_cache_policy_info(struct logical_volume *lv,
 			 const char **policy_name, int *policy_argc,
 			 const char ***policy_argv);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
-			 percent_t *percent);
+			 dm_percent_t *percent);
 int lv_thin_percent(const struct logical_volume *lv, int mapped,
-		    percent_t *percent);
+		    dm_percent_t *percent);
 int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 				uint64_t *transaction_id);
 int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 22b13ec..e30b176 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -719,28 +719,28 @@ int add_linear_area_to_dtree(struct dm_tree_node *node, uint64_t size, uint32_t
 	return 1;
 }
 
-static percent_range_t _combine_percent(percent_t a, percent_t b,
-                                        uint32_t numerator, uint32_t denominator)
+static dm_percent_range_t _combine_percent(dm_percent_t a, dm_percent_t b,
+					   uint32_t numerator, uint32_t denominator)
 {
-	if (a == PERCENT_MERGE_FAILED || b == PERCENT_MERGE_FAILED)
-		return PERCENT_MERGE_FAILED;
+	if (a == LVM_PERCENT_MERGE_FAILED || b == LVM_PERCENT_MERGE_FAILED)
+		return LVM_PERCENT_MERGE_FAILED;
 
-	if (a == PERCENT_INVALID || b == PERCENT_INVALID)
-		return PERCENT_INVALID;
+	if (a == DM_PERCENT_INVALID || b == DM_PERCENT_INVALID)
+		return DM_PERCENT_INVALID;
 
-	if (a == PERCENT_100 && b == PERCENT_100)
-		return PERCENT_100;
+	if (a == DM_PERCENT_100 && b == DM_PERCENT_100)
+		return DM_PERCENT_100;
 
-	if (a == PERCENT_0 && b == PERCENT_0)
-		return PERCENT_0;
+	if (a == DM_PERCENT_0 && b == DM_PERCENT_0)
+		return DM_PERCENT_0;
 
-	return (percent_range_t) make_percent(numerator, denominator);
+	return (dm_percent_range_t) dm_make_percent(numerator, denominator);
 }
 
 static int _percent_run(struct dev_manager *dm, const char *name,
 			const char *dlid,
 			const char *target_type, int wait,
-			const struct logical_volume *lv, percent_t *overall_percent,
+			const struct logical_volume *lv, dm_percent_t *overall_percent,
 			uint32_t *event_nr, int fail_if_percent_unsupported)
 {
 	int r = 0;
@@ -754,7 +754,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	struct lv_segment *seg = NULL;
 	struct segment_type *segtype;
 	int first_time = 1;
-	percent_t percent = PERCENT_INVALID;
+	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	uint64_t total_numerator = 0, total_denominator = 0;
 
@@ -829,12 +829,12 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	if (first_time) {
 		/* above ->target_percent() was not executed! */
 		/* FIXME why return PERCENT_100 et. al. in this case? */
-		*overall_percent = PERCENT_100;
+		*overall_percent = DM_PERCENT_100;
 		if (fail_if_percent_unsupported)
 			goto_out;
 	}
 
-	log_debug_activation("LV percent: %f", percent_to_float(*overall_percent));
+	log_debug_activation("LV percent: %f", dm_percent_to_float(*overall_percent));
 	r = 1;
 
       out:
@@ -844,7 +844,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 
 static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 		    const char *target_type, int wait,
-		    const struct logical_volume *lv, percent_t *percent,
+		    const struct logical_volume *lv, dm_percent_t *percent,
 		    uint32_t *event_nr, int fail_if_percent_unsupported)
 {
 	if (dlid && *dlid) {
@@ -988,7 +988,7 @@ void dev_manager_exit(void)
 
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
-				 percent_t *percent)
+				 dm_percent_t *percent)
 {
 	const struct logical_volume *snap_lv;
 	char *name;
@@ -1041,7 +1041,7 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 /* FIXME Cope with more than one target */
 int dev_manager_mirror_percent(struct dev_manager *dm,
 			       const struct logical_volume *lv, int wait,
-			       percent_t *percent, uint32_t *event_nr)
+			       dm_percent_t *percent, uint32_t *event_nr)
 {
 	char *name;
 	const char *dlid;
@@ -1325,7 +1325,7 @@ out:
 
 int dev_manager_thin_pool_percent(struct dev_manager *dm,
 				  const struct logical_volume *lv,
-				  int metadata, percent_t *percent)
+				  int metadata, dm_percent_t *percent)
 {
 	char *name;
 	const char *dlid;
@@ -1348,7 +1348,7 @@ int dev_manager_thin_pool_percent(struct dev_manager *dm,
 
 int dev_manager_thin_percent(struct dev_manager *dm,
 			     const struct logical_volume *lv,
-			     int mapped, percent_t *percent)
+			     int mapped, dm_percent_t *percent)
 {
 	char *name;
 	const char *dlid;
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 446b349..9bdc413 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -50,10 +50,10 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		     struct dm_info *info, uint32_t *read_ahead);
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
-				 percent_t *percent);
+				 dm_percent_t *percent);
 int dev_manager_mirror_percent(struct dev_manager *dm,
 			       const struct logical_volume *lv, int wait,
-			       percent_t *percent, uint32_t *event_nr);
+			       dm_percent_t *percent, uint32_t *event_nr);
 int dev_manager_raid_status(struct dev_manager *dm,
 			    const struct logical_volume *lv,
 			    struct dm_status_raid **status);
@@ -69,10 +69,10 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 int noflush);
 int dev_manager_thin_pool_percent(struct dev_manager *dm,
 				  const struct logical_volume *lv,
-				  int metadata, percent_t *percent);
+				  int metadata, dm_percent_t *percent);
 int dev_manager_thin_percent(struct dev_manager *dm,
 			     const struct logical_volume *lv,
-			     int mapped, percent_t *percent);
+			     int mapped, dm_percent_t *percent);
 int dev_manager_thin_device_id(struct dev_manager *dm,
 			       const struct logical_volume *lv,
 			       uint32_t *device_id);
diff --git a/lib/display/display.c b/lib/display/display.c
index 70a4cda..9780f10 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -427,11 +427,11 @@ int lvdisplay_full(struct cmd_context *cmd,
 	struct lv_segment *snap_seg = NULL, *mirror_seg = NULL;
 	struct lv_segment *seg = NULL;
 	int lvm1compat;
-	percent_t snap_percent;
+	dm_percent_t snap_percent;
 	int thin_data_active = 0, thin_metadata_active = 0;
-	percent_t thin_data_percent, thin_metadata_percent;
+	dm_percent_t thin_data_percent, thin_metadata_percent;
 	int thin_active = 0;
-	percent_t thin_percent;
+	dm_percent_t thin_percent;
 
 	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid)))
 		return_0;
@@ -477,7 +477,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 			if (inkernel &&
 			    (snap_active = lv_snapshot_percent(snap_seg->cow,
 							       &snap_percent)))
-				if (snap_percent == PERCENT_INVALID)
+				if (snap_percent == DM_PERCENT_INVALID)
 					snap_active = 0;
 			if (lvm1compat)
 				log_print("                       %s%s/%s [%s]",
@@ -494,7 +494,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 		if (inkernel &&
 		    (snap_active = lv_snapshot_percent(snap_seg->cow,
 						       &snap_percent)))
-			if (snap_percent == PERCENT_INVALID)
+			if (snap_percent == DM_PERCENT_INVALID)
 				snap_active = 0;
 
 		if (lvm1compat)
@@ -555,15 +555,15 @@ int lvdisplay_full(struct cmd_context *cmd,
 
 	if (thin_data_active)
 		log_print("Allocated pool data    %.2f%%",
-			  percent_to_float(thin_data_percent));
+			  dm_percent_to_float(thin_data_percent));
 
 	if (thin_metadata_active)
 		log_print("Allocated metadata     %.2f%%",
-			  percent_to_float(thin_metadata_percent));
+			  dm_percent_to_float(thin_metadata_percent));
 
 	if (thin_active)
 		log_print("Mapped size            %.2f%%",
-			  percent_to_float(thin_percent));
+			  dm_percent_to_float(thin_percent));
 
 	log_print("Current LE             %u",
 		  snap_seg ? snap_seg->origin->le_count : lv->le_count);
@@ -575,7 +575,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 
 		if (snap_active)
 			log_print("Allocated to snapshot  %.2f%%",
-				  percent_to_float(snap_percent));
+				  dm_percent_to_float(snap_percent));
 
 		log_print("Snapshot chunk size    %s",
 			  display_size(cmd, (uint64_t) snap_seg->chunk_size));
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 5414d94..733e9f6 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -392,7 +392,7 @@ uint64_t lv_size(const struct logical_volume *lv)
 
 static int _lv_mimage_in_sync(const struct logical_volume *lv)
 {
-	percent_t percent;
+	dm_percent_t percent;
 	struct lv_segment *seg = first_seg(lv);
 	struct lv_segment *mirror_seg;
 
@@ -406,13 +406,13 @@ static int _lv_mimage_in_sync(const struct logical_volume *lv)
 			       NULL))
 		return_0;
 
-	return (percent == PERCENT_100) ? 1 : 0;
+	return (percent == DM_PERCENT_100) ? 1 : 0;
 }
 
 static int _lv_raid_image_in_sync(const struct logical_volume *lv)
 {
 	unsigned s;
-	percent_t percent;
+	dm_percent_t percent;
 	char *raid_health;
 	struct lv_segment *seg, *raid_seg = NULL;
 
@@ -444,7 +444,7 @@ static int _lv_raid_image_in_sync(const struct logical_volume *lv)
 	if (!lv_raid_percent(raid_seg->lv, &percent))
 		return_0;
 
-	if (percent == PERCENT_100)
+	if (percent == DM_PERCENT_100)
 		return 1;
 
 	/* Find out which sub-LV this is. */
@@ -537,7 +537,7 @@ static int _lv_raid_healthy(const struct logical_volume *lv)
 
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
-	percent_t snap_percent;
+	dm_percent_t snap_percent;
 	struct lvinfo info;
 	struct lv_segment *seg;
 	char *repstr;
@@ -628,13 +628,13 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		/* Snapshot dropped? */
 		if (info.live_table && lv_is_cow(lv)) {
 			if (!lv_snapshot_percent(lv, &snap_percent) ||
-			    snap_percent == PERCENT_INVALID) {
+			    snap_percent == DM_PERCENT_INVALID) {
 				if (info.suspended)
 					repstr[4] = 'S'; /* Susp Inv snapshot */
 				else
 					repstr[4] = 'I'; /* Invalid snapshot */
 			}
-			else if (snap_percent == PERCENT_MERGE_FAILED) {
+			else if (snap_percent == LVM_PERCENT_MERGE_FAILED) {
 				if (info.suspended)
 					repstr[4] = 'M'; /* Susp snapshot merge failed */
 				else
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9fe441d..0aac385 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -418,7 +418,7 @@ uint32_t find_free_lvnum(struct logical_volume *lv)
 	return i;
 }
 
-percent_t copy_percent(const struct logical_volume *lv)
+dm_percent_t copy_percent(const struct logical_volume *lv)
 {
 	uint32_t numerator = 0u, denominator = 0u;
 	struct lv_segment *seg;
@@ -434,7 +434,7 @@ percent_t copy_percent(const struct logical_volume *lv)
 			numerator += seg->area_len;
 	}
 
-	return denominator ? make_percent( numerator, denominator ) : 100.0;
+	return denominator ? dm_make_percent( numerator, denominator ) : 100.0;
 }
 
 /*
@@ -3157,7 +3157,7 @@ int lv_extend(struct logical_volume *lv,
 		if ((lv->le_count != extents) &&
 		    segtype_is_mirrored(segtype) &&
 		    (lv->status & LV_NOTSYNCED)) {
-			percent_t sync_percent = PERCENT_INVALID;
+			dm_percent_t sync_percent = DM_PERCENT_INVALID;
 
 			if (!lv_is_active_locally(lv)) {
 				log_error("%s/%s is not active locally."
@@ -3178,7 +3178,7 @@ int lv_extend(struct logical_volume *lv,
 				log_error("Failed to get sync percent for %s/%s",
 					  lv->vg->name, lv->name);
 				goto out;
-			} else if (sync_percent == PERCENT_100) {
+			} else if (sync_percent == DM_PERCENT_100) {
 				log_verbose("Skipping initial resync for "
 					    "extended portion of %s/%s",
 					    lv->vg->name, lv->name);
@@ -3576,32 +3576,32 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 static int _adjust_policy_params(struct cmd_context *cmd,
 				 struct logical_volume *lv, struct lvresize_params *lp)
 {
-	percent_t percent;
+	dm_percent_t percent;
 	int policy_threshold, policy_amount;
 
 	if (lv_is_thin_pool(lv)) {
 		policy_threshold =
 			find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG,
-					     lv_config_profile(lv)) * PERCENT_1;
+					     lv_config_profile(lv)) * DM_PERCENT_1;
 		policy_amount =
 			find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG,
 					     lv_config_profile(lv));
-		if (!policy_amount && policy_threshold < PERCENT_100)
+		if (!policy_amount && policy_threshold < DM_PERCENT_100)
                         return 0;
 	} else {
 		policy_threshold =
-			find_config_tree_int(cmd, activation_snapshot_autoextend_threshold_CFG, NULL) * PERCENT_1;
+			find_config_tree_int(cmd, activation_snapshot_autoextend_threshold_CFG, NULL) * DM_PERCENT_1;
 		policy_amount =
 			find_config_tree_int(cmd, activation_snapshot_autoextend_percent_CFG, NULL);
 	}
 
-	if (policy_threshold >= PERCENT_100)
+	if (policy_threshold >= DM_PERCENT_100)
 		return 1; /* nothing to do */
 
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, 1, &percent))
 			return_0;
-		if ((PERCENT_0 < percent && percent <= PERCENT_100) &&
+		if ((DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) &&
 		    (percent > policy_threshold)) {
 			if (!thin_pool_feature_supported(lv, THIN_FEATURE_METADATA_RESIZE)) {
 				log_error_once("Online metadata resize for %s/%s is not supported.",
@@ -3615,14 +3615,14 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 
 		if (!lv_thin_pool_percent(lv, 0, &percent))
 			return_0;
-		if (!(PERCENT_0 < percent && percent <= PERCENT_100) ||
+		if (!(DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) ||
 		    percent <= policy_threshold)
 			return 1;
 	} else {
 		if (!lv_snapshot_percent(lv, &percent))
 			return_0;
-		if (!(PERCENT_0 < percent && percent <= PERCENT_100) || percent <= policy_threshold)
-			return 1; /* nothing to do */
+		if (!(DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) || percent <= policy_threshold)
+		return 1; /* nothing to do */
 	}
 
 	lp->extents = policy_amount;
@@ -4876,7 +4876,7 @@ static int _lv_remove_segs_using_this_lv(struct cmd_context *cmd, struct logical
 int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
 				const force_t force, unsigned level)
 {
-	percent_t snap_percent;
+	dm_percent_t snap_percent;
 	struct dm_list *snh, *snht;
 	struct lv_list *lvl;
 	struct lvinfo info;
@@ -4896,12 +4896,12 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 						  lv->name);
 					return 0;
 				}
-				if ((snap_percent != PERCENT_INVALID) &&
-				     (snap_percent != PERCENT_MERGE_FAILED)) {
+				if ((snap_percent != DM_PERCENT_INVALID) &&
+				     (snap_percent != LVM_PERCENT_MERGE_FAILED)) {
 					log_error("Can't remove merging snapshot logical volume \"%s\"",
 						  lv->name);
 					return 0;
-				} else if ((snap_percent == PERCENT_MERGE_FAILED) &&
+				} else if ((snap_percent == LVM_PERCENT_MERGE_FAILED) &&
 					 (force == PROMPT) &&
 					 yes_no_prompt("Removing snapshot \"%s\" that failed to merge may leave origin \"%s\" inconsistent. "
 						       "Proceed? [y/n]: ", lv->name, origin_from_cow(lv)->name) == 'n')
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6f97564..237ed18 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1065,7 +1065,7 @@ struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv);
 
 uint32_t find_free_lvnum(struct logical_volume *lv);
-percent_t copy_percent(const struct logical_volume *lv_mirr);
+dm_percent_t copy_percent(const struct logical_volume *lv_mirr);
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len);
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index b03cdbe..81a5f19 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -575,7 +575,7 @@ static int _move_removable_mimages_to_end(struct logical_volume *lv,
 
 static int _mirrored_lv_in_sync(struct logical_volume *lv)
 {
-	percent_t sync_percent;
+	dm_percent_t sync_percent;
 
 	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
 			       NULL)) {
@@ -590,7 +590,7 @@ static int _mirrored_lv_in_sync(struct logical_volume *lv)
 		return 0;
 	}
 
-	return (sync_percent == PERCENT_100) ? 1 : 0;
+	return (sync_percent == DM_PERCENT_100) ? 1 : 0;
 }
 
 /*
@@ -1701,7 +1701,7 @@ int remove_mirror_log(struct cmd_context *cmd,
 		      struct dm_list *removable_pvs,
 		      int force)
 {
-	percent_t sync_percent;
+	dm_percent_t sync_percent;
 	struct volume_group *vg = lv->vg;
 
 	/* Unimplemented features */
@@ -1734,7 +1734,7 @@ int remove_mirror_log(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (sync_percent == PERCENT_100)
+	if (sync_percent == DM_PERCENT_100)
 		init_mirror_in_sync(1);
 	else {
 		/* A full resync will take place */
@@ -1896,7 +1896,7 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
 	struct dm_list *parallel_areas;
-	percent_t sync_percent;
+	dm_percent_t sync_percent;
 	int in_sync;
 	struct logical_volume *log_lv;
 	unsigned old_log_count;
@@ -1964,7 +1964,7 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	/* check sync status */
 	if (mirror_in_sync() ||
 	    (lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL) &&
-	     (sync_percent == PERCENT_100)))
+	     (sync_percent == DM_PERCENT_100)))
 		in_sync = 1;
 	else
 		in_sync = 0;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ac0f948..4c13b66 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -87,7 +87,7 @@ static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
  */
 static int _raid_in_sync(struct logical_volume *lv)
 {
-	percent_t sync_percent;
+	dm_percent_t sync_percent;
 
 	if (!lv_raid_percent(lv, &sync_percent)) {
 		log_error("Unable to determine sync status of %s/%s.",
@@ -95,7 +95,7 @@ static int _raid_in_sync(struct logical_volume *lv)
 		return 0;
 	}
 
-	return (sync_percent == PERCENT_100) ? 1 : 0;
+	return (sync_percent == DM_PERCENT_100) ? 1 : 0;
 }
 
 /*
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 1a4a92f..891c378 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -112,7 +112,7 @@ struct segtype_handler {
 	int (*target_status_compatible) (const char *type);
 	int (*check_transient_status) (struct lv_segment *seg, char *params);
 	int (*target_percent) (void **target_state,
-			       percent_t *percent,
+			       dm_percent_t *percent,
 			       struct dm_pool * mem,
 			       struct cmd_context *cmd,
 			       struct lv_segment *seg, char *params,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index cccd244..8520440 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -231,8 +231,8 @@ int thin_pool_feature_supported(const struct logical_volume *lv, int feature)
 
 int pool_below_threshold(const struct lv_segment *pool_seg)
 {
-	percent_t percent;
-	int threshold = PERCENT_1 *
+	dm_percent_t percent;
+	int threshold = DM_PERCENT_1 *
 		find_config_tree_int(pool_seg->lv->vg->cmd, activation_thin_pool_autoextend_threshold_CFG,
 				     lv_config_profile(pool_seg->lv));
 
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 5040011..1ab06ce 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -166,7 +166,7 @@ static struct mirror_state *_mirrored_init_target(struct dm_pool *mem,
 }
 
 static int _mirrored_target_percent(void **target_state,
-				    percent_t *percent,
+				    dm_percent_t *percent,
 				    struct dm_pool *mem,
 				    struct cmd_context *cmd,
 				    struct lv_segment *seg, char *params,
@@ -213,7 +213,7 @@ static int _mirrored_target_percent(void **target_state,
 	if (seg)
 		seg->extents_copied = seg->area_len * numerator / denominator;
 
-        *percent = make_percent(numerator, denominator);
+        *percent = dm_make_percent(numerator, denominator);
 
 	return 1;
 }
diff --git a/lib/misc/lvm-percent.c b/lib/misc/lvm-percent.c
index 013544f..95c41d6 100644
--- a/lib/misc/lvm-percent.c
+++ b/lib/misc/lvm-percent.c
@@ -15,30 +15,6 @@
 #include "lib.h"
 #include "lvm-percent.h"
 
-float percent_to_float(percent_t v)
-{
-    return (float)v / PERCENT_1;
-}
-
-percent_t make_percent(uint64_t numerator, uint64_t denominator)
-{
-    percent_t percent;
-    if (!denominator)
-        return PERCENT_100; /* FIXME? */
-    if (!numerator)
-        return PERCENT_0;
-    if (numerator == denominator)
-        return PERCENT_100;
-    switch (percent = PERCENT_100 * ((double) numerator / (double) denominator)) {
-    case PERCENT_100:
-        return PERCENT_100 - 1;
-    case PERCENT_0:
-        return PERCENT_0 + 1;
-    default:
-        return percent;
-    }
-}
-
 uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup)
 {
 	return (uint32_t)(((uint64_t)percents * (uint64_t)count +
diff --git a/lib/misc/lvm-percent.h b/lib/misc/lvm-percent.h
index ff3de42..481c947 100644
--- a/lib/misc/lvm-percent.h
+++ b/lib/misc/lvm-percent.h
@@ -16,20 +16,6 @@
 #define _LVM_PERCENT_H
 #include <stdint.h>
 
-/*
- * A fixed-point representation of percent values. One percent equals to
- * PERCENT_1 as defined below. Values that are not multiples of PERCENT_1
- * represent fractions, with precision of 1/1000000 of a percent. See
- * percent_to_float for a conversion to a floating-point representation.
- *
- * You should always use make_percent when building percent_t values. The
- * implementation of make_percent is biased towards the middle: it ensures that
- * the result is PERCENT_0 or PERCENT_100 if and only if this is the actual
- * value -- it never rounds any intermediate value (> 0 or < 100) to either 0
- * or 100.
- */
-typedef int32_t percent_t;
-
 typedef enum {
 	SIGN_NONE = 0,
 	SIGN_PLUS = 1,
@@ -45,16 +31,7 @@ typedef enum {
 	PERCENT_ORIGIN
 } percent_type_t;
 
-typedef enum {
-	PERCENT_0 = 0,
-	PERCENT_1 = 1000000,
-	PERCENT_100 = 100 * PERCENT_1,
-	PERCENT_INVALID = -1,
-	PERCENT_MERGE_FAILED = -2
-} percent_range_t;
-
-float percent_to_float(percent_t v);
-percent_t make_percent(uint64_t numerator, uint64_t denominator);
+#define LVM_PERCENT_MERGE_FAILED DM_PERCENT_FAILED
 
 uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup);
 
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index b77c315..33ba5b7 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -269,7 +269,7 @@ static void _raid_destroy(struct segment_type *segtype)
 
 #ifdef DEVMAPPER_SUPPORT
 static int _raid_target_percent(void **target_state,
-				percent_t *percent,
+				dm_percent_t *percent,
 				struct dm_pool *mem,
 				struct cmd_context *cmd,
 				struct lv_segment *seg, char *params,
@@ -305,7 +305,7 @@ static int _raid_target_percent(void **target_state,
 	if (seg)
 		seg->extents_copied = seg->area_len * numerator / denominator;
 
-	*percent = make_percent(numerator, denominator);
+	*percent = dm_make_percent(numerator, denominator);
 
 	return 1;
 }
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 76bdbca..6a116d2 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -363,7 +363,7 @@ static int _replicator_add_target_line(struct dev_manager *dm,
 
 /* FIXME: write something useful for replicator here */
 static int _replicator_target_percent(void **target_state,
-				      percent_t *percent,
+				      dm_percent_t *percent,
 				      struct dm_pool *mem,
 				      struct cmd_context *cmd,
 				      struct lv_segment *seg,
@@ -709,7 +709,7 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 
 /* FIXME: write something useful for replicator-dev here */
 static int _replicator_dev_target_percent(void **target_state,
-					  percent_t *percent,
+					  dm_percent_t *percent,
 					  struct dm_pool *mem,
 					  struct cmd_context *cmd,
 					  struct lv_segment *seg,
diff --git a/lib/report/properties.c b/lib/report/properties.c
index ec7bc4d..0c49b0f 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -47,12 +47,12 @@
 #define GET_PVSEG_STR_PROPERTY_FN(NAME, VALUE) \
 	GET_STR_PROPERTY_FN(NAME, VALUE, pv_segment, pvseg)
 
-static percent_t _copy_percent(const struct logical_volume *lv)
+static dm_percent_t _copy_percent(const struct logical_volume *lv)
 {
-	percent_t percent;
+	dm_percent_t percent;
 
 	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))
-		percent = PERCENT_INVALID;
+		percent = DM_PERCENT_INVALID;
 
 	return percent;
 }
@@ -91,34 +91,34 @@ static uint32_t _raidmaxrecoveryrate(const struct logical_volume *lv)
 	return first_seg(lv)->max_recovery_rate;
 }
 
-static percent_t _snap_percent(const struct logical_volume *lv)
+static dm_percent_t _snap_percent(const struct logical_volume *lv)
 {
-	percent_t percent;
+	dm_percent_t percent;
 
 	if (!lv_is_cow(lv) || !lv_snapshot_percent(lv, &percent))
-		percent = PERCENT_INVALID;
+		percent = DM_PERCENT_INVALID;
 
 	return percent;
 }
 
-static percent_t _data_percent(const struct logical_volume *lv)
+static dm_percent_t _data_percent(const struct logical_volume *lv)
 {
-	percent_t percent;
+	dm_percent_t percent;
 
 	if (lv_is_cow(lv))
 		return _snap_percent(lv);
 
 	if (lv_is_thin_volume(lv))
-		return lv_thin_percent(lv, 0, &percent) ? percent : PERCENT_INVALID;
+		return lv_thin_percent(lv, 0, &percent) ? percent : DM_PERCENT_INVALID;
 
-	return lv_thin_pool_percent(lv, 0, &percent) ? percent : PERCENT_INVALID;
+	return lv_thin_pool_percent(lv, 0, &percent) ? percent : DM_PERCENT_INVALID;
 }
 
-static percent_t _metadata_percent(const struct logical_volume *lv)
+static dm_percent_t _metadata_percent(const struct logical_volume *lv)
 {
-	percent_t percent;
+	dm_percent_t percent;
 
-	return lv_thin_pool_percent(lv, 1, &percent) ? percent : PERCENT_INVALID;
+	return lv_thin_pool_percent(lv, 1, &percent) ? percent : DM_PERCENT_INVALID;
 }
 
 /* PV */
diff --git a/lib/report/report.c b/lib/report/report.c
index 7f509e1..6f507b6 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -36,7 +36,6 @@ struct lvm_report_object {
 	struct label *label;
 };
 
-static const uint64_t _hundred64 = UINT64_C(100);
 static const uint64_t _zero64 = UINT64_C(0);
 
 static const uint64_t _reserved_number_undef_64 = UINT64_C(-1);
@@ -71,35 +70,6 @@ static int _field_set_value(struct dm_report_field *field, const void *data, con
 	return 1;
 }
 
-static int _field_set_percent(struct dm_report_field *field,
-			      struct dm_pool *mem,
-			      percent_t percent)
-{
-	char *repstr;
-	uint64_t *sortval;
-
-	if (percent == PERCENT_INVALID)
-		return _field_set_value(field, "", &_reserved_number_undef_64);
-
-	if (!(repstr = dm_pool_alloc(mem, 8)) ||
-	    !(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
-		if (repstr)
-			dm_pool_free(mem, repstr);
-		log_error("dm_pool_alloc failed.");
-		return 0;
-	}
-
-	if (dm_snprintf(repstr, 7, "%.2f", percent_to_float(percent)) < 0) {
-		dm_pool_free(mem, repstr);
-		log_error("Percentage too large.");
-		return 0;
-	}
-
-	*sortval = (uint64_t)(percent * 1000.f);
-
-	return _field_set_value(field, repstr, sortval);
-}
-
 /*
  * Data-munging functions to prepare each data type for display and sorting
  */
@@ -904,21 +874,23 @@ static int _snapcount_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
-static int _snpercent_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+static int _snpercent_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			   struct dm_report_field *field,
 			   const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	percent_t snap_percent;
+	dm_percent_t snap_percent;
 
 	if ((lv_is_cow(lv) || lv_is_merging_origin(lv)) &&
 	    lv_snapshot_percent(lv, &snap_percent)) {
-		if ((snap_percent != PERCENT_INVALID) &&
-		    (snap_percent != PERCENT_MERGE_FAILED))
-			return _field_set_percent(field, mem, snap_percent);
+		if ((snap_percent != DM_PERCENT_INVALID) &&
+		    (snap_percent != LVM_PERCENT_MERGE_FAILED))
+			return dm_report_field_percent(rh, field, &snap_percent);
 
-		if (!lv_is_merging_origin(lv))
-			return _field_set_value(field, "100.00", &_hundred64);
+		if (!lv_is_merging_origin(lv)) {
+			snap_percent = DM_PERCENT_100;
+			return dm_report_field_percent(rh, field, &snap_percent);
+		}
 
 		/*
 		 * on activate merge that hasn't started yet would
@@ -926,27 +898,28 @@ static int _snpercent_disp(struct dm_report *rh __attribute__((unused)), struct
 		 */
 	}
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	snap_percent = DM_PERCENT_INVALID;
+	return dm_report_field_percent(rh, field, &snap_percent);
 }
 
-static int _copypercent_disp(struct dm_report *rh __attribute__((unused)),
-			     struct dm_pool *mem,
+static int _copypercent_disp(struct dm_report *rh,
+			     struct dm_pool *mem __attribute__((unused)),
 			     struct dm_report_field *field,
 			     const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	percent_t percent;
+	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	if (((lv_is_raid(lv) && lv_raid_percent(lv, &percent)) ||
 
 	    ((lv->status & (PVMOVE | MIRRORED)) &&
 	     lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
-	    (percent != PERCENT_INVALID)) {
+	    (percent != DM_PERCENT_INVALID)) {
 		percent = copy_percent(lv);
-		return _field_set_percent(field, mem, percent);
+		return dm_report_field_percent(rh, field, &percent);
 	}
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return dm_report_field_percent(rh, field, &percent);
 }
 
 static int _raidsyncaction_disp(struct dm_report *rh __attribute__((unused)),
@@ -1024,17 +997,17 @@ static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 }
 
 /* Called only with lv_is_thin_pool/volume */
-static int _dtpercent_disp(int metadata, struct dm_pool *mem,
+static int _dtpercent_disp(int metadata, struct dm_report *rh,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	percent_t percent;
+	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	/* Suppress data percent if not using driver */
 	/* cannot use lv_is_active_locally - need to check for layer -tpool */
 	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
-		return _field_set_value(field, "",  &_reserved_number_undef_64);
+		return dm_report_field_percent(rh, field, &percent);
 
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, metadata, &percent))
@@ -1044,7 +1017,7 @@ static int _dtpercent_disp(int metadata, struct dm_pool *mem,
 			return_0;
 	}
 
-	return _field_set_percent(field, mem, percent);
+	return dm_report_field_percent(rh, field, &percent);
 }
 
 static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1052,24 +1025,26 @@ static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 			     const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
+	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	if (lv_is_cow(lv))
 		return _snpercent_disp(rh, mem, field, data, private);
 
 	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
-		return _dtpercent_disp(0, mem, field, data, private);
+		return _dtpercent_disp(0, rh, field, data, private);
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return dm_report_field_percent(rh, field, &percent);
 }
 
-static int _metadatapercent_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _metadatapercent_disp(struct dm_report *rh,
+				 struct dm_pool *mem __attribute__((unused)),
 				 struct dm_report_field *field,
 				 const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv_is_thin_pool(lv))
-		return _dtpercent_disp(1, mem, field, data, private);
+		return _dtpercent_disp(1, rh, field, data, private);
 
 	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index a4ee2ea..afa1a90 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -107,7 +107,7 @@ static int _snap_target_status_compatible(const char *type)
 }
 
 static int _snap_target_percent(void **target_state __attribute__((unused)),
-				percent_t *percent,
+				dm_percent_t *percent,
 				struct dm_pool *mem __attribute__((unused)),
 				struct cmd_context *cmd __attribute__((unused)),
 				struct lv_segment *seg __attribute__((unused)),
@@ -120,19 +120,19 @@ static int _snap_target_percent(void **target_state __attribute__((unused)),
 		return_0;
 
 	if (s->invalid)
-		*percent = PERCENT_INVALID;
+		*percent = DM_PERCENT_INVALID;
 	else if (s->merge_failed)
-		*percent = PERCENT_MERGE_FAILED;
+		*percent = LVM_PERCENT_MERGE_FAILED;
 	else {
 		*total_numerator += s->used_sectors;
 		*total_denominator += s->total_sectors;
 		if (s->has_metadata_sectors &&
 		    s->used_sectors == s->metadata_sectors)
-			*percent = PERCENT_0;
+			*percent = DM_PERCENT_0;
 		else if (s->used_sectors == s->total_sectors)
-			*percent = PERCENT_100;
+			*percent = DM_PERCENT_100;
 		else
-			*percent = make_percent(*total_numerator, *total_denominator);
+			*percent = dm_make_percent(*total_numerator, *total_denominator);
 	}
 
 	return 1;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 28f3e43..020ccc1 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -382,7 +382,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 }
 
 static int _thin_pool_target_percent(void **target_state __attribute__((unused)),
-				     percent_t *percent,
+				     dm_percent_t *percent,
 				     struct dm_pool *mem,
 				     struct cmd_context *cmd __attribute__((unused)),
 				     struct lv_segment *seg,
@@ -397,13 +397,13 @@ static int _thin_pool_target_percent(void **target_state __attribute__((unused))
 
 	/* With 'seg' report metadata percent, otherwice data percent */
 	if (seg) {
-		*percent = make_percent(s->used_metadata_blocks,
-					s->total_metadata_blocks);
+		*percent = dm_make_percent(s->used_metadata_blocks,
+					   s->total_metadata_blocks);
 		*total_numerator += s->used_metadata_blocks;
 		*total_denominator += s->total_metadata_blocks;
 	} else {
-		*percent = make_percent(s->used_data_blocks,
-					s->total_data_blocks);
+		*percent = dm_make_percent(s->used_data_blocks,
+					   s->total_data_blocks);
 		*total_numerator += s->used_data_blocks;
 		*total_denominator += s->total_data_blocks;
 	}
@@ -603,7 +603,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 }
 
 static int _thin_target_percent(void **target_state __attribute__((unused)),
-				percent_t *percent,
+				dm_percent_t *percent,
 				struct dm_pool *mem,
 				struct cmd_context *cmd __attribute__((unused)),
 				struct lv_segment *seg,
@@ -618,11 +618,11 @@ static int _thin_target_percent(void **target_state __attribute__((unused)),
 		return_0;
 
 	if (seg) {
-		*percent = make_percent(s->mapped_sectors, seg->lv->size);
+		*percent = dm_make_percent(s->mapped_sectors, seg->lv->size);
 		*total_denominator += seg->lv->size;
 	} else {
 		/* No lv_segment info here */
-		*percent = PERCENT_INVALID;
+		*percent = DM_PERCENT_INVALID;
 		/* FIXME: Using denominator to pass the mapped info upward? */
 		*total_denominator += s->highest_mapped_sector;
 	}
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0dae981..ecf5640 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1582,6 +1582,36 @@ int dm_regex_match(struct dm_regex *regex, const char *s);
  */
 uint32_t dm_regex_fingerprint(struct dm_regex *regex);
 
+/******************
+ * percent handling
+ ******************/
+/*
+ * A fixed-point representation of percent values. One percent equals to
+ * DM_PERCENT_1 as defined below. Values that are not multiples of DM_PERCENT_1
+ * represent fractions, with precision of 1/1000000 of a percent. See
+ * dm_percent_to_float for a conversion to a floating-point representation.
+ *
+ * You should always use dm_make_percent when building dm_percent_t values. The
+ * implementation of dm_make_percent is biased towards the middle: it ensures that
+ * the result is DM_PERCENT_0 or DM_PERCENT_100 if and only if this is the actual
+ * value -- it never rounds any intermediate value (> 0 or < 100) to either 0
+ * or 100.
+*/
+#define DM_PERCENT_CHAR '%'
+
+typedef enum {
+	DM_PERCENT_0 = 0,
+	DM_PERCENT_1 = 1000000,
+	DM_PERCENT_100 = 100 * DM_PERCENT_1,
+	DM_PERCENT_INVALID = -1,
+	DM_PERCENT_FAILED = -2
+} dm_percent_range_t;
+
+typedef int32_t dm_percent_t;
+
+float dm_percent_to_float(dm_percent_t percent);
+dm_percent_t dm_make_percent(uint64_t numerator, uint64_t denominator);
+
 /*********************
  * reporting functions
  *********************/
@@ -1698,6 +1728,8 @@ int dm_report_field_int(struct dm_report *rh, struct dm_report_field *field,
 			const int *data);
 int dm_report_field_uint64(struct dm_report *rh, struct dm_report_field *field,
 			   const uint64_t *data);
+int dm_report_field_percent(struct dm_report *rh, struct dm_report_field *field,
+			    const dm_percent_t *data);
 
 /*
  * For custom fields, allocate the data in 'mem' and use
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index aa640de..f053f3d 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -236,6 +236,41 @@ struct str_list_sort_value {
 	struct str_list_sort_value_item *items;
 };
 
+int dm_report_field_percent(struct dm_report *rh,
+			    struct dm_report_field *field,
+			    const dm_percent_t *data)
+{
+	char *repstr;
+	uint64_t *sortval;
+
+	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(uint64_t)))) {
+		log_error("dm_report_field_percent: dm_pool_alloc failed for sort_value.");
+		return 0;
+	}
+
+	*sortval = (uint64_t)(*data);
+
+	if (*data == DM_PERCENT_INVALID) {
+		dm_report_field_set_value(field, "", sortval);
+		return 1;
+	}
+
+	if (!(repstr = dm_pool_alloc(rh->mem, 8))) {
+		dm_pool_free(rh->mem, sortval);
+		log_error("dm_report_field_percent: dm_pool_alloc failed for percent report string.");
+		return 0;
+	}
+
+	if (dm_snprintf(repstr, 7, "%.2f", dm_percent_to_float(*data)) < 0) {
+		dm_pool_free(rh->mem, sortval);
+		log_error("dm_report_field_percent: percentage too large.");
+		return 0;
+	}
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
 int dm_report_field_string_list(struct dm_report *rh,
 				struct dm_report_field *field,
 				const struct dm_list *data,
@@ -1484,6 +1519,31 @@ static int _check_value_is_reserved(struct dm_report *rh, unsigned type, const v
 	return 0;
 }
 
+float dm_percent_to_float(dm_percent_t percent)
+{
+	return (float) percent / DM_PERCENT_1;
+}
+
+dm_percent_t dm_make_percent(uint64_t numerator, uint64_t denominator)
+{
+	dm_percent_t percent;
+
+	if (!denominator)
+		return DM_PERCENT_100; /* FIXME? */
+	if (!numerator)
+		return DM_PERCENT_0;
+	if (numerator == denominator)
+		return DM_PERCENT_100;
+	switch (percent = DM_PERCENT_100 * ((double) numerator / (double) denominator)) {
+		case DM_PERCENT_100:
+			return DM_PERCENT_100 - 1;
+		case DM_PERCENT_0:
+			return DM_PERCENT_0 + 1;
+		default:
+			return percent;
+	}
+}
+
 /*
  * Used to check whether the reserved_values definition passed to
  * dm_report_init_with_selection contains only supported reserved value types.
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index a91640a..3692f9a 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1828,7 +1828,7 @@ uint64_t lvm_pv_get_free(const pv_t pv);
  * The memory allocated for a string property value is tied to the vg_t handle
  * and will be released when lvm_vg_close() is called. For "percent" values
  * (those obtained for copy_percent and snap_percent properties), please see
- * percent_range_t and lvm_percent_to_float().
+ * dm_percent_range_t and lvm_percent_to_float().
  *
  * Example:
  *      lvm_property_value value;
@@ -1957,24 +1957,13 @@ pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid);
  */
 int lvm_pv_resize(const pv_t pv, uint64_t new_size);
 
-#ifndef _LVM_PERCENT_H
+#define PERCENT_0 DM_PERCENT_0
+#define PERCENT_1 DM_PERCENT_1
+#define PERCENT_100 DM_PERCENT_100
+#define PERCENT_INVALID DM_PERCENT_INVALID
+#define PERCENT_MERGE_FAILED DM_PERCENT_FAILED
 
-/**
- * This type defines a couple of special percent values. The PERCENT_0 and
- * PERCENT_100 constants designate *exact* percentages: values are never
- * rounded to either of these two.
- */
-typedef enum {
-	PERCENT_0 = 0,
-	PERCENT_1 = 1000000,
-	PERCENT_100 = 100 * PERCENT_1,
-	PERCENT_INVALID = -1,
-	PERCENT_MERGE_FAILED = -2
-} percent_range_t;
-
-typedef int32_t percent_t;
-
-#endif
+typedef dm_percent_t percent_t;
 
 /**
  * Convert a (fixed-point) value obtained from the percent-denominated
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 47ad241..80d8dbb 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -197,5 +197,5 @@ const char *lvm_vgname_from_device(lvm_t libh, const char *device)
  */
 float lvm_percent_to_float(percent_t v)
 {
-	return percent_to_float(v);
+	return dm_percent_to_float(v);
 }
diff --git a/test/api/thin_percent.c b/test/api/thin_percent.c
index 0df896c..61a928c 100644
--- a/test/api/thin_percent.c
+++ b/test/api/thin_percent.c
@@ -65,7 +65,7 @@ int main(int argc, char *argv[])
 
 	v = lvm_lv_get_property(lv, "snap_percent");
 	assert(v.is_valid);
-	assert(v.value.integer == (uint64_t) PERCENT_INVALID);
+	assert(v.value.integer == (uint64_t) DM_PERCENT_INVALID);
 
 	v = lvm_lv_get_property(lv, "origin");
 	assert(v.is_valid);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 75eb565..e857a70 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -799,28 +799,28 @@ static progress_t _poll_merge_progress(struct cmd_context *cmd,
 				       const char *name __attribute__((unused)),
 				       struct daemon_parms *parms)
 {
-	percent_t percent = PERCENT_0;
+	dm_percent_t percent = DM_PERCENT_0;
 
 	if (!lv_is_merging_origin(lv) ||
 	    !lv_snapshot_percent(lv, &percent)) {
 		log_error("%s: Failed query for merging percentage. Aborting merge.", lv->name);
 		return PROGRESS_CHECK_FAILED;
-	} else if (percent == PERCENT_INVALID) {
+	} else if (percent == DM_PERCENT_INVALID) {
 		log_error("%s: Merging snapshot invalidated. Aborting merge.", lv->name);
 		return PROGRESS_CHECK_FAILED;
-	} else if (percent == PERCENT_MERGE_FAILED) {
+	} else if (percent == LVM_PERCENT_MERGE_FAILED) {
 		log_error("%s: Merge failed. Retry merge or inspect manually.", lv->name);
 		return PROGRESS_CHECK_FAILED;
 	}
 
 	if (parms->progress_display)
 		log_print_unless_silent("%s: %s: %.1f%%", lv->name, parms->progress_title,
-					100.0 - percent_to_float(percent));
+					100.0 - dm_percent_to_float(percent));
 	else
 		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title,
-			    100.0 - percent_to_float(percent));
+			    100.0 - dm_percent_to_float(percent));
 
-	if (percent == PERCENT_0)
+	if (percent == DM_PERCENT_0)
 		return PROGRESS_FINISHED_ALL;
 
 	return PROGRESS_UNFINISHED;
@@ -1836,7 +1836,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	struct dm_list *failed_pvs;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
-	percent_t sync_percent;
+	dm_percent_t sync_percent;
 
 	if (!arg_count(cmd, type_ARG))
 		lp->segtype = seg->segtype;
@@ -1911,7 +1911,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 0;
 		}
 
-		if (sync_percent != PERCENT_100) {
+		if (sync_percent != DM_PERCENT_100) {
 			log_error("WARNING: %s/%s is not in-sync.",
 				  lv->vg->name, lv->name);
 			log_error("WARNING: Portions of the array may"
@@ -2106,7 +2106,7 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	struct logical_volume *origin = origin_from_cow(lv);
 	struct lv_segment *snap_seg = find_snapshot(lv);
 	struct lvinfo info;
-	percent_t snap_percent;
+	dm_percent_t snap_percent;
 
 	/* Check if merge is possible */
 	if (!lv_is_cow(lv)) {
@@ -2141,7 +2141,7 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)
 	    && info.exists && info.live_table &&
 	    (!lv_snapshot_percent(lv, &snap_percent) ||
-	     snap_percent == PERCENT_INVALID)) {
+	     snap_percent == DM_PERCENT_INVALID)) {
 		log_error("Unable to merge invalidated snapshot LV \"%s\".",
 			  lv->name);
 		return 0;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 86264f3..47459ec 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -331,7 +331,7 @@ static int _determine_cache_argument(struct volume_group *vg,
 /*
  * Update extents parameters based on other parameters which affect the size
  * calculation.
- * NOTE: We must do this here because of the percent_t typedef and because we
+ * NOTE: We must do this here because of the dm_percent_t typedef and because we
  * need the vg.
  */
 static int _update_extents_params(struct volume_group *vg,
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 47e79d6..2641054 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -20,7 +20,7 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	struct lvinfo info;
 	int inkernel, snap_active = 1;
-	percent_t snap_percent;     /* fused, fsize; */
+	dm_percent_t snap_percent;     /* fused, fsize; */
 
 	const char *active_str, *snapshot_str;
 
@@ -31,7 +31,7 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lv_is_cow(lv)) {
 		if (inkernel &&
 		    (snap_active = lv_snapshot_percent(lv, &snap_percent)))
-			if (snap_percent == PERCENT_INVALID)
+			if (snap_percent == DM_PERCENT_INVALID)
 				snap_active = 0;
 	}
 
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 0765930..8d5c6ba 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -21,13 +21,13 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 				struct logical_volume *lv, const char *name,
 				struct daemon_parms *parms)
 {
-	percent_t segment_percent = PERCENT_0, overall_percent = PERCENT_0;
+	dm_percent_t segment_percent = DM_PERCENT_0, overall_percent = DM_PERCENT_0;
 	uint32_t event_nr = 0;
 
 	if (!lv_is_mirrored(lv) ||
 	    !lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
 			       &event_nr) ||
-	    (segment_percent == PERCENT_INVALID)) {
+	    (segment_percent == DM_PERCENT_INVALID)) {
 		log_error("ABORTING: Mirror percentage check failed.");
 		return PROGRESS_CHECK_FAILED;
 	}
@@ -35,15 +35,15 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 	overall_percent = copy_percent(lv);
 	if (parms->progress_display)
 		log_print_unless_silent("%s: %s: %.1f%%", name, parms->progress_title,
-					percent_to_float(overall_percent));
+					dm_percent_to_float(overall_percent));
 	else
 		log_verbose("%s: %s: %.1f%%", name, parms->progress_title,
-			    percent_to_float(overall_percent));
+			    dm_percent_to_float(overall_percent));
 
-	if (segment_percent != PERCENT_100)
+	if (segment_percent != DM_PERCENT_100)
 		return PROGRESS_UNFINISHED;
 
-	if (overall_percent == PERCENT_100)
+	if (overall_percent == DM_PERCENT_100)
 		return PROGRESS_FINISHED_ALL;
 
 	return PROGRESS_FINISHED_SEGMENT;



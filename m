From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 30 Sep 2009 19:08:09 -0400
Subject: [PATCH v2 1/2] Avoid depending on comparison of floating-point values.
In-Reply-To: <1254352090-23243-1-git-send-email-snitzer@redhat.com>
References: <1254352090-23243-1-git-send-email-snitzer@redhat.com>
Message-ID: <1254352090-23243-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Avoid depending on comparison of floating-point values. Return 4 values:
TARGET_STATUS_ERROR --- error occured
TARGET_STATUS_INVALIDATED --- the snapshot is invalidated (there may still exist
	100% filled snapshot that is not invalidated)
TARGET_STATUS_PROCESSING --- mirror is resynchronizing, snapshot is neither
	empty nor invalidated.
TARGET_STATUS_FINISHED --- finished. For mirrors, it is returned when the mirror
	resynchronization finished. For snapshots, it is returned when the
	snapshot contains no exceptions (merging finished).

Decisions are made based on these returned values, not on actual floating point
number.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>

---
FIXME: introduce 'target_status_t' enum type instead of using #define values;
       not the most straight-forward as there isn't a common header for the enum.
       -- e.g. dev_manager.h has a bunch of forward declarations; can't get away
       	  with the same for an enum type
---
 lib/activate/activate.c    |    3 +-
 lib/activate/dev_manager.c |   56 +++++++++++++++++++++++++--------------------
 lib/display/display.c      |   16 ++++--------
 lib/metadata/mirror.c      |   20 ++++++++--------
 lib/metadata/segtype.h     |    6 ++++
 lib/mirror/mirrored.c      |    8 +++---
 lib/report/report.c        |   15 +++++-------
 lib/snapshot/snapshot.c    |   11 +++++++-
 tools/lvscan.c             |   15 ++++--------
 tools/polldaemon.c         |    7 +++--
 10 files changed, 86 insertions(+), 71 deletions(-)

Index: lvm2/lib/metadata/segtype.h
===================================================================
--- lvm2.orig/lib/metadata/segtype.h
+++ lvm2/lib/metadata/segtype.h
@@ -73,6 +73,12 @@ struct segtype_handler {
                                 struct lv_segment *seg,
                                 struct dm_tree_node *node, uint64_t len,
                                 uint32_t *pvmove_mirror_count);
+/* return value of target_percent. The order is important, if multiple targets
+   return different values, the lowest value wins */
+#define TARGET_STATUS_ERROR		0
+#define TARGET_STATUS_INVALIDATED	1
+#define TARGET_STATUS_PROCESSING	2
+#define TARGET_STATUS_FINISHED		3
 	int (*target_percent) (void **target_state, struct dm_pool * mem,
 			       struct cmd_context *cmd,
 			       struct lv_segment *seg, char *params,
Index: lvm2/lib/mirror/mirrored.c
===================================================================
--- lvm2.orig/lib/mirror/mirrored.c
+++ lvm2/lib/mirror/mirrored.c
@@ -200,7 +200,7 @@ static int _mirrored_target_percent(void
 	if (sscanf(pos, "%u %n", &mirror_count, &used) != 1) {
 		log_error("Failure parsing mirror status mirror count: %s",
 			  params);
-		return 0;
+		return TARGET_STATUS_ERROR;
 	}
 	pos += used;
 
@@ -208,7 +208,7 @@ static int _mirrored_target_percent(void
 		if (sscanf(pos, "%*x:%*x %n", &used) != 0) {
 			log_error("Failure parsing mirror status devices: %s",
 				  params);
-			return 0;
+			return TARGET_STATUS_ERROR;
 		}
 		pos += used;
 	}
@@ -216,7 +216,7 @@ static int _mirrored_target_percent(void
 	if (sscanf(pos, "%" PRIu64 "/%" PRIu64 "%n", &numerator, &denominator,
 		   &used) != 2) {
 		log_error("Failure parsing mirror status fraction: %s", params);
-		return 0;
+		return TARGET_STATUS_ERROR;
 	}
 	pos += used;
 
@@ -226,7 +226,7 @@ static int _mirrored_target_percent(void
 	if (seg)
 		seg->extents_copied = seg->area_len * numerator / denominator;
 
-	return 1;
+	return numerator != denominator ? TARGET_STATUS_PROCESSING : TARGET_STATUS_FINISHED;
 }
 
 static int _add_log(struct dev_manager *dm, struct lv_segment *seg,
Index: lvm2/lib/snapshot/snapshot.c
===================================================================
--- lvm2.orig/lib/snapshot/snapshot.c
+++ lvm2/lib/snapshot/snapshot.c
@@ -100,9 +100,16 @@ static int _snap_target_percent(void **t
 		   &numerator, &denominator) == 2) {
 		*total_numerator += numerator;
 		*total_denominator += denominator;
+		if (!numerator) {
+			return TARGET_STATUS_FINISHED;
+		} else {
+			return TARGET_STATUS_PROCESSING;
+		}
+	} else if (!strcmp(params, "Invalid")) {
+		return TARGET_STATUS_INVALIDATED;
+	} else {
+		return TARGET_STATUS_ERROR;
 	}
-
-	return 1;
 }
 
 static int _snap_target_present(struct cmd_context *cmd,
Index: lvm2/lib/activate/dev_manager.c
===================================================================
--- lvm2.orig/lib/activate/dev_manager.c
+++ lvm2/lib/activate/dev_manager.c
@@ -333,7 +333,7 @@ static int _percent_run(struct dev_manag
 			struct logical_volume *lv, float *percent,
 			uint32_t *event_nr)
 {
-	int r = 0;
+	int r = TARGET_STATUS_ERROR;
 	struct dm_task *dmt;
 	struct dm_info info;
 	void *next = NULL;
@@ -364,6 +364,7 @@ static int _percent_run(struct dev_manag
 	if (event_nr)
 		*event_nr = info.event_nr;
 
+	r = TARGET_STATUS_FINISHED;
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length, &type,
 					  &params);
@@ -382,16 +383,21 @@ static int _percent_run(struct dev_manag
 		if (!(segtype = get_segtype_from_string(dm->cmd, type)))
 			continue;
 
-		if (segtype->ops->target_percent &&
-		    !segtype->ops->target_percent(&dm->target_state, dm->mem,
-						  dm->cmd, seg, params,
-						  &total_numerator,
-						  &total_denominator))
-			goto_out;
+		if (segtype->ops->target_percent) {
+			int target_status =
+			    segtype->ops->target_percent(&dm->target_state,
+							 dm->mem, dm->cmd, seg,
+							 params,
+							 &total_numerator,
+							 &total_denominator);
+			if (target_status < r)
+				r = target_status;
+		}
 
 	} while (next);
 
 	if (lv && (segh = dm_list_next(&lv->segments, segh))) {
+		r = TARGET_STATUS_ERROR;
 		log_error("Number of segments in active LV %s does not "
 			  "match metadata", lv->name);
 		goto out;
@@ -403,7 +409,6 @@ static int _percent_run(struct dev_manag
 		*percent = 100;
 
 	log_debug("LV percent: %f", *percent);
-	r = 1;
 
       out:
 	dm_task_destroy(dmt);
@@ -415,19 +420,21 @@ static int _percent(struct dev_manager *
 		    struct logical_volume *lv, float *percent,
 		    uint32_t *event_nr)
 {
+	int r;
 	if (dlid && *dlid) {
-		if (_percent_run(dm, NULL, dlid, target_type, wait, lv, percent,
-				 event_nr))
-			return 1;
-		else if (_percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
-				      target_type, wait, lv, percent,
-				      event_nr))
-			return 1;
+		if ((r = _percent_run(dm, NULL, dlid, target_type, wait, lv,
+				      percent, event_nr)))
+			return r;
+		else if ((r = _percent_run(dm, NULL,
+					   dlid + sizeof(UUID_PREFIX) - 1,
+					   target_type, wait, lv, percent,
+					   event_nr)))
+			return r;
 	}
 
-	if (name && _percent_run(dm, name, NULL, target_type, wait, lv, percent,
-				 event_nr))
-		return 1;
+	if (name && ((r = _percent_run(dm, name, NULL, target_type, wait, lv,
+				       percent, event_nr))))
+		return r;
 
 	return 0;
 }
@@ -483,6 +490,7 @@ int dev_manager_snapshot_percent(struct 
 				 const struct logical_volume *lv,
 				 float *percent)
 {
+	int r;
 	char *name;
 	const char *dlid;
 
@@ -499,14 +507,13 @@ int dev_manager_snapshot_percent(struct 
 	 * Try and get some info on this device.
 	 */
 	log_debug("Getting device status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
-		       NULL)))
+	if (!(r = _percent(dm, name, dlid, "snapshot", 0, NULL, percent, NULL)))
 		return_0;
 
 	/* FIXME dm_pool_free ? */
 
 	/* If the snapshot isn't available, percent will be -1 */
-	return 1;
+	return r;
 }
 
 /* FIXME Merge with snapshot_percent, auto-detecting target type */
@@ -515,6 +522,7 @@ int dev_manager_mirror_percent(struct de
 			       struct logical_volume *lv, int wait,
 			       float *percent, uint32_t *event_nr)
 {
+	int r;
 	char *name;
 	const char *dlid;
 
@@ -532,11 +540,11 @@ int dev_manager_mirror_percent(struct de
 	}
 
 	log_debug("Getting device mirror status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "mirror", wait, lv, percent,
-		       event_nr)))
+	if (!(r = _percent(dm, name, dlid, "mirror", wait, lv, percent,
+			   event_nr)))
 		return_0;
 
-	return 1;
+	return r;
 }
 
 #if 0
Index: lvm2/lib/display/display.c
===================================================================
--- lvm2.orig/lib/display/display.c
+++ lvm2/lib/display/display.c
@@ -504,11 +504,9 @@ int lvdisplay_full(struct cmd_context *c
 
 		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
 				       origin_list) {
-			if (inkernel &&
-			    (snap_active = lv_snapshot_percent(snap_seg->cow,
-							       &snap_percent)))
-				if (snap_percent < 0 || snap_percent >= 100)
-					snap_active = 0;
+			if (inkernel)
+				snap_active = lv_snapshot_percent(snap_seg->cow,
+				     &snap_percent) >= TARGET_STATUS_PROCESSING;
 			log_print("                       %s%s/%s [%s]",
 				  lv->vg->cmd->dev_dir, lv->vg->name,
 				  snap_seg->cow->name,
@@ -516,11 +514,9 @@ int lvdisplay_full(struct cmd_context *c
 		}
 		snap_seg = NULL;
 	} else if ((snap_seg = find_cow(lv))) {
-		if (inkernel &&
-		    (snap_active = lv_snapshot_percent(snap_seg->cow,
-						       &snap_percent)))
-			if (snap_percent < 0 || snap_percent >= 100)
-				snap_active = 0;
+		if (inkernel)
+			snap_active = lv_snapshot_percent(snap_seg->cow,
+				&snap_percent) >= TARGET_STATUS_PROCESSING;
 
 		log_print("LV snapshot status     %s destination for %s%s/%s",
 			  (snap_active > 0) ? "active" : "INACTIVE",
Index: lvm2/lib/metadata/mirror.c
===================================================================
--- lvm2.orig/lib/metadata/mirror.c
+++ lvm2/lib/metadata/mirror.c
@@ -700,18 +700,16 @@ int remove_mirror_images(struct logical_
 
 static int _mirrored_lv_in_sync(struct logical_volume *lv)
 {
+	int r;
 	float sync_percent;
 
-	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent, NULL)) {
+	if (!(r = lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent, NULL))) {
 		log_error("Unable to determine mirror sync status of %s/%s.",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
 
-	if (sync_percent >= 100.0)
-		return 1;
-
-	return 0;
+	return r == TARGET_STATUS_FINISHED;
 }
 
 /*
@@ -1203,6 +1201,7 @@ int remove_mirror_log(struct cmd_context
 		      struct dm_list *removable_pvs)
 {
 	float sync_percent;
+	int sync_status;
 	struct lvinfo info;
 	struct volume_group *vg = lv->vg;
 
@@ -1214,7 +1213,8 @@ int remove_mirror_log(struct cmd_context
 
 	/* Had disk log, switch to core. */
 	if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
-		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
+		if (!(sync_status = lv_mirror_percent(cmd, lv, 0, &sync_percent,
+						      NULL))) {
 			log_error("Unable to determine mirror sync status.");
 			return 0;
 		}
@@ -1225,11 +1225,11 @@ int remove_mirror_log(struct cmd_context
 	} else if (yes_no_prompt("Full resync required to convert "
 				 "inactive mirror %s to core log. "
 				 "Proceed? [y/n]: ") == 'y')
-		sync_percent = 0;
+		sync_status = TARGET_STATUS_PROCESSING;
 	else
 		return 0;
 
-	if (sync_percent >= 100.0)
+	if (sync_status == TARGET_STATUS_FINISHED)
 		init_mirror_in_sync(1);
 	else {
 		/* A full resync will take place */
@@ -1404,8 +1404,8 @@ int add_mirror_log(struct cmd_context *c
 	}
 
 	/* check sync status */
-	if (lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL) &&
-	    sync_percent >= 100.0)
+	if (lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)
+	    == TARGET_STATUS_FINISHED)
 		in_sync = 1;
 	else
 		in_sync = 0;
Index: lvm2/lib/report/report.c
===================================================================
--- lvm2.orig/lib/report/report.c
+++ lvm2/lib/report/report.c
@@ -274,19 +274,18 @@ static int _lvkmin_disp(struct dm_report
 
 static int _lv_mimage_in_sync(const struct logical_volume *lv)
 {
+	int status;
 	float percent;
 	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
 
 	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
 		return_0;
 
-	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent, NULL))
+	if (!(status = lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0,
+					 &percent, NULL)))
 		return_0;
 
-	if (percent >= 100.0)
-		return 1;
-
-	return 0;
+	return status == TARGET_STATUS_FINISHED;
 }
 
 static int _lvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
@@ -363,8 +362,8 @@ static int _lvstatus_disp(struct dm_repo
 
 		/* Snapshot dropped? */
 		if (info.live_table && lv_is_cow(lv) &&
-		    (!lv_snapshot_percent(lv, &snap_percent) ||
-		     snap_percent < 0 || snap_percent >= 100)) {
+		    (lv_snapshot_percent(lv, &snap_percent)
+		     <= TARGET_STATUS_INVALIDATED)) {
 			repstr[0] = toupper(repstr[0]);
 			if (info.suspended)
 				repstr[4] = 'S'; /* Susp Inv snapshot */
@@ -1030,7 +1029,7 @@ static int _snpercent_disp(struct dm_rep
 		return 1;
 	}
 
-	if (!lv_snapshot_percent(lv, &snap_percent) || snap_percent < 0) {
+	if (lv_snapshot_percent(lv, &snap_percent) == TARGET_STATUS_ERROR) {
 		*sortval = UINT64_C(100);
 		dm_report_field_set_value(field, "100.00", sortval);
 		return 1;
Index: lvm2/tools/lvscan.c
===================================================================
--- lvm2.orig/tools/lvscan.c
+++ lvm2/tools/lvscan.c
@@ -34,18 +34,15 @@ static int lvscan_single(struct cmd_cont
 	if (lv_is_origin(lv)) {
 		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
 				       origin_list) {
-			if (inkernel &&
-			    (snap_active = lv_snapshot_percent(snap_seg->cow,
-							       &snap_percent)))
-				if (snap_percent < 0 || snap_percent >= 100)
-					snap_active = 0;
+			if (inkernel)
+				snap_active = lv_snapshot_percent(snap_seg->cow,
+				     &snap_percent) >= TARGET_STATUS_PROCESSING;
 		}
 		snap_seg = NULL;
 	} else if (lv_is_cow(lv)) {
-		if (inkernel &&
-		    (snap_active = lv_snapshot_percent(lv, &snap_percent)))
-			if (snap_percent < 0 || snap_percent >= 100)
-				snap_active = 0;
+		if (inkernel)
+			snap_active = lv_snapshot_percent(lv, &snap_percent)
+					>= TARGET_STATUS_PROCESSING;
 	}
 
 /* FIXME Add -D arg to skip this! */
Index: lvm2/tools/polldaemon.c
===================================================================
--- lvm2.orig/tools/polldaemon.c
+++ lvm2/tools/polldaemon.c
@@ -68,10 +68,11 @@ progress_t poll_mirror_progress(struct c
 				struct daemon_parms *parms)
 {
 	float segment_percent = 0.0, overall_percent = 0.0;
+	int status;
 	uint32_t event_nr = 0;
 
-	if (!lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
-			       &event_nr)) {
+	if (!(status = lv_mirror_percent(cmd, lv, !parms->interval,
+					 &segment_percent, &event_nr))) {
 		log_error("ABORTING: Mirror percentage check failed.");
 		return PROGRESS_CHECK_FAILED;
 	}
@@ -84,7 +85,7 @@ progress_t poll_mirror_progress(struct c
 		log_verbose("%s: %s: %.1f%%", name, parms->progress_title,
 			    overall_percent);
 
-	if (segment_percent < 100.0)
+	if (status < TARGET_STATUS_FINISHED)
 		return PROGRESS_UNFINISHED;
 
 	if (overall_percent >= 100.0)
Index: lvm2/lib/activate/activate.c
===================================================================
--- lvm2.orig/lib/activate/activate.c
+++ lvm2/lib/activate/activate.c
@@ -493,7 +493,8 @@ int lv_info_by_lvid(struct cmd_context *
 }
 
 /*
- * Returns 1 if percent set, else 0 on failure.
+ * Returns TARGET_STATUS_PROCESSING or TARGET_STATUS_FINISHED if percent set;
+ * else TARGET_STATUS_ERROR or TARGET_STATUS_INVALIDATED on failure.
  */
 int lv_snapshot_percent(const struct logical_volume *lv, float *percent)
 {



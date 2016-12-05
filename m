From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:14 +0000 (UTC)
Subject: master - activation: lv_info_with_seg_status unify status selection
Message-ID: <20161205161514.21A4C60243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed93f0973a307634d1266aeab5c0d2bbceab086e
Commit:        ed93f0973a307634d1266aeab5c0d2bbceab086e
Parent:        0089201588d65bf131d3fadd1cf5be67a562c4b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 5 10:20:42 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:09:13 2016 +0100

activation: lv_info_with_seg_status unify status selection

Start moving selection of status taken for a LV into a single place.
The logic for showing info & status has been spread over multiple
places and were doing too complex decision going agains each other.

Unify selection of status of origin & cow scanned device.

TODO: in future we want to grab status for LV and layered LV and have
both statuses present for display - i.e. when 'old snapshot'
of thinLV is takes and there is ongoing merge - at some moment
we are not capable to show all needed info.
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |   82 ++++++++++++++++++++++++++++++--------------
 lib/activate/dev_manager.c |   56 +++++++++++++++--------------
 tools/reporter.c           |   41 +++-------------------
 4 files changed, 91 insertions(+), 89 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0f5ed02..2b0e822 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Decide which status is needed in one place for lv_info_with_seg_status.
   Fix matching of LV segment when checking for it info status.
   Report log_warn when status cannot be parsed.
   Test segment type before accessing segment members when checking status.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index efb8912..1b1f7e4 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -688,32 +688,6 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 	if (seg_status) {
 		/* TODO: for now it's mess with seg_status */
 		seg_status->seg = seg;
-		if (lv_is_merging_cow(lv)) {
-			if (lv_has_target_type(cmd->mem, origin_from_cow(lv), NULL, TARGET_NAME_SNAPSHOT_MERGE)) {
-				/*
-				 * When the snapshot-merge has not yet started, query COW LVs as is.
-				 * When merge is in progress, query merging origin LV instead.
-				 * COW volume is already mapped as error target in this case.
-				 */
-				lv = origin_from_cow(lv);
-				seg_status->seg = first_seg(lv);
-				log_debug_activation("Snapshot merge is in progress, querying status of %s instead.",
-						     display_lvname(lv));
-			}
-		} else if (!use_layer && lv_is_origin(lv) && !lv_is_external_origin(lv)) {
-			/*
-			 * Query status for 'layered' (-real) device most of the time,
-			 * only when snapshot merge started, query its progress.
-			 * TODO: single LV may need couple status to be exposed at once....
-			 *       but this needs more logical background
-			 */
-			if (!lv_is_merging_origin(lv) ||
-			    !lv_has_target_type(cmd->mem, origin_from_cow(lv), NULL, TARGET_NAME_SNAPSHOT_MERGE))
-				use_layer = 1;
-		} else if (lv_is_cow(lv)) {
-			/* Hadle fictional lvm2 snapshot and query snapshotX volume */
-			seg_status->seg = find_snapshot(lv);
-		}
 	}
 
 	if (!dev_manager_info(cmd, lv,
@@ -783,6 +757,8 @@ int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
  * Returns 1 if lv_with_info_and_seg_status structure populated,
  * else 0 on failure or if device not active locally.
  *
+ * When seg_status parsing had troubles it will set type to SEG_STATUS_UNKNOWN.
+ *
  * This is the same as calling lv_info and lv_status,
  * but* it's done in one go with one ioctl if possible!                                                             ]
  */
@@ -794,6 +770,18 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 	if (!activation())
 		return 0;
 
+	if (lv_is_used_cache_pool(lv)) {
+		/* INFO is not set as cache-pool cannot be active.
+		 * STATUS is collected from cache LV */
+		lv_seg = get_only_segment_using_this_lv(lv);
+		(void) _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, &status->seg_status, 0, 0);
+		return 1;
+	}
+
+	/* By default, take the first LV segment to report status for. */
+	if (!lv_seg)
+		lv_seg = first_seg(lv);
+
 	if (lv != lv_seg->lv)
 		/*
 		 * If the info is requested for an LV and segment
@@ -803,6 +791,48 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 		return _lv_info(cmd, lv, use_layer, &status->info, NULL, NULL, with_open_count, with_read_ahead) &&
 			_lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, &status->seg_status, 0, 0);
 
+	if (lv_is_thin_pool(lv)) {
+		/* Always collect status for '-tpool' */
+		if (_lv_info(cmd, lv, 1, &status->info, lv_seg, &status->seg_status, 0, 0) &&
+		    (status->seg_status.type == SEG_STATUS_THIN_POOL)) {
+			/* There is -tpool device, but query 'active' state of 'fake' thin-pool */
+			if (!_lv_info(cmd, lv, 0, NULL, NULL, NULL, 0, 0) &&
+			    !status->seg_status.thin_pool->needs_check)
+				status->info.exists = 0; /* So pool LV is not active */
+		}
+		return 1;
+	} else if (lv_is_origin(lv) &&
+		   (!lv_is_merging_origin(lv) ||
+		    !lv_has_target_type(cmd->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) {
+		/* Query segment status for 'layered' (-real) device most of the time,
+		 * only for merging snapshot, query its progress.
+		 * TODO: single LV may need couple status to be exposed at once....
+		 *       but this needs more logical background
+		 */
+		/* Show INFO for actual origin */
+		if (!_lv_info(cmd, lv, 0, &status->info, NULL, NULL, with_open_count, with_read_ahead))
+			return_0;
+
+		if (status->info.exists)
+			/* Grab STATUS from layered -real */
+			(void) _lv_info(cmd, lv, 1, NULL, lv_seg, &status->seg_status, 0, 0);
+		return 1;
+	} else if (lv_is_cow(lv)) {
+		if (lv_is_merging_cow(lv) &&
+		    lv_has_target_type(cmd->mem, origin_from_cow(lv), NULL, TARGET_NAME_SNAPSHOT_MERGE)) {
+			/*
+			 * When merge is in progress, query merging origin LV instead.
+			 * COW volume is already mapped as error target in this case.
+			 */
+			lv = origin_from_cow(lv);
+			lv_seg = first_seg(lv);
+			log_debug_activation("Snapshot merge is in progress, querying status of %s instead.",
+					     display_lvname(lv));
+		} else
+			/* Hadle fictional lvm2 snapshot and query snapshotX volume */
+			lv_seg = find_snapshot(lv);
+	}
+
 	return _lv_info(cmd, lv, use_layer, &status->info, lv_seg, &status->seg_status,
 			with_open_count, with_read_ahead);
 }
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 56c6d1d..a72d5a9 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -124,42 +124,41 @@ static int _get_segment_status_from_target_params(const char *target_name,
 						  const char *params,
 						  struct lv_seg_status *seg_status)
 {
-	struct segment_type *segtype;
+	const struct lv_segment *seg = seg_status->seg;
+	const struct segment_type *segtype = seg->segtype;
 
 	seg_status->type = SEG_STATUS_UNKNOWN; /* Parsing failed */
 
+	/* Switch to snapshot segtype status logic for merging origin */
+	/* This is 'dynamic' decision, both states are valid */
+	if (lv_is_merging_origin(seg->lv)) {
+		if (!strcmp(target_name, TARGET_NAME_SNAPSHOT_ORIGIN)) {
+			seg_status->type = SEG_STATUS_NONE;
+			return 1; /* Merge has not yet started */
+		}
+		if (!strcmp(target_name, TARGET_NAME_SNAPSHOT_MERGE) &&
+		    !(segtype = get_segtype_from_string(seg->lv->vg->cmd, TARGET_NAME_SNAPSHOT)))
+			return_0;
+		/* Merging, parse 'snapshot' status of merge progress */
+	}
+
 	if (!params) {
 		log_warn("WARNING: Cannot find matching %s segment for %s.",
-			 seg_status->seg->segtype->name,
-			 display_lvname(seg_status->seg->lv));
+			 segtype->name, display_lvname(seg_status->seg->lv));
 		return 0;
 	}
 
-	/*
-	 * TODO: Add support for other segment types too!
-	 * The segment to report status for must be properly
-	 * selected for all the other types - mainly make sure
-	 * linear/striped, old snapshots and raids have proper
-	 * segment selected for status!
-	 */
-	if (!strcmp(target_name, TARGET_NAME_SNAPSHOT_MERGE) &&
-	    lv_is_merging_origin(seg_status->seg->lv)) {
-		/* Snapshot merge has started, check snapshot status */
-		if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, TARGET_NAME_SNAPSHOT)))
-			return_0;
-	} else {
-		if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name)))
-			return_0;
-
-		/* Validate segtype from DM table and lvm2 metadata */
-		if (segtype != seg_status->seg->segtype) {
-			log_warn("WARNING: segment type %s found does not match "
-				 "expected segment type %s.",
-				 segtype->name, seg_status->seg->segtype->name);
-			return 0;
-		}
+	/* Validate target_name segtype from DM table with lvm2 metadata segtype */
+	if (strcmp(segtype->name, target_name) &&
+	    /* If kernel's type isn't an exact match is it compatible? */
+	    (!segtype->ops->target_status_compatible ||
+	     !segtype->ops->target_status_compatible(target_name))) {
+		log_warn(INTERNAL_ERROR "WARNING: Segment type %s found does not match expected type %s for %s.",
+			 target_name, segtype->name, display_lvname(seg_status->seg->lv));
+		return 0;
 	}
 
+	/* TODO: move into segtype method */
 	if (segtype_is_cache(segtype)) {
 		if (!dm_get_status_cache(seg_status->mem, params, &(seg_status->cache)))
 			return_0;
@@ -181,7 +180,10 @@ static int _get_segment_status_from_target_params(const char *target_name,
 			return_0;
 		seg_status->type = SEG_STATUS_SNAPSHOT;
 	} else
-		/* Status not supported */
+		/*
+		 * TODO: Add support for other segment types too!
+		 * Status not supported
+		 */
 		seg_status->type = SEG_STATUS_NONE;
 
 	return 1;
diff --git a/tools/reporter.c b/tools/reporter.c
index b7a2f39..0a9ca34 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -87,32 +87,12 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 	return ECMD_PROCESSED;
 }
 
-static void _choose_lv_segment_for_status_report(const struct logical_volume *lv, const struct lv_segment **lv_seg)
-{
-	if (lv_is_used_cache_pool(lv)) {
-		/* For a used cache pool, choose cache volume segment */
-		*lv_seg = get_only_segment_using_this_lv(lv);
-		return;
-	}
-
-	/*
-	 * By default, take the first LV segment to report status for.
-	 * If there's any other specific segment that needs to be
-	 * reported instead for the LV, choose it here and assign it
-	 * to lvdm->seg_status->seg. This is the segment whose
-	 * status line will be used for report exactly.
-	 */
-	*lv_seg = first_seg(lv);
-}
-
 static int _do_info_and_status(struct cmd_context *cmd,
 				const struct logical_volume *lv,
 				const struct lv_segment *lv_seg,
 				struct lv_with_info_and_seg_status *status,
 				int do_info, int do_status)
 {
-	unsigned use_layer = lv_is_thin_pool(lv) ? 1 : 0;
-
 	status->lv = lv;
 
 	if (lv_is_historical(lv))
@@ -121,27 +101,16 @@ static int _do_info_and_status(struct cmd_context *cmd,
 	if (do_status) {
 		if (!(status->seg_status.mem = dm_pool_create("reporter_pool", 1024)))
 			return_0;
-		if (!lv_seg || seg_is_used_cache_pool(lv_seg))
-			_choose_lv_segment_for_status_report(lv, &lv_seg);
 
-		if (do_info) {
+		if (do_info)
 			/* both info and status */
-			status->info_ok = lv_info_with_seg_status(cmd, lv, lv_seg, use_layer, status, 1, 1);
-			/* for inactive thin-pools reset lv info struct */
-			if (use_layer && status->info_ok &&
-			    !lv_info(cmd, lv, 0, NULL, 0, 0))
-				memset(&status->info,  0, sizeof(status->info));
-			/* for inactive cache reset lvinfo for its struct for cache-pool */
-			if (lv_is_used_cache_pool(lv) && !status->info_ok) {
-				memset(&status->info,  0, sizeof(status->info));
-				status->info_ok = 1;
-			}
-		} else
+			status->info_ok = lv_info_with_seg_status(cmd, lv, lv_seg, 0, status, 1, 1);
+		else
 			/* status only */
-			status->info_ok = lv_status(cmd, lv_seg, use_layer, &status->seg_status);
+			status->info_ok = lv_info_with_seg_status(cmd, lv, lv_seg, 0, status, 0, 0);
 	} else if (do_info)
 		/* info only */
-		status->info_ok = lv_info(cmd, lv, use_layer, &status->info, 1, 1);
+		status->info_ok = lv_info(cmd, lv, 0, &status->info, 1, 1);
 
 	return 1;
 }



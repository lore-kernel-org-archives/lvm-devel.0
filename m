From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jun 2017 06:19:57 -0400
Subject: master - debug: more display_lvname usage
Message-ID: <201706271019.v5RAJvtg003854@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b939ddf80c7370ae17e26c6d05482be6799245e3
Commit:        b939ddf80c7370ae17e26c6d05482be6799245e3
Parent:        275fc2d45bbef5ffaa43a83c1f9572232fdf2268
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 27 08:28:36 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 08:28:36 2017 +0200

debug: more display_lvname usage

---
 lib/metadata/thin_manip.c |   25 +++++++++++++------------
 tools/lvconvert_poll.c    |   27 ++++++++++++++++-----------
 2 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 559e435..88dc51a 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -29,17 +29,18 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 	struct lv_thin_message *tmsg;
 
 	if (!seg_is_thin_pool(pool_seg)) {
-		log_error(INTERNAL_ERROR "Cannot attach message to non-pool LV %s.", pool_seg->lv->name);
+		log_error(INTERNAL_ERROR "Cannot attach message to non-pool LV %s.",
+			  display_lvname(pool_seg->lv));
 		return 0;
 	}
 
 	if (pool_has_message(pool_seg, lv, delete_id)) {
 		if (lv)
 			log_error("Message referring LV %s already queued in pool %s.",
-				  lv->name, pool_seg->lv->name);
+				  display_lvname(lv), display_lvname(pool_seg->lv));
 		else
 			log_error("Delete for device %u already queued in pool %s.",
-				  delete_id, pool_seg->lv->name);
+				  delete_id, display_lvname(pool_seg->lv));
 		return 0;
 	}
 
@@ -81,8 +82,8 @@ int attach_thin_external_origin(struct lv_segment *seg,
 				struct logical_volume *external_lv)
 {
 	if (seg->external_lv) {
-		log_error(INTERNAL_ERROR "LV \"%s\" already has external origin.",
-			  seg->lv->name);
+		log_error(INTERNAL_ERROR "LV %s already has external origin.",
+			  display_lvname(seg->lv));
 		return 0;
 	}
 
@@ -96,7 +97,7 @@ int attach_thin_external_origin(struct lv_segment *seg,
 
 		if (external_lv->status & LVM_WRITE) {
 			log_verbose("Setting logical volume \"%s\" read-only.",
-				    external_lv->name);
+				    display_lvname(external_lv));
 			external_lv->status &= ~LVM_WRITE;
 		}
 
@@ -144,7 +145,7 @@ int pool_has_message(const struct lv_segment *seg,
 	const struct lv_thin_message *tmsg;
 
 	if (!seg_is_thin_pool(seg)) {
-		log_error(INTERNAL_ERROR "LV %s is not pool.", seg->lv->name);
+		log_error(INTERNAL_ERROR "LV %s is not pool.", display_lvname(seg->lv));
 		return 0;
 	}
 
@@ -204,7 +205,7 @@ int thin_pool_feature_supported(const struct logical_volume *lv, int feature)
 	struct lv_segment *seg;
 
 	if (!lv_is_thin_pool(lv)) {
-		log_error(INTERNAL_ERROR "LV %s is not thin pool.", lv->name);
+		log_error(INTERNAL_ERROR "LV %s is not thin pool.", display_lvname(lv));
 		return 0;
 	}
 
@@ -213,7 +214,7 @@ int thin_pool_feature_supported(const struct logical_volume *lv, int feature)
 	    seg->segtype->ops->target_present &&
 	    !seg->segtype->ops->target_present(lv->vg->cmd, NULL, &attr)) {
 		log_error("%s: Required device-mapper target(s) not "
-			  "detected in your kernel.", seg->segtype->name);
+			  "detected in your kernel.", lvseg_name(seg));
 		return 0;
 	}
 
@@ -404,7 +405,7 @@ struct logical_volume *find_pool_lv(const struct logical_volume *lv)
 	struct lv_segment *seg;
 
 	if (!(seg = first_seg(lv))) {
-		log_error("LV %s has no segment", lv->name);
+		log_error("LV %s has no segment.", display_lvname(lv));
 		return NULL;
 	}
 
@@ -431,7 +432,7 @@ uint32_t get_free_pool_device_id(struct lv_segment *thin_pool_seg)
 	if (!seg_is_thin_pool(thin_pool_seg)) {
 		log_error(INTERNAL_ERROR
 			  "Segment in %s is not a thin pool segment.",
-			  thin_pool_seg->lv->name);
+			  display_lvname(thin_pool_seg->lv));
 		return 0;
 	}
 
@@ -482,7 +483,7 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	int ret = 1;
 
 	if (!lv_is_thin_pool(lv)) {
-		log_error(INTERNAL_ERROR "Updated LV %s is not pool.", lv->name);
+		log_error(INTERNAL_ERROR "Updated LV %s is not pool.", display_lvname(lv));
 		return 0;
 	}
 
diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index 0daa927..b9ec316 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -34,7 +34,7 @@ int lvconvert_mirror_finish(struct cmd_context *cmd,
 	if (!lv_update_and_reload(lv))
 		return_0;
 
-	log_print_unless_silent("Logical volume %s converted.", lv->name);
+	log_print_unless_silent("Logical volume %s converted.", display_lvname(lv));
 
 	return 1;
 }
@@ -89,7 +89,7 @@ int thin_merge_finish(struct cmd_context *cmd,
 {
 	if (!swap_lv_identifiers(cmd, merge_lv, lv)) {
 		log_error("Failed to swap %s with merging %s.",
-			  lv->name, merge_lv->name);
+			  display_lvname(lv), display_lvname(merge_lv));
 		return 0;
 	}
 
@@ -111,11 +111,13 @@ int lvconvert_merge_finish(struct cmd_context *cmd,
 	struct lv_segment *snap_seg = find_snapshot(lv);
 
 	if (!lv_is_merging_origin(lv)) {
-		log_error("Logical volume %s has no merging snapshot.", lv->name);
+		log_error("Logical volume %s has no merging snapshot.",
+			  display_lvname(lv));
 		return 0;
 	}
 
-	log_print_unless_silent("Merge of snapshot into logical volume %s has finished.", lv->name);
+	log_print_unless_silent("Merge of snapshot into logical volume %s has finished.",
+				display_lvname(lv));
 
 	if (seg_is_thin_volume(snap_seg)) {
 		clear_snapshot_merge(lv);
@@ -125,7 +127,7 @@ int lvconvert_merge_finish(struct cmd_context *cmd,
 
 	} else if (!lv_remove_single(cmd, snap_seg->cow, DONT_PROMPT, 0)) {
 		log_error("Could not remove snapshot %s merged into %s.",
-			  snap_seg->cow->name, lv->name);
+			  display_lvname(snap_seg->cow), display_lvname(lv));
 		return 0;
 	}
 
@@ -141,21 +143,24 @@ progress_t poll_merge_progress(struct cmd_context *cmd,
 
 	if (!lv_is_merging_origin(lv) ||
 	    !lv_snapshot_percent(lv, &percent)) {
-		log_error("%s: Failed query for merging percentage. Aborting merge.", lv->name);
+		log_error("%s: Failed query for merging percentage. Aborting merge.",
+			  display_lvname(lv));
 		return PROGRESS_CHECK_FAILED;
 	} else if (percent == DM_PERCENT_INVALID) {
-		log_error("%s: Merging snapshot invalidated. Aborting merge.", lv->name);
+		log_error("%s: Merging snapshot invalidated. Aborting merge.",
+			  display_lvname(lv));
 		return PROGRESS_CHECK_FAILED;
 	} else if (percent == LVM_PERCENT_MERGE_FAILED) {
-		log_error("%s: Merge failed. Retry merge or inspect manually.", lv->name);
+		log_error("%s: Merge failed. Retry merge or inspect manually.",
+			  display_lvname(lv));
 		return PROGRESS_CHECK_FAILED;
 	}
 
 	if (parms->progress_display)
-		log_print_unless_silent("%s: %s: %s%%", lv->name, parms->progress_title,
+		log_print_unless_silent("%s: %s: %s%%", display_lvname(lv), parms->progress_title,
 					display_percent(cmd, DM_PERCENT_100 - percent));
 	else
-		log_verbose("%s: %s: %s%%", lv->name, parms->progress_title,
+		log_verbose("%s: %s: %s%%", display_lvname(lv), parms->progress_title,
 			    display_percent(cmd, DM_PERCENT_100 - percent));
 
 	if (percent == DM_PERCENT_0)
@@ -182,7 +187,7 @@ progress_t poll_thin_merge_progress(struct cmd_context *cmd,
 	 */
 
 	if (device_id != find_snapshot(lv)->device_id) {
-		log_error("LV %s is not merged.", lv->name);
+		log_error("LV %s is not merged.", display_lvname(lv));
 		return PROGRESS_CHECK_FAILED;
 	}
 



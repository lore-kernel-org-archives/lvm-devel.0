From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 24 Jun 2017 12:00:30 -0400
Subject: master - cleanup: use display_percent
Message-ID: <201706241600.v5OG0UWU026854@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bd4b0059bbfebe912115f0889e8f3489422f5fc
Commit:        1bd4b0059bbfebe912115f0889e8f3489422f5fc
Parent:        07eec06f5d7f7a9589b8555df7e67d211dcd3257
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 16:22:36 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jun 24 17:44:42 2017 +0200

cleanup: use display_percent

Replace occurence of %.2f with call of display_percent function.
---
 lib/activate/dev_manager.c |    3 ++-
 lib/display/display.c      |   28 ++++++++++++++--------------
 lib/metadata/metadata.c    |    8 ++++----
 lib/metadata/thin_manip.c  |   21 +++++++++++----------
 tools/lvconvert_poll.c     |    8 ++++----
 tools/polldaemon.c         |    8 ++++----
 6 files changed, 39 insertions(+), 37 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8f71771..d10a917 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1037,7 +1037,8 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 			goto_out;
 	}
 
-	log_debug_activation("LV percent: %.2f", dm_percent_to_float(*overall_percent));
+	log_debug_activation("LV percent: %s",
+			     display_percent(dm->cmd, *overall_percent));
 	r = 1;
 
       out:
diff --git a/lib/display/display.c b/lib/display/display.c
index 5940cf0..18e49f9 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -549,12 +549,12 @@ int lvdisplay_full(struct cmd_context *cmd,
 			       snap_seg ? snap_seg->origin->size : lv->size));
 
 	if (cache_status) {
-		log_print("Cache used blocks      %.2f%%",
-			  dm_percent_to_float(cache_status->data_usage));
-		log_print("Cache metadata blocks  %.2f%%",
-			  dm_percent_to_float(cache_status->metadata_usage));
-		log_print("Cache dirty blocks     %.2f%%",
-			  dm_percent_to_float(cache_status->dirty_usage));
+		log_print("Cache used blocks      %s%%",
+			  display_percent(cmd, cache_status->data_usage));
+		log_print("Cache metadata blocks  %s%%",
+			  display_percent(cmd, cache_status->metadata_usage));
+		log_print("Cache dirty blocks     %s%%",
+			  display_percent(cmd, cache_status->dirty_usage));
 		log_print("Cache read hits/misses " FMTu64 " / " FMTu64,
 			  cache_status->cache->read_hits,
 			  cache_status->cache->read_misses);
@@ -570,16 +570,16 @@ int lvdisplay_full(struct cmd_context *cmd,
 	}
 
 	if (thin_data_active)
-		log_print("Allocated pool data    %.2f%%",
-			  dm_percent_to_float(thin_data_percent));
+		log_print("Allocated pool data    %s%%",
+			  display_percent(cmd, thin_data_percent));
 
 	if (thin_metadata_active)
-		log_print("Allocated metadata     %.2f%%",
-			  dm_percent_to_float(thin_metadata_percent));
+		log_print("Allocated metadata     %s%%",
+			  display_percent(cmd, thin_metadata_percent));
 
 	if (thin_active)
-		log_print("Mapped size            %.2f%%",
-			  dm_percent_to_float(thin_percent));
+		log_print("Mapped size            %s%%",
+			  display_percent(cmd, thin_percent));
 
 	log_print("Current LE             %u",
 		  snap_seg ? snap_seg->origin->le_count : lv->le_count);
@@ -590,8 +590,8 @@ int lvdisplay_full(struct cmd_context *cmd,
 		log_print("COW-table LE           %u", lv->le_count);
 
 		if (snap_active)
-			log_print("Allocated to snapshot  %.2f%%",
-				  dm_percent_to_float(snap_percent));
+			log_print("Allocated to snapshot  %s%%",
+				  display_percent(cmd, snap_percent));
 
 		log_print("Snapshot chunk size    %s",
 			  display_size(cmd, (uint64_t) snap_seg->chunk_size));
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4ba81c7..b44f2df 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1273,11 +1273,11 @@ uint32_t extents_from_percent_size(struct volume_group *vg, const struct dm_list
 	}
 
 	if (!(count = percent_of_extents(size, extents, roundup)))
-		log_error("Converted  %.2f%%%s into 0 extents.",
-			  (double) size / DM_PERCENT_1, get_percent_string(percent));
+		log_error("Converted  %s%%%s into 0 extents.",
+			  display_percent(vg->cmd, size), get_percent_string(percent));
 	else
-		log_verbose("Converted %.2f%%%s into %" PRIu32 " extents.",
-			    (double) size / DM_PERCENT_1, get_percent_string(percent), count);
+		log_verbose("Converted %s%%%s into %" PRIu32 " extents.",
+			    display_percent(vg->cmd, size), get_percent_string(percent), count);
 
 	return count;
 }
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index ad45ce9..559e435 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -241,10 +241,11 @@ int pool_metadata_min_threshold(const struct lv_segment *pool_seg)
 
 int pool_below_threshold(const struct lv_segment *pool_seg)
 {
+	struct cmd_context *cmd = pool_seg->lv->vg->cmd;
 	dm_percent_t percent;
 	dm_percent_t min_threshold = pool_metadata_min_threshold(pool_seg);
 	dm_percent_t threshold = DM_PERCENT_1 *
-		find_config_tree_int(pool_seg->lv->vg->cmd, activation_thin_pool_autoextend_threshold_CFG,
+		find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG,
 				     lv_config_profile(pool_seg->lv));
 
 	/* Data */
@@ -253,10 +254,10 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 
 	if (percent > threshold || percent >= DM_PERCENT_100) {
 		log_debug("Threshold configured for free data space in "
-			  "thin pool %s has been reached (%.2f%% >= %.2f%%).",
+			  "thin pool %s has been reached (%s%% >= %s%%).",
 			  display_lvname(pool_seg->lv),
-			  dm_percent_to_float(percent),
-			  dm_percent_to_float(threshold));
+			  display_percent(cmd, percent),
+			  display_percent(cmd, threshold));
 		return 0;
 	}
 
@@ -267,21 +268,21 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 
 	if (percent >= min_threshold) {
 		log_warn("WARNING: Remaining free space in metadata of thin pool %s "
-			 "is too low (%.2f%% >= %.2f%%). "
+			 "is too low (%s%% >= %s%%). "
 			 "Resize is recommended.",
 			 display_lvname(pool_seg->lv),
-			 dm_percent_to_float(percent),
-			 dm_percent_to_float(min_threshold));
+			 display_percent(cmd, percent),
+			 display_percent(cmd, min_threshold));
 		return 0;
 	}
 
 
 	if (percent > threshold) {
 		log_debug("Threshold configured for free metadata space in "
-			  "thin pool %s has been reached (%.2f%% > %.2f%%).",
+			  "thin pool %s has been reached (%s%% > %s%%).",
 			  display_lvname(pool_seg->lv),
-			  dm_percent_to_float(percent),
-			  dm_percent_to_float(threshold));
+			  display_percent(cmd, percent),
+			  display_percent(cmd, threshold));
 		return 0;
 	}
 
diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index 36db1c7..0daa927 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -152,11 +152,11 @@ progress_t poll_merge_progress(struct cmd_context *cmd,
 	}
 
 	if (parms->progress_display)
-		log_print_unless_silent("%s: %s: %.2f%%", lv->name, parms->progress_title,
-					dm_percent_to_float(DM_PERCENT_100 - percent));
+		log_print_unless_silent("%s: %s: %s%%", lv->name, parms->progress_title,
+					display_percent(cmd, DM_PERCENT_100 - percent));
 	else
-		log_verbose("%s: %s: %.2f%%", lv->name, parms->progress_title,
-			    dm_percent_to_float(DM_PERCENT_100 - percent));
+		log_verbose("%s: %s: %s%%", lv->name, parms->progress_title,
+			    display_percent(cmd, DM_PERCENT_100 - percent));
 
 	if (percent == DM_PERCENT_0)
 		return PROGRESS_FINISHED_ALL;
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 2b64c4e..33fe947 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -40,11 +40,11 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 
 	overall_percent = copy_percent(lv);
 	if (parms->progress_display)
-		log_print_unless_silent("%s: %s: %.2f%%", name, parms->progress_title,
-					dm_percent_to_float(overall_percent));
+		log_print_unless_silent("%s: %s: %s%%", name, parms->progress_title,
+					display_percent(cmd, overall_percent));
 	else
-		log_verbose("%s: %s: %.2f%%", name, parms->progress_title,
-			    dm_percent_to_float(overall_percent));
+		log_verbose("%s: %s: %s%%", name, parms->progress_title,
+			    display_percent(cmd, overall_percent));
 
 	if (segment_percent != DM_PERCENT_100)
 		return PROGRESS_UNFINISHED;



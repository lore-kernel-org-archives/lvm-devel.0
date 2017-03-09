From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 8 Mar 2017 21:59:21 -0500
Subject: master - lvconvert: prompt when converting raid1 to linear
Message-ID: <201703090259.v292xLfP032693@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7fbe6ef16bfb95ffe7c02e29872ccd2d86445acf
Commit:        7fbe6ef16bfb95ffe7c02e29872ccd2d86445acf
Parent:        8daad1166608cd99beca7fb23223a9ed66353e40
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 02:39:49 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 02:39:49 2017 +0100

lvconvert: prompt when converting raid1 to linear

Ask user when converting raid1 to linear to avoid
uninformed loss of all resilience.
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |   28 +++++++++++++++++-----------
 tools/lvconvert.c                |    2 +-
 3 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4960499..28e1f52 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1212,6 +1212,7 @@ struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 int lv_is_raid_with_tracking(const struct logical_volume *lv);
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
 int lv_raid_change_image_count(struct logical_volume *lv,
+			       int yes,
 			       uint32_t new_count,
 			       uint32_t new_region_size,
 			       struct dm_list *allocate_pvs);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 68b1b85..c1788c3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1712,7 +1712,7 @@ static int _reshape_adjust_to_size(struct logical_volume *lv,
  * Reshape: add immages to existing raid lv
  *
  */
-static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
+static int _lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_count,
 				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs,
 				       int commit, int use_existing_area_len);
 static int _raid_reshape_add_images(struct logical_volume *lv,
@@ -1773,7 +1773,7 @@ static int _raid_reshape_add_images(struct logical_volume *lv,
 	log_debug_metadata("Adding %u data and metadata image LV pair%s to %s.",
 			   new_image_count - old_image_count, new_image_count - old_image_count > 1 ? "s" : "",
 			   display_lvname(lv));
-	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, NULL, 0, 0))
+	if (!_lv_raid_change_image_count(lv, 1, new_image_count, allocate_pvs, NULL, 0, 0))
 		return 0;
 
 	/* Reshape adding image component pairs -> change sizes/counters accordingly */
@@ -1949,7 +1949,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 		log_debug_metadata("Removing %u data and metadata image LV pair%s from %s.",
 				   old_image_count - new_image_count, old_image_count - new_image_count > 1 ? "s" : "",
 				   display_lvname(lv));
-		if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, removal_lvs, 0, 0))
+		if (!_lv_raid_change_image_count(lv, 1, new_image_count, allocate_pvs, removal_lvs, 0, 0))
 			return 0;
 
 		seg->area_count = new_image_count;
@@ -2959,7 +2959,7 @@ static int _raid_extract_images(struct logical_volume *lv,
 	return 1;
 }
 
-static int _raid_remove_images(struct logical_volume *lv,
+static int _raid_remove_images(struct logical_volume *lv, int yes,
 			       uint32_t new_count, struct dm_list *allocate_pvs,
 			       struct dm_list *removal_lvs, int commit)
 {
@@ -2982,6 +2982,12 @@ static int _raid_remove_images(struct logical_volume *lv,
 
 	/* Convert to linear? */
 	if (new_count == 1) {
+		if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s to type %s loosing all resilience? [y/n]: ",
+					  lvseg_name(first_seg(lv)), display_lvname(lv), SEG_TYPE_NAME_LINEAR) == 'n') {
+			log_error("Logical volume %s NOT converted to \"%s\".",
+				  display_lvname(lv), SEG_TYPE_NAME_LINEAR);
+			return 0;
+		}
 		if (!_raid_remove_top_layer(lv, removal_lvs)) {
 			log_error("Failed to remove RAID layer "
 				  "after linear conversion.");
@@ -3024,7 +3030,7 @@ static int _raid_remove_images(struct logical_volume *lv,
  * This function adds or removes _both_ portions of the image and commits
  * the results.
  */
-static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
+static int _lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_count,
 				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs,
 				       int commit, int use_existing_area_len)
 {
@@ -3047,12 +3053,12 @@ static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_c
 	}
 
 	if (old_count > new_count)
-		return _raid_remove_images(lv, new_count, allocate_pvs, removal_lvs, commit);
+		return _raid_remove_images(lv, yes, new_count, allocate_pvs, removal_lvs, commit);
 
 	return _raid_add_images(lv, new_count, allocate_pvs, commit, use_existing_area_len);
 }
 
-int lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
+int lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_count,
 			       const uint32_t new_region_size, struct dm_list *allocate_pvs)
 {
 	struct lv_segment *seg = first_seg(lv);
@@ -3062,7 +3068,7 @@ int lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
 		_check_and_adjust_region_size(lv);
 	}
 
-	return _lv_raid_change_image_count(lv, new_count, allocate_pvs, NULL, 1, 0);
+	return _lv_raid_change_image_count(lv, yes, new_count, allocate_pvs, NULL, 1, 0);
 }
 
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
@@ -3886,7 +3892,7 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 	if (new_image_count != seg->area_count) {
 		log_debug_metadata("Changing image count to %u on %s.",
 				   new_image_count, display_lvname(lv));
-		if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, removal_lvs, 0, 0))
+		if (!_lv_raid_change_image_count(lv, 1, new_image_count, allocate_pvs, removal_lvs, 0, 0))
 			return_0;
 	}
 
@@ -4886,7 +4892,7 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 		log_debug_metadata("Removing %" PRIu32 " component LV pair(s) to %s.",
 				   lv_raid_image_count(lv) - new_image_count,
 				   display_lvname(lv));
-		if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, &removal_lvs, 0, 0))
+		if (!_lv_raid_change_image_count(lv, 1, new_image_count, allocate_pvs, &removal_lvs, 0, 0))
 			return 0;
 
 		seg->area_count = new_image_count;
@@ -5135,7 +5141,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 		log_debug_metadata("Adding %" PRIu32 " component LV pair(s) to %s.",
 				   new_image_count - lv_raid_image_count(lv),
 				   display_lvname(lv));
-		if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, NULL, 0, 1))
+		if (!_lv_raid_change_image_count(lv, 1, new_image_count, allocate_pvs, NULL, 0, 1))
 			return 0;
 
 		seg = first_seg(lv);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 97d17e4..3110522 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1359,7 +1359,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 					  DEFAULT_RAID1_MAX_IMAGES, lp->segtype->name, display_lvname(lv));
 				return 0;
 			}
-			if (!lv_raid_change_image_count(lv, image_count, lp->region_size, lp->pvh))
+			if (!lv_raid_change_image_count(lv, lp->yes, image_count, lp->region_size, lp->pvh))
 				return_0;
 
 			log_print_unless_silent("Logical volume %s successfully converted.",



From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 21 Feb 2013 13:19:34 +0000 (UTC)
Subject: master - RAID: Allow remove/replace of sub-LVs composed of error segments.
Message-ID: <20130221131934.CEB64AC684@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd0ee420b597d38e37cfe738951cb1242f527638
Commit:        bd0ee420b597d38e37cfe738951cb1242f527638
Parent:        845852d6b4b486075f3ed866890f79b278a990ce
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 20 14:58:56 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 20 14:58:56 2013 -0600

RAID:  Allow remove/replace of sub-LVs composed of error segments.

When a device fails, we may wish to replace those segments with an
error segment.  (Like when a 'vgreduce --removemissing' removes a
failed device that happens to be a RAID image/meta.)  We are then left
with images that we will eventually want to remove or replace.

This patch allows us to pull out these virtual "error" sub-LVs.  This
allows a user to 'lvconvert -m -1 vg/lv' to extract the bad sub-LVs.
Sub-LVs with error segments are considered for extraction before other
possible devices so that good devices are not accidentally removed.

This patch also adds the ability to replace RAID images that contain error
segments.  The user will still be unable to run 'lvconvert --replace'
because there is no way to address the 'error' segment (i.e. no PV
that it is associated with).  However, 'lvconvert --repair' can be
used to replace the image's error segment with a new PV.  This is also
the most appropriate way to do it, since the LV will continue to be
reported as 'partial'.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   73 +++++++++++++++++++++++++++++++++++----------
 2 files changed, 58 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d237386..33993e4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Allow remove/replace of RAID sub-LVs that are composed of error targets.
   Make 'vgreduce --removemissing' able to handle RAID LVs with missing PVs.
   Rename lvm.conf setting 'mirror_region_size' to 'raid_region_size'.
   Fix pvs -o pv_free reporting for PVs with zero PE count.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 74bb80a..f716664 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -958,10 +958,11 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 			        struct dm_list *extracted_meta_lvs,
 			        struct dm_list *extracted_data_lvs)
 {
-	int s, extract, lvl_idx = 0;
+	int ss, s, extract, lvl_idx = 0;
 	struct lv_list *lvl_array;
 	struct lv_segment *seg = first_seg(lv);
 	struct logical_volume *rmeta_lv, *rimage_lv;
+	struct segment_type *error_segtype;
 
 	extract = seg->area_count - new_count;
 	log_verbose("Extracting %u %s from %s/%s", extract,
@@ -973,18 +974,53 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 	if (!lvl_array)
 		return_0;
 
-	for (s = seg->area_count - 1; (s >= 0) && extract; s--) {
-		if (!_lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
-		    !_lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
-			continue;
-		if (!_raid_in_sync(lv) &&
-		    (!seg_is_mirrored(seg) || (s == 0))) {
-			log_error("Unable to extract %sRAID image"
-				  " while RAID array is not in-sync",
-				  seg_is_mirrored(seg) ? "primary " : "");
-			return 0;
-		}
+	error_segtype = get_segtype_from_string(lv->vg->cmd, "error");
+
+	/*
+	 * We make two passes over the devices.
+	 * - The first pass we look for error LVs
+	 * - The second pass we look for PVs that match target_pvs
+	 */
+	for (ss = (seg->area_count * 2) - 1; (ss >= 0) && extract; ss--) {
+		s = ss % seg->area_count;
+
+		if (ss / seg->area_count) {
+			/* Conditions for first pass */
+			if ((first_seg(seg_lv(seg, s))->segtype != error_segtype) &&
+			    (first_seg(seg_metalv(seg, s))->segtype != error_segtype))
+				continue;
 
+			if (target_pvs && !dm_list_empty(target_pvs) &&
+			    (target_pvs != &lv->vg->pvs)) {
+				/*
+				 * User has supplied a list of PVs, but we
+				 * cannot honor that list because error LVs
+				 * must come first.
+				 */
+				log_error("%s has components with error targets"
+					  " that must be removed first: %s",
+					  lv->name, seg_lv(seg, s)->name);
+
+				log_error("Try removing the PV list and rerun"
+					  " the command.");
+				return 0;
+			}
+			log_debug("LVs with error segments to be removed: %s %s",
+				  seg_metalv(seg, s)->name, seg_lv(seg, s)->name);
+		} else {
+			/* Conditions for second pass */
+			if (!_lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
+			    !_lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
+				continue;
+
+			if (!_raid_in_sync(lv) &&
+			    (!seg_is_mirrored(seg) || (s == 0))) {
+				log_error("Unable to extract %sRAID image"
+					  " while RAID array is not in-sync",
+					  seg_is_mirrored(seg) ? "primary " : "");
+				return 0;
+			}
+		}
 		if (!_extract_image_components(seg, s, &rmeta_lv, &rimage_lv)) {
 			log_error("Failed to extract %s from %s",
 				  seg_lv(seg, s)->name, lv->name);
@@ -1595,8 +1631,8 @@ int lv_raid_reshape(struct logical_volume *lv,
 /*
  * lv_raid_replace
  * @lv
- * @replace_pvs
- * @allocatable_pvs
+ * @remove_pvs
+ * @allocate_pvs
  *
  * Replace the specified PVs.
  */
@@ -1639,7 +1675,10 @@ int lv_raid_replace(struct logical_volume *lv,
 			return 0;
 		}
 
-		if (_lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
+		// FIXME: safe to use 'virtual' as a substitute for 'error'?
+		if (lv_is_virtual(seg_lv(raid_seg, s)) ||
+		    lv_is_virtual(seg_metalv(raid_seg, s)) ||
+		    _lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
 		    _lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs))
 			match_count++;
 	}
@@ -1669,7 +1708,9 @@ int lv_raid_replace(struct logical_volume *lv,
 			if (!(i % copies))
 				rebuilds_per_group = 0;
 			if (_lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
-			    _lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs))
+			    _lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs) ||
+			    lv_is_virtual(seg_lv(raid_seg, s)) ||
+			    lv_is_virtual(seg_metalv(raid_seg, s)))
 				rebuilds_per_group++;
 			if (rebuilds_per_group >= copies) {
 				log_error("Unable to replace all the devices "



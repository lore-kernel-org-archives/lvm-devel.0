From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 26 Jun 2014 03:26:49 +0000 (UTC)
Subject: master - raid: Allow repair to reuse PVs from same image that suffered a PV failure
Message-ID: <20140626032649.186ED61013@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed3c2537b82be4e326a53c7e3e6d5eccdd833800
Commit:        ed3c2537b82be4e326a53c7e3e6d5eccdd833800
Parent:        7028fd31a0f2d2234ffdd1b94ea6ae6128ca9362
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 25 22:26:06 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 25 22:26:06 2014 -0500

raid: Allow repair to reuse PVs from same image that suffered a PV failure

When repairing RAID LVs that have multiple PVs per image, allow
replacement images to be reallocated from the PVs that have not
failed in the image if there is sufficient space.

This allows for scenarios where a 2-way RAID1 is spread across 4 PVs,
where each image lives on two PVs but doesn't use the entire space
on any of them.  If one PV fails and there is sufficient space on the
remaining PV in the image, the image can be reallocated on just the
remaining PV.
---
 WHATS_NEW                               |    1 +
 lib/metadata/raid_manip.c               |  127 ++++++++++++++++++++++++++++---
 test/shell/lvconvert-raid-allocation.sh |   20 ++++-
 3 files changed, 133 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 05b3c7c..396dd07 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Allow RAID repair to reuse PVs from same image that suffered a failure.
   New RAID images now avoid allocation on any PVs in the same parent RAID LV.
   Always reevaluate filters just before creating PV.
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0303654..6fead9a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1501,6 +1501,85 @@ int lv_raid_reshape(struct logical_volume *lv,
 	return 0;
 }
 
+
+static int _remove_partial_multi_segment_image(struct logical_volume *lv,
+					       struct dm_list *remove_pvs)
+{
+	uint32_t s, extents_needed;
+	struct lv_segment *rm_seg, *raid_seg = first_seg(lv);
+	struct logical_volume *rm_image = NULL;
+	struct physical_volume *pv;
+
+	if (!(lv->status & PARTIAL_LV))
+		return_0;
+
+	for (s = 0; s < raid_seg->area_count; s++) {
+		extents_needed = 0;
+		if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) &&
+		    lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) &&
+		    (dm_list_size(&(seg_lv(raid_seg, s)->segments)) > 1)) {
+			rm_image = seg_lv(raid_seg, s);
+
+			/* First, how many damaged extents are there */
+			if (seg_metalv(raid_seg, s)->status & PARTIAL_LV)
+				extents_needed += seg_metalv(raid_seg, s)->le_count;
+			dm_list_iterate_items(rm_seg, &rm_image->segments) {
+				/*
+				 * segment areas are for stripe, mirror, raid,
+				 * etc.  We only need to check the first area
+				 * if we are dealing with RAID image LVs.
+				 */
+				if (seg_type(rm_seg, 0) != AREA_PV)
+					continue;
+				pv = seg_pv(rm_seg, 0);
+				if (pv->status & MISSING_PV)
+					extents_needed += rm_seg->len;
+			}
+			log_debug("%u extents needed to repair %s",
+				  extents_needed, rm_image->name);
+
+			/* Second, do the other PVs have the space */
+			dm_list_iterate_items(rm_seg, &rm_image->segments) {
+				if (seg_type(rm_seg, 0) != AREA_PV)
+					continue;
+				pv = seg_pv(rm_seg, 0);
+				if (pv->status & MISSING_PV)
+					continue;
+
+				if ((pv->pe_count - pv->pe_alloc_count) >
+				    extents_needed) {
+					log_debug("%s has enough space for %s",
+						  pv_dev_name(pv),
+						  rm_image->name);
+					goto has_enough_space;
+				}
+				log_debug("Not enough space on %s for %s",
+					  pv_dev_name(pv), rm_image->name);
+			}
+		}
+	}
+
+	/*
+	 * This is likely to be the normal case - single
+	 * segment images.
+	 */
+	return_0;
+
+has_enough_space:
+	/*
+	 * Now we have a multi-segment, partial image that has enough
+	 * space on just one of its PVs for the entire image to be
+	 * replaced.  So, we replace the image's space with an error
+	 * target so that the allocator can find that space (along with
+	 * the remaining free space) in order to allocate the image
+	 * anew.
+	 */
+	if (!replace_lv_with_error_segment(rm_image))
+		return_0;
+
+	return 1;
+}
+
 /*
  * lv_raid_replace
  * @lv
@@ -1513,6 +1592,7 @@ int lv_raid_replace(struct logical_volume *lv,
 		    struct dm_list *remove_pvs,
 		    struct dm_list *allocate_pvs)
 {
+	int partial_segment_removed = 0;
 	uint32_t s, sd, match_count = 0;
 	struct dm_list old_lvs;
 	struct dm_list new_meta_lvs, new_data_lvs;
@@ -1605,25 +1685,40 @@ int lv_raid_replace(struct logical_volume *lv,
 try_again:
 	if (!_alloc_image_components(lv, allocate_pvs, match_count,
 				     &new_meta_lvs, &new_data_lvs)) {
-		log_error("Failed to allocate replacement images for %s/%s",
-			  lv->vg->name, lv->name);
-
-		/*
-		 * If this is a repair, then try to
-		 * do better than all-or-nothing
-		 */
-		if (match_count > 1) {
-			log_error("Attempting replacement of %u devices"
-				  " instead of %u", match_count - 1, match_count);
-			match_count--;
+		if (!(lv->status & PARTIAL_LV))
+			return 0;
 
+		/* This is a repair, so try to do better than all-or-nothing */
+		match_count--;
+		if (match_count > 0) {
+			log_error("Failed to replace %u devices."
+				  "  Attempting to replace %u instead.",
+				  match_count, match_count+1);
 			/*
 			 * Since we are replacing some but not all of the bad
 			 * devices, we must set partial_activation
 			 */
 			lv->vg->cmd->partial_activation = 1;
 			goto try_again;
+		} else if (!match_count && !partial_segment_removed) {
+			/*
+			 * We are down to the last straw.  We can only hope
+			 * that a failed PV is just one of several PVs in
+			 * the image; and if we extract the image, there may
+			 * be enough room on the image's other PVs for a
+			 * reallocation of the image.
+			 */
+			if (!_remove_partial_multi_segment_image(lv, remove_pvs))
+				return_0;
+
+			match_count = 1;
+			partial_segment_removed = 1;
+			lv->vg->cmd->partial_activation = 1;
+			goto try_again;
 		}
+		log_error("Failed to allocate replacement images for %s/%s",
+			  lv->vg->name, lv->name);
+
 		return 0;
 	}
 
@@ -1632,9 +1727,17 @@ try_again:
 	 * - If we did this before the allocate, we wouldn't have to rename
 	 *   the allocated images, but it'd be much harder to avoid the right
 	 *   PVs during allocation.
+	 *
+	 * - If this is a repair and we were forced to call
+	 *   _remove_partial_multi_segment_image, then the remove_pvs list
+	 *   is no longer relevant - _raid_extract_images is forced to replace
+	 *   the image with the error target.  Thus, the full set of PVs is
+	 *   supplied - knowing that only the image with the error target
+	 *   will be affected.
 	 */
 	if (!_raid_extract_images(lv, raid_seg->area_count - match_count,
-				  remove_pvs, 0,
+				  partial_segment_removed ?
+				  &lv->vg->pvs : remove_pvs, 0,
 				  &old_lvs, &old_lvs)) {
 		log_error("Failed to remove the specified images from %s/%s",
 			  lv->vg->name, lv->name);
diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index 804317b..aef786c 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -27,7 +27,8 @@ lvconvert -m 0 $vg/$lv1
 # lvconvert --type raid1 -m 1 --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
 lvremove -ff $vg
 
-# Setup 2-way RAID1 LV to spread across 4 devices.
+
+# Setup 2-way RAID1 LV, spread across 4 devices.
 # For each image:
 #  - metadata LV + 1 image extent (2 total extents) on one PV
 #  - 2 image extents on the other PV
@@ -43,10 +44,8 @@ aux wait_for_sync $vg $lv1
 # Should not be enough non-overlapping space.
 not lvconvert -m +1 $vg/$lv1 \
     "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
-
 lvconvert -m +1 $vg/$lv1 "$dev5"
 lvconvert -m 0 $vg/$lv1
-
 # Should work due to '--alloc anywhere'
 # RAID conversion not honoring allocation policy!
 #lvconvert -m +1 --alloc anywhere $vg/$lv1 \
@@ -54,4 +53,19 @@ lvconvert -m 0 $vg/$lv1
 lvremove -ff $vg
 
 
+# Setup 2-way RAID1 LV, spread across 4 devices
+#  - metadata LV + 1 image extent (2 total extents) on one PV
+#  - 2 image extents on the other PV
+# Kill one PV.  There should be enough space on the remaining
+# PV for that image to reallocate the entire image there and
+# still maintain redundancy.
+lvcreate --type raid1 -m 1 -l 3 -n $lv1 $vg \
+    "$dev1:0-1" "$dev2:0-1" "$dev3:0-1" "$dev4:0-1"
+aux wait_for_sync $vg $lv1
+aux disable_dev "$dev1"
+lvconvert --repair -y $vg/$lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+#FIXME: ensure non-overlapping images (they should not share PVs)
+aux enable_dev "$dev1"
+lvremove -ff $vg
+
 vgremove -ff $vg



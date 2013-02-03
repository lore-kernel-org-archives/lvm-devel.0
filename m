From: Jonathan Brassow <jbrassow@redhat.com>
Date: Sun, 03 Feb 2013 02:31:13 -0600
Subject: [PATCH 2 of 3] Allow down-convert to work on RAID images with error segments
In-Reply-To: <1359880051.15387.8.camel@f16>
References: <1359880051.15387.8.camel@f16>
Message-ID: <1359880273.15387.12.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

RAID: Allow removal of RAID images that contain error segments

When a device fails, we may wish to replace those segments with an
error segment.  (Like when a 'vgreduce --removemissing' removes a
failed device that happens to be a RAID image/meta.)  We are then left
with images that we will eventually want to remove or replace.

This patch allows us to pull out these virtual "error" sub-LVs.  This
allows a user to 'lvconvert -m -1 vg/lv' to extract the bad sub-LVs.
Sub-LVs with error segments are considered for extraction before other
possible devices so that good devices are not accidentally removed.
 
Index: lvm2/lib/metadata/raid_manip.c
===================================================================
--- lvm2.orig/lib/metadata/raid_manip.c
+++ lvm2/lib/metadata/raid_manip.c
@@ -958,10 +958,11 @@ static int _raid_extract_images(struct l
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
@@ -973,18 +974,53 @@ static int _raid_extract_images(struct l
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




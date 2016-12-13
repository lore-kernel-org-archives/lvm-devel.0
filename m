From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:09:54 +0000 (UTC)
Subject: master - cleanup: log message updates
Message-ID: <20161213210954.2032C607A9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7da16e5f162193db16f2a1845200fc99ed6ebc3
Commit:        c7da16e5f162193db16f2a1845200fc99ed6ebc3
Parent:        a8f5e1f2744a568779445aa5def423f7e1210ee7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 13 00:10:01 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 13 22:07:52 2016 +0100

cleanup: log message updates

---
 lib/metadata/raid_manip.c |   42 ++++++++++++++++++++++++------------------
 1 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 81e2ac2..56fe6a7 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1056,8 +1056,10 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
 	struct logical_volume *data_lv = seg_lv(seg, idx);
 	struct logical_volume *meta_lv = seg_metalv(seg, idx);
 
-	log_very_verbose("Extracting image components %s and %s from %s",
-			 data_lv->name, meta_lv->name, seg->lv->name);
+	log_very_verbose("Extracting image components %s and %s from %s.",
+			 display_lvname(data_lv),
+			 display_lvname(meta_lv),
+			 display_lvname(seg->lv));
 
 	data_lv->status &= ~RAID_IMAGE;
 	meta_lv->status &= ~RAID_META;
@@ -1185,8 +1187,9 @@ static int _raid_extract_images(struct logical_volume *lv,
 			}
 		}
 		if (!_extract_image_components(seg, s, &rmeta_lv, &rimage_lv)) {
-			log_error("Failed to extract %s from %s",
-				  seg_lv(seg, s)->name, lv->name);
+			log_error("Failed to extract %s from %s.",
+				  display_lvname(seg_lv(seg, s)),
+				  display_lvname(lv));
 			return 0;
 		}
 
@@ -1362,7 +1365,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		if (!lv_is_on_pvs(tracking, splittable_pvs)) {
 			log_error("Unable to split additional image from %s "
 				  "while tracking changes for %s.",
-				  display_lvname(lv), tracking->name);
+				  display_lvname(lv), display_lvname(tracking));
 			return 0;
 		}
 
@@ -1502,7 +1505,7 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 	}
 
 	if (s < 0) {
-		log_error("Unable to find image to satisfy request");
+		log_error("Unable to find image to satisfy request.");
 		return 0;
 	}
 
@@ -2042,12 +2045,12 @@ static int _adjust_data_lvs(struct logical_volume *lv, enum mirror_raid_conv dir
 		dlv = seg_lv(seg, s);
 
 		if (!(sublv_name_suffix = first_substring(dlv->name, "_mimage_", "_rimage_", NULL))) {
-			log_error(INTERNAL_ERROR "name lags image part");
+			log_error(INTERNAL_ERROR "Name %s lags image part.", dlv->name);
 			return 0;
 		}
 
 		*(sublv_name_suffix + 1) = conv[direction].type_char;
-		log_debug_metadata("data LV renamed to %s.", display_lvname(dlv));
+		log_debug_metadata("Data LV renamed to %s.", display_lvname(dlv));
 
 		dlv->status &= ~conv[direction].reset_flag;
 		dlv->status |= conv[direction].set_flag;
@@ -3084,7 +3087,7 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 	if (!yes && yes_no_prompt("Are you sure you want to convert \"%s\" LV %s to \"%s\" "
 				  "type losing all resilience? [y/n]: ",
 				  lvseg_name(seg), display_lvname(lv), new_segtype->name) == 'n') {
-		log_error("Logical volume %s NOT converted to \"%s\"",
+		log_error("Logical volume %s NOT converted to \"%s\".",
 			  display_lvname(lv), new_segtype->name);
 		return 0;
 	}
@@ -3108,7 +3111,8 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 
 		if (segtype_is_any_raid0(new_segtype) &&
 		    !(rename_sublvs = _rename_area_lvs(lv, "_"))) {
-			log_error("Failed to rename %s LV %s MetaLVs", lvseg_name(seg), display_lvname(lv));
+			log_error("Failed to rename %s LV %s MetaLVs.",
+				  lvseg_name(seg), display_lvname(lv));
 			return 0;
 		}
 
@@ -3138,7 +3142,8 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 
 	if (rename_sublvs) {
 		if (!_rename_area_lvs(lv, NULL)) {
-			log_error("Failed to rename %s LV %s MetaLVs", lvseg_name(seg), display_lvname(lv));
+			log_error("Failed to rename %s LV %s MetaLVs.",
+				  lvseg_name(seg), display_lvname(lv));
 			return 0;
 		}
 		if (!lv_update_and_reload(lv))
@@ -3181,19 +3186,19 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 
 	if (new_data_copies > new_image_count) {
-		log_error("N number of data_copies \"--mirrors N-1\" may not be larger than number of stripes");
+		log_error("N number of data_copies \"--mirrors N-1\" may not be larger than number of stripes.");
 		return 0;
 	}
 
 	if (new_stripes && new_stripes != seg->area_count) {
-		log_error("Can't restripe LV %s during conversion", display_lvname(lv));
+		log_error("Can't restripe LV %s during conversion.", display_lvname(lv));
 		return 0;
 	}
 
 	/* FIXME: restricted to raid4 for the time being... */
 	if (!segtype_is_raid4(new_segtype)) {
 		/* Can't convert striped/raid0* to e.g. raid10_offset */
-		log_error("Can't convert %s to %s", display_lvname(lv), new_segtype->name);
+		log_error("Can't convert %s to %s.", display_lvname(lv), new_segtype->name);
 		return 0;
 	}
 
@@ -3211,7 +3216,7 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 
 	/* Add metadata LVs */
 	if (seg_is_raid0(seg)) {
-		log_debug_metadata("Adding metadata LVs to %s", display_lvname(lv));
+		log_debug_metadata("Adding metadata LVs to %s.", display_lvname(lv));
 		if (!_raid0_add_or_remove_metadata_lvs(lv, 1 /* update_and_reload */, allocate_pvs, NULL))
 			return_0;
 	/* raid0_meta -> raid4 needs clearing of MetaLVs in order to avoid raid disk role cahnge issues in the kernel */
@@ -3220,7 +3225,8 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		return_0;
 
 	/* Add the additional component LV pairs */
-	log_debug_metadata("Adding %" PRIu32 " component LV pair(s) to %s", new_image_count - lv_raid_image_count(lv),
+	log_debug_metadata("Adding %" PRIu32 " component LV pair(s) to %s.",
+			   new_image_count - lv_raid_image_count(lv),
 			   display_lvname(lv));
 	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, NULL, 0, 1))
 		return_0;
@@ -3228,7 +3234,7 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 	if (segtype_is_raid4(new_segtype) &&
 	    (!_shift_parity_dev(seg) ||
 	     !_rename_area_lvs(lv, "_"))) {
-		log_error("Can't convert %s to %s", display_lvname(lv), new_segtype->name);
+		log_error("Can't convert %s to %s.", display_lvname(lv), new_segtype->name);
 		return 0;
 	}
 
@@ -3239,7 +3245,7 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 
 	_check_and_adjust_region_size(lv);
 
-	log_debug_metadata("Updating VG metadata and reloading %s LV %s",
+	log_debug_metadata("Updating VG metadata and reloading %s LV %s.",
 			   lvseg_name(seg), display_lvname(lv));
 	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, NULL))
 		return_0;



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 31 Oct 2019 10:44:24 -0400
Subject: master - raid: drop internal error
Message-ID: <201910311444.x9VEiO6g018550@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8689b4ed8217bab779a6136a0e3d3b963bac11f4
Commit:        8689b4ed8217bab779a6136a0e3d3b963bac11f4
Parent:        3d9fc7d6f32db7fb605e0551afacb0fc3ccac3ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 31 11:47:39 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 31 15:31:30 2019 +0100

raid: drop internal error

Fix some internal error reports and debug trace returns
---
 lib/metadata/raid_manip.c |   23 ++++++++++-------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 183435b..a1c51aa 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -213,7 +213,7 @@ static int _get_available_removed_sublvs(const struct logical_volume *lv, uint32
 		if (seg_type(seg, s) != AREA_LV || !(slv = seg_lv(seg, s))) {
 			log_error(INTERNAL_ERROR "Missing image sub lv in area %" PRIu32 " of LV %s.",
 				  s, display_lvname(lv));
-			return_0;
+			return 0;
 		}
 
 		(slv->status & LV_REMOVE_AFTER_RESHAPE) ? (*removed_slvs)++ : (*available_slvs)++;
@@ -619,10 +619,9 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 
 	/* Update and reload to clear out reset flags in the metadata and in the kernel */
 	log_debug_metadata("Updating metadata mappings for %s.", display_lvname(lv));
-	if ((r != 2 || flags_reset) && !(r = (origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv)))) {
-		log_error(INTERNAL_ERROR "Update of LV %s failed.", display_lvname(lv));
-		return 0;
-	}
+	if ((r != 2 || flags_reset) &&
+	    !(r = (origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv))))
+		return_0;
 
 	return 1;
 }
@@ -1829,7 +1828,7 @@ static int _raid_reshape_add_images(struct logical_volume *lv,
 
 	if (new_image_count == old_image_count) {
 		log_error(INTERNAL_ERROR "No change of image count on LV %s.", display_lvname(lv));
-		return_0;
+		return 0;
 	}
 
 	vg = lv->vg;
@@ -1955,7 +1954,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 
 	if (new_image_count == old_image_count) {
 		log_error(INTERNAL_ERROR "No change of image count on LV %s.", display_lvname(lv));
-		return_0;
+		return 0;
 	}
 
 	switch (_reshaped_state(lv, new_image_count, &devs_health, &devs_in_sync)) {
@@ -6374,8 +6373,8 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 			return_0;
 
 		if (dm_snprintf(fmt, sz, "%s%s%s", basic_fmt, (seg_from->segtype == *segtype_to) ? "" : type_fmt, question_fmt) < 0) {
-			log_error(INTERNAL_ERROR "dm_snprintf failed.");
-			return_0;
+			log_error("dm_snprintf failed.");
+			return 0;
 		}
 
 		if (yes_no_prompt(fmt, lvseg_name(seg_from), display_lvname(seg_from->lv),
@@ -7184,10 +7183,8 @@ int partial_raid_lv_supports_degraded_activation(const struct logical_volume *cl
 	if (!_lv_may_be_activated_in_degraded_mode(lv, &not_capable) || not_capable)
 		return_0;
 
-	if (!for_each_sub_lv(lv, _lv_may_be_activated_in_degraded_mode, &not_capable)) {
-		log_error(INTERNAL_ERROR "for_each_sub_lv failure.");
-		return 0;
-	}
+	if (!for_each_sub_lv(lv, _lv_may_be_activated_in_degraded_mode, &not_capable))
+		return_0;
 
 	return !not_capable;
 }



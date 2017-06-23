From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 12:49:06 -0400
Subject: master - raid: improving messages for regionsize change
Message-ID: <201706231649.v5NGn6uF019852@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d30350dd1bed68826ebe103f3e58c46d251caf6
Commit:        6d30350dd1bed68826ebe103f3e58c46d251caf6
Parent:        cb2c2484b976e0ea4684cdf4ec26ab6adadce024
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 14:40:10 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:44:00 2017 +0200

raid: improving messages for regionsize change

Handle change of 'region size' better and follow also standard rule
if the command can't success (i.e. size is already same) we return
error for all such cases.

Also log_pring more info about adjusted value (just like we
do for rounding)

Also avoid keep pointers on 'display_*' values - they are in
ringbuffer for immediate use - not to be kept across multiple calls
(as they could be already overwritten by later calls) - so dropped
seg_region_size_str
---
 lib/metadata/raid_manip.c |   81 +++++++++++++++++++++++---------------------
 1 files changed, 42 insertions(+), 39 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 08347f9..be431f1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -167,12 +167,20 @@ static int _check_max_mirror_devices(uint32_t image_count)
  * Fix up LV region_size if not yet set.
  */
 /* FIXME Check this happens exactly once at the right place. */
-static void _check_and_adjust_region_size(const struct logical_volume *lv)
+static void _check_and_adjust_region_size(struct logical_volume *lv)
 {
 	struct lv_segment *seg = first_seg(lv);
+	uint32_t region_size;
 
 	seg->region_size = seg->region_size ? : get_default_region_size(lv->vg->cmd);
-	seg->region_size = raid_ensure_min_region_size(lv, lv->size, seg->region_size);
+	region_size = raid_ensure_min_region_size(lv, lv->size, seg->region_size);
+	if (seg->region_size != region_size) {
+		log_print_unless_silent("Adjusting region size of %s LV from %s to %s.",
+					display_lvname(lv),
+					display_size(lv->vg->cmd, seg->region_size),
+					display_size(lv->vg->cmd, region_size));
+		seg->region_size = region_size;
+	}
 }
 
 /* Drop @suffix from *str by writing '\0' to the beginning of @suffix */
@@ -6075,7 +6083,6 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 static int _region_size_change_requested(struct logical_volume *lv, int yes, const uint32_t region_size)
 {
 	uint32_t old_region_size;
-	const char *seg_region_size_str;
 	struct lv_segment *seg = first_seg(lv);
 
 	/* Caller should ensure this */
@@ -6096,46 +6103,52 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, con
 	if (!_check_region_size_constraints(lv, seg->segtype, region_size, seg->stripe_size))
 		return_0;
 
-	if (!_raid_in_sync(lv)) {
-		log_error("Unable to change region size on %s LV %s while it is not in-sync.",
+	old_region_size = seg->region_size;
+	seg->region_size = region_size;
+	_check_and_adjust_region_size(lv);
+
+	if (seg->region_size == old_region_size) {
+		log_error("Region size is already matching %s on %s LV %s due to adjustment.",
+			  display_size(lv->vg->cmd, seg->region_size),
 			  lvseg_name(seg), display_lvname(lv));
 		return 0;
 	}
 
-	old_region_size = seg->region_size;
-	seg_region_size_str = display_size(lv->vg->cmd, region_size);
-
 	if (!yes && yes_no_prompt("Do you really want to change the region_size %s of LV %s to %s? [y/n]: ",
 				  display_size(lv->vg->cmd, old_region_size),
-				  display_lvname(lv), seg_region_size_str) == 'n') {
-		log_error("Logical volume %s NOT converted", display_lvname(lv));
+				  display_lvname(lv),
+				  display_size(lv->vg->cmd, region_size)) == 'n') {
+		log_error("Logical volume %s NOT converted.", display_lvname(lv));
 		return 0;
 	}
 
-	seg->region_size = region_size;
-	_check_and_adjust_region_size(lv);
-
-	if (seg->region_size == old_region_size) {
-		log_warn("Region size on %s did not change due to adjustment.",
-			 display_lvname(lv));
-		return 1;
-	}
-
 	/* Check for new region size causing bitmap to still fit metadata image LV */
 	if (seg->meta_areas && seg_metatype(seg, 0) == AREA_LV && seg_metalv(seg, 0)->le_count <
 	    _raid_rmeta_extents(lv->vg->cmd, lv->le_count, seg->region_size, lv->vg->extent_size)) {
 		log_error("Region size %s on %s is too small for metadata LV size.",
-			  seg_region_size_str, display_lvname(lv));
+			  display_size(lv->vg->cmd, region_size),
+			  display_lvname(lv));
 		return 0;
 	}
 
+	if (!_raid_in_sync(lv)) {
+		log_error("Unable to change region size on %s LV %s while it is not in-sync.",
+			  lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+
+	log_verbose("Converting %s LV %s to regionsize %s.",
+		    lvseg_name(seg), display_lvname(lv),
+		    display_size(lv->vg->cmd, seg->region_size));
+
 	lv->status &= ~LV_RESHAPE;
 
 	if (!lv_update_and_reload_origin(lv))
 		return_0;
 
-	log_warn("Changed region size on RAID LV %s to %s.",
-		 display_lvname(lv), seg_region_size_str);
+	log_print_unless_silent("Changed region size on %s LV %s to %s.",
+				lvseg_name(seg), display_lvname(lv),
+				display_size(lv->vg->cmd, seg->region_size));
 	return 1;
 }
 
@@ -6403,23 +6416,8 @@ int lv_raid_convert(struct logical_volume *lv,
 	 *
 	 * Check if a regionsize change is required.
 	 */
-	if (seg->segtype == new_segtype && new_region_size) {
-		if (seg->region_size != new_region_size) {
-			log_verbose("Converting %s LV %s to regionsize %s.",
-				    lvseg_name(first_seg(lv)), display_lvname(lv),
-				    display_size(lv->vg->cmd, new_region_size));
-			return _region_size_change_requested(lv, yes, new_region_size);
-		} else {
-			log_error("Can't convert %s LV %s without a region size change.",
-				  lvseg_name(seg), display_lvname(lv));
-			return 0;
-		}
-	}
-
-	log_verbose("Converting %s from %s to %s.",
-		    display_lvname(lv), lvseg_name(first_seg(lv)),
-		    (segtype_is_striped_target(new_segtype) &&
-		    (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
+	if (seg->segtype == new_segtype && new_region_size)
+		return _region_size_change_requested(lv, yes, new_region_size);
 
 	/* LV must be in sync. */
 	if (!_raid_in_sync(lv)) {
@@ -6428,6 +6426,11 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
+	log_verbose("Converting %s from %s to %s.",
+		    display_lvname(lv), lvseg_name(first_seg(lv)),
+		    (segtype_is_striped_target(new_segtype) &&
+		    (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
+
 	lv->status &= ~LV_RESHAPE;
 
 	return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, new_stripes, stripe_size,



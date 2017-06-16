From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Jun 2017 11:13:32 -0400
Subject: master - cleanup: improve debug tracing
Message-ID: <201706161513.v5GFDWUb011190@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14816222a19c01e3846d8a38f89113613ae531e8
Commit:        14816222a19c01e3846d8a38f89113613ae531e8
Parent:        b7c9ec8a24a0271e55ea5aa0c9f6525011d0fa0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 14 16:26:35 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 16 17:04:02 2017 +0200

cleanup: improve debug tracing

---
 lib/metadata/raid_manip.c |   27 +++++++++++++--------------
 1 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 214aa19..87b6c01 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -442,7 +442,7 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 
 	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, 2 * sizeof(*lvl)))) {
 		log_error("Memory allocation failed.");
-		return_0;
+		return 0;
 	}
 
 	/* Add last metadata area to removal_lvs */
@@ -545,11 +545,13 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 			fn_pre_data = va_arg(ap, void *);
 	}
 
+	va_end(ap);
+
 	/* Call any fn_pre_on_lv before the first update and reload call (e.g. to rename LVs) */
 	/* returns 1: ok+ask caller to update, 2: metadata commited+ask caller to resume */
 	if (fn_pre_on_lv && !(r = fn_pre_on_lv(lv, fn_pre_data))) {
 		log_error(INTERNAL_ERROR "Pre callout function failed.");
-		goto err;
+		return 0;
 	}
 
 	if (r == 2) {
@@ -560,16 +562,16 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 		if (!(r = (origin_only ? resume_lv_origin(lv->vg->cmd, lv_lock_holder(lv)) :
 					 resume_lv(lv->vg->cmd, lv_lock_holder(lv))))) {
 			log_error("Failed to resume %s.", display_lvname(lv));
-			goto err;
+			return 0;
 		}
 
 	/* Update metadata and reload mappings including flags (e.g. LV_REBUILD, LV_RESHAPE_DELTA_DISKS_PLUS) */
 	} else if (!(r = (origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv))))
-		goto err;
+		return_0;
 
 	/* Eliminate any residual LV and don't commit the metadata */
 	if (!(r = _eliminate_extracted_lvs_optional_write_vg(lv->vg, removal_lvs, 0)))
-		goto err;
+		return_0;
 
 	/*
 	 * Now that any 'REBUILD' or 'RESHAPE_DELTA_DISKS' etc.
@@ -582,25 +584,22 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 	 */
 	log_debug_metadata("Clearing any flags for %s passed to the kernel.", display_lvname(lv));
 	if (!(r = _reset_flags_passed_to_kernel(lv, &flags_reset)))
-		goto err;
+		return_0;
 
 	/* Call any @fn_post_on_lv before the second update call (e.g. to rename LVs back) */
 	if (fn_post_on_lv && !(r = fn_post_on_lv(lv, fn_post_data))) {
 		log_error("Post callout function failed.");
-		goto err;
+		return 0;
 	}
 
 	/* Update and reload to clear out reset flags in the metadata and in the kernel */
 	log_debug_metadata("Updating metadata mappings for %s.", display_lvname(lv));
 	if ((r != 2 || flags_reset) && !(r = (origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv)))) {
 		log_error(INTERNAL_ERROR "Update of LV %s failed.", display_lvname(lv));
-		goto err;
+		return 0;
 	}
 
-	r = 1;
-err:
-	va_end(ap);
-	return r;
+	return 1;
 }
 
 /*
@@ -4030,14 +4029,14 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 	/* Remove rmeta LVs */
 	log_debug_metadata("Extracting and renaming metadata LVs.");
 	if (!_extract_image_component_list(seg, RAID_META, 0, removal_lvs))
-		return 0;
+		return_0;
 
 	seg->meta_areas = NULL;
 
 	/* Rename all data sub LVs from "*_rimage_*" to "*_mimage_*" and set their status */
 	log_debug_metadata("Adjust data LVs of %s.", display_lvname(lv));
 	if (!_adjust_data_lvs(lv, RAID1_TO_MIRROR))
-		return 0;
+		return_0;
 
 	seg->segtype = new_segtype;
 	seg->region_size = new_region_size;



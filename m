From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 25 Oct 2018 08:37:08 -0400
Subject: master - Revert "raid: fix left behind SubLVs"
Message-ID: <201810251237.w9PCb8HS030018@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8df2dd66ce53817b250f5dd6bd05fda3a38ac26e
Commit:        8df2dd66ce53817b250f5dd6bd05fda3a38ac26e
Parent:        16ae968d24b4fe3264dc9b46063345ff2846957b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Oct 25 14:30:32 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Oct 25 14:35:56 2018 +0200

Revert "raid: fix left behind SubLVs"

This reverts commit 16ae968d24b4fe3264dc9b46063345ff2846957b.

We need to come up with a better fix, because we fall short
wiping all known signatures when not using the wipe_lv API.
---
 lib/metadata/raid_manip.c |  140 +++++++++++++++++++++------------------------
 1 files changed, 66 insertions(+), 74 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 25960a3..3944dc4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -689,90 +689,86 @@ static int _lv_update_and_reload_list(struct logical_volume *lv, int origin_only
 	return r;
 }
 
-/*
- * HM Helper
- *
- * clear first @sectors of @lv
- *
- * Presuming we are holding an exclusive lock, we can clear the first
- * @sectors of the (metadata) @lv directly on the respective PE(s) thus
- * avoiding write+commit+activation of @lv altogether and hence superfluous
- * latencies or left behind visible SubLVs on a command/system crash.
+/* Makes on-disk metadata changes
+ * If LV is active:
+ *	clear first block of device
+ * otherwise:
+ *	activate, clear, deactivate
  *
  * Returns: 1 on success, 0 on failure
- *
- * HM FIXME: share with lv_manip.c!
  */
-static int _clear_lv(struct logical_volume *lv, uint32_t sectors)
+static int _clear_lvs(struct dm_list *lv_list)
 {
-	struct lv_segment *seg;
-	struct physical_volume *pv;
-	uint64_t offset;
-	uint32_t cur_sectors;
+	struct lv_list *lvl;
+	struct volume_group *vg = NULL;
+	unsigned i = 0, sz = dm_list_size(lv_list);
+	char *was_active;
+	int r = 1;
 
-	if (test_mode())
+	if (!sz) {
+		log_debug_metadata(INTERNAL_ERROR "Empty list of LVs given for clearing.");
 		return 1;
+	}
 
-	if (!sectors)
-		return_0;
+	dm_list_iterate_items(lvl, lv_list) {
+		if (!lv_is_visible(lvl->lv)) {
+			log_error(INTERNAL_ERROR
+				  "LVs must be set visible before clearing.");
+			return 0;
+		}
+		vg = lvl->lv->vg;
+	}
+
+	if (test_mode())
+		return 1;
 
 	/*
-	 * Rather than wiping lv->size, we can simply wipe the first 4KiB
-	 * to remove the superblock of any previous RAID devices.  It is much
-	 * quicker than wiping a potentially larger metadata device completely.
+	 * FIXME: only vg_[write|commit] if LVs are not already written
+	 * as visible in the LVM metadata (which is never the case yet).
 	 */
-	log_verbose("Clearing metadata area of %s.", display_lvname(lv));
-
-	dm_list_iterate_items(seg, &lv->segments) {
-		if (seg_type(seg, 0) != AREA_PV)
-			return_0;
-		if (seg->area_count != 1)
-			return_0;
-		if (!(pv = seg_pv(seg, 0)))
-			return_0;
-		if (!pv->pe_start) /* Be careful */
-			return_0;
-
-		offset = (pv->pe_start + seg_pe(seg, 0) * pv->pe_size) << 9;
-		cur_sectors = min(sectors, pv->pe_size);
-		sectors -= cur_sectors;
-		if (!dev_set(pv->dev, offset, cur_sectors << 9, DEV_IO_LOG, 0))
-			return_0;
-
-		if (!sectors)
-			break;
-	}
-
-	return 1;
-}
+	if (!vg || !vg_write(vg) || !vg_commit(vg))
+		return_0;
 
-/*
- * HM Helper:
- *
- * wipe all LVs first sector on @lv_list avoiding metadata commit/activation.
- *
- * Returns 1 on success or 0 on failure
- *
- * HM FIXME: share with lv_manip.c!
- */
-static int _clear_lvs(struct dm_list *lv_list)
-{
-	struct lv_list *lvl;
+	was_active = alloca(sz);
 
-	if (test_mode())
-		return 1;
+	dm_list_iterate_items(lvl, lv_list)
+		if (!(was_active[i++] = lv_is_active(lvl->lv))) {
+			lvl->lv->status |= LV_TEMPORARY;
+			if (!activate_lv(vg->cmd, lvl->lv)) {
+				log_error("Failed to activate localy %s for clearing.",
+					  display_lvname(lvl->lv));
+				r = 0;
+				goto out;
+			}
+			lvl->lv->status &= ~LV_TEMPORARY;
+		}
 
-	if (!dm_list_size(lv_list)) {
-		log_debug_metadata(INTERNAL_ERROR "Empty list of LVs given for clearing.");
-		return 1;
+	dm_list_iterate_items(lvl, lv_list) {
+		log_verbose("Clearing metadata area %s.", display_lvname(lvl->lv));
+		/*
+		 * Rather than wiping lv->size, we can simply
+		 * wipe the first sector to remove the superblock of any previous
+		 * RAID devices.  It is much quicker.
+		 */
+		if (!wipe_lv(lvl->lv, (struct wipe_params) { .do_zero = 1, .zero_sectors = 1 })) {
+			log_error("Failed to zero %s.", display_lvname(lvl->lv));
+			r = 0;
+			goto out;
+		}
 	}
-
-	/* Walk list and clear first sector of each LV */
+out:
+	/* TODO:   deactivation is only needed with clustered locking
+	 *         in normal case we should keep device active
+	 */
+	sz = 0;
 	dm_list_iterate_items(lvl, lv_list)
-		if (!_clear_lv(lvl->lv, 1))
-			return 0;
+		if ((i > sz) && !was_active[sz++] &&
+		    !deactivate_lv(vg->cmd, lvl->lv)) {
+			log_error("Failed to deactivate %s.", display_lvname(lvl->lv));
+			r = 0; /* continue deactivating */
+		}
 
-	return 1;
+	return r;
 }
 
 /* raid0* <-> raid10_near area reorder helper: swap 2 LV segment areas @a1 and @a2 */
@@ -5507,12 +5503,8 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 			if (segtype_is_striped_target(initial_segtype) &&
 			    !_convert_raid0_to_striped(lv, 0, &removal_lvs))
 				return_0;
-			if (!dm_list_empty(&removal_lvs)) {
-				if (!vg_write(lv->vg) || !vg_commit(lv->vg))
-					return_0;
-				if (!_eliminate_extracted_lvs(lv->vg, &removal_lvs)) /* Updates vg */
-					return_0;
-			}
+			if (!_eliminate_extracted_lvs(lv->vg, &removal_lvs)) /* Updates vg */
+				return_0;
 
 			return_0;
 		}



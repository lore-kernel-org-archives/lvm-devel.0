From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 May 2016 21:56:50 +0000 (UTC)
Subject: master - raid0: Standardise meta_areas checks before access.
Message-ID: <20160523215650.CCE1660659@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b896f7de1e6773ce6c17bf29a9123276695f4b60
Commit:        b896f7de1e6773ce6c17bf29a9123276695f4b60
Parent:        757f7d55082844a17372e4e83c6a95884c2550a8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon May 23 22:55:13 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon May 23 22:55:13 2016 +0100

raid0: Standardise meta_areas checks before access.

---
 lib/activate/dev_manager.c |    4 ++--
 lib/metadata/lv.c          |    4 ++--
 lib/metadata/lv_manip.c    |    8 ++++----
 lib/metadata/merge.c       |    2 +-
 lib/metadata/raid_manip.c  |    6 +++---
 lib/metadata/segtype.h     |    2 ++
 lib/raid/raid.c            |    6 +++---
 tools/lvchange.c           |    2 +-
 tools/vgsplit.c            |    6 +++---
 9 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 711074d..32295fb 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2207,7 +2207,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			    (!dm->track_pending_delete || !lv_is_cache(lv)) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
 				return_0;
-			if (seg_is_raid(seg) && seg->meta_areas && seg_metalv(seg, s) &&
+			if (seg_is_raid_with_meta(seg) && seg->meta_areas && seg_metalv(seg, s) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 0))
 				return_0;
 		}
@@ -2713,7 +2713,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		    !_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
 					  laopts, NULL))
 			return_0;
-		if (seg_is_raid(seg) && seg->meta_areas && seg_metalv(seg, s) &&
+		if (seg_is_raid_with_meta(seg) && seg->meta_areas && seg_metalv(seg, s) &&
 		    !_add_new_lv_to_dtree(dm, dtree, seg_metalv(seg, s),
 					  laopts, NULL))
 			return_0;
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index cb30e2d..0a531cf 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -53,7 +53,7 @@ static struct dm_list *_format_pvsegs(struct dm_pool *mem, const struct lv_segme
 		goto bad;
 	}
 
-	if (metadata_areas_only && (!seg_is_raid(seg) || lv_is_raid_metadata(seg->lv) || lv_is_raid_image(seg->lv)))
+	if (metadata_areas_only && (!seg_is_raid_with_meta(seg) || !seg->meta_areas || lv_is_raid_metadata(seg->lv) || lv_is_raid_image(seg->lv)))
 		goto out;
 
 	for (s = 0; s < seg->area_count; s++) {
@@ -1012,7 +1012,7 @@ int lv_raid_healthy(const struct logical_volume *lv)
 	/* Find out which sub-LV this is. */
 	for (s = 0; s < raid_seg->area_count; s++)
 		if ((lv_is_raid_image(lv) && (seg_lv(raid_seg, s) == lv)) ||
-		    (lv_is_raid_metadata(lv) && (seg_metalv(raid_seg,s) == lv)))
+		    (lv_is_raid_metadata(lv) && (seg_metalv(raid_seg, s) == lv)))
 			break;
 	if (s == raid_seg->area_count) {
 		log_error(INTERNAL_ERROR
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 82faf42..2e9a7a3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1019,7 +1019,7 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		}
 
 		/* Remove metadata area if image has been removed */
-		if (area_reduction == seg->area_len) {
+		if (seg->meta_areas && seg_metalv(seg, s) && (area_reduction == seg->area_len)) {
 			if (!lv_reduce(seg_metalv(seg, s),
 				       seg_metalv(seg, s)->le_count)) {
 				log_error("Failed to remove RAID meta-device %s",
@@ -3826,7 +3826,7 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		}
 
 		/* Extend metadata LVs only on initial creation */
-		if (seg_is_raid(seg) && !seg_is_raid0(seg) && !lv->le_count) {
+		if (seg_is_raid_with_meta(seg) && !lv->le_count) {
 			if (!seg->meta_areas) {
 				log_error("No meta_areas for RAID type");
 				return 0;
@@ -4190,12 +4190,12 @@ static int _for_each_sub_lv(struct logical_volume *lv, int skip_pools,
 				return_0;
 		}
 
-		if (!seg_is_raid(seg))
+		if (!seg_is_raid_with_meta(seg))
 			continue;
 
 		/* RAID has meta_areas */
 		for (s = 0; s < seg->area_count; s++) {
-			if (seg_metatype(seg, s) != AREA_LV)
+			if ((seg_metatype(seg, s) != AREA_LV) || !seg_metalv(seg, s))
 				continue;
 			if (!fn(seg_metalv(seg, s), data))
 				return_0;
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 4f730e0..62fc70a 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -441,7 +441,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				continue;
 			if (lv == seg_lv(seg, s))
 				seg_found++;
-			if (seg_is_raid(seg) && (lv == seg_metalv(seg, s)))
+			if (seg_is_raid_with_meta(seg) && (lv == seg_metalv(seg, s)))
 				seg_found++;
 		}
 		if (seg_is_replicator_dev(seg)) {
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 887b27f..739e144 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1871,8 +1871,8 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 	 */
 
 	for (s = 0; s < seg->area_count; s++) {
-		if (!lv_is_partial(seg_lv(seg, s)) &&
-		    !lv_is_partial(seg_metalv(seg, s)))
+		if (!lv_is_partial(seg_lv(seg, s)) && 
+		    (!seg->meta_areas || !seg_metalv(seg, s) || !lv_is_partial(seg_metalv(seg, s))))
 			continue;
 
 		log_debug("Replacing %s and %s segments with error target",
@@ -1882,7 +1882,7 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 				  display_lvname(seg_lv(seg, s)));
 			return 0;
 		}
-		if (!replace_lv_with_error_segment(seg_metalv(seg, s))) {
+		if (seg->meta_areas && !replace_lv_with_error_segment(seg_metalv(seg, s))) {
 			log_error("Failed to replace %s's extents with error target.",
 				  display_lvname(seg_metalv(seg, s)));
 			return 0;
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 3fc4266..f3b1510 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -119,6 +119,7 @@ struct dev_manager;
 #define segtype_is_raid6_nr(segtype)	((segtype)->flags & SEG_RAID6_NR ? 1 : 0)
 #define segtype_is_raid6_zr(segtype)	((segtype)->flags & SEG_RAID6_ZR ? 1 : 0)
 #define segtype_is_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
+#define segtype_is_raid_with_meta(segtype)	(segtype_is_raid(segtype) && !segtype_is_raid0(segtype))
 #define segtype_is_snapshot(segtype)	((segtype)->flags & SEG_SNAPSHOT ? 1 : 0)
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_thin(segtype)	((segtype)->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
@@ -148,6 +149,7 @@ struct dev_manager;
 #define seg_is_raid6_nr(seg)	segtype_is_raid6_nr((seg)->segtype)
 #define seg_is_raid6_nc(seg)	segtype_is_raid6_nc((seg)->segtype)
 #define seg_is_raid10(seg)	segtype_is_raid10((seg)->segtype)
+#define seg_is_raid_with_meta(seg)	segtype_is_raid_with_meta((seg)->segtype)
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
 #define seg_is_snapshot(seg)	segtype_is_snapshot((seg)->segtype)
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 4987f91..e299e17 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -33,10 +33,10 @@ static void _raid_display(const struct lv_segment *seg)
 		display_stripe(seg, s, "    ");
 	}
 
-	if (seg->meta_areas) {
+	if (seg->meta_areas)
 		for (s = 0; s < seg->area_count; ++s)
-			log_print("  Raid Metadata LV%2d\t%s", s, seg_metalv(seg, s)->name);
-	}
+			if (seg_metalv(seg, s))
+				log_print("  Raid Metadata LV%2d\t%s", s, seg_metalv(seg, s)->name);
 
 	log_print(" ");
 }
diff --git a/tools/lvchange.c b/tools/lvchange.c
index c37a597..1ce19c5 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -243,7 +243,7 @@ static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 	if (!(lvl = dm_pool_alloc(seg->lv->vg->vgmem, sizeof(*lvl) * num_meta_lvs)))
 		return_0;
 
-	if (seg_is_raid(seg)) {
+	if (seg_is_raid_with_meta(seg)) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (!seg_metalv(seg, s))
 				return_0; /* Trap this future possibility */
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 8335570..e7c6e19 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -253,11 +253,11 @@ static int _move_raid(struct volume_group *vg_from,
 		for (s = 0; s < seg->area_count; s++) {
 			if (_lv_is_in_vg(vg_to, seg_lv(seg, s)))
 				seg_in++;
-			if (_lv_is_in_vg(vg_to, seg_metalv(seg, s)))
-				seg_in++;
+			if (seg->meta_areas && seg_metalv(seg, s) && _lv_is_in_vg(vg_to, seg_metalv(seg, s)))
+				seg_in++;	/* FIXME Inadequate - must count separately */
 		}
 
-		if (seg_in && seg_in != (seg->area_count * 2)) {
+		if (seg_in && seg_in != (seg->area_count * (seg->meta_areas ? 2 : 1))) {
 			log_error("Can't split RAID %s between "
 				  "two Volume Groups", lv->name);
 			return 0;



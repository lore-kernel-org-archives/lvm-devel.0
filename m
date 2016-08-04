From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  4 Aug 2016 20:16:41 +0000 (UTC)
Subject: master - raid0: Validate presence of raid0 meta_areas more tightly.
Message-ID: <20160804201641.26A0B60553@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1b0b134ecd55fad004d56301c52b32234db3c9a
Commit:        b1b0b134ecd55fad004d56301c52b32234db3c9a
Parent:        d1a25fe597569fd15fd934f639d41d991d767219
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Aug 4 21:13:36 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Aug 4 21:15:07 2016 +0100

raid0: Validate presence of raid0 meta_areas more tightly.

---
 lib/metadata/merge.c      |    7 ++++++-
 lib/metadata/raid_manip.c |    9 ++++++---
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 05cef17..ce33e28 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -97,6 +97,9 @@ static void _check_raid0_seg(struct lv_segment *seg, int *error_count)
 	if (seg_is_raid0_meta(seg) &&
 	    !seg->meta_areas)
 		raid_seg_error("no meta areas");
+	if (!seg_is_raid0_meta(seg) &&
+	    seg->meta_areas)
+		raid_seg_error("meta areas");
 	if (!seg->stripe_size)
 		raid_seg_error("zero stripe size");
 	if (!is_power_of_2(seg->stripe_size))
@@ -289,8 +292,10 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 	/* Check for any MetaLV flaws like non-existing ones or size variations */
 	if (seg->meta_areas)
 		for (area_len = s = 0; s < seg->area_count; s++) {
-			if (seg_metatype(seg, s) != AREA_LV)
+			if (seg_metatype(seg, s) != AREA_LV) {
 				raid_seg_error("no MetaLV");
+				continue;
+			}
 			if (!lv_is_raid_metadata(seg_metalv(seg, s)))
 				raid_seg_error("MetaLV without RAID metadata flag");
 			if (area_len &&
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 1c03d37..109cb2e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1701,7 +1701,8 @@ static int _extract_image_component_list(struct lv_segment *seg,
  */
 static int _alloc_rmeta_devs_for_lv(struct logical_volume *lv,
 				    struct dm_list *meta_lvs,
-				    struct dm_list *allocate_pvs)
+				    struct dm_list *allocate_pvs,
+				    struct lv_segment_area **seg_meta_areas)
 {
 	uint32_t s;
 	struct lv_list *lvl_array;
@@ -1710,7 +1711,7 @@ static int _alloc_rmeta_devs_for_lv(struct logical_volume *lv,
 
 	dm_list_init(&data_lvs);
 
-	if (!(seg->meta_areas = dm_pool_zalloc(lv->vg->vgmem, seg->area_count * sizeof(*seg->meta_areas))))
+	if (!(*seg_meta_areas = dm_pool_zalloc(lv->vg->vgmem, seg->area_count * sizeof(*seg->meta_areas))))
 		return 0;
 
 	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, seg->area_count * sizeof(*lvl_array))))
@@ -1736,11 +1737,12 @@ static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv, struct dm
 {
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list meta_lvs;
+	struct lv_segment_area *seg_meta_areas;
 
 	dm_list_init(&meta_lvs);
 
 	log_debug_metadata("Allocating metadata LVs for %s", display_lvname(lv));
-	if (!_alloc_rmeta_devs_for_lv(lv, &meta_lvs, allocate_pvs)) {
+	if (!_alloc_rmeta_devs_for_lv(lv, &meta_lvs, allocate_pvs, &seg_meta_areas)) {
 		log_error("Failed to allocate metadata LVs for %s", display_lvname(lv));
 		return_0;
 	}
@@ -1753,6 +1755,7 @@ static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv, struct dm
 	}
 
 	/* Set segment areas for metadata sub_lvs */
+	seg->meta_areas = seg_meta_areas;
 	log_debug_metadata("Adding newly allocated metadata LVs to %s", display_lvname(lv));
 	if (!_add_image_component_list(seg, 1, 0, &meta_lvs, 0)) {
 		log_error("Failed to add newly allocated metadata LVs to %s", display_lvname(lv));



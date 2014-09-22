From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:37:53 +0000 (UTC)
Subject: dev-dct-process-latest - raid: use _generate_raid_name
Message-ID: <20140922153753.3251360EE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c10c16cc3531cf613152675b732a50b1339e62c9
Commit:        c10c16cc3531cf613152675b732a50b1339e62c9
Parent:        2db0312455260cda6f45ee8d3814a00f3f297af0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 12 11:39:48 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:29 2014 +0200

raid: use _generate_raid_name

Use new function to get implicit name validation
(so we do not exit with internal error on metadata validation).
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   56 ++++++++-------------------------------------
 2 files changed, 11 insertions(+), 46 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a84ef4b..ebbc76f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Properly validate raid leg names.
   Archive metadata before starting their modification in raid target.
   Add missing vg_revert in suspend_lv() error path in raid target.
   Add missing backup of lvm2 metadata after some raid modifications.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index bff6e59..6edd56d 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -590,21 +590,14 @@ static int _raid_add_images(struct logical_volume *lv,
 	 * commits the LVM metadata before clearing the LVs.
 	 */
 	if (seg_is_linear(seg)) {
-		char *name;
-		size_t len;
 		struct dm_list *l;
 		struct lv_list *lvl_tmp;
 
 		dm_list_iterate(l, &data_lvs) {
 			if (l == dm_list_last(&data_lvs)) {
 				lvl = dm_list_item(l, struct lv_list);
-				len = strlen(lv->name) + sizeof("_rimage_XXX");
-				if (!(name = dm_pool_alloc(lv->vg->vgmem, len))) {
-					log_error("Failed to allocate rimage name.");
-					return 0;
-				}
-				sprintf(name, "%s_rimage_%u", lv->name, count);
-				lvl->lv->name = name;
+				if (!(lvl->lv->name = _generate_raid_name(lv, "rimage", count)))
+					return_0;
 				continue;
 			}
 			lvl = dm_list_item(l, struct lv_list);
@@ -778,9 +771,6 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
 				     struct logical_volume **extracted_rmeta,
 				     struct logical_volume **extracted_rimage)
 {
-	int len;
-	char *tmp_name;
-	struct volume_group *vg = seg->lv->vg;
 	struct logical_volume *data_lv = seg_lv(seg, idx);
 	struct logical_volume *meta_lv = seg_metalv(seg, idx);
 
@@ -800,19 +790,11 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
 	seg_type(seg, idx) = AREA_UNASSIGNED;
 	seg_metatype(seg, idx) = AREA_UNASSIGNED;
 
-	len = strlen(meta_lv->name) + strlen("_extracted") + 1;
-	tmp_name = dm_pool_alloc(vg->vgmem, len);
-	if (!tmp_name)
+	if (!(data_lv->name = _generate_raid_name(data_lv, "_extracted", -1)))
 		return_0;
-	sprintf(tmp_name, "%s_extracted", meta_lv->name);
-	meta_lv->name = tmp_name;
 
-	len = strlen(data_lv->name) + strlen("_extracted") + 1;
-	tmp_name = dm_pool_alloc(vg->vgmem, len);
-	if (!tmp_name)
+	if (!(meta_lv->name = _generate_raid_name(meta_lv, "_extracted", -1)))
 		return_0;
-	sprintf(tmp_name, "%s_extracted", data_lv->name);
-	data_lv->name = tmp_name;
 
 	*extracted_rmeta = meta_lv;
 	*extracted_rimage = data_lv;
@@ -1335,6 +1317,7 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	struct lv_list lvl_array[seg->area_count], *lvl;
 	struct dm_list meta_lvs;
 	struct lv_segment_area *meta_areas;
+	char *new_name;
 
 	dm_list_init(&meta_lvs);
 
@@ -1399,18 +1382,9 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 		s++;
 	}
 
-	for (s = 0; s < seg->area_count; s++) {
-		char *new_name;
-
-		new_name = dm_pool_zalloc(lv->vg->vgmem,
-					  strlen(lv->name) +
-					  strlen("_rimage_XXn"));
-		if (!new_name) {
-			log_error("Failed to rename mirror images");
-			return 0;
-		}
-
-		sprintf(new_name, "%s_rimage_%u", lv->name, s);
+	for (s = 0; s < seg->area_count; ++s) {
+		if (!(new_name = _generate_raid_name(seg_lv(seg, s), "rimage", s)))
+			return_0;
 		log_debug_metadata("Renaming %s to %s", seg_lv(seg, s)->name, new_name);
 		seg_lv(seg, s)->name = new_name;
 		seg_lv(seg, s)->status &= ~MIRROR_IMAGE;
@@ -1737,12 +1711,7 @@ try_again:
 			lvl = dm_list_item(dm_list_first(&new_meta_lvs),
 					   struct lv_list);
 			dm_list_del(&lvl->list);
-			tmp_names[s] = dm_pool_alloc(lv->vg->vgmem,
-						    strlen(lvl->lv->name) + 1);
-			if (!tmp_names[s])
-				return_0;
-			if (dm_snprintf(tmp_names[s], strlen(lvl->lv->name) + 1,
-					"%s_rmeta_%u", lv->name, s) < 0)
+			if (!(tmp_names[s] = _generate_raid_name(lv, "rmeta", s)))
 				return_0;
 			if (!set_lv_segment_area_lv(raid_seg, s, lvl->lv, 0,
 						    lvl->lv->status)) {
@@ -1756,12 +1725,7 @@ try_again:
 			lvl = dm_list_item(dm_list_first(&new_data_lvs),
 					   struct lv_list);
 			dm_list_del(&lvl->list);
-			tmp_names[sd] = dm_pool_alloc(lv->vg->vgmem,
-						     strlen(lvl->lv->name) + 1);
-			if (!tmp_names[sd])
-				return_0;
-			if (dm_snprintf(tmp_names[sd], strlen(lvl->lv->name) + 1,
-					"%s_rimage_%u", lv->name, s) < 0)
+			if (!(tmp_names[sd] = _generate_raid_name(lv, "rimage", s)))
 				return_0;
 			if (!set_lv_segment_area_lv(raid_seg, s, lvl->lv, 0,
 						    lvl->lv->status)) {



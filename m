From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  6 Aug 2016 23:57:07 +0000 (UTC)
Subject: master - raid: Add workaround to prepare for raid4 conversions.
Message-ID: <20160806235708.0057660DBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f236c3353cbcac799f755870251da7a5d576c41
Commit:        6f236c3353cbcac799f755870251da7a5d576c41
Parent:        ba0c26a078119f5a7d551e047189f23bdd76e2be
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Aug 7 00:07:06 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Aug 7 00:07:06 2016 +0100

raid: Add workaround to prepare for raid4 conversions.

---
 lib/metadata/raid_manip.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f5a800b..840c831 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -571,7 +571,7 @@ static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
 static int _alloc_image_components(struct logical_volume *lv,
 				   struct dm_list *pvs, uint32_t count,
 				   struct dm_list *new_meta_lvs,
-				   struct dm_list *new_data_lvs)
+				   struct dm_list *new_data_lvs, int use_existing_area_len)
 {
 	uint32_t s;
 	uint32_t region_size;
@@ -607,7 +607,11 @@ static int _alloc_image_components(struct logical_volume *lv,
 	 * individual devies, we must specify how large the individual device
 	 * is along with the number we want ('count').
 	 */
-	if (segtype_is_raid10(segtype)) {
+	if (use_existing_area_len)
+		/* FIXME Workaround for segment type changes where new segtype is unknown here */
+		/* Only for raid0* to raid4 */
+		extents = (lv->le_count / seg->area_count) * count;
+	else if (segtype_is_raid10(segtype)) {
 		if (seg->area_count < 2) {
 			log_error(INTERNAL_ERROR "LV %s needs@least 2 areas.",
 				  display_lvname(lv));
@@ -715,7 +719,8 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 }
 
 static int _raid_add_images_without_commit(struct logical_volume *lv,
-					   uint32_t new_count, struct dm_list *pvs)
+					   uint32_t new_count, struct dm_list *pvs,
+					   int use_existing_area_len)
 {
 	uint32_t s;
 	uint32_t old_count = lv_raid_image_count(lv);
@@ -767,7 +772,7 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!_alloc_image_components(lv, pvs, count, &meta_lvs, &data_lvs))
+	if (!_alloc_image_components(lv, pvs, count, &meta_lvs, &data_lvs, use_existing_area_len))
 		return_0;
 
 	/*
@@ -910,13 +915,13 @@ fail:
 
 static int _raid_add_images(struct logical_volume *lv,
 			    uint32_t new_count, struct dm_list *pvs,
-			    int commit)
+			    int commit, int use_existing_area_len)
 {
 	int rebuild_flag_cleared = 0;
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t s;
 
-	if (!_raid_add_images_without_commit(lv, new_count, pvs))
+	if (!_raid_add_images_without_commit(lv, new_count, pvs, use_existing_area_len))
 		return_0;
 
 	if (!commit)
@@ -1235,7 +1240,7 @@ static int _raid_remove_images(struct logical_volume *lv,
  */
 static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
 				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs,
-				       int commit)
+				       int commit, int use_existing_area_len)
 {
 	uint32_t old_count = lv_raid_image_count(lv);
 
@@ -1258,13 +1263,13 @@ static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_c
 	if (old_count > new_count)
 		return _raid_remove_images(lv, new_count, allocate_pvs, removal_lvs, commit);
 
-	return _raid_add_images(lv, new_count, allocate_pvs, commit);
+	return _raid_add_images(lv, new_count, allocate_pvs, commit, use_existing_area_len);
 }
 
 int lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
 			       struct dm_list *allocate_pvs)
 {
-	return _lv_raid_change_image_count(lv, new_count, allocate_pvs, NULL, 1);
+	return _lv_raid_change_image_count(lv, new_count, allocate_pvs, NULL, 1, 0);
 }
 
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
@@ -2204,7 +2209,7 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 
 	/* Allocate empty rimage components */
 	dm_list_init(&data_lvs);
-	if (!_alloc_image_components(lv, NULL, area_count, NULL, &data_lvs)) {
+	if (!_alloc_image_components(lv, NULL, area_count, NULL, &data_lvs, 0)) {
 		log_error("Failed to allocate empty image components for raid0 LV %s.",
 			  display_lvname(lv));
 		return NULL;
@@ -3050,7 +3055,7 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 	 */
 try_again:
 	if (!_alloc_image_components(lv, allocate_pvs, match_count,
-				     &new_meta_lvs, &new_data_lvs)) {
+				     &new_meta_lvs, &new_data_lvs, 0)) {
 		if (!lv_is_partial(lv)) {
 			log_error("LV %s in not partial.", display_lvname(lv));
 			return 0;



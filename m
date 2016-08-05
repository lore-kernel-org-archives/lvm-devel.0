From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  5 Aug 2016 13:18:21 +0000 (UTC)
Subject: master - raid: Turn lv_raid_change_image_count into wrapper
Message-ID: <20160805131821.C7BE661B98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7482ff93b8316767ad128b43fcf5fae8725f8057
Commit:        7482ff93b8316767ad128b43fcf5fae8725f8057
Parent:        b66fa91c46f88029eb730f07524d2c09a4ded559
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 5 14:10:41 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 5 14:17:54 2016 +0100

raid: Turn lv_raid_change_image_count into wrapper

Eventually the separate entry point will disappear.
---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/raid_manip.c        |   24 ++++++++++++++----------
 2 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 531fa03..e61802d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1190,7 +1190,7 @@ struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 int lv_is_raid_with_tracking(const struct logical_volume *lv);
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
 int lv_raid_change_image_count(struct logical_volume *lv,
-			       uint32_t new_count, struct dm_list *pvs);
+			       uint32_t new_count, struct dm_list *allocate_pvs);
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs);
 int lv_raid_split_and_track(struct logical_volume *lv,
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 109cb2e..2cc48e1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1171,21 +1171,18 @@ static int _raid_remove_images(struct logical_volume *lv,
 }
 
 /*
- * lv_raid_change_image_count
- * @lv
- * @new_count: The absolute count of images (e.g. '2' for a 2-way mirror)
- * @pvs: The list of PVs that are candidates for removal (or empty list)
+ * _lv_raid_change_image_count
+ * new_count: The absolute count of images (e.g. '2' for a 2-way mirror)
+ * allocate_pvs: The list of PVs that are candidates for removal (or empty list)
  *
  * RAID arrays have 'images' which are composed of two parts, they are:
  *    - 'rimage': The data/parity holding portion
  *    - 'rmeta' : The metadata holding portion (i.e. superblock/bitmap area)
  * This function adds or removes _both_ portions of the image and commits
  * the results.
- *
- * Returns: 1 on success, 0 on failure
  */
-int lv_raid_change_image_count(struct logical_volume *lv,
-			       uint32_t new_count, struct dm_list *pvs)
+static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
+				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs)
 {
 	uint32_t old_count = lv_raid_image_count(lv);
 
@@ -1206,9 +1203,15 @@ int lv_raid_change_image_count(struct logical_volume *lv,
 	}
 
 	if (old_count > new_count)
-		return _raid_remove_images(lv, new_count, pvs);
+		return _raid_remove_images(lv, new_count, allocate_pvs);
 
-	return _raid_add_images(lv, new_count, pvs);
+	return _raid_add_images(lv, new_count, allocate_pvs);
+}
+
+int lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
+			       struct dm_list *allocate_pvs)
+{
+	return _lv_raid_change_image_count(lv, new_count, allocate_pvs, NULL);
 }
 
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
@@ -1543,6 +1546,7 @@ static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
 
 	return 1;
 }
+
 /* Add new @lvs to @lv at @area_offset */
 static int _add_image_component_list(struct lv_segment *seg, int delete_from_list,
 				     uint64_t lv_flags, struct dm_list *lvs, uint32_t area_offset)



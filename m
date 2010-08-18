From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 18 Aug 2010 09:51:52 -0400
Subject: [PATCH 01/11] Add vg_mda_size and vg_mda_free functions.
In-Reply-To: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1282139522-31240-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add supporting functions to get vg_mda_size and vg_mda_free fields.
Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata.h |    4 ++++
 lib/report/report.c     |   37 ++++---------------------------------
 3 files changed, 50 insertions(+), 33 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6cd7793..ba532aa 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1217,6 +1217,48 @@ int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies)
 	return 1;
 }
 
+uint64_t find_min_mda_size(struct dm_list *mdas)
+{
+	uint64_t min_mda_size = UINT64_MAX, mda_size;
+	struct metadata_area *mda;
+
+	dm_list_iterate_items(mda, mdas) {
+		if (!mda->ops->mda_total_sectors)
+			continue;
+		mda_size = mda->ops->mda_total_sectors(mda);
+		if (mda_size < min_mda_size)
+			min_mda_size = mda_size;
+	}
+
+	if (min_mda_size == UINT64_MAX)
+		min_mda_size = UINT64_C(0);
+
+	return min_mda_size;
+}
+
+uint64_t vg_mda_size(const struct volume_group *vg)
+{
+	return find_min_mda_size(&vg->fid->metadata_areas_in_use);
+}
+
+uint64_t vg_mda_free(const struct volume_group *vg)
+{
+	uint64_t freespace = UINT64_MAX, mda_free;
+	struct metadata_area *mda;
+
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		if (!mda->ops->mda_free_sectors)
+			continue;
+		mda_free = mda->ops->mda_free_sectors(mda);
+		if (mda_free < freespace)
+			freespace = mda_free;
+	}
+
+	if (freespace == UINT64_MAX)
+		freespace = UINT64_C(0);
+	return freespace;
+}
+
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 25399c7..3d074dc 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -416,4 +416,8 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 int vg_mark_partial_lvs(struct volume_group *vg);
 int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 
+uint64_t find_min_mda_size(struct dm_list *mdas);
+uint64_t vg_mda_size(const struct volume_group *vg);
+uint64_t vg_mda_free(const struct volume_group *vg);
+
 #endif
diff --git a/lib/report/report.c b/lib/report/report.c
index 718b28e..4f7cd0c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -958,25 +958,6 @@ static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
-static uint64_t _find_min_mda_size(struct dm_list *mdas)
-{
-	uint64_t min_mda_size = UINT64_MAX, mda_size;
-	struct metadata_area *mda;
-
-	dm_list_iterate_items(mda, mdas) {
-		if (!mda->ops->mda_total_sectors)
-			continue;
-		mda_size = mda->ops->mda_total_sectors(mda);
-		if (mda_size < min_mda_size)
-			min_mda_size = mda_size;
-	}
-
-	if (min_mda_size == UINT64_MAX)
-		min_mda_size = UINT64_C(0);
-
-	return min_mda_size;
-}
-
 static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
@@ -987,7 +968,7 @@ static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	/* PVs could have 2 mdas of different sizes (rounding effect) */
 	if ((info = info_from_pvid(pvid, 0)))
-		min_mda_size = _find_min_mda_size(&info->mdas);
+		min_mda_size = find_min_mda_size(&info->mdas);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
@@ -999,7 +980,7 @@ static int _vgmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t min_mda_size;
 
-	min_mda_size = _find_min_mda_size(&vg->fid->metadata_areas_in_use);
+	min_mda_size = vg_mda_size(vg);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
@@ -1009,19 +990,9 @@ static int _vgmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint64_t freespace = UINT64_MAX, mda_free;
-	struct metadata_area *mda;
-
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
-		if (!mda->ops->mda_free_sectors)
-			continue;
-		mda_free = mda->ops->mda_free_sectors(mda);
-		if (mda_free < freespace)
-			freespace = mda_free;
-	}
+	uint64_t freespace;
 
-	if (freespace == UINT64_MAX)
-		freespace = UINT64_C(0);
+	freespace = vg_mda_free(vg);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
-- 
1.7.2.1



From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:36:07 -0400
Subject: [PATCH 15/19] Add pv_mda_size, pv_mda_free, and pv_used functions.
In-Reply-To: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284564971-26060-16-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata.h |    3 +++
 lib/report/report.c     |   34 +++++++++-------------------------
 3 files changed, 56 insertions(+), 25 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index de878c3..62dbfde 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1277,6 +1277,39 @@ uint64_t vg_mda_free(const struct volume_group *vg)
 	return freespace;
 }
 
+uint64_t pv_mda_size(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+	uint64_t min_mda_size = 0;
+	const char *pvid = (const char *)(&pv->id.uuid);
+
+	/* PVs could have 2 mdas of different sizes (rounding effect) */
+	if ((info = info_from_pvid(pvid, 0)))
+		min_mda_size = find_min_mda_size(&info->mdas);
+	return min_mda_size;
+}
+
+uint64_t pv_mda_free(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+	uint64_t freespace = UINT64_MAX, mda_free;
+	const char *pvid = (const char *)&pv->id.uuid;
+	struct metadata_area *mda;
+
+	if ((info = info_from_pvid(pvid, 0)))
+		dm_list_iterate_items(mda, &info->mdas) {
+			if (!mda->ops->mda_free_sectors)
+				continue;
+			mda_free = mda->ops->mda_free_sectors(mda);
+			if (mda_free < freespace)
+				freespace = mda_free;
+		}
+
+	if (freespace == UINT64_MAX)
+		freespace = UINT64_C(0);
+	return freespace;
+}
+
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;
@@ -4205,6 +4238,17 @@ uint64_t pv_free(const struct physical_volume *pv)
 	return freespace;
 }
 
+uint64_t pv_used(const struct physical_volume *pv)
+{
+	uint64_t used;
+
+	if (!pv->pe_count)
+		used = 0LL;
+	else
+		used = (uint64_t) pv->pe_alloc_count * pv->pe_size;
+	return used;
+}
+
 uint64_t pv_status(const struct physical_volume *pv)
 {
 	return pv_field(pv, status);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 47fcd08..2a40d8a 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -419,6 +419,9 @@ int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 uint64_t find_min_mda_size(struct dm_list *mdas);
 uint64_t vg_mda_size(const struct volume_group *vg);
 uint64_t vg_mda_free(const struct volume_group *vg);
+uint64_t pv_mda_size(const struct physical_volume *pv);
+uint64_t pv_mda_free(const struct physical_volume *pv);
+uint64_t pv_used(const struct physical_volume *pv);
 char *pv_attr(struct dm_pool *mem, const struct physical_volume *pv);
 char *vg_attr(struct dm_pool *mem, const struct volume_group *vg);
 char *lv_attr(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/report.c b/lib/report/report.c
index ed53fac..4861f95 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -597,10 +597,7 @@ static int _pvused_disp(struct dm_report *rh, struct dm_pool *mem,
 	    (const struct physical_volume *) data;
 	uint64_t used;
 
-	if (!pv->pe_count)
-		used = 0LL;
-	else
-		used = (uint64_t) pv->pe_alloc_count * pv->pe_size;
+	used = pv_used(pv);
 
 	return _size64_disp(rh, mem, field, &used, private);
 }
@@ -754,22 +751,11 @@ static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
-	struct lvmcache_info *info;
-	uint64_t freespace = UINT64_MAX, mda_free;
-	const char *pvid = (const char *)(&((const struct id *) data)->uuid);
-	struct metadata_area *mda;
-
-	if ((info = info_from_pvid(pvid, 0)))
-		dm_list_iterate_items(mda, &info->mdas) {
-			if (!mda->ops->mda_free_sectors)
-				continue;
-			mda_free = mda->ops->mda_free_sectors(mda);
-			if (mda_free < freespace)
-				freespace = mda_free;
-		}
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
+	uint64_t freespace;
 
-	if (freespace == UINT64_MAX)
-		freespace = UINT64_C(0);
+	freespace = pv_mda_free(pv);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
@@ -778,13 +764,11 @@ static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
-	struct lvmcache_info *info;
-	uint64_t min_mda_size = 0;
-	const char *pvid = (const char *)(&((const struct id *) data)->uuid);
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
+	uint64_t min_mda_size;
 
-	/* PVs could have 2 mdas of different sizes (rounding effect) */
-	if ((info = info_from_pvid(pvid, 0)))
-		min_mda_size = find_min_mda_size(&info->mdas);
+	min_mda_size = pv_mda_size(pv);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
-- 
1.7.2.1



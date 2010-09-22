From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:27 -0400
Subject: [PATCH 15/20] Add pv_mda_size, pv_mda_free, and pv_used functions, call from 'disp' functions.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-16-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/pv.c   |   44 ++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/pv.h   |    3 +++
 lib/report/report.c |   34 +++++++++-------------------------
 3 files changed, 56 insertions(+), 25 deletions(-)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 5d29693..8b4dbf5 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -187,6 +187,50 @@ char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
 	return repstr;
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
 unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignored)
 {
 	struct lvmcache_info *info;
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 14133c7..295f811 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -67,6 +67,9 @@ uint32_t pv_pe_size(const struct physical_volume *pv);
 uint64_t pv_pe_start(const struct physical_volume *pv);
 uint32_t pv_pe_count(const struct physical_volume *pv);
 uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
+uint64_t pv_mda_size(const struct physical_volume *pv);
+uint64_t pv_mda_free(const struct physical_volume *pv);
+uint64_t pv_used(const struct physical_volume *pv);
 uint32_t pv_mda_count(const struct physical_volume *pv);
 uint32_t pv_mda_used_count(const struct physical_volume *pv);
 unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored);
diff --git a/lib/report/report.c b/lib/report/report.c
index cac4f8b..95f4550 100644
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
1.7.2.2



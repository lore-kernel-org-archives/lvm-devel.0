From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:26 -0400
Subject: [PATCH 13/30] Update pvmdasize_disp and vgmdasize_disp to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-13-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-6-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-7-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-8-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-9-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-10-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-11-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-12-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-13-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-14-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.
We must move both pvmdasize and vgmdasize at the same time since they both
use the _find_min_mda_size() code.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |   33 +++++++++++++++++++++++++++++----
 lib/report/report.c          |   30 ++++--------------------------
 2 files changed, 33 insertions(+), 30 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index 8f8b5d7..726d2b6 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -392,14 +392,40 @@ int lvm_pv_set_mda_free(pv_t *pv, const uint64_t value)
 	/* FIXME: implement function body */
 	return -1;
 }
+
+static uint64_t _find_min_mda_size(struct dm_list *mdas)
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
 /**
  * lvm_pv_{get|set}_mda_size
  * mda_size - Size of smallest metadata area on this device in current units.
  */
 uint64_t lvm_pv_get_mda_size(const pv_t *pv)
 {
-	/* FIXME: implement function body */
-	return 0;
+	struct lvmcache_info *info;
+	uint64_t min_mda_size = 0;
+	const char *pvid = (const char *)pv->id.uuid;
+
+	/* PVs could have 2 mdas of different sizes (rounding effect) */
+	if ((info = info_from_pvid(pvid, 0)))
+		min_mda_size = _find_min_mda_size(&info->mdas);
+	return min_mda_size;
 }
 int lvm_pv_set_mda_size(pv_t *pv, const uint64_t value)
 {
@@ -792,8 +818,7 @@ int lvm_vg_set_mda_free(vg_t *vg, const uint64_t value)
  */
 uint64_t lvm_vg_get_mda_size(const vg_t *vg)
 {
-	/* FIXME: implement function body */
-	return 0;
+	return _find_min_mda_size(&vg->fid->metadata_areas);;
 }
 int lvm_vg_set_mda_size(vg_t *vg, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index 1fa7aa6..da694a5 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -915,36 +915,14 @@ static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
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
 {
-	struct lvmcache_info *info;
-	uint64_t min_mda_size = 0;
-	const char *pvid = (const char *)(&((struct id *) data)->uuid);
+	const struct physical_volume *pv = (const struct physical_volume *) data;
+	uint64_t min_mda_size;
 
-	/* PVs could have 2 mdas of different sizes (rounding effect) */
-	if ((info = info_from_pvid(pvid, 0)))
-		min_mda_size = _find_min_mda_size(&info->mdas);
+	min_mda_size = lvm_pv_get_mda_size(pv);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
@@ -956,7 +934,7 @@ static int _vgmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t min_mda_size;
 
-	min_mda_size = _find_min_mda_size(&vg->fid->metadata_areas);
+	min_mda_size = lvm_vg_get_mda_size(vg);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
-- 
1.6.0.6



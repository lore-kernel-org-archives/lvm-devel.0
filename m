From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:16 -0400
Subject: [PATCH 04/20] Add {pv|vg|lv}_attr_dup() functions and refactor 'disp' functions.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move the creating of the 'attr' strings into a common function so
they can be called from the 'disp' functions as well as the new
'get' property functions.
Add "_dup" suffix to indicate memory is allocated.
Refactor pvstatus_disp to take pv argument and call pv_attr_dup().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c       |  118 ++++++++++++++++++++++++++++++++
 lib/metadata/lv.h       |    1 +
 lib/metadata/metadata.c |   16 ++++
 lib/metadata/metadata.h |    1 +
 lib/metadata/pv.c       |   21 ++++++
 lib/metadata/pv.h       |    1 +
 lib/metadata/vg.c       |   37 ++++++++++
 lib/metadata/vg.h       |    1 +
 lib/report/columns.h    |    2 +-
 lib/report/report.c     |  174 ++---------------------------------------------
 10 files changed, 202 insertions(+), 170 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 49f0b3d..0c01c73 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -14,8 +14,126 @@
 
 #include "lib.h"
 #include "metadata.h"
+#include "activate.h"
 
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
 }
+
+static int _lv_mimage_in_sync(const struct logical_volume *lv)
+{
+	float percent;
+	percent_range_t percent_range;
+	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
+
+	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
+		return_0;
+
+	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent,
+			       &percent_range, NULL))
+		return_0;
+
+	return (percent_range == PERCENT_100) ? 1 : 0;
+}
+
+char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	float snap_percent;
+	percent_range_t percent_range;
+	struct lvinfo info;
+	char *repstr;
+
+	if (!(repstr = dm_pool_zalloc(mem, 7))) {
+		log_error("dm_pool_alloc failed");
+		return 0;
+	}
+
+	/* Blank if this is a "free space" LV. */
+	if (!*lv->name)
+		goto out;
+
+	if (lv->status & PVMOVE)
+		repstr[0] = 'p';
+	else if (lv->status & CONVERTING)
+		repstr[0] = 'c';
+	else if (lv->status & VIRTUAL)
+		repstr[0] = 'v';
+	/* Origin takes precedence over Mirror */
+	else if (lv_is_origin(lv)) {
+		if (lv_is_merging_origin(lv))
+			repstr[0] = 'O';
+		else
+			repstr[0] = 'o';
+	}
+	else if (lv->status & MIRRORED) {
+		if (lv->status & MIRROR_NOTSYNCED)
+			repstr[0] = 'M';
+		else
+			repstr[0] = 'm';
+	}else if (lv->status & MIRROR_IMAGE)
+		if (_lv_mimage_in_sync(lv))
+			repstr[0] = 'i';
+		else
+			repstr[0] = 'I';
+	else if (lv->status & MIRROR_LOG)
+		repstr[0] = 'l';
+	else if (lv_is_cow(lv)) {
+		if (lv_is_merging_cow(lv))
+			repstr[0] = 'S';
+		else
+			repstr[0] = 's';
+	} else
+		repstr[0] = '-';
+
+	if (lv->status & PVMOVE)
+		repstr[1] = '-';
+	else if (lv->status & LVM_WRITE)
+		repstr[1] = 'w';
+	else if (lv->status & LVM_READ)
+		repstr[1] = 'r';
+	else
+		repstr[1] = '-';
+
+	repstr[2] = alloc_policy_char(lv->alloc);
+
+	if (lv->status & LOCKED)
+		repstr[2] = toupper(repstr[2]);
+
+	if (lv->status & FIXED_MINOR)
+		repstr[3] = 'm';	/* Fixed Minor */
+	else
+		repstr[3] = '-';
+
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
+		if (info.suspended)
+			repstr[4] = 's';	/* Suspended */
+		else if (info.live_table)
+			repstr[4] = 'a';	/* Active */
+		else if (info.inactive_table)
+			repstr[4] = 'i';	/* Inactive with table */
+		else
+			repstr[4] = 'd';	/* Inactive without table */
+
+		/* Snapshot dropped? */
+		if (info.live_table && lv_is_cow(lv) &&
+		    (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
+		     percent_range == PERCENT_INVALID)) {
+			repstr[0] = toupper(repstr[0]);
+			if (info.suspended)
+				repstr[4] = 'S'; /* Susp Inv snapshot */
+			else
+				repstr[4] = 'I'; /* Invalid snapshot */
+		}
+
+		if (info.open_count)
+			repstr[5] = 'o';	/* Open */
+		else
+			repstr[5] = '-';
+	} else {
+		repstr[4] = '-';
+		repstr[5] = '-';
+	}
+out:
+	return repstr;
+}
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index d3b0d82..4cf06b2 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -48,5 +48,6 @@ struct logical_volume {
 };
 
 uint64_t lv_size(const struct logical_volume *lv);
+char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1251345..07f6a90 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3920,6 +3920,22 @@ int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignored)
 	return 1;
 }
 
+char alloc_policy_char(alloc_policy_t alloc)
+{
+	switch (alloc) {
+	case ALLOC_CONTIGUOUS:
+		return 'c';
+	case ALLOC_CLING:
+		return 'l';
+	case ALLOC_NORMAL:
+		return 'n';
+	case ALLOC_ANYWHERE:
+		return 'a';
+	default:
+		return 'i';
+	}
+}
+
 /**
  * pv_by_path - Given a device path return a PV handle if it is a PV
  * @cmd - handle to the LVM command instance
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f0f0732..70efe9e 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -412,5 +412,6 @@ int vg_mark_partial_lvs(struct volume_group *vg);
 int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
+char alloc_policy_char(alloc_policy_t alloc);
 
 #endif
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index dc4a300..7c603e1 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -163,6 +163,27 @@ int is_missing_pv(const struct physical_volume *pv)
 	return pv_field(pv, status) & MISSING_PV ? 1 : 0;
 }
 
+char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
+{
+	char *repstr;
+
+	if (!(repstr = dm_pool_zalloc(mem, 3))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (pv->status & ALLOCATABLE_PV)
+		repstr[0] = 'a';
+	else
+		repstr[0] = '-';
+
+	if (pv->status & EXPORTED_VG)
+		repstr[1] = 'x';
+	else
+		repstr[1] = '-';
+	return repstr;
+}
+
 unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignored)
 {
 	struct lvmcache_info *info;
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index ba5c4a4..9e1c619 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -54,6 +54,7 @@ struct physical_volume {
 
 struct device *pv_dev(const struct physical_volume *pv);
 const char *pv_vg_name(const struct physical_volume *pv);
+char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
 uint64_t pv_size_field(const struct physical_volume *pv);
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 40270ec..3315c7e 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -434,3 +434,40 @@ int vg_set_clustered(struct volume_group *vg, int clustered)
 	return 1;
 }
 
+char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg)
+{
+	char *repstr;
+
+	if (!(repstr = dm_pool_zalloc(mem, 7))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (vg->status & LVM_WRITE)
+		repstr[0] = 'w';
+	else
+		repstr[0] = 'r';
+
+	if (vg_is_resizeable(vg))
+		repstr[1] = 'z';
+	else
+		repstr[1] = '-';
+
+	if (vg_is_exported(vg))
+		repstr[2] = 'x';
+	else
+		repstr[2] = '-';
+
+	if (vg_missing_pv_count(vg))
+		repstr[3] = 'p';
+	else
+		repstr[3] = '-';
+
+	repstr[4] = alloc_policy_char(vg->alloc);
+
+	if (vg_is_clustered(vg))
+		repstr[5] = 'c';
+	else
+		repstr[5] = '-';
+	return repstr;
+}
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 1610087..ebb44e0 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -123,5 +123,6 @@ unsigned snapshot_count(const struct volume_group *vg);
 
 uint64_t vg_mda_size(const struct volume_group *vg);
 uint64_t vg_mda_free(const struct volume_group *vg);
+char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg);
 
 #endif
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 95ad578..689f6a5 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -93,7 +93,7 @@ FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, pe_start, "Offset to the star
 FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, pv_size, "Size of PV in current units.", 0)
 FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, pv_free, "Total amount of unallocated space in current units.", 0)
 FIELD(PVS, pv, NUM, "Used", id, 4, pvused, pv_used, "Total amount of allocated space in current units.", 0)
-FIELD(PVS, pv, STR, "Attr", status, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
+FIELD(PVS, pv, STR, "Attr", id, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
 FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, pv_pe_count, "Total number of Physical Extents.", 0)
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Total number of allocated Physical Extents.", 0)
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 703060b..d0901a5 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -34,22 +34,6 @@ struct lvm_report_object {
 	struct pv_segment *pvseg;
 };
 
-static char _alloc_policy_char(alloc_policy_t alloc)
-{
-	switch (alloc) {
-	case ALLOC_CONTIGUOUS:
-		return 'c';
-	case ALLOC_CLING:
-		return 'l';
-	case ALLOC_NORMAL:
-		return 'n';
-	case ALLOC_ANYWHERE:
-		return 'a';
-	default:
-		return 'i';
-	}
-}
-
 static const uint64_t _minusone64 = UINT64_C(-1);
 static const int32_t _minusone32 = INT32_C(-1);
 
@@ -264,124 +248,16 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	return dm_report_field_int32(rh, field, &_minusone32);
 }
 
-static int _lv_mimage_in_sync(const struct logical_volume *lv)
-{
-	float percent;
-	percent_range_t percent_range;
-	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
-
-	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
-		return_0;
-
-	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent,
-			       &percent_range, NULL))
-		return_0;
-
-	return (percent_range == PERCENT_100) ? 1 : 0;
-}
-
 static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
 	char *repstr;
-	float snap_percent;
-	percent_range_t percent_range;
 
-	if (!(repstr = dm_pool_zalloc(mem, 7))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = lv_attr_dup(mem, lv)))
 		return 0;
-	}
-
-	/* Blank if this is a "free space" LV. */
-	if (!*lv->name)
-		goto out;
-
-	if (lv->status & PVMOVE)
-		repstr[0] = 'p';
-	else if (lv->status & CONVERTING)
-		repstr[0] = 'c';
-	else if (lv->status & VIRTUAL)
-		repstr[0] = 'v';
-	/* Origin takes precedence over Mirror */
-	else if (lv_is_origin(lv)) {
-		if (lv_is_merging_origin(lv))
-			repstr[0] = 'O';
-		else
-			repstr[0] = 'o';
-	}
-	else if (lv->status & MIRRORED) {
-		if (lv->status & MIRROR_NOTSYNCED)
-			repstr[0] = 'M';
-		else
-			repstr[0] = 'm';
-	}else if (lv->status & MIRROR_IMAGE)
-		if (_lv_mimage_in_sync(lv))
-			repstr[0] = 'i';
-		else
-			repstr[0] = 'I';
-	else if (lv->status & MIRROR_LOG)
-		repstr[0] = 'l';
-	else if (lv_is_cow(lv)) {
-		if (lv_is_merging_cow(lv))
-			repstr[0] = 'S';
-		else
-			repstr[0] = 's';
-	} else
-		repstr[0] = '-';
-
-	if (lv->status & PVMOVE)
-		repstr[1] = '-';
-	else if (lv->status & LVM_WRITE)
-		repstr[1] = 'w';
-	else if (lv->status & LVM_READ)
-		repstr[1] = 'r';
-	else
-		repstr[1] = '-';
-
-	repstr[2] = _alloc_policy_char(lv->alloc);
-
-	if (lv->status & LOCKED)
-		repstr[2] = toupper(repstr[2]);
-
-	if (lv->status & FIXED_MINOR)
-		repstr[3] = 'm';	/* Fixed Minor */
-	else
-		repstr[3] = '-';
-
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
-		if (info.suspended)
-			repstr[4] = 's';	/* Suspended */
-		else if (info.live_table)
-			repstr[4] = 'a';	/* Active */
-		else if (info.inactive_table)
-			repstr[4] = 'i';	/* Inactive with table */
-		else
-			repstr[4] = 'd';	/* Inactive without table */
-
-		/* Snapshot dropped? */
-		if (info.live_table && lv_is_cow(lv) &&
-		    (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
-		     percent_range == PERCENT_INVALID)) {
-			repstr[0] = toupper(repstr[0]);
-			if (info.suspended)
-				repstr[4] = 'S'; /* Susp Inv snapshot */
-			else
-				repstr[4] = 'I'; /* Invalid snapshot */
-		}
-
-		if (info.open_count)
-			repstr[5] = 'o';	/* Open */
-		else
-			repstr[5] = '-';
-	} else {
-		repstr[4] = '-';
-		repstr[5] = '-';
-	}
 
-out:
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
 }
@@ -390,23 +266,12 @@ static int _pvstatus_disp(struct dm_report *rh __attribute__((unused)), struct d
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
 {
-	const uint32_t status = *(const uint32_t *) data;
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 3))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = pv_attr_dup(mem, pv)))
 		return 0;
-	}
-
-	if (status & ALLOCATABLE_PV)
-		repstr[0] = 'a';
-	else
-		repstr[0] = '-';
-
-	if (status & EXPORTED_VG)
-		repstr[1] = 'x';
-	else
-		repstr[1] = '-';
 
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
@@ -419,37 +284,8 @@ static int _vgstatus_disp(struct dm_report *rh __attribute__((unused)), struct d
 	const struct volume_group *vg = (const struct volume_group *) data;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 7))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = vg_attr_dup(mem, vg)))
 		return 0;
-	}
-
-	if (vg->status & LVM_WRITE)
-		repstr[0] = 'w';
-	else
-		repstr[0] = 'r';
-
-	if (vg_is_resizeable(vg))
-		repstr[1] = 'z';
-	else
-		repstr[1] = '-';
-
-	if (vg_is_exported(vg))
-		repstr[2] = 'x';
-	else
-		repstr[2] = '-';
-
-	if (vg_missing_pv_count(vg))
-		repstr[3] = 'p';
-	else
-		repstr[3] = '-';
-
-	repstr[4] = _alloc_policy_char(vg->alloc);
-
-	if (vg_is_clustered(vg))
-		repstr[5] = 'c';
-	else
-		repstr[5] = '-';
 
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
-- 
1.7.2.2



From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri,  9 Jan 2009 14:25:51 -0500
Subject: [PATCH] Add pv_mda_size to 'pvs' and vg_mda_size to 'vgs'.
Message-ID: <1231529151-21061-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Reports the size of the smallest metadata area in a PV or a VG.
Useful to confirm pvcreate --metadatasize or pvmetadatasize setting in
/etc/lvm/lvm.conf file.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |    8 +++++++
 lib/metadata/metadata.h       |    5 ++++
 lib/report/columns.h          |    6 +++-
 lib/report/report.c           |   42 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 59 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index af9c2ac..428b5e2 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -87,6 +87,13 @@ static uint64_t _mda_free_sectors_raw(struct metadata_area *mda)
 	return mdac->free_sectors;
 }
 
+static uint64_t _mda_total_sectors_raw(struct metadata_area *mda)
+{
+	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+
+	return mdac->area.size >> SECTOR_SHIFT;
+}
+
 /*
  * Check if metadata area belongs to vg
  */
@@ -1559,6 +1566,7 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 	.vg_commit = _vg_commit_raw,
 	.vg_revert = _vg_revert_raw,
 	.mda_free_sectors = _mda_free_sectors_raw,
+	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
 	.pv_analyze_mda = _pv_analyze_mda_raw,
 };
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 9963c6d..eb6ed45 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -139,6 +139,11 @@ struct metadata_area_ops {
 	uint64_t (*mda_free_sectors) (struct metadata_area *mda);
 
 	/*
+	 * Returns number of total sectors in given metadata area.
+	 */
+	uint64_t (*mda_total_sectors) (struct metadata_area *mda);
+
+	/*
 	 * Check if metadata area belongs to vg
 	 */
 	int (*mda_in_vg) (struct format_instance * fi,
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 0310e75..a8f3806 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -51,7 +51,8 @@ FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, "pv_pe_count", "Total number of P
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "Total number of allocated Physical Extents.")
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.")
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, "pv_mda_count", "Number of metadata areas on this device.")
-FIELD(PVS, pv, NUM, "#PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
+FIELD(PVS, pv, NUM, "PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
+FIELD(PVS, pv, NUM, "PMdaSize", id, 9, pvmdasize, "pv_mda_size", "Size of smallest metadata area on this device in current units.")
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt", "Type of metadata.")
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid", "Unique identifier.")
@@ -71,7 +72,8 @@ FIELD(VGS, vg, NUM, "#SN", snapshot_count, 3, uint32, "snap_count", "Number of s
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
 FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas in use by this VG.")
-FIELD(VGS, vg, NUM, "#VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
+FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
+FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, "vg_mda_size", "Size of smallest metadata area for this VG in current units.")
 
 FIELD(SEGS, seg, STR, "Type", list, 4, segtype, "segtype", "Type of LV segment")
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, "stripes", "Number of stripes or mirror legs.")
diff --git a/lib/report/report.c b/lib/report/report.c
index a439c80..6e9aa54 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -884,6 +884,28 @@ static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
+static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	struct lvmcache_info *info;
+	uint64_t min_mda_size = UINT64_MAX, mda_size;
+	const char *pvid = (const char *)(&((struct id *) data)->uuid);
+	struct metadata_area *mda;
+
+	info = info_from_pvid(pvid, 0);
+
+	dm_list_iterate_items(mda, &info->mdas) {
+		if (!mda->ops->mda_total_sectors)
+			continue;
+		mda_size = mda->ops->mda_total_sectors(mda);
+		if (mda_size < min_mda_size)
+			min_mda_size = mda_size;
+	}
+
+	return _size64_disp(rh, mem, field, &min_mda_size, private);
+}
+
 static int _vgmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
@@ -906,6 +928,26 @@ static int _vgmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
+static int _vgmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint64_t min_mda_size = UINT64_MAX, mda_size;
+	struct metadata_area *mda;
+
+
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+		if (!mda->ops->mda_total_sectors)
+			continue;
+		mda_size = mda->ops->mda_total_sectors(mda);
+		if (mda_size < min_mda_size)
+			min_mda_size = mda_size;
+	}
+
+	return _size64_disp(rh, mem, field, &min_mda_size, private);
+}
+
 static int _lvcount_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
-- 
1.5.5.1



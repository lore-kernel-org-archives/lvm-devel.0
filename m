From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri,  9 Jan 2009 13:31:44 -0500
Subject: [PATCH] Add pv_mda_size to 'pvs' reporting command.
Message-ID: <1231525904-20227-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Reports the size of one metadata area - can be used to confirm pvcreate --metadatasize or
pvmetadatasize setting in /etc/lvm/lvm.conf file.

Previously we could use pe_start and pv_mda_free to indicate this size but adding this
field is more accurate and clearer for the user.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |    8 ++++++++
 lib/metadata/metadata.h       |    5 +++++
 lib/report/columns.h          |    1 +
 lib/report/report.c           |   21 +++++++++++++++++++++
 4 files changed, 35 insertions(+), 0 deletions(-)

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
index 0310e75..df11dae 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -52,6 +52,7 @@ FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "To
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.")
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, "pv_mda_count", "Number of metadata areas on this device.")
 FIELD(PVS, pv, NUM, "#PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
+FIELD(PVS, pv, NUM, "#PMdaSize", id, 9, pvmdasize, "pv_mda_size", "Size of one metadata area on this device in current units.")
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt", "Type of metadata.")
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid", "Unique identifier.")
diff --git a/lib/report/report.c b/lib/report/report.c
index a439c80..dd7e741 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -884,6 +884,27 @@ static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
+static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	struct lvmcache_info *info;
+	uint64_t mda_size = UINT64_C(0);
+	const char *pvid = (const char *)(&((struct id *) data)->uuid);
+	struct metadata_area *mda;
+
+	info = info_from_pvid(pvid, 0);
+
+	dm_list_iterate_items(mda, &info->mdas) {
+		if (!mda->ops->mda_total_sectors)
+			continue;
+		mda_size = mda->ops->mda_total_sectors(mda);
+		break;
+	}
+
+	return _size64_disp(rh, mem, field, &mda_size, private);
+}
+
 static int _vgmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
-- 
1.5.5.1



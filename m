From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:13 -0500
Subject: [PATCH 10/21] Define new functions and vgs/pvs fields related to mda disable/enable.
In-Reply-To: <1265754744-17319-10-git-send-email-dwysocha@redhat.com>
References: <1265754744-17319-1-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-2-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-3-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-4-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-5-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-6-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-7-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-8-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-9-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1265754744-17319-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Define a new pvs field, pv_mda_count_disabled, and a new vgs field,
vg_mda_count_disabled to match the existing pv_mda_count and vg_mda_count.
Also define various supporting functions to implement the counting as
well as setting the disabled flag and determining if an mda is disabled.
These high level functions call into the lower level format independent
mda disable functions defined by earlier patches.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    4 ++
 lib/metadata/metadata.c          |   89 ++++++++++++++++++++++++++++++++++++++
 lib/report/columns.h             |    2 +
 lib/report/report.c              |   25 +++++++++++
 4 files changed, 120 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 084fc81..1ae058e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -733,6 +733,9 @@ uint64_t pv_pe_start(const struct physical_volume *pv);
 uint32_t pv_pe_count(const struct physical_volume *pv);
 uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
 uint32_t pv_mda_count(const struct physical_volume *pv);
+uint32_t pv_mda_count_disabled(const struct physical_volume *pv);
+uint32_t pv_mda_is_disabled(const struct physical_volume *pv);
+int pv_mda_set_disabled(const struct physical_volume *pv, int value);
 
 uint64_t lv_size(const struct logical_volume *lv);
 
@@ -748,6 +751,7 @@ uint64_t vg_pv_count(const struct volume_group *vg);
 uint64_t vg_max_pv(const struct volume_group *vg);
 uint64_t vg_max_lv(const struct volume_group *vg);
 uint32_t vg_mda_count(const struct volume_group *vg);
+uint32_t vg_mda_count_disabled(const struct volume_group *vg);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 874f417..95d74b4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3684,6 +3684,82 @@ uint32_t pv_mda_count(const struct physical_volume *pv)
 	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
 }
 
+uint32_t pv_mda_count_disabled(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+	struct metadata_area *mda, *mda_vg;
+	uint32_t count=0;
+	struct dm_list *mdas_vg;
+
+	info = info_from_pvid((const char *)&pv->id.uuid, 0);
+	if (!info)
+		return 0;
+	if (!is_orphan(pv)) {
+		/*
+		 * If the PV is in a VG, the mdas are attached to the 'fid'.
+		 */
+		mdas_vg = &pv->vg->fid->metadata_areas;
+		dm_list_iterate_items(mda, &info->mdas) {
+			dm_list_iterate_items(mda_vg, mdas_vg) {
+				if (mda_locn_match(mda, mda_vg) &&
+				    mda_is_disabled(mda_vg))
+					count++;
+			}
+		}
+	} else {
+
+		dm_list_iterate_items(mda, &info->mdas) {
+			if (mda_is_disabled(mda))
+				count++;
+		}
+	}
+	return count;
+}
+
+uint32_t pv_mda_is_disabled(const struct physical_volume *pv)
+{
+	return pv_mda_count_disabled(pv) ? 1 : 0;
+}
+
+int pv_mda_set_disabled(const struct physical_volume *pv, int value)
+{
+	struct lvmcache_info *info;
+	struct metadata_area *mda, *mda_vg;
+	struct dm_list *mdas_vg;
+
+	info = info_from_pvid((const char *)&pv->id.uuid, 0);
+	if (!info)
+		return_0;
+
+	if (!is_orphan(pv)) {
+		/*
+		 * Do not allow disabling of the the last PV in a VG.
+		 */
+		if (!pv_mda_count_disabled(pv) &&
+		    (pv_mda_count(pv) ==
+		     vg_mda_count(pv->vg) - vg_mda_count_disabled(pv->vg))) {
+			log_error("Cannot disable metadata - volume group "
+				  "needs at least one enabled physical volume.\n");
+			return 0;
+		}
+		/*
+		 * If the PV is in a VG, the mdas are attached to the 'fid'.
+		 */
+		mdas_vg = &pv->vg->fid->metadata_areas;
+		dm_list_iterate_items(mda, &info->mdas) {
+			dm_list_iterate_items(mda_vg, mdas_vg) {
+				if (mda_locn_match(mda, mda_vg))
+					mda_set_disabled(mda_vg, value);
+			}
+		}
+	} else {
+		dm_list_iterate_items(mda, &info->mdas) {
+			mda_set_disabled(mda, value);
+		}
+	}
+	return 1;
+}
+
 uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
@@ -3739,6 +3815,19 @@ uint32_t vg_mda_count(const struct volume_group *vg)
 	return dm_list_size(&vg->fid->metadata_areas);
 }
 
+uint32_t vg_mda_count_disabled(const struct volume_group *vg)
+{
+	struct metadata_area *mda;
+	uint32_t count=0;
+
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+		if (mda_is_disabled(mda))
+			count++;
+	}
+
+	return count;
+}
+
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 49ebab4..9dd67d9 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -92,6 +92,7 @@ FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, "pv_pe_count", "Total number of P
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "Total number of allocated Physical Extents.")
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.")
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, "pv_mda_count", "Number of metadata areas on this device.")
+FIELD(PVS, pv, NUM, "#PMdaDis", id, 8, pvmdas_disabled, "pv_mda_count_disabled", "Number of metadata areas disabled on this device.")
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt", "Type of metadata.")
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid", "Unique identifier.")
@@ -111,6 +112,7 @@ FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, "snap_count", "Number of snapshots
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
 FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas in use by this VG.")
+FIELD(VGS, vg, NUM, "#VMdaDis", cmd, 8, vgmdas_disabled, "vg_mda_count_disabled", "Number of metadata areas disabled in this VG.")
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, "vg_mda_size", "Size of smallest metadata area for this VG in current units.")
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 2cceedd..e6a5785 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -861,6 +861,19 @@ static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _pvmdas_disabled_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	uint32_t count;
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
+
+	count = pv_mda_count_disabled(pv);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _vgmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
@@ -873,6 +886,18 @@ static int _vgmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _vgmdas_disabled_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint32_t count;
+
+	count = vg_mda_count_disabled(vg);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
-- 
1.6.0.6



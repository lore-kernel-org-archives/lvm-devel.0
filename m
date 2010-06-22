From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:05:45 -0400
Subject: [PATCH 12/35] Define new functions and vgs/pvs fields related to mda ignore.
In-Reply-To: <1277175968-9661-12-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-13-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Define a new pvs field, pv_mda_count_ignored, and a new vgs field,
vg_mda_count_ignored to match the existing pv_mda_count and vg_mda_count.
Also define various supporting functions to implement the counting as
well as setting the ignored flag and determining if an mda is ignored.
These high level functions call into the lower level location independent
mda ignore functions defined by earlier patches.

Note that counting ignored mdas in a vg requires traversing both lists
and checking for the ignored bit on the mda.  The count of 'ignored'
mdas then is defined by having the bit set, not by which list the mda
is on.  The list does determine whether LVM actually does read/write to
the mda, though we must count the bits in order to return accurate numbers
for the various counts.  Also, pv_mda_set_ignored must search both vg
lists for ignored mda.  If the state changes and needs to be committed
to disk, the ignored mda will be on the non-ignored list.

Note also in pv_mda_set_ignored(), we must properly manage the mda lists.
If we change the ignored state of an mda, we must change any mdas on
vg->fid->metadata_areas that correspond to this pv.  Also, we may
need to allocate a copy of the mda, as is done when fid->metadata_areas
is populated from _vg_read(), if we are un-ignoring an ignored mda.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    4 +
 lib/metadata/metadata.c          |  116 +++++++++++++++++++++++++++++++++++++-
 lib/report/columns.h             |    2 +
 lib/report/report.c              |   25 ++++++++
 4 files changed, 146 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d0e10e6..8c12f36 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -857,6 +857,9 @@ uint64_t pv_pe_start(const struct physical_volume *pv);
 uint32_t pv_pe_count(const struct physical_volume *pv);
 uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
 uint32_t pv_mda_count(const struct physical_volume *pv);
+uint32_t pv_mda_count_ignored(const struct physical_volume *pv);
+uint32_t pv_mda_is_ignored(const struct physical_volume *pv);
+int pv_mda_set_ignored(const struct physical_volume *pv, int value);
 
 uint64_t lv_size(const struct logical_volume *lv);
 
@@ -872,6 +875,7 @@ uint64_t vg_pv_count(const struct volume_group *vg);
 uint64_t vg_max_pv(const struct volume_group *vg);
 uint64_t vg_max_lv(const struct volume_group *vg);
 uint32_t vg_mda_count(const struct volume_group *vg);
+uint32_t vg_mda_count_ignored(const struct volume_group *vg);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c7b829f..b52447a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3954,6 +3954,97 @@ uint32_t pv_mda_count(const struct physical_volume *pv)
 	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
 }
 
+uint32_t pv_mda_count_ignored(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+	struct metadata_area *mda;
+	uint32_t count=0;
+
+	info = info_from_pvid((const char *)&pv->id.uuid, 0);
+	if (!info)
+		return 0;
+	dm_list_iterate_items(mda, &info->mdas) {
+		if (mda_is_ignored(mda))
+			count++;
+	}
+	return count;
+}
+
+uint32_t pv_mda_is_ignored(const struct physical_volume *pv)
+{
+	return pv_mda_count_ignored(pv) ? 1 : 0;
+}
+
+int pv_mda_set_ignored(const struct physical_volume *pv, int value)
+{
+	struct lvmcache_info *info;
+	struct metadata_area *mda, *mda_vg, *tmda;
+	struct dm_list *mdas_vg, *mdas_vg_ignored;
+
+	info = info_from_pvid((const char *)&pv->id.uuid, 0);
+	if (!info)
+		return_0;
+
+	if (is_orphan(pv)) {
+		dm_list_iterate_items(mda, &info->mdas) {
+			mda_set_ignored(mda, value);
+		}
+		return 1;
+	}
+
+	/*
+	 * Do not allow disabling of the the last PV in a VG.
+	 */
+	if (!pv_mda_count_ignored(pv) &&
+	    (pv_mda_count(pv) ==
+	     vg_mda_count(pv->vg) - vg_mda_count_ignored(pv->vg))) {
+		log_error("Cannot disable metadata - volume group "
+			  "needs at least one enabled physical volume.\n");
+		return 0;
+	}
+
+	/*
+	 * Non-orphan case is more complex.
+	 * If the PV's mdas are ignored, and we wish to un-ignore,
+	 * we clear the bit and move them from the ignored mda list to the
+	 * non-ignored list, ensuring the new state will get written to disk
+	 * in the vg_write() path.
+	 * If the PV's mdas are not ignored, and we are setting
+	 * them to ignored, we set the bit but leave them on the non-ignored
+	 * list, ensuring the new state will get written to disk in the
+	 * vg_write() path.
+	 */
+	mdas_vg = &pv->vg->fid->metadata_areas;
+	mdas_vg_ignored = &pv->vg->fid->metadata_areas_ignored;
+	dm_list_iterate_items(mda, &info->mdas) {
+		if (mda_is_ignored(mda) && !value) {
+			/* If the mda is ignored, it could be on either list */
+			dm_list_iterate_items_safe(mda_vg, tmda, mdas_vg_ignored) {
+				if (mda_locn_match(mda, mda_vg)) {
+					mda_set_ignored(mda_vg, value);
+					dm_list_move(mdas_vg, &mda_vg->list);
+				}
+			}
+			dm_list_iterate_items_safe(mda_vg, tmda, mdas_vg) {
+				if (mda_locn_match(mda, mda_vg)) {
+					mda_set_ignored(mda_vg, value);
+					dm_list_move(mdas_vg, &mda_vg->list);
+				}
+			}
+		} else if (!mda_is_ignored(mda) && value) {
+			dm_list_iterate_items_safe(mda_vg, tmda, mdas_vg) {
+				if (mda_locn_match(mda, mda_vg)) {
+					mda_set_ignored(mda_vg, value);
+					/* don't move mda - needs written to
+					   disk */
+				}
+			}
+		}
+		mda_set_ignored(mda, value);
+	}
+	return 1;
+}
+
 uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
@@ -4006,7 +4097,30 @@ uint64_t vg_max_lv(const struct volume_group *vg)
 
 uint32_t vg_mda_count(const struct volume_group *vg)
 {
-	return dm_list_size(&vg->fid->metadata_areas);
+	return dm_list_size(&vg->fid->metadata_areas) +
+		dm_list_size(&vg->fid->metadata_areas_ignored);
+}
+
+uint32_t vg_mda_count_ignored(const struct volume_group *vg)
+{
+       uint32_t count = 0;
+       struct metadata_area *mda;
+
+       /*
+	* Ignored mdas could be on either list - the reason being the state
+	* may have changed from ignored to un-ignored and we need to write
+	* the state to disk.
+	*/
+       dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+	       if (mda_is_ignored(mda))
+		       count++;
+       }
+       dm_list_iterate_items(mda, &vg->fid->metadata_areas_ignored) {
+	       if (mda_is_ignored(mda))
+		       count++;
+       }
+
+       return count;
 }
 
 uint64_t lv_size(const struct logical_volume *lv)
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 1414971..9cc5cb1 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -92,6 +92,7 @@ FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, "pv_pe_count", "Total number of P
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "Total number of allocated Physical Extents.")
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.")
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, "pv_mda_count", "Number of metadata areas on this device.")
+FIELD(PVS, pv, NUM, "#PMdaIgn", id, 8, pvmdas_ignored, "pv_mda_count_ignored", "Number of metadata areas ignored on this device.")
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt", "Type of metadata.")
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid", "Unique identifier.")
@@ -111,6 +112,7 @@ FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, "snap_count", "Number of snapshots
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
 FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas in use by this VG.")
+FIELD(VGS, vg, NUM, "#VMdaIgn", cmd, 8, vgmdas_ignored, "vg_mda_count_ignored", "Number of metadata areas ignored in this VG.")
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, "vg_mda_size", "Size of smallest metadata area for this VG in current units.")
 
diff --git a/lib/report/report.c b/lib/report/report.c
index d912758..9196531 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -856,6 +856,19 @@ static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _pvmdas_ignored_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	uint32_t count;
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
+
+	count = pv_mda_count_ignored(pv);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _vgmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
@@ -868,6 +881,18 @@ static int _vgmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _vgmdas_ignored_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint32_t count;
+
+	count = vg_mda_count_ignored(vg);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
-- 
1.6.0.6



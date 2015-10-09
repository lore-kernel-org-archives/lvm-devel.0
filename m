From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 Oct 2015 14:32:53 +0000 (UTC)
Subject: master - report: add vg_missing_pv_count field
Message-ID: <20151009143253.21E1B60EDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8733a8d89040820f66a99d4d4e8f524ab2497983
Commit:        8733a8d89040820f66a99d4d4e8f524ab2497983
Parent:        5446d177569ca10476c935013ae03e6a0763ab34
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 9 16:20:29 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 9 16:28:58 2015 +0200

report: add vg_missing_pv_count field

We already have pv_count to report number of PVs that a VG has based
on metadata.

This patch exposes the information about how many of these PVs are
missing which is also useful information for a VG. Wwe could count
the sum of pv_missing reporting fields for each PV in the VG before,
but the new field is practical when reporting VG as a whole and there's
no need to process each PV from VG alone.
---
 WHATS_NEW               |    1 +
 lib/report/columns.h    |    3 ++-
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   11 +++++++++++
 4 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 227530d..ac9f6b8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Add vg_missing_pv_count report field to report number of missing PVs in a VG.
   Properly identify internal LV holding sanlock locks within lv_role field.
   Add metadata_devices and seg_metadata_le_ranges report fields for raid vols.
   Fix lvm2-{activation,clvmd,cmirrord,monitor} service to exec before mounting.
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 6041eeb..41a03f4 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -158,7 +158,8 @@ FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, vg_extent_count, "Total num
 FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, vg_free_count, "Total number of unallocated Physical Extents.", 0)
 FIELD(VGS, vg, NUM, "MaxLV", max_lv, 5, uint32, max_lv, "Maximum number of LVs allowed in VG or 0 if unlimited.", 0)
 FIELD(VGS, vg, NUM, "MaxPV", max_pv, 5, uint32, max_pv, "Maximum number of PVs allowed in VG or 0 if unlimited.", 0)
-FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, pv_count, "Number of PVs.", 0)
+FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, pv_count, "Number of PVs in VG.", 0)
+FIELD(VGS, vg, NUM, "#PV Missing", cmd, 11, vgmissingpvcount, vg_missing_pv_count, "Number of PVs in VG which are missing.", 0)
 FIELD(VGS, vg, NUM, "#LV", cmd, 3, lvcount, lv_count, "Number of LVs.", 0)
 FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, snap_count, "Number of snapshots.", 0)
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, vg_seqno, "Revision number of internal metadata.  Incremented whenever it changes.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 262cc26..7dafbe5 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -420,6 +420,8 @@ GET_VG_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
 SET_VG_NUM_PROPERTY_FN(vg_mda_copies, vg_set_mda_copies)
 GET_VG_STR_PROPERTY_FN(vg_profile, vg_profile_dup(vg))
 #define _vg_profile_set prop_not_implemented_set
+GET_VG_NUM_PROPERTY_FN(vg_missing_pv_count, vg_missing_pv_count(vg))
+#define _vg_missing_pv_count_set prop_not_implemented_set
 
 /* LVSEG */
 GET_LVSEG_STR_PROPERTY_FN(segtype, lvseg_segtype_dup(lvseg->lv->vg->vgmem, lvseg))
diff --git a/lib/report/report.c b/lib/report/report.c
index 7ac1ac5..dea66ee 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2438,6 +2438,17 @@ static int _vgprofile_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, "", NULL);
 }
 
+static int _vgmissingpvcount_disp(struct dm_report *rh, struct dm_pool *mem,
+				  struct dm_report_field *field,
+				  const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint32_t count = vg_missing_pv_count(vg);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
+
 static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)



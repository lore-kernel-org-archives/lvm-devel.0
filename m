From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:33:58 +0000 (UTC)
Subject: master - report: select: add DM_REPORT_FIELD_TYPE_SIZE to make a difference between NUMBER and SIZE
Message-ID: <20140617143358.CC92A60C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7dbbc05a69c4cb9756464720cad29e3c1ed971c3
Commit:        7dbbc05a69c4cb9756464720cad29e3c1ed971c3
Parent:        378fa9d1585941a8492830d866377e5f29dff29c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:37:22 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:20 2014 +0200

report: select: add DM_REPORT_FIELD_TYPE_SIZE to make a difference between NUMBER and SIZE

This makes it easier to check against the fields (following patches for
report selection) and check whether size units are allowed or not
with the field value.
---
 lib/properties/prop_common.h |    1 +
 lib/report/columns.h         |   48 +++++++++++++++++++++---------------------
 lib/report/properties.c      |    2 +
 lib/report/report.c          |    2 +
 libdm/libdevmapper.h         |    1 +
 libdm/libdm-report.c         |    6 +++-
 tools/dmsetup.c              |    2 +
 7 files changed, 36 insertions(+), 26 deletions(-)

diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
index 6c89ad6..d6a0bb7 100644
--- a/lib/properties/prop_common.h
+++ b/lib/properties/prop_common.h
@@ -122,6 +122,7 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 
 #define STR 1
 #define NUM 2
+#define SIZ 3
 
 #define FIELD_MODIFIABLE 0x00000001
 #define FIELD(type, strct, field_type, head, field, width, fn, id, desc, settable) \
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 7c36d10..8328321 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -35,15 +35,15 @@ FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - se
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
-FIELD(LVS, lv, NUM, "Rahead", lvid, 6, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
+FIELD(LVS, lv, SIZ, "Rahead", lvid, 6, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
 FIELD(LVS, lv, NUM, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
 FIELD(LVS, lv, NUM, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
-FIELD(LVS, lv, NUM, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
-FIELD(LVS, lv, NUM, "LSize", size, 5, size64, lv_size, "Size of LV in current units.", 0)
-FIELD(LVS, lv, NUM, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thin pools, the size of the LV that holds the metadata.", 0)
+FIELD(LVS, lv, SIZ, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
+FIELD(LVS, lv, SIZ, "LSize", size, 5, size64, lv_size, "Size of LV in current units.", 0)
+FIELD(LVS, lv, SIZ, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thin pools, the size of the LV that holds the metadata.", 0)
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, seg_count, "Number of segments in LV.", 0)
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, origin, "For snapshots, the origin device of this LV.", 0)
-FIELD(LVS, lv, NUM, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
+FIELD(LVS, lv, SIZ, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
 FIELD(LVS, lv, NUM, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
@@ -68,15 +68,15 @@ FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapp
 
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
-FIELD(LABEL, label, NUM, "DevSize", dev, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
+FIELD(LABEL, label, SIZ, "DevSize", dev, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
 FIELD(LABEL, label, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
-FIELD(LABEL, label, NUM, "PMdaFree", type, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
-FIELD(LABEL, label, NUM, "PMdaSize", type, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
+FIELD(LABEL, label, SIZ, "PMdaFree", type, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
+FIELD(LABEL, label, SIZ, "PMdaSize", type, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
 
 FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, pe_start, "Offset to the start of data on the underlying device.", 0)
-FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, pv_size, "Size of PV in current units.", 0)
-FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, pv_free, "Total amount of unallocated space in current units.", 0)
-FIELD(PVS, pv, NUM, "Used", id, 4, pvused, pv_used, "Total amount of allocated space in current units.", 0)
+FIELD(PVS, pv, SIZ, "PSize", id, 5, pvsize, pv_size, "Size of PV in current units.", 0)
+FIELD(PVS, pv, SIZ, "PFree", id, 5, pvfree, pv_free, "Total amount of unallocated space in current units.", 0)
+FIELD(PVS, pv, SIZ, "Used", id, 4, pvused, pv_used, "Total amount of allocated space in current units.", 0)
 FIELD(PVS, pv, STR, "Attr", id, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
 FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, pv_pe_count, "Total number of Physical Extents.", 0)
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Total number of allocated Physical Extents.", 0)
@@ -84,16 +84,16 @@ FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, pv_mda_count, "Number of metadata areas on this device.", 0)
 FIELD(PVS, pv, NUM, "#PMdaUse", id, 8, pvmdasused, pv_mda_used_count, "Number of metadata areas in use on this device.", 0)
 FIELD(PVS, pv, NUM, "BA start", ba_start, 8, size64, pv_ba_start, "Offset to the start of PV Bootloader Area on the underlying device in current units.", 0)
-FIELD(PVS, pv, NUM, "BA size", ba_size, 7, size64, pv_ba_size, "Size of PV Bootloader Area in current units.", 0)
+FIELD(PVS, pv, SIZ, "BA size", ba_size, 7, size64, pv_ba_size, "Size of PV Bootloader Area in current units.", 0)
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, vg_fmt, "Type of metadata.", 0)
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
 FIELD(VGS, vg, STR, "VG", name, 4, string, vg_name, "Name.", 0)
 FIELD(VGS, vg, STR, "Attr", cmd, 5, vgstatus, vg_attr, "Various attributes - see man page.", 0)
-FIELD(VGS, vg, NUM, "VSize", cmd, 5, vgsize, vg_size, "Total size of VG in current units.", 0)
+FIELD(VGS, vg, SIZ, "VSize", cmd, 5, vgsize, vg_size, "Total size of VG in current units.", 0)
 FIELD(VGS, vg, NUM, "VFree", cmd, 5, vgfree, vg_free, "Total amount of free space in current units.", 0)
 FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, vg_sysid, "System ID indicating when and where it was created.", 0)
-FIELD(VGS, vg, NUM, "Ext", extent_size, 3, size32, vg_extent_size, "Size of Physical Extents in current units.", 0)
+FIELD(VGS, vg, SIZ, "Ext", extent_size, 3, size32, vg_extent_size, "Size of Physical Extents in current units.", 0)
 FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, vg_extent_count, "Total number of Physical Extents.", 0)
 FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, vg_free_count, "Total number of unallocated Physical Extents.", 0)
 FIELD(VGS, vg, NUM, "MaxLV", max_lv, 5, uint32, max_lv, "Maximum number of LVs allowed in VG or 0 if unlimited.", 0)
@@ -106,18 +106,18 @@ FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, vg_tags, "Tags, if any.", 0)
 FIELD(VGS, vg, STR, "VProfile", cmd, 8, vgprofile, vg_profile, "Configuration profile attached to this VG.", 0)
 FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, vg_mda_count, "Number of metadata areas on this VG.", 0)
 FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, vg_mda_used_count, "Number of metadata areas in use on this VG.", 0)
-FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, vg_mda_free, "Free metadata area space for this VG in current units.", 0)
-FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, vg_mda_size, "Size of smallest metadata area for this VG in current units.", 0)
+FIELD(VGS, vg, SIZ, "VMdaFree", cmd, 9, vgmdafree, vg_mda_free, "Free metadata area space for this VG in current units.", 0)
+FIELD(VGS, vg, SIZ, "VMdaSize", cmd, 9, vgmdasize, vg_mda_size, "Size of smallest metadata area for this VG in current units.", 0)
 FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 1)
 
 FIELD(SEGS, seg, STR, "Type", list, 4, segtype, segtype, "Type of LV segment.", 0)
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, stripes, "Number of stripes or mirror legs.", 0)
-FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, stripesize, "For stripes, amount of data placed on one device before switching to the next.", 0)
-FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, stripe_size, "For stripes, amount of data placed on one device before switching to the next.", 0)
-FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, regionsize, "For mirrors, the unit of data copied when synchronising devices.", 0)
-FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, region_size, "For mirrors, the unit of data copied when synchronising devices.", 0)
-FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunksize, "For snapshots, the unit of data used when tracking changes.", 0)
-FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
+FIELD(SEGS, seg, SIZ, "Stripe", stripe_size, 6, size32, stripesize, "For stripes, amount of data placed on one device before switching to the next.", 0)
+FIELD(SEGS, seg, SIZ, "Stripe", stripe_size, 6, size32, stripe_size, "For stripes, amount of data placed on one device before switching to the next.", 0)
+FIELD(SEGS, seg, SIZ, "Region", region_size, 6, size32, regionsize, "For mirrors, the unit of data copied when synchronising devices.", 0)
+FIELD(SEGS, seg, SIZ, "Region", region_size, 6, size32, region_size, "For mirrors, the unit of data copied when synchronising devices.", 0)
+FIELD(SEGS, seg, SIZ, "Chunk", list, 5, chunksize, chunksize, "For snapshots, the unit of data used when tracking changes.", 0)
+FIELD(SEGS, seg, SIZ, "Chunk", list, 5, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "#Thins", list, 4, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
 FIELD(SEGS, seg, STR, "Discards", list, 8, discards, discards, "For thin pools, how discards are handled.", 0)
 FIELD(SEGS, seg, NUM, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
@@ -125,8 +125,8 @@ FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For th
 FIELD(SEGS, seg, NUM, "ThId", list, 4, thinid, thin_id, "For thin volume, the thin device id.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, seg_start_pe, "Offset within the LV to the start of the segment in physical extents.", 0)
-FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, seg_size, "Size of segment in current units.", 0)
-FIELD(SEGS, seg, NUM, "SSize", list, 5, segsizepe, seg_size_pe, "Size of segment in physical extents.", 0)
+FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsize, seg_size, "Size of segment in current units.", 0)
+FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsizepe, seg_size_pe, "Size of segment in physical extents.", 0)
 FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
 FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
 FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index c6ccb72..876a408 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -334,6 +334,7 @@ GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_size, (SECTOR_SIZE * pvseg->len))
 #define _pvseg_size_set prop_not_implemented_set
 
+
 struct lvm_property_type _properties[] = {
 #include "columns.h"
 	{ 0, "", 0, 0, 0, { .integer = 0 }, prop_not_implemented_get, prop_not_implemented_set },
@@ -341,6 +342,7 @@ struct lvm_property_type _properties[] = {
 
 #undef STR
 #undef NUM
+#undef SIZ
 #undef FIELD
 
 int lvseg_get_property(const struct lv_segment *lvseg,
diff --git a/lib/report/report.c b/lib/report/report.c
index 6b32bee..2f340ed 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1202,6 +1202,7 @@ static const struct dm_report_object_type _devtypes_report_types[] = {
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
+#define SIZ DM_REPORT_FIELD_TYPE_SIZE
 #define FIELD(type, strct, sorttype, head, field, width, func, id, desc, writeable) \
 	{type, sorttype, offsetof(type_ ## strct, field), width, \
 	 #id, head, &_ ## func ## _disp, desc},
@@ -1227,6 +1228,7 @@ static const struct dm_report_field_type _devtypes_fields[] = {
 
 #undef STR
 #undef NUM
+#undef SIZ
 #undef FIELD
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 386ef07..3a51e14 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1597,6 +1597,7 @@ struct dm_report_field;
 #define DM_REPORT_FIELD_TYPE_MASK	0x000000F0
 #define DM_REPORT_FIELD_TYPE_STRING	0x00000010
 #define DM_REPORT_FIELD_TYPE_NUMBER	0x00000020
+#define DM_REPORT_FIELD_TYPE_SIZE	0x00000040
 
 #define DM_REPORT_FIELD_TYPE_ID_LEN 32
 #define DM_REPORT_FIELD_TYPE_HEADING_LEN 32
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index bdc293b..e0c6b1d 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -862,7 +862,8 @@ static int _row_compare(const void *a, const void *b)
 	for (cnt = 0; cnt < rowa->rh->keys_count; cnt++) {
 		sfa = (*rowa->sort_fields)[cnt];
 		sfb = (*rowb->sort_fields)[cnt];
-		if (sfa->props->flags & DM_REPORT_FIELD_TYPE_NUMBER) {
+		if ((sfa->props->flags & DM_REPORT_FIELD_TYPE_NUMBER) ||
+		    (sfa->props->flags & DM_REPORT_FIELD_TYPE_SIZE)) {
 			const uint64_t numa =
 			    *(const uint64_t *) sfa->sort_value;
 			const uint64_t numb =
@@ -972,7 +973,8 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		}
 	} else {
 		if (!(align = field->props->flags & DM_REPORT_FIELD_ALIGN_MASK))
-			align = (field->props->flags & DM_REPORT_FIELD_TYPE_NUMBER) ? 
+			align = ((field->props->flags & DM_REPORT_FIELD_TYPE_NUMBER) ||
+				 (field->props->flags & DM_REPORT_FIELD_TYPE_SIZE)) ? 
 				DM_REPORT_FIELD_ALIGN_RIGHT : DM_REPORT_FIELD_ALIGN_LEFT;
 
 		/* Including trailing '\0'! */
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f84d1a8..fd87d42 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2786,6 +2786,7 @@ static const struct dm_report_object_type _report_types[] = {
 #define OFFSET_OF(strct, field) (((char*)&((struct strct*)0)->field) - (char*)0)
 #define STR (DM_REPORT_FIELD_TYPE_STRING)
 #define NUM (DM_REPORT_FIELD_TYPE_NUMBER)
+#define SIZ (DM_REPORT_FIELD_TYPE_SIZE)
 #define FIELD_O(type, strct, sorttype, head, field, width, func, id, desc) {DR_ ## type, sorttype, OFFSET_OF(strct, field), width, id, head, &_ ## func ## _disp, desc},
 #define FIELD_F(type, sorttype, head, width, func, id, desc) {DR_ ## type, sorttype, 0, width, id, head, &_ ## func ## _disp, desc},
 
@@ -2833,6 +2834,7 @@ FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 7, dm_lv_layer_name, "lv_
 
 #undef STR
 #undef NUM
+#undef SIZ
 #undef FIELD_O
 #undef FIELD_F
 



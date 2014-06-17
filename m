From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:22 +0000 (UTC)
Subject: master - report: select: add DM_REPORT_FIELD_TYPE_STRING_LIST to make a difference between STRING and STRING_LIST
Message-ID: <20140617143422.2C85F60C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6694cfc299111127e6f6f261ba1b99b3a3f9a19
Commit:        a6694cfc299111127e6f6f261ba1b99b3a3f9a19
Parent:        76467bdcfd297ffbe2c088b6340ecc7d17d56742
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:41:36 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:20 2014 +0200

report: select: add DM_REPORT_FIELD_TYPE_STRING_LIST to make a difference between STRING and STRING_LIST

The {pv,vg,lv,seg}_tags and lv_modules fields are reported as string
lists using the new dm_report_field_string_list - so we just pass
the list to the fn that takes care of reporting and item sorting itself.
---
 lib/properties/prop_common.h |    1 +
 lib/report/columns.h         |   10 +++++-----
 lib/report/properties.c      |    1 +
 lib/report/report.c          |   22 +++++++++++++---------
 libdm/libdevmapper.h         |   17 +++++++++--------
 libdm/libdm-report.c         |    4 +++-
 6 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
index d6a0bb7..e2249e1 100644
--- a/lib/properties/prop_common.h
+++ b/lib/properties/prop_common.h
@@ -123,6 +123,7 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 #define STR 1
 #define NUM 2
 #define SIZ 3
+#define STR_LIST 4
 
 #define FIELD_MODIFIABLE 0x00000001
 #define FIELD(type, strct, field_type, head, field, width, fn, id, desc, settable) \
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 8328321..e3998ef 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -60,11 +60,11 @@ FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV hold
 FIELD(LVS, lv, STR, "Data", lvid, 4, datalv, data_lv, "For thin pools, the LV holding the associated data.", 0)
 FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin pools, the LV holding the associated metadata.", 0)
 FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, pool_lv, "For thin volumes, the thin pool LV for this volume.", 0)
-FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
+FIELD(LVS, lv, STR_LIST, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration profile attached to this LV.", 0)
 FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
-FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
+FIELD(LVS, lv, STR_LIST, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
@@ -80,7 +80,7 @@ FIELD(PVS, pv, SIZ, "Used", id, 4, pvused, pv_used, "Total amount of allocated s
 FIELD(PVS, pv, STR, "Attr", id, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
 FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, pv_pe_count, "Total number of Physical Extents.", 0)
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Total number of allocated Physical Extents.", 0)
-FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
+FIELD(PVS, pv, STR_LIST, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, pv_mda_count, "Number of metadata areas on this device.", 0)
 FIELD(PVS, pv, NUM, "#PMdaUse", id, 8, pvmdasused, pv_mda_used_count, "Number of metadata areas in use on this device.", 0)
 FIELD(PVS, pv, NUM, "BA start", ba_start, 8, size64, pv_ba_start, "Offset to the start of PV Bootloader Area on the underlying device in current units.", 0)
@@ -102,7 +102,7 @@ FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, pv_count, "Number of PVs.", 0)
 FIELD(VGS, vg, NUM, "#LV", cmd, 3, lvcount, lv_count, "Number of LVs.", 0)
 FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, snap_count, "Number of snapshots.", 0)
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, vg_seqno, "Revision number of internal metadata.  Incremented whenever it changes.", 0)
-FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, vg_tags, "Tags, if any.", 0)
+FIELD(VGS, vg, STR_LIST, "VG Tags", tags, 7, tags, vg_tags, "Tags, if any.", 0)
 FIELD(VGS, vg, STR, "VProfile", cmd, 8, vgprofile, vg_profile, "Configuration profile attached to this VG.", 0)
 FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, vg_mda_count, "Number of metadata areas on this VG.", 0)
 FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, vg_mda_used_count, "Number of metadata areas in use on this VG.", 0)
@@ -127,7 +127,7 @@ FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, seg_start_pe, "Offset within the LV to the start of the segment in physical extents.", 0)
 FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsize, seg_size, "Size of segment in current units.", 0)
 FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsizepe, seg_size_pe, "Size of segment in physical extents.", 0)
-FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
+FIELD(SEGS, seg, STR_LIST, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
 FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
 FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
 FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, seg_monitor, "Dmeventd monitoring status of the segment.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 876a408..ec7bc4d 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -343,6 +343,7 @@ struct lvm_property_type _properties[] = {
 #undef STR
 #undef NUM
 #undef SIZ
+#undef STR_LIST
 #undef FIELD
 
 int lvseg_get_property(const struct lv_segment *lvseg,
diff --git a/lib/report/report.c b/lib/report/report.c
index 8a87bd2..e8ff5bb 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -23,6 +23,7 @@
 #include "segtype.h"
 #include "lvmcache.h"
 #include "device-types.h"
+#include "str_list.h"
 
 #include <stddef.h> /* offsetof() */
 
@@ -126,17 +127,13 @@ static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct d
 	return _field_set_value(field, str, NULL);
 }
 
-static int _tags_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,
 		      struct dm_report_field *field,
 		      const void *data, void *private __attribute__((unused)))
 {
 	const struct dm_list *tagsl = (const struct dm_list *) data;
-	char *tags_str;
 
-	if (!(tags_str = tags_format_and_copy(mem, tagsl)))
-		return_0;
-
-	return _field_set_value(field, tags_str, NULL);
+	return dm_report_field_string_list(rh, field, tagsl, NULL);
 }
 
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -144,12 +141,17 @@ static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
 			 const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	char *modules_str;
+	struct dm_list *modules;
+
+	if (!(modules = str_list_create(mem))) {
+		log_error("modules str_list allocation failed");
+		return 0;
+	}
 
-	if (!(modules_str = lv_modules_dup(mem, lv)))
+	if (!(list_lv_modules(mem, lv, modules)))
 		return_0;
 
-	return _field_set_value(field, modules_str, NULL);
+	return dm_report_field_string_list(rh, field, modules, NULL);
 }
 
 static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1203,6 +1205,7 @@ static const struct dm_report_object_type _devtypes_report_types[] = {
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
 #define SIZ DM_REPORT_FIELD_TYPE_SIZE
+#define STR_LIST DM_REPORT_FIELD_TYPE_STRING_LIST
 #define FIELD(type, strct, sorttype, head, field, width, func, id, desc, writeable) \
 	{type, sorttype, offsetof(type_ ## strct, field), width, \
 	 #id, head, &_ ## func ## _disp, desc},
@@ -1229,6 +1232,7 @@ static const struct dm_report_field_type _devtypes_fields[] = {
 #undef STR
 #undef NUM
 #undef SIZ
+#undef STR_LIST
 #undef FIELD
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e007b9b..d256373 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1598,14 +1598,15 @@ struct dm_report_field;
 /*
  * dm_report_field_type flags
  */
-#define DM_REPORT_FIELD_MASK		0x000000FF
-#define DM_REPORT_FIELD_ALIGN_MASK	0x0000000F
-#define DM_REPORT_FIELD_ALIGN_LEFT	0x00000001
-#define DM_REPORT_FIELD_ALIGN_RIGHT	0x00000002
-#define DM_REPORT_FIELD_TYPE_MASK	0x000000F0
-#define DM_REPORT_FIELD_TYPE_STRING	0x00000010
-#define DM_REPORT_FIELD_TYPE_NUMBER	0x00000020
-#define DM_REPORT_FIELD_TYPE_SIZE	0x00000040
+#define DM_REPORT_FIELD_MASK			0x000000FF
+#define DM_REPORT_FIELD_ALIGN_MASK		0x0000000F
+#define DM_REPORT_FIELD_ALIGN_LEFT		0x00000001
+#define DM_REPORT_FIELD_ALIGN_RIGHT		0x00000002
+#define DM_REPORT_FIELD_TYPE_MASK		0x000000F0
+#define DM_REPORT_FIELD_TYPE_STRING		0x00000010
+#define DM_REPORT_FIELD_TYPE_NUMBER		0x00000020
+#define DM_REPORT_FIELD_TYPE_SIZE		0x00000040
+#define DM_REPORT_FIELD_TYPE_STRING_LIST	0x00000080
 
 #define DM_REPORT_FIELD_TYPE_ID_LEN 32
 #define DM_REPORT_FIELD_TYPE_HEADING_LEN 32
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 0feef17..e61d2c9 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1949,7 +1949,9 @@ static int _row_compare(const void *a, const void *b)
 			} else {	/* FLD_DESCENDING */
 				return (numa < numb) ? 1 : -1;
 			}
-		} else {	/* DM_REPORT_FIELD_TYPE_STRING */
+		} else {
+			/* DM_REPORT_FIELD_TYPE_STRING
+			 * DM_REPORT_FIELD_TYPE_STRING_LIST */
 			const char *stra = (const char *) sfa->sort_value;
 			const char *strb = (const char *) sfb->sort_value;
 			int cmp = strcmp(stra, strb);



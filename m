From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Jan 2016 13:30:45 +0000 (UTC)
Subject: master - report: add seg_le_ranges report field
Message-ID: <20160119133045.6FF066033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1341f835547ce89240754054614ec5acea60a58a
Commit:        1341f835547ce89240754054614ec5acea60a58a
Parent:        fccb1bb276d37825d5147936c80e761e1334032b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 19 13:51:11 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 19 14:30:21 2016 +0100

report: add seg_le_ranges report field

---
 WHATS_NEW               |    1 +
 lib/metadata/lv.c       |   15 +++++++++++++++
 lib/metadata/lv.h       |    2 ++
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   13 +++++++++++++
 6 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6f3e5ea..c5db715 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.141 - 
 ====================================
+  Add seg_le_ranges report field for common format when displaying seg devices.
   Honour report/list_item_separator for seg_metadata_le_ranges report field.
   Don't mark hidden devs in -o devices,metadata_devices,seg_pe_ranges (2.02.140).
   Change LV sizes in seg_pe_ranges report field to match underlying devices.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 8178530..b5c9852 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -173,6 +173,21 @@ char *lvseg_seg_pe_ranges_str(struct dm_pool *mem, const struct lv_segment *seg)
 	return str_list_to_str(mem, list, " ");
 }
 
+struct dm_list *lvseg_seg_le_ranges(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	return _format_pvsegs(mem, seg, 1, 0, seg->lv->vg->cmd->report_mark_hidden_devices);
+}
+
+char *lvseg_seg_le_ranges_str(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	struct dm_list *list;
+
+	if (!(list = lvseg_seg_pe_ranges(mem, seg)))
+		return_NULL;
+
+	return str_list_to_str(mem, list, seg->lv->vg->cmd->report_list_item_separator);
+}
+
 struct dm_list *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg)
 {
 	return _format_pvsegs(mem, seg, 1, 1, seg->lv->vg->cmd->report_mark_hidden_devices);
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 6b5115f..b23b3b0 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -92,6 +92,8 @@ struct dm_list *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segm
 char *lvseg_metadata_devices_str(struct dm_pool *mem, const struct lv_segment *seg);
 struct dm_list *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_seg_pe_ranges_str(struct dm_pool *mem, const struct lv_segment *seg);
+struct dm_list *lvseg_seg_le_ranges(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_seg_le_ranges_str(struct dm_pool *mem, const struct lv_segment *seg);
 struct dm_list *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_seg_metadata_le_ranges_str(struct dm_pool *mem, const struct lv_segment *seg);
 
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 04b9aa1..bbea697 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -193,6 +193,7 @@ FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsize, seg_size, "Size of segment in c
 FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsizepe, seg_size_pe, "Size of segment in physical extents.", 0)
 FIELD(SEGS, seg, STR_LIST, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
 FIELD(SEGS, seg, STR_LIST, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
+FIELD(SEGS, seg, STR_LIST, "LE Ranges", list, 9, leranges, seg_le_ranges, "Ranges of Logical Extents of underlying devices in command line format.", 0)
 FIELD(SEGS, seg, STR_LIST, "Metadata LE Ranges", list, 18, metadataleranges, seg_metadata_le_ranges, "Ranges of Logical Extents of underlying metadata devices in command line format.", 0)
 FIELD(SEGS, seg, STR_LIST, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
 FIELD(SEGS, seg, STR_LIST, "Metadata Devs", list, 13, metadatadevices, metadata_devices, "Underlying metadata devices used with starting extent numbers.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index bd5f081..5cac7c7 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -466,6 +466,8 @@ GET_LVSEG_STR_PROPERTY_FN(seg_tags, lvseg_tags_dup(lvseg))
 #define _seg_tags_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_pe_ranges, lvseg_seg_pe_ranges_str(lvseg->lv->vg->vgmem, lvseg))
 #define _seg_pe_ranges_set prop_not_implemented_set
+GET_LVSEG_STR_PROPERTY_FN(seg_le_ranges, lvseg_seg_le_ranges_str(lvseg->lv->vg->vgmem, lvseg))
+#define _seg_le_ranges_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_metadata_le_ranges, lvseg_seg_metadata_le_ranges_str(lvseg->lv->vg->vgmem, lvseg))
 #define _seg_metadata_le_ranges_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices_str(lvseg->lv->vg->vgmem, lvseg))
diff --git a/lib/report/report.c b/lib/report/report.c
index 788d806..17195c7 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1332,6 +1332,19 @@ static int _peranges_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_string_list(rh, field, list, private, 0, " ");
 }
 
+static int _leranges_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	struct dm_list *list;
+
+	if (!(list = lvseg_seg_le_ranges(mem, seg)))
+		return_0;
+
+	return _field_set_string_list(rh, field, list, private, 0, NULL);
+}
+
 static int _metadataleranges_disp(struct dm_report *rh, struct dm_pool *mem,
 				  struct dm_report_field *field,
 				  const void *data, void *private)



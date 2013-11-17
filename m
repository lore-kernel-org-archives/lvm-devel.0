From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:58 +0000 (UTC)
Subject: master - report: Add a proper "label" field type.
Message-ID: <20131117222658.B6ADC60ECE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e33f50cea7a7240d81ffdec3f8b0c6a1976fce3
Commit:        7e33f50cea7a7240d81ffdec3f8b0c6a1976fce3
Parent:        6b41e916ff8a11e91fade523323db549417f703c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 29 19:07:11 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:27 2013 +0100

report: Add a proper "label" field type.

---
 lib/report/report.c |   13 +++++++++++--
 lib/report/report.h |    4 +++-
 tools/reporter.c    |   19 +++++++++++--------
 3 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 2684392..f304157 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -32,6 +32,7 @@ struct lvm_report_object {
 	struct physical_volume *pv;
 	struct lv_segment *seg;
 	struct pv_segment *pvseg;
+	struct label *label;
 };
 
 static const uint64_t _hundred64 = UINT64_C(100);
@@ -1138,6 +1139,11 @@ static void *_obj_get_pv(void *obj)
 	return ((struct lvm_report_object *)obj)->pv;
 }
 
+static void *_obj_get_label(void *obj)
+{
+	return ((struct lvm_report_object *)obj)->label;
+}
+
 static void *_obj_get_seg(void *obj)
 {
 	return ((struct lvm_report_object *)obj)->seg;
@@ -1157,7 +1163,7 @@ static const struct dm_report_object_type _report_types[] = {
 	{ VGS, "Volume Group", "vg_", _obj_get_vg },
 	{ LVS, "Logical Volume", "lv_", _obj_get_lv },
 	{ PVS, "Physical Volume", "pv_", _obj_get_pv },
-	{ LABEL, "Physical Volume Label", "pv_", _obj_get_pv },
+	{ LABEL, "Physical Volume Label", "pv_", _obj_get_label },
 	{ SEGS, "Logical Volume Segment", "seg_", _obj_get_seg },
 	{ PVSEGS, "Physical Volume Segment", "pvseg_", _obj_get_pvseg },
 	{ 0, "", "", NULL },
@@ -1183,6 +1189,7 @@ typedef struct logical_volume type_lv;
 typedef struct volume_group type_vg;
 typedef struct lv_segment type_seg;
 typedef struct pv_segment type_pvseg;
+typedef struct label type_label;
 
 typedef dev_known_type_t type_devtype;
 
@@ -1242,7 +1249,8 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
  */
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
-		  struct lv_segment *seg, struct pv_segment *pvseg)
+		  struct lv_segment *seg, struct pv_segment *pvseg,
+		  struct label *label)
 {
 	struct lvm_report_object obj;
 
@@ -1255,6 +1263,7 @@ int report_object(void *handle, struct volume_group *vg,
 	obj.pv = pv;
 	obj.seg = seg;
 	obj.pvseg = pvseg;
+	obj.label = label ? label : (pv ? pv_label(pv) : NULL);
 
 	return dm_report_object(handle, &obj);
 }
diff --git a/lib/report/report.h b/lib/report/report.h
index bda8553..2c093b0 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -17,6 +17,7 @@
 #define _LVM_REPORT_H
 
 #include "metadata-exported.h"
+#include "label.h"
 
 typedef enum {
 	LVS		= 1,
@@ -41,7 +42,8 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 void report_free(void *handle);
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
-		  struct lv_segment *seg, struct pv_segment *pvseg);
+		  struct lv_segment *seg, struct pv_segment *pvseg,
+		  struct label *label);
 int report_devtypes(void *handle);
 int report_output(void *handle);
 
diff --git a/tools/reporter.c b/tools/reporter.c
index a967f60..8b2a7c7 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -31,7 +31,7 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name, struct volume_group *vg,
 		       void *handle)
 {
-	if (!report_object(handle, vg, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, vg, NULL, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	check_current_backup(vg);
@@ -42,7 +42,7 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL))
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -51,7 +51,7 @@ static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 static int _segs_single(struct cmd_context *cmd __attribute__((unused)),
 			struct lv_segment *seg, void *handle)
 {
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL))
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -107,7 +107,7 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 	dm_list_init(&_free_logical_volume.snapshot_segs);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
-			   seg ? : &_free_lv_segment, pvseg)) {
+			   seg ? : &_free_lv_segment, pvseg, NULL)) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}
@@ -140,6 +140,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	const char *vg_name = NULL;
 	struct volume_group *old_vg = vg;
 	char uuid[64] __attribute__((aligned(8)));
+	struct label *label;
 
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
@@ -177,7 +178,9 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		pv = pvl->pv;
 	}
 
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL)) {
+	if ((!(label = pv_label(pv))) ||
+	    (!report_object(handle, vg, NULL, pv, NULL, NULL, label)))
+	{
 		stack;
 		ret = ECMD_FAILED;
 	}
@@ -192,10 +195,10 @@ out:
 	return ret;
 }
 
-static int _label_single(struct cmd_context *cmd, struct volume_group *vg,
-		       struct physical_volume *pv, void *handle)
+static int _label_single(struct cmd_context *cmd, struct label *label,
+		         void *handle)
 {
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL))
+	if (!report_object(handle, NULL, NULL, NULL, NULL, NULL, label))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;



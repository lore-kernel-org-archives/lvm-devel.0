From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:20 +0200
Subject: [PATCH 16/20] report: Add a proper "label" field type.
In-Reply-To: <1375125564-1188-1-git-send-email-prockai@redhat.com>
References: <1375125564-1188-1-git-send-email-prockai@redhat.com>
Message-ID: <1375125564-1188-16-git-send-email-prockai@redhat.com>
	(sfid-20130729_211929_213882_F42B5C78)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/report/report.c | 13 +++++++++++--
 lib/report/report.h |  4 +++-
 tools/reporter.c    | 19 +++++++++++--------
 3 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 6c4caf3..912bcde 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -31,6 +31,7 @@ struct lvm_report_object {
 	struct physical_volume *pv;
 	struct lv_segment *seg;
 	struct pv_segment *pvseg;
+	struct label *label;
 };
 
 static const uint64_t _minusone64 = UINT64_C(-1);
@@ -1256,6 +1257,11 @@ static void *_obj_get_pv(void *obj)
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
@@ -1270,7 +1276,7 @@ static const struct dm_report_object_type _report_types[] = {
 	{ VGS, "Volume Group", "vg_", _obj_get_vg },
 	{ LVS, "Logical Volume", "lv_", _obj_get_lv },
 	{ PVS, "Physical Volume", "pv_", _obj_get_pv },
-	{ LABEL, "Physical Volume Label", "pv_", _obj_get_pv },
+	{ LABEL, "Physical Volume Label", "pv_", _obj_get_label },
 	{ SEGS, "Logical Volume Segment", "seg_", _obj_get_seg },
 	{ PVSEGS, "Physical Volume Segment", "pvseg_", _obj_get_pvseg },
 	{ 0, "", "", NULL },
@@ -1291,6 +1297,7 @@ typedef struct logical_volume type_lv;
 typedef struct volume_group type_vg;
 typedef struct lv_segment type_seg;
 typedef struct pv_segment type_pvseg;
+typedef struct label type_label;
 
 static const struct dm_report_field_type _fields[] = {
 #include "columns.h"
@@ -1341,7 +1348,8 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
  */
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
-		  struct lv_segment *seg, struct pv_segment *pvseg)
+		  struct lv_segment *seg, struct pv_segment *pvseg,
+		  struct label *label)
 {
 	struct lvm_report_object obj;
 
@@ -1354,6 +1362,7 @@ int report_object(void *handle, struct volume_group *vg,
 	obj.pv = pv;
 	obj.seg = seg;
 	obj.pvseg = pvseg;
+	obj.label = label ? label : (pv ? pv_label(pv) : NULL);
 
 	return dm_report_object(handle, &obj);
 }
diff --git a/lib/report/report.h b/lib/report/report.h
index 26cc2f7..8a5b946 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -17,6 +17,7 @@
 #define _LVM_REPORT_H
 
 #include "metadata-exported.h"
+#include "label.h"
 
 typedef enum {
 	LVS	= 1,
@@ -40,7 +41,8 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 void report_free(void *handle);
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
-		  struct lv_segment *seg, struct pv_segment *pvseg);
+		  struct lv_segment *seg, struct pv_segment *pvseg,
+		  struct label *label);
 int report_output(void *handle);
 
 #endif
diff --git a/tools/reporter.c b/tools/reporter.c
index a6941e3..6bf2048 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -20,7 +20,7 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name, struct volume_group *vg,
 		       void *handle)
 {
-	if (!report_object(handle, vg, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, vg, NULL, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	check_current_backup(vg);
@@ -31,7 +31,7 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL))
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -40,7 +40,7 @@ static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 static int _segs_single(struct cmd_context *cmd __attribute__((unused)),
 			struct lv_segment *seg, void *handle)
 {
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL))
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -96,7 +96,7 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 	dm_list_init(&_free_logical_volume.snapshot_segs);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
-			   seg ? : &_free_lv_segment, pvseg)) {
+			   seg ? : &_free_lv_segment, pvseg, NULL)) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}
@@ -129,6 +129,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	const char *vg_name = NULL;
 	struct volume_group *old_vg = vg;
 	char uuid[64] __attribute__((aligned(8)));
+	struct label *label;
 
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
@@ -166,7 +167,9 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		pv = pvl->pv;
 	}
 
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL)) {
+	if ((!(label = pv_label(pv))) ||
+	    (!report_object(handle, vg, NULL, pv, NULL, NULL, label)))
+	{
 		stack;
 		ret = ECMD_FAILED;
 	}
@@ -181,10 +184,10 @@ out:
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
-- 
1.8.2



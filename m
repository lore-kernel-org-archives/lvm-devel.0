From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Jul 2014 14:00:16 +0000 (UTC)
Subject: master - reporter: add separate LVSINFO report type
Message-ID: <20140704140016.7CD5F60F98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ecb2be5d1642aa0142d216f9e52f64fd3e8c3fc8
Commit:        ecb2be5d1642aa0142d216f9e52f64fd3e8c3fc8
Parent:        6b58647848dca8f0e7bab04f4c6491dab28173ff
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 2 09:45:53 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 4 15:40:17 2014 +0200

reporter: add separate LVSINFO report type

LVSINFO is exactly the same as existing LVS report type,
but it has the "struct lvinfo" populated in addition for
use - this is useful for fields that display the status
of the LV device itself (e.g. suspended state, tables
present/missing...).

Currently, such properties are reported within the "lv_attr"
field so separation is unnecessary - the "lvinfo" call
to populate the "struct lvinfo" is directly a part of the
field reporting function - _lvstatus_disp/lv_attr_dup.

With upcoming patches, we'd like the lv_attr field bits
to be separated into their own fields. To avoid calling
"lvinfo" fn as many times as there are fields requiring
the "lv_info" structure to be populated while reporting
one row related to one LV, we're separating former LVS
into LVS and LVSINFO report type. With this, there's
just one "lvinfo" call for one report row and LV reporting
fields will take the info needed from this struct then,
hence reusing it and not calling "lvinfo" fn on their own.
---
 lib/report/report.c |   20 ++++++++++++++++----
 lib/report/report.h |   16 +++++++++-------
 tools/reporter.c    |   32 ++++++++++++++++++++++++++------
 3 files changed, 51 insertions(+), 17 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 3b71989..eb4c5ac 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -27,9 +27,14 @@
 
 #include <stddef.h> /* offsetof() */
 
+struct lv_with_info {
+	struct logical_volume *lv;
+	struct lvinfo *info;
+};
+
 struct lvm_report_object {
 	struct volume_group *vg;
-	struct logical_volume *lv;
+	struct lv_with_info *lvi;
 	struct physical_volume *pv;
 	struct lv_segment *seg;
 	struct pv_segment *pvseg;
@@ -1192,7 +1197,12 @@ static void *_obj_get_vg(void *obj)
 
 static void *_obj_get_lv(void *obj)
 {
-	return ((struct lvm_report_object *)obj)->lv;
+	return ((struct lvm_report_object *)obj)->lvi->lv;
+}
+
+static void *_obj_get_lv_with_info(void *obj)
+{
+	return ((struct lvm_report_object *)obj)->lvi;
 }
 
 static void *_obj_get_pv(void *obj)
@@ -1223,6 +1233,7 @@ static void *_obj_get_devtypes(void *obj)
 static const struct dm_report_object_type _report_types[] = {
 	{ VGS, "Volume Group", "vg_", _obj_get_vg },
 	{ LVS, "Logical Volume", "lv_", _obj_get_lv },
+	{ LVSINFO, "Logical Volume Device", "lv_", _obj_get_lv_with_info },
 	{ PVS, "Physical Volume", "pv_", _obj_get_pv },
 	{ LABEL, "Physical Volume Label", "pv_", _obj_get_label },
 	{ SEGS, "Logical Volume Segment", "seg_", _obj_get_seg },
@@ -1318,13 +1329,14 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
 		  struct lv_segment *seg, struct pv_segment *pvseg,
-		  struct label *label)
+		  struct lvinfo *lvinfo, struct label *label)
 {
 	struct device dummy_device = { .dev = 0 };
 	struct label dummy_label = { .dev = &dummy_device };
+	struct lv_with_info lvi = { .lv = lv, .info = lvinfo };
 	struct lvm_report_object obj = {
 		.vg = vg,
-		.lv = lv,
+		.lvi = &lvi,
 		.pv = pv,
 		.seg = seg,
 		.pvseg = pvseg,
diff --git a/lib/report/report.h b/lib/report/report.h
index a89a637..089fc15 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -18,15 +18,17 @@
 
 #include "metadata-exported.h"
 #include "label.h"
+#include "activate.h"
 
 typedef enum {
 	LVS		= 1,
-	PVS		= 2,
-	VGS		= 4,
-	SEGS		= 8,
-	PVSEGS		= 16,
-	LABEL		= 32,
-	DEVTYPES	= 64
+	LVSINFO		= 2,
+	PVS		= 4,
+	VGS		= 8,
+	SEGS		= 16,
+	PVSEGS		= 32,
+	LABEL		= 64,
+	DEVTYPES	= 128
 } report_type_t;
 
 struct field;
@@ -43,7 +45,7 @@ void report_free(void *handle);
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
 		  struct lv_segment *seg, struct pv_segment *pvseg,
-		  struct label *label);
+		  struct lvinfo *lvinfo, struct label *label);
 int report_devtypes(void *handle);
 int report_output(void *handle);
 
diff --git a/tools/reporter.c b/tools/reporter.c
index b08d97b..524d6c4 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -31,7 +31,7 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name, struct volume_group *vg,
 		       void *handle)
 {
-	if (!report_object(handle, vg, NULL, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, vg, NULL, NULL, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	check_current_backup(vg);
@@ -42,7 +42,21 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, NULL, NULL))
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume *lv,
+				 void *handle)
+{
+	struct lvinfo lvinfo;
+
+	if (!lv_info(cmd, lv, 0, &lvinfo, 1, 1))
+		return_ECMD_FAILED;
+
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, &lvinfo, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -51,7 +65,7 @@ static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 static int _segs_single(struct cmd_context *cmd __attribute__((unused)),
 			struct lv_segment *seg, void *handle)
 {
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, NULL))
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -107,7 +121,7 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 	dm_list_init(&_free_logical_volume.snapshot_segs);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
-			   seg ? : &_free_lv_segment, pvseg, pv_label(pvseg->pv))) {
+			   seg ? : &_free_lv_segment, pvseg, NULL, pv_label(pvseg->pv))) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}
@@ -177,7 +191,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		pv = pvl->pv;
 	}
 
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL, NULL)) {
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL, NULL, NULL)) {
 		stack;
 		ret = ECMD_FAILED;
 	}
@@ -195,7 +209,7 @@ out:
 static int _label_single(struct cmd_context *cmd, struct label *label,
 		         void *handle)
 {
-	if (!report_object(handle, NULL, NULL, NULL, NULL, NULL, label))
+	if (!report_object(handle, NULL, NULL, NULL, NULL, NULL, NULL, label))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -378,6 +392,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		report_type = PVS;
 	else if (report_type & SEGS)
 		report_type = SEGS;
+	else if (report_type & LVSINFO)
+		report_type = LVSINFO;
 	else if (report_type & LVS)
 		report_type = LVS;
 
@@ -389,6 +405,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		r = process_each_lv(cmd, argc, argv, 0, report_handle,
 				    &_lvs_single);
 		break;
+	case LVSINFO:
+		r = process_each_lv(cmd, argc, argv, 0, report_handle,
+				    &_lvs_with_info_single);
+		break;
 	case VGS:
 		r = process_each_vg(cmd, argc, argv, 0,
 				    report_handle, &_vgs_single);



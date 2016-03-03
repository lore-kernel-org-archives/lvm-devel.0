From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:09 +0000 (UTC)
Subject: master - report: add full_descendants field to display descendants with history
Message-ID: <20160303132009.C8E69602AD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0339a5f447f8d0b12bb874f19e84427849b33674
Commit:        0339a5f447f8d0b12bb874f19e84427849b33674
Parent:        715f1fb4c4cbdb49a86ee95e17070d0ecc548ee0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:24:48 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:15 2016 +0100

report: add full_descendants field to display descendants with history

Same as lv_full_ancestors, but the other way round in the ancestry chain.
---
 lib/report/columns.h    |    3 +-
 lib/report/properties.c |    2 +
 lib/report/report.c     |  100 ++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 89 insertions(+), 16 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 07ebc44..f22b37a 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -67,7 +67,8 @@ FIELD(LVS, lv, STR, "Origin UUID", lvid, 38, originuuid, origin_uuid, "For snaps
 FIELD(LVS, lv, SIZ, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
 FIELD(LVS, lv, STR_LIST, "Ancestors", lvid, 12, lvancestors, lv_ancestors, "LV ancestors ignoring any stored history of the ancestry chain.", 0)
 FIELD(LVS, lv, STR_LIST, "FAncestors", lvid, 12, lvfullancestors, lv_full_ancestors, "LV ancestors including stored history of the ancestry chain.", 0)
-FIELD(LVS, lv, STR_LIST, "Descendants", lvid, 12, lvdescendants, lv_descendants, "Descendants of this LV.", 0)
+FIELD(LVS, lv, STR_LIST, "Descendants", lvid, 12, lvdescendants, lv_descendants, "LV descendants ignoring any stored history of the ancestry chain.", 0)
+FIELD(LVS, lv, STR_LIST, "FDescendants", lvid, 12, lvfulldescendants, lv_full_descendants, "LV descendants including stored history of the ancestry chain.", 0)
 FIELD(LVS, lv, PCT, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, PCT, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, PCT, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index c879bc8..92e30c9 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -316,6 +316,8 @@ GET_LV_NUM_PROPERTY_FN(origin_size, (SECTOR_SIZE * lv_origin_size(lv)))
 #define _lv_full_ancestors_get prop_not_implemented_get
 #define _lv_descendants_set prop_not_implemented_set
 #define _lv_descendants_get prop_not_implemented_get
+#define _lv_full_descendants_set prop_not_implemented_set
+#define _lv_full_descendants_get prop_not_implemented_get
 GET_LV_NUM_PROPERTY_FN(snap_percent, _snap_percent(lv))
 #define _snap_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(copy_percent, _copy_percent(lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index b1ba9fd..1a4ce42 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2034,33 +2034,70 @@ static int _lvfullancestors_disp(struct dm_report *rh, struct dm_pool *mem,
 }
 
 static int _find_descendants(struct _str_list_append_baton *descendants,
-			     struct logical_volume *lv)
+			     struct generic_logical_volume glv,
+			     int full, int include_historical_lvs)
 {
-	struct logical_volume *descendant_lv = NULL;
+	struct generic_logical_volume glv_next = {0};
 	const struct seg_list *sl;
 	struct lv_segment *seg;
+	struct glv_list *glvl;
+	struct dm_list *list;
+	const char *descendant_str;
+	char buf[64];
 
-	if (lv_is_origin(lv)) {
-		dm_list_iterate_items_gen(seg, &lv->snapshot_segs, origin_list) {
-			if ((descendant_lv = seg->cow)) {
-				if (!_str_list_append(descendant_lv->name, descendants))
+	if (glv.is_historical) {
+		if (full) {
+			list = &glv.historical->indirect_glvs;
+			dm_list_iterate_items(glvl, list) {
+				if (!glvl->glv->is_historical || include_historical_lvs) {
+					if (!(descendant_str = _get_glv_str(buf, sizeof(buf), glvl->glv)))
+						return_0;
+					if (!_str_list_append(descendant_str, descendants))
+						return_0;
+				}
+				if (!_find_descendants(descendants, *glvl->glv, full, include_historical_lvs))
+					return_0;
+			}
+		}
+	} else if (lv_is_origin(glv.live)) {
+		list = &glv.live->snapshot_segs;
+		dm_list_iterate_items_gen(seg, list, origin_list) {
+			if ((glv.live = seg->cow)) {
+				if (!(descendant_str = _get_glv_str(buf, sizeof(buf), &glv)))
 					return_0;
-				if (!_find_descendants(descendants, descendant_lv))
+				if (!_str_list_append(descendant_str, descendants))
+					return_0;
+				if (!_find_descendants(descendants, glv, full, include_historical_lvs))
 					return_0;
 			}
 		}
 	} else {
-		dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+		list = &glv.live->segs_using_this_lv;
+		dm_list_iterate_items(sl, list) {
 			if (lv_is_thin_volume(sl->seg->lv)) {
 				seg = first_seg(sl->seg->lv);
-				if ((seg->origin == lv) || (seg->external_lv == lv))
-					descendant_lv = sl->seg->lv;
+				if ((seg->origin == glv.live) || (seg->external_lv == glv.live)) {
+					glv_next.live = sl->seg->lv;
+					if (!(descendant_str = _get_glv_str(buf, sizeof(buf), &glv_next)))
+						return_0;
+					if (!_str_list_append(descendant_str, descendants))
+						return_0;
+					if (!_find_descendants(descendants, glv_next, full, include_historical_lvs))
+						return_0;
+				}
 			}
+		}
 
-			if (descendant_lv) {
-				if (!_str_list_append(descendant_lv->name, descendants))
-					return_0;
-				if (!_find_descendants(descendants, descendant_lv))
+		if (full) {
+			list = &glv.live->indirect_glvs;
+			dm_list_iterate_items(glvl, list) {
+				if (!glvl->glv->is_historical || include_historical_lvs) {
+					if (!(descendant_str = _get_glv_str(buf, sizeof(buf), glvl->glv)))
+						return_0;
+					if (!_str_list_append(descendant_str, descendants))
+						return_0;
+				}
+				if (!_find_descendants(descendants, *glvl->glv, full, include_historical_lvs))
 					return_0;
 			}
 		}
@@ -2073,14 +2110,47 @@ static int _lvdescendants_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private)
 {
+	struct cmd_context *cmd = (struct cmd_context *) private;
 	struct logical_volume *lv = (struct logical_volume *) data;
 	struct _str_list_append_baton descendants;
+	struct generic_logical_volume glv;
 
 	descendants.mem = mem;
 	if (!(descendants.result = str_list_create(mem)))
 		return_0;
 
-	if (!_find_descendants(&descendants, lv)) {
+	if ((glv.is_historical = lv_is_historical(lv)))
+		glv.historical = lv->this_glv->historical;
+	else
+		glv.live = lv;
+
+	if (!_find_descendants(&descendants, glv, 0, cmd->include_historical_lvs)) {
+		dm_pool_free(descendants.mem, descendants.result);
+		return_0;
+	}
+
+	return _field_set_string_list(rh, field, descendants.result, private, 0, NULL);
+}
+
+static int _lvfulldescendants_disp(struct dm_report *rh, struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data, void *private)
+{
+	struct cmd_context *cmd = (struct cmd_context *) private;
+	struct logical_volume *lv = (struct logical_volume *) data;
+	struct _str_list_append_baton descendants;
+	struct generic_logical_volume glv;
+
+	descendants.mem = mem;
+	if (!(descendants.result = str_list_create(mem)))
+		return_0;
+
+	if ((glv.is_historical = lv_is_historical(lv)))
+		glv.historical = lv->this_glv->historical;
+	else
+		glv.live = lv;
+
+	if (!_find_descendants(&descendants, glv, 1, cmd->include_historical_lvs)) {
 		dm_pool_free(descendants.mem, descendants.result);
 		return_0;
 	}



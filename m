From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:07 +0000 (UTC)
Subject: master - report: add full_ancestors field to display ancestors with history
Message-ID: <20160303132007.B6C9D602AD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=715f1fb4c4cbdb49a86ee95e17070d0ecc548ee0
Commit:        715f1fb4c4cbdb49a86ee95e17070d0ecc548ee0
Parent:        f228750386ae4b5b00375e1a14139b53f86f9cca
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:24:40 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:15 2016 +0100

report: add full_ancestors field to display ancestors with history

The lv_full_ancestors reporting field is just like the existing
lv_ancestors field but it also takes into account any history and
indirect relations recorded.
---
 lib/report/columns.h    |    3 +-
 lib/report/properties.c |    2 +
 lib/report/report.c     |   85 +++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 76 insertions(+), 14 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 11d5639..07ebc44 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -65,7 +65,8 @@ FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, seg_count, "Number of segments
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, origin, "For snapshots, the origin device of this LV.", 0)
 FIELD(LVS, lv, STR, "Origin UUID", lvid, 38, originuuid, origin_uuid, "For snapshots, the UUID of origin device of this LV.", 0)
 FIELD(LVS, lv, SIZ, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
-FIELD(LVS, lv, STR_LIST, "Ancestors", lvid, 12, lvancestors, lv_ancestors, "Ancestors of this LV.", 0)
+FIELD(LVS, lv, STR_LIST, "Ancestors", lvid, 12, lvancestors, lv_ancestors, "LV ancestors ignoring any stored history of the ancestry chain.", 0)
+FIELD(LVS, lv, STR_LIST, "FAncestors", lvid, 12, lvfullancestors, lv_full_ancestors, "LV ancestors including stored history of the ancestry chain.", 0)
 FIELD(LVS, lv, STR_LIST, "Descendants", lvid, 12, lvdescendants, lv_descendants, "Descendants of this LV.", 0)
 FIELD(LVS, lv, PCT, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, PCT, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 9c1b23a..c879bc8 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -312,6 +312,8 @@ GET_LV_NUM_PROPERTY_FN(origin_size, (SECTOR_SIZE * lv_origin_size(lv)))
 #define _origin_size_set prop_not_implemented_set
 #define _lv_ancestors_set prop_not_implemented_set
 #define _lv_ancestors_get prop_not_implemented_get
+#define _lv_full_ancestors_set prop_not_implemented_set
+#define _lv_full_ancestors_get prop_not_implemented_get
 #define _lv_descendants_set prop_not_implemented_set
 #define _lv_descendants_get prop_not_implemented_get
 GET_LV_NUM_PROPERTY_FN(snap_percent, _snap_percent(lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index dfc76bc..b1ba9fd 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1929,26 +1929,52 @@ static int _originuuid_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _do_origin_disp(rh, mem, field, data, private, 1);
 }
 
+static const char *_get_glv_str(char *buf, size_t buf_len,
+				struct generic_logical_volume *glv)
+{
+	if (!glv->is_historical)
+		return glv->live->name;
+
+	if (dm_snprintf(buf, buf_len, "%s%s", HISTORICAL_LV_PREFIX, glv->historical->name) < 0) {
+		log_error("_get_glv_str: dm_snprintf failed");
+		return NULL;
+	}
+
+	return buf;
+}
+
 static int _find_ancestors(struct _str_list_append_baton *ancestors,
-			   struct logical_volume *lv)
+			   struct generic_logical_volume glv,
+			   int full, int include_historical_lvs)
 {
-	struct logical_volume *ancestor_lv = NULL;
 	struct lv_segment *seg;
-
-	if (lv_is_cow(lv)) {
-		ancestor_lv = origin_from_cow(lv);
-	} else 	if (lv_is_thin_volume(lv)) {
-		seg = first_seg(lv);
+	void *orig_p = glv.live;
+	const char *ancestor_str;
+	char buf[NAME_LEN + strlen(HISTORICAL_LV_PREFIX) + 1];
+
+	if (glv.is_historical) {
+		if (full && glv.historical->indirect_origin)
+			glv = *glv.historical->indirect_origin;
+	} else if (lv_is_cow(glv.live)) {
+		glv.live = origin_from_cow(glv.live);
+	} else if (lv_is_thin_volume(glv.live)) {
+		seg = first_seg(glv.live);
 		if (seg->origin)
-			ancestor_lv = seg->origin;
+			glv.live = seg->origin;
 		else if (seg->external_lv)
-			ancestor_lv = seg->external_lv;
+			glv.live = seg->external_lv;
+		else if (full && seg->indirect_origin)
+			glv = *seg->indirect_origin;
 	}
 
-	if (ancestor_lv) {
-		if (!_str_list_append(ancestor_lv->name, ancestors))
+	if (orig_p != glv.live) {
+		if (!(ancestor_str = _get_glv_str(buf, sizeof(buf), &glv)))
 			return_0;
-		if (!_find_ancestors(ancestors, ancestor_lv))
+		if (!glv.is_historical || include_historical_lvs) {
+			if (!_str_list_append(ancestor_str, ancestors))
+				return_0;
+		}
+		if (!_find_ancestors(ancestors, glv, full, include_historical_lvs))
 			return_0;
 	}
 
@@ -1959,14 +1985,21 @@ static int _lvancestors_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
+	struct cmd_context *cmd = (struct cmd_context *) private;
 	struct logical_volume *lv = (struct logical_volume *) data;
 	struct _str_list_append_baton ancestors;
+	struct generic_logical_volume glv;
 
 	ancestors.mem = mem;
 	if (!(ancestors.result = str_list_create(mem)))
 		return_0;
 
-	if (!_find_ancestors(&ancestors, lv)) {
+	if ((glv.is_historical = lv_is_historical(lv)))
+		glv.historical = lv->this_glv->historical;
+	else
+		glv.live = lv;
+
+	if (!_find_ancestors(&ancestors, glv, 0, cmd->include_historical_lvs)) {
 		dm_pool_free(ancestors.mem, ancestors.result);
 		return_0;
 	}
@@ -1974,6 +2007,32 @@ static int _lvancestors_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_string_list(rh, field, ancestors.result, private, 0, NULL);
 }
 
+static int _lvfullancestors_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	struct cmd_context *cmd = (struct cmd_context *) private;
+	struct logical_volume *lv = (struct logical_volume *) data;
+	struct _str_list_append_baton full_ancestors;
+	struct generic_logical_volume glv;
+
+	full_ancestors.mem = mem;
+	if (!(full_ancestors.result = str_list_create(mem)))
+		return_0;
+
+	if ((glv.is_historical = lv_is_historical(lv)))
+		glv.historical = lv->this_glv->historical;
+	else
+		glv.live = lv;
+
+	if (!_find_ancestors(&full_ancestors, glv, 1, cmd->include_historical_lvs)) {
+		dm_pool_free(full_ancestors.mem, full_ancestors.result);
+		return_0;
+	}
+
+	return _field_set_string_list(rh, field, full_ancestors.result, private, 0, NULL);
+}
+
 static int _find_descendants(struct _str_list_append_baton *descendants,
 			     struct logical_volume *lv)
 {



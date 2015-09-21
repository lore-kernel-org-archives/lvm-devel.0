From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Sep 2015 12:46:16 +0000 (UTC)
Subject: master - report: add lv_data_lv_uuid field
Message-ID: <20150921124616.9E1FB60DEC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f61a394be4304fbdbfb94376b4e818b5d64d3cfd
Commit:        f61a394be4304fbdbfb94376b4e818b5d64d3cfd
Parent:        c2ea5b3dee29b072afc52d99bb6c6723072a36a2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 21 13:07:28 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 21 14:21:21 2015 +0200

report: add lv_data_lv_uuid field

---
 lib/metadata/lv.c       |   23 +++++++++++++++++++++--
 lib/metadata/lv.h       |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   29 ++++++++++++++++++++++++-----
 5 files changed, 49 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9604751..02fbd79 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -347,14 +347,33 @@ char *lv_pool_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return _do_lv_pool_lv_dup(mem, lv, 1);
 }
 
-char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+static char *_do_lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
+				int uuid)
 {
 	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
 		first_seg(lv) : NULL;
 
-	return seg ? dm_pool_strdup(mem, seg_lv(seg, 0)->name) : NULL;
+	if (seg) {
+		if (uuid)
+			return lv_uuid_dup(mem, seg_lv(seg, 0));
+		else
+			return lv_name_dup(mem, seg_lv(seg, 0));
+	}
+
+	return NULL;
+}
+
+char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_data_lv_dup(mem, lv, 0);
+}
+
+char *lv_data_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_data_lv_dup(mem, lv, 1);
 }
 
+
 static char *_do_lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
 				    int uuid)
 {
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index e8ced3b..258d826 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -73,6 +73,7 @@ int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_data_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_metadata_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index cf12451..4793eb6 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -81,6 +81,7 @@ FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
 FIELD(LVS, lv, STR, "Data", lvid, 4, datalv, data_lv, "For thin and cache pools, the LV holding the associated data.", 0)
+FIELD(LVS, lv, STR, "Data UUID", lvid, 38, datalvuuid, data_lv_uuid, "For thin and cache pools, the UUID of the LV holding the associated data.", 0)
 FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin and cache pools, the LV holding the associated metadata.", 0)
 FIELD(LVS, lv, STR, "Meta UUID", lvid, 38, metadatalvuuid, metadata_lv_uuid, "For thin and cache pools, the UUID of the LV holding the associated metadata.", 0)
 FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, pool_lv, "For thin volumes, the thin pool LV for this volume.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 24b5ca8..d2760f2 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -334,6 +334,8 @@ GET_LV_STR_PROPERTY_FN(lv_modules, lv_modules_dup(lv->vg->vgmem, lv))
 #define _lv_modules_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(data_lv, lv_data_lv_dup(lv->vg->vgmem, lv))
 #define _data_lv_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(data_lv_uuid, lv_data_lv_uuid_dup(lv->vg->vgmem, lv))
+#define _data_lv_uuid_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(metadata_lv, lv_metadata_lv_dup(lv->vg->vgmem, lv))
 #define _metadata_lv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(metadata_lv_uuid, lv_metadata_lv_uuid_dup(lv->vg->vgmem, lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index 14c2d98..2e1a5ca 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1624,19 +1624,38 @@ static int _lvparent_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, repstr, NULL);
 }
 
-static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-			struct dm_report_field *field,
-			const void *data, void *private __attribute__((unused)))
+static int _do_datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			   struct dm_report_field *field,
+			   const void *data, void *private __attribute__((unused)),
+			   int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const struct lv_segment *seg = (lv_is_pool(lv)) ? first_seg(lv) : NULL;
 
-	if (seg)
-		return _lvname_disp(rh, mem, field, seg_lv(seg, 0), private);
+	if (seg) {
+		if (uuid)
+			return _uuid_disp(rh, mem, field, &seg_lv(seg, 0)->lvid.id[1], private);
+		else
+			return _lvname_disp(rh, mem, field, seg_lv(seg, 0), private);
+	}
 
 	return _field_set_value(field, "", NULL);
 }
 
+static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			struct dm_report_field *field,
+			const void *data, void *private __attribute__((unused)))
+{
+	return _do_datalv_disp(rh, mem, field, data, private, 0);
+}
+
+static int _datalvuuid_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			    struct dm_report_field *field,
+			    const void *data, void *private __attribute__((unused)))
+{
+	return _do_datalv_disp(rh, mem, field, data, private, 1);
+}
+
 static int _do_metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			       struct dm_report_field *field,
 			       const void *data, void *private __attribute__((unused)),



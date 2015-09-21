From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Sep 2015 12:46:25 +0000 (UTC)
Subject: master - report: add lv_convert_lv_uuid field
Message-ID: <20150921124625.16CCF6036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a54b4bba3578e371bb36ddb3b040a71825a62814
Commit:        a54b4bba3578e371bb36ddb3b040a71825a62814
Parent:        0a01c5aa360db1e54b26ad8b9f7ae22abb6cef7b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 21 14:10:21 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 21 14:22:23 2015 +0200

report: add lv_convert_lv_uuid field

---
 lib/metadata/lv.c       |   21 ++++++++++++++++++---
 lib/metadata/lv.h       |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   32 ++++++++++++++++++++++++++------
 5 files changed, 48 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e32564f..8f3500c 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -443,7 +443,8 @@ int lv_kernel_major(const struct logical_volume *lv)
 	return -1;
 }
 
-char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+static char *_do_lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
+				   int uuid)
 {
 	struct lv_segment *seg;
 
@@ -452,12 +453,26 @@ char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 		/* Temporary mirror is always area_num == 0 */
 		if (seg_type(seg, 0) == AREA_LV &&
-		    is_temporary_mirror_layer(seg_lv(seg, 0)))
-			return dm_pool_strdup(mem, seg_lv(seg, 0)->name);
+		    is_temporary_mirror_layer(seg_lv(seg, 0))) {
+			if (uuid)
+				return lv_uuid_dup(mem, seg_lv(seg, 0));
+			else
+				return lv_name_dup(mem, seg_lv(seg, 0));
+		}
 	}
 	return NULL;
 }
 
+char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_convert_lv_dup(mem, lv, 0);
+}
+
+char *lv_convert_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_convert_lv_dup(mem, lv, 1);
+}
+
 static char *_do_lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv,
 				int uuid)
 {
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 879dfe9..efd2a90 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -70,6 +70,7 @@ uint64_t lv_origin_size(const struct logical_volume *lv);
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_move_pv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_convert_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 9578aac..3b58aee 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -80,6 +80,7 @@ FIELD(LVS, lv, NUM, "MaxSync", lvid, 7, raidmaxrecoveryrate, raid_max_recovery_r
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Move UUID", lvid, 38, movepvuuid, move_pv_uuid, "For pvmove, the UUID of Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
+FIELD(LVS, lv, STR, "Convert", lvid, 38, convertlvuuid, convert_lv_uuid, "For lvconvert, UUID of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
 FIELD(LVS, lv, STR, "Log UUID", lvid, 38, loglvuuid, mirror_log_uuid, "For mirrors, the UUID of the LV holding the synchronisation log.", 0)
 FIELD(LVS, lv, STR, "Data", lvid, 4, datalv, data_lv, "For thin and cache pools, the LV holding the associated data.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 5363e3d..72dcaff 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -328,6 +328,8 @@ GET_LV_STR_PROPERTY_FN(move_pv_uuid, lv_move_pv_uuid_dup(lv->vg->vgmem, lv))
 #define _move_pv_uuid_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))
 #define _convert_lv_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(convert_lv_uuid, lv_convert_lv_uuid_dup(lv->vg->vgmem, lv))
+#define _convert_lv_uuid_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
 #define _lv_tags_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(mirror_log, lv_mirror_log_dup(lv->vg->vgmem, lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index b632629..bf2f1c8 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1940,19 +1940,39 @@ static int _movepvuuid_disp(struct dm_report *rh, struct dm_pool *mem __attribut
 	return _do_movepv_disp(rh, mem, field, data, private, 1);
 }
 
-static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-			   struct dm_report_field *field,
-			   const void *data, void *private __attribute__((unused)))
+static int _do_convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			      struct dm_report_field *field,
+			      const void *data, void *private __attribute__((unused)),
+			      int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const char *name;
+	const char *repstr;
 
-	if ((name = lv_convert_lv_dup(mem, lv)))
-		return dm_report_field_string(rh, field, &name);
+	if (uuid)
+		repstr = lv_convert_lv_uuid_dup(mem, lv);
+	else
+		repstr = lv_convert_lv_dup(mem, lv);
+
+	if (repstr)
+		return dm_report_field_string(rh, field, &repstr);
 
 	return _field_set_value(field, "", NULL);
 }
 
+static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			   struct dm_report_field *field,
+			   const void *data, void *private __attribute__((unused)))
+{
+	return _do_convertlv_disp(rh, mem, field, data, private, 0);
+}
+
+static int _convertlvuuid_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			       struct dm_report_field *field,
+			       const void *data, void *private __attribute__((unused)))
+{
+	return _do_convertlv_disp(rh, mem, field, data, private, 1);
+}
+
 static int _size32_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)



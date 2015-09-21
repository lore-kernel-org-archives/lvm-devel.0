From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Sep 2015 12:46:18 +0000 (UTC)
Subject: master - report: add lv_mirror_log_uuid field
Message-ID: <20150921124618.BC07060DEC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ffa7b37b281faaafaa5053d292502dafcdbf27f9
Commit:        ffa7b37b281faaafaa5053d292502dafcdbf27f9
Parent:        f61a394be4304fbdbfb94376b4e818b5d64d3cfd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 21 13:16:48 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 21 14:21:39 2015 +0200

report: add lv_mirror_log_uuid field

---
 lib/metadata/lv.c       |   24 ++++++++++++++++++++----
 lib/metadata/lv.h       |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   32 ++++++++++++++++++++++++++------
 5 files changed, 50 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 02fbd79..0bd455b 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -308,17 +308,33 @@ char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return tags_format_and_copy(mem, modules);
 }
 
-char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv)
+static char *_do_lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv,
+				   int uuid)
 {
 	struct lv_segment *seg;
 
-	dm_list_iterate_items(seg, &lv->segments)
-		if (seg_is_mirrored(seg) && seg->log_lv)
-			return dm_pool_strdup(mem, seg->log_lv->name);
+	dm_list_iterate_items(seg, &lv->segments) {
+		if (seg_is_mirrored(seg) && seg->log_lv) {
+			if (uuid)
+				return lv_uuid_dup(mem, seg->log_lv);
+			else
+				return lv_name_dup(mem, seg->log_lv);
+		}
+	}
 
 	return NULL;
 }
 
+char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_mirror_log_dup(mem, lv, 0);
+}
+
+char *lv_mirror_log_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_mirror_log_dup(mem, lv, 1);
+}
+
 static char *_do_lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
 				int uuid)
 {
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 258d826..875bb20 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -72,6 +72,7 @@ char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_mirror_log_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_data_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 4793eb6..27c1005 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -80,6 +80,7 @@ FIELD(LVS, lv, NUM, "MaxSync", lvid, 7, raidmaxrecoveryrate, raid_max_recovery_r
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
+FIELD(LVS, lv, STR, "Log UUID", lvid, 38, loglvuuid, mirror_log_uuid, "For mirrors, the UUID of the LV holding the synchronisation log.", 0)
 FIELD(LVS, lv, STR, "Data", lvid, 4, datalv, data_lv, "For thin and cache pools, the LV holding the associated data.", 0)
 FIELD(LVS, lv, STR, "Data UUID", lvid, 38, datalvuuid, data_lv_uuid, "For thin and cache pools, the UUID of the LV holding the associated data.", 0)
 FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin and cache pools, the LV holding the associated metadata.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index d2760f2..b151190 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -330,6 +330,8 @@ GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
 #define _lv_tags_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(mirror_log, lv_mirror_log_dup(lv->vg->vgmem, lv))
 #define _mirror_log_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(mirror_log_uuid, lv_mirror_log_uuid_dup(lv->vg->vgmem, lv))
+#define _mirror_log_uuid_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_modules, lv_modules_dup(lv->vg->vgmem, lv))
 #define _lv_modules_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(data_lv, lv_data_lv_dup(lv->vg->vgmem, lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index 2e1a5ca..4cbf824 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1555,19 +1555,39 @@ static int _segtype_disp(struct dm_report *rh __attribute__((unused)),
 	return _field_set_value(field, name, NULL);
 }
 
-static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-		       struct dm_report_field *field,
-		       const void *data, void *private __attribute__((unused)))
+static int _do_loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			  struct dm_report_field *field,
+			  const void *data, void *private __attribute__((unused)),
+			  int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const char *name;
+	const char *repstr = NULL;
 
-	if ((name = lv_mirror_log_dup(mem, lv)))
-		return dm_report_field_string(rh, field, &name);
+	if (uuid)
+		repstr = lv_mirror_log_uuid_dup(mem, lv);
+	else
+		repstr = lv_mirror_log_dup(mem, lv);
+
+	if (repstr)
+		return dm_report_field_string(rh, field, &repstr);
 
 	return _field_set_value(field, "", NULL);
 }
 
+static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+		       struct dm_report_field *field,
+		       const void *data, void *private __attribute__((unused)))
+{
+	return _do_loglv_disp(rh, mem, field, data, private, 0);
+}
+
+static int _loglvuuid_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			   struct dm_report_field *field,
+			   const void *data, void *private __attribute__((unused)))
+{
+	return _do_loglv_disp(rh, mem, field, data, private, 1);
+}
+
 static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))



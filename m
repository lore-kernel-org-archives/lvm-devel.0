From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:36 +0000 (UTC)
Subject: master - lv: add common lv_mirror_log_lv for use in report and dup, use brackets for invisible devices
Message-ID: <20160113134636.BB7846066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d50cd9d8d766671e89f24f7fd0e23dc96f883ea3
Commit:        d50cd9d8d766671e89f24f7fd0e23dc96f883ea3
Parent:        aae45a1f21b94c2f025fdb55e9b8546b5973a107
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 12 11:05:16 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 11:19:51 2016 +0100

lv: add common lv_mirror_log_lv for use in report and dup, use brackets for invisible devices

The common lv_mirror_log_lv fn avoids code duplication and also
the reporting part now uses _lvname_disp and _uuid_disp to display
name and uuid respectively, including brackets for the name if the
dev is invisible.
---
 lib/metadata/lv.c   |   25 +++++++++++++------
 lib/metadata/lv.h   |    1 +
 lib/report/report.c |   64 ++++++++++++++++++++++++--------------------------
 3 files changed, 49 insertions(+), 41 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index a190ae0..ab8a7c4 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -334,23 +334,32 @@ char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return tags_format_and_copy(mem, modules);
 }
 
-static char *_do_lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv,
-				   int uuid)
+struct logical_volume *lv_mirror_log_lv(const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 
 	dm_list_iterate_items(seg, &lv->segments) {
-		if (seg_is_mirrored(seg) && seg->log_lv) {
-			if (uuid)
-				return lv_uuid_dup(mem, seg->log_lv);
-			else
-				return lv_name_dup(mem, seg->log_lv);
-		}
+		if (seg_is_mirrored(seg) && seg->log_lv)
+			return seg->log_lv;
 	}
 
 	return NULL;
 }
 
+static char *_do_lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv,
+				   int uuid)
+{
+	struct logical_volume *mirror_log_lv = lv_mirror_log_lv(lv);
+
+	if (!mirror_log_lv)
+		return NULL;
+
+	if (uuid)
+		return lv_uuid_dup(mem, mirror_log_lv);
+	else
+		return lv_name_dup(mem, mirror_log_lv);
+}
+
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	return _do_lv_mirror_log_dup(mem, lv, 0);
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index e346059..b37cc4e 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -88,6 +88,7 @@ char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv);
 struct logical_volume *lv_parent(const struct logical_volume *lv);
 struct logical_volume *lv_convert_lv(const struct logical_volume *lv);
 struct logical_volume *lv_origin_lv(const struct logical_volume *lv);
+struct logical_volume *lv_mirror_log_lv(const struct logical_volume *lv);
 char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/report.c b/lib/report/report.c
index 9ffaf73..80896b3 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1577,39 +1577,6 @@ static int _segtype_disp(struct dm_report *rh __attribute__((unused)),
 	return _field_set_value(field, name, NULL);
 }
 
-static int _do_loglv_disp(struct dm_report *rh, struct dm_pool *mem,
-			  struct dm_report_field *field,
-			  const void *data, void *private,
-			  int uuid)
-{
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const char *repstr = NULL;
-
-	if (uuid)
-		repstr = lv_mirror_log_uuid_dup(mem, lv);
-	else
-		repstr = lv_mirror_log_dup(mem, lv);
-
-	if (repstr)
-		return _string_disp(rh, mem, field, &repstr, private);
-
-	return _field_set_value(field, "", NULL);
-}
-
-static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-		       struct dm_report_field *field,
-		       const void *data, void *private __attribute__((unused)))
-{
-	return _do_loglv_disp(rh, mem, field, data, private, 0);
-}
-
-static int _loglvuuid_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-			   struct dm_report_field *field,
-			   const void *data, void *private __attribute__((unused)))
-{
-	return _do_loglv_disp(rh, mem, field, data, private, 1);
-}
-
 static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
@@ -1640,6 +1607,37 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, repstr, lvname);
 }
 
+static int _do_loglv_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private,
+			  int uuid)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	struct logical_volume *mirror_log_lv = lv_mirror_log_lv(lv);
+
+	if (!mirror_log_lv)
+		return _field_set_value(field, "", NULL);
+
+	if (uuid)
+		return _uuid_disp(rh, mem, field, &mirror_log_lv->lvid.id[1], private);
+	else
+		return _lvname_disp(rh, mem, field, mirror_log_lv, private);
+}
+
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
 static int _lvfullname_disp(struct dm_report *rh, struct dm_pool *mem,
 			    struct dm_report_field *field,
 			    const void *data, void *private __attribute__((unused)))



From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:32 +0000 (UTC)
Subject: master - lv: add common lv_convert_lv fn for use in report and dup, use brackets for invisible devices
Message-ID: <20160113134632.6A4D46066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1bd83814ce53f07cf93f6f55629f9a81da5aaca3
Commit:        1bd83814ce53f07cf93f6f55629f9a81da5aaca3
Parent:        9e336582f4c9ba185ff7c9ba1031066fbeed863e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 12 10:44:59 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 11:16:37 2016 +0100

lv: add common lv_convert_lv fn for use in report and dup, use brackets for invisible devices

The common lv_convert_lv fn avoids code duplication and also
the reporting part now uses _lvname_disp and _uuid_disp to display
name and uuid respectively, including brackets for the name if the
dev is invisible.
---
 lib/metadata/lv.c   |   27 +++++++++++++++++++--------
 lib/metadata/lv.h   |    1 +
 lib/report/report.c |   18 ++++++++----------
 3 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 0310e70..e1cf5cd 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -462,8 +462,7 @@ int lv_kernel_major(const struct logical_volume *lv)
 	return -1;
 }
 
-static char *_do_lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
-				   int uuid)
+struct logical_volume *lv_convert_lv(const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 
@@ -472,13 +471,25 @@ static char *_do_lv_convert_lv_dup(struct dm_pool *mem, const struct logical_vol
 
 		/* Temporary mirror is always area_num == 0 */
 		if (seg_type(seg, 0) == AREA_LV &&
-		    is_temporary_mirror_layer(seg_lv(seg, 0))) {
-			if (uuid)
-				return lv_uuid_dup(mem, seg_lv(seg, 0));
-			else
-				return lv_name_dup(mem, seg_lv(seg, 0));
-		}
+		    is_temporary_mirror_layer(seg_lv(seg, 0)))
+			return seg_lv(seg, 0);
 	}
+
+	return NULL;
+}
+
+static char *_do_lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
+				   int uuid)
+{
+	struct logical_volume *convert_lv = lv_convert_lv(lv);
+
+	if (convert_lv) {
+		if (uuid)
+			return lv_uuid_dup(mem, convert_lv);
+		else
+			return lv_name_dup(mem, convert_lv);
+	}
+
 	return NULL;
 }
 
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 2f1e4f9..afecd0a 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -86,6 +86,7 @@ char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv);
 struct logical_volume *lv_parent(const struct logical_volume *lv);
+struct logical_volume *lv_convert_lv(const struct logical_volume *lv);
 char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/report.c b/lib/report/report.c
index 9f44212..dad163b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1271,9 +1271,9 @@ static int _chars_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((
 	return dm_report_field_string(rh, field, (const char * const *) &data);
 }
 
-static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+static int _uuid_disp(struct dm_report *rh, struct dm_pool *mem,
 		      struct dm_report_field *field,
-		      const void *data, void *private __attribute__((unused)))
+		      const void *data, void *private)
 {
 	char *repstr;
 
@@ -1968,17 +1968,15 @@ static int _do_convertlv_disp(struct dm_report *rh, struct dm_pool *mem,
 			      int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const char *repstr;
+	const struct logical_volume *convert_lv = lv_convert_lv(lv);
+
+	if (!convert_lv)
+		return _field_set_value(field, "", NULL);
 
 	if (uuid)
-		repstr = lv_convert_lv_uuid_dup(mem, lv);
+		return _uuid_disp(rh, mem, field, &convert_lv->lvid.id[1], private);
 	else
-		repstr = lv_convert_lv_dup(mem, lv);
-
-	if (repstr)
-		return _string_disp(rh, mem, field, &repstr, private);
-
-	return _field_set_value(field, "", NULL);
+		return _lvname_disp(rh, mem, field, convert_lv, private);
 }
 
 static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),



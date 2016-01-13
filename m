From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:34 +0000 (UTC)
Subject: master - lv: add common lv_origin_lv fn for use in report and dup, use brackets for invisible devices
Message-ID: <20160113134634.962946066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aae45a1f21b94c2f025fdb55e9b8546b5973a107
Commit:        aae45a1f21b94c2f025fdb55e9b8546b5973a107
Parent:        1bd83814ce53f07cf93f6f55629f9a81da5aaca3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 12 10:52:34 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 11:19:45 2016 +0100

lv: add common lv_origin_lv fn for use in report and dup, use brackets for invisible devices

The common lv_origin_lv fn avoids code duplication and also
the reporting part now uses _lvname_disp and _uuid_disp to display
name and uuid respectively, including brackets for the name if the
dev is invisible.
---
 lib/metadata/lv.c   |   21 ++++++++++++++-------
 lib/metadata/lv.h   |    1 +
 lib/report/report.c |   19 +++++--------------
 3 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e1cf5cd..a190ae0 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -236,11 +236,9 @@ uint32_t lv_kernel_read_ahead(const struct logical_volume *lv)
 	return info.read_ahead;
 }
 
-static char *_do_lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv,
-			       int uuid)
+struct logical_volume *lv_origin_lv(const struct logical_volume *lv)
 {
-	struct logical_volume *origin;
-
+	struct logical_volume *origin = NULL;
 
 	if (lv_is_cow(lv))
 		origin = origin_from_cow(lv);
@@ -250,13 +248,22 @@ static char *_do_lv_origin_dup(struct dm_pool *mem, const struct logical_volume
 		origin = first_seg(lv)->origin;
 	else if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
 		origin = first_seg(lv)->external_lv;
-	else
+
+	return origin;
+}
+
+static char *_do_lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv,
+			       int uuid)
+{
+	struct logical_volume *origin_lv = lv_origin_lv(lv);
+
+	if (!lv)
 		return NULL;
 
 	if (uuid)
-		return lv_uuid_dup(mem, origin);
+		return lv_uuid_dup(mem, origin_lv);
 	else
-		return lv_name_dup(mem, origin);
+		return lv_name_dup(mem, origin_lv);
 }
 
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index afecd0a..e346059 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -87,6 +87,7 @@ char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv);
 struct logical_volume *lv_parent(const struct logical_volume *lv);
 struct logical_volume *lv_convert_lv(const struct logical_volume *lv);
+struct logical_volume *lv_origin_lv(const struct logical_volume *lv);
 char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/report.c b/lib/report/report.c
index dad163b..9ffaf73 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1795,24 +1795,15 @@ static int _do_origin_disp(struct dm_report *rh, struct dm_pool *mem,
 			   int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const struct lv_segment *seg = first_seg(lv);
-	struct logical_volume *origin;
+	struct logical_volume *origin_lv = lv_origin_lv(lv);
 
-	if (lv_is_cow(lv))
-		origin = origin_from_cow(lv);
-	else if (lv_is_cache(lv) && !lv_is_pending_delete(lv))
-		origin = seg_lv(seg, 0);
-	else if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
-		origin = first_seg(lv)->origin;
-	else if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
-		origin = first_seg(lv)->external_lv;
-	else
+	if (!origin_lv)
 		return _field_set_value(field, "", NULL);
 
 	if (uuid)
-		return _uuid_disp(rh, mem, field, &origin->lvid.id[1], private);
+		return _uuid_disp(rh, mem, field, &origin_lv->lvid.id[1], private);
 	else
-		return _lvname_disp(rh, mem, field, origin, private);
+		return _lvname_disp(rh, mem, field, origin_lv, private);
 }
 
 static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,



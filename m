From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:43 +0000 (UTC)
Subject: master - lv: add common lv_pool_lv fn for use in report and dup, use brackets for invisible devices
Message-ID: <20160113134643.1AA6D6066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1fe7af014003b6a4b1000eaf3f78a61885f8182
Commit:        f1fe7af014003b6a4b1000eaf3f78a61885f8182
Parent:        42fcbc1fd4acd4dc239ef8f24b02fd45f9783567
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 12 11:53:39 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 11:20:01 2016 +0100

lv: add common lv_pool_lv fn for use in report and dup, use brackets for invisible devices

The common lv_pool_lv fn avoids code duplication and also
the reporting part now uses _lvname_disp and _uuid_disp to display
name and uuid respectively, including brackets for the name if the
dev is invisible.
---
 lib/metadata/lv.c   |   27 ++++++++++++++++-----------
 lib/metadata/lv.h   |    1 +
 lib/report/report.c |   16 +++++++---------
 3 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index f308395..368ba19 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -370,22 +370,27 @@ char *lv_mirror_log_uuid_dup(struct dm_pool *mem, const struct logical_volume *l
 	return _do_lv_mirror_log_dup(mem, lv, 1);
 }
 
+struct logical_volume *lv_pool_lv(const struct logical_volume *lv)
+{
+	struct lv_segment *seg = (lv_is_thin_volume(lv) || lv_is_cache(lv)) ?
+				  first_seg(lv) : NULL;
+	struct logical_volume *pool_lv = seg ? seg->pool_lv : NULL;
+
+	return pool_lv;
+}
+
 static char *_do_lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
 				int uuid)
 {
-	struct lv_segment *seg;
+	struct logical_volume *pool_lv = lv_pool_lv(lv);
 
-	dm_list_iterate_items(seg, &lv->segments) {
-		if (seg->pool_lv &&
-		    (seg_is_thin_volume(seg) || seg_is_cache(seg))) {
-			if (uuid)
-				return lv_uuid_dup(mem, seg->pool_lv);
-			else
-				return lv_name_dup(mem, seg->pool_lv);
-		}
-	}
+	if (!pool_lv)
+		return NULL;
 
-	return NULL;
+	if (uuid)
+		return lv_uuid_dup(mem, pool_lv);
+	else
+		return lv_name_dup(mem, pool_lv);
 }
 
 char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index d1c95ed..2834ae5 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -95,6 +95,7 @@ struct logical_volume *lv_origin(const struct logical_volume *lv);
 struct logical_volume *lv_mirror_log(const struct logical_volume *lv);
 struct logical_volume *lv_data(const struct logical_volume *lv);
 struct logical_volume *lv_metadata_lv(const struct logical_volume *lv);
+struct logical_volume *lv_pool_lv(const struct logical_volume *lv);
 char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/report.c b/lib/report/report.c
index a170bfa..4b2c0c0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1732,17 +1732,15 @@ static int _do_poollv_disp(struct dm_report *rh, struct dm_pool *mem,
 			   int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lv_segment *seg = (lv_is_thin_volume(lv) || lv_is_cache(lv)) ?
-				  first_seg(lv) : NULL;
+	struct logical_volume *pool_lv = lv_pool_lv(lv);
 
-	if (seg) {
-		if (uuid)
-			return _uuid_disp(rh, mem, field, &seg->pool_lv->lvid.id[1], private);
-		else
-			return _lvname_disp(rh, mem, field, seg->pool_lv, private);
-	}
+	if (!pool_lv)
+		return _field_set_value(field, "", NULL);
 
-	return _field_set_value(field, "", NULL);
+	if (uuid)
+		return _uuid_disp(rh, mem, field, &pool_lv->lvid.id[1], private);
+	else
+		return _lvname_disp(rh, mem, field, pool_lv, private);
 }
 
 static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),



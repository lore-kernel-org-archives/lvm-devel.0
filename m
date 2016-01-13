From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:38 +0000 (UTC)
Subject: master - lv: add common lv_data_lv fn for use in report and dup, use brackets for invisible devices
Message-ID: <20160113134638.E0AFC6066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cdbf76b2f0c12d6ab12c3d4b2253e60f9f5420d3
Commit:        cdbf76b2f0c12d6ab12c3d4b2253e60f9f5420d3
Parent:        d50cd9d8d766671e89f24f7fd0e23dc96f883ea3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 12 11:15:22 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 11:19:55 2016 +0100

lv: add common lv_data_lv fn for use in report and dup, use brackets for invisible devices

The common lv_data_lv fn avoids code duplication and also
the reporting part now uses _lvname_disp and _uuid_disp to display
name and uuid respectively, including brackets for the name if the
dev is invisible.
---
 lib/metadata/lv.c   |   25 ++++++++++++++++---------
 lib/metadata/lv.h   |    1 +
 lib/report/report.c |   15 +++++++--------
 3 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index ab8a7c4..e8b5ada 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -398,20 +398,27 @@ char *lv_pool_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return _do_lv_pool_lv_dup(mem, lv, 1);
 }
 
+struct logical_volume *lv_data_lv(const struct logical_volume *lv)
+{
+	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
+				  first_seg(lv) : NULL;
+	struct logical_volume *data_lv = seg ? seg_lv(seg, 0) : NULL;
+
+	return data_lv;
+}
+
 static char *_do_lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
 				int uuid)
 {
-	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
-		first_seg(lv) : NULL;
+	struct logical_volume *data_lv = lv_data_lv(lv);
 
-	if (seg) {
-		if (uuid)
-			return lv_uuid_dup(mem, seg_lv(seg, 0));
-		else
-			return lv_name_dup(mem, seg_lv(seg, 0));
-	}
+	if (!data_lv)
+		return NULL;
 
-	return NULL;
+	if (uuid)
+		return lv_uuid_dup(mem, data_lv);
+	else
+		return lv_name_dup(mem, data_lv);
 }
 
 char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index b37cc4e..44f7fda 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -89,6 +89,7 @@ struct logical_volume *lv_parent(const struct logical_volume *lv);
 struct logical_volume *lv_convert_lv(const struct logical_volume *lv);
 struct logical_volume *lv_origin_lv(const struct logical_volume *lv);
 struct logical_volume *lv_mirror_log_lv(const struct logical_volume *lv);
+struct logical_volume *lv_data_lv(const struct logical_volume *lv);
 char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/report.c b/lib/report/report.c
index 80896b3..467cf85 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1670,16 +1670,15 @@ static int _do_datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute
 			   int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const struct lv_segment *seg = (lv_is_pool(lv)) ? first_seg(lv) : NULL;
+	struct logical_volume *data_lv = lv_data_lv(lv);
 
-	if (seg) {
-		if (uuid)
-			return _uuid_disp(rh, mem, field, &seg_lv(seg, 0)->lvid.id[1], private);
-		else
-			return _lvname_disp(rh, mem, field, seg_lv(seg, 0), private);
-	}
+	if (!data_lv)
+		return _field_set_value(field, "", NULL);
 
-	return _field_set_value(field, "", NULL);
+	if (uuid)
+		return _uuid_disp(rh, mem, field, &data_lv->lvid.id[1], private);
+	else
+		return _lvname_disp(rh, mem, field, data_lv, private);
 }
 
 static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),



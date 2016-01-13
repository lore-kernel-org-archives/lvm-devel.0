From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:40 +0000 (UTC)
Subject: master - lv: add common lv_metadata_lv fn for use in report and dup, use brackets for invisible devices
Message-ID: <20160113134640.F22CC6066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42fcbc1fd4acd4dc239ef8f24b02fd45f9783567
Commit:        42fcbc1fd4acd4dc239ef8f24b02fd45f9783567
Parent:        cdbf76b2f0c12d6ab12c3d4b2253e60f9f5420d3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 12 11:23:56 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 11:19:58 2016 +0100

lv: add common lv_metadata_lv fn for use in report and dup, use brackets for invisible devices

The common lv_metadata_lv fn avoids code duplication and also
the reporting part now uses _lvname_disp and _uuid_disp to display
name and uuid respectively, including brackets for the name if the
dev is invisible.
---
 lib/metadata/lv.c   |   24 +++++++++++++++---------
 lib/metadata/lv.h   |    5 +++++
 lib/report/report.c |   15 +++++++--------
 3 files changed, 27 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e8b5ada..f308395 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -431,21 +431,27 @@ char *lv_data_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return _do_lv_data_lv_dup(mem, lv, 1);
 }
 
+struct logical_volume *lv_metadata_lv(const struct logical_volume *lv)
+{
+	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
+				  first_seg(lv) : NULL;
+	struct logical_volume *metadata_lv = seg ? seg->metadata_lv : NULL;
+
+	return metadata_lv;
+}
 
 static char *_do_lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
 				    int uuid)
 {
-	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
-		first_seg(lv) : NULL;
+	struct logical_volume *metadata_lv = lv_metadata_lv(lv);
 
-	if (seg) {
-		if (uuid)
-			return lv_uuid_dup(mem, seg->metadata_lv);
-		else
-			return lv_name_dup(mem, seg->metadata_lv);
-	}
+	if (!metadata_lv)
+		return NULL;
 
-	return NULL;
+	if (uuid)
+		return lv_uuid_dup(mem, metadata_lv);
+	else
+		return lv_name_dup(mem, metadata_lv);
 }
 
 char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 44f7fda..d1c95ed 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -90,6 +90,11 @@ struct logical_volume *lv_convert_lv(const struct logical_volume *lv);
 struct logical_volume *lv_origin_lv(const struct logical_volume *lv);
 struct logical_volume *lv_mirror_log_lv(const struct logical_volume *lv);
 struct logical_volume *lv_data_lv(const struct logical_volume *lv);
+struct logical_volume *lv_convert(const struct logical_volume *lv);
+struct logical_volume *lv_origin(const struct logical_volume *lv);
+struct logical_volume *lv_mirror_log(const struct logical_volume *lv);
+struct logical_volume *lv_data(const struct logical_volume *lv);
+struct logical_volume *lv_metadata_lv(const struct logical_volume *lv);
 char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/report.c b/lib/report/report.c
index 467cf85..a170bfa 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1701,16 +1701,15 @@ static int _do_metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attri
 			       int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const struct lv_segment *seg = (lv_is_pool(lv)) ? first_seg(lv) : NULL;
+	struct logical_volume *metadata_lv = lv_metadata_lv(lv);
 
-	if (seg) {
-		if (uuid)
-			return _uuid_disp(rh, mem, field, &seg->metadata_lv->lvid.id[1], private);
-		else
-			return _lvname_disp(rh, mem, field, seg->metadata_lv, private);
-	}
+	if (!metadata_lv)
+		return _field_set_value(field, "", NULL);		
 
-	return _field_set_value(field, "", NULL);
+	if (uuid)
+		return _uuid_disp(rh, mem, field, &metadata_lv->lvid.id[1], private);
+	else
+		return _lvname_disp(rh, mem, field, metadata_lv, private);
 }
 
 static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),



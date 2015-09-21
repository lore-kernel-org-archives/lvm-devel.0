From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Sep 2015 12:46:12 +0000 (UTC)
Subject: master - report: add lv_origin_uuid field
Message-ID: <20150921124612.6830960DEC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=199697accff0658a11420e263c1f85fb74cd39d3
Commit:        199697accff0658a11420e263c1f85fb74cd39d3
Parent:        cb8f29d1473d993d890387fe24331c9b9fe4713c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 21 12:44:29 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 21 14:20:36 2015 +0200

report: add lv_origin_uuid field

---
 lib/metadata/lv.c       |   36 ++++++++++++++++++++++++++----------
 lib/metadata/lv.h       |    2 ++
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   42 ++++++++++++++++++++++++++++++------------
 5 files changed, 61 insertions(+), 22 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index b3ee72d..7f9f645 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -219,21 +219,37 @@ uint32_t lv_kernel_read_ahead(const struct logical_volume *lv)
 	return info.read_ahead;
 }
 
-char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
+static char *_do_lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv,
+			       int uuid)
 {
-	if (lv_is_cow(lv))
-		return lv_name_dup(mem, origin_from_cow(lv));
+	struct logical_volume *origin;
 
-	if (lv_is_cache(lv) && first_seg(lv)->origin)
-		return lv_name_dup(mem, first_seg(lv)->origin);
 
-	if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
-		return lv_name_dup(mem, first_seg(lv)->origin);
+	if (lv_is_cow(lv))
+		origin = origin_from_cow(lv);
+	else if (lv_is_cache(lv) && first_seg(lv)->origin)
+		origin = first_seg(lv)->origin;
+	else if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
+		origin = first_seg(lv)->origin;
+	else if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
+		origin = first_seg(lv)->external_lv;
+	else
+		return NULL;
 
-	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
-		return lv_name_dup(mem, first_seg(lv)->external_lv);
+	if (uuid)
+		return lv_uuid_dup(mem, origin);
+	else
+		return lv_name_dup(mem, origin);
+}
 
-	return NULL;
+char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_origin_dup(mem, lv, 0);
+}
+
+char *lv_origin_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_origin_dup(mem, lv, 1);
 }
 
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 3986457..47eedb2 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -83,6 +83,8 @@ char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv);
 struct logical_volume *lv_parent(const struct logical_volume *lv);
 char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_origin_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
+
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
 const char *lvseg_name(const struct lv_segment *seg);
 uint64_t lvseg_start(const struct lv_segment *seg);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index d704101..2c80904 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -63,6 +63,7 @@ FIELD(LVS, lv, SIZ, "LSize", size, 5, size64, lv_size, "Size of LV in current un
 FIELD(LVS, lv, SIZ, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thin and cache pools, the size of the LV that holds the metadata.", 0)
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, seg_count, "Number of segments in LV.", 0)
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, origin, "For snapshots, the origin device of this LV.", 0)
+FIELD(LVS, lv, STR, "Origin UUID", lvid, 38, originuuid, origin_uuid, "For snapshots, the UUID of origin device of this LV.", 0)
 FIELD(LVS, lv, SIZ, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
 FIELD(LVS, lv, STR_LIST, "Ancestors", lvid, 12, lvancestors, lv_ancestors, "Ancestors of this LV.", 0)
 FIELD(LVS, lv, STR_LIST, "Descendants", lvid, 12, lvdescendants, lv_descendants, "Descendants of this LV.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index ec5b415..3654a37 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -298,6 +298,8 @@ GET_LV_NUM_PROPERTY_FN(seg_count, dm_list_size(&lv->segments))
 #define _seg_count_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(origin, lv_origin_dup(lv->vg->vgmem, lv))
 #define _origin_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(origin_uuid, lv_origin_uuid_dup(lv->vg->vgmem, lv))
+#define _origin_uuid_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(origin_size, (SECTOR_SIZE * lv_origin_size(lv)))
 #define _origin_size_set prop_not_implemented_set
 #define _lv_ancestors_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 26b7eac..714f668 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1709,26 +1709,44 @@ static int _lvdmpath_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, repstr, NULL);
 }
 
-static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
-			struct dm_report_field *field,
-			const void *data, void *private)
+static int _do_origin_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private,
+			   int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const struct lv_segment *seg = first_seg(lv);
+	struct logical_volume *origin;
 
 	if (lv_is_cow(lv))
-		return _lvname_disp(rh, mem, field, origin_from_cow(lv), private);
-
-	if (lv_is_cache(lv) && !lv_is_pending_delete(lv))
-		return _lvname_disp(rh, mem, field, seg_lv(seg, 0), private);
+		origin = origin_from_cow(lv);
+	else if (lv_is_cache(lv) && !lv_is_pending_delete(lv))
+		origin = seg_lv(seg, 0);
+	else if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
+		origin = first_seg(lv)->origin;
+	else if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
+		origin = first_seg(lv)->external_lv;
+	else
+		return _field_set_value(field, "", NULL);
 
-	if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
-		return _lvname_disp(rh, mem, field, first_seg(lv)->origin, private);
+	if (uuid)
+		return _uuid_disp(rh, mem, field, &origin->lvid.id[1], private);
+	else
+		return _lvname_disp(rh, mem, field, origin, private);
+}
 
-	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
-		return _lvname_disp(rh, mem, field, first_seg(lv)->external_lv, private);
+static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	return _do_origin_disp(rh, mem, field, data, private, 0);
+}
 
-	return _field_set_value(field, "", NULL);
+static int _originuuid_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	return _do_origin_disp(rh, mem, field, data, private, 1);
 }
 
 static int _find_ancestors(struct _str_list_append_baton *ancestors,



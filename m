From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Sep 2015 12:46:10 +0000 (UTC)
Subject: master - report: add lv_pool_lv_uuid field
Message-ID: <20150921124610.3EBCA61059@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb8f29d1473d993d890387fe24331c9b9fe4713c
Commit:        cb8f29d1473d993d890387fe24331c9b9fe4713c
Parent:        0e3042f488dd22b99b4ac0705a18bb03ee48a4d3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 21 12:28:58 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 21 14:20:12 2015 +0200

report: add lv_pool_lv_uuid field

---
 lib/metadata/lv.c       |   24 ++++++++++++++++++++----
 lib/metadata/lv.h       |    2 ++
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   29 ++++++++++++++++++++++++-----
 5 files changed, 49 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 3009149..b3ee72d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -303,18 +303,34 @@ char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return NULL;
 }
 
-char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+static char *_do_lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
+				int uuid)
 {
 	struct lv_segment *seg;
 
-	dm_list_iterate_items(seg, &lv->segments)
+	dm_list_iterate_items(seg, &lv->segments) {
 		if (seg->pool_lv &&
-		    (seg_is_thin_volume(seg) || seg_is_cache(seg)))
-			return dm_pool_strdup(mem, seg->pool_lv->name);
+		    (seg_is_thin_volume(seg) || seg_is_cache(seg))) {
+			if (uuid)
+				return lv_uuid_dup(mem, seg->pool_lv);
+			else
+				return lv_name_dup(mem, seg->pool_lv);
+		}
+	}
 
 	return NULL;
 }
 
+char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_pool_lv_dup(mem, lv, 0);
+}
+
+char *lv_pool_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_pool_lv_dup(mem, lv, 1);
+}
+
 char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index bc82d3e..3986457 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -75,6 +75,8 @@ char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_pool_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
+
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index fe9aad9..d704101 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -82,6 +82,7 @@ FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV hold
 FIELD(LVS, lv, STR, "Data", lvid, 4, datalv, data_lv, "For thin and cache pools, the LV holding the associated data.", 0)
 FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin and cache pools, the LV holding the associated metadata.", 0)
 FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, pool_lv, "For thin volumes, the thin pool LV for this volume.", 0)
+FIELD(LVS, lv, STR, "Pool UUID", lvid, 38, poollvuuid, pool_lv_uuid, "For thin volumes, the UUID of the thin pool LV for this volume.", 0)
 FIELD(LVS, lv, STR_LIST, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration profile attached to this LV.", 0)
 FIELD(LVS, lv, STR, "Lock Args", lvid, 9, lvlockargs, lv_lockargs, "Lock args of the LV used by lvmlockd.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 4b2aff5..ec5b415 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -336,6 +336,8 @@ GET_LV_STR_PROPERTY_FN(metadata_lv, lv_metadata_lv_dup(lv->vg->vgmem, lv))
 #define _metadata_lv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(pool_lv, lv_pool_lv_dup(lv->vg->vgmem, lv))
 #define _pool_lv_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(pool_lv_uuid, lv_pool_lv_uuid_dup(lv->vg->vgmem, lv))
+#define _pool_lv_uuid_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(data_percent, _data_percent(lv))
 #define _data_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(metadata_percent, _metadata_percent(lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index 1c6ce5b..26b7eac 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1650,20 +1650,39 @@ static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribut
 	return _field_set_value(field, "", NULL);
 }
 
-static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-			struct dm_report_field *field,
-			const void *data, void *private __attribute__((unused)))
+static int _do_poollv_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private,
+			   int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lv_segment *seg = (lv_is_thin_volume(lv) || lv_is_cache(lv)) ?
 				  first_seg(lv) : NULL;
 
-	if (seg)
-		return _lvname_disp(rh, mem, field, seg->pool_lv, private);
+	if (seg) {
+		if (uuid)
+			return _uuid_disp(rh, mem, field, &seg->pool_lv->lvid.id[1], private);
+		else
+			return _lvname_disp(rh, mem, field, seg->pool_lv, private);
+	}
 
 	return _field_set_value(field, "", NULL);
 }
 
+static int _poollv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			struct dm_report_field *field,
+			const void *data, void *private __attribute__((unused)))
+{
+	return _do_poollv_disp(rh, mem, field, data, private, 0);
+}
+
+static int _poollvuuid_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private __attribute__((unused)))
+{
+	return _do_poollv_disp(rh, mem, field, data, private, 1);
+}
+
 static int _lvpath_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))



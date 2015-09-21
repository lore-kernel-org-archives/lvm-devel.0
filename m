From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Sep 2015 12:46:14 +0000 (UTC)
Subject: master - report: add lv_metadata_lv_uuid field
Message-ID: <20150921124614.8790F60DEC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2ea5b3dee29b072afc52d99bb6c6723072a36a2
Commit:        c2ea5b3dee29b072afc52d99bb6c6723072a36a2
Parent:        199697accff0658a11420e263c1f85fb74cd39d3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 21 12:59:08 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 21 14:20:58 2015 +0200

report: add lv_metadata_lv_uuid field

---
 lib/metadata/lv.c       |   22 ++++++++++++++++++++--
 lib/metadata/lv.h       |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   29 ++++++++++++++++++++++++-----
 5 files changed, 48 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 7f9f645..9604751 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -355,12 +355,30 @@ char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return seg ? dm_pool_strdup(mem, seg_lv(seg, 0)->name) : NULL;
 }
 
-char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+static char *_do_lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
+				    int uuid)
 {
 	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
 		first_seg(lv) : NULL;
 
-	return seg ? dm_pool_strdup(mem, seg->metadata_lv->name) : NULL;
+	if (seg) {
+		if (uuid)
+			return lv_uuid_dup(mem, seg->metadata_lv);
+		else
+			return lv_name_dup(mem, seg->metadata_lv);
+	}
+
+	return NULL;
+}
+
+char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_metadata_lv_dup(mem, lv, 0);
+}
+
+char *lv_metadata_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_metadata_lv_dup(mem, lv, 1);
 }
 
 const char *lv_layer(const struct logical_volume *lv)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 47eedb2..e8ced3b 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -74,6 +74,7 @@ int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_data_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_metadata_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_pool_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 2c80904..cf12451 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -82,6 +82,7 @@ FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, N
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
 FIELD(LVS, lv, STR, "Data", lvid, 4, datalv, data_lv, "For thin and cache pools, the LV holding the associated data.", 0)
 FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin and cache pools, the LV holding the associated metadata.", 0)
+FIELD(LVS, lv, STR, "Meta UUID", lvid, 38, metadatalvuuid, metadata_lv_uuid, "For thin and cache pools, the UUID of the LV holding the associated metadata.", 0)
 FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, pool_lv, "For thin volumes, the thin pool LV for this volume.", 0)
 FIELD(LVS, lv, STR, "Pool UUID", lvid, 38, poollvuuid, pool_lv_uuid, "For thin volumes, the UUID of the thin pool LV for this volume.", 0)
 FIELD(LVS, lv, STR_LIST, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 3654a37..24b5ca8 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -336,6 +336,8 @@ GET_LV_STR_PROPERTY_FN(data_lv, lv_data_lv_dup(lv->vg->vgmem, lv))
 #define _data_lv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(metadata_lv, lv_metadata_lv_dup(lv->vg->vgmem, lv))
 #define _metadata_lv_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(metadata_lv_uuid, lv_metadata_lv_uuid_dup(lv->vg->vgmem, lv))
+#define _metadata_lv_uuid_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(pool_lv, lv_pool_lv_dup(lv->vg->vgmem, lv))
 #define _pool_lv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(pool_lv_uuid, lv_pool_lv_uuid_dup(lv->vg->vgmem, lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index 714f668..14c2d98 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1637,19 +1637,38 @@ static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	return _field_set_value(field, "", NULL);
 }
 
-static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-			    struct dm_report_field *field,
-			    const void *data, void *private __attribute__((unused)))
+static int _do_metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			       struct dm_report_field *field,
+			       const void *data, void *private __attribute__((unused)),
+			       int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const struct lv_segment *seg = (lv_is_pool(lv)) ? first_seg(lv) : NULL;
 
-	if (seg)
-		return _lvname_disp(rh, mem, field, seg->metadata_lv, private);
+	if (seg) {
+		if (uuid)
+			return _uuid_disp(rh, mem, field, &seg->metadata_lv->lvid.id[1], private);
+		else
+			return _lvname_disp(rh, mem, field, seg->metadata_lv, private);
+	}
 
 	return _field_set_value(field, "", NULL);
 }
 
+static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			    struct dm_report_field *field,
+			    const void *data, void *private __attribute__((unused)))
+{
+	return _do_metadatalv_disp(rh, mem, field, data, private, 0);
+}
+
+static int _metadatalvuuid_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+				struct dm_report_field *field,
+				const void *data, void *private __attribute__((unused)))
+{
+	return _do_metadatalv_disp(rh, mem, field, data, private, 1);
+}
+
 static int _do_poollv_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private,



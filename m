From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Sep 2015 12:46:23 +0000 (UTC)
Subject: master - report: add lv_move_pv_uuid field
Message-ID: <20150921124623.05BCD60079@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a01c5aa360db1e54b26ad8b9f7ae22abb6cef7b
Commit:        0a01c5aa360db1e54b26ad8b9f7ae22abb6cef7b
Parent:        f01b7afa19433e4d428478fd0bb5e5a33d45685e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 21 14:01:41 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 21 14:22:03 2015 +0200

report: add lv_move_pv_uuid field

---
 lib/metadata/lv.c       |   24 +++++++++++++++++++-----
 lib/metadata/lv.h       |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   32 ++++++++++++++++++++++++++------
 5 files changed, 49 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 0bd455b..e32564f 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -458,11 +458,12 @@ char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return NULL;
 }
 
-char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+static char *_do_lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv,
+				int uuid)
 {
 	struct logical_volume *mimage0_lv;
 	struct lv_segment *seg;
-	const struct device *dev;
+	struct pv_segment *pvseg;
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		if (seg->status & PVMOVE) {
@@ -473,17 +474,30 @@ char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 						  "Bad pvmove structure");
 					return NULL;
 				}
-				dev = seg_dev(first_seg(mimage0_lv), 0);
+				pvseg = seg_pvseg(first_seg(mimage0_lv), 0);
 			} else /* Segment pvmove */
-				dev = seg_dev(seg, 0);
+				pvseg = seg_pvseg(seg, 0);
 
-			return dm_pool_strdup(mem, dev_name(dev));
+			if (uuid)
+				return pv_uuid_dup(mem, pvseg->pv);
+			else
+				return pv_name_dup(mem, pvseg->pv);
 		}
 	}
 
 	return NULL;
 }
 
+char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_move_pv_dup(mem, lv, 0);
+}
+
+char *lv_move_pv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return _do_lv_move_pv_dup(mem, lv, 1);
+}
+
 uint64_t lv_origin_size(const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 875bb20..879dfe9 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -68,6 +68,7 @@ char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_dmpath_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint64_t lv_origin_size(const struct logical_volume *lv);
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_move_pv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 27c1005..9578aac 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -78,6 +78,7 @@ FIELD(LVS, lv, NUM, "WBehind", lvid, 7, raidwritebehind, raid_write_behind, "For
 FIELD(LVS, lv, NUM, "MinSync", lvid, 7, raidminrecoveryrate, raid_min_recovery_rate, "For RAID1, the minimum recovery I/O load in kiB/sec/disk.", 0)
 FIELD(LVS, lv, NUM, "MaxSync", lvid, 7, raidmaxrecoveryrate, raid_max_recovery_rate, "For RAID1, the maximum recovery I/O load in kiB/sec/disk.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
+FIELD(LVS, lv, STR, "Move UUID", lvid, 38, movepvuuid, move_pv_uuid, "For pvmove, the UUID of Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
 FIELD(LVS, lv, STR, "Log UUID", lvid, 38, loglvuuid, mirror_log_uuid, "For mirrors, the UUID of the LV holding the synchronisation log.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 6f55a56..5363e3d 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -324,6 +324,8 @@ GET_LV_STR_PROPERTY_FN(raid_sync_action, _raidsyncaction(lv))
 #define _raid_sync_action_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(move_pv_uuid, lv_move_pv_uuid_dup(lv->vg->vgmem, lv))
+#define _move_pv_uuid_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))
 #define _convert_lv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index 4cbf824..b632629 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1907,19 +1907,39 @@ static int _lvdescendants_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_string_list(rh, field, descendants.result, private, 0);
 }
 
-static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-			struct dm_report_field *field,
-			const void *data, void *private __attribute__((unused)))
+static int _do_movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			   struct dm_report_field *field,
+			   const void *data, void *private __attribute__((unused)),
+			   int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const char *name;
+	const char *repstr;
 
-	if ((name = lv_move_pv_dup(mem, lv)))
-		return dm_report_field_string(rh, field, &name);
+	if (uuid)
+		repstr = lv_move_pv_uuid_dup(mem, lv);
+	else
+		repstr = lv_move_pv_dup(mem, lv);
+
+	if (repstr)
+		return dm_report_field_string(rh, field, &repstr);
 
 	return _field_set_value(field, "", NULL);
 }
 
+static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			struct dm_report_field *field,
+			const void *data, void *private __attribute__((unused)))
+{
+	return _do_movepv_disp(rh, mem, field, data, private, 0);
+}
+
+static int _movepvuuid_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			    struct dm_report_field *field,
+			    const void *data, void *private __attribute__((unused)))
+{
+	return _do_movepv_disp(rh, mem, field, data, private, 1);
+}
+
 static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			   struct dm_report_field *field,
 			   const void *data, void *private __attribute__((unused)))



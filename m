From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 Jan 2015 09:50:43 +0000 (UTC)
Subject: master - report: rename lv_error_when_full field to lv_when_full and display either "error", "queue" or ""
Message-ID: <20150121095043.E095960057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7bcb3fb02d6aacc566871326c0d01c331497a5b2
Commit:        7bcb3fb02d6aacc566871326c0d01c331497a5b2
Parent:        5e8f362c9eaae7bbcf69fd779d8c441f7de9042a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 21 10:43:40 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 21 10:50:32 2015 +0100

report: rename lv_error_when_full field to lv_when_full and display either "error", "queue" or ""

Rename original lv_error_when_full field to lv_when_full and also
convert it from binary field to string field displaying three
possible values: "error", "queueu" or "" (blank for undefined).

$ lvs vg/pool vg/pool1 vg/linear_lv -o+lv_when_full
  LV        VG   Attr       LSize Data%  Meta%  WhenFull
  linear_lv vg   -wi-a----- 4.00m
  pool      vg   twi-aotz-- 4.00m 0.00   0.98   queue
  pool1     vg   twi-a-tz-- 4.00m 0.00   0.88   error

For -S|--select these synonyms are recognized:

"error" -> "error when full", "error if no space"
"queue" -> "queue when full", "queue if no space"
   ""   -> "undefined"
---
 WHATS_NEW               |    2 +-
 lib/metadata/lv.c       |    5 -----
 lib/report/columns.h    |    2 +-
 lib/report/properties.c |    4 ++--
 lib/report/report.c     |   19 ++++++++++++++-----
 lib/report/values.h     |    4 +++-
 6 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 022e4cf..f0b6991 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -4,7 +4,7 @@ Version 2.02.115 -
   Support lvchange --errorwhenfull for thin pools.
   Improve the processing and reporting of duplicate PVs.
   Report lv_health_status and health attribute also for thin pool.
-  Add lv_error_when_full reporting field.
+  Add lv_when_full reporting field.
   Add support for lvcreate --errorwhenfull y|n for thin pools.
   Fix lvconvert --repair to honour resilience requirement for segmented RAID LV.
   Filter out partitioned device-mapper devices as unsuitable for use as PVs.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index eb67d20..683ec47 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -211,11 +211,6 @@ uint64_t lvseg_size(const struct lv_segment *seg)
 	return (uint64_t) seg->len * seg->lv->vg->extent_size;
 }
 
-uint32_t lv_error_when_full(const struct logical_volume *lv)
-{
-	return (lv_is_thin_pool(lv) && (lv->status & LV_ERROR_WHEN_FULL)) ? 1 : 0;
-}
-
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv)
 {
 	struct lvinfo info;
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 25eca80..449536b 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -51,7 +51,7 @@ FIELD(LVS, lv, BIN, "FixMin", lvid, 10, lvfixedminor, lv_fixed_minor, "Set if LV
 FIELD(LVS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Set if snapshot merge failed.", 0)
 FIELD(LVS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Set if snapshot LV is invalid.", 0)
 FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Set if LV is skipped on activation.", 0)
-FIELD(LVS, lv, BIN, "WhenFull", lvid, 15, lverrorwhenfull, lv_error_when_full, "For thin pools, behavior when full.", 0)
+FIELD(LVS, lv, STR, "WhenFull", lvid, 15, lvwhenfull, lv_when_full, "For thin pools, behavior when full.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, BIN, "ActLocal", lvid, 10, lvactivelocally, lv_active_locally, "Set if the LV is active locally.", 0)
 FIELD(LVS, lv, BIN, "ActRemote", lvid, 10, lvactiveremotely, lv_active_remotely, "Set if the LV is active remotely.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index cece62c..8866928 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -281,8 +281,8 @@ GET_LV_STR_PROPERTY_FN(lv_attr, lv_attr_dup(lv->vg->vgmem, lv))
 GET_LV_NUM_PROPERTY_FN(lv_major, lv->major)
 #define _lv_major_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_minor, lv->minor)
-#define _lv_error_when_full_set prop_not_implemented_set
-GET_LV_NUM_PROPERTY_FN(lv_error_when_full, lv_error_when_full(lv))
+#define _lv_when_full_get prop_not_implemented_get
+#define _lv_when_full_set prop_not_implemented_set
 #define _lv_minor_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_read_ahead, lv->read_ahead * SECTOR_SIZE)
 #define _lv_read_ahead_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 3331e5e..53de714 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -729,14 +729,23 @@ static int _int32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((
 	return dm_report_field_int32(rh, field, data);
 }
 
-static int _lverrorwhenfull_disp(struct dm_report *rh, struct dm_pool *mem,
-				 struct dm_report_field *field,
-				 const void *data, void *private __attribute__((unused)))
+static int _lvwhenfull_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
-	return _binary_disp(rh, mem, field, lv_error_when_full(lv),
-			    GET_FIRST_RESERVED_NAME(lv_error_when_full_y), private);
+	if (lv_is_thin_pool(lv)) {
+		if (lv->status & LV_ERROR_WHEN_FULL)
+			return _field_set_value(field, GET_FIRST_RESERVED_NAME(lv_when_full_error),
+						GET_FIELD_RESERVED_VALUE(lv_when_full_error));
+		else
+			return _field_set_value(field, GET_FIRST_RESERVED_NAME(lv_when_full_queue),
+						GET_FIELD_RESERVED_VALUE(lv_when_full_queue));
+	}
+
+	return _field_set_value(field, GET_FIRST_RESERVED_NAME(lv_when_full_undef),
+				GET_FIELD_RESERVED_VALUE(lv_when_full_undef));
 }
 
 static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
diff --git a/lib/report/values.h b/lib/report/values.h
index 9d7b272..bc42563 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -68,7 +68,6 @@ FIELD_RESERVED_BINARY_VALUE(lv_image_synced, lv_image_synced, "", "image synced"
 FIELD_RESERVED_BINARY_VALUE(lv_merging, lv_merging, "", "merging")
 FIELD_RESERVED_BINARY_VALUE(lv_converting, lv_converting, "", "converting")
 FIELD_RESERVED_BINARY_VALUE(lv_allocation_locked, lv_allocation_locked, "", "allocation locked", "locked")
-FIELD_RESERVED_BINARY_VALUE(lv_error_when_full, lv_error_when_full, "", "error when full", "error if no space", "error")
 FIELD_RESERVED_BINARY_VALUE(lv_fixed_minor, lv_fixed_minor, "", "fixed minor", "fixed")
 FIELD_RESERVED_BINARY_VALUE(lv_active_locally, lv_active_locally, "", "active locally", "active", "locally")
 FIELD_RESERVED_BINARY_VALUE(lv_active_remotely, lv_active_remotely, "", "active remotely", "active", "remotely")
@@ -85,6 +84,9 @@ FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, "", "writeable", "writea
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", "read-only", "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")
 FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead_auto, "", &GET_TYPE_RESERVED_VALUE(num_undef_64), "auto")
+FIELD_RESERVED_VALUE(lv_when_full, lv_when_full_error, "", "error", "error", "error when full", "error if no space")
+FIELD_RESERVED_VALUE(lv_when_full, lv_when_full_queue, "", "queue", "queue", "queue when full", "queue if no space")
+FIELD_RESERVED_VALUE(lv_when_full, lv_when_full_undef, "", "", "", "undefined")
 
 /* Reserved values for SEG fields */
 FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "", "", "undefined")



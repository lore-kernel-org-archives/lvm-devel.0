From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 14 Jan 2016 15:56:44 +0000 (UTC)
Subject: master - report: add kernel_discards report field to display thin pool discard used in kernel
Message-ID: <20160114155644.D045060DFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b82d5ee0926acee37356f5a322edbb4694081699
Commit:        b82d5ee0926acee37356f5a322edbb4694081699
Parent:        6d09c8c2c45ea1dea243134b8badc841a87cc979
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jan 14 16:54:12 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jan 14 16:54:12 2016 +0100

report: add kernel_discards report field to display thin pool discard used in kernel

Thin pool discard mode set in metadata can be different from the one
actually used if any device underneath does not support that mode. Add
kernel_discard report field to make it possible to see this difference.
---
 WHATS_NEW                   |    1 +
 lib/metadata/lv.c           |   39 +++++++++++++++++++++++++++++++++++++++
 lib/metadata/lv.h           |    2 ++
 lib/report/columns.h        |    1 +
 lib/report/properties.c     |    2 ++
 lib/report/report.c         |   17 +++++++++++++++++
 lib/report/values.h         |    1 +
 test/shell/discards-thin.sh |   27 +++++++++++++++++++++++++++
 8 files changed, 90 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ae70f5a..b64f725 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.140 -
 ===================================
+  Add kernel_discards report field to display thin pool discard used in kernel.
   Correct checking of target presence when driver access is disabled.
   Eval poolmetadatasize arg earlier in lvresize.
   Fix vgcfgrestore to respect allocatable attribute of PVs.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 6575cc9..49c195f 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -162,6 +162,45 @@ char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
 	return  dm_pool_strdup(mem, get_pool_discards_name(seg->discards));
 }
 
+char *lvseg_kernel_discards_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm)
+{
+	const char *s = "";
+	char *ret;
+
+	if (lvdm->seg_status.type == SEG_STATUS_THIN_POOL)
+		s = get_pool_discards_name(lvdm->seg_status.thin_pool->discards);
+
+	if (!(ret = dm_pool_strdup(mem, s))) {
+		log_error("lvseg_kernel_discards_dup_with_info_and_seg_status: dm_pool_strdup failed");
+		return NULL;
+	}
+
+	return ret;
+}
+
+char *lvseg_kernel_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	char *ret = NULL;
+	struct lv_with_info_and_seg_status status = {
+		.seg_status.type = SEG_STATUS_NONE,
+		.seg_status.seg = seg
+	};
+
+	if (!lv_is_thin_pool(seg->lv))
+		return NULL;
+
+	if (!(status.seg_status.mem = dm_pool_create("reporter_pool", 1024)))
+		return_NULL;
+
+	if (!(status.info_ok = lv_info_with_seg_status(seg->lv->vg->cmd, seg->lv, seg, 1, &status, 0, 0)))
+		goto_bad;
+
+	ret = lvseg_kernel_discards_dup_with_info_and_seg_status(mem, &status);
+bad:
+	dm_pool_destroy(status.seg_status.mem);
+	return ret;
+}
+
 char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg)
 {
 	const char *name = get_cache_mode_name(seg);
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index bbd4564..18c662b 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -95,6 +95,7 @@ char *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment
 int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
+char *lvseg_kernel_discards_dup(struct dm_pool *mem, const struct lv_segment *seg);
 
 /* LV modification functions */
 int lv_set_creation(struct logical_volume *lv,
@@ -137,4 +138,5 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_lock_args_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lvseg_kernel_discards_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm);
 #endif /* _LVM_LV_H */
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 41a03f4..e097fec 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -113,6 +113,7 @@ FIELD(LVSSTATUS, lv, NUM, "CacheReadMisses", lvid, 16, cache_read_misses, cache_
 FIELD(LVSSTATUS, lv, NUM, "CacheWriteHits", lvid, 16, cache_write_hits, cache_write_hits, "Cache write hits.", 0)
 FIELD(LVSSTATUS, lv, NUM, "CacheWriteMisses", lvid, 16, cache_write_misses, cache_write_misses, "Cache write misses.", 0)
 FIELD(LVSSTATUS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
+FIELD(LVSSTATUS, lv, STR, "KDiscards", lvid, 8, kdiscards, kernel_discards, "For thin pools, how discards are handled in kernel.", 0)
 
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 7dafbe5..705a9b9 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -450,6 +450,8 @@ GET_LVSEG_NUM_PROPERTY_FN(thin_id, lvseg->device_id)
 #define _thin_id_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(discards, lvseg_discards_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _discards_set prop_not_implemented_set
+GET_LVSEG_STR_PROPERTY_FN(kernel_discards, lvseg_kernel_discards_dup(lvseg->lv->vg->vgmem, lvseg))
+#define _kernel_discards_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(cachemode, lvseg_cachemode_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _cachemode_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start, (SECTOR_SIZE * lvseg_start(lvseg)))
diff --git a/lib/report/report.c b/lib/report/report.c
index 40fcdd8..53ff753 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2221,6 +2221,23 @@ static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, "", NULL);
 }
 
+static int _kdiscards_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+	const char *discards_str;
+
+	if (!(discards_str = lvseg_kernel_discards_dup_with_info_and_seg_status(mem, lvdm)))
+		return_0;
+
+	if (*discards_str)
+		return _field_set_value(field, discards_str, NULL);
+
+	return _field_set_value(field, GET_FIRST_RESERVED_NAME(seg_kernel_discards_undef),
+				GET_FIELD_RESERVED_VALUE(seg_kernel_discards_undef));
+}
+
 static int _cachemode_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
diff --git a/lib/report/values.h b/lib/report/values.h
index 728760c..600f304 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -93,6 +93,7 @@ FIELD_RESERVED_VALUE(NAMED | RANGE | FUZZY | DYNAMIC, lv_time, lv_time_fuzzy, ""
 FIELD_RESERVED_VALUE(NOFLAG, cache_policy, cache_policy_undef, "", "", "", "undefined")
 FIELD_RESERVED_VALUE(NOFLAG, seg_monitor, seg_monitor_undef, "", "", "", "undefined")
 FIELD_RESERVED_VALUE(NOFLAG, lv_health_status, health_undef, "", "", "", "undefined")
+FIELD_RESERVED_VALUE(NOFLAG, kernel_discards, seg_kernel_discards_undef, "", "", "", "undefined")
 /* TODO the following 2 need STR_LIST support for reserved values
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_default, "", "default", "default")
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_undef, "", "undefined", "undefined") */
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index 95a5880..92146e3 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -26,15 +26,20 @@ aux have_thin 1 1 0 || skip
 
 aux prepare_pvs 2 64
 
+aux extend_filter_LVMTEST
+
 vgcreate $vg -s 64K $(cat DEVICES)
 
 # Create named pool only
 lvcreate -l1 --discards ignore -T $vg/pool
 check lv_field $vg/pool discards "ignore"
+check lv_field $vg/pool kernel_discards "ignore"
 lvcreate -l1 --discards nopassdown -T $vg/pool1
 check lv_field $vg/pool1 discards "nopassdown"
+check lv_field $vg/pool1 kernel_discards "nopassdown"
 lvcreate -l1 --discards passdown -T $vg/pool2
 check lv_field $vg/pool2 discards "passdown"
+check lv_field $vg/pool2 discards "passdown"
 
 lvchange --discards nopassdown $vg/pool2
 
@@ -66,3 +71,25 @@ lvchange --discards ignore $vg/pool1
 check lv_field $vg/pool1 discards "ignore"
 
 vgremove -ff $vg
+
+# Create thin pool with discards set to "ignore".
+# If we create a thin volume which we use for a PV
+# which we use to create another thin pool on top
+# with discards set to "passdown", the discards value
+# in metadata is still "passdown", but because the
+# device below does not support it, the kernel value
+# of discards actually used will be "nopassdown".
+# This is why we have "-o discards" and "-o kernel_discards".
+vgcreate -s 1m ${vg}_1 $(cat DEVICES)
+lvcreate -l 10 -T ${vg}_1/pool --discards ignore
+lvcreate -V 9m -T ${vg}_1/pool -n device_with_ignored_discards
+vgcreate -s 1m ${vg}_2 "$DM_DEV_DIR/${vg}_1/device_with_ignored_discards"
+lvcreate -l 1 -T ${vg}_2/pool --discards passdown
+lvcreate -V 1 -T ${vg}_2/pool
+check lv_field ${vg}_1/pool discards "ignore"
+check lv_field ${vg}_1/pool kernel_discards "ignore"
+check lv_field ${vg}_2/pool discards "passdown"
+check lv_field ${vg}_2/pool kernel_discards "nopassdown"
+
+vgremove -ff ${vg}_2
+vgremove -ff ${vg}_1



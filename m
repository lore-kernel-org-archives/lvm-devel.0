From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Mar 2016 09:20:04 +0000 (UTC)
Subject: master - cache: add kernel_cache_policy option
Message-ID: <20160303092004.6A12E605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88ce15004e414a64a3f967908cb2721671a191ba
Commit:        88ce15004e414a64a3f967908cb2721671a191ba
Parent:        3d610fabbdb5f63e6e46661f7080f74852b118b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 2 11:12:46 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 3 10:14:23 2016 +0100

cache: add kernel_cache_policy option

Pair kernel_cache_settings with kernel_cache_policy.
There is very small chance in error case that the value in table
might be differnet from the value stored in metadata
so make it 'checkable'.
---
 WHATS_NEW               |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   14 ++++++++++++++
 4 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7602fa4..668e8a4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.145 - 
 =====================================
+  Add kernel_cache_policy lvs field.
   Display [unknown] instead of 'unknown device' in pvs output.
   Fix error path when pvcreate allocation fails (2.02.144).
   Display [unknown] instead of blank for unknown VG names in pvs output.
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 040caf3..56a8628 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -113,6 +113,7 @@ FIELD(LVSSTATUS, lv, NUM, "CacheReadMisses", lvid, 16, cache_read_misses, cache_
 FIELD(LVSSTATUS, lv, NUM, "CacheWriteHits", lvid, 16, cache_write_hits, cache_write_hits, "Cache write hits.", 0)
 FIELD(LVSSTATUS, lv, NUM, "CacheWriteMisses", lvid, 16, cache_write_misses, cache_write_misses, "Cache write misses.", 0)
 FIELD(LVSSTATUS, lv, STR_LIST, "KCache Settings", lvid, 18, kernel_cache_settings, kernel_cache_settings, "Cache settings/parameters as set in kernel, including default values (cached segments only).", 0)
+FIELD(LVSSTATUS, lv, STR, "KCache Policy", lvid, 18, kernel_cache_policy, kernel_cache_policy, "Cache policy used in kernel.", 0)
 FIELD(LVSSTATUS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVSSTATUS, lv, STR, "KDiscards", lvid, 8, kdiscards, kernel_discards, "For thin pools, how discards are handled in kernel.", 0)
 FIELD(LVSSTATUS, lv, BIN, "CheckNeeded", lvid, 15, lvcheckneeded, lv_check_needed, "For thin pools, whether metadata check is needed.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 024919c..76a72be 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -489,6 +489,8 @@ GET_LVSEG_STR_PROPERTY_FN(seg_monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, l
 #define _cache_settings_set prop_not_implemented_set
 #define _kernel_cache_settings_get prop_not_implemented_get
 #define _kernel_cache_settings_set prop_not_implemented_set
+#define _kernel_cache_policy_get prop_not_implemented_get
+#define _kernel_cache_policy_set prop_not_implemented_set
 
 /* PVSEG */
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
diff --git a/lib/report/report.c b/lib/report/report.c
index 39dbb67..ff54cc4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1499,6 +1499,20 @@ out:
 	return r;
 }
 
+static int _kernel_cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
+				     struct dm_report_field *field,
+				     const void *data, void *private)
+{
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+
+	if ((lvdm->seg_status.type == SEG_STATUS_CACHE) &&
+	    lvdm->seg_status.cache->policy_name)
+		return _string_disp(rh, mem, field, &lvdm->seg_status.cache->policy_name, NULL);
+
+	return _field_set_value(field, GET_FIRST_RESERVED_NAME(cache_policy_undef),
+				GET_FIELD_RESERVED_VALUE(cache_policy_undef));
+}
+
 static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data, void *private)



From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 18 Jan 2016 13:44:36 +0000 (UTC)
Subject: master - report: add kernel_cache_settings field
Message-ID: <20160118134436.4D0D260EFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ee6af344bd805d4fa847b95b326c2fe1e52d7cd
Commit:        1ee6af344bd805d4fa847b95b326c2fe1e52d7cd
Parent:        7f627770412c7edd08aa5e5376fad58bca0b6c36
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 18 14:32:17 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 18 14:42:29 2016 +0100

report: add kernel_cache_settings field

Existing cache_settings field displays the settings which are
saved in metadata. Add new kernel_cache_settings fields to display
the settings which are currently used by kernel, including fields
for which default values are used.

This way users have complete view of the set of cache settings
supported (and which they can set) and their values which are used
at the moment by kernel.

For example:

$  lvs -o name,cache_policy,cache_settings,kernel_cache_settings vg
  LV      Cache Policy Cache Settings                               KCache Settings
  cached1 mq    migration_threshold=1024,write_promote_adjustment=2 migration_threshold=1024,random_threshold=4,sequential_threshold=512,discard_promote_adjustment=1,read_promote_adjustment=4,write_promote_adjustment=2
  cached2 smq   migration_threshold=1024                            migration_threshold=1024
  cached3 smq   migration_threshold=2048
---
 WHATS_NEW               |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 +
 lib/report/report.c     |   68 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 65f845f..0499469 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.141 - 
 ====================================
+  Add kernel_cache_settings report field for cache LV settings used in kernel.
 
 Version 2.02.140 - 16th January 2016
 ====================================
diff --git a/lib/report/columns.h b/lib/report/columns.h
index e097fec..9bd9fd4 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -112,6 +112,7 @@ FIELD(LVSSTATUS, lv, NUM, "CacheReadHits", lvid, 16, cache_read_hits, cache_read
 FIELD(LVSSTATUS, lv, NUM, "CacheReadMisses", lvid, 16, cache_read_misses, cache_read_misses, "Cache read misses.", 0)
 FIELD(LVSSTATUS, lv, NUM, "CacheWriteHits", lvid, 16, cache_write_hits, cache_write_hits, "Cache write hits.", 0)
 FIELD(LVSSTATUS, lv, NUM, "CacheWriteMisses", lvid, 16, cache_write_misses, cache_write_misses, "Cache write misses.", 0)
+FIELD(LVSSTATUS, lv, STR_LIST, "KCache Settings", lvid, 18, kernel_cache_settings, kernel_cache_settings, "Cache settings/parameters as set in kernel, including default values (cached segments only).", 0)
 FIELD(LVSSTATUS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVSSTATUS, lv, STR, "KDiscards", lvid, 8, kdiscards, kernel_discards, "For thin pools, how discards are handled in kernel.", 0)
 
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 705a9b9..6218835 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -481,6 +481,8 @@ GET_LVSEG_STR_PROPERTY_FN(seg_monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, l
 #define _cache_policy_set prop_not_implemented_set
 #define _cache_settings_get prop_not_implemented_get
 #define _cache_settings_set prop_not_implemented_set
+#define _kernel_cache_settings_get prop_not_implemented_get
+#define _kernel_cache_settings_set prop_not_implemented_set
 
 /* PVSEG */
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
diff --git a/lib/report/report.c b/lib/report/report.c
index 53ff753..c03469a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1412,6 +1412,74 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_string_list(rh, field, result, private, 0);
 }
 
+static int _do_get_kernel_cache_settings_list(struct dm_pool *mem,
+					      int cache_argc, char **cache_argv,
+					      struct dm_list *result)
+{
+	const char *key, *value;
+	char *buf;
+	size_t buf_len;
+	int i;
+
+	for (i = 0; i+1 < cache_argc; i += 2) {
+		key = cache_argv[i];
+		value = cache_argv[i+1];
+		/* +1 for "=" char and +1 for trailing zero */
+		buf_len = strlen(key) + strlen(value) + 2;
+		if (!(buf = dm_pool_alloc(mem, buf_len)))
+			return_0;
+		dm_snprintf(buf, buf_len, "%s=%s", key, value);
+		if (!str_list_add_no_dup_check(mem, result, buf))
+			return_0;
+	}
+
+	return 1;
+}
+
+static int _get_kernel_cache_settings_list(struct dm_pool *mem,
+					   struct dm_status_cache *cache_status,
+					   struct dm_list **result)
+{
+	if (!(*result = str_list_create(mem)))
+		return_0;
+
+	if (!_do_get_kernel_cache_settings_list(mem, cache_status->core_argc,
+						cache_status->core_argv, *result))
+		return_0;
+
+	if (!_do_get_kernel_cache_settings_list(mem, cache_status->policy_argc,
+						cache_status->policy_argv, *result))
+		return_0;
+
+	return 1;
+}
+
+static int _kernel_cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
+				       struct dm_report_field *field,
+				       const void *data, void *private)
+{
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+	struct dm_list dummy_list; /* dummy list to display "nothing" */
+	struct dm_list *result;
+	int r = 0;
+
+	if (lvdm->seg_status.type != SEG_STATUS_CACHE) {
+		dm_list_init(&dummy_list);
+		return _field_set_string_list(rh, field, &dummy_list, private, 0);
+	}
+
+	if (!(mem = dm_pool_create("reporter_pool", 1024)))
+		return_0;
+
+	if (!_get_kernel_cache_settings_list(mem, lvdm->seg_status.cache, &result))
+		goto_out;
+
+	r = _field_set_string_list(rh, field, result, private, 0);
+out:
+	dm_pool_destroy(mem);
+	return r;
+}
+
 static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data, void *private)



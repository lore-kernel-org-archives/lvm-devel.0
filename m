From: Petr Rockai <prockai@redhat.com>
Date: Wed, 17 Dec 2014 11:31:26 +0100
Subject: [PATCH 3/3] report: Attach cache policy to the cache (not pool) LV, use reserved values.
In-Reply-To: <1418812286-19535-1-git-send-email-prockai@redhat.com>
References: <1418812286-19535-1-git-send-email-prockai@redhat.com>
Message-ID: <1418812286-19535-3-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/report/columns.h    |  4 ++--
 lib/report/report.c     | 40 ++++++++++++++++++++++++++++++++++------
 lib/report/values.h     |  6 ++++++
 test/shell/lvs-cache.sh | 18 +++++++++---------
 4 files changed, 51 insertions(+), 17 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 4b627a3..1dd2ae0 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -178,8 +178,8 @@ FIELD(SEGS, seg, STR_LIST, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.",
 FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
 FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
 FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, seg_monitor, "Dmeventd monitoring status of the segment.", 0)
-FIELD(SEGS, seg, STR, "Cache Policy", policy_name, 11, string, cache_policy, "The cache policy (cached segments only).", 0)
-FIELD(SEGS, seg, STR_LIST, "Cache Settings", policy_settings, 20, cache_settings, cache_settings, "Cache settings/parameters (cached segments only).", 0)
+FIELD(SEGS, seg, STR, "Cache Policy", list, 12, cache_policy, cache_policy, "The cache policy (cached segments only).", 0)
+FIELD(SEGS, seg, STR_LIST, "Cache Settings", list, 14, cache_settings, cache_settings, "Cache settings/parameters (cached segments only).", 0)
 
 FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, pvseg_start, "Physical Extent number of start of segment.", 0)
 FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, pvseg_size, "Number of extents in segment.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 54860dc..6c009d2 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -247,19 +247,47 @@ static int _str_list_append(const char *line, void *baton)
 	return 1;
 }
 
+static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	if (seg_is_cache(seg))
+		seg = first_seg(seg->pool_lv);
+	else
+		return _field_set_value(field, "", &RESERVED(cache_policy_undef));
+
+	if (seg->policy_name)
+		return _field_set_value(field, seg->policy_name, NULL);
+	else
+		return _field_set_value(field, "", &RESERVED(cache_policy_default));
+}
+
 static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 				struct dm_report_field *field,
 				const void *data, void *private)
 {
-	const struct dm_config_node *settings = *(const struct dm_config_node **) data;
-	struct dm_list *result = str_list_create(mem);
-	struct _str_list_append_baton baton = { mem, result };
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	const struct dm_config_node *settings;
+	struct dm_list *result;
+	struct _str_list_append_baton baton;
+
+	if (seg_is_cache(seg))
+		seg = first_seg(seg->pool_lv);
+	else
+		return _field_set_value(field, "", &RESERVED(cache_settings_undef));
+
+	if (seg->policy_settings)
+		settings = seg->policy_settings->child;
+	else
+		return _field_set_value(field, "", &RESERVED(cache_settings_default));
 
-	if (!result)
+	if (!(result = str_list_create(mem)))
 		return_0;
 
-	if (settings)
-		settings = settings->child;
+	baton.mem = mem;
+	baton.result = result;
 
 	while (settings) {
 		dm_config_write_one_node(settings, _str_list_append, &baton);
diff --git a/lib/report/values.h b/lib/report/values.h
index f909ce9..58b1b8c 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -81,4 +81,10 @@ FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", "read-only", "read-on
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")
 FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, "", &RESERVED(number_undef_64), "auto")
 
+/* Reserved values for SEG fields */
+FIELD_RESERVED_VALUE(cache_policy, cache_policy_default, "", "default", "default")
+FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "undefined", "undefined")
+FIELD_RESERVED_VALUE(cache_settings, cache_settings_default, "", "default", "default")
+FIELD_RESERVED_VALUE(cache_settings, cache_settings_undef, "", "undefined", "undefined")
+
 /* *INDENT-ON* */
diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
index 6ac5d0d..a4aa164 100644
--- a/test/shell/lvs-cache.sh
+++ b/test/shell/lvs-cache.sh
@@ -21,30 +21,30 @@ aux prepare_vg 5 8000
 
 lvcreate --type cache-pool -L10 $vg/cpool
 lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
-lvs -a -o lv_name,cache_policy
-lvs -a -o lv_name,cache_settings
+lvs -o lv_name,cache_policy
+lvs -o lv_name,cache_settings
 
 lvremove -f $vg
 
 lvcreate --type cache-pool -L10 $vg/cpool
 lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg --cachepolicy mq \
 	 --cachesettings migration_threshold=233
-lvs -a -o lv_name,cache_policy   | grep mq
-lvs -a -o lv_name,cache_settings | grep migration_threshold=233
+lvs -o lv_name,cache_policy   | grep mq
+lvs -o lv_name,cache_settings | grep migration_threshold=233
 
 lvremove -f $vg
 
 lvcreate --type cache-pool -L10 --cachepolicy mq --cachesettings migration_threshold=233 $vg/cpool
 lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
-lvs -a -o lv_name,cache_policy   | grep mq
-lvs -a -o lv_name,cache_settings | grep migration_threshold=233
+lvs -o lv_name,cache_policy   | grep mq
+lvs -o lv_name,cache_settings | grep migration_threshold=233
 
 lvremove -f $vg
 
 lvcreate --type cache-pool -L10 --cachepolicy mq --cachesettings migration_threshold=233 --cachesettings sequential_threshold=13 $vg/cpool
 lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
-lvs -a -o lv_name,cache_policy   | grep mq
-lvs -a -o lv_name,cache_settings | grep migration_threshold=233
-lvs -a -o lv_name,cache_settings | grep sequential_threshold=13
+lvs -o lv_name,cache_policy   | grep mq
+lvs -o lv_name,cache_settings | grep migration_threshold=233
+lvs -o lv_name,cache_settings | grep sequential_threshold=13
 
 lvremove -f $vg
-- 
2.1.2



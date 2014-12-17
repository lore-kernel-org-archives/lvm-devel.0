From: Petr Rockai <prockai@redhat.com>
Date: Wed, 17 Dec 2014 14:26:45 +0100
Subject: [PATCH] report: Add cache_policy and cache_settings (LV) segment fields.
Message-ID: <1418822805-24304-1-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/report/columns.h         |  2 ++
 lib/report/properties.c      |  5 ++++
 lib/report/report.c          | 68 ++++++++++++++++++++++++++++++++++++++++++++
 lib/report/values.h          |  6 ++++
 test/shell/lvcreate-cache.sh |  3 ++
 test/shell/lvs-cache.sh      | 50 ++++++++++++++++++++++++++++++++
 6 files changed, 134 insertions(+)
 create mode 100644 test/shell/lvs-cache.sh

diff --git a/lib/report/columns.h b/lib/report/columns.h
index db43e13..1dd2ae0 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -178,6 +178,8 @@ FIELD(SEGS, seg, STR_LIST, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.",
 FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
 FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
 FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, seg_monitor, "Dmeventd monitoring status of the segment.", 0)
+FIELD(SEGS, seg, STR, "Cache Policy", list, 12, cache_policy, cache_policy, "The cache policy (cached segments only).", 0)
+FIELD(SEGS, seg, STR_LIST, "Cache Settings", list, 14, cache_settings, cache_settings, "Cache settings/parameters (cached segments only).", 0)
 
 FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, pvseg_start, "Physical Extent number of start of segment.", 0)
 FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, pvseg_size, "Number of extents in segment.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 2308c36..4796000 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -440,6 +440,11 @@ GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices(lvseg->lv->vg->vgmem, lvseg))
 GET_LVSEG_STR_PROPERTY_FN(seg_monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _seg_monitor_set prop_not_implemented_set
 
+#define _cache_policy_get prop_not_implemented_get
+#define _cache_policy_set prop_not_implemented_set
+#define _cache_settings_get prop_not_implemented_get
+#define _cache_settings_set prop_not_implemented_set
+
 /* PVSEG */
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
 #define _pvseg_start_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 5637d50..4e025e0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -231,6 +231,74 @@ static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_string_list(rh, field, tagsl, private, 1);
 }
 
+struct _str_list_append_baton {
+	struct dm_pool *mem;
+	struct dm_list *result;
+};
+
+static int _str_list_append(const char *line, void *baton)
+{
+	struct _str_list_append_baton *b = baton;
+	const char *dup = dm_pool_strdup(b->mem, line);
+	if (!dup)
+		return_0;
+	if (!str_list_add(b->mem, b->result, dup))
+		return_0;
+	return 1;
+}
+
+static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
+				struct dm_report_field *field,
+				const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	const struct dm_config_node *settings;
+	struct dm_list *result;
+	struct _str_list_append_baton baton;
+
+	if (seg_is_cache(seg))
+		seg = first_seg(seg->pool_lv);
+	else
+		return _field_set_value(field, "", NULL /* TODO: &FIRST_NAME(cache_settings_undef) */);
+
+	if (seg->policy_settings)
+		settings = seg->policy_settings->child;
+	else
+		return _field_set_value(field, "", NULL /* TODO: &FIRST_NAME(cache_settings_default) */);
+
+	if (!(result = str_list_create(mem)))
+		return_0;
+
+	baton.mem = mem;
+	baton.result = result;
+
+	while (settings) {
+		dm_config_write_one_node(settings, _str_list_append, &baton);
+		settings = settings->sib;
+	};
+
+	return _field_set_string_list(rh, field, result, private, 0);
+}
+
+static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	if (seg_is_cache(seg))
+		seg = first_seg(seg->pool_lv);
+	else
+		return _field_set_value(field, "", &FIRST_NAME(cache_policy_undef));
+
+	if (seg->policy_name)
+		return _field_set_value(field, seg->policy_name, NULL);
+	else {
+		log_error(INTERNAL_ERROR "unexpected NULL policy name");
+		return_0;
+	}
+}
+
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
diff --git a/lib/report/values.h b/lib/report/values.h
index f909ce9..b0382c0 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -81,4 +81,10 @@ FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", "read-only", "read-on
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")
 FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, "", &RESERVED(number_undef_64), "auto")
 
+/* Reserved values for SEG fields */
+FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "undefined", "undefined")
+/* TODO the following 2 need STR_LIST support for reserved values
+FIELD_RESERVED_VALUE(cache_settings, cache_settings_default, "", "default", "default")
+FIELD_RESERVED_VALUE(cache_settings, cache_settings_undef, "", "undefined", "undefined") */
+
 /* *INDENT-ON* */
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index f709d8b..89efc4d 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -230,6 +230,9 @@ lvcreate --type cache-pool -L10 $vg/cpool
 lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg --cachepolicy mq --cachesettings migration_threshold=233
 dmsetup status | grep $vg
 dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
+lvchange -an $vg
+lvchange -ay $vg
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
 
 lvremove -f $vg
 
diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
new file mode 100644
index 0000000..a4aa164
--- /dev/null
+++ b/test/shell/lvs-cache.sh
@@ -0,0 +1,50 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Exercise creation of cache and cache pool volumes
+
+# Full CLI uses  --type
+# Shorthand CLI uses -H | --cache
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+aux prepare_vg 5 8000
+
+lvcreate --type cache-pool -L10 $vg/cpool
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
+lvs -o lv_name,cache_policy
+lvs -o lv_name,cache_settings
+
+lvremove -f $vg
+
+lvcreate --type cache-pool -L10 $vg/cpool
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg --cachepolicy mq \
+	 --cachesettings migration_threshold=233
+lvs -o lv_name,cache_policy   | grep mq
+lvs -o lv_name,cache_settings | grep migration_threshold=233
+
+lvremove -f $vg
+
+lvcreate --type cache-pool -L10 --cachepolicy mq --cachesettings migration_threshold=233 $vg/cpool
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
+lvs -o lv_name,cache_policy   | grep mq
+lvs -o lv_name,cache_settings | grep migration_threshold=233
+
+lvremove -f $vg
+
+lvcreate --type cache-pool -L10 --cachepolicy mq --cachesettings migration_threshold=233 --cachesettings sequential_threshold=13 $vg/cpool
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
+lvs -o lv_name,cache_policy   | grep mq
+lvs -o lv_name,cache_settings | grep migration_threshold=233
+lvs -o lv_name,cache_settings | grep sequential_threshold=13
+
+lvremove -f $vg
-- 
2.1.2



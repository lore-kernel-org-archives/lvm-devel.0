From: Petr Rockai <prockai@redhat.com>
Date: Wed, 17 Dec 2014 11:31:24 +0100
Subject: [PATCH 1/3] report: Add cache_policy and cache_settings (LV) segment fields.
Message-ID: <1418812286-19535-1-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/report/columns.h    |  2 ++
 lib/report/properties.c |  5 +++++
 lib/report/report.c     | 38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 45 insertions(+)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index db43e13..4b627a3 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -178,6 +178,8 @@ FIELD(SEGS, seg, STR_LIST, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.",
 FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
 FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
 FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, seg_monitor, "Dmeventd monitoring status of the segment.", 0)
+FIELD(SEGS, seg, STR, "Cache Policy", policy_name, 11, string, cache_policy, "The cache policy (cached segments only).", 0)
+FIELD(SEGS, seg, STR_LIST, "Cache Settings", policy_settings, 20, cache_settings, cache_settings, "Cache settings/parameters (cached segments only).", 0)
 
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
index 5637d50..54860dc 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -231,6 +231,44 @@ static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,
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
+	const struct dm_config_node *settings = *(const struct dm_config_node **) data;
+	struct dm_list *result = str_list_create(mem);
+	struct _str_list_append_baton baton = { mem, result };
+
+	if (!result)
+		return_0;
+
+	if (settings)
+		settings = settings->child;
+
+	while (settings) {
+		dm_config_write_one_node(settings, _str_list_append, &baton);
+		settings = settings->sib;
+	};
+
+	return _field_set_string_list(rh, field, result, private, 0);
+}
+
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
-- 
2.1.2



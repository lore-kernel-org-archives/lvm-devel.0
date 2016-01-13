From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:47 +0000 (UTC)
Subject: master - conf: add report/mark_invisible_devices
Message-ID: <20160113134647.4E4426066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e168b5de75204a554fcb6f9a3bd25dada2561c86
Commit:        e168b5de75204a554fcb6f9a3bd25dada2561c86
Parent:        7f74a995029caa41ee3cf9aec0bd024a34bfd89a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 11:30:07 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 12:01:10 2016 +0100

conf: add report/mark_invisible_devices

---
 lib/commands/toolcontext.c   |    1 +
 lib/commands/toolcontext.h   |    1 +
 lib/config/config_settings.h |    3 +++
 lib/metadata/lv.c            |   15 ++++++++-------
 lib/report/report.c          |    3 ++-
 5 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a2f21b8..a8bf187 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -478,6 +478,7 @@ int process_profilable_config(struct cmd_context *cmd)
 
 	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG, NULL);
 	cmd->report_binary_values_as_numeric = find_config_tree_bool(cmd, report_binary_values_as_numeric_CFG, NULL);
+	cmd->report_mark_invisible_devices = find_config_tree_bool(cmd, report_mark_invisible_devices_CFG, NULL);
 	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
 	cmd->report_list_item_separator = find_config_tree_str(cmd, report_list_item_separator_CFG, NULL);
 	if (!(cmd->time_format = _set_time_format(cmd)))
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index cd55348..5a7b3af 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -121,6 +121,7 @@ struct cmd_context {
 	unsigned auto_set_activation_skip:1;
 	unsigned si_unit_consistency:1;
 	unsigned report_binary_values_as_numeric:1;
+	unsigned report_mark_invisible_devices:1;
 	unsigned metadata_read_only:1;
 	unsigned ignore_clustered_vgs:1;
 	unsigned threaded:1;			/* set if running within a thread e.g. clvmd */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 52954d5..bb5d7d9 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1671,6 +1671,9 @@ cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, C
 	"List of columns to sort by when reporting 'pvs --segments' command in verbose mode.\n"
 	"See 'pvs --segments -o help' for the list of possible fields.\n")
 
+cfg(report_mark_invisible_devices_CFG, "mark_invisible_devices", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 2, 140), NULL, 0, NULL,
+	"Use brackets [] to mark invisible devices.\n")
+
 cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_MIRROR_LIB, vsn(1, 2, 3), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a mirror device.\n"
 	"libdevmapper-event-lvm2mirror.so attempts to recover from\n"
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index d591f24..44db4df 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -29,7 +29,8 @@ static struct utsname _utsname;
 static int _utsinit = 0;
 
 static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
-			    int range_format, int metadata_areas_only)
+			    int range_format, int metadata_areas_only,
+			    int mark_invisible)
 {
 	static const char pool_grow_object_failed_msg[] = "dm_pool_grow_object failed";
 	unsigned int s;
@@ -71,7 +72,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 			return NULL;
 		}
 
-		if (!visible && !dm_pool_grow_object(mem, "[", 1)) {
+		if (!visible && mark_invisible && !dm_pool_grow_object(mem, "[", 1)) {
 			log_error(pool_grow_object_failed_msg);
 			return NULL;
 		}
@@ -81,7 +82,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 			return NULL;
 		}
 
-		if (!visible && !dm_pool_grow_object(mem, "]", 1)) {
+		if (!visible && mark_invisible && !dm_pool_grow_object(mem, "]", 1)) {
 			log_error(pool_grow_object_failed_msg);
 			return NULL;
 		}
@@ -128,22 +129,22 @@ out:
 
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 0, 0);
+	return _format_pvsegs(mem, seg, 0, 0, seg->lv->vg->cmd->report_mark_invisible_devices);
 }
 
 char *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 0, 1);
+	return _format_pvsegs(mem, seg, 0, 1, seg->lv->vg->cmd->report_mark_invisible_devices);
 }
 
 char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 1, 0);
+	return _format_pvsegs(mem, seg, 1, 0, seg->lv->vg->cmd->report_mark_invisible_devices);
 }
 
 char *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 1, 1);
+	return _format_pvsegs(mem, seg, 1, 1, seg->lv->vg->cmd->report_mark_invisible_devices);
 }
 
 char *lvseg_tags_dup(const struct lv_segment *seg)
diff --git a/lib/report/report.c b/lib/report/report.c
index 4b2c0c0..3c73a2f 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1581,11 +1581,12 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
 {
+	struct cmd_context *cmd = (struct cmd_context *) private;
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	char *repstr, *lvname;
 	size_t len;
 
-	if (lv_is_visible(lv))
+	if (lv_is_visible(lv) || !cmd->report_mark_invisible_devices)
 		return _string_disp(rh, mem, field, &lv->name, private);
 
 	len = strlen(lv->name) + 3;



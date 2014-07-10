From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Jul 2014 14:22:50 +0000 (UTC)
Subject: master - conf: add report/list_item_separator lvm.conf option
Message-ID: <20140710142250.30A40611D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d169ff1e039ecdfb1efac0a6464ca149d71d8767
Commit:        d169ff1e039ecdfb1efac0a6464ca149d71d8767
Parent:        e38af4e28fba0c6854f4bc2dc3842d74a11d199e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 10 16:18:45 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 10 16:18:45 2014 +0200

conf: add report/list_item_separator lvm.conf option

For example:

$ lvm dumpconfig report/list_item_separator
list_item_separator=","

$ lvs -o name,tags vg/lvol1
  LV    LV Tags
  lvol1 a,x,y

$ lvm dumpconfig report/list_item_separator
list_item_separator=":"

$ lvs -o name,tags vg/lvol1
  LV    LV Tags
  lvol1 a:x:y
---
 conf/command_profile_template.profile.in |    1 +
 conf/example.conf.in                     |    3 +++
 lib/commands/toolcontext.c               |    1 +
 lib/commands/toolcontext.h               |    1 +
 lib/config/config_settings.h             |    1 +
 lib/config/defaults.h                    |    1 +
 lib/report/report.c                      |   13 ++++++++++---
 7 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/conf/command_profile_template.profile.in b/conf/command_profile_template.profile.in
index 7401aa5..0c1e6f0 100644
--- a/conf/command_profile_template.profile.in
+++ b/conf/command_profile_template.profile.in
@@ -22,6 +22,7 @@ report {
 	buffered=1
 	headings=1
 	separator=" "
+	list_item_separator=","
 	prefixes=0
 	quoted=1
 	colums_as_rows=0
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 11f50f0..91768fb 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1057,6 +1057,9 @@ activation {
     # A separator to use on report after each field.
     # separator=" "
 
+    # A separator to use for list items when reported.
+    # list_item_separator=","
+
     # Use a field name prefix for each field reported.
     # prefixes=0
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 6ac4a42..fe79a81 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -299,6 +299,7 @@ int process_profilable_config(struct cmd_context *cmd) {
 	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG, NULL);
 	cmd->report_binary_values_as_numeric = find_config_tree_bool(cmd, report_binary_values_as_numeric_CFG, NULL);
 	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
+	cmd->report_list_item_separator = find_config_tree_str(cmd, report_list_item_separator_CFG, NULL);
 
 	return 1;
 }
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index d06dd7d..57c51d2 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -119,6 +119,7 @@ struct cmd_context {
 
 	/* List of defined tags */
 	struct dm_list tags;
+	const char *report_list_item_separator;
 	int hosttags;
 
 	const char *lib_dir;		/* Cache value global/library_dir */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7289a04..455eb4f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -231,6 +231,7 @@ cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_
 cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0), NULL)
 cfg(report_headings_CFG, "headings", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_HEADINGS, vsn(1, 0, 0), NULL)
 cfg(report_separator_CFG, "separator", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_REP_SEPARATOR, vsn(1, 0, 0), NULL)
+cfg(report_list_item_separator_CFG, "list_item_separator", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_REP_LIST_ITEM_SEPARATOR, vsn(2, 2, 108), NULL)
 cfg(report_prefixes_CFG, "prefixes", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_PREFIXES, vsn(2, 2, 36), NULL)
 cfg(report_quoted_CFG, "quoted", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_QUOTED, vsn(2, 2, 39), NULL)
 cfg(report_colums_as_rows_CFG, "colums_as_rows", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 086f7fd..815d6a3 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -180,6 +180,7 @@
 #define DEFAULT_REP_PREFIXES 0
 #define DEFAULT_REP_QUOTED 1
 #define DEFAULT_REP_SEPARATOR " "
+#define DEFAULT_REP_LIST_ITEM_SEPARATOR ","
 
 #define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,metadata_percent,move_pv,mirror_log,copy_percent,convert_lv"
 #define DEFAULT_VGS_COLS "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
diff --git a/lib/report/report.c b/lib/report/report.c
index 5931021..6dc792b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -139,6 +139,13 @@ static int _field_set_value(struct dm_report_field *field, const void *data, con
 	return 1;
 }
 
+static int _field_set_string_list(struct dm_report *rh, struct dm_report_field *field,
+				  const struct dm_list *list, void *private)
+{
+	struct cmd_context *cmd = (struct cmd_context *) private;
+	return dm_report_field_string_list(rh, field, list, cmd->report_list_item_separator);
+}
+
 /*
  * Data-munging functions to prepare each data type for display and sorting
  */
@@ -221,11 +228,11 @@ static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct d
 
 static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,
 		      struct dm_report_field *field,
-		      const void *data, void *private __attribute__((unused)))
+		      const void *data, void *private)
 {
 	const struct dm_list *tagsl = (const struct dm_list *) data;
 
-	return dm_report_field_string_list(rh, field, tagsl, NULL);
+	return _field_set_string_list(rh, field, tagsl, private);
 }
 
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -243,7 +250,7 @@ static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (!(list_lv_modules(mem, lv, modules)))
 		return_0;
 
-	return dm_report_field_string_list(rh, field, modules, NULL);
+	return _field_set_string_list(rh, field, modules, private);
 }
 
 static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,



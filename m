From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Jul 2014 13:57:47 +0000 (UTC)
Subject: master - cleanup: use macros for definition of reporting/selection reserved values
Message-ID: <20140709135747.8EF40600EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ccab185aa7accd348409b9c0261bc3200570710d
Commit:        ccab185aa7accd348409b9c0261bc3200570710d
Parent:        1a05862732d8e809f888313c546e97381c4e1f49
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 8 12:40:45 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 9 15:55:54 2014 +0200

cleanup: use macros for definition of reporting/selection reserved values

The macros for reserved value definition makes the process a bit easier,
but there's still a place for improvement and make this even more
transparent. We can optimize and provide better automatism here later on.
---
 lib/report/columns.h |    4 +
 lib/report/report.c  |  329 ++++++++++++++++++++++----------------------------
 2 files changed, 149 insertions(+), 184 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 2769c2d..21ca585 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -27,6 +27,10 @@
  * Help text ends with a full stop.
  */
 
+/*
+ * FIELD(report_object_type, structure, sort_type, heading, structure_field, output width, reporting_function, field_id, description, settable_via_lib)
+ */
+
 /* *INDENT-OFF* */
 FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, lv_uuid, "Unique identifier.", 0)
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, lv_name, "Name.  LVs created for internal use are enclosed in brackets.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 4ec75aa..adcd2be 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -41,159 +41,118 @@ struct lvm_report_object {
 	struct label *label;
 };
 
-/* Enum for field_num index to use in per-field reserved value definition. */
+/*
+ *  Enum for field_num index to use in per-field reserved value definition.
+ *  Each field is represented by enum value with name "field_<id>" where <id>
+ *  is the field_id of the field as registered in columns.h.
+ */
 #define FIELD(type, strct, sorttype, head, field_name, width, func, id, desc, writeable) field_ ## id,
 enum {
 #include "columns.h"
 };
 #undef FIELD
 
-
 static const uint64_t _zero64 = UINT64_C(0);
 static const uint64_t _one64 = UINT64_C(1);
-static const char * const _str_zero = "0";
-static const char * const _str_one = "1";
+static const char const _str_zero[] = "0";
+static const char const _str_one[] = "1";
+static const char const _str_minus_one[] = "-1";
+static const char const _str_unknown[] = "unknown";
 
 /*
- * TODO: try to automate reserved value definition and declare reserved values
- *       using FIELD macro directly. The FIELD macro should be able to define
- *       proper structures automatically then.
- */
-
-/* Per-type reserved values. */
-static const uint64_t _reserved_number_undef_64 = UINT64_C(-1);
-/*
  * 32 bit signed is casted to 64 bit unsigned in dm_report_field internally!
  * So when stored in the struct, the _reserved_number_undef_32 is actually
  * equal to _reserved_number_undef_64.
  */
 static const int32_t _reserved_number_undef_32 = INT32_C(-1);
 
-/* Per-field reserved values. */
-static const struct dm_report_field_reserved_value _reserved_pv_allocatable = {field_pv_allocatable, &_one64};
-static const struct dm_report_field_reserved_value _reserved_pv_exported = {field_pv_exported, &_one64};
-static const struct dm_report_field_reserved_value _reserved_pv_missing = {field_pv_missing, &_one64};
-static const struct dm_report_field_reserved_value _reserved_vg_extendable = {field_vg_extendable, &_one64};
-static const struct dm_report_field_reserved_value _reserved_vg_exported = {field_vg_exported, &_one64};
-static const struct dm_report_field_reserved_value _reserved_vg_partial = {field_vg_partial, &_one64};
-static const struct dm_report_field_reserved_value _reserved_vg_clustered = {field_vg_clustered, &_one64};
-static const struct dm_report_field_reserved_value _reserved_vg_permissions_rw = {field_vg_permissions, "writeable"};
-static const struct dm_report_field_reserved_value _reserved_vg_permissions_r = {field_vg_permissions, "read-only"};
-static const struct dm_report_field_reserved_value _reserved_vg_mda_copies = {field_vg_mda_copies, &_reserved_number_undef_64};
-static const struct dm_report_field_reserved_value _reserved_lv_initial_image_sync = {field_lv_initial_image_sync, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_image_synced = {field_lv_image_synced, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_merging = {field_lv_merging, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_converting = {field_lv_converting, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_allocation_locked = {field_lv_allocation_locked, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_fixed_minor = {field_lv_fixed_minor, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_merge_failed = {field_lv_merge_failed, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_snapshot_invalid = {field_lv_snapshot_invalid, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_suspended = {field_lv_suspended, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_live_table = {field_lv_live_table, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_inactive_table = {field_lv_inactive_table, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_device_open = {field_lv_device_open, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_skip_activation = {field_lv_skip_activation, &_one64};
-static const struct dm_report_field_reserved_value _reserved_lv_permissions_rw = {field_lv_permissions, "writeable"};
-static const struct dm_report_field_reserved_value _reserved_lv_permissions_r = {field_lv_permissions, "read-only"};
-static const struct dm_report_field_reserved_value _reserved_lv_permissions_r_override = {field_lv_permissions, "read-only-override"};
-static const struct dm_report_field_reserved_value _reserved_lv_read_ahead = {field_lv_read_ahead, &_reserved_number_undef_64};
-
-/* Per-type reserved names. */
-static const char const *_reserved_number_undef_64_names[]={"-1", "undefined", "undef", "unknown", NULL};
-
-/* Per-field reserved names. */
-static const char *_reserved_pv_allocatable_names[]={"allocatable", NULL};
-static const char *_reserved_pv_exported_names[]={"exported", NULL};
-static const char *_reserved_pv_missing_names[]={"missing", NULL};
-static const char *_reserved_vg_extendable_names[]={"extendable", NULL};
-static const char *_reserved_vg_exported_names[]={"exported", NULL};
-static const char *_reserved_vg_partial_names[]={"partial", NULL};
-static const char *_reserved_vg_clustered_names[]={"clustered", NULL};
-static const char *_reserved_vg_permissions_rw_names[]={"writeable", "rw", "read-write", NULL};
-static const char *_reserved_vg_permissions_r_names[]={"read-only", "r", "ro", NULL};
-static const char *_reserved_vg_mda_copies_names[]={"unmanaged", NULL};
-static const char *_reserved_lv_initial_image_sync_names[]={"initial image sync", "sync", NULL};
-static const char *_reserved_lv_image_synced_names[]={"image synced", "synced", NULL};
-static const char *_reserved_lv_merging_names[]={"merging", NULL};
-static const char *_reserved_lv_converting_names[]={"converting", NULL};
-static const char *_reserved_lv_allocation_locked_names[]={"allocation locked", "locked", NULL};
-static const char *_reserved_lv_fixed_minor_names[]={"fixed minor", "fixed", NULL};
-static const char *_reserved_lv_merge_failed_names[]={"merge failed", "failed", NULL};
-static const char *_reserved_lv_snapshot_invalid_names[]={"snapsot invalid", "invalid", NULL};
-static const char *_reserved_lv_suspended_names[]={"suspended", NULL};
-static const char *_reserved_lv_live_table_names[]={"live table present", "live table", "live", NULL};
-static const char *_reserved_lv_inactive_table_names[]={"inactive table present", "inactive table", "inactive", NULL};
-static const char *_reserved_lv_device_open_names[]={"open", NULL};
-static const char *_reserved_lv_skip_activation_names[]={"skip activation", "skip", NULL};
-static const char *_reserved_lv_permissions_rw_names[]={"writeable", "rw", "read-write", NULL};
-static const char *_reserved_lv_permissions_r_names[]={"read-only", "r", "ro", NULL};
-static const char *_reserved_lv_permissions_r_override_names[]={"read-only-override", "ro-override", "r-override", "R", NULL};
-static const char *_reserved_lv_read_ahead_names[]={"auto", NULL};
-
-/* Put together arrays of reserved names with their reserved values. */
+#define FIRST_NAME(id) _reserved_ ## id ## _names[0]
+#define TYPE_RESERVED_VALUE(type, id, value, ...) \
+	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__, NULL}; \
+	static const type _reserved_ ## id = value;
+#define FIELD_RESERVED_VALUE(field_id, id, value, ...) \
+	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__ , NULL}; \
+	static const struct dm_report_field_reserved_value _reserved_ ## id = {field_ ## field_id, &value};
+
+/*
+ * Reserved values and their assigned names.
+ * The first name is the one that is also used for reporting.
+ * All names listed are synonyms recognized in selection criteria.
+ * For binary-based values we map all reserved names listed onto value 1, blank onto value 0.
+ *
+ * TYPE_RESERVED_VALUE(type, reserved_value_id, value, reserved name, ...)
+ * FIELD_RESERVED_VALUE(field_id, reserved_value_id, value, reserved name, ...)
+ *
+ */
+TYPE_RESERVED_VALUE(uint64_t, number_undef_64, UINT64_C(-1), _str_minus_one, _str_unknown, "undefined", "undef");
+FIELD_RESERVED_VALUE(pv_allocatable, pv_allocatable, _one64, "allocatable")
+FIELD_RESERVED_VALUE(pv_exported, pv_exported, _one64, "exported")
+FIELD_RESERVED_VALUE(pv_missing, pv_missing, _one64, "missing")
+FIELD_RESERVED_VALUE(vg_extendable, vg_extendable, _one64, "extendable")
+FIELD_RESERVED_VALUE(vg_exported, vg_exported, _one64, "exported")
+FIELD_RESERVED_VALUE(vg_partial, vg_partial, _one64, "partial")
+FIELD_RESERVED_VALUE(vg_clustered, vg_clustered, _one64, "clustered")
+FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, FIRST_NAME(vg_permissions_rw), "writeable", "rw", "read_write")
+FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, FIRST_NAME(vg_permissions_r), "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, _reserved_number_undef_64, "unmanaged")
+FIELD_RESERVED_VALUE(lv_initial_image_sync, lv_initial_image_sync, _one64, "initial image sync", "sync")
+FIELD_RESERVED_VALUE(lv_image_synced, lv_image_synced, _one64, "image synced", "synced")
+FIELD_RESERVED_VALUE(lv_merging, lv_merging, _one64, "merging")
+FIELD_RESERVED_VALUE(lv_converting, lv_converting, _one64, "converting")
+FIELD_RESERVED_VALUE(lv_allocation_locked, lv_allocation_locked, _one64, "allocation locked", "locked")
+FIELD_RESERVED_VALUE(lv_fixed_minor, lv_fixed_minor, _one64, "fixed minor", "fixed")
+FIELD_RESERVED_VALUE(lv_merge_failed, lv_merge_failed, _one64, "merge failed", "failed")
+FIELD_RESERVED_VALUE(lv_snapshot_invalid, lv_snapshot_invalid, _one64, "snapsot invalid", "invalid")
+FIELD_RESERVED_VALUE(lv_suspended, lv_suspended, _one64, "suspended")
+FIELD_RESERVED_VALUE(lv_live_table, lv_live_table, _one64, "live table present", "live table", "live")
+FIELD_RESERVED_VALUE(lv_inactive_table, lv_inactive_table, _one64, "inactive table present", "inactive table", "inactive")
+FIELD_RESERVED_VALUE(lv_device_open, lv_device_open, _one64, "open")
+FIELD_RESERVED_VALUE(lv_skip_activation, lv_skip_activation, _one64, "skip activation", "skip")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, FIRST_NAME(lv_permissions_rw), "writeable", "rw", "read-write")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, FIRST_NAME(lv_permissions_r), "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, FIRST_NAME(lv_permissions_r_override), "read-only-override", "ro-override", "r-override", "R")
+FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, _reserved_number_undef_64, "auto")
+
+#define TYPE_RESERVED_VALUE_REG(type, id, description) {DM_REPORT_FIELD_TYPE_ ## type, &_reserved_ ## id, _reserved_ ## id ## _names, description},
+#define FIELD_RESERVED_VALUE_REG(id, description) {DM_REPORT_FIELD_TYPE_NONE, &_reserved_ ## id, _reserved_ ## id ## _names, description},
+
+/*
+ * Create array of reserved values to be passed for dm_report_init_with_selection
+ * function that initializes report with selection criteria. Selection code then
+ * recognizes these reserved values when parsing selection criteria.
+ */
 static const struct dm_report_reserved_value _report_reserved_values[] = {
-	{DM_REPORT_FIELD_TYPE_NUMBER, &_reserved_number_undef_64, _reserved_number_undef_64_names,
-		"Reserved value for undefined numeric value."},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_pv_allocatable, _reserved_pv_allocatable_names,
-		"pv_allocatable reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_pv_exported, _reserved_pv_exported_names,
-		"pv_exported reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_pv_missing, _reserved_pv_missing_names,
-		"pv_missing reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_extendable, _reserved_vg_extendable_names,
-		"vg_extendable reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_exported, _reserved_vg_exported_names,
-		"vg_exported reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_partial, _reserved_vg_partial_names,
-		"vg_partial reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_clustered, _reserved_vg_clustered_names,
-		"vg_clustered reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_permissions_rw, _reserved_vg_permissions_rw_names,
-		"vg_permissions reserved values (writeable)"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_permissions_r, _reserved_vg_permissions_r_names,
-		"vg_permissions reserved values (read-only)"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_mda_copies, _reserved_vg_mda_copies_names,
-		"vg_mda_copies reserved values (unmanaged)"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_initial_image_sync, _reserved_lv_initial_image_sync_names,
-		"lv_initial_image_sync reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_image_synced, _reserved_lv_image_synced_names,
-		"lv_image_synced reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_merging, _reserved_lv_merging_names,
-		"lv_merging reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_converting, _reserved_lv_converting_names,
-		"lv_converting reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_allocation_locked, _reserved_lv_allocation_locked_names,
-		"lv_allocation_locked reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_fixed_minor, _reserved_lv_fixed_minor_names,
-		"lv_fixed_minor reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_merge_failed, _reserved_lv_merge_failed_names,
-		"lv_merge_failed reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_snapshot_invalid, _reserved_lv_snapshot_invalid_names,
-		"lv_snapshot_invalid reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_suspended, _reserved_lv_suspended_names,
-		"lv_suspended reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_live_table, _reserved_lv_live_table_names,
-		"lv_live_table reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_inactive_table, _reserved_lv_inactive_table_names,
-		"lv_inactive_table reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_device_open, _reserved_lv_device_open_names,
-		"lv_device_open reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_skip_activation, _reserved_lv_skip_activation_names,
-		"lv_inactive_table reserved values"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_permissions_rw, _reserved_lv_permissions_rw_names,
-		"lv_permissions reserved values (writeable)"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_permissions_r, _reserved_lv_permissions_r_names,
-		"lv_permissions reserved values (read-only)"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_permissions_r_override, _reserved_lv_permissions_r_override_names,
-		"lv_permissions reserved values (read-only-override)"},
-	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_read_ahead, _reserved_lv_read_ahead_names,
-		"lv_read_ahead reserved values (auto)"},
+	TYPE_RESERVED_VALUE_REG(NUMBER, number_undef_64, "Reserved value for undefined numeric value.")
+	FIELD_RESERVED_VALUE_REG(pv_allocatable, "pv_allocatable reserved values")
+	FIELD_RESERVED_VALUE_REG(pv_exported, "pv_exported reserved values")
+	FIELD_RESERVED_VALUE_REG(pv_missing, "pv_missing reserved values")
+	FIELD_RESERVED_VALUE_REG(vg_extendable, "vg_extendable reserved values")
+	FIELD_RESERVED_VALUE_REG(vg_exported, "vg_exported reserved values")
+	FIELD_RESERVED_VALUE_REG(vg_partial, "vg_partial reserved values")
+	FIELD_RESERVED_VALUE_REG(vg_clustered, "vg_clustered reserved values")
+	FIELD_RESERVED_VALUE_REG(vg_permissions_rw, "vg_permissions reserved values (writeable)")
+	FIELD_RESERVED_VALUE_REG(vg_permissions_r, "vg_permissions reserved values (read-only)")
+	FIELD_RESERVED_VALUE_REG(vg_mda_copies, "vg_mda_copies reserved values (unmanaged)")
+	FIELD_RESERVED_VALUE_REG(lv_initial_image_sync, "lv_initial_image_sync reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_image_synced, "lv_image_synced reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_merging, "lv_merging reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_converting, "lv_converting reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_allocation_locked, "lv_allocation_locked reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_fixed_minor, "lv_fixed_minor reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_merge_failed, "lv_merge_failed reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_snapshot_invalid, "lv_snapshot_invalid reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_suspended, "lv_suspended reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_live_table, "lv_live_table reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_inactive_table, "lv_inactive_table reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_device_open, "lv_device_open reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_skip_activation, "lv_inactive_table reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_permissions_rw, "lv_permissions reserved values (writeable)")
+	FIELD_RESERVED_VALUE_REG(lv_permissions_r, "lv_permissions reserved values (read-only)")
+	FIELD_RESERVED_VALUE_REG(lv_permissions_r_override,  "lv_permissions reserved values (read-only-override)")
+	FIELD_RESERVED_VALUE_REG(lv_read_ahead, "lv_read_ahead reserved values (auto)")
 	{0, NULL, NULL}
 };
 
-static const char *_str_unknown = "unknown";
-static const char *_str_minus_one = "-1";
-
 static int _field_set_value(struct dm_report_field *field, const void *data, const void *sort)
 {
 	dm_report_field_set_value(field, data, sort);
@@ -204,6 +163,36 @@ static int _field_set_value(struct dm_report_field *field, const void *data, con
 /*
  * Data-munging functions to prepare each data type for display and sorting
  */
+
+/*
+ * Display either "0"/"1" or ""/"word" based on bin_value,
+ * cmd->report_binary_values_as_numeric selects the mode to use.
+*/
+static int _binary_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			struct dm_report_field *field, int bin_value, const char *word,
+			void *private)
+{
+	const struct cmd_context *cmd = (const struct cmd_context *) private;
+
+	if (cmd->report_binary_values_as_numeric)
+		/* "0"/"1" */
+		return _field_set_value(field, bin_value ? _str_one : _str_zero, bin_value ? &_one64 : &_zero64);
+	else
+		/* blank/"word" */
+		return _field_set_value(field, bin_value ? word : "", bin_value ? &_one64 : &_zero64);
+}
+
+static int _binary_undef_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			      struct dm_report_field *field, void *private)
+{
+	const struct cmd_context *cmd = (const struct cmd_context *) private;
+
+	if (cmd->report_binary_values_as_numeric)
+		return _field_set_value(field, FIRST_NAME(number_undef_64), &_reserved_number_undef_64);
+	else
+		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+}
+
 static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
@@ -1296,41 +1285,12 @@ static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
 
 /* PV/VG/LV Attributes */
 
-/*
- * Display either "0"/"1" or ""/"word" based on bin_value,
- * cmd->report_binary_values_as_numeric selects the mode to use.
-*/
-static int _binary_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-			struct dm_report_field *field, int bin_value, const char *word,
-			void *private)
-{
-	const struct cmd_context *cmd = (const struct cmd_context *) private;
-
-	if (cmd->report_binary_values_as_numeric)
-		/* "0"/"1" */
-		return _field_set_value(field, bin_value ? _str_one : _str_zero, bin_value ? &_one64 : &_zero64);
-	else
-		/* blank/"word" */
-		return _field_set_value(field, bin_value ? word : "", bin_value ? &_one64 : &_zero64);
-}
-
-static int _binary_undef_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
-			      struct dm_report_field *field, void *private)
-{
-	const struct cmd_context *cmd = (const struct cmd_context *) private;
-
-	if (cmd->report_binary_values_as_numeric)
-		return _field_set_value(field, _str_minus_one, &_reserved_number_undef_64);
-	else
-		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
-}
-
 static int _pvallocatable_disp(struct dm_report *rh, struct dm_pool *mem,
 			       struct dm_report_field *field,
 			       const void *data, void *private)
 {
 	int allocatable = (((const struct physical_volume *) data)->status & ALLOCATABLE_PV) != 0;
-	return _binary_disp(rh, mem, field, allocatable, "allocatable", private);
+	return _binary_disp(rh, mem, field, allocatable, FIRST_NAME(pv_allocatable), private);
 }
 
 static int _pvexported_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1338,7 +1298,7 @@ static int _pvexported_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	int exported = (((const struct physical_volume *) data)->status & EXPORTED_VG) != 0;
-	return _binary_disp(rh, mem, field, exported, "exported", private);
+	return _binary_disp(rh, mem, field, exported, FIRST_NAME(pv_exported), private);
 }
 
 static int _pvmissing_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1346,14 +1306,15 @@ static int _pvmissing_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	int missing = (((const struct physical_volume *) data)->status & MISSING_PV) != 0;
-	return _binary_disp(rh, mem, field, missing, "missing", private);
+	return _binary_disp(rh, mem, field, missing, FIRST_NAME(pv_missing), private);
 }
 
 static int _vgpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 			       struct dm_report_field *field,
 			       const void *data, void *private)
 {
-	const char *perms = ((const struct volume_group *) data)->status & LVM_WRITE ? "writeable" : "read-only";
+	const char *perms = ((const struct volume_group *) data)->status & LVM_WRITE ? FIRST_NAME(vg_permissions_rw)
+										     : FIRST_NAME(vg_permissions_r);
 	return _string_disp(rh, mem, field, &perms, private);
 }
 
@@ -1362,7 +1323,7 @@ static int _vgextendable_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	int extendable = (vg_is_resizeable((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, extendable, "extendable", private);
+	return _binary_disp(rh, mem, field, extendable, FIRST_NAME(vg_extendable), private);
 }
 
 static int _vgexported_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1370,7 +1331,7 @@ static int _vgexported_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	int exported = (vg_is_exported((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, exported, "exported", private);
+	return _binary_disp(rh, mem, field, exported, FIRST_NAME(vg_exported), private);
 }
 
 static int _vgpartial_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1378,7 +1339,7 @@ static int _vgpartial_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	int partial = (vg_missing_pv_count((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, partial, "partial", private);
+	return _binary_disp(rh, mem, field, partial, FIRST_NAME(vg_partial), private);
 }
 
 static int _vgallocationpolicy_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1394,7 +1355,7 @@ static int _vgclustered_disp(struct dm_report *rh, struct dm_pool *mem,
 			     const void *data, void *private)
 {
 	int clustered = (vg_is_clustered((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, clustered, "clustered", private);
+	return _binary_disp(rh, mem, field, clustered, FIRST_NAME(vg_clustered), private);
 }
 
 static int _lvvolumetype_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1417,7 +1378,7 @@ static int _lvinitialimagesync_disp(struct dm_report *rh, struct dm_pool *mem,
 	else
 		initial_image_sync = 0;
 
-	return _binary_disp(rh, mem, field, initial_image_sync, "initial image sync", private);
+	return _binary_disp(rh, mem, field, initial_image_sync, FIRST_NAME(lv_initial_image_sync), private);
 }
 
 static int _lvimagesynced_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1434,7 +1395,7 @@ static int _lvimagesynced_disp(struct dm_report *rh, struct dm_pool *mem,
 	else
 		image_synced = 0;
 
-	return _binary_disp(rh, mem, field, image_synced, "image synced", private);
+	return _binary_disp(rh, mem, field, image_synced, FIRST_NAME(lv_image_synced), private);
 }
 
 static int _lvmerging_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1453,7 +1414,7 @@ static int _lvmerging_disp(struct dm_report *rh, struct dm_pool *mem,
 	else
 		merging = 0;
 
-	return _binary_disp(rh, mem, field, merging, "merging", private);
+	return _binary_disp(rh, mem, field, merging, FIRST_NAME(lv_merging), private);
 }
 
 static int _lvconverting_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1474,11 +1435,11 @@ static int _lvpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (!(lvi->lv->status & PVMOVE)) {
 		if (lvi->lv->status & LVM_WRITE) {
 			if (lvi->info->read_only)
-				perms = "read-only-override";
+				perms = FIRST_NAME(lv_permissions_r_override);
 			else
-				perms = "writeable";
+				perms = FIRST_NAME(lv_permissions_rw);
 		} else if (lvi->lv->status & LVM_READ)
-			perms = "read-only";
+			perms = FIRST_NAME(lv_permissions_r);
 		else
 			perms = _str_unknown;
 	}
@@ -1499,7 +1460,7 @@ static int _lvallocationlocked_disp(struct dm_report *rh, struct dm_pool *mem,
 				    const void *data, void *private)
 {
 	int alloc_locked = (((const struct logical_volume *) data)->status & LOCKED) != 0;
-	return _binary_disp(rh, mem, field, alloc_locked, "allocation locked", private);
+	return _binary_disp(rh, mem, field, alloc_locked, FIRST_NAME(lv_allocation_locked), private);
 }
 
 static int _lvfixedminor_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1507,7 +1468,7 @@ static int _lvfixedminor_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	int fixed_minor = (((const struct logical_volume *) data)->status & FIXED_MINOR) != 0;
-	return _binary_disp(rh, mem, field, fixed_minor, "fixed minor", private);
+	return _binary_disp(rh, mem, field, fixed_minor, FIRST_NAME(lv_fixed_minor), private);
 }
 
 static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1522,7 +1483,7 @@ static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
 
 	merge_failed = snap_percent == LVM_PERCENT_MERGE_FAILED;
-	return _binary_disp(rh, mem, field, merge_failed, "merge failed", private);
+	return _binary_disp(rh, mem, field, merge_failed, FIRST_NAME(lv_merge_failed), private);
 }
 
 static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1537,7 +1498,7 @@ static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
 
 	snap_invalid = !lv_snapshot_percent(lv, &snap_percent) || snap_percent == DM_PERCENT_INVALID;
-	return _binary_disp(rh, mem, field, snap_invalid, "snapshot invalid", private);
+	return _binary_disp(rh, mem, field, snap_invalid, FIRST_NAME(lv_snapshot_invalid), private);
 }
 
 static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1547,7 +1508,7 @@ static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
 	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->suspended, "suspended", private);
+		return _binary_disp(rh, mem, field, lvi->info->suspended, FIRST_NAME(lv_suspended), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1559,7 +1520,7 @@ static int _lvlivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
 	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->live_table, "live table present", private);
+		return _binary_disp(rh, mem, field, lvi->info->live_table, FIRST_NAME(lv_live_table), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1571,7 +1532,7 @@ static int _lvinactivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
 	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->inactive_table, "inactive table present", private);
+		return _binary_disp(rh, mem, field, lvi->info->inactive_table, FIRST_NAME(lv_inactive_table), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1583,7 +1544,7 @@ static int _lvdeviceopen_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
 	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->open_count, "open", private);
+		return _binary_disp(rh, mem, field, lvi->info->open_count, FIRST_NAME(lv_device_open), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }



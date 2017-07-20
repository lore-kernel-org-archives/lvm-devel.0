From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 06:18:50 -0400
Subject: master - cleanup: add braces in macro
Message-ID: <201707201018.v6KAIoeV016476@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0d0a3397c22b9d5342584299acd814f6c8221c18
Commit:        0d0a3397c22b9d5342584299acd814f6c8221c18
Parent:        b37e4e3f90b005e116b46949d55f95b9d1470f5b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 19 16:17:30 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 11:18:29 2017 +0200

cleanup: add braces in macro

---
 lib/config/config.c           |   16 ++++++++--------
 lib/device/dev-md.c           |    2 +-
 lib/format_text/export.c      |    2 +-
 lib/format_text/import_vsn1.c |    6 +++---
 lib/locking/lvmlockd.c        |    2 +-
 lib/metadata/raid_manip.c     |    2 +-
 lib/report/report.c           |    6 +++---
 libdm/libdm-report.c          |    4 ++--
 tools/command.c               |    2 +-
 tools/dmsetup.c               |    2 +-
 tools/reporter.c              |   10 +++++-----
 tools/toollib.c               |    4 ++--
 12 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 5c5916b..daf5fa3 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -65,11 +65,11 @@ struct config_source {
  * Map each ID to respective definition of the configuration item.
  */
 static struct cfg_def_item _cfg_def_items[CFG_COUNT + 1] = {
-#define cfg_section(id, name, parent, flags, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_SECTION, {0}, flags, since_version, {0}, deprecated_since_version, deprecation_comment, comment},
-#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, deprecated_since_version, deprecation_comment, comment) {id, parent, name, type, {.v_##type = default_value}, flags, since_version, {.v_UNCONFIGURED = unconfigured_value}, deprecated_since_version, deprecation_comment, comment},
-#define cfg_runtime(id, name, parent, flags, type, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, type, {.fn_##type = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, {.fn_UNCONFIGURED = get_default_unconfigured_##id}, deprecated_since_version, deprecation_comment, comment},
-#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.v_CFG_TYPE_STRING = default_value}, flags, since_version, {.v_UNCONFIGURED = unconfigured_value}, deprecated_since_version, deprecation_comment, comment},
-#define cfg_array_runtime(id, name, parent, flags, types, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.fn_CFG_TYPE_STRING = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, {.fn_UNCONFIGURED = get_default_unconfigured_##id}, deprecated_since_version, deprecation_comment, comment},
+#define cfg_section(id, name, parent, flags, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_SECTION, {0}, (flags), since_version, {0}, deprecated_since_version, deprecation_comment, comment},
+#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, deprecated_since_version, deprecation_comment, comment) {id, parent, name, type, {.v_##type = (default_value)}, (flags), since_version, {.v_UNCONFIGURED = (unconfigured_value)}, deprecated_since_version, deprecation_comment, comment},
+#define cfg_runtime(id, name, parent, flags, type, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, type, {.fn_##type = get_default_##id}, (flags) | CFG_DEFAULT_RUN_TIME, since_version, {.fn_UNCONFIGURED = get_default_unconfigured_##id}, deprecated_since_version, (deprecation_comment), comment},
+#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_ARRAY | (types), {.v_CFG_TYPE_STRING = (default_value)}, (flags), (since_version), {.v_UNCONFIGURED = (unconfigured_value)}, deprecated_since_version, deprecation_comment, comment},
+#define cfg_array_runtime(id, name, parent, flags, types, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_ARRAY | (types), {.fn_CFG_TYPE_STRING = get_default_##id}, (flags) | CFG_DEFAULT_RUN_TIME, (since_version), {.fn_UNCONFIGURED = get_default_unconfigured_##id}, deprecated_since_version, deprecation_comment, comment},
 #include "config_settings.h"
 #undef cfg_section
 #undef cfg
@@ -619,9 +619,9 @@ struct timespec config_file_timestamp(struct dm_config_tree *cft)
 }
 
 #define cfg_def_get_item_p(id) (&_cfg_def_items[id])
-#define cfg_def_get_default_unconfigured_value_hint(cmd,item) ((item->flags & CFG_DEFAULT_RUN_TIME) ? item->default_unconfigured_value.fn_UNCONFIGURED(cmd) : item->default_unconfigured_value.v_UNCONFIGURED)
-#define cfg_def_get_default_value_hint(cmd,item,type,profile) ((item->flags & CFG_DEFAULT_RUN_TIME) ? item->default_value.fn_##type(cmd,profile) : item->default_value.v_##type)
-#define cfg_def_get_default_value(cmd,item,type,profile) (item->flags & CFG_DEFAULT_UNDEFINED ? 0 : cfg_def_get_default_value_hint(cmd,item,type,profile))
+#define cfg_def_get_default_unconfigured_value_hint(cmd,item) (((item)->flags & CFG_DEFAULT_RUN_TIME) ? (item)->default_unconfigured_value.fn_UNCONFIGURED(cmd) : (item)->default_unconfigured_value.v_UNCONFIGURED)
+#define cfg_def_get_default_value_hint(cmd,item,type,profile) (((item)->flags & CFG_DEFAULT_RUN_TIME) ? (item)->default_value.fn_##type(cmd,profile) : (item)->default_value.v_##type)
+#define cfg_def_get_default_value(cmd,item,type,profile) ((item)->flags & CFG_DEFAULT_UNDEFINED ? 0 : cfg_def_get_default_value_hint(cmd,item,type,profile))
 
 static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t *item, int xlate)
 {
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 3dbe831..d0e69a1 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -28,7 +28,7 @@
 #define MD_SB_MAGIC 0xa92b4efc
 #define MD_RESERVED_BYTES (64 * 1024ULL)
 #define MD_RESERVED_SECTORS (MD_RESERVED_BYTES / 512)
-#define MD_NEW_SIZE_SECTORS(x) ((x & ~(MD_RESERVED_SECTORS - 1)) \
+#define MD_NEW_SIZE_SECTORS(x) (((x) & ~(MD_RESERVED_SECTORS - 1)) \
 				- MD_RESERVED_SECTORS)
 #define MD_MAX_SYSFS_SIZE 64
 
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 7a84909..9fede20 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -42,7 +42,7 @@ typedef int (*nl_fn) (struct formatter * f);
 #define _out_with_comment(f, buffer, fmt, ap) \
 	do { \
 		va_start(ap, fmt); \
-		r = f->out_with_comment(f, buffer, fmt, ap); \
+		r = (f)->out_with_comment((f), (buffer), (fmt), ap); \
 		va_end(ap); \
 	} while (r == -1)
 
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 7d9257e..9267d45 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -37,13 +37,13 @@ typedef int (*section_fn) (struct format_instance * fid,
 			   unsigned report_missing_devices);
 
 #define _read_int32(root, path, result) \
-	dm_config_get_uint32(root, path, (uint32_t *) result)
+	dm_config_get_uint32(root, path, (uint32_t *) (result))
 
 #define _read_uint32(root, path, result) \
-	dm_config_get_uint32(root, path, result)
+	dm_config_get_uint32(root, path, (result))
 
 #define _read_uint64(root, path, result) \
-	dm_config_get_uint64(root, path, result)
+	dm_config_get_uint64(root, path, (result))
 
 /*
  * Logs an attempt to read an invalid format file.
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 34b3882..94a674f 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -134,7 +134,7 @@ static void _flags_str_to_lockd_flags(const char *flags_str, uint32_t *lockd_fla
  * will not return.  daemon_reply_int reverts to this
  * value if it finds no result value.
  */
-#define NO_LOCKD_RESULT -1000
+#define NO_LOCKD_RESULT (-1000)
 
 static int _lockd_result(daemon_reply reply, int *result, uint32_t *lockd_flags)
 {
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c207970..84c14ba 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -26,7 +26,7 @@ typedef int (*fn_on_lv_t)(struct logical_volume *lv, void *data);
 static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
 						      struct dm_list *removal_lvs,
 						      int vg_write_requested);
-#define	ARRAY_SIZE(a) (sizeof(a) / sizeof(*a))
+#define	ARRAY_SIZE(a) (sizeof(a) / sizeof(*(a)))
 
 static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index de8c06a..71fe35a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -162,7 +162,7 @@ struct time_prop {
 	time_id_t granularity;
 };
 
-#define ADD_TIME_PROP(id, flags, granularity) [id] = {id, flags, granularity},
+#define ADD_TIME_PROP(id, flags, granularity) [(id)] = {(id), (flags), (granularity)},
 
 static const struct time_prop _time_props[] = {
 	ADD_TIME_PROP(TIME_NULL,                    0,							TIME_NULL)
@@ -228,7 +228,7 @@ struct time_reg {
 	uint32_t reg_flags;
 };
 
-#define TIME_PROP(id) (_time_props + id)
+#define TIME_PROP(id) (_time_props + (id))
 
 static const struct time_reg _time_reg[] = {
 	/*
@@ -3915,7 +3915,7 @@ static const struct dm_report_object_type _devtypes_report_types[] = {
 #define STR_LIST DM_REPORT_FIELD_TYPE_STRING_LIST
 #define SNUM DM_REPORT_FIELD_TYPE_NUMBER
 #define FIELD(type, strct, sorttype, head, field, width, func, id, desc, writeable) \
-	{type, sorttype, offsetof(type_ ## strct, field), width ? : sizeof(head) - 1, \
+	{type, sorttype, offsetof(type_ ## strct, field), (width) ? : sizeof(head) - 1, \
 	 #id, head, &_ ## func ## _disp, desc},
 
 typedef struct cmd_log_item type_cmd_log_item;
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index a0ad26c..a5100d4 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1426,10 +1426,10 @@ static int _dbl_less_or_equal(double d1, double d2)
 }
 
 #define _uint64 *(const uint64_t *)
-#define _uint64arr(var,index) ((const uint64_t *)var)[index]
+#define _uint64arr(var,index) ((const uint64_t *)(var))[(index)]
 #define _str (const char *)
 #define _dbl *(const double *)
-#define _dblarr(var,index) ((const double *)var)[index]
+#define _dblarr(var,index) ((const double *)(var))[(index)]
 
 static int _do_check_value_is_strictly_reserved(unsigned type, const void *res_val, int res_range,
 						const void *val, struct field_selection *fs)
diff --git a/tools/command.c b/tools/command.c
index c094f12..bd3c7cc 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -284,7 +284,7 @@ static struct oo_line oo_lines[MAX_OO_LINES];
 
 #define REQUIRED 1  /* required option */
 #define OPTIONAL 0  /* optional option */
-#define IGNORE -1   /* ignore option */
+#define IGNORE (-1)   /* ignore option */
 
 #define MAX_LINE 1024
 #define MAX_LINE_ARGC 256
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 69649ae..cbaae22 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -296,7 +296,7 @@ static uint64_t _new_interval = 0; /* flag top-of-interval */
 static uint64_t _last_interval = 0; /* approx. measured interval in nsecs */
 
 /* Invalid fd value used to signal end-of-reporting. */
-#define TIMER_STOPPED -2
+#define TIMER_STOPPED (-2)
 
 #define NSEC_PER_USEC	UINT64_C(1000)
 #define NSEC_PER_MSEC	UINT64_C(1000000)
diff --git a/tools/reporter.c b/tools/reporter.c
index ad9d5ee..98e3d12 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -780,7 +780,7 @@ static void _del_option_from_list(struct dm_list *sll, const char *prefix,
 }
 
 #define _get_report_idx(report_type,single_report_type) \
-	(((report_type != FULL) && (report_type == single_report_type)) ? REPORT_IDX_SINGLE : REPORT_IDX_FULL_ ## single_report_type)
+	((((report_type) != FULL) && ((report_type) == single_report_type)) ? REPORT_IDX_SINGLE : REPORT_IDX_FULL_ ## single_report_type)
 
 static report_idx_t _get_report_idx_from_name(report_type_t report_type, const char *name)
 {
@@ -1262,10 +1262,10 @@ out:
 
 #define _set_full_report_single(cmd,args,type,name) \
 	do { \
-		args->single_args[REPORT_IDX_FULL_ ## type].report_type = type; \
-		args->single_args[REPORT_IDX_FULL_ ## type].keys = find_config_tree_str(cmd, report_ ## name ## _sort_full_CFG, NULL); \
-		args->single_args[REPORT_IDX_FULL_ ## type].options = find_config_tree_str(cmd, report_ ## name ## _cols_full_CFG, NULL); \
-		if (!_set_report_prefix_and_name(args, &args->single_args[REPORT_IDX_FULL_ ## type])) \
+		(args)->single_args[REPORT_IDX_FULL_ ## type].report_type = type; \
+		(args)->single_args[REPORT_IDX_FULL_ ## type].keys = find_config_tree_str(cmd, report_ ## name ## _sort_full_CFG, NULL); \
+		(args)->single_args[REPORT_IDX_FULL_ ## type].options = find_config_tree_str(cmd, report_ ## name ## _cols_full_CFG, NULL); \
+		if (!_set_report_prefix_and_name((args), &(args)->single_args[REPORT_IDX_FULL_ ## type])) \
 			return_0; \
 	} while (0)
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 2836aeb..9e89ed7 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -23,8 +23,8 @@
 #include <sys/utsname.h>
 
 #define report_log_ret_code(ret_code) report_current_object_cmdlog(REPORT_OBJECT_CMDLOG_NAME, \
-					ret_code == ECMD_PROCESSED ? REPORT_OBJECT_CMDLOG_SUCCESS \
-								   : REPORT_OBJECT_CMDLOG_FAILURE, ret_code)
+					((ret_code) == ECMD_PROCESSED) ? REPORT_OBJECT_CMDLOG_SUCCESS \
+								   : REPORT_OBJECT_CMDLOG_FAILURE, (ret_code))
 
 struct device_id_list {
 	struct dm_list list;



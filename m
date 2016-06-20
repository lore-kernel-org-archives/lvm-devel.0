From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:03 +0000 (UTC)
Subject: master - log: log warnings and errors via report if set; add log_set_report* fns
Message-ID: <20160620094103.3082E60FE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d4a15e53a19dcc073b7037638d811eba3a85edf
Commit:        7d4a15e53a19dcc073b7037638d811eba3a85edf
Parent:        8cfc385491484e71d66e5991e09c3d0a47570a13
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 3 11:46:52 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

log: log warnings and errors via report if set; add log_set_report* fns

This patch adds structures and functions to reroute error and warning
logs to log report, if it's set.

There are 5 new functions:
  - log_set_report
    Set log report where logging will be rerouted.

  - log_set_report_context
    Set context globally so any report_cmdlog call will use it.

  - log_set_report_object_type
    Set object type globally so any report_cmdlog call will use it.

  - log_set_report_object_name_and_id
    Set object ID and name globally so any report_cmdlog call will use it.

  - log_set_report_object_group_and_group_id
    Set object group ID and name globally so any report_cmdlog call will use it.

These functions will be called during LVM command processing so any logs
which are rerouted to log report contain proper information about current
processing state.
---
 WHATS_NEW             |    1 +
 lib/log/log.c         |  101 ++++++++++++++++++++++++++++++++++++++++++++++++-
 lib/log/lvm-logging.h |   37 ++++++++++++++++++
 lib/report/report.h   |    3 +-
 tools/reporter.c      |    8 +++-
 tools/toollib.c       |    8 +++-
 tools/toollib.h       |    1 +
 7 files changed, 154 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index edbc0f3..88e785a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Log warnings and errors via report during cmd processing if this is enabled.
   Make it possible to iterate over internal 'orphan' VGs in process_each_vg fn.
   Make -S|--select option groupable that allows this option to be repeated.
   Make -O|--sort option groupable that allows this option to be repeated.
diff --git a/lib/log/log.c b/lib/log/log.c
index 7b0026f..3181fdd 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -17,6 +17,7 @@
 #include "device.h"
 #include "memlock.h"
 #include "defaults.h"
+#include "report.h"
 
 #include <stdio.h>
 #include <stdarg.h>
@@ -47,6 +48,15 @@ static size_t _lvm_errmsg_size = 0;
 static size_t _lvm_errmsg_len = 0;
 #define MAX_ERRMSG_LEN (512 * 1024)  /* Max size of error buffer 512KB */
 
+static log_report_t _log_report = {
+	.report = NULL,
+	.context = LOG_REPORT_CONTEXT_NULL,
+	.object_type = LOG_REPORT_OBJECT_TYPE_NULL,
+	.object_id = NULL,
+	.object_name = NULL,
+	.object_group = NULL
+};
+
 void init_log_fn(lvm2_log_fn_t log_fn)
 {
 	_lvm2_log_fn = log_fn;
@@ -260,6 +270,38 @@ void reset_log_duplicated(void) {
 	}
 }
 
+static const char *_get_log_level_name(int level)
+{
+	static const char *log_level_names[] = {"",      /* unassigned */
+						"",      /* unassigned */
+						"fatal", /* _LOG_FATAL */
+						"error", /* _LOG_ERROR */
+						"warn",  /* _LOG_WARN */
+						"notice" /* _LOG_NOTICE */
+						"info",  /* _LOG_INFO */
+						"debug"  /* _LOG_DEBUG */
+						};
+	level &= ~_LOG_STDERR;
+	return log_level_names[level];
+}
+
+const char *log_get_report_context_name(log_report_context_t context)
+{
+	static const char *log_context_names[LOG_REPORT_CONTEXT_COUNT] = {[LOG_REPORT_CONTEXT_NULL] = "",
+									  [LOG_REPORT_CONTEXT_PROCESSING] = "processing"};
+	return log_context_names[context];
+}
+
+
+const char *log_get_report_object_type_name(log_report_object_type_t object_type)
+{
+	static const char *log_object_type_names[LOG_REPORT_OBJECT_TYPE_COUNT] = {[LOG_REPORT_OBJECT_TYPE_NULL] = "",
+										  [LOG_REPORT_OBJECT_TYPE_PV] = "pv",
+										  [LOG_REPORT_OBJECT_TYPE_VG] = "vg",
+										  [LOG_REPORT_OBJECT_TYPE_LV] = "lv"};
+	return log_object_type_names[object_type];
+}
+
 void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	       const char *format, ...)
 {
@@ -277,6 +319,8 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	static int _abort_on_internal_errors_env_present = -1;
 	static int _abort_on_internal_errors_env = 0;
 	char *env_str;
+	struct dm_report *orig_report;
+	int logged_via_report = 0;
 
 	level &= ~(_LOG_STDERR|_LOG_ONCE);
 
@@ -309,6 +353,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 
 	if (_lvm2_log_fn ||
 	    (_store_errmsg && (level <= _LOG_ERR)) ||
+	    (_log_report.report && (use_stderr || (level <=_LOG_ERR))) ||
 	    log_once) {
 		va_start(ap, format);
 		n = vsnprintf(message, sizeof(message), trformat, ap);
@@ -356,6 +401,23 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		}
 	}
 
+	if (_log_report.report && (use_stderr || (level <= _LOG_ERR))) {
+		orig_report = _log_report.report;
+		_log_report.report = NULL;
+
+		if (!report_cmdlog(orig_report, _get_log_level_name(level),
+				   log_get_report_context_name(_log_report.context),
+				   log_get_report_object_type_name(_log_report.object_type),
+				   _log_report.object_name, _log_report.object_id,
+				   _log_report.object_group, _log_report.object_group_id,
+				   message, _lvm_errno, 0))
+			fprintf(stderr, _("failed to report cmdstatus"));
+		else
+			logged_via_report = 1;
+
+		_log_report.report = orig_report;
+	}
+
 	if (_lvm2_log_fn) {
 		_lvm2_log_fn(level, file, line, 0, message);
 		if (fatal_internal_error)
@@ -364,7 +426,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	}
 
       log_it:
-	if ((verbose_level() >= level) && !_log_suppress) {
+	if (!logged_via_report && ((verbose_level() >= level) && !_log_suppress)) {
 		if (verbose_level() > _LOG_DEBUG) {
 			(void) dm_snprintf(buf, sizeof(buf), "#%s:%d ",
 					   file, line);
@@ -462,3 +524,40 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		_already_logging = 0;
 	}
 }
+
+log_report_t log_get_report_state(void)
+{
+	return _log_report;
+}
+
+void log_restore_report_state(log_report_t log_report)
+{
+	_log_report = log_report;
+}
+
+void log_set_report(struct dm_report *report)
+{
+	_log_report.report = report;
+}
+
+void log_set_report_context(log_report_context_t context)
+{
+	_log_report.context = context;
+}
+
+void log_set_report_object_type(log_report_object_type_t object_type)
+{
+	_log_report.object_type = object_type;
+}
+
+void log_set_report_object_group_and_group_id(const char *group, const char *id)
+{
+	_log_report.object_group = group;
+	_log_report.object_group_id = id;
+}
+
+void log_set_report_object_name_and_id(const char *name, const char *id)
+{
+	_log_report.object_name = name;
+	_log_report.object_id = id;
+}
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 56e95ff..5789c0b 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -65,4 +65,41 @@ int log_suppress(int suppress);
 /* Suppress messages to syslog */
 void syslog_suppress(int suppress);
 
+/* Hooks to handle logging through report. */
+typedef enum {
+	LOG_REPORT_CONTEXT_NULL,
+	LOG_REPORT_CONTEXT_PROCESSING,
+	LOG_REPORT_CONTEXT_COUNT
+} log_report_context_t;
+
+typedef enum {
+	LOG_REPORT_OBJECT_TYPE_NULL,
+	LOG_REPORT_OBJECT_TYPE_PV,
+	LOG_REPORT_OBJECT_TYPE_VG,
+	LOG_REPORT_OBJECT_TYPE_LV,
+	LOG_REPORT_OBJECT_TYPE_COUNT
+} log_report_object_type_t;
+
+typedef struct log_report {
+	struct dm_report *report;
+	log_report_context_t context;
+	log_report_object_type_t object_type;
+	const char *object_name;
+	const char *object_id;
+	const char *object_group;
+	const char *object_group_id;
+} log_report_t;
+
+log_report_t log_get_report_state(void);
+void log_restore_report_state(log_report_t log_report);
+
+void log_set_report(struct dm_report *report);
+void log_set_report_context(log_report_context_t context);
+void log_set_report_object_type(log_report_object_type_t object_type);
+void log_set_report_object_group_and_group_id(const char *group, const char *group_id);
+void log_set_report_object_name_and_id(const char *name, const char *id);
+
+const char *log_get_report_context_name(log_report_context_t context);
+const char *log_get_report_object_type_name(log_report_object_type_t object_type);
+
 #endif
diff --git a/lib/report/report.h b/lib/report/report.h
index f5df51e..37e1061 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -82,7 +82,8 @@ typedef int (*field_report_fn) (struct report_handle * dh, struct field * field,
 				const void *data);
 
 int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_group_type,
-		       struct dm_report_group **report_group, struct dm_report **log_rh);
+		       struct dm_report_group **report_group, struct dm_report **log_rh,
+		       log_report_t *saved_log_report_state);
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
diff --git a/tools/reporter.c b/tools/reporter.c
index 0509c88..d376947 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1418,7 +1418,8 @@ int devtypes(struct cmd_context *cmd, int argc, char **argv)
 #define REPORT_FORMAT_NAME_JSON "json"
 
 int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_group_type,
-		       struct dm_report_group **report_group, struct dm_report **log_rh)
+		       struct dm_report_group **report_group, struct dm_report **log_rh,
+		       log_report_t *saved_log_report_state)
 {
 	int config_set = find_config_tree_node(cmd, report_output_format_CFG, NULL) != NULL;
 	const char *config_format_str = find_config_tree_str(cmd, report_output_format_CFG, NULL);
@@ -1483,6 +1484,11 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 	*report_group = new_report_group;
 	if (tmp_log_rh)
 		*log_rh = tmp_log_rh;
+
+	if (saved_log_report_state) {
+		*saved_log_report_state = log_get_report_state();
+		log_set_report(*log_rh);
+	}
 	return 1;
 bad:
 	if (!dm_report_group_destroy(new_report_group))
diff --git a/tools/toollib.c b/tools/toollib.c
index 925157d..fe162d1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1729,11 +1729,12 @@ struct processing_handle *init_processing_handle(struct cmd_context *cmd, struct
 
 	if (!parent_handle) {
 		if (!report_format_init(cmd, &handle->report_group_type, &handle->report_group,
-					&handle->log_rh)) {
+					&handle->log_rh, &handle->saved_log_report_state)) {
 			dm_pool_free(cmd->mem, handle);
 			return NULL;
 		}
-	}
+	} else
+		handle->saved_log_report_state = log_get_report_state();
 
 	return handle;
 }
@@ -1767,6 +1768,9 @@ void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle
 	if (handle) {
 		if (handle->selection_handle && handle->selection_handle->selection_rh)
 			dm_report_free(handle->selection_handle->selection_rh);
+
+		log_restore_report_state(handle->saved_log_report_state);
+
 		if (!dm_report_group_destroy(handle->report_group))
 			stack;
 		if (handle->log_rh)
diff --git a/tools/toollib.h b/tools/toollib.h
index 179efe5..1144793 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -76,6 +76,7 @@ struct processing_handle {
 	dm_report_group_type_t report_group_type;
 	struct dm_report_group *report_group;
 	struct dm_report *log_rh;
+	log_report_t saved_log_report_state;
 	void *custom_handle;
 };
 



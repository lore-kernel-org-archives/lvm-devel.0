From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:07 +0000 (UTC)
Subject: master - log: also pass log_print through report and add log_print_bypass_report for use in libdm-report for direct print without report
Message-ID: <20160620094107.544FA60D3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f50d4011cdd3ef38c15b9dea05e73321592d93c2
Commit:        f50d4011cdd3ef38c15b9dea05e73321592d93c2
Parent:        fe63715f25cf156b07e144a2e7b5cce56d32e39e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 19 12:19:48 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

log: also pass log_print through report and add log_print_bypass_report for use in libdm-report for direct print without report

log_print is used during cmd line processing to log the result of the
operation (e.g. "Volume group vg successfully changed" and similar).

We don't want output from log_print to be interleaved with current
reports from group where log is reported as well. Also, the information
printed by log_print belongs to the log report too, so it should be
rerouted to log report if it's set.

Since the code in libdm-report which is responsible for doing the report
output uses log_print too, we need to use a different kind of log_print
which bypasses any log report currently used for logging (...simply,
we can't call log_print to output the log report itself which in turn
would again reroute to report - the report would never get on output
this way).
---
 WHATS_NEW            |    1 +
 WHATS_NEW_DM         |    1 +
 lib/log/log.c        |   16 +++++++++-------
 lib/log/log.h        |    2 ++
 libdm/libdm-common.c |    2 +-
 libdm/libdm-report.c |   32 ++++++++++++++++----------------
 6 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 88e785a..823eeaf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Also pass common printed messages (besides warnings and errors) to log report.
   Log warnings and errors via report during cmd processing if this is enabled.
   Make it possible to iterate over internal 'orphan' VGs in process_each_vg fn.
   Make -S|--select option groupable that allows this option to be repeated.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index da36f49..fa4b9e6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.128 -
 =================================
+  Add _LOG_BYPASS_REPORT flag for bypassing any log report currently set.
   Introduce DM_REPORT_GROUP_JSON for report group with JSON output format.
   Introduce DM_REPORT_GROUP_BASIC for report group with basic report output.
   Introduce DM_REPORT_GROUP_SINGLE for report group having single report only.
diff --git a/lib/log/log.c b/lib/log/log.c
index 3181fdd..0bd2de9 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -270,7 +270,7 @@ void reset_log_duplicated(void) {
 	}
 }
 
-static const char *_get_log_level_name(int level)
+static const char *_get_log_level_name(int use_stderr, int level)
 {
 	static const char *log_level_names[] = {"",      /* unassigned */
 						"",      /* unassigned */
@@ -281,7 +281,9 @@ static const char *_get_log_level_name(int level)
 						"info",  /* _LOG_INFO */
 						"debug"  /* _LOG_DEBUG */
 						};
-	level &= ~_LOG_STDERR;
+	if (level == _LOG_WARN && !use_stderr)
+		return "print";
+
 	return log_level_names[level];
 }
 
@@ -312,6 +314,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	char *newbuf;
 	int use_stderr = level & _LOG_STDERR;
 	int log_once = level & _LOG_ONCE;
+	int log_bypass_report = level & _LOG_BYPASS_REPORT;
 	int fatal_internal_error = 0;
 	size_t msglen;
 	const char *indent_spaces = "";
@@ -322,7 +325,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	struct dm_report *orig_report;
 	int logged_via_report = 0;
 
-	level &= ~(_LOG_STDERR|_LOG_ONCE);
+	level &= ~(_LOG_STDERR|_LOG_ONCE|_LOG_BYPASS_REPORT);
 
 	if (_abort_on_internal_errors_env_present < 0) {
 		if ((env_str = getenv("DM_ABORT_ON_INTERNAL_ERRORS"))) {
@@ -353,7 +356,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 
 	if (_lvm2_log_fn ||
 	    (_store_errmsg && (level <= _LOG_ERR)) ||
-	    (_log_report.report && (use_stderr || (level <=_LOG_ERR))) ||
+	    (_log_report.report && !log_bypass_report && (use_stderr || (level <=_LOG_WARN))) ||
 	    log_once) {
 		va_start(ap, format);
 		n = vsnprintf(message, sizeof(message), trformat, ap);
@@ -401,11 +404,10 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		}
 	}
 
-	if (_log_report.report && (use_stderr || (level <= _LOG_ERR))) {
+	if (_log_report.report && !log_bypass_report && (use_stderr || (level <= _LOG_WARN))) {
 		orig_report = _log_report.report;
 		_log_report.report = NULL;
-
-		if (!report_cmdlog(orig_report, _get_log_level_name(level),
+		if (!report_cmdlog(orig_report, _get_log_level_name(use_stderr, level),
 				   log_get_report_context_name(_log_report.context),
 				   log_get_report_object_type_name(_log_report.object_type),
 				   _log_report.object_name, _log_report.object_id,
diff --git a/lib/log/log.h b/lib/log/log.h
index 222a1ad..15d363e 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -44,6 +44,7 @@
 #define _LOG_STDERR 128 /* force things to go to stderr, even if loglevel
 			   would make them go to stdout */
 #define _LOG_ONCE 256 /* downgrade to NOTICE if this has been already logged */
+#define _LOG_BYPASS_REPORT 512 /* do not log through report even if report available */
 #define _LOG_DEBUG 7
 #define _LOG_INFO 6
 #define _LOG_NOTICE 5
@@ -93,6 +94,7 @@
 #define log_very_verbose(args...) log_info(args)
 #define log_verbose(args...) log_notice(args)
 #define log_print(args...) LOG_LINE(_LOG_WARN, args)
+#define log_print_bypass_report(args...) LOG_LINE(_LOG_WARN | _LOG_BYPASS_REPORT, args)
 #define log_print_unless_silent(args...) LOG_LINE(silent_mode() ? _LOG_NOTICE : _LOG_WARN, args)
 #define log_error(args...) log_err(args)
 #define log_error_suppress(s, args...) log_err_suppress(s, args)
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index d67d0bb..6ac936f 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -116,7 +116,7 @@ static void _default_log_line(int level,
 	static int _abort_on_internal_errors = -1;
 	FILE *out = (level & _LOG_STDERR) ? stderr : stdout;
 
-	level &= ~_LOG_STDERR;
+	level &= ~(_LOG_STDERR | _LOG_BYPASS_REPORT);
 
 	if (level <= _LOG_WARN || _verbose) {
 		if (level < _LOG_WARN)
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 485bbdf..3fa596e 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4105,7 +4105,7 @@ static int _report_headings(struct dm_report *rh)
 
 	/* print all headings */
 	heading = (char *) dm_pool_end_object(rh->mem);
-	log_print("%s", heading);
+	log_print_bypass_report("%s", heading);
 
 	dm_pool_free(rh->mem, (void *)heading);
 	dm_free(buf);
@@ -4422,7 +4422,7 @@ static int _output_as_rows(struct dm_report *rh)
 			log_error("dm_report: Failed to terminate row");
 			goto bad;
 		}
-		log_print("%s", (char *) dm_pool_end_object(rh->mem));
+		log_print_bypass_report("%s", (char *) dm_pool_end_object(rh->mem));
 	}
 
 	_destroy_rows(rh);
@@ -4510,7 +4510,7 @@ static int _output_as_columns(struct dm_report *rh)
 		}
 
 		line = (char *) dm_pool_end_object(rh->mem);
-		log_print("%*s", rh->group_item ? rh->group_item->group->indent + (int) strlen(line) : 0, line);
+		log_print_bypass_report("%*s", rh->group_item ? rh->group_item->group->indent + (int) strlen(line) : 0, line);
 		dm_list_del(&row->list);
 	}
 
@@ -4560,14 +4560,14 @@ static int _json_output_array_start(struct dm_pool *mem, struct report_group_ite
 	}
 
 	if (item->parent->store.finished_count > 0)
-		log_print("%*s", item->group->indent + (int) sizeof(JSON_SEPARATOR) - 1, JSON_SEPARATOR);
+		log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_SEPARATOR) - 1, JSON_SEPARATOR);
 
 	if (item->parent->parent && item->parent->data) {
-		log_print("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_START) - 1, JSON_OBJECT_START);
+		log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_START) - 1, JSON_OBJECT_START);
 		item->group->indent += JSON_INDENT_UNIT;
 	}
 
-	log_print("%*s", item->group->indent + (int) strlen(output), output);
+	log_print_bypass_report("%*s", item->group->indent + (int) strlen(output), output);
 	item->group->indent += JSON_INDENT_UNIT;
 
 	dm_pool_free(mem, output);
@@ -4616,9 +4616,9 @@ static int _print_basic_report_header(struct dm_report *rh)
 	memset(underline, '=', len);
 
 	if (rh->group_item->parent->store.finished_count > 0)
-		log_print("%s", "");
-	log_print("%s", report_name);
-	log_print("%s", underline);
+		log_print_bypass_report("%s", "");
+	log_print_bypass_report("%s", report_name);
+	log_print_bypass_report("%s", underline);
 
 	dm_pool_free(rh->mem, underline);
 	return 1;
@@ -4665,7 +4665,7 @@ static int _report_group_create_basic(struct dm_report_group *group)
 
 static int _report_group_create_json(struct dm_report_group *group)
 {
-	log_print(JSON_OBJECT_START);
+	log_print_bypass_report(JSON_OBJECT_START);
 	group->indent += JSON_INDENT_UNIT;
 	return 1;
 }
@@ -4742,7 +4742,7 @@ static int _report_group_push_single(struct report_group_item *item, void *data)
 static int _report_group_push_basic(struct report_group_item *item, const char *name)
 {
 	if (!item->report && !name && item->parent->store.finished_count > 0)
-		log_print("%s", "");
+		log_print_bypass_report("%s", "");
 
 	return 1;
 }
@@ -4769,8 +4769,8 @@ static int _report_group_push_json(struct report_group_item *item, const char *n
 				return 0;
 			}
 			if (item->parent->store.finished_count > 0)
-				log_print("%*s", item->group->indent + (int) sizeof(JSON_SEPARATOR) - 1, JSON_SEPARATOR);
-			log_print("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_START) - 1, JSON_OBJECT_START);
+				log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_SEPARATOR) - 1, JSON_SEPARATOR);
+			log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_START) - 1, JSON_OBJECT_START);
 			item->group->indent += JSON_INDENT_UNIT;
 		}
 
@@ -4848,11 +4848,11 @@ static int _report_group_pop_json(struct report_group_item *item)
 	if (item->output_done && item->needs_closing) {
 		if (item->data) {
 			item->group->indent -= JSON_INDENT_UNIT;
-			log_print("%*s", item->group->indent + (int) sizeof(JSON_ARRAY_END) - 1, JSON_ARRAY_END);
+			log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_ARRAY_END) - 1, JSON_ARRAY_END);
 		}
 		if (item->parent->data && item->parent->parent) {
 			item->group->indent -= JSON_INDENT_UNIT;
-			log_print("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_END) - 1, JSON_OBJECT_END);
+			log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_END) - 1, JSON_OBJECT_END);
 		}
 		item->needs_closing = 0;
 	}
@@ -4915,7 +4915,7 @@ static int _report_group_destroy_basic(void)
 
 static int _report_group_destroy_json(void)
 {
-	log_print(JSON_OBJECT_END);
+	log_print_bypass_report(JSON_OBJECT_END);
 	return 1;
 }
 



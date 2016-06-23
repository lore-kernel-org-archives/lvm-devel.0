From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 23 Jun 2016 12:47:46 +0000 (UTC)
Subject: master - libdm: log: remove log_print_bypass_report calls and register new print_log_libdm for libdm during lvm initialization instead
Message-ID: <20160623124746.EECB8607BF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=751163a74375cc3bfc9f338f1317f14a23798812
Commit:        751163a74375cc3bfc9f338f1317f14a23798812
Parent:        6eeb66e51d0a230e2b8a03e5c060d31d939fd52c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 23 13:55:39 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 23 14:45:52 2016 +0200

libdm: log: remove log_print_bypass_report calls and register new print_log_libdm for libdm during lvm initialization instead

This fixes commit f50d4011cdd3ef38c15b9dea05e73321592d93c2 which
introduced a problem when using older lvm2 code with newer libdm.
In this case, the old LVM didn't recognize new _LOG_BYPASS_REPORT flag
that libdm-report code used. This ended up with no output at all
from libdm where log_print_bypass_report was called because the
_LOG_BYPASS_REPORT was not masked properly in lvm2's print_log fn
which was called as callback function for logging.

With this patch, the lvm2 registers separate print_log_libdm logging
function for libdm instead. The print_log_libdm is exactly the same
as print_log (used throughout lvm2 code) but it checks whether we're
printing common line on output where "common" means not going to stderr,
not a warning and not an error and if we are, it adds the
_LOG_BYPASS_REPORT flag so the log_print goes directly to output, not
to any log report.

So this achieves the same goal as in f50d4011cdd3ef38c15b9dea05e73321592d93c2,
just doing it in a way that newer libdm is still compatible with older
lvm2 code (libdm-report is the only code using log_print).

Looking at the opposite mixture - older libdm with newer lvm2 code,
that won't be compilable because the new log report functionality
that is in lvm2 also requires new dm_report_group_* libdm functions
so we don't need to care here.
---
 lib/commands/toolcontext.c |    2 +-
 lib/log/log.c              |   19 +++++++++++++++++++
 lib/log/log.h              |    1 -
 lib/log/lvm-logging.h      |    4 ++++
 libdm/libdm-report.c       |   32 ++++++++++++++++----------------
 5 files changed, 40 insertions(+), 18 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index d263e13..d3bd5bc 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -365,7 +365,7 @@ static void _init_logging(struct cmd_context *cmd)
 	/* Tell device-mapper about our logging */
 #ifdef DEVMAPPER_SUPPORT
 	if (!dm_log_is_non_default())
-		dm_log_with_errno_init(print_log);
+		dm_log_with_errno_init(print_log_libdm);
 #endif
 	reset_log_duplicated();
 	reset_lvm_errno(1);
diff --git a/lib/log/log.c b/lib/log/log.c
index febd2e5..b3453dc 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -540,6 +540,25 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	va_end(ap);
 }
 
+void print_log_libdm(int level, const char *file, int line, int dm_errno_or_class,
+		     const char *format, ...)
+{
+	va_list ap;
+
+	/*
+	 * Bypass report if printing output from libdm and if we have
+	 * LOG_WARN level and it's not going to stderr (so we're
+	 * printing common message that is not an error/warning).
+	*/
+	if (!(level & _LOG_STDERR) &&
+	    ((level & ~(_LOG_STDERR|_LOG_ONCE|_LOG_BYPASS_REPORT)) == _LOG_WARN))
+		level |= _LOG_BYPASS_REPORT;
+
+	va_start(ap, format);
+	_vprint_log(level, file, line, dm_errno_or_class, format, ap);
+	va_end(ap);
+}
+
 log_report_t log_get_report_state(void)
 {
 	return _log_report;
diff --git a/lib/log/log.h b/lib/log/log.h
index 1bc9cbe..dac627e 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -94,7 +94,6 @@
 #define log_very_verbose(args...) log_info(args)
 #define log_verbose(args...) log_notice(args)
 #define log_print(args...) LOG_LINE(_LOG_WARN, args)
-#define log_print_bypass_report(args...) LOG_LINE(_LOG_WARN | _LOG_BYPASS_REPORT, args)
 #define log_print_unless_silent(args...) LOG_LINE(silent_mode() ? _LOG_NOTICE : _LOG_WARN, args)
 #define log_error(args...) log_err(args)
 #define log_error_suppress(s, args...) log_err_suppress(s, args)
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 59ed7ac..4101bc8 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -20,6 +20,10 @@ __attribute__ ((format(printf, 5, 6)))
 void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	       const char *format, ...);
 
+__attribute__ ((format(printf, 5, 6)))
+void print_log_libdm(int level, const char *file, int line, int dm_errno_or_class,
+		     const char *format, ...);
+
 #define LOG_LINE(l, x...) \
     print_log(l, __FILE__, __LINE__ , 0, ## x)
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 1326fdf..6bea34c 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4175,7 +4175,7 @@ static int _report_headings(struct dm_report *rh)
 
 	/* print all headings */
 	heading = (char *) dm_pool_end_object(rh->mem);
-	log_print_bypass_report("%s", heading);
+	log_print("%s", heading);
 
 	dm_pool_free(rh->mem, (void *)heading);
 	dm_free(buf);
@@ -4490,7 +4490,7 @@ static int _output_as_rows(struct dm_report *rh)
 			log_error("dm_report: Failed to terminate row");
 			goto bad;
 		}
-		log_print_bypass_report("%s", (char *) dm_pool_end_object(rh->mem));
+		log_print("%s", (char *) dm_pool_end_object(rh->mem));
 	}
 
 	_destroy_rows(rh);
@@ -4583,7 +4583,7 @@ static int _output_as_columns(struct dm_report *rh)
 		}
 
 		line = (char *) dm_pool_end_object(rh->mem);
-		log_print_bypass_report("%*s", rh->group_item ? rh->group_item->group->indent + (int) strlen(line) : 0, line);
+		log_print("%*s", rh->group_item ? rh->group_item->group->indent + (int) strlen(line) : 0, line);
 		if (!(rh->flags & DM_REPORT_OUTPUT_MULTIPLE_TIMES))
 			dm_list_del(&row->list);
 	}
@@ -4635,14 +4635,14 @@ static int _json_output_array_start(struct dm_pool *mem, struct report_group_ite
 	}
 
 	if (item->parent->store.finished_count > 0)
-		log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_SEPARATOR) - 1, JSON_SEPARATOR);
+		log_print("%*s", item->group->indent + (int) sizeof(JSON_SEPARATOR) - 1, JSON_SEPARATOR);
 
 	if (item->parent->parent && item->parent->data) {
-		log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_START) - 1, JSON_OBJECT_START);
+		log_print("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_START) - 1, JSON_OBJECT_START);
 		item->group->indent += JSON_INDENT_UNIT;
 	}
 
-	log_print_bypass_report("%*s", item->group->indent + (int) strlen(output), output);
+	log_print("%*s", item->group->indent + (int) strlen(output), output);
 	item->group->indent += JSON_INDENT_UNIT;
 
 	dm_pool_free(mem, output);
@@ -4691,9 +4691,9 @@ static int _print_basic_report_header(struct dm_report *rh)
 	memset(underline, '=', len);
 
 	if (rh->group_item->parent->store.finished_count > 0)
-		log_print_bypass_report("%s", "");
-	log_print_bypass_report("%s", report_name);
-	log_print_bypass_report("%s", underline);
+		log_print("%s", "");
+	log_print("%s", report_name);
+	log_print("%s", underline);
 
 	dm_pool_free(rh->mem, underline);
 	return 1;
@@ -4759,7 +4759,7 @@ static int _report_group_create_basic(struct dm_report_group *group)
 
 static int _report_group_create_json(struct dm_report_group *group)
 {
-	log_print_bypass_report(JSON_OBJECT_START);
+	log_print(JSON_OBJECT_START);
 	group->indent += JSON_INDENT_UNIT;
 	return 1;
 }
@@ -4840,7 +4840,7 @@ static int _report_group_push_basic(struct report_group_item *item, const char *
 			item->report->flags &= ~(DM_REPORT_OUTPUT_MULTIPLE_TIMES);
 	} else {
 		if (!name && item->parent->store.finished_count > 0)
-			log_print_bypass_report("%s", "");
+			log_print("%s", "");
 	}
 
 	return 1;
@@ -4868,8 +4868,8 @@ static int _report_group_push_json(struct report_group_item *item, const char *n
 				return 0;
 			}
 			if (item->parent->store.finished_count > 0)
-				log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_SEPARATOR) - 1, JSON_SEPARATOR);
-			log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_START) - 1, JSON_OBJECT_START);
+				log_print("%*s", item->group->indent + (int) sizeof(JSON_SEPARATOR) - 1, JSON_SEPARATOR);
+			log_print("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_START) - 1, JSON_OBJECT_START);
 			item->group->indent += JSON_INDENT_UNIT;
 		}
 
@@ -4948,11 +4948,11 @@ static int _report_group_pop_json(struct report_group_item *item)
 	if (item->output_done && item->needs_closing) {
 		if (item->data) {
 			item->group->indent -= JSON_INDENT_UNIT;
-			log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_ARRAY_END) - 1, JSON_ARRAY_END);
+			log_print("%*s", item->group->indent + (int) sizeof(JSON_ARRAY_END) - 1, JSON_ARRAY_END);
 		}
 		if (item->parent->data && item->parent->parent) {
 			item->group->indent -= JSON_INDENT_UNIT;
-			log_print_bypass_report("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_END) - 1, JSON_OBJECT_END);
+			log_print("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_END) - 1, JSON_OBJECT_END);
 		}
 		item->needs_closing = 0;
 	}
@@ -5015,7 +5015,7 @@ static int _report_group_destroy_basic(void)
 
 static int _report_group_destroy_json(void)
 {
-	log_print_bypass_report(JSON_OBJECT_END);
+	log_print(JSON_OBJECT_END);
 	return 1;
 }
 



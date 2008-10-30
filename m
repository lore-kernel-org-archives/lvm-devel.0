From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Oct 2008 17:27:31 -0000
Subject: LVM2 tools/tools.h lib/misc/lib.h lib/log/log. ...
Message-ID: <20081030172731.3654.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-30 17:27:28

Modified files:
	tools          : tools.h 
	lib/misc       : lib.h 
	lib/log        : log.c log.h 
	include        : .symlinks 
	lib            : Makefile.in 
	.              : WHATS_NEW 
Added files:
	lib/log        : lvm-logging.h 

Log message:
	Split out lvm-logging.h from log.h.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lib.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/lvm-logging.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.984&r2=1.985

--- LVM2/tools/tools.h	2008/04/02 21:23:39	1.61
+++ LVM2/tools/tools.h	2008/10/30 17:27:25	1.62
@@ -24,7 +24,7 @@
 #include <libdevmapper.h>
 
 #include "lvm-types.h"
-#include "log.h"
+#include "lvm-logging.h"
 #include "activate.h"
 #include "archiver.h"
 #include "lvmcache.h"
--- LVM2/lib/misc/lib.h	2007/08/20 20:55:27	1.13
+++ LVM2/lib/misc/lib.h	2008/10/30 17:27:27	1.14
@@ -25,8 +25,8 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-#include "log.h"
 #include "intl.h"
+#include "lvm-logging.h"
 #include "lvm-types.h"
 #include "lvm-wrappers.h"
 #include "util.h"
/cvs/lvm2/LVM2/lib/log/lvm-logging.h,v  -->  standard output
revision 1.1
--- LVM2/lib/log/lvm-logging.h
+++ -	2008-10-30 17:27:30.148957000 +0000
@@ -0,0 +1,55 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_LOGGING_H
+#define _LVM_LOGGING_H
+
+#include "lvm-globals.h"
+
+void print_log(int level, const char *file, int line, const char *format, ...)
+    __attribute__ ((format(printf, 4, 5)));
+
+#define plog(l, x...) print_log(l, __FILE__, __LINE__ , ## x)
+
+#include "log.h"
+
+typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
+			       const char *message);
+
+void init_log_fn(lvm2_log_fn_t log_fn);
+
+void init_indent(int indent);
+void init_msg_prefix(const char *prefix);
+
+void init_log_file(const char *log_file, int append);
+void init_log_direct(const char *log_file, int append);
+void init_log_while_suspended(int log_while_suspended);
+
+void fin_log(void);
+void release_log_memory(void);
+
+void init_syslog(int facility);
+void fin_syslog(void);
+
+int error_message_produced(void);
+
+/* Suppress messages to stdout/stderr (1) or everywhere (2) */
+/* Returns previous setting */
+int log_suppress(int suppress);
+
+/* Suppress messages to syslog */
+void syslog_suppress(int suppress);
+
+#endif
--- LVM2/lib/log/log.c	2008/09/19 06:41:59	1.48
+++ LVM2/lib/log/log.c	2008/10/30 17:27:27	1.49
@@ -27,30 +27,14 @@
 static struct device _log_dev;
 static struct str_list _log_dev_alias;
 
-static int _verbose_level = VERBOSE_BASE_LEVEL;
-static int _test = 0;
-static int _md_filtering = 0;
-static int _pvmove = 0;
-static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
-static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
-static int _debug_level = 0;
 static int _syslog = 0;
 static int _log_to_file = 0;
 static int _log_direct = 0;
 static int _log_while_suspended = 0;
 static int _indent = 1;
-static int _log_cmd_name = 0;
 static int _log_suppress = 0;
-static int _ignorelockingfailure = 0;
-static int _lockingfailed = 0;
-static int _security_level = SECURITY_LEVEL;
-static char _cmd_name[30] = "";
 static char _msg_prefix[30] = "  ";
 static int _already_logging = 0;
-static int _mirror_in_sync = 0;
-static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
-static int _ignore_suspended_devices = 0;
-static int _error_message_produced = 0;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
@@ -141,87 +125,6 @@
 	_syslog = 0;
 }
 
-void init_verbose(int level)
-{
-	_verbose_level = level;
-}
-
-void init_test(int level)
-{
-	if (!_test && level)
-		log_print("Test mode: Metadata will NOT be updated.");
-	_test = level;
-}
-
-void init_md_filtering(int level)
-{
-	_md_filtering = level;
-}
-
-void init_pvmove(int level)
-{
-	_pvmove = level;
-}
-
-void init_full_scan_done(int level)
-{
-	_full_scan_done = level;
-}
-
-void init_trust_cache(int trustcache)
-{
-	_trust_cache = trustcache;
-}
-
-void init_ignorelockingfailure(int level)
-{
-	_ignorelockingfailure = level;
-}
-
-void init_lockingfailed(int level)
-{
-	_lockingfailed = level;
-}
-
-void init_security_level(int level)
-{
-	_security_level = level;
-}
-
-void init_mirror_in_sync(int in_sync)
-{
-	_mirror_in_sync = in_sync;
-}
-
-void init_dmeventd_monitor(int reg)
-{
-	_dmeventd_monitor = reg;
-}
-
-void init_ignore_suspended_devices(int ignore)
-{
-	_ignore_suspended_devices = ignore;
-}
-
-void init_cmd_name(int status)
-{
-	_log_cmd_name = status;
-}
-
-void set_cmd_name(const char *cmd)
-{
-	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
-	_cmd_name[sizeof(_cmd_name) - 1] = '\0';
-}
-
-static const char *_command_name()
-{
-	if (!_log_cmd_name)
-		return "";
-
-	return _cmd_name;
-}
-
 void init_msg_prefix(const char *prefix)
 {
 	strncpy(_msg_prefix, prefix, sizeof(_msg_prefix));
@@ -233,81 +136,6 @@
 	_indent = indent;
 }
 
-void init_error_message_produced(int value)
-{
-	_error_message_produced = value;
-}
-
-int error_message_produced(void)
-{
-	return _error_message_produced;
-}
-
-int test_mode()
-{
-	return _test;
-}
-
-int md_filtering()
-{
-	return _md_filtering;
-}
-
-int pvmove_mode()
-{
-	return _pvmove;
-}
-
-int full_scan_done()
-{
-	return _full_scan_done;
-}
-
-int trust_cache()
-{
-	return _trust_cache;
-}
-
-int lockingfailed()
-{
-	return _lockingfailed;
-}
-
-int ignorelockingfailure()
-{
-	return _ignorelockingfailure;
-}
-
-int security_level()
-{
-	return _security_level;
-}
-
-int mirror_in_sync(void)
-{
-	return _mirror_in_sync;
-}
-
-int dmeventd_monitor_mode(void)
-{
-	return _dmeventd_monitor;
-}
-
-int ignore_suspended_devices(void)
-{
-	return _ignore_suspended_devices;
-}
-
-void init_debug(int level)
-{
-	_debug_level = level;
-}
-
-int debug_level()
-{
-	return _debug_level;
-}
-
 void print_log(int level, const char *file, int line, const char *format, ...)
 {
 	va_list ap;
@@ -323,7 +151,7 @@
 		return;
 
 	if (level <= _LOG_ERR)
-		_error_message_produced = 1;
+		init_error_message_produced(1);
 
 	trformat = _(format);
 
@@ -348,7 +176,7 @@
 
       log_it:
 	if (!_log_suppress) {
-		if (_verbose_level > _LOG_DEBUG)
+		if (verbose_level() > _LOG_DEBUG)
 			dm_snprintf(locn, sizeof(locn), "#%s:%d ",
 				     file, line);
 		else
@@ -358,10 +186,10 @@
 		switch (level) {
 		case _LOG_DEBUG:
 			if (!strcmp("<backtrace>", format) &&
-			    _verbose_level <= _LOG_DEBUG)
+			    verbose_level() <= _LOG_DEBUG)
 				break;
-			if (_verbose_level >= _LOG_DEBUG) {
-				fprintf(stderr, "%s%s%s", locn, _command_name(),
+			if (verbose_level() >= _LOG_DEBUG) {
+				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				if (_indent)
 					fprintf(stderr, "      ");
@@ -371,8 +199,8 @@
 			break;
 
 		case _LOG_INFO:
-			if (_verbose_level >= _LOG_INFO) {
-				fprintf(stderr, "%s%s%s", locn, _command_name(),
+			if (verbose_level() >= _LOG_INFO) {
+				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				if (_indent)
 					fprintf(stderr, "    ");
@@ -381,8 +209,8 @@
 			}
 			break;
 		case _LOG_NOTICE:
-			if (_verbose_level >= _LOG_NOTICE) {
-				fprintf(stderr, "%s%s%s", locn, _command_name(),
+			if (verbose_level() >= _LOG_NOTICE) {
+				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				if (_indent)
 					fprintf(stderr, "  ");
@@ -391,16 +219,16 @@
 			}
 			break;
 		case _LOG_WARN:
-			if (_verbose_level >= _LOG_WARN) {
+			if (verbose_level() >= _LOG_WARN) {
 				fprintf(use_stderr ? stderr : stdout, "%s%s",
-					_command_name(), _msg_prefix);
+					log_command_name(), _msg_prefix);
 				vfprintf(use_stderr ? stderr : stdout, trformat, ap);
 				fputc('\n', use_stderr ? stderr : stdout);
 			}
 			break;
 		case _LOG_ERR:
-			if (_verbose_level >= _LOG_ERR) {
-				fprintf(stderr, "%s%s%s", locn, _command_name(),
+			if (verbose_level() >= _LOG_ERR) {
+				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				vfprintf(stderr, trformat, ap);
 				fputc('\n', stderr);
@@ -408,8 +236,8 @@
 			break;
 		case _LOG_FATAL:
 		default:
-			if (_verbose_level >= _LOG_FATAL) {
-				fprintf(stderr, "%s%s%s", locn, _command_name(),
+			if (verbose_level() >= _LOG_FATAL) {
+				fprintf(stderr, "%s%s%s", locn, log_command_name(),
 					_msg_prefix);
 				vfprintf(stderr, trformat, ap);
 				fputc('\n', stderr);
@@ -419,11 +247,11 @@
 		va_end(ap);
 	}
 
-	if (level > _debug_level)
+	if (level > debug_level())
 		return;
 
 	if (_log_to_file && (_log_while_suspended || !memlock())) {
-		fprintf(_log_file, "%s:%d %s%s", file, line, _command_name(),
+		fprintf(_log_file, "%s:%d %s%s", file, line, log_command_name(),
 			_msg_prefix);
 
 		va_start(ap, format);
@@ -446,7 +274,7 @@
 		memset(&buf, ' ', sizeof(buf));
 		bufused = 0;
 		if ((n = dm_snprintf(buf, sizeof(buf) - bufused - 1,
-				      "%s:%d %s%s", file, line, _command_name(),
+				      "%s:%d %s%s", file, line, log_command_name(),
 				      _msg_prefix)) == -1)
 			goto done;
 
--- LVM2/lib/log/log.h	2008/09/19 06:41:59	1.42
+++ LVM2/lib/log/log.h	2008/10/30 17:27:27	1.43
@@ -50,71 +50,6 @@
 #define _LOG_ERR 3
 #define _LOG_FATAL 2
 
-#define VERBOSE_BASE_LEVEL _LOG_WARN
-#define SECURITY_LEVEL 0
-
-void init_log_file(const char *log_file, int append);
-void init_log_direct(const char *log_file, int append);
-void init_log_while_suspended(int log_while_suspended);
-void fin_log(void);
-void release_log_memory(void);
-
-void init_syslog(int facility);
-void fin_syslog(void);
-
-void init_verbose(int level);
-void init_test(int level);
-void init_md_filtering(int level);
-void init_pvmove(int level);
-void init_full_scan_done(int level);
-void init_trust_cache(int trustcache);
-void init_debug(int level);
-void init_cmd_name(int status);
-void init_msg_prefix(const char *prefix);
-void init_indent(int indent);
-void init_ignorelockingfailure(int level);
-void init_lockingfailed(int level);
-void init_security_level(int level);
-void init_mirror_in_sync(int in_sync);
-void init_dmeventd_monitor(int reg);
-void init_ignore_suspended_devices(int ignore);
-void init_error_message_produced(int error_message_produced);
-
-void set_cmd_name(const char *cmd_name);
-
-int test_mode(void);
-int md_filtering(void);
-int pvmove_mode(void);
-int full_scan_done(void);
-int trust_cache(void);
-int debug_level(void);
-int ignorelockingfailure(void);
-int lockingfailed(void);
-int security_level(void);
-int mirror_in_sync(void);
-int ignore_suspended_devices(void);
-int error_message_produced(void);
-
-#define DMEVENTD_MONITOR_IGNORE -1
-int dmeventd_monitor_mode(void);
-
-/* Suppress messages to stdout/stderr (1) or everywhere (2) */
-/* Returns previous setting */
-int log_suppress(int suppress);
-
-/* Suppress messages to syslog */
-void syslog_suppress(int suppress);
-
-typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
-			       const char *message);
-
-void init_log_fn(lvm2_log_fn_t log_fn);
-
-void print_log(int level, const char *file, int line, const char *format, ...)
-    __attribute__ ((format(printf, 4, 5)));
-
-#define plog(l, x...) print_log(l, __FILE__, __LINE__ , ## x)
-
 #define log_debug(x...) plog(_LOG_DEBUG, x)
 #define log_info(x...) plog(_LOG_INFO, x)
 #define log_notice(x...) plog(_LOG_NOTICE, x)
@@ -123,13 +58,12 @@
 #define log_fatal(x...) plog(_LOG_FATAL, x)
 
 #define stack log_debug("<backtrace>")	/* Backtrace on error */
-
-#define log_error(args...) log_err(args)
-#define log_print(args...) plog(_LOG_WARN, args)
-#define log_verbose(args...) log_notice(args)
 #define log_very_verbose(args...) log_info(args)
+#define log_verbose(args...) log_notice(args)
+#define log_print(args...) plog(_LOG_WARN, args)
+#define log_error(args...) log_err(args)
 
-/* Two System call equivalents */
+/* System call equivalents */
 #define log_sys_error(x, y) \
 		log_err("%s: %s failed: %s", y, x, strerror(errno))
 #define log_sys_very_verbose(x, y) \
--- LVM2/include/.symlinks	2008/10/30 15:31:33	1.48
+++ LVM2/include/.symlinks	2008/10/30 17:27:28	1.49
@@ -28,6 +28,7 @@
 ../lib/label/label.h
 ../lib/locking/locking.h
 ../lib/log/log.h
+../lib/log/lvm-logging.h
 ../lib/metadata/lv_alloc.h
 ../lib/metadata/metadata.h
 ../lib/metadata/metadata-exported.h
@@ -43,6 +44,7 @@
 ../lib/misc/lib.h
 ../lib/misc/lvm-exec.h
 ../lib/misc/lvm-file.h
+../lib/misc/lvm-globals.h
 ../lib/misc/lvm-string.h
 ../lib/misc/lvm-wrappers.h
 ../lib/misc/sharedlib.h
--- LVM2/lib/Makefile.in	2008/06/25 16:52:26	1.85
+++ LVM2/lib/Makefile.in	2008/10/30 17:27:28	1.86
@@ -78,6 +78,7 @@
 	misc/crc.c \
 	misc/lvm-exec.c \
 	misc/lvm-file.c \
+	misc/lvm-globals.c \
 	misc/lvm-string.c \
 	misc/lvm-wrappers.c \
 	misc/timestamp.c \
--- LVM2/WHATS_NEW	2008/10/30 15:31:33	1.984
+++ LVM2/WHATS_NEW	2008/10/30 17:27:28	1.985
@@ -1,5 +1,6 @@
 Version 2.02.43 -
 ===================================
+  Split out lvm-logging.h from log.h.
   Add libdm subdirectory for libdevmapper files.
 
 Version 2.02.42 - 26th October 2008



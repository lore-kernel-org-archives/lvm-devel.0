From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2009 17:17:13 -0000
Subject: LVM2 doc/example.conf lib/commands/toolcontext ...
Message-ID: <20091130171713.32649.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-30 17:17:12

Modified files:
	doc            : example.conf 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	lib/log        : log.c lvm-logging.h 
	test           : test-utils.sh 

Log message:
	Optionally abort on internal errors (and leverage this option in the
	testsuite). (This is showing a problem in the pvmove test for me, so I expect
	the tests to start failing -- this needs to be fixed separately though.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/lvm-logging.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/doc/example.conf	2009/10/05 12:44:21	1.51
+++ LVM2/doc/example.conf	2009/11/30 17:17:11	1.52
@@ -316,6 +316,10 @@
 
     # The external locking library to load if locking_type is set to 2.
     #   locking_library = "liblvm2clusterlock.so"
+
+    # Treat any internal errors as fatal errors, aborting the process that
+    # encountered the internal error. Please only enable for debugging.
+    abort_on_internal_errors = 0
 }
 
 activation {
--- LVM2/lib/commands/toolcontext.c	2009/11/24 16:11:38	1.88
+++ LVM2/lib/commands/toolcontext.c	2009/11/30 17:17:11	1.89
@@ -147,7 +147,9 @@
 
 	/* Log message formatting */
 	init_indent(find_config_tree_int(cmd, "log/indent",
-				    DEFAULT_INDENT));
+					 DEFAULT_INDENT));
+	init_abort_on_internal_errors(find_config_tree_int(cmd, "global/abort_on_internal_errors",
+							   DEFAULT_ABORT_ON_INTERNAL_ERRORS));
 
 	cmd->default_settings.msg_prefix = find_config_tree_str(cmd,
 							   "log/prefix",
--- LVM2/lib/config/defaults.h	2009/11/27 14:35:39	1.54
+++ LVM2/lib/config/defaults.h	2009/11/30 17:17:12	1.55
@@ -85,6 +85,7 @@
 #define DEFAULT_VERBOSE 0
 #define DEFAULT_LOGLEVEL 0
 #define DEFAULT_INDENT 1
+#define DEFAULT_ABORT_ON_INTERNAL_ERRORS 0
 #define DEFAULT_UNITS "h"
 #define DEFAULT_SUFFIX 1
 #define DEFAULT_HOSTTAGS 0
--- LVM2/lib/log/log.c	2009/07/16 13:13:33	1.52
+++ LVM2/lib/log/log.c	2009/11/30 17:17:12	1.53
@@ -19,6 +19,7 @@
 #include "lvm-string.h"
 #include "lvm-file.h"
 #include "defaults.h"
+#include "config.h"
 
 #include <stdarg.h>
 #include <syslog.h>
@@ -35,6 +36,7 @@
 static int _log_suppress = 0;
 static char _msg_prefix[30] = "  ";
 static int _already_logging = 0;
+static int _abort_on_internal_errors = 0;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
@@ -140,6 +142,11 @@
 	_indent = indent;
 }
 
+void init_abort_on_internal_errors(int fatal)
+{
+	_abort_on_internal_errors = fatal;
+}
+
 void reset_lvm_errno(int store_errmsg)
 {
 	_lvm_errno = 0;
@@ -172,9 +179,14 @@
 	const char *trformat;		/* Translated format string */
 	char *newbuf;
 	int use_stderr = level & _LOG_STDERR;
+	int internal_error = 0;
 
 	level &= ~_LOG_STDERR;
 
+	if (!strncmp(format, "Internal error:",
+		     strlen("Internal error:")))
+		internal_error = 1;
+
 	if (_log_suppress == 2)
 		return;
 
@@ -291,6 +303,9 @@
 		va_end(ap);
 	}
 
+	if (internal_error && _abort_on_internal_errors)
+		abort();
+
 	if (level > debug_level())
 		return;
 
--- LVM2/lib/log/lvm-logging.h	2009/07/16 03:07:45	1.7
+++ LVM2/lib/log/lvm-logging.h	2009/11/30 17:17:12	1.8
@@ -39,6 +39,7 @@
 void init_log_file(const char *log_file, int append);
 void init_log_direct(const char *log_file, int append);
 void init_log_while_suspended(int log_while_suspended);
+void init_abort_on_internal_errors(int fatal);
 
 void fin_log(void);
 void release_log_memory(void);
--- LVM2/test/test-utils.sh	2009/08/02 21:45:45	1.14
+++ LVM2/test/test-utils.sh	2009/11/30 17:17:12	1.15
@@ -199,8 +199,9 @@
     archive = 0
   }
   global {
+    abort_on_internal_errors = 1
     library_dir = "$G_root_/lib"
-     locking_dir = "$G_root_/var/lock/lvm"
+    locking_dir = "$G_root_/var/lock/lvm"
   }
 EOF
 }



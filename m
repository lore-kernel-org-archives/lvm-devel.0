From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jul 2009 00:52:13 -0000
Subject: LVM2 ./WHATS_NEW lib/log/log.h lib/log/lvm-log ...
Message-ID: <20090716005213.1979.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-16 00:52:10

Modified files:
	.              : WHATS_NEW 
	lib/log        : log.h lvm-logging.h 
	libdm/misc     : dm-logging.h 
	libdm/mm       : dbg_malloc.c 

Log message:
	Add log_errno to set a specific errno and replace log_error in due course.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1191&r2=1.1192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/lvm-logging.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-logging.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2009/07/16 00:36:59	1.1191
+++ LVM2/WHATS_NEW	2009/07/16 00:52:06	1.1192
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Add log_errno to set a specific errno and replace log_error in due course.
   Add lvm_errno and lvm_errmsg to liblvm to obtain failure information.
   Change create_toolcontext to still return an object if it fails part-way.
   Add EUNCLASSIFIED (-1) as the default LVM errno code.
--- LVM2/lib/log/log.h	2009/07/10 09:59:37	1.44
+++ LVM2/lib/log/log.h	2009/07/16 00:52:09	1.45
@@ -16,6 +16,8 @@
 #ifndef _LVM_LOG_H
 #define _LVM_LOG_H
 
+#include <errno.h>
+
 /*
  * printf()-style macros to use for messages:
  *
@@ -62,6 +64,7 @@
 #define log_verbose(args...) log_notice(args)
 #define log_print(args...) LOG_LINE(_LOG_WARN, args)
 #define log_error(args...) log_err(args)
+#define log_errno(args...) LOG_LINE_WITH_ERRNO(_LOG_ERR, args)
 
 /* System call equivalents */
 #define log_sys_error(x, y) \
--- LVM2/lib/log/lvm-logging.h	2009/07/16 00:36:59	1.5
+++ LVM2/lib/log/lvm-logging.h	2009/07/16 00:52:09	1.6
@@ -16,12 +16,17 @@
 #ifndef _LVM_LOGGING_H
 #define _LVM_LOGGING_H
 
+#define EUNCLASSIFIED -1	/* Generic error code */
+
 void print_log(int level, const char *file, int line, int dm_errno,
 	       const char *format, ...)
     __attribute__ ((format(printf, 5, 6)));
 
-#define EUNCLASSIFIED -1	/* Generic error code */
-#define LOG_LINE(l, x...) print_log(l, __FILE__, __LINE__ , EUNCLASSIFIED, ## x)
+#define LOG_LINE(l, x...) \
+    print_log(l, __FILE__, __LINE__ , EUNCLASSIFIED, ## x)
+
+#define LOG_LINE_WITH_ERRNO(l, e, x...) \
+    print_log(l, __FILE__, __LINE__ , e, ## x)
 
 #include "log.h"
 
--- LVM2/libdm/misc/dm-logging.h	2009/07/15 14:18:41	1.3
+++ LVM2/libdm/misc/dm-logging.h	2009/07/16 00:52:09	1.4
@@ -21,15 +21,16 @@
 extern dm_log_fn dm_log;
 extern dm_log_with_errno_fn dm_log_with_errno;
 
-#define LOG_MESG(l, f, ln, x...) \
+#define LOG_MESG(l, f, ln, e, x...) \
 	do { \
 		if (dm_log_is_non_default()) \
 			dm_log(l, f, ln, ## x); \
 		else \
-			dm_log_with_errno(l, f, ln, 0, ## x); \
+			dm_log_with_errno(l, f, ln, e, ## x); \
 	} while (0)
 
-#define LOG_LINE(l, x...) LOG_MESG(l, __FILE__, __LINE__, ## x)
+#define LOG_LINE(l, x...) LOG_MESG(l, __FILE__, __LINE__, 0, ## x)
+#define LOG_LINE_WITH_ERRNO(l, e, x...) LOG_MESG(l, __FILE__, __LINE__, e, ## x)
 
 #include "log.h"
 
--- LVM2/libdm/mm/dbg_malloc.c	2009/07/15 14:18:41	1.15
+++ LVM2/libdm/mm/dbg_malloc.c	2009/07/16 00:52:10	1.16
@@ -205,7 +205,7 @@
 		}
 		str[sizeof(str) - 1] = '\0';
 
-		LOG_MESG(_LOG_INFO, mb->file, mb->line,
+		LOG_MESG(_LOG_INFO, mb->file, mb->line, 0,
 			 "block %d at %p, size %" PRIsize_t "\t [%s]",
 			 mb->id, mb->magic, mb->length, str);
 		tot += mb->length;



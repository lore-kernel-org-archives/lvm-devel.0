From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jul 2009 14:18:42 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/misc/dm-logging.h li ...
Message-ID: <20090715141842.15384.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-15 14:18:42

Modified files:
	.              : WHATS_NEW_DM 
	libdm/misc     : dm-logging.h 
	libdm/mm       : dbg_malloc.c 

Log message:
	New LOG_MESG macro to fix file/line number logging for memory leaks after
	LOG_LINENO macro was added.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.286&r2=1.287
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-logging.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW_DM	2009/07/15 13:20:07	1.286
+++ LVM2/WHATS_NEW_DM	2009/07/15 14:18:38	1.287
@@ -1,6 +1,7 @@
 Version 1.02.34 - 15th July 2009
 ================================
-  Rename plog macro to LOG_LINE and use in dm_dump_memory_debug.
+  Use _exit() not exit() after forking to avoid flushing libc buffers twice.
+  Rename plog macro to LOG_LINE & add LOG_MESG variant for dm_dump_memory_debug.
   Change plog to use dm_log_with_errno unless deprecated dm_log_init was used.
   Add dm_log_with_errno and dm_log_with_errno_init, deprecating the old fns.
   Fix whitespace in linear target line to fix identical table line detection.
--- LVM2/libdm/misc/dm-logging.h	2009/07/10 09:59:38	1.2
+++ LVM2/libdm/misc/dm-logging.h	2009/07/15 14:18:41	1.3
@@ -21,14 +21,16 @@
 extern dm_log_fn dm_log;
 extern dm_log_with_errno_fn dm_log_with_errno;
 
-#define LOG_LINE(l, x...) \
+#define LOG_MESG(l, f, ln, x...) \
 	do { \
 		if (dm_log_is_non_default()) \
-			dm_log(l, __FILE__, __LINE__, ## x); \
+			dm_log(l, f, ln, ## x); \
 		else \
-			dm_log_with_errno(l, __FILE__, __LINE__, 0, ## x); \
+			dm_log_with_errno(l, f, ln, 0, ## x); \
 	} while (0)
 
+#define LOG_LINE(l, x...) LOG_MESG(l, __FILE__, __LINE__, ## x)
+
 #include "log.h"
 
 #endif
--- LVM2/libdm/mm/dbg_malloc.c	2009/07/10 09:59:38	1.14
+++ LVM2/libdm/mm/dbg_malloc.c	2009/07/15 14:18:41	1.15
@@ -205,7 +205,7 @@
 		}
 		str[sizeof(str) - 1] = '\0';
 
-		LOG_LINE(_LOG_INFO, mb->file, mb->line,
+		LOG_MESG(_LOG_INFO, mb->file, mb->line,
 			 "block %d at %p, size %" PRIsize_t "\t [%s]",
 			 mb->id, mb->magic, mb->length, str);
 		tot += mb->length;



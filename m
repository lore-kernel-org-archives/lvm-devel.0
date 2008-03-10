From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Mar 2008 18:51:27 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/forma ...
Message-ID: <20080310185127.31430.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-03-10 18:51:27

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 
	lib/format_text: text_export.h 

Log message:
	Use return_0 in a couple more places.
	Correct a function name typo in _line_append error message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.800&r2=1.801
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_export.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2008/03/06 08:41:05	1.800
+++ LVM2/WHATS_NEW	2008/03/10 18:51:27	1.801
@@ -1,5 +1,7 @@
 Version 2.02.34 -
 ===================================
+  Use return_0 in a couple more places.
+  Correct a function name typo in _line_append error message.
   Include limits.h in clvmd so it compiles with newer headers.
   Add VirtIO disks (vd) to filters.
   Fix resetting of MIRROR_IMAGE and VISIBLE_LV after removal of LV. (2.02.30)
--- LVM2/lib/config/config.c	2008/01/30 13:19:44	1.66
+++ LVM2/lib/config/config.c	2008/03/10 18:51:27	1.67
@@ -372,7 +372,7 @@
 	va_end(ap);
 
 	if (!dm_pool_grow_object(outline->mem, &buf[0], strlen(buf))) {
-		log_error("dm_pool_grew_object failed for config line");
+		log_error("dm_pool_grow_object failed for config line");
 		return 0;
 	}
 
--- LVM2/lib/format_text/text_export.h	2007/08/20 20:55:26	1.3
+++ LVM2/lib/format_text/text_export.h	2008/03/10 18:51:27	1.4
@@ -16,8 +16,8 @@
 #ifndef _LVM_TEXT_EXPORT_H
 #define _LVM_TEXT_EXPORT_H
 
-#define outf(args...) do {if (!out_text(args)) {stack; return 0;}} while (0)
-#define outnl(f) do {if (!f->nl(f)) {stack; return 0;}} while (0)
+#define outf(args...) do {if (!out_text(args)) return_0;} while (0)
+#define outnl(f) do {if (!f->nl(f)) return_0;} while (0)
 
 struct formatter;
 struct lv_segment;



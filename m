From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jan 2010 14:45:30 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/export.c lib/ ...
Message-ID: <20100107144530.28882.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-07 14:45:29

Modified files:
	.              : WHATS_NEW 
	lib/format_text: export.c text_export.h 

Log message:
	Export function out_text_with_comment() and add outfc() macro that checks
	for error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1369&r2=1.1370
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_export.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2010/01/07 14:40:46	1.1369
+++ LVM2/WHATS_NEW	2010/01/07 14:45:28	1.1370
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Add macro outfc() and export out_text_with_comment().
   Add macros outsize() and outhint().
   Use offsetof() macro for FIELD() macro in lib/report/report.c.
   Rename mirror_device_fault_policy to mirror_image_fault policy.
--- LVM2/lib/format_text/export.c	2010/01/07 14:40:46	1.74
+++ LVM2/lib/format_text/export.c	2010/01/07 14:45:28	1.75
@@ -286,9 +286,9 @@
 }
 
 /*
- * Appends a comment
+ * The normal output function with comment
  */
-static int _out_comment(struct formatter *f, const char *comment, const char *fmt, ...)
+int out_text_with_comment(struct formatter *f, const char *comment, const char *fmt, ...)
 {
 	va_list ap;
 	int r;
@@ -579,7 +579,7 @@
 
 	switch (lv->read_ahead) {
 	case DM_READ_AHEAD_NONE:
-		_out_comment(f, "# None", "read_ahead = -1");
+		outfc(f, "# None", "read_ahead = -1");
 		break;
 	case DM_READ_AHEAD_AUTO:
 		/* No output - use default */
--- LVM2/lib/format_text/text_export.h	2010/01/07 14:40:46	1.7
+++ LVM2/lib/format_text/text_export.h	2010/01/07 14:45:28	1.8
@@ -18,6 +18,7 @@
 
 #define outsize(args...) do {if (!out_size(args)) return_0;} while (0)
 #define outhint(args...) do {if (!out_hint(args)) return_0;} while (0)
+#define outfc(args...) do {if (!out_text_with_comment(args)) return_0;} while (0)
 #define outf(args...) do {if (!out_text(args)) return_0;} while (0)
 #define outnl(f) do {if (!out_newline(f)) return_0;} while (0)
 
@@ -39,6 +40,9 @@
 int out_areas(struct formatter *f, const struct lv_segment *seg,
 	      const char *type);
 
+int out_text_with_comment(struct formatter *f, const char* comment, const char *fmt, ...)
+    __attribute__ ((format(printf, 3, 4)));
+
 void out_inc_indent(struct formatter *f);
 void out_dec_indent(struct formatter *f);
 int out_newline(struct formatter *f);



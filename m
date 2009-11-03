From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2009 11:00:47 -0000
Subject: LVM2/lib/format_text export.c text_export.h
Message-ID: <20091103110047.25927.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-11-03 11:00:47

Modified files:
	lib/format_text: export.c text_export.h 

Log message:
	Export functions out_inc_indent(), out_dec_indent() for creating
	indented metadata lines.
	
	Macro outnl() is using exported out_newline() instead of direct
	call f->fn(), that required the visibility of the internal
	struct formatter.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_export.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/format_text/export.c	2009/10/16 17:41:51	1.70
+++ LVM2/lib/format_text/export.c	2009/11/03 11:00:46	1.71
@@ -235,6 +235,24 @@
 	return dm_snprintf(buffer, s, "# %g %s", d, _units[i]) > 0;
 }
 
+/* increment indention level */
+void out_inc_indent(struct formatter *f)
+{
+	_inc_indent(f);
+}
+
+/* decrement indention level */
+void out_dec_indent(struct formatter *f)
+{
+	_dec_indent(f);
+}
+
+/* insert new line */
+int out_newline(struct formatter *f)
+{
+	return f->nl(f);
+}
+
 /*
  * Appends a comment giving a size in more easily
  * readable form (eg, 4M instead of 8096).
--- LVM2/lib/format_text/text_export.h	2009/10/16 17:41:51	1.5
+++ LVM2/lib/format_text/text_export.h	2009/11/03 11:00:46	1.6
@@ -17,7 +17,7 @@
 #define _LVM_TEXT_EXPORT_H
 
 #define outf(args...) do {if (!out_text(args)) return_0;} while (0)
-#define outnl(f) do {if (!f->nl(f)) return_0;} while (0)
+#define outnl(f) do {if (!out_newline(f)) return_0;} while (0)
 
 struct formatter;
 struct lv_segment;
@@ -37,4 +37,8 @@
 int out_areas(struct formatter *f, const struct lv_segment *seg,
 	      const char *type);
 
+void out_inc_indent(struct formatter *f);
+void out_dec_indent(struct formatter *f);
+int out_newline(struct formatter *f);
+
 #endif



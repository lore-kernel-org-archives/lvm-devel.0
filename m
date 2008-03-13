From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Mar 2008 12:33:26 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import.c
Message-ID: <20080313123326.30882.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-03-13 12:33:25

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import.c 

Log message:
	Refactor text format initialisation into _init_text_import.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.802&r2=1.803
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/WHATS_NEW	2008/03/12 16:03:21	1.802
+++ LVM2/WHATS_NEW	2008/03/13 12:33:21	1.803
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Refactor text format initialisation into _init_text_import.
   Escape double quotes and backslashes in external metadata and config data.
   Add functions for escaping double quotes in strings.
   Rename count_chars_len to count_chars.
--- LVM2/lib/format_text/import.c	2008/01/30 13:59:59	1.45
+++ LVM2/lib/format_text/import.c	2008/03/13 12:33:22	1.46
@@ -23,6 +23,18 @@
 /* FIXME Use tidier inclusion method */
 static struct text_vg_version_ops *(_text_vsn_list[2]);
 
+static int _text_import_initialised = 0;
+
+static void _init_text_import()
+{
+	if (_text_import_initialised)
+		return;
+
+	_text_vsn_list[0] = text_vg_vsn1_init();
+	_text_vsn_list[1] = NULL;
+	_text_import_initialised = 1;
+}
+
 const char *text_vgname_import(const struct format_type *fmt,
 			       struct device *dev,
 			       off_t offset, uint32_t size,
@@ -35,13 +47,7 @@
 	struct text_vg_version_ops **vsn;
 	const char *vgname = NULL;
 
-	static int _text_import_initialised = 0;
-
-	if (!_text_import_initialised) {
-		_text_vsn_list[0] = text_vg_vsn1_init();
-		_text_vsn_list[1] = NULL;
-		_text_import_initialised = 1;
-	}
+	_init_text_import();
 
 	if (!(cft = create_config_tree(NULL, 0)))
 		return_NULL;
@@ -83,13 +89,7 @@
 	struct config_tree *cft;
 	struct text_vg_version_ops **vsn;
 
-	static int _text_vg_import_initialised = 0;
-
-	if (!_text_vg_import_initialised) {
-		_text_vsn_list[0] = text_vg_vsn1_init();
-		_text_vsn_list[1] = NULL;
-		_text_vg_import_initialised = 1;
-	}
+	_init_text_import();
 
 	*desc = NULL;
 	*when = 0;



From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Mar 2011 13:44:09 -0000
Subject: LVM2/lib/format_text import_vsn1.c
Message-ID: <20110327134409.10024.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-03-27 13:44:09

Modified files:
	lib/format_text: import_vsn1.c 

Log message:
	Rename _check_version

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/lib/format_text/import_vsn1.c	2011/03/13 23:05:48	1.85
+++ LVM2/lib/format_text/import_vsn1.c	2011/03/27 13:44:08	1.86
@@ -54,7 +54,7 @@
  * Checks that the config file contains vg metadata, and that it
  * we recognise the version number,
  */
-static int _check_version(const struct config_tree *cft)
+static int _vsn1_check_version(const struct config_tree *cft)
 {
 	const struct config_node *cn;
 	const struct config_value *cv;
@@ -871,7 +871,7 @@
 }
 
 static struct text_vg_version_ops _vsn1_ops = {
-	.check_version = _check_version,
+	.check_version = _vsn1_check_version,
 	.read_vg = _read_vg,
 	.read_desc = _read_desc,
 	.read_vgname = _read_vgname,



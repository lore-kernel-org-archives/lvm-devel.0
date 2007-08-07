From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Aug 2007 18:55:39 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20070807185539.26876.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-07 18:55:38

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	A few more cleanups for lvrename of mirrors checkin:
	* add struct lv_names for old/new names
	* replace lv->status & MIRROR checks with lv_is_visible()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/lib/metadata/lv_manip.c	2007/08/07 16:57:09	1.120
+++ LVM2/lib/metadata/lv_manip.c	2007/08/07 18:55:38	1.121
@@ -25,6 +25,11 @@
 #include "segtype.h"
 #include "archiver.h"
 
+struct lv_names {
+	const char *old;
+	const char *new;
+};
+
 /*
  * PVs used by a segment of an LV
  */
@@ -1548,9 +1553,9 @@
 static int _rename_cb(struct cmd_context *cmd, struct logical_volume *lv,
 		      void *data)
 {
-	char **names = (char **) data;
+	struct lv_names *lv_names = (struct lv_names *) data;
 
-	return _rename_sub_lv(cmd, lv, names[0], names[1]);
+	return _rename_sub_lv(cmd, lv, lv_names->old, lv_names->new);
 }
 
 /*
@@ -1588,10 +1593,10 @@
 	      const char *new_name)
 {
 	struct volume_group *vg = lv->vg;
-	const char *names[2];
+	struct lv_names lv_names;
 
 	/* rename is not allowed on sub LVs */
-	if ((lv->status & MIRROR_LOG) || (lv->status & MIRROR_IMAGE)) {
+	if (!lv_is_visible(lv)) {
 		log_error("Cannot rename internal LV \"%s\".", lv->name);
 		return 0;
 	}
@@ -1611,9 +1616,9 @@
 		return 0;
 
 	/* rename sub LVs */
-	names[0] = lv->name;
-	names[1] = new_name;
-	if (!_for_each_sub_lv(cmd, lv, _rename_cb, (void *) names))
+	lv_names.old = lv->name;
+	lv_names.new = new_name;
+	if (!_for_each_sub_lv(cmd, lv, _rename_cb, (void *) &lv_names))
 		return 0;
 
 	/* rename main LV */



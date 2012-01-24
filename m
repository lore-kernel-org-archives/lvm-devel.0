From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Jan 2012 14:15:53 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120124141553.7046.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-01-24 14:15:52

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Properly show LV removal message.
	
	(Fix regression in commit 6e181ba96dc1f806afc2d7fe825a8d3dd8093052)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.346&r2=1.347

--- LVM2/lib/metadata/lv_manip.c	2012/01/24 00:55:03	1.346
+++ LVM2/lib/metadata/lv_manip.c	2012/01/24 14:15:52	1.347
@@ -3143,6 +3143,7 @@
 	struct lvinfo info;
 	struct logical_volume *format1_origin = NULL;
 	int format1_reload_required = 0;
+	int visible;
 
 	vg = lv->vg;
 
@@ -3217,6 +3218,8 @@
 		return 0;
 	}
 
+	visible = lv_is_visible(lv);
+
 	log_verbose("Releasing logical volume \"%s\"", lv->name);
 	if (!lv_remove(lv)) {
 		log_error("Error releasing logical volume \"%s\"", lv->name);
@@ -3251,7 +3254,7 @@
 
 	backup(vg);
 
-	if (lv_is_visible(lv))
+	if (visible)
 		log_print("Logical volume \"%s\" successfully removed", lv->name);
 
 	return 1;



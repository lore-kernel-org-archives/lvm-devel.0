From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Nov 2007 20:02:56 -0000
Subject: LVM2/tools lvcreate.c lvresize.c toollib.c
Message-ID: <20071112200256.23753.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-11-12 20:02:56

Modified files:
	tools          : lvcreate.c lvresize.c toollib.c 

Log message:
	Fix compile warnings / minor errors introduced recently.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/tools/lvcreate.c	2007/11/12 13:34:14	1.155
+++ LVM2/tools/lvcreate.c	2007/11/12 20:02:55	1.156
@@ -638,7 +638,7 @@
 		lp->extents = lp->extents - size_rest + lp->stripes;
 	}
 
-	if (lp->zero && !activation) {
+	if (lp->zero && !activation()) {
 		log_error("Can't wipe start of new LV without using "
 			  "device-mapper kernel driver");
 		return 0;
@@ -918,7 +918,7 @@
 
 revert_new_lv:
 	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(lv) || !vg_write(vg) || backup(vg), !vg_commit(vg))
+	if (!lv_remove(lv) || !vg_write(vg) || backup(vg) || !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
 	return 0;
--- LVM2/tools/lvresize.c	2007/11/02 20:40:04	1.85
+++ LVM2/tools/lvresize.c	2007/11/12 20:02:55	1.86
@@ -243,7 +243,7 @@
 	if (!validate_name(lp->vg_name)) {
 		log_error("Volume group name %s has invalid characters",
 			  lp->vg_name);
-		return NULL;
+		return 0;
 	}
 
 	if ((st = strrchr(lp->lv_name, '/')))
--- LVM2/tools/toollib.c	2007/11/12 14:36:57	1.111
+++ LVM2/tools/toollib.c	2007/11/12 20:02:55	1.112
@@ -1415,7 +1415,7 @@
 	}
 
 revert_new_lv:
-	if (!lv_remove(log_lv) || !vg_write(vg) || backup(vg), !vg_commit(vg))
+	if (!lv_remove(log_lv) || !vg_write(vg) || backup(vg) || !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned log LV before retrying.");
 	return NULL;



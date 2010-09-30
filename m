From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:07:21 -0000
Subject: LVM2/lib/metadata lv.c pv.c vg.c
Message-ID: <20100930140721.15911.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:07:19

Modified files:
	lib/metadata   : lv.c pv.c vg.c 

Log message:
	Simplify logic to create 'attr' strings.
	
	This patch addresses code review request to simplify creation of 'attr'
	strings.  The simplification is done in this separate patch to more
	easily review and ensure the simplification is done without error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/metadata/lv.c	2010/09/30 13:52:55	1.2
+++ LVM2/lib/metadata/lv.c	2010/09/30 14:07:19	1.3
@@ -61,28 +61,16 @@
 		repstr[0] = 'v';
 	/* Origin takes precedence over Mirror */
 	else if (lv_is_origin(lv)) {
-		if (lv_is_merging_origin(lv))
-			repstr[0] = 'O';
-		else
-			repstr[0] = 'o';
+		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
 	}
 	else if (lv->status & MIRRORED) {
-		if (lv->status & MIRROR_NOTSYNCED)
-			repstr[0] = 'M';
-		else
-			repstr[0] = 'm';
+		repstr[0] = (lv->status & MIRROR_NOTSYNCED) ? 'M' : 'm';
 	}else if (lv->status & MIRROR_IMAGE)
-		if (_lv_mimage_in_sync(lv))
-			repstr[0] = 'i';
-		else
-			repstr[0] = 'I';
+		repstr[0] = (_lv_mimage_in_sync(lv)) ? 'i' : 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
 	else if (lv_is_cow(lv)) {
-		if (lv_is_merging_cow(lv))
-			repstr[0] = 'S';
-		else
-			repstr[0] = 's';
+		repstr[0] = (lv_is_merging_cow(lv)) ? 'S' : 's';
 	} else
 		repstr[0] = '-';
 
@@ -100,10 +88,7 @@
 	if (lv->status & LOCKED)
 		repstr[2] = toupper(repstr[2]);
 
-	if (lv->status & FIXED_MINOR)
-		repstr[3] = 'm';	/* Fixed Minor */
-	else
-		repstr[3] = '-';
+	repstr[3] = (lv->status & FIXED_MINOR) ? 'm' : '-';
 
 	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
 		if (info.suspended)
@@ -126,10 +111,7 @@
 				repstr[4] = 'I'; /* Invalid snapshot */
 		}
 
-		if (info.open_count)
-			repstr[5] = 'o';	/* Open */
-		else
-			repstr[5] = '-';
+		repstr[5] = (info.open_count) ? 'o' : '-';
 	} else {
 		repstr[4] = '-';
 		repstr[5] = '-';
--- LVM2/lib/metadata/pv.c	2010/09/30 13:52:56	1.2
+++ LVM2/lib/metadata/pv.c	2010/09/30 14:07:19	1.3
@@ -172,15 +172,8 @@
 		return NULL;
 	}
 
-	if (pv->status & ALLOCATABLE_PV)
-		repstr[0] = 'a';
-	else
-		repstr[0] = '-';
-
-	if (pv->status & EXPORTED_VG)
-		repstr[1] = 'x';
-	else
-		repstr[1] = '-';
+	repstr[0] = (pv->status & ALLOCATABLE_PV) ? 'a' : '-';
+	repstr[1] = (pv->status & EXPORTED_VG) ? 'x' : '-';
 	return repstr;
 }
 
--- LVM2/lib/metadata/vg.c	2010/09/30 13:52:56	1.2
+++ LVM2/lib/metadata/vg.c	2010/09/30 14:07:19	1.3
@@ -443,31 +443,11 @@
 		return NULL;
 	}
 
-	if (vg->status & LVM_WRITE)
-		repstr[0] = 'w';
-	else
-		repstr[0] = 'r';
-
-	if (vg_is_resizeable(vg))
-		repstr[1] = 'z';
-	else
-		repstr[1] = '-';
-
-	if (vg_is_exported(vg))
-		repstr[2] = 'x';
-	else
-		repstr[2] = '-';
-
-	if (vg_missing_pv_count(vg))
-		repstr[3] = 'p';
-	else
-		repstr[3] = '-';
-
+	repstr[0] = (vg->status & LVM_WRITE) ? 'w' : 'r';
+	repstr[1] = (vg_is_resizeable(vg)) ? 'z' : '-';
+	repstr[2] = (vg_is_exported(vg)) ? 'x' : '-';
+	repstr[3] = (vg_missing_pv_count(vg)) ? 'p' : '-';
 	repstr[4] = alloc_policy_char(vg->alloc);
-
-	if (vg_is_clustered(vg))
-		repstr[5] = 'c';
-	else
-		repstr[5] = '-';
+	repstr[5] = (vg_is_clustered(vg)) ? 'c' : '-';
 	return repstr;
 }



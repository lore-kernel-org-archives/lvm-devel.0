From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 Jun 2007 04:36:14 -0000
Subject: LVM2 lib/metadata/metadata.c lib/metadata/meta ...
Message-ID: <20070619043614.1805.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-19 04:36:12

Modified files:
	lib/metadata   : metadata.c metadata.h 
	tools          : lvremove.c polldaemon.c toollib.c vgck.c 
	                 vgconvert.c vgdisplay.c vgexport.c vgreduce.c 
	                 vgremove.c 

Log message:
	Convert vg->status checks to use vg_check_status function.\nRename status_flags to status in vg_check_status.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.165&r2=1.166
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgexport.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/lib/metadata/metadata.c	2007/06/19 04:23:32	1.120
+++ LVM2/lib/metadata/metadata.c	2007/06/19 04:36:12	1.121
@@ -1744,33 +1744,33 @@
 /**
  * vg_check_status - check volume group status flags and log error
  * @vg - volume group to check status flags
- * @status_flags - specific status flags to check (e.g. EXPORTED_VG)
+ * @status - specific status flags to check (e.g. EXPORTED_VG)
  *
  * Returns:
  * 0 - fail
  * 1 - success
  */
-int vg_check_status(struct volume_group *vg, uint32_t status_flags)
+int vg_check_status(struct volume_group *vg, uint32_t status)
 {
-	if ((status_flags & CLUSTERED) &&
+	if ((status & CLUSTERED) &&
 	    (vg->status & CLUSTERED) && !locking_is_clustered() &&
 	    !lockingfailed()) {
 		log_error("Skipping clustered volume group %s", vg->name);
 		return 0;
 	}
 
-	if ((status_flags & EXPORTED_VG) &&
+	if ((status & EXPORTED_VG) &&
 	    (vg->status & EXPORTED_VG)) {
 		log_error("Volume group %s is exported", vg->name);
 		return 0;
 	}
 
-	if ((status_flags & LVM_WRITE) &&
+	if ((status & LVM_WRITE) &&
 	    !(vg->status & LVM_WRITE)) {
 		log_error("Volume group %s is read-only", vg->name);
 		return 0;
 	}
-	if ((status_flags & RESIZEABLE_VG) &&
+	if ((status & RESIZEABLE_VG) &&
 	    !(vg->status & RESIZEABLE_VG)) {
 		log_error("Volume group %s is not resizeable.", vg->name);
 		return 0;
--- LVM2/lib/metadata/metadata.h	2007/06/19 04:23:32	1.165
+++ LVM2/lib/metadata/metadata.h	2007/06/19 04:36:12	1.166
@@ -580,7 +580,7 @@
 
 int vg_remove_snapshot(struct logical_volume *cow);
 
-int vg_check_status(struct volume_group *vg, uint32_t status_flags);
+int vg_check_status(struct volume_group *vg, uint32_t status);
 
 /*
  * Mirroring functions
--- LVM2/tools/lvremove.c	2006/10/23 11:46:16	1.49
+++ LVM2/tools/lvremove.c	2007/06/19 04:36:12	1.50
@@ -24,10 +24,8 @@
 
 	vg = lv->vg;
 
-	if (!(vg->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", vg->name);
+	if (!vg_check_status(vg, LVM_WRITE))
 		return ECMD_FAILED;
-	}
 
 	if (lv_is_origin(lv)) {
 		log_error("Can't remove logical volume \"%s\" under snapshot",
@@ -77,7 +75,7 @@
 
 	/* If the VG is clustered then make sure no-one else is using the LV
 	   we are about to remove */
-	if (vg->status & CLUSTERED) {
+	if (vg_status(vg) & CLUSTERED) {
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Can't get exclusive access to volume \"%s\"",
 				  lv->name);
--- LVM2/tools/polldaemon.c	2006/05/09 21:23:51	1.6
+++ LVM2/tools/polldaemon.c	2007/06/19 04:36:12	1.7
@@ -191,10 +191,8 @@
 		return ECMD_FAILED;
 	}
 
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg->name);
+	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
-	}
 
 	list_iterate_items(lvl, &vg->lvs) {
 		lv_mirr = lvl->lv;
--- LVM2/tools/toollib.c	2007/06/15 10:11:14	1.100
+++ LVM2/tools/toollib.c	2007/06/19 04:36:12	1.101
@@ -159,10 +159,8 @@
 
 	struct lv_list *lvl;
 
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg->name);
+	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
-	}
 
 	if (tags && !list_empty(tags))
 		tags_supplied = 1;
--- LVM2/tools/vgck.c	2006/05/09 21:23:51	1.15
+++ LVM2/tools/vgck.c	2007/06/19 04:36:12	1.16
@@ -30,10 +30,8 @@
 		return ECMD_FAILED;
 	}
 
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg_name);
+	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
-	}
 
 	return ECMD_PROCESSED;
 }
--- LVM2/tools/vgconvert.c	2007/06/15 22:16:55	1.22
+++ LVM2/tools/vgconvert.c	2007/06/19 04:36:12	1.23
@@ -45,15 +45,8 @@
 			return ECMD_FAILED;
 	}
 
-	if (!(vg->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", vg->name);
+	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG))
 		return ECMD_FAILED;
-	}
-
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg_name);
-		return ECMD_FAILED;
-	}
 
 	if (vg->fid->fmt == cmd->fmt) {
 		log_error("Volume group \"%s\" already uses format %s",
--- LVM2/tools/vgdisplay.c	2006/05/09 21:23:51	1.16
+++ LVM2/tools/vgdisplay.c	2007/06/19 04:36:12	1.17
@@ -28,8 +28,7 @@
 	if (!consistent)
 		log_error("WARNING: Volume group \"%s\" inconsistent", vg_name);
 
-	if (vg->status & EXPORTED_VG)
-		log_print("WARNING: volume group \"%s\" is exported", vg_name);
+	vg_check_status(vg, EXPORTED_VG);
 
 	if (arg_count(cmd, colon_ARG)) {
 		vgdisplay_colons(vg);
--- LVM2/tools/vgexport.c	2006/05/09 21:23:51	1.15
+++ LVM2/tools/vgexport.c	2007/06/19 04:36:12	1.16
@@ -33,13 +33,7 @@
 		goto error;
 	}
 
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is already exported", vg_name);
-		goto error;
-	}
-
-	if (!(vg->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", vg_name);
+	if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE)) {
 		goto error;
 	}
 
--- LVM2/tools/vgreduce.c	2007/06/15 22:16:55	1.64
+++ LVM2/tools/vgreduce.c	2007/06/19 04:36:12	1.65
@@ -532,21 +532,7 @@
 		log_print("Wrote out consistent volume group %s", vg_name);
 
 	} else {
-		if (vg->status & EXPORTED_VG) {
-			log_error("Volume group \"%s\" is exported", vg->name);
-			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
-		}
-
-		if (!(vg->status & LVM_WRITE)) {
-			log_error("Volume group \"%s\" is read-only", vg_name);
-			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
-		}
-
-		if (!(vg->status & RESIZEABLE_VG)) {
-			log_error("Volume group \"%s\" is not reducible",
-				  vg_name);
+		if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG)) {
 			unlock_vg(cmd, vg_name);
 			return ECMD_FAILED;
 		}
--- LVM2/tools/vgremove.c	2007/06/15 22:16:55	1.40
+++ LVM2/tools/vgremove.c	2007/06/19 04:36:12	1.41
@@ -23,7 +23,7 @@
 	struct pv_list *pvl;
 	int ret = ECMD_PROCESSED;
 
-	if (!vg || !consistent || (vg->status & PARTIAL_VG)) {
+	if (!vg || !consistent || (vg_status(vg) & PARTIAL_VG)) {
 		log_error("Volume group \"%s\" not found or inconsistent.",
 			  vg_name);
 		log_error("Consider vgreduce --removemissing if metadata "
@@ -31,10 +31,8 @@
 		return ECMD_FAILED;
 	}
 
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg->name);
+	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
-	}
 
 	if (vg->lv_count) {
 		log_error("Volume group \"%s\" still contains %d "



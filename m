From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Jun 2007 19:40:30 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20070606194030.11078.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-06 19:40:28

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c metadata.h 
	tools          : lvconvert.c lvcreate.c lvrename.c lvresize.c 
	                 pvchange.c pvdisplay.c pvmove.c pvresize.c 
	                 reporter.c toollib.c vgextend.c vgmerge.c 
	                 vgreduce.c vgrename.c vgsplit.c 

Log message:
	Add vg_check_status to consolidate vg status flags checks and error messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.623&r2=1.624
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.156&r2=1.157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/WHATS_NEW	2007/05/31 14:19:57	1.623
+++ LVM2/WHATS_NEW	2007/06/06 19:40:27	1.624
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Add vg_check_status to consolidate vg status checks and error messages.
   Add pvdisplay --maps implementation.
   Fix vgcfgrestore man pg to show mandatory VG name and remove LVM1 options.
   Fix vgrename man page to include UUID and be consistent with lvrename.
--- LVM2/lib/metadata/metadata.c	2007/04/26 16:44:59	1.108
+++ LVM2/lib/metadata/metadata.c	2007/06/06 19:40:27	1.109
@@ -24,6 +24,7 @@
 #include "pv_alloc.h"
 #include "activate.h"
 #include "display.h"
+#include "locking.h"
 
 #include <sys/param.h>
 
@@ -1593,3 +1594,44 @@
 
 	return 1;
 }
+
+
+
+/**
+ * vg_check_status - check volume group status flags and log error
+ *
+ * @vg - volume group to check status flags
+ * @status_flags - specific status flags to check (e.g. EXPORTED_VG)
+ *
+ * Returns:
+ * 0 - fail
+ * 1 - success
+ */
+int vg_check_status(struct volume_group *vg, uint32_t status_flags)
+{
+	if ((status_flags & CLUSTERED) &&
+	    (vg->status & CLUSTERED) && !locking_is_clustered() &&
+	    !lockingfailed()) {
+		log_error("Skipping clustered volume group %s", vg->name);
+		return 0;
+	}
+
+	if ((status_flags & EXPORTED_VG) &&
+	    (vg->status & EXPORTED_VG)) {
+		log_error("Volume group %s is exported", vg->name);
+		return 0;
+	}
+
+	if ((status_flags & LVM_WRITE) &&
+	    !(vg->status & LVM_WRITE)) {
+		log_error("Volume group %s is read-only", vg->name);
+		return 0;
+	}
+	if ((status_flags & RESIZEABLE_VG) &&
+	    !(vg->status & RESIZEABLE_VG)) {
+		log_error("Volume group %s is not resizeable.", vg->name);
+		return 0;
+	}
+
+	return 1;
+}
--- LVM2/lib/metadata/metadata.h	2007/04/25 21:10:55	1.156
+++ LVM2/lib/metadata/metadata.h	2007/06/06 19:40:27	1.157
@@ -578,6 +578,8 @@
 
 int vg_remove_snapshot(struct logical_volume *cow);
 
+int vg_check_status(struct volume_group *vg, uint32_t status_flags);
+
 /*
  * Mirroring functions
  */
--- LVM2/tools/lvconvert.c	2007/03/26 16:10:10	1.26
+++ LVM2/tools/lvconvert.c	2007/06/06 19:40:28	1.27
@@ -557,21 +557,8 @@
 		goto error;
 	}
 
-	if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", lp.vg_name);
+	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
 		goto error;
-	}
-
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", lp.vg_name);
-		goto error;
-	}
-
-	if (!(vg->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", lp.vg_name);
-		goto error;
-	}
 
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
 		log_error("Logical volume \"%s\" not found in "
--- LVM2/tools/lvcreate.c	2007/03/26 16:10:10	1.134
+++ LVM2/tools/lvcreate.c	2007/06/06 19:40:28	1.135
@@ -493,21 +493,8 @@
 		return 0;
 	}
 
-	if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", lp->vg_name);
+	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
 		return 0;
-	}
-
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", lp->vg_name);
-		return 0;
-	}
-
-	if (!(vg->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", lp->vg_name);
-		return 0;
-	}
 
 	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
--- LVM2/tools/lvrename.c	2007/03/09 20:47:41	1.42
+++ LVM2/tools/lvrename.c	2007/06/06 19:40:28	1.43
@@ -109,21 +109,8 @@
 		goto error;
 	}
 
-	if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
 		goto error;
-	}
-
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg->name);
-		goto error;
-	}
-
-	if (!(vg->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", vg_name);
-		goto error;
-	}
 
 	if (find_lv_in_vg(vg, lv_name_new)) {
 		log_error("Logical volume \"%s\" already exists in "
--- LVM2/tools/lvresize.c	2006/09/26 09:35:43	1.76
+++ LVM2/tools/lvresize.c	2007/06/06 19:40:28	1.77
@@ -141,21 +141,8 @@
 		return ECMD_FAILED;
 	}
 
-	if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
 		return ECMD_FAILED;
-	}
-
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group %s is exported", vg->name);
-		return ECMD_FAILED;
-	}
-
-	if (!(vg->status & LVM_WRITE)) {
-		log_error("Volume group %s is read-only", lp->vg_name);
-		return ECMD_FAILED;
-	}
 
 	/* does LV exist? */
 	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
--- LVM2/tools/pvchange.c	2006/11/30 23:11:42	1.44
+++ LVM2/tools/pvchange.c	2007/06/06 19:40:28	1.45
@@ -67,21 +67,9 @@
 			return 0;
 		}
 
-		if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-		    !lockingfailed()) {
-			log_error("Skipping clustered volume group %s", vg->name);
-			return 0;
-		}
-
-		if (vg->status & EXPORTED_VG) {
-			unlock_vg(cmd, pv->vg_name);
-			log_error("Volume group \"%s\" is exported", vg->name);
-			return 0;
-		}
-
-		if (!(vg->status & LVM_WRITE)) {
+		if (!vg_check_status(vg,
+				     CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
 			unlock_vg(cmd, pv->vg_name);
-			log_error("Volume group \"%s\" is read-only", vg->name);
 			return 0;
 		}
 
--- LVM2/tools/pvdisplay.c	2007/06/05 18:23:17	1.28
+++ LVM2/tools/pvdisplay.c	2007/06/06 19:40:28	1.29
@@ -37,10 +37,7 @@
 	                 goto out;
 	         }
 
-	         if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	             !lockingfailed()) {
-	                 log_error("Skipping clustered volume group %s",
-	                           vg->name);
+		 if (!vg_check_status(vg, CLUSTERED)) {
 	                 ret = ECMD_FAILED;
 	                 goto out;
 	         }
--- LVM2/tools/pvmove.c	2007/03/09 20:47:41	1.33
+++ LVM2/tools/pvmove.c	2007/06/06 19:40:28	1.34
@@ -66,20 +66,7 @@
 		return NULL;
 	}
 
-	if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vgname);
-		return NULL;
-	}
-
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vgname);
-		unlock_vg(cmd, vgname);
-		return NULL;
-	}
-
-	if (!(vg->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", vgname);
+	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
 		unlock_vg(cmd, vgname);
 		return NULL;
 	}
--- LVM2/tools/pvresize.c	2006/09/02 01:18:17	1.3
+++ LVM2/tools/pvresize.c	2007/06/06 19:40:28	1.4
@@ -77,22 +77,8 @@
 			return ECMD_FAILED;
 		}
 
-		if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-		    !lockingfailed()) {
+		if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
 			unlock_vg(cmd, vg_name);
-			log_error("Skipping clustered volume group %s", vg->name);
-			return ECMD_FAILED;
-		}
-
-		if (vg->status & EXPORTED_VG) {
-			unlock_vg(cmd, vg_name);
-			log_error("Volume group \"%s\" is exported", vg->name);
-			return ECMD_FAILED;
-		}
-
-		if (!(vg->status & LVM_WRITE)) {
-			unlock_vg(cmd, pv->vg_name);
-			log_error("Volume group \"%s\" is read-only", vg->name);
 			return ECMD_FAILED;
 		}
 
--- LVM2/tools/reporter.c	2007/02/14 15:18:31	1.21
+++ LVM2/tools/reporter.c	2007/06/06 19:40:28	1.22
@@ -71,9 +71,7 @@
 		goto out;
 	}
 
-	if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+	if (!vg_check_status(vg, CLUSTERED)) {
 		ret = ECMD_FAILED;
 		goto out;
 	}
@@ -119,10 +117,7 @@
 			goto out;
 		}
 
-		if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-		    !lockingfailed()) {
-			log_error("Skipping clustered volume group %s",
-				  vg->name);
+		if (!vg_check_status(vg, CLUSTERED)) {
 			ret = ECMD_FAILED;
 			goto out;
 		}
--- LVM2/tools/toollib.c	2007/03/26 16:10:10	1.98
+++ LVM2/tools/toollib.c	2007/06/06 19:40:28	1.99
@@ -357,11 +357,7 @@
 				log_error("Volume group \"%s\" "
 					  "not found", vgname);
 			else {
-				if ((vg->status & CLUSTERED) &&
-			    	    !locking_is_clustered() &&
-				    !lockingfailed()) {
-					log_error("Skipping clustered volume "
-						  "group %s", vgname);
+				if (!vg_check_status(vg, CLUSTERED)) {
 					if (ret_max < ECMD_FAILED)
 						ret_max = ECMD_FAILED;
 					continue;
@@ -377,10 +373,8 @@
 			}
 		}
 
-		if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-		    !lockingfailed()) {
+		if (!vg_check_status(vg, CLUSTERED)) {
 			unlock_vg(cmd, vgname);
-			log_error("Skipping clustered volume group %s", vgname);
 			if (ret_max < ECMD_FAILED)
 				ret_max = ECMD_FAILED;
 			continue;
@@ -485,9 +479,7 @@
 		return ECMD_FAILED;
 	}
 
-	if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg_name);
+	if (!vg_check_status(vg, CLUSTERED)) {
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
 	}
@@ -735,13 +727,8 @@
 				if (!consistent)
 					continue;
 
-				if ((vg->status & CLUSTERED) &&
-				    !locking_is_clustered() &&
-				    !lockingfailed()) {
-					log_error("Skipping clustered volume "
-						  "group %s", sll->str);
+				if (!vg_check_status(vg, CLUSTERED))
 					continue;
-				}
 
 				ret = process_each_pv_in_vg(cmd, vg, &tags,
 							    handle,
--- LVM2/tools/vgextend.c	2007/03/09 21:25:33	1.29
+++ LVM2/tools/vgextend.c	2007/06/06 19:40:28	1.30
@@ -59,26 +59,9 @@
 		goto error;
 	}
 
-	if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+	if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG |
+				 LVM_WRITE | RESIZEABLE_VG))
 		goto error;
-	}
-
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg->name);
-		goto error;
-	}
-
-	if (!(vg->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", vg_name);
-		goto error;
-	}
-
-	if (!(vg->status & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" is not resizeable.", vg_name);
-		goto error;
-	}
 
 /********** FIXME
 	log_print("maximum logical volume size is %s",
--- LVM2/tools/vgmerge.c	2007/03/09 20:47:41	1.36
+++ LVM2/tools/vgmerge.c	2007/06/06 19:40:28	1.37
@@ -41,21 +41,7 @@
 		return ECMD_FAILED;
 	}
 
-	if ((vg_to->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg_name_to);
-		unlock_vg(cmd, vg_name_to);
-		return ECMD_FAILED;
-	}
-
-	if (vg_to->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg_to->name);
-		unlock_vg(cmd, vg_name_to);
-		return ECMD_FAILED;
-	}
-
-	if (!(vg_to->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", vg_to->name);
+	if (!vg_check_status(vg_to, CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
 		unlock_vg(cmd, vg_name_to);
 		return ECMD_FAILED;
 	}
@@ -73,21 +59,8 @@
 		goto error;
 	}
 
-        if ((vg_from->status & CLUSTERED) && !locking_is_clustered() &&
-            !lockingfailed()) {
-                log_error("Skipping clustered volume group %s", vg_name_from);
+	if (!vg_check_status(vg_from, CLUSTERED | EXPORTED_VG | LVM_WRITE))
                 goto error;
-        }
-
-	if (vg_from->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg_from->name);
-		goto error;
-	}
-
-	if (!(vg_from->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", vg_from->name);
-		goto error;
-	}
 
 	if ((active = lvs_in_vg_activated(vg_from))) {
 		log_error("Logical volumes in \"%s\" must be inactive",
--- LVM2/tools/vgreduce.c	2007/03/09 21:25:33	1.58
+++ LVM2/tools/vgreduce.c	2007/06/06 19:40:28	1.59
@@ -484,9 +484,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (vg && (vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+	if (vg && !vg_check_status(vg, CLUSTERED)) {
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
 	}
@@ -506,10 +504,7 @@
 			unlock_vg(cmd, vg_name);
 			return ECMD_FAILED;
 		}
-		if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-		    !lockingfailed()) {
-			log_error("Skipping clustered volume group %s",
-				  vg->name);
+		if (!vg_check_status(vg, CLUSTERED)) {
 			unlock_vg(cmd, vg_name);
 			return ECMD_FAILED;
 		}
--- LVM2/tools/vgrename.c	2007/03/09 20:47:41	1.43
+++ LVM2/tools/vgrename.c	2007/06/06 19:40:28	1.44
@@ -102,21 +102,13 @@
 		return ECMD_FAILED;
 	}
 
-	if ((vg_old->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg_old->name);
+	if (!vg_check_status(vg_old, CLUSTERED | LVM_WRITE)) {
 		unlock_vg(cmd, vg_name_old);
 		return ECMD_FAILED;
 	}
 
-	if (vg_old->status & EXPORTED_VG)
-		log_info("Volume group \"%s\" is exported", vg_old->name);
-
-	if (!(vg_old->status & LVM_WRITE)) {
-		unlock_vg(cmd, vg_name_old);
-		log_error("Volume group \"%s\" is read-only", vg_old->name);
-		return ECMD_FAILED;
-	}
+	/* Don't return failure for EXPORTED_VG */
+	vg_check_status(vg_old, EXPORTED_VG);
 
 	if (lvs_in_vg_activated_by_uuid_only(vg_old)) {
 		unlock_vg(cmd, vg_name_old);
--- LVM2/tools/vgsplit.c	2007/05/15 13:01:41	1.25
+++ LVM2/tools/vgsplit.c	2007/06/06 19:40:28	1.26
@@ -251,27 +251,8 @@
 		return ECMD_FAILED;
 	}
 
-	if ((vg_from->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg_from->name);
-		unlock_vg(cmd, vg_name_from);
-		return ECMD_FAILED;
-	}
-
-	if (vg_from->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg_from->name);
-		unlock_vg(cmd, vg_name_from);
-		return ECMD_FAILED;
-	}
-
-	if (!(vg_from->status & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" is not resizeable", vg_from->name);
-		unlock_vg(cmd, vg_name_from);
-		return ECMD_FAILED;
-	}
-
-	if (!(vg_from->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", vg_from->name);
+	if (!vg_check_status(vg_from, CLUSTERED | EXPORTED_VG |
+				      RESIZEABLE_VG | LVM_WRITE)) {
 		unlock_vg(cmd, vg_name_from);
 		return ECMD_FAILED;
 	}



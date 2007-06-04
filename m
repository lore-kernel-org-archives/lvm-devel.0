From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 04 Jun 2007 14:40:10 -0400
Subject: [PATCH] add vg_check_status to consolidate vg status checks and error messages
Message-ID: <1180982410.3830.18.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Simple function that enables some code cleanup of vg status flag
checking.

Should not change major functional behavior, but there are minor changes
a few RFC's:

Minor functional changes:
1) Some checks are not in the exact order as before, but this should not
matter (other than possible error message sequencing)
2) Very slight differences in some error messages as a result of the
messages printed from a single function (e.g. some vg names displayed
were in double quotes, others were not)
3) Now using "vg->name" in the log_error messages, instead of the
variety of different variables being used.  I traced the prior call to
vg_read though, and if we get non-NULL there, vg->name should be valid,
so I'm fairly certain this is ok.

RFC items:
1) Possible unlock errors in 2 places of existing code involving the
CLUSTERED check (see pvchange.c and pvmove.c).  I think an unlock should
be added here but left it out to keep as close to existing code as
possible and to call out this possible change.
2) Not sure if lib/metadata.c is the right place for this.  Should I
create a lib/metadata/vg_manip.c or put it elsewhere


Add vg_check_status to consolidate vg status flags checks and error messages.
Index: LVM2/lib/metadata/metadata.c
===================================================================
--- LVM2.orig/lib/metadata/metadata.c	2007-04-26 12:44:59.000000000 -0400
+++ LVM2/lib/metadata/metadata.c	2007-06-04 13:51:33.000000000 -0400
@@ -24,6 +24,7 @@
 #include "pv_alloc.h"
 #include "activate.h"
 #include "display.h"
+#include "locking.h"
 
 #include <sys/param.h>
 
@@ -1593,3 +1594,44 @@ int pv_analyze(struct cmd_context *cmd, 
 
 	return 1;
 }
+
+
+
+/**
+ * vg_check_status - check volume group status flags and log error if not set
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
+		log_error("Volume group \"%s\" is exported", vg->name);
+		return 0;
+	}
+
+	if ((status_flags & LVM_WRITE) &&
+	    !(vg->status & LVM_WRITE)) {
+		log_error("Volume group \"%s\" is read-only", vg->name);
+		return 0;
+	}
+	if ((status_flags & RESIZEABLE_VG) &&
+	    !(vg->status & RESIZEABLE_VG)) {
+		log_error("Volume group \"%s\" is not resizeable.", vg->name);
+		return 0;
+	}
+
+	return 1;
+}
Index: LVM2/lib/metadata/metadata.h
===================================================================
--- LVM2.orig/lib/metadata/metadata.h	2007-04-25 17:10:55.000000000 -0400
+++ LVM2/lib/metadata/metadata.h	2007-06-04 13:51:10.000000000 -0400
@@ -578,6 +578,8 @@ int vg_add_snapshot(struct format_instan
 
 int vg_remove_snapshot(struct logical_volume *cow);
 
+int vg_check_status(struct volume_group *vg, uint32_t status_flags);
+
 /*
  * Mirroring functions
  */
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c	2007-03-26 12:10:10.000000000 -0400
+++ LVM2/tools/lvconvert.c	2007-06-04 13:52:34.000000000 -0400
@@ -557,21 +557,8 @@ int lvconvert(struct cmd_context * cmd, 
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
Index: LVM2/tools/lvcreate.c
===================================================================
--- LVM2.orig/tools/lvcreate.c	2007-03-26 12:10:10.000000000 -0400
+++ LVM2/tools/lvcreate.c	2007-06-04 13:53:26.000000000 -0400
@@ -493,21 +493,8 @@ static int _lvcreate(struct cmd_context 
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
Index: LVM2/tools/lvrename.c
===================================================================
--- LVM2.orig/tools/lvrename.c	2007-03-09 15:47:41.000000000 -0500
+++ LVM2/tools/lvrename.c	2007-06-04 13:54:33.000000000 -0400
@@ -109,21 +109,8 @@ int lvrename(struct cmd_context *cmd, in
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
Index: LVM2/tools/lvresize.c
===================================================================
--- LVM2.orig/tools/lvresize.c	2006-09-26 05:35:43.000000000 -0400
+++ LVM2/tools/lvresize.c	2007-06-04 13:55:15.000000000 -0400
@@ -141,21 +141,8 @@ static int _lvresize(struct cmd_context 
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
Index: LVM2/tools/pvchange.c
===================================================================
--- LVM2.orig/tools/pvchange.c	2006-11-30 18:11:42.000000000 -0500
+++ LVM2/tools/pvchange.c	2007-06-04 13:57:11.000000000 -0400
@@ -67,21 +67,11 @@ static int _pvchange_single(struct cmd_c
 			return 0;
 		}
 
-		if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-		    !lockingfailed()) {
-			log_error("Skipping clustered volume group %s", vg->name);
+		if (!vg_check_status(vg, CLUSTERED))
 			return 0;
-		}
-
-		if (vg->status & EXPORTED_VG) {
-			unlock_vg(cmd, pv->vg_name);
-			log_error("Volume group \"%s\" is exported", vg->name);
-			return 0;
-		}
 
-		if (!(vg->status & LVM_WRITE)) {
+		if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE)) {
 			unlock_vg(cmd, pv->vg_name);
-			log_error("Volume group \"%s\" is read-only", vg->name);
 			return 0;
 		}
 
Index: LVM2/tools/pvdisplay.c
===================================================================
--- LVM2.orig/tools/pvdisplay.c	2007-05-31 16:10:25.000000000 -0400
+++ LVM2/tools/pvdisplay.c	2007-06-04 13:58:07.000000000 -0400
@@ -37,10 +37,7 @@ static int _pvdisplay_single(struct cmd_
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
Index: LVM2/tools/pvmove.c
===================================================================
--- LVM2.orig/tools/pvmove.c	2007-03-09 15:47:41.000000000 -0500
+++ LVM2/tools/pvmove.c	2007-06-04 13:59:09.000000000 -0400
@@ -66,20 +66,10 @@ static struct volume_group *_get_vg(stru
 		return NULL;
 	}
 
-	if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vgname);
+	if (!vg_check_status(vg, CLUSTERED))
 		return NULL;
-	}
-
-	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vgname);
-		unlock_vg(cmd, vgname);
-		return NULL;
-	}
 
-	if (!(vg->status & LVM_WRITE)) {
-		log_error("Volume group \"%s\" is read-only", vgname);
+	if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE)) {
 		unlock_vg(cmd, vgname);
 		return NULL;
 	}
Index: LVM2/tools/pvresize.c
===================================================================
--- LVM2.orig/tools/pvresize.c	2006-09-01 21:18:17.000000000 -0400
+++ LVM2/tools/pvresize.c	2007-06-04 13:59:51.000000000 -0400
@@ -77,22 +77,8 @@ static int _pvresize_single(struct cmd_c
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
 
Index: LVM2/tools/reporter.c
===================================================================
--- LVM2.orig/tools/reporter.c	2007-02-14 10:18:31.000000000 -0500
+++ LVM2/tools/reporter.c	2007-06-04 14:00:14.000000000 -0400
@@ -71,9 +71,7 @@ static int _pvsegs_sub_single(struct cmd
 		goto out;
 	}
 
-	if ((vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+	if (!vg_check_status(vg, CLUSTERED)) {
 		ret = ECMD_FAILED;
 		goto out;
 	}
Index: LVM2/tools/toollib.c
===================================================================
--- LVM2.orig/tools/toollib.c	2007-03-26 12:10:10.000000000 -0400
+++ LVM2/tools/toollib.c	2007-06-04 14:01:30.000000000 -0400
@@ -357,11 +357,7 @@ int process_each_lv(struct cmd_context *
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
Index: LVM2/tools/vgextend.c
===================================================================
--- LVM2.orig/tools/vgextend.c	2007-03-09 16:25:33.000000000 -0500
+++ LVM2/tools/vgextend.c	2007-06-04 14:09:14.000000000 -0400
@@ -59,26 +59,9 @@ int vgextend(struct cmd_context *cmd, in
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
Index: LVM2/tools/vgmerge.c
===================================================================
--- LVM2.orig/tools/vgmerge.c	2007-03-09 15:47:41.000000000 -0500
+++ LVM2/tools/vgmerge.c	2007-06-04 14:10:32.000000000 -0400
@@ -41,21 +41,7 @@ static int _vgmerge_single(struct cmd_co
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
Index: LVM2/tools/vgreduce.c
===================================================================
--- LVM2.orig/tools/vgreduce.c	2007-03-09 16:25:33.000000000 -0500
+++ LVM2/tools/vgreduce.c	2007-06-04 14:04:47.000000000 -0400
@@ -484,9 +484,7 @@ int vgreduce(struct cmd_context *cmd, in
 		return ECMD_FAILED;
 	}
 
-	if (vg && (vg->status & CLUSTERED) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+	if (vg && !vg_check_status(vg, CLUSTERED)) {
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
 	}
Index: LVM2/tools/vgrename.c
===================================================================
--- LVM2.orig/tools/vgrename.c	2007-03-09 15:47:41.000000000 -0500
+++ LVM2/tools/vgrename.c	2007-06-04 14:07:15.000000000 -0400
@@ -102,21 +102,13 @@ int vgrename(struct cmd_context *cmd, in
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
Index: LVM2/tools/vgsplit.c
===================================================================
--- LVM2.orig/tools/vgsplit.c	2007-05-15 09:01:41.000000000 -0400
+++ LVM2/tools/vgsplit.c	2007-06-04 14:09:22.000000000 -0400
@@ -251,27 +251,8 @@ int vgsplit(struct cmd_context *cmd, int
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




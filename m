From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2007 16:16:55 -0000
Subject: LVM2 lib/metadata/metadata-exported.h tools/lv ...
Message-ID: <20070820161655.25192.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-20 16:16:54

Modified files:
	lib/metadata   : metadata-exported.h 
	tools          : lvremove.c 

Log message:
	Prepare to move guts of lvremove into lvm library

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/lib/metadata/metadata-exported.h	2007/08/07 09:06:05	1.7
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/20 16:16:54	1.8
@@ -103,6 +103,15 @@
 	AREA_LV
 } area_type_t;
 
+/*
+ * Whether or not to force an operation.
+ */
+typedef enum {
+	DONT_FORCE = 0,
+	FORCE = 1,
+	FORCE_2 = 2
+} force_t;
+
 struct cmd_context;
 struct format_handler;
 struct labeller;
--- LVM2/tools/lvremove.c	2007/06/19 04:36:12	1.50
+++ LVM2/tools/lvremove.c	2007/08/20 16:16:54	1.51
@@ -15,8 +15,9 @@
 
 #include "tools.h"
 
-static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
-			   void *handle __attribute((unused)))
+/* TODO: Next checkin, move to lvm library (lv_manip.c, metadata-exported.h) */
+static int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
+			    force_t force)
 {
 	struct volume_group *vg;
 	struct lvinfo info;
@@ -25,29 +26,29 @@
 	vg = lv->vg;
 
 	if (!vg_check_status(vg, LVM_WRITE))
-		return ECMD_FAILED;
+		return 0;
 
 	if (lv_is_origin(lv)) {
 		log_error("Can't remove logical volume \"%s\" under snapshot",
 			  lv->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv->status & MIRROR_IMAGE) {
 		log_error("Can't remove logical volume %s used by a mirror",
 			  lv->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv->status & MIRROR_LOG) {
 		log_error("Can't remove logical volume %s used as mirror log",
 			  lv->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	/* FIXME Ensure not referred to by another existing LVs */
@@ -56,22 +57,22 @@
 		if (info.open_count) {
 			log_error("Can't remove open logical volume \"%s\"",
 				  lv->name);
-			return ECMD_FAILED;
+			return 0;
 		}
 
-		if (info.exists && !arg_count(cmd, force_ARG)) {
+		if (info.exists && (force == DONT_FORCE)) {
 			if (yes_no_prompt("Do you really want to remove active "
 					  "logical volume \"%s\"? [y/n]: ",
 					  lv->name) == 'n') {
 				log_print("Logical volume \"%s\" not removed",
 					  lv->name);
-				return ECMD_FAILED;
+				return 0;
 			}
 		}
 	}
 
 	if (!archive(vg))
-		return ECMD_FAILED;
+		return 0;
 
 	/* If the VG is clustered then make sure no-one else is using the LV
 	   we are about to remove */
@@ -79,7 +80,7 @@
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Can't get exclusive access to volume \"%s\"",
 				  lv->name);
-			return ECMD_FAILED;
+			return 0;
 		}
 	}
 
@@ -87,7 +88,7 @@
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate logical volume \"%s\"",
 			  lv->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv_is_cow(lv)) {
@@ -95,24 +96,24 @@
 		log_verbose("Removing snapshot %s", lv->name);
 		if (!vg_remove_snapshot(lv)) {
 			stack;
-			return ECMD_FAILED;
+			return 0;
 		}
 	}
 
 	log_verbose("Releasing logical volume \"%s\"", lv->name);
 	if (!lv_remove(lv)) {
 		log_error("Error releasing logical volume \"%s\"", lv->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	/* store it on disks */
 	if (!vg_write(vg))
-		return ECMD_FAILED;
+		return 0;
 
 	backup(vg);
 
 	if (!vg_commit(vg))
-		return ECMD_FAILED;
+		return 0;
 
 	/* If no snapshots left, reload without -real. */
 	if (origin && !lv_is_origin(origin)) {
@@ -123,7 +124,16 @@
 	}
 
 	log_print("Logical volume \"%s\" successfully removed", lv->name);
-	return ECMD_PROCESSED;
+	return 1;
+}
+
+static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
+			   void *handle __attribute((unused)))
+{
+	if (!lv_remove_single(cmd, lv, arg_count(cmd, force_ARG)))
+		return ECMD_FAILED;
+	else
+		return ECMD_PROCESSED;
 }
 
 int lvremove(struct cmd_context *cmd, int argc, char **argv)



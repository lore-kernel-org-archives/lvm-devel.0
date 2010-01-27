From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Jan 2010 13:29:12 -0000
Subject: LVM2 ./WHATS_NEW tools/pvmove.c
Message-ID: <20100127132912.13717.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-27 13:29:11

Modified files:
	.              : WHATS_NEW 
	tools          : pvmove.c 

Log message:
	Fix pvmove abort when temporary mirror fails to be cluster-aware.
	
	When activation of pvmove mirror fails on cluster, some nodes
	still possibly succeeded in activation.
	
	- Explicitly deactivate that mirror to be sure
	- properly pair suspend/resume calls to not cause memory lock problems in clvmd
	
	Code cannot simply call _finish_pvmove on cluster in this situation, because
	changed LVs are suspended twice (causing memory inbalance) and also temporary
	mirror is activated when it is not expected (and we know that it failed already).
	
	Patch prepares special function which remove temporary mirror references from
	metadata and then resumes changed LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1411&r2=1.1412
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/WHATS_NEW	2010/01/27 13:23:57	1.1411
+++ LVM2/WHATS_NEW	2010/01/27 13:29:11	1.1412
@@ -1,5 +1,6 @@
 Version 2.02.60 - 23rd January 2010
 ===================================
+  Fix pvmove abort workaround to be cluster-aware when temporary mirror activation fails.
   Always query device by using uuid only and not name in clvmd.
   Add missing metadata reverts in pvmove error path.
   Unlock shared lock in clvmd if activation calls failed.
--- LVM2/tools/pvmove.c	2010/01/26 08:01:18	1.73
+++ LVM2/tools/pvmove.c	2010/01/27 13:29:11	1.74
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -284,9 +284,26 @@
 	return r;
 }
 
-static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
-			  struct logical_volume *lv_mirr,
-			  struct dm_list *lvs_changed);
+static int _detach_pvmove_mirror(struct cmd_context *cmd,
+				 struct logical_volume *lv_mirr)
+{
+	struct dm_list lvs_completed;
+	struct lv_list *lvl;
+
+	/* Update metadata to remove mirror segments and break dependencies */
+	dm_list_init(&lvs_completed);
+	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, NULL, PVMOVE) ||
+	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
+					    &lvs_completed)) {
+		return 0;
+	}
+
+	dm_list_iterate_items(lvl, &lvs_completed)
+		/* FIXME Assumes only one pvmove at a time! */
+		lvl->lv->status &= ~LOCKED;
+
+	return 1;
+}
 
 static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			    struct logical_volume *lv_mirr,
@@ -341,12 +358,27 @@
 			}
 
 			/*
+			 * FIXME: review ordering of operations above,
+			 * temporary mirror should be preloaded in suspend.
+			 * Also banned operation here when suspended.
 			 * Nothing changed yet, try to revert pvmove.
 			 */
 			log_error("Temporary pvmove mirror activation failed.");
-			if (!_finish_pvmove(cmd, vg, lv_mirr, lvs_changed))
+
+			/* Ensure that temporary mrror is deactivate even on other nodes. */
+			(void)deactivate_lv(cmd, lv_mirr);
+
+			/* Revert metadata */
+			if (!_detach_pvmove_mirror(cmd, lv_mirr) ||
+			    !lv_remove(lv_mirr) ||
+			    !vg_write(vg) || !vg_commit(vg))
 				log_error("ABORTING: Restoring original configuration "
 					  "before pvmove failed. Run pvmove --abort.");
+
+			/* Unsuspend LVs */
+			if(!resume_lvs(cmd, lvs_changed))
+				stack;
+
 			goto out;
 		}
 	} else if (!resume_lv(cmd, lv_mirr)) {
@@ -487,22 +519,12 @@
 			  struct dm_list *lvs_changed)
 {
 	int r = 1;
-	struct dm_list lvs_completed;
-	struct lv_list *lvl;
 
-	/* Update metadata to remove mirror segments and break dependencies */
-	dm_list_init(&lvs_completed);
-	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, NULL, PVMOVE) ||
-	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
-					    &lvs_completed)) {
+	if (!_detach_pvmove_mirror(cmd, lv_mirr)) {
 		log_error("ABORTING: Removal of temporary mirror failed");
 		return 0;
 	}
 
-	dm_list_iterate_items(lvl, &lvs_completed)
-		/* FIXME Assumes only one pvmove at a time! */
-		lvl->lv->status &= ~LOCKED;
-
 	/* Store metadata without dependencies on mirror segments */
 	if (!vg_write(vg)) {
 		log_error("ABORTING: Failed to write new data locations "



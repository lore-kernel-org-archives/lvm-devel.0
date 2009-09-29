From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Sep 2009 19:35:27 -0000
Subject: LVM2 ./WHATS_NEW tools/polldaemon.c tools/poll ...
Message-ID: <20090929193527.14723.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-29 19:35:26

Modified files:
	.              : WHATS_NEW 
	tools          : polldaemon.c polldaemon.h 

Log message:
	Generalise polldaemon code by changing mirror-specific variable names.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1279&r2=1.1280
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2009/09/29 18:50:28	1.1279
+++ LVM2/WHATS_NEW	2009/09/29 19:35:26	1.1280
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Generalise polldaemon code by changing mirror-specific variable names.
   Don't attempt to deactivate an LV if any of its snapshots are in use.
   Return fail if lv_deactivate fails to remove device from kernel.
   Provide alternative implementation of obsolete siginterrupt().
--- LVM2/tools/polldaemon.c	2009/09/15 01:38:59	1.23
+++ LVM2/tools/polldaemon.c	2009/09/29 19:35:26	1.24
@@ -63,11 +63,11 @@
 	return 1;
 }
 
-static int _check_mirror_status(struct cmd_context *cmd,
-				struct volume_group *vg,
-				struct logical_volume *lv_mirr,
-				const char *name, struct daemon_parms *parms,
-				int *finished)
+static int _check_lv_status(struct cmd_context *cmd,
+			    struct volume_group *vg,
+			    struct logical_volume *lv,
+			    const char *name, struct daemon_parms *parms,
+			    int *finished)
 {
 	struct dm_list *lvs_changed;
 	float segment_percent = 0.0, overall_percent = 0.0;
@@ -77,22 +77,22 @@
 	*finished = 1;
 
 	if (parms->aborting) {
-		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
+		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv))) {
 			log_error("Failed to generate list of copied LVs: "
 				  "can't abort.");
 			return 0;
 		}
-		parms->poll_fns->finish_copy(cmd, vg, lv_mirr, lvs_changed);
+		parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed);
 		return 0;
 	}
 
-	if (!lv_mirror_percent(cmd, lv_mirr, !parms->interval, &segment_percent,
+	if (!lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
 			       &event_nr)) {
 		log_error("ABORTING: Mirror percentage check failed.");
 		return 0;
 	}
 
-	overall_percent = copy_percent(lv_mirr);
+	overall_percent = copy_percent(lv);
 	if (parms->progress_display)
 		log_print("%s: %s: %.1f%%", name, parms->progress_title,
 			  overall_percent);
@@ -106,22 +106,20 @@
 		return 1;
 	}
 
-	if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
+	if (!(lvs_changed = lvs_using_lv(cmd, vg, lv))) {
 		log_error("ABORTING: Failed to generate list of copied LVs");
 		return 0;
 	}
 
 	/* Finished? Or progress to next segment? */
 	if (overall_percent >= 100.0) {
-		if (!parms->poll_fns->finish_copy(cmd, vg, lv_mirr,
-						  lvs_changed))
+		if (!parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed))
 			return 0;
 	} else {
-		if (!parms->poll_fns->update_metadata(cmd, vg, lv_mirr,
-						      lvs_changed, 0)) {
+		if (!parms->poll_fns->update_metadata(cmd, vg, lv, lvs_changed,
+						      0)) {
 			log_error("ABORTING: Segment progression failed.");
-			parms->poll_fns->finish_copy(cmd, vg, lv_mirr,
-						     lvs_changed);
+			parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed);
 			return 0;
 		}
 		*finished = 0;	/* Another segment */
@@ -130,14 +128,14 @@
 	return 1;
 }
 
-static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name, const char *uuid,
+static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const char *uuid,
 				   struct daemon_parms *parms)
 {
 	struct volume_group *vg;
-	struct logical_volume *lv_mirr;
+	struct logical_volume *lv;
 	int finished = 0;
 
-	/* Poll for mirror completion */
+	/* Poll for completion */
 	while (!finished) {
 		/* FIXME Also needed in vg/lvchange -ay? */
 		/* FIXME Use alarm for regular intervals instead */
@@ -156,16 +154,15 @@
 			return 0;
 		}
 
-		if (!(lv_mirr = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid,
-							     parms->lv_type))) {
+		if (!(lv = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid,
+							parms->lv_type))) {
 			log_error("ABORTING: Can't find mirror LV in %s for %s",
 				  vg->name, name);
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return 0;
 		}
 
-		if (!_check_mirror_status(cmd, vg, lv_mirr, name, parms,
-					  &finished)) {
+		if (!_check_lv_status(cmd, vg, lv, name, parms, &finished)) {
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return 0;
 		}
@@ -181,20 +178,20 @@
 {
 	struct daemon_parms *parms = (struct daemon_parms *) handle;
 	struct lv_list *lvl;
-	struct logical_volume *lv_mirr;
+	struct logical_volume *lv;
 	const char *name;
 	int finished;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		lv_mirr = lvl->lv;
-		if (!(lv_mirr->status & parms->lv_type))
+		lv = lvl->lv;
+		if (!(lv->status & parms->lv_type))
 			continue;
-		if (!(name = parms->poll_fns->get_copy_name_from_lv(lv_mirr)))
+		if (!(name = parms->poll_fns->get_copy_name_from_lv(lv)))
 			continue;
 		/* FIXME Need to do the activation from _set_up_pvmove here
 		 *       if it's not running and we're not aborting */
-		if (_check_mirror_status(cmd, vg, lv_mirr, name,
-					 parms, &finished) && !finished)
+		if (_check_lv_status(cmd, vg, lv, name, parms, &finished) &&
+		    !finished)
 			parms->outstanding_count++;
 	}
 
@@ -249,8 +246,11 @@
 		/*       fork one daemon per copy? */
 	}
 
+	/*
+	 * Process one specific task or all incomplete tasks?
+	 */
 	if (name) {
-		if (!_wait_for_single_mirror(cmd, name, uuid, &parms)) {
+		if (!_wait_for_single_lv(cmd, name, uuid, &parms)) {
 			stack;
 			return ECMD_FAILED;
 		}
--- LVM2/tools/polldaemon.h	2009/06/01 14:43:28	1.8
+++ LVM2/tools/polldaemon.h	2009/09/29 19:35:26	1.9
@@ -19,7 +19,7 @@
 #include "metadata-exported.h"
 
 struct poll_functions {
-	const char *(*get_copy_name_from_lv) (struct logical_volume *lv_mirr);
+	const char *(*get_copy_name_from_lv) (struct logical_volume *lv);
 	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
 					     const char *name,
 					     const char *uuid);
@@ -30,11 +30,11 @@
 					       uint32_t lv_type);
 	int (*update_metadata) (struct cmd_context *cmd,
 				struct volume_group *vg,
-				struct logical_volume *lv_mirr,
+				struct logical_volume *lv,
 				struct dm_list *lvs_changed, unsigned flags);
 	int (*finish_copy) (struct cmd_context *cmd,
 			    struct volume_group *vg,
-			    struct logical_volume *lv_mirr,
+			    struct logical_volume *lv,
 			    struct dm_list *lvs_changed);
 };
 



From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 29 Sep 2009 11:22:54 -0400
Subject: [PATCH 1/4] Rename the polldaemon's mirror-specific names
In-Reply-To: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
References: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
Message-ID: <1254237777-30501-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Just drop "mirror" or "mirr" part of names in polldaemon. The polldaemon will
also be used for polling snapshot merging, so naming the arguments with
"mirror" is misleading.

This patch does nothing but change variable and function names.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reviewed-by: Mike Snitzer <snitzer@redhat.com>

---
 tools/polldaemon.c |   57 ++++++++++++++++++++++++++---------------------------
 tools/polldaemon.h |    6 ++---
 2 files changed, 31 insertions(+), 32 deletions(-)

Index: lvm2/tools/polldaemon.c
===================================================================
--- lvm2.orig/tools/polldaemon.c
+++ lvm2/tools/polldaemon.c
@@ -63,11 +63,11 @@ static int _become_daemon(struct cmd_con
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
@@ -78,22 +78,22 @@ static int _check_mirror_status(struct c
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
 
-	if (!(status = lv_mirror_percent(cmd, lv_mirr, !parms->interval,
+	if (!(status = lv_mirror_percent(cmd, lv, !parms->interval,
 					 &segment_percent, &event_nr))) {
 		log_error("ABORTING: Mirror percentage check failed.");
 		return 0;
 	}
 
-	overall_status = copy_percent(lv_mirr, &overall_percent);
+	overall_status = copy_percent(lv, &overall_percent);
 	if (parms->progress_display)
 		log_print("%s: %s: %.1f%%", name, parms->progress_title,
 			  overall_percent);
@@ -107,22 +107,20 @@ static int _check_mirror_status(struct c
 		return 1;
 	}
 
-	if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
+	if (!(lvs_changed = lvs_using_lv(cmd, vg, lv))) {
 		log_error("ABORTING: Failed to generate list of copied LVs");
 		return 0;
 	}
 
 	/* Finished? Or progress to next segment? */
 	if (overall_status == TARGET_STATUS_FINISHED) {
-		if (!parms->poll_fns->finish_copy(cmd, vg, lv_mirr,
-						  lvs_changed))
+		if (!parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed))
 			return 0;
 	} else {
-		if (!parms->poll_fns->update_metadata(cmd, vg, lv_mirr,
+		if (!parms->poll_fns->update_metadata(cmd, vg, lv,
 						      lvs_changed, 0)) {
 			log_error("ABORTING: Segment progression failed.");
-			parms->poll_fns->finish_copy(cmd, vg, lv_mirr,
-						     lvs_changed);
+			parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed);
 			return 0;
 		}
 		*finished = 0;	/* Another segment */
@@ -131,11 +129,11 @@ static int _check_mirror_status(struct c
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
 
 	/* Poll for mirror completion */
@@ -157,16 +155,15 @@ static int _wait_for_single_mirror(struc
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
@@ -182,20 +179,20 @@ static int _poll_vg(struct cmd_context *
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
+		if (_check_lv_status(cmd, vg, lv, name,
+				     parms, &finished) && !finished)
 			parms->outstanding_count++;
 	}
 
@@ -251,12 +248,14 @@ int poll_daemon(struct cmd_context *cmd,
 	}
 
 	if (name) {
-		if (!_wait_for_single_mirror(cmd, name, uuid, &parms)) {
+		if (!_wait_for_single_lv(cmd, name, uuid, &parms)) {
 			stack;
 			return ECMD_FAILED;
 		}
-	} else
+	} else {
+		/* Only used for pvmove --abort */
 		_poll_for_all_vgs(cmd, &parms);
+	}
 
 	return ECMD_PROCESSED;
 }
Index: lvm2/tools/polldaemon.h
===================================================================
--- lvm2.orig/tools/polldaemon.h
+++ lvm2/tools/polldaemon.h
@@ -19,7 +19,7 @@
 #include "metadata-exported.h"
 
 struct poll_functions {
-	const char *(*get_copy_name_from_lv) (struct logical_volume *lv_mirr);
+	const char *(*get_copy_name_from_lv) (struct logical_volume *lv);
 	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
 					     const char *name,
 					     const char *uuid);
@@ -30,11 +30,11 @@ struct poll_functions {
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
 



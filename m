From: Milan Broz <mbroz@redhat.com>
Date: Sat, 23 Jan 2010 21:58:48 +0100
Subject: [PATCH 6/6] Fix pvmove abort when temporary mirror fails to be cluster-aware.
In-Reply-To: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
References: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
Message-ID: <1264280328-8728-6-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When activation of pvmove mirror fails on cluster, some nodes
still possibly succeeded in activation.

 - Explicitly deactivate that mirror to be sure
 - properly pair suspend/resume calls to not cause memory lock problems in clvmd

Code cannot simply call _finish_pvmove on cluster in this situation, because
changed LVs are suspended twice (causing memory inbalance) and also temporary
mirror is activated when it is not expected (and we know that it failed already).

Patch prepares special fucntion which remove temporary mirror references from
metadata and then resumes changed LVs.
---
 tools/pvmove.c |   51 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 35 insertions(+), 16 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index a286db1..7ff94ff 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -284,9 +284,26 @@ static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
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
@@ -344,9 +361,21 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
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
@@ -487,22 +516,12 @@ static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
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
-- 
1.6.6



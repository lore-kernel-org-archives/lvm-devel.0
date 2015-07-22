From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 22 Jul 2015 17:29:55 +0000 (UTC)
Subject: master - lvconvert: merge polling fixes for lockd
Message-ID: <20150722172955.CA6F1617DD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=27e6aee3904d195de658505b3bacc65601344d46
Commit:        27e6aee3904d195de658505b3bacc65601344d46
Parent:        8bfcefe11a2ce594d1f6e8ef5a1b17e80786ceab
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 22 11:42:57 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 22 12:28:06 2015 -0500

lvconvert: merge polling fixes for lockd

. the poll check will eventually call finish which will
  write the VG, so an ex VG lock is needed from lvmlockd.

. fix missing unlock on poll error path

. remove the lockd locking while monitoring the progress
  of the command, as suggested by the earlier FIXME comment,
  as it's not needed.
---
 tools/lvconvert.c  |   10 +------
 tools/polldaemon.c |   61 +++++++++++++++++++++++++++++-----------------------
 2 files changed, 36 insertions(+), 35 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0c5e2bd..6a0e0ca 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3410,10 +3410,7 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 		cmd->handles_missing_pvs = 1;
 	}
 
-	/*
-	 * The VG lock will be released when the command exits.
-	 * Commands that poll the LV will reacquire the VG lock.
-	 */
+	/* Unlock on error paths not required, it's automatic when command exits. */
 	if (!lockd_vg(cmd, lp->vg_name, "ex", 0, &lockd_state))
 		goto_out;
 
@@ -3461,10 +3458,7 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 bad:
 	unlock_vg(cmd, lp->vg_name);
 
-	/*
-	 * The command may sit and monitor progress for some time,
-	 * and we do not need or want the VG lock held during that.
-	 */
+	/* Unlock here so it's not held during polling. */
 	lockd_vg(cmd, lp->vg_name, "un", 0, &lockd_state);
 
 	release_vg(vg);
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index bbe4641..4527efb 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -136,17 +136,22 @@ static void _sleep_and_rescan_devices(struct daemon_parms *parms)
 int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		       struct daemon_parms *parms)
 {
-	struct volume_group *vg;
+	struct volume_group *vg = NULL;
 	struct logical_volume *lv;
 	int finished = 0;
 	uint32_t lockd_state = 0;
+	int ret;
 
 	/* Poll for completion */
 	while (!finished) {
 		if (parms->wait_before_testing)
 			_sleep_and_rescan_devices(parms);
 
-		if (!lockd_vg(cmd, id->vg_name, "sh", 0, &lockd_state)) {
+		/*
+		 * An ex VG lock is needed because the check can call finish_copy
+		 * which writes the VG.
+		 */
+		if (!lockd_vg(cmd, id->vg_name, "ex", 0, &lockd_state)) {
 			log_error("ABORTING: Can't lock VG for %s.", id->display_name);
 			return 0;
 		}
@@ -154,10 +159,12 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		/* Locks the (possibly renamed) VG again */
 		vg = vg_read(cmd, id->vg_name, NULL, READ_FOR_UPDATE, lockd_state);
 		if (vg_read_error(vg)) {
-			release_vg(vg);
-			log_error("ABORTING: Can't reread VG for %s.", id->display_name);
 			/* What more could we do here? */
-			return 0;
+			log_error("ABORTING: Can't reread VG for %s.", id->display_name);
+			release_vg(vg);
+			vg = NULL;
+			ret = 0;
+			goto out;
 		}
 
 		lv = find_lv(vg, id->lv_name);
@@ -174,9 +181,8 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 			else
 				log_print_unless_silent("Can't find LV in %s for %s.",
 							vg->name, id->display_name);
-
-			unlock_and_release_vg(cmd, vg, vg->name);
-			return 1;
+			ret = 1;
+			goto out;
 		}
 
 		/*
@@ -185,13 +191,13 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		 */
 		if (!lv_is_active_locally(lv)) {
 			log_print_unless_silent("%s: Interrupted: No longer active.", id->display_name);
-			unlock_and_release_vg(cmd, vg, vg->name);
-			return 1;
+			ret = 1;
+			goto out;
 		}
 
 		if (!_check_lv_status(cmd, vg, lv, id->display_name, parms, &finished)) {
-			unlock_and_release_vg(cmd, vg, vg->name);
-			return_0;
+			ret = 0;
+			goto_out;
 		}
 
 		unlock_and_release_vg(cmd, vg, vg->name);
@@ -215,6 +221,12 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 	}
 
 	return 1;
+
+out:
+	if (vg)
+		unlock_and_release_vg(cmd, vg, vg->name);
+	lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state);
+	return ret;
 }
 
 struct poll_id_list {
@@ -373,21 +385,17 @@ static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id
 	int ret;
 
 	/*
-	 * FIXME: we don't really need to take the vg lock here,
-	 * because we only report the progress on the same host
-	 * where the pvmove/lvconvert is happening.  This means
-	 * that the local pvmove/lvconvert/lvpoll commands are
-	 * updating the local lvmetad with the latest info they
-	 * have, and we just need to read the latest info that
-	 * they have put into lvmetad about their progress.
-	 * No VG lock is needed to protect anything here
-	 * (we're just reading the VG), and no VG lock is
-	 * needed to force a VG read from disk to get changes
-	 * from other hosts, because the only change to the VG
-	 * we're interested in is the change done locally.
+	 * It's reasonable to expect a lockd_vg("sh") here, but it should
+	 * not actually be needed, because we only report the progress on
+	 * the same host where the pvmove/lvconvert is happening.  This means
+	 * that the local pvmove/lvconvert/lvpoll commands are updating the
+	 * local lvmetad with the latest info they have, and we just need to
+	 * read the latest info that they have put into lvmetad about their
+	 * progress.  No VG lock is needed to protect anything here (we're
+	 * just reading the VG), and no VG lock is needed to force a VG read
+	 * from disk to get changes from other hosts, because the only change
+	 * to the VG we're interested in is the change done locally.
 	 */
-	if (!lockd_vg(cmd, id->vg_name, "sh", 0, &lockd_state))
-		return 0;
 
 	vg = vg_read(cmd, id->vg_name, NULL, 0, lockd_state);
 	if (vg_read_error(vg)) {
@@ -431,7 +439,6 @@ static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id
 out:
 	unlock_and_release_vg(cmd, vg, vg->name);
 out_ret:
-	lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state);
 	return ret;
 }
 



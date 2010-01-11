From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 11 Jan 2010 09:41:08 -0500
Subject: [RFC][PATCH] exit backgrounded polldaemon on completion
Message-ID: <20100111144107.GA9999@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the polldaemon is executed in the background (the child) it will go
on to duplicate the work that poll_daemon() caller (the parent) already
performed.  So for example, "vgchange -ay" will spawn backgrounded
polldaemons that will complete and then go on to spawn additional
polldaemon(s) because it duplicates the parent's "vgchange -ay" work.
The backgrounded polldaemon should exit() on completion.

This is an RFC because if the backgrounded polldaemon is made to exit()
there is some log noise about memory leaks (from memory the child
inherited from the parent, more specific in patch below).  In that we
exit() the leaks aren't a huge probloem; but the user won't know that.

Cleaning up such memory (vg->vgmem) would require specialized calls to
vg_release() from _become_daemon() -- which doesn't have access to the
vg.  So this would seem to warrant further discussion.

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index b4d6ebb..32fe4b0 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -238,6 +238,7 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 		const char *progress_title)
 {
 	struct daemon_parms parms;
+	int ret = ECMD_PROCESSED;
 
 	parms.aborting = arg_is_set(cmd, abort_ARG);
 	parms.background = background;
@@ -273,10 +274,27 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 	if (name) {
 		if (!_wait_for_single_lv(cmd, name, uuid, &parms)) {
 			stack;
-			return ECMD_FAILED;
+			ret = ECMD_FAILED;
 		}
 	} else
 		_poll_for_all_vgs(cmd, &parms);
 
-	return ECMD_PROCESSED;
+	if (parms.background) {
+		/*
+		 * background polldaemon must not return to the caller
+		 * because it will redundantly continue performing the
+		 * caller's task (that the parent already performed)
+		 */
+		fin_locking();
+		dm_pool_empty(cmd->mem);
+		lvm_fin(cmd);
+		/*
+		 * FIXME child's memory that was inherited from parent
+		 * (e.g. "lvm2 vg_read" mempool) will leak on exit;
+		 * other than the log_error() noise do we care?
+		 */
+		exit(ret == ECMD_PROCESSED ? 0 : ret);
+	}
+
+	return ret;
 }



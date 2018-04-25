From: David Teigland <teigland@sourceware.org>
Date: Wed, 25 Apr 2018 17:51:29 -0400
Subject: master - pvmove: in fork mode destroy bcache in child
Message-ID: <201804252151.w3PLpTDl018012@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c7fdacbc5001f3bdfaa441fedb7da120af5d8af9
Commit:        c7fdacbc5001f3bdfaa441fedb7da120af5d8af9
Parent:        0fe4f65f65faf9c61017bb14e281108b41165185
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 25 16:23:55 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 25 16:40:36 2018 -0500

pvmove: in fork mode destroy bcache in child

When pvmove was run in background mode and forks
instead of using lvmpolld, the child pvmove process
was not clearing the bcache from the parent, so all
the aio ops in the child were failing.
---
 tools/polldaemon.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 83f0424..5b5f57f 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -377,8 +377,6 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 		process_each_vg(cmd, 0, NULL, NULL, NULL, READ_FOR_UPDATE, 0, handle, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
-		if (parms->interval)
-			dev_close_all();
 		_nanosleep(parms->interval, 1);
 	}
 }
@@ -618,6 +616,12 @@ static int _poll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
 	/*
 	 * Process one specific task or all incomplete tasks?
 	 */
+
+	/* clear lvmcache/bcache/fds from the parent */
+	lvmcache_destroy(cmd, 1, 0);
+	label_scan_destroy(cmd);
+	dev_close_all();
+
 	if (id) {
 		if (!wait_for_single_lv(cmd, id, parms)) {
 			stack;
@@ -626,6 +630,7 @@ static int _poll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
 	} else {
 		if (!parms->interval)
 			parms->interval = find_config_tree_int(cmd, activation_polling_interval_CFG, NULL);
+
 		if (!(handle = init_processing_handle(cmd, NULL))) {
 			log_error("Failed to initialize processing handle.");
 			ret = ECMD_FAILED;



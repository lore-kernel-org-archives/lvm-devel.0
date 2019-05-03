From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 May 2019 17:36:44 -0400
Subject: master - pvs: remove unnecessary label scan
Message-ID: <201905032136.x43LaiTW029164@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3405ead1e09aa6916cd5ac84ae629c13991e6ec5
Commit:        3405ead1e09aa6916cd5ac84ae629c13991e6ec5
Parent:        6ff1583c1ba58d045fb5c8a198698e0d13f1acee
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 3 16:12:43 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 3 16:16:29 2019 -0500

pvs: remove unnecessary label scan

The scanning rework missed removing this instance of label scan.
It's no longer needed because of the way that label scan is always
run once from the start of the command.  This unnecessary scan
would be triggered by running 'pvs @tag'.
---
 tools/reporter.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 48050ec..db982b3 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -708,7 +708,6 @@ int report_for_selection(struct cmd_context *cmd,
 static void _check_pv_list(struct cmd_context *cmd, struct report_args *args, struct single_report_args *single_args)
 {
 	int i;
-	int rescan_done = 0;
 
 	if (!args->argv)
 		return;
@@ -719,12 +718,6 @@ static void _check_pv_list(struct cmd_context *cmd, struct report_args *args, st
 
 	if (single_args->args_are_pvs && args->argc) {
 		for (i = 0; i < args->argc; i++) {
-			if (!rescan_done && !dev_cache_get(cmd, args->argv[i], cmd->filter)) {
-				cmd->filter->wipe(cmd->filter);
-				/* FIXME scan only one device */
-				lvmcache_label_scan(cmd);
-				rescan_done = 1;
-			}
 			if (*args->argv[i] == '@') {
 				/*
 				 * Tags are metadata related, not label
@@ -732,13 +725,7 @@ static void _check_pv_list(struct cmd_context *cmd, struct report_args *args, st
 				 */
 				if (single_args->report_type == LABEL)
 					single_args->report_type = PVS;
-				/*
-				 * If we changed the report_type and we did rescan,
-				 * no need to iterate over dev list further - nothing
-				 * else would change.
-				 */
-				if (rescan_done)
-					break;
+				break;
 			}
 		}
 	}



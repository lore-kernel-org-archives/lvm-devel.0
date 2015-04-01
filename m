From: okozina <okozina@fedoraproject.org>
Date: Wed,  1 Apr 2015 18:42:59 +0000 (UTC)
Subject: master - polldaemon: alter few lines related to interval
Message-ID: <20150401184259.861B860CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f199aeb9eaa1821811f98308565ccc54ab52edf8
Commit:        f199aeb9eaa1821811f98308565ccc54ab52edf8
Parent:        7abb7894e4143021b003aaa906aa1945dcb59f06
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Mar 17 18:44:25 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Apr 1 20:41:52 2015 +0200

polldaemon: alter few lines related to interval

we do not allow 0 interval for pvmove command issued
without parameters with classical polldaemon. It would
query the kernel too often with possibly many pvmoves
in-progress.
---
 tools/polldaemon.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 466cfc6..6cdcbbb 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -282,14 +282,6 @@ static int _poll_daemon(struct cmd_context *cmd, const char *name,
 	int daemon_mode = 0;
 	int ret = ECMD_PROCESSED;
 
-	if (!parms->interval) {
-		parms->progress_display = 0;
-
-		/* FIXME Disabled multiple-copy wait_event */
-		if (!name)
-			parms->interval = find_config_tree_int(cmd, activation_polling_interval_CFG, NULL);
-	}
-
 	if (parms->background) {
 		daemon_mode = become_daemon(cmd, 0);
 		if (daemon_mode == 0)
@@ -309,6 +301,8 @@ static int _poll_daemon(struct cmd_context *cmd, const char *name,
 			ret = ECMD_FAILED;
 		}
 	} else {
+		if (!parms->interval)
+			parms->interval = find_config_tree_int(cmd, activation_polling_interval_CFG, NULL);
 		if (!(handle = init_processing_handle(cmd))) {
 			log_error("Failed to initialize processing handle.");
 			ret = ECMD_FAILED;
@@ -350,7 +344,6 @@ static int _daemon_parms_init(struct cmd_context *cmd, struct daemon_parms *parm
 	parms->interval = arg_uint_value(cmd, interval_ARG,
 					 find_config_tree_int(cmd, activation_polling_interval_CFG, NULL));
 	parms->wait_before_testing = (interval_sign == SIGN_PLUS);
-	parms->progress_display = 1;
 	parms->progress_title = progress_title;
 	parms->lv_type = lv_type;
 	parms->poll_fns = poll_fns;
@@ -360,6 +353,8 @@ static int _daemon_parms_init(struct cmd_context *cmd, struct daemon_parms *parm
 			    (parms->wait_before_testing ? "after" : "before"),
 			    parms->interval);
 
+	parms->progress_display = parms->interval ? 1 : 0;
+
 	return 1;
 }
 



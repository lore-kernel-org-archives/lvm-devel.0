From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:31 +0000 (UTC)
Subject: master - lvpoll.c: replace arg_count with arg_is_set
Message-ID: <20150515183731.91E3560E34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba120640b2db0acf166d60046cd3b0afdf7774b0
Commit:        ba120640b2db0acf166d60046cd3b0afdf7774b0
Parent:        0d15217a6c08d99314324469f42ad9b8cd0baccc
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 15 16:45:02 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:33:04 2015 +0200

lvpoll.c: replace arg_count with arg_is_set

didn't need to count the occurence but check if set
---
 tools/lvpoll.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvpoll.c b/tools/lvpoll.c
index 6db0ade..945e5d1 100644
--- a/tools/lvpoll.c
+++ b/tools/lvpoll.c
@@ -52,7 +52,7 @@ static int _set_daemon_parms(struct cmd_context *cmd, struct daemon_parms *parms
 	const char *poll_oper = arg_str_value(cmd, polloperation_ARG, "");
 
 	parms->interval = arg_uint_value(cmd, interval_ARG, 0);
-	parms->aborting = arg_count(cmd, abort_ARG);
+	parms->aborting = arg_is_set(cmd, abort_ARG);
 	parms->progress_display = 1;
 	parms->wait_before_testing = (arg_sign_value(cmd, interval_ARG, SIGN_NONE) == SIGN_PLUS);
 
@@ -74,7 +74,7 @@ static int _set_daemon_parms(struct cmd_context *cmd, struct daemon_parms *parms
 		return 0;
 	}
 
-	cmd->handles_missing_pvs = arg_count(cmd, handlemissingpvs_ARG);
+	cmd->handles_missing_pvs = arg_is_set(cmd, handlemissingpvs_ARG);
 
 	return 1;
 }
@@ -96,7 +96,7 @@ static int poll_lv(struct cmd_context *cmd, const char *lv_name)
 
 int lvpoll(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (!arg_count(cmd, polloperation_ARG)) {
+	if (!arg_is_set(cmd, polloperation_ARG)) {
 		log_error("--polloperation parameter is mandatory");
 		return EINVALID_CMD_LINE;
 	}



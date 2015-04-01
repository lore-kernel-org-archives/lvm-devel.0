From: okozina <okozina@fedoraproject.org>
Date: Wed,  1 Apr 2015 18:42:57 +0000 (UTC)
Subject: master - polldaemon: separate daemon_parms initialisation
Message-ID: <20150401184257.635C360CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7abb7894e4143021b003aaa906aa1945dcb59f06
Commit:        7abb7894e4143021b003aaa906aa1945dcb59f06
Parent:        3929b00466c3c415a8e82e8346d79ec6c5c0eb76
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Mar 17 18:40:43 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Apr 1 20:41:39 2015 +0200

polldaemon: separate daemon_parms initialisation

---
 tools/polldaemon.c |   78 +++++++++++++++++++++++++++++----------------------
 1 files changed, 44 insertions(+), 34 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index dd53055..466cfc6 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -276,50 +276,26 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
  *   if it was requested.
  */
 static int _poll_daemon(struct cmd_context *cmd, const char *name,
-			const char *uuid, unsigned background, uint64_t lv_type,
-			struct poll_functions *poll_fns,
-			const char *progress_title)
+			const char *uuid, struct daemon_parms *parms)
 {
 	struct processing_handle *handle = NULL;
-	struct daemon_parms parms;
 	int daemon_mode = 0;
 	int ret = ECMD_PROCESSED;
-	sign_t interval_sign;
 
-	parms.aborting = arg_is_set(cmd, abort_ARG);
-	parms.background = background;
-	interval_sign = arg_sign_value(cmd, interval_ARG, SIGN_NONE);
-	if (interval_sign == SIGN_MINUS) {
-		log_error("Argument to --interval cannot be negative");
-		return EINVALID_CMD_LINE;
-	}
-	parms.interval = arg_uint_value(cmd, interval_ARG,
-					find_config_tree_int(cmd, activation_polling_interval_CFG, NULL));
-	parms.wait_before_testing = (interval_sign == SIGN_PLUS);
-	parms.progress_display = 1;
-	parms.progress_title = progress_title;
-	parms.lv_type = lv_type;
-	parms.poll_fns = poll_fns;
-
-	if (parms.interval && !parms.aborting)
-		log_verbose("Checking progress %s waiting every %u seconds",
-			    (parms.wait_before_testing ? "after" : "before"),
-			    parms.interval);
-
-	if (!parms.interval) {
-		parms.progress_display = 0;
+	if (!parms->interval) {
+		parms->progress_display = 0;
 
 		/* FIXME Disabled multiple-copy wait_event */
 		if (!name)
-			parms.interval = find_config_tree_int(cmd, activation_polling_interval_CFG, NULL);
+			parms->interval = find_config_tree_int(cmd, activation_polling_interval_CFG, NULL);
 	}
 
-	if (parms.background) {
+	if (parms->background) {
 		daemon_mode = become_daemon(cmd, 0);
 		if (daemon_mode == 0)
 			return ECMD_PROCESSED;	    /* Parent */
 		else if (daemon_mode == 1)
-			parms.progress_display = 0; /* Child */
+			parms->progress_display = 0; /* Child */
 		/* FIXME Use wait_event (i.e. interval = 0) and */
 		/*       fork one daemon per copy? */
 	}
@@ -328,7 +304,7 @@ static int _poll_daemon(struct cmd_context *cmd, const char *name,
 	 * Process one specific task or all incomplete tasks?
 	 */
 	if (name) {
-		if (!_wait_for_single_lv(cmd, name, uuid, &parms)) {
+		if (!_wait_for_single_lv(cmd, name, uuid, parms)) {
 			stack;
 			ret = ECMD_FAILED;
 		}
@@ -337,12 +313,12 @@ static int _poll_daemon(struct cmd_context *cmd, const char *name,
 			log_error("Failed to initialize processing handle.");
 			ret = ECMD_FAILED;
 		} else {
-			handle->custom_handle = &parms;
+			handle->custom_handle = parms;
 			_poll_for_all_vgs(cmd, handle);
 		}
 	}
 
-	if (parms.background && daemon_mode == 1) {
+	if (parms->background && daemon_mode == 1) {
 		destroy_processing_handle(cmd, handle);
 		/*
 		 * child was successfully forked:
@@ -358,10 +334,44 @@ static int _poll_daemon(struct cmd_context *cmd, const char *name,
 	return ret;
 }
 
+static int _daemon_parms_init(struct cmd_context *cmd, struct daemon_parms *parms,
+			      unsigned background, struct poll_functions *poll_fns,
+			      const char *progress_title, uint64_t lv_type)
+{
+	sign_t interval_sign;
+
+	parms->aborting = arg_is_set(cmd, abort_ARG);
+	parms->background = background;
+	interval_sign = arg_sign_value(cmd, interval_ARG, SIGN_NONE);
+	if (interval_sign == SIGN_MINUS) {
+		log_error("Argument to --interval cannot be negative.");
+		return 0;
+	}
+	parms->interval = arg_uint_value(cmd, interval_ARG,
+					 find_config_tree_int(cmd, activation_polling_interval_CFG, NULL));
+	parms->wait_before_testing = (interval_sign == SIGN_PLUS);
+	parms->progress_display = 1;
+	parms->progress_title = progress_title;
+	parms->lv_type = lv_type;
+	parms->poll_fns = poll_fns;
+
+	if (parms->interval && !parms->aborting)
+		log_verbose("Checking progress %s waiting every %u seconds.",
+			    (parms->wait_before_testing ? "after" : "before"),
+			    parms->interval);
+
+	return 1;
+}
+
 int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 		unsigned background,
 		uint64_t lv_type, struct poll_functions *poll_fns,
 		const char *progress_title)
 {
-	return _poll_daemon(cmd, name, uuid, background, lv_type, poll_fns, progress_title);
+	struct daemon_parms parms;
+
+	if (!_daemon_parms_init(cmd, &parms, background, poll_fns, progress_title, lv_type))
+		return_EINVALID_CMD_LINE;
+
+	return _poll_daemon(cmd, name, uuid, &parms);
 }



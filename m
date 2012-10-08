From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  8 Oct 2012 12:40:47 +0000 (UTC)
Subject: master - lvmetad: In pvscan --cache, update the token directly.
Message-ID: <20121008124047.B5143151E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=582a344cd68d663917928edba3cc76510941322d
Commit:        582a344cd68d663917928edba3cc76510941322d
Parent:        40182cbd82430a127bfeac5d93f98e642c94e06b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 12:21:36 2012 +0200
Committer:     Petr Ro??kai <mornfall@b3.mornfall.net>
CommitterDate: Mon Oct 8 14:38:22 2012 +0200

lvmetad: In pvscan --cache, update the token directly.

---
 lib/cache/lvmetad.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 24a6b16..b5fdc54 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -102,7 +102,6 @@ static daemon_reply _lvmetad_send(const char *id, ...)
 	daemon_reply repl, token_set;
 	daemon_request req;
 	int try = 0;
-	char *future_token;
 
 retry:
 	req = daemon_request_make(id);
@@ -118,19 +117,13 @@ retry:
 
 	daemon_request_destroy(req);
 
-	if (!repl.error && !strcmp(daemon_reply_str(repl, "response", ""), "token_mismatch") && try < 2 && !test_mode()) {
-		future_token = _lvmetad_token;
-		_lvmetad_token = (char *) "update in progress";
-		if (!_token_update()) goto out;
-
+	if (!repl.error && !strcmp(daemon_reply_str(repl, "response", ""), "token_mismatch") &&
+	    try < 2 && !test_mode()) {
 		if (lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL)) {
-			_lvmetad_token = future_token;
-			if (!_token_update()) goto out;
+			++ try;
+			daemon_reply_destroy(repl);
+			goto retry;
 		}
-		_lvmetad_token = future_token;
-		++ try;
-		daemon_reply_destroy(repl);
-		goto retry;
 	}
 
 out:
@@ -858,22 +851,28 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 	struct device *dev;
 	daemon_reply reply;
 	int r = 1;
+	char *future_token;
 
 	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 1))) {
 		log_error("dev_iter creation failed");
 		return 0;
 	}
 
+	future_token = _lvmetad_token;
+	_lvmetad_token = (char *) "update in progress";
+	if (!_token_update()) {
+		_lvmetad_token = future_token;
+		return 0;
+	}
+
 	reply = _lvmetad_send("pv_clear_all", NULL);
 	if (!_lvmetad_handle_reply(reply, "clear status on all PVs", "", NULL))
 		r = 0;
 	daemon_reply_destroy(reply);
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!lvmetad_pvscan_single(cmd, dev, handler)) {
+		if (!lvmetad_pvscan_single(cmd, dev, handler))
 			r = 0;
-			break;
-		}
 
 		if (sigint_caught())
 			break;
@@ -881,6 +880,10 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 
 	dev_iter_destroy(iter);
 
+	_lvmetad_token = future_token;
+	if (!_token_update())
+		return 0;
+
 	return r;
 }
 



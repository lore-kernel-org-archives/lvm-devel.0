From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:56:01 +0000 (UTC)
Subject: master - lvmetad: Fix #845269: SEGV on corrupt lvmetad response.
Message-ID: <20120926175601.592FCA33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c731bb1ee13565763cc1ac77ed1a01ccea0337ac
Commit:        c731bb1ee13565763cc1ac77ed1a01ccea0337ac
Parent:        d2d66634282459438210f1f9ba7e2e4c910e13ba
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 19 23:30:16 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

lvmetad: Fix #845269: SEGV on corrupt lvmetad response.

---
 lib/cache/lvmetad.c              |    6 +++---
 libdaemon/client/daemon-client.c |    2 ++
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a7e3cd3..8ac5732 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -86,7 +86,7 @@ static int _token_update()
 {
 	daemon_reply repl = _lvmetad_send("token_update", NULL);
 
-	if (strcmp(daemon_reply_str(repl, "response", ""), "OK")) {
+	if (repl.error || strcmp(daemon_reply_str(repl, "response", ""), "OK")) {
 		daemon_reply_destroy(repl);
 		return 0;
 	}
@@ -118,7 +118,7 @@ retry:
 
 	daemon_request_destroy(req);
 
-	if (!strcmp(daemon_reply_str(repl, "response", ""), "token_mismatch") && try < 2 && !test_mode()) {
+	if (!repl.error && !strcmp(daemon_reply_str(repl, "response", ""), "token_mismatch") && try < 2 && !test_mode()) {
 		future_token = _lvmetad_token;
 		_lvmetad_token = (char *) "update in progress";
 		if (!_token_update()) goto out;
@@ -298,7 +298,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 		reply = _lvmetad_send("vg_lookup", "name = %s", vgname, NULL);
 	}
 
-	if (!strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+	if (!reply.error && !strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
 
 		if (!(top = dm_config_find_node(reply.cft->root, "metadata"))) {
 			log_error(INTERNAL_ERROR "metadata config node not found.");
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 0ade329..39b082f 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -81,6 +81,8 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 
 	if (read_buffer(h.socket_fd, &reply.buffer)) {
 		reply.cft = dm_config_from_string(reply.buffer);
+		if (!reply.cft)
+			reply.error = EPROTO;
 	} else
 		reply.error = errno;
 



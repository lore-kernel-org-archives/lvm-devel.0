From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  7 Jun 2016 15:18:00 +0000 (UTC)
Subject: master - lvmetad: define special update in progress string
Message-ID: <20160607151800.8C7F261EF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e7f352c70decb779508b038a22e87c8e3f58b61
Commit:        0e7f352c70decb779508b038a22e87c8e3f58b61
Parent:        7ae05adf462b8de4428f32600fb43583dce5009a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 19 16:19:38 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 7 10:17:00 2016 -0500

lvmetad: define special update in progress string

---
 daemons/lvmetad/lvmetad-client.h |    2 ++
 lib/cache/lvmetad.c              |   12 ++++++------
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-client.h b/daemons/lvmetad/lvmetad-client.h
index 1376e6b..47eb6b4 100644
--- a/daemons/lvmetad/lvmetad-client.h
+++ b/daemons/lvmetad/lvmetad-client.h
@@ -19,6 +19,8 @@
 
 #define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
 
+#define LVMETAD_TOKEN_UPDATE_IN_PROGRESS "update in progress"
+
 #define LVMETAD_DISABLE_REASON_DIRECT		"DIRECT"
 #define LVMETAD_DISABLE_REASON_LVM1		"LVM1"
 #define LVMETAD_DISABLE_REASON_DUPLICATES	"DUPLICATES"
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 6f914b2..a87c952 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -286,7 +286,7 @@ retry:
 	 * the update message so that callers could detect when a rescan has
 	 * stalled while updating lvmetad.
 	 */
-	if (!strcmp(daemon_token, "update in progress")) {
+	if (!strcmp(daemon_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS)) {
 		if (!(now = _monotonic_seconds()))
 			goto fail;
 
@@ -370,7 +370,7 @@ retry:
 	if (!(daemon_token = daemon_reply_str(reply, "token", NULL)))
 		goto out;
 
-	if (!strcmp(daemon_token, "update in progress")) {
+	if (!strcmp(daemon_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS)) {
 		ret = 1;
 
 		if (!do_wait)
@@ -441,7 +441,7 @@ retry:
 		goto out;
 
 	if (!strcmp(daemon_reply_str(reply, "response", ""), "token_mismatch")) {
-		if (!strcmp(daemon_reply_str(reply, "expected", ""), "update in progress")) {
+		if (!strcmp(daemon_reply_str(reply, "expected", ""), LVMETAD_TOKEN_UPDATE_IN_PROGRESS)) {
 			/*
 			 * Another command is updating the lvmetad cache, and
 			 * we cannot use lvmetad until the update is finished.
@@ -520,7 +520,7 @@ static int _token_update(int *replaced_update)
 	}
 
 	if ((prev_token = daemon_reply_str(reply, "prev_token", NULL))) {
-		if (!strcmp(prev_token, "update in progress"))
+		if (!strcmp(prev_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS))
 			if (replaced_update)
 				*replaced_update = 1;
 	}
@@ -583,7 +583,7 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char
 	 * See the description of the token mismatch errors in lvmetad_send.
 	 */
 	if (!strcmp(daemon_reply_str(reply, "response", ""), "token_mismatch")) {
-		if (!strcmp(daemon_reply_str(reply, "expected", ""), "update in progress")) {
+		if (!strcmp(daemon_reply_str(reply, "expected", ""), LVMETAD_TOKEN_UPDATE_IN_PROGRESS)) {
 			/*
 			 * lvmetad_send retried up to the limit and eventually
 			 * printed a warning and gave up.
@@ -1739,7 +1739,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 	}
 
 	future_token = _lvmetad_token;
-	_lvmetad_token = (char *) "update in progress";
+	_lvmetad_token = (char *) LVMETAD_TOKEN_UPDATE_IN_PROGRESS;
 
 	if (!_token_update(&replaced_update)) {
 		log_error("Failed to update lvmetad which had an update in progress.");



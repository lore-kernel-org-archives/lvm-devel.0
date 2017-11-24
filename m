From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:11:21 -0500
Subject: master - cleanup: reduce couple debug lines
Message-ID: <201711241511.vAOFBL3c000758@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=54741aeac5e45abbad26343776a6205dab85b0fb
Commit:        54741aeac5e45abbad26343776a6205dab85b0fb
Parent:        5e88d3a89b353ad4d286d453dcc24042b09efaf9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 17 00:01:45 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:09:59 2017 +0100

cleanup: reduce couple debug lines

---
 lib/cache/lvmetad.c |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 1fd9091..6755ed6 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -551,6 +551,7 @@ static int _token_update(int *replaced_update)
 	daemon_reply reply;
 	const char *token_expected;
 	const char *prev_token;
+	const char *reply_str;
 	int update_pid;
 	int ending_our_update;
 
@@ -567,13 +568,14 @@ static int _token_update(int *replaced_update)
 	}
 
 	update_pid = (int)daemon_reply_int(reply, "update_pid", 0);
+	reply_str = daemon_reply_str(reply, "response", "");
 
 	/*
 	 * A mismatch can only happen when this command attempts to set the
 	 * token to filter:<hash> at the end of its update, but the update has
 	 * been preempted in lvmetad by a new one (from update_pid).
 	 */
-	if (!strcmp(daemon_reply_str(reply, "response", ""), "token_mismatch")) {
+	if (!strcmp(reply_str, "token_mismatch")) {
 		token_expected = daemon_reply_str(reply, "expected", "");
 
 		ending_our_update = strcmp(_lvmetad_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
@@ -599,7 +601,7 @@ static int _token_update(int *replaced_update)
 		return 0;
 	}
 
-	if (strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+	if (strcmp(reply_str, "OK")) {
 		log_error("Failed response from lvmetad for token update.");
 		daemon_reply_destroy(reply);
 		return 0;
@@ -626,6 +628,7 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char
 {
 	const char *token_expected;
 	const char *action;
+	const char *reply_str;
 	int action_modifies = 0;
 	int daemon_in_update;
 	int we_are_in_update;
@@ -670,8 +673,8 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char
 	/*
 	 * Errors related to token mismatch.
 	 */
-
-	if (!strcmp(daemon_reply_str(reply, "response", ""), "token_mismatch")) {
+	reply_str = daemon_reply_str(reply, "response", "");
+	if (!strcmp(reply_str, "token_mismatch")) {
 
 		token_expected = daemon_reply_str(reply, "expected", "");
 		update_pid = (int)daemon_reply_int(reply, "update_pid", 0);
@@ -769,14 +772,14 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char
 	 */
 
 	/* All OK? */
-	if (!strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+	if (!strcmp(reply_str, "OK")) {
 		if (found)
 			*found = 1;
 		return 1;
 	}
 
 	/* Unknown device permitted? */
-	if (found && !strcmp(daemon_reply_str(reply, "response", ""), "unknown")) {
+	if (found && !strcmp(reply_str, "unknown")) {
 		log_very_verbose("Request to %s %s%sin lvmetad did not find any matching object.",
 				 action, object, *object ? " " : "");
 		*found = 0;
@@ -784,7 +787,7 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char
 	}
 
 	/* Multiple VGs with the same name were found. */
-	if (found && !strcmp(daemon_reply_str(reply, "response", ""), "multiple")) {
+	if (found && !strcmp(reply_str, "multiple")) {
 		log_very_verbose("Request to %s %s%sin lvmetad found multiple matching objects.",
 				 action, object, *object ? " " : "");
 		if (found)
@@ -1607,7 +1610,7 @@ int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct devi
 	struct dm_config_tree *pvmeta, *vgmeta;
 	const char *status = NULL, *vgname = NULL;
 	int64_t changed = 0;
-	int result;
+	int result, seqno_after;
 
 	if (!lvmetad_used() || test_mode())
 		return 1;
@@ -1672,10 +1675,12 @@ int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct devi
 
 	result = _lvmetad_handle_reply(reply, "pv_found", uuid, NULL);
 
-	if (vg && result &&
-	    (daemon_reply_int(reply, "seqno_after", -1) != vg->seqno ||
-	     daemon_reply_int(reply, "seqno_after", -1) != daemon_reply_int(reply, "seqno_before", -1)))
-		log_warn("WARNING: Inconsistent metadata found for VG %s", vg->name);
+	if (vg && result) {
+		seqno_after = daemon_reply_int(reply, "seqno_after", -1);
+		if ((seqno_after != vg->seqno) ||
+		    (seqno_after != daemon_reply_int(reply, "seqno_before", -1)))
+			log_warn("WARNING: Inconsistent metadata found for VG %s", vg->name);
+	}
 
 	if (result && found_vgnames) {
 		status = daemon_reply_str(reply, "status", NULL);



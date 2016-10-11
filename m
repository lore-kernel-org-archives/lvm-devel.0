From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Oct 2016 11:39:28 +0000 (UTC)
Subject: master - cleanup: reorder code
Message-ID: <20161011113928.13096602BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f4ae43934a02c5cb90845758804fc278f5fb0edb
Commit:        f4ae43934a02c5cb90845758804fc278f5fb0edb
Parent:        706d3ddf901584d182b5bab49f3d7d4b3476e807
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 11 11:56:15 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 11 13:37:43 2016 +0200

cleanup: reorder code

Move some arg test into a single place with sort of alphabetic order
when possible to make reading easier.
---
 tools/lvconvert.c |   63 +++++++++++++++++++++++++++-------------------------
 1 files changed, 33 insertions(+), 30 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 05bf51a..499ff1c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -451,6 +451,30 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	if (!_read_conversion_type(cmd, lp))
 		return_0;
 
+	if (!arg_is_set(cmd, background_ARG))
+		lp->wait_completion = 1;
+
+	if (arg_is_set(cmd, corelog_ARG))
+		lp->corelog = 1;
+
+	if (arg_is_set(cmd, mirrorlog_ARG)) {
+		if (lp->corelog) {
+			log_error("--mirrorlog and --corelog are incompatible.");
+			return 0;
+		}
+		lp->mirrorlog = 1;
+	}
+
+	if (arg_is_set(cmd, merge_ARG)) {
+		if (arg_outside_list_is_set(cmd, "cannot be used with --merge",
+					    merge_ARG,
+					    background_ARG, interval_ARG,
+					    force_ARG, noudevsync_ARG, test_ARG,
+					    -1))
+			return_0;
+		lp->merge = 1;
+	}
+
 	/* If --repair, check for incompatible args. */
 	if (arg_is_set(cmd, repair_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --repair",
@@ -462,15 +486,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->repair = 1;
 	}
 
-	if (arg_is_set(cmd, mirrorlog_ARG))
-		lp->mirrorlog = 1;
-	if (arg_is_set(cmd, corelog_ARG))
-		lp->corelog = 1;
-
-	if (lp->mirrorlog && lp->corelog) {
-		log_error("--mirrorlog and --corelog are incompatible.");
-		return 0;
-	}
+	if (arg_is_set(cmd, replace_ARG))
+		lp->replace = 1;
 
 	if (arg_is_set(cmd, split_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --split",
@@ -500,6 +517,9 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->splitsnapshot = 1;
 	}
 
+	if (arg_is_set(cmd, trackchanges_ARG))
+		lp->track_changes = 1;
+
 	if (arg_is_set(cmd, uncache_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --uncache",
 					    uncache_ARG,
@@ -538,11 +558,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	if (!_read_pool_params(cmd, &argc, &argv, lp))
 		return_0;
 
-	if (!arg_is_set(cmd, background_ARG))
-		lp->wait_completion = 1;
-
 	if (_snapshot_type_requested(cmd, lp->type_str)) {
-		if (arg_is_set(cmd, merge_ARG)) {
+		if (lp->merge) {
 			log_error("--snapshot and --merge are mutually exclusive.");
 			return 0;
 		}
@@ -550,9 +567,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->snapshot = 1;
 	}
 
-	if (arg_is_set(cmd, trackchanges_ARG))
-		lp->track_changes = 1;
-
 	if (lp->split) {
 		lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL);
 
@@ -589,12 +603,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		}
 	}
 
-	if (arg_is_set(cmd, merge_ARG))
-		lp->merge = 1;
-
-	if (arg_is_set(cmd, replace_ARG))
-		lp->replace = 1;
-
 	/* If no other case was identified, then use of --stripes means --type striped */
 	if (!arg_is_set(cmd, type_ARG) && !*lp->type_str && !lp->merge && !lp->splitsnapshot &&
 	    !lp->splitcache && !lp->split && !lp->snapshot && !lp->uncache && !lp->cache && !lp->thin &&
@@ -655,14 +663,9 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	 *   --type mirror|raid  lp->mirrorlog lp->corelog
 	 *   --type raid0|striped
 	 */
-	if (lp->merge) {	/* Snapshot or mirror merge */
-		if (arg_outside_list_is_set(cmd, "cannot be used with --merge",
-					    merge_ARG,
-					    background_ARG, interval_ARG,
-					    force_ARG, noudevsync_ARG, test_ARG,
-					    -1))
-			return_0;
-	} else if (lp->splitsnapshot)	/* Destroy snapshot retaining cow as separate LV */
+	if (lp->merge)			/* Snapshot or mirror merge */
+                ;
+	else if (lp->splitsnapshot)	/* Destroy snapshot retaining cow as separate LV */
 		;
 	else if (lp->splitcache)
 		;



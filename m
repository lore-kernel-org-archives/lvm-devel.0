From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 25 Jul 2016 18:33:15 +0000 (UTC)
Subject: master - lvconvert: --trackchanges requires --splitmirrors
Message-ID: <20160725183315.4A5BA60C57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1efb1c23432f504db685c4ff9f2c08a5ba74e68f
Commit:        1efb1c23432f504db685c4ff9f2c08a5ba74e68f
Parent:        7b1daa248ffdc473e016b9694c1f85a827334c89
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 25 19:32:10 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 25 19:32:10 2016 +0100

lvconvert: --trackchanges requires --splitmirrors

---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   39 ++++++++++++++++++++++++---------------
 2 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f5b8306..b80d189 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.162 - 
 =================================
+  Improve lvconvert --trackchanges validation to require --splitmirrors.
   Add note about lastlog built-in command to lvm man page.
   Fix unrecognised segtype flag message.
   lvconvert reuse cachepool metadade now ONLY with -Zn and clear otherwise.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c31a8a3..91765d6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -59,6 +59,8 @@ struct lvconvert_params {
 	int merge_snapshot;	/* merge is also set */
 	int merge_mirror;	/* merge is also set */
 
+	int track_changes;	/* keep_mimages is also set (--splitmirrors) */
+
 	int poolmetadataspare;
 	int force;
 	int yes;
@@ -77,7 +79,7 @@ struct lvconvert_params {
 
 	uint32_t mirrors;
 	sign_t mirrors_sign;
-	uint32_t keep_mimages;
+	uint32_t keep_mimages;	/* --splitmirrors */
 	uint32_t stripes;
 	uint32_t stripe_size;
 	uint32_t read_ahead;
@@ -335,7 +337,7 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 		    strcmp(lp->type_str, "cache") &&
 		    strcmp(lp->type_str, "cache-pool")) {
 			log_error("--cachepool argument is only valid with "
-				  " the cache or cache-pool segment type.");
+				  "the cache or cache-pool segment type.");
 			return 0;
 		}
 		cachepool = 1;
@@ -347,7 +349,7 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 		    strcmp(lp->type_str, "thin") &&
 		    strcmp(lp->type_str, "thin-pool")) {
 			log_error("--thinpool argument is only valid with "
-				  " the thin or thin-pool segment type.");
+				  "the thin or thin-pool segment type.");
 			return 0;
 		}
 		thinpool = 1;
@@ -542,6 +544,9 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->snapshot = 1;
 	}
 
+	if (arg_is_set(cmd, trackchanges_ARG))
+		lp->track_changes = 1;
+
 	if (lp->split) {
 		lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL);
 
@@ -557,8 +562,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 				  "mutually exclusive.");
 			return 0;
 		}
-		if (!arg_is_set(cmd, name_ARG) &&
-		    !arg_is_set(cmd, trackchanges_ARG)) {
+
+		if (!arg_is_set(cmd, name_ARG) && !lp->track_changes) {
 			log_error("Please name the new logical volume using '--name'");
 			return 0;
 		}
@@ -567,10 +572,15 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->keep_mimages = 1;
 		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);
 		lp->mirrors_sign = SIGN_MINUS;
-	} else if (arg_is_set(cmd, name_ARG)) {
-		log_error("The 'name' argument is only valid"
-			  " with --splitmirrors");
-		return 0;
+	} else {
+		if (lp->track_changes) {
+			log_error("--trackchanges is only valid with --splitmirrors.");
+			return 0;
+		}
+		if (arg_is_set(cmd, name_ARG)) {
+			log_error("The 'name' argument is only valid with --splitmirrors");
+			return 0;
+		}
 	}
 
 	if (arg_is_set(cmd, merge_ARG))
@@ -1504,7 +1514,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 
 		/* Reduce number of mirrors */
 		if (lp->keep_mimages) {
-			if (arg_is_set(cmd, trackchanges_ARG)) {
+			if (lp->track_changes) {
 				log_error("--trackchanges is not available "
 					  "to 'mirror' segment type.");
 				return 0;
@@ -1889,7 +1899,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (lp->merge_mirror)
 		return lv_raid_merge(lv);
 
-	if (arg_is_set(cmd, trackchanges_ARG))
+	if (lp->track_changes)
 		return lv_raid_split_and_track(lv, lp->pvh);
 
 	if (lp->keep_mimages)
@@ -1933,8 +1943,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		}
 
 		if (sync_percent != DM_PERCENT_100) {
-			log_warn("WARNING: %s is not in-sync.",
-				 display_lvname(lv));
+			log_warn("WARNING: %s is not in-sync.", display_lvname(lv));
 			log_warn("WARNING: Portions of the array may be unrecoverable.");
 
 			/*
@@ -1957,8 +1966,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 				return 0;
 			}
 
-			log_print_unless_silent("Faulty devices in %s successfully"
-						" replaced.", display_lvname(lv));
+			log_print_unless_silent("Faulty devices in %s successfully replaced.",
+						display_lvname(lv));
 			return 1;
 		}
 



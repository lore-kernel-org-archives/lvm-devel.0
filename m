From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:36:25 +0000 (UTC)
Subject: master - lvconvert: use lp->repair
Message-ID: <20160225223625.E720B60C5C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cdcf4cc794827e61a1babd549f4a0ef4e6439165
Commit:        cdcf4cc794827e61a1babd549f4a0ef4e6439165
Parent:        ec8a75a321fa96fd0fff6bf68e00599288c21ec4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 15:12:17 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 25 23:30:25 2016 +0100

lvconvert: use lp->repair

Set variable for repair testing.
---
 tools/lvconvert.c |   43 ++++++++++++++++++++++---------------------
 1 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 10ee775..23f3cf4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -28,6 +28,7 @@ struct lvconvert_params {
 	int merge;
 	int merge_mirror;
 	int poolmetadataspare;
+	int repair;
 	int thin;
 	int uncache;
 	int yes;
@@ -194,7 +195,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		lp->lv_name = lp->lv_name_full;
 
 	if (!lp->merge_mirror &&
-	    !arg_count(cmd, repair_ARG) &&
+	    !lp->repair &&
 	    !arg_count(cmd, splitmirrors_ARG) &&
 	    !strstr(lp->lv_name, "_tdata") &&
 	    !strstr(lp->lv_name, "_tmeta") &&
@@ -383,14 +384,16 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	if (!_check_conversion_type(cmd, type_str))
 		return_0;
 
-	if (arg_count(cmd, repair_ARG) &&
-	    arg_outside_list_is_set(cmd, "cannot be used with --repair",
-				    repair_ARG,
-				    alloc_ARG, usepolicies_ARG,
-				    stripes_long_ARG, stripesize_ARG,
-				    force_ARG, noudevsync_ARG, test_ARG,
-				    -1))
-		return_0;
+	if (arg_count(cmd, repair_ARG)) {
+		if (arg_outside_list_is_set(cmd, "cannot be used with --repair",
+					    repair_ARG,
+					    alloc_ARG, usepolicies_ARG,
+					    stripes_long_ARG, stripesize_ARG,
+					    force_ARG, noudevsync_ARG, test_ARG,
+					    -1))
+			return_0;
+		lp->repair = 1;
+	}
 
 	if (arg_is_set(cmd, mirrorlog_ARG) && arg_is_set(cmd, corelog_ARG)) {
 		log_error("--mirrorlog and --corelog are incompatible.");
@@ -436,7 +439,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 	if ((_snapshot_type_requested(cmd, type_str) || arg_count(cmd, merge_ARG)) &&
 	    (arg_count(cmd, mirrorlog_ARG) || _mirror_or_raid_type_requested(cmd, type_str) ||
-	     arg_count(cmd, repair_ARG) || arg_count(cmd, thinpool_ARG))) {
+	     lp->repair || arg_count(cmd, thinpool_ARG))) {
 		log_error("--snapshot/--type snapshot or --merge argument "
 			  "cannot be mixed with --mirrors/--type mirror/--type raid*, "
 			  "--mirrorlog, --repair or --thinpool.");
@@ -445,7 +448,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 	if ((arg_count(cmd, stripes_long_ARG) || arg_count(cmd, stripesize_ARG)) &&
 	    !(_mirror_or_raid_type_requested(cmd, type_str) ||
-	      arg_count(cmd, repair_ARG) ||
+	      lp->repair ||
 	      arg_count(cmd, thinpool_ARG))) {
 		log_error("--stripes or --stripesize argument is only valid "
 			  "with --mirrors/--type mirror/--type raid*, --repair and --thinpool");
@@ -1143,7 +1146,6 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 					   uint32_t *new_mimage_count,
 					   uint32_t *new_log_count)
 {
-	int repair = arg_count(cmd, repair_ARG);
 	*old_mimage_count = lv_mirror_count(lv);
 	*old_log_count = _get_log_count(lv);
 
@@ -1160,7 +1162,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	 */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
 	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
-	    !arg_count(cmd, splitmirrors_ARG) && !repair) {
+	    !arg_count(cmd, splitmirrors_ARG) && !lp->repair) {
 		*new_mimage_count = *old_mimage_count;
 		*new_log_count = *old_log_count;
 
@@ -1605,7 +1607,6 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 			      struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
-	int repair = arg_count(cmd, repair_ARG);
 	uint32_t old_mimage_count;
 	uint32_t old_log_count;
 	uint32_t new_mimage_count;
@@ -1651,10 +1652,10 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 
 	/* Nothing to do?  (Probably finishing collapse.) */
 	if ((old_mimage_count == new_mimage_count) &&
-	    (old_log_count == new_log_count) && !repair)
+	    (old_log_count == new_log_count) && !lp->repair)
 		return 1;
 
-	if (repair)
+	if (lp->repair)
 		return _lvconvert_mirrors_repair(cmd, lv, lp);
 
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
@@ -1778,7 +1779,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (arg_count(cmd, replace_ARG))
 		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
 
-	if (arg_count(cmd, repair_ARG)) {
+	if (lp->repair) {
 		if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
 			log_error("%s/%s must be active %sto perform this"
 				  " operation.", lv->vg->name, lv->name,
@@ -3277,7 +3278,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (arg_count(cmd, repair_ARG)) {
+	if (lp->repair) {
 		if (lv_is_pool(lv)) {
 			if (lv_is_cache_pool(lv)) {
 				log_error("Repair for cache pool %s not yet implemented.",
@@ -3350,7 +3351,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_ECMD_FAILED;
 
 		/* If repairing and using policies, remove missing PVs from VG */
-		if (arg_count(cmd, repair_ARG) && arg_count(cmd, usepolicies_ARG))
+		if (lp->repair && arg_count(cmd, usepolicies_ARG))
 			_remove_missing_empty_pv(lv->vg, failed_pvs);
 	} else if (arg_count(cmd, mirrors_ARG) ||
 		   arg_count(cmd, splitmirrors_ARG) ||
@@ -3365,7 +3366,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_ECMD_FAILED;
 
 		/* If repairing and using policies, remove missing PVs from VG */
-		if (arg_count(cmd, repair_ARG) && arg_count(cmd, usepolicies_ARG))
+		if (lp->repair && arg_count(cmd, usepolicies_ARG))
 			_remove_missing_empty_pv(lv->vg, failed_pvs);
 	}
 
@@ -3425,7 +3426,7 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
 	uint32_t lockd_state = 0;
 
-	if (arg_count(cmd, repair_ARG)) {
+	if (lp->repair) {
 		init_ignore_suspended_devices(1);
 		cmd->handles_missing_pvs = 1;
 	}



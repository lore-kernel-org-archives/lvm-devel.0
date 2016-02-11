From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:48 +0000 (UTC)
Subject: master - cleanup: rename usepolicies
Message-ID: <20160211173948.41AE560975@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=740d27f9fea2596d0f4bcf32c07cd72bad798537
Commit:        740d27f9fea2596d0f4bcf32c07cd72bad798537
Parent:        3f916e8285a8f164927a68082ac6dc759d6720a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 8 13:09:37 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:35:06 2016 +0100

cleanup: rename usepolicies

Switch to ARG name without '_' in the middle (like all others args).
---
 tools/args.h      |    2 +-
 tools/commands.h  |    6 +++---
 tools/lvconvert.c |   14 +++++++-------
 tools/lvresize.c  |    4 ++--
 4 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 991d250..68de524 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -123,7 +123,7 @@ arg(cachesettings_ARG, '\0', "cachesettings", string_arg, ARG_GROUPABLE)
 arg(unconfigured_ARG, '\0', "unconfigured", NULL, 0)
 arg(units_ARG, '\0', "units", string_arg, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
-arg(use_policies_ARG, '\0', "usepolicies", NULL, 0)
+arg(usepolicies_ARG, '\0', "usepolicies", NULL, 0)
 arg(validate_ARG, '\0', "validate", NULL, 0)
 arg(version_ARG, '\0', "version", NULL, 0)
 arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 651852d..0748568 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -294,7 +294,7 @@ xx(lvconvert,
    repair_ARG, replace_ARG, snapshot_ARG,
    split_ARG, splitcache_ARG, splitmirrors_ARG, splitsnapshot_ARG,
    stripes_long_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
-   trackchanges_ARG, type_ARG, uncache_ARG, use_policies_ARG, zero_ARG)
+   trackchanges_ARG, type_ARG, uncache_ARG, usepolicies_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
@@ -480,8 +480,8 @@ xx(lvextend,
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
    nofsck_ARG, nosync_ARG, noudevsync_ARG, poolmetadatasize_ARG,
-   resizefs_ARG, size_ARG, stripes_ARG,
-   stripesize_ARG, test_ARG, type_ARG, use_policies_ARG)
+   resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG,
+   test_ARG, type_ARG, usepolicies_ARG)
 
 xx(lvmchange,
    "With the device mapper, this is obsolete and does nothing.",
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e2b91fa..4e6d91b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -387,7 +387,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	if (arg_count(cmd, repair_ARG) &&
 	    arg_outside_list_is_set(cmd, "cannot be used with --repair",
 				    repair_ARG,
-				    alloc_ARG, use_policies_ARG,
+				    alloc_ARG, usepolicies_ARG,
 				    stripes_long_ARG, stripesize_ARG,
 				    force_ARG, noudevsync_ARG, test_ARG,
 				    -1))
@@ -953,7 +953,7 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 	int force = arg_count(cmd, force_ARG);
 	int yes = arg_count(cmd, yes_ARG);
 
-	if (arg_count(cmd, use_policies_ARG)) {
+	if (arg_count(cmd, usepolicies_ARG)) {
 		leg_policy = find_config_tree_str(cmd, activation_mirror_image_fault_policy_CFG, NULL);
 		log_policy = find_config_tree_str(cmd, activation_mirror_log_fault_policy_CFG, NULL);
 		*replace_mirrors = strcmp(leg_policy, "remove");
@@ -1686,7 +1686,7 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd,
 
 	*replace_dev = 1;
 
-	if (arg_count(cmd, use_policies_ARG)) {
+	if (arg_count(cmd, usepolicies_ARG)) {
 		dev_policy = find_config_tree_str(cmd, activation_raid_fault_policy_CFG, NULL);
 
 		if (!strcmp(dev_policy, "allocate") ||
@@ -1822,7 +1822,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		}
 
 		/* "warn" if policy not set to replace */
-		if (arg_count(cmd, use_policies_ARG))
+		if (arg_count(cmd, usepolicies_ARG))
 			log_warn("Use 'lvconvert --repair %s/%s' to replace "
 				 "failed device.", lv->vg->name, lv->name);
 		return 1;
@@ -3286,7 +3286,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return ECMD_PROCESSED;
 		}
 		if (!lv_is_mirrored(lv) && !lv_is_raid(lv)) {
-			if (arg_count(cmd, use_policies_ARG))
+			if (arg_count(cmd, usepolicies_ARG))
 				return ECMD_PROCESSED; /* nothing to be done here */
 			log_error("Can't repair LV \"%s\" of segtype %s.",
 				  lv->name, lvseg_name(first_seg(lv)));
@@ -3345,7 +3345,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_ECMD_FAILED;
 
 		/* If repairing and using policies, remove missing PVs from VG */
-		if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
+		if (arg_count(cmd, repair_ARG) && arg_count(cmd, usepolicies_ARG))
 			_remove_missing_empty_pv(lv->vg, failed_pvs);
 	} else if (arg_count(cmd, mirrors_ARG) ||
 		   arg_count(cmd, splitmirrors_ARG) ||
@@ -3360,7 +3360,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_ECMD_FAILED;
 
 		/* If repairing and using policies, remove missing PVs from VG */
-		if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
+		if (arg_count(cmd, repair_ARG) && arg_count(cmd, usepolicies_ARG))
 			_remove_missing_empty_pv(lv->vg, failed_pvs);
 	}
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 602cbb8..d1c20b6 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -20,7 +20,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 {
 	const char *cmd_name;
 	char *st;
-	int use_policy = arg_count(cmd, use_policies_ARG);
+	int use_policy = arg_count(cmd, usepolicies_ARG);
 
 	lp->sign = SIGN_NONE;
 	lp->poolmetadatasign = SIGN_NONE;
@@ -124,7 +124,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->argc = argc;
 	lp->argv = argv;
 
-	lp->ac_policy = arg_count(cmd, use_policies_ARG);
+	lp->ac_policy = arg_count(cmd, usepolicies_ARG);
 	lp->ac_stripes = arg_count(cmd, stripes_ARG);
 	if (lp->ac_stripes) {
 		lp->ac_stripes_value = arg_uint_value(cmd, stripes_ARG, 1);



From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 21 Jun 2016 21:35:29 +0000 (UTC)
Subject: master - tools: Use arg_is_set instead of arg_count.
Message-ID: <20160621213529.CFEB660313@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e671e5dd0af699244902d5ce71a7159253c9e2b
Commit:        7e671e5dd0af699244902d5ce71a7159253c9e2b
Parent:        6c269e639a121329fc035685f944816a763b23cf
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jun 21 22:24:52 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 21 22:24:52 2016 +0100

tools: Use arg_is_set instead of arg_count.

---
 tools/dumpconfig.c   |   62 +++++++++++++-------------
 tools/lvchange.c     |  116 ++++++++++++++++++++++++------------------------
 tools/lvconvert.c    |  122 +++++++++++++++++++++++++-------------------------
 tools/lvcreate.c     |   18 ++++----
 tools/lvdisplay.c    |   26 +++++-----
 tools/lvmcmdline.c   |   98 ++++++++++++++++++++--------------------
 tools/lvmdiskscan.c  |    6 +-
 tools/lvresize.c     |   22 +++++-----
 tools/lvscan.c       |    6 +-
 tools/pvchange.c     |   26 +++++-----
 tools/pvcreate.c     |   12 +++---
 tools/pvdisplay.c    |   32 +++++++-------
 tools/pvmove.c       |    4 +-
 tools/pvscan.c       |   24 +++++-----
 tools/reporter.c     |   42 +++++++++---------
 tools/toollib.c      |   46 +++++++++---------
 tools/vgcfgbackup.c  |    2 +-
 tools/vgcfgrestore.c |    8 ++--
 tools/vgchange.c     |   98 ++++++++++++++++++++--------------------
 tools/vgconvert.c    |   10 ++--
 tools/vgcreate.c     |    2 +-
 tools/vgdisplay.c    |   36 +++++++-------
 tools/vgexport.c     |    4 +-
 tools/vgextend.c     |    6 +-
 tools/vgimport.c     |    6 +-
 tools/vgmknodes.c    |    2 +-
 tools/vgreduce.c     |   10 ++--
 tools/vgscan.c       |    2 +-
 tools/vgsplit.c      |   16 +++---
 29 files changed, 432 insertions(+), 432 deletions(-)

diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 0880740..3da04f0 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -20,9 +20,9 @@ static int _get_vsn(struct cmd_context *cmd, uint16_t *version_int)
 	const char *vsn;
 	unsigned int major, minor, patchlevel;
 
-	if (arg_count(cmd, atversion_ARG))
+	if (arg_is_set(cmd, atversion_ARG))
 		vsn = arg_str_value(cmd, atversion_ARG, NULL);
-	else if (arg_count(cmd, sinceversion_ARG))
+	else if (arg_is_set(cmd, sinceversion_ARG))
 		vsn = arg_str_value(cmd, sinceversion_ARG, NULL);
 	else
 		vsn = LVM_VERSION;
@@ -98,7 +98,7 @@ static int _config_validate(struct cmd_context *cmd, struct dm_config_tree *cft)
 int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *file = arg_str_value(cmd, file_ARG, NULL);
-	const char *type = arg_str_value(cmd, configtype_ARG, arg_count(cmd, list_ARG) ? "list" : "current");
+	const char *type = arg_str_value(cmd, configtype_ARG, arg_is_set(cmd, list_ARG) ? "list" : "current");
 	struct config_def_tree_spec tree_spec = {0};
 	struct dm_config_tree *cft = NULL;
 	struct cft_check_handle *cft_check_handle = NULL;
@@ -107,43 +107,43 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 
 	tree_spec.cmd = cmd;
 
-	if (arg_count(cmd, configtype_ARG) && arg_count(cmd, validate_ARG)) {
+	if (arg_is_set(cmd, configtype_ARG) && arg_is_set(cmd, validate_ARG)) {
 		log_error("Only one of --type and --validate permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, configtype_ARG) && arg_count(cmd, list_ARG)) {
+	if (arg_is_set(cmd, configtype_ARG) && arg_is_set(cmd, list_ARG)) {
 		log_error("Only one of --type and --list permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, atversion_ARG)) {
-		if (arg_count(cmd, sinceversion_ARG)) {
+	if (arg_is_set(cmd, atversion_ARG)) {
+		if (arg_is_set(cmd, sinceversion_ARG)) {
 			log_error("Only one of --atversion and --sinceversion permitted.");
 			return EINVALID_CMD_LINE;
 		}
 
-		if (!arg_count(cmd, configtype_ARG) && !arg_count(cmd, list_ARG)) {
+		if (!arg_is_set(cmd, configtype_ARG) && !arg_is_set(cmd, list_ARG)) {
 			log_error("--atversion requires --type or --list");
 			return EINVALID_CMD_LINE;
 		}
-	} else if (arg_count(cmd, sinceversion_ARG)) {
-		if (!arg_count(cmd, configtype_ARG) || strcmp(type, "new")) {
+	} else if (arg_is_set(cmd, sinceversion_ARG)) {
+		if (!arg_is_set(cmd, configtype_ARG) || strcmp(type, "new")) {
 			log_error("--sinceversion requires --type new");
 			return EINVALID_CMD_LINE;
 		}
 	}
 
-	if (arg_count(cmd, ignoreadvanced_ARG))
+	if (arg_is_set(cmd, ignoreadvanced_ARG))
 		tree_spec.ignoreadvanced = 1;
 
-	if (arg_count(cmd, ignoreunsupported_ARG)) {
-		if (arg_count(cmd, showunsupported_ARG)) {
+	if (arg_is_set(cmd, ignoreunsupported_ARG)) {
+		if (arg_is_set(cmd, showunsupported_ARG)) {
 			log_error("Only one of --ignoreunsupported and --showunsupported permitted.");
 			return EINVALID_CMD_LINE;
 		}
 		tree_spec.ignoreunsupported = 1;
-	} else if (arg_count(cmd, showunsupported_ARG)) {
+	} else if (arg_is_set(cmd, showunsupported_ARG)) {
 		tree_spec.ignoreunsupported = 0;
 	} else if (strcmp(type, "current") && strcmp(type, "diff")) {
 		/*
@@ -165,28 +165,28 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		 * is lower than the version in which the
 		 * setting was deprecated.
 		 */
-		if (!arg_count(cmd, showdeprecated_ARG))
+		if (!arg_is_set(cmd, showdeprecated_ARG))
 			tree_spec.ignoredeprecated = 1;
 	}
 
-	if (arg_count(cmd, ignorelocal_ARG))
+	if (arg_is_set(cmd, ignorelocal_ARG))
 		tree_spec.ignorelocal = 1;
 
 	if (!strcmp(type, "current") || !strcmp(type, "full")) {
-		if (arg_count(cmd, atversion_ARG)) {
+		if (arg_is_set(cmd, atversion_ARG)) {
 			log_error("--atversion has no effect with --type %s", type);
 			return EINVALID_CMD_LINE;
 		}
 
-		if ((arg_count(cmd, ignoreunsupported_ARG) ||
-		    arg_count(cmd, ignoreadvanced_ARG)) &&
+		if ((arg_is_set(cmd, ignoreunsupported_ARG) ||
+		    arg_is_set(cmd, ignoreadvanced_ARG)) &&
 		    !strcmp(type, "current")) {
 			/* FIXME: allow these even for --type current */
 			log_error("--ignoreadvanced and --ignoreunsupported has "
 				  "no effect with --type current");
 			return EINVALID_CMD_LINE;
 		}
-	} else if (arg_count(cmd, mergedconfig_ARG)) {
+	} else if (arg_is_set(cmd, mergedconfig_ARG)) {
 		log_error("--mergedconfig has no effect without --type current or --type full");
 		return EINVALID_CMD_LINE;
 	}
@@ -199,7 +199,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	 * but it is used just for dumping the profile content and not for
 	 * application.
 	 */
-	if (arg_count(cmd, profile_ARG) &&
+	if (arg_is_set(cmd, profile_ARG) &&
 	    (!(profile = add_profile(cmd, arg_str_value(cmd, profile_ARG, NULL), CONFIG_PROFILE_COMMAND)) ||
 	    !override_config_tree_from_profile(cmd, profile))) {
 		log_error("Failed to load profile %s.", arg_str_value(cmd, profile_ARG, NULL));
@@ -210,7 +210,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	 * Set the 'cft' to work with based on whether we need the plain
 	 * config tree or merged config tree cascade if --mergedconfig is used.
 	 */
-	if ((arg_count(cmd, mergedconfig_ARG) || !strcmp(type, "full") || !strcmp(type, "diff")) && cmd->cft->cascade) {
+	if ((arg_is_set(cmd, mergedconfig_ARG) || !strcmp(type, "full") || !strcmp(type, "diff")) && cmd->cft->cascade) {
 		if (!_merge_config_cascade(cmd, cmd->cft, &cft)) {
 			log_error("Failed to merge configuration.");
 			r = ECMD_FAILED;
@@ -220,7 +220,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		cft = cmd->cft;
 	tree_spec.current_cft = cft;
 
-	if (arg_count(cmd, validate_ARG)) {
+	if (arg_is_set(cmd, validate_ARG)) {
 		if (_config_validate(cmd, cft)) {
 			log_print("LVM configuration valid.");
 			goto out;
@@ -231,9 +231,9 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	if (!strcmp(type, "list") || arg_count(cmd, list_ARG)) {
+	if (!strcmp(type, "list") || arg_is_set(cmd, list_ARG)) {
 		tree_spec.type = CFG_DEF_TREE_LIST;
-		if (arg_count(cmd, withcomments_ARG)) {
+		if (arg_is_set(cmd, withcomments_ARG)) {
 			log_error("--withcomments has no effect with --type list");
 			return EINVALID_CMD_LINE;
 		}
@@ -270,7 +270,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 	else if (!strcmp(type, "new")) {
-		tree_spec.type = arg_count(cmd, sinceversion_ARG) ? CFG_DEF_TREE_NEW_SINCE
+		tree_spec.type = arg_is_set(cmd, sinceversion_ARG) ? CFG_DEF_TREE_NEW_SINCE
 								  : CFG_DEF_TREE_NEW;
 		/* new type does not require check status */
 	}
@@ -294,17 +294,17 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (arg_count(cmd, withsummary_ARG) || arg_count(cmd, list_ARG))
+	if (arg_is_set(cmd, withsummary_ARG) || arg_is_set(cmd, list_ARG))
 		tree_spec.withsummary = 1;
-	if (arg_count(cmd, withcomments_ARG))
+	if (arg_is_set(cmd, withcomments_ARG))
 		tree_spec.withcomments = 1;
-	if (arg_count(cmd, unconfigured_ARG))
+	if (arg_is_set(cmd, unconfigured_ARG))
 		tree_spec.unconfigured = 1;
 
-	if (arg_count(cmd, withversions_ARG))
+	if (arg_is_set(cmd, withversions_ARG))
 		tree_spec.withversions = 1;
 
-	if (arg_count(cmd, withspaces_ARG))
+	if (arg_is_set(cmd, withspaces_ARG))
 		tree_spec.withspaces = 1;
 
 	if (cft_check_handle)
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 16ede56..b9944f7 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -108,7 +108,7 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, discards_ARG)) {
+	if (arg_is_set(cmd, discards_ARG)) {
 		discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_IGNORE);
 		if (discards != first_seg(lv)->discards) {
 			if (((discards == THIN_DISCARDS_IGNORE) ||
@@ -124,7 +124,7 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 				  lv->name, get_pool_discards_name(discards));
 	}
 
-	if (arg_count(cmd, zero_ARG)) {
+	if (arg_is_set(cmd, zero_ARG)) {
 		val = arg_uint_value(cmd, zero_ARG, 1);
 		if (val != first_seg(lv)->zero_new_blocks) {
 			first_seg(lv)->zero_new_blocks = val;
@@ -200,7 +200,7 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 		return ECMD_FAILED;
 	}
 
-	if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG)))
+	if (lv_activation_skip(lv, activate, arg_is_set(cmd, ignoreactivationskip_ARG)))
 		return 1;
 
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)))
@@ -350,7 +350,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 			return 0;
 		}
 
-		if (!arg_count(cmd, yes_ARG) &&
+		if (!arg_is_set(cmd, yes_ARG) &&
 		    yes_no_prompt("Do you really want to deactivate "
 				  "logical volume %s to resync it? [y/n]: ",
 				  lv->name) == 'n') {
@@ -625,8 +625,8 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 			    display_lvname(lv));
 	} else {
 		if (lv_is_active(lv)) {
-			if (!arg_count(cmd, force_ARG) &&
-			    !arg_count(cmd, yes_ARG) &&
+			if (!arg_is_set(cmd, force_ARG) &&
+			    !arg_is_set(cmd, yes_ARG) &&
 			    yes_no_prompt("Logical volume %s will be "
 					  "deactivated temporarily. "
 					  "Continue? [y/n]: ", lv->name) == 'n') {
@@ -760,11 +760,11 @@ static int _lvchange_writemostly(struct logical_volume *lv)
 
 	if (!seg_is_raid1(raid_seg)) {
 		log_error("--write%s can only be used with 'raid1' segment type",
-			  arg_count(cmd, writemostly_ARG) ? "mostly" : "behind");
+			  arg_is_set(cmd, writemostly_ARG) ? "mostly" : "behind");
 		return 0;
 	}
 
-	if (arg_count(cmd, writebehind_ARG))
+	if (arg_is_set(cmd, writebehind_ARG))
 		raid_seg->writebehind = arg_uint_value(cmd, writebehind_ARG, 0);
 
 	if ((pv_count = arg_count(cmd, writemostly_ARG))) {
@@ -858,10 +858,10 @@ static int _lvchange_recovery_rate(struct logical_volume *lv)
 		return 0;
 	}
 
-	if (arg_count(cmd, minrecoveryrate_ARG))
+	if (arg_is_set(cmd, minrecoveryrate_ARG))
 		raid_seg->min_recovery_rate =
 			arg_uint_value(cmd, minrecoveryrate_ARG, 0) / 2;
-	if (arg_count(cmd, maxrecoveryrate_ARG))
+	if (arg_is_set(cmd, maxrecoveryrate_ARG))
 		raid_seg->max_recovery_rate =
 			arg_uint_value(cmd, maxrecoveryrate_ARG, 0) / 2;
 
@@ -885,11 +885,11 @@ static int _lvchange_profile(struct logical_volume *lv)
 
 	old_profile_name = lv->profile ? lv->profile->name : "(inherited)";
 
-	if (arg_count(lv->vg->cmd, detachprofile_ARG)) {
+	if (arg_is_set(lv->vg->cmd, detachprofile_ARG)) {
 		new_profile_name = "(inherited)";
 		lv->profile = NULL;
 	} else {
-		if (arg_count(lv->vg->cmd, metadataprofile_ARG))
+		if (arg_is_set(lv->vg->cmd, metadataprofile_ARG))
 			new_profile_name = arg_str_value(lv->vg->cmd, metadataprofile_ARG, NULL);
 		else
 			new_profile_name = arg_str_value(lv->vg->cmd, profile_ARG, NULL);
@@ -971,7 +971,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (lv_is_pvmove(lv)) {
 		log_error("Unable to change pvmove LV %s", lv->name);
-		if (arg_count(cmd, activate_ARG))
+		if (arg_is_set(cmd, activate_ARG))
 			log_error("Use 'pvmove --abort' to abandon a pvmove");
 		return ECMD_FAILED;
 	}
@@ -988,15 +988,15 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* If LV is sparse, activate origin instead */
-	if (arg_count(cmd, activate_ARG) && lv_is_cow(lv) &&
+	if (arg_is_set(cmd, activate_ARG) && lv_is_cow(lv) &&
 	    lv_is_virtual_origin(origin = origin_from_cow(lv)))
 		lv = origin;
 
 	if ((lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv) ||
 	     lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) &&
-	    !arg_count(cmd, activate_ARG) &&
-	    !arg_count(cmd, permission_ARG) &&
-	    !arg_count(cmd, setactivationskip_ARG))
+	    !arg_is_set(cmd, activate_ARG) &&
+	    !arg_is_set(cmd, permission_ARG) &&
+	    !arg_is_set(cmd, setactivationskip_ARG))
 	    /* Rest can be changed for stacked thin pool meta/data volumes */
 	    ;
 	else if (!lv_is_visible(lv) && !lv_is_virtual_origin(lv)) {
@@ -1005,7 +1005,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_cow(lv) && arg_count(cmd, activate_ARG)) {
+	if (lv_is_cow(lv) && arg_is_set(cmd, activate_ARG)) {
 		origin = origin_from_cow(lv);
 		if (origin->origin_count < 2)
 			snaps_msg[0] = '\0';
@@ -1016,7 +1016,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return ECMD_FAILED;
 		}
 
-		if (!arg_count(cmd, yes_ARG) &&
+		if (!arg_is_set(cmd, yes_ARG) &&
 		    (yes_no_prompt("Change of snapshot %s will also change its "
 				   "origin %s%s. Proceed? [y/n]: ",
 				   display_lvname(lv), display_lvname(origin),
@@ -1031,12 +1031,12 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (arg_count(cmd, persistent_ARG) && lv_is_pool(lv)) {
+	if (arg_is_set(cmd, persistent_ARG) && lv_is_pool(lv)) {
 		log_error("Persistent major and minor numbers are not supported with pools.");
 		return ECMD_FAILED;
 	}
 
-	if (!arg_count(cmd, activate_ARG) && !arg_count(cmd, refresh_ARG)) {
+	if (!arg_is_set(cmd, activate_ARG) && !arg_is_set(cmd, refresh_ARG)) {
 		/*
 		 * If a persistent lv lock already exists from activation
 		 * (with the needed mode or higher), this will be a no-op.
@@ -1061,12 +1061,12 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	 *
 	 * Do not initiate any polling if --sysinit option is used.
 	 */
-	init_background_polling(arg_count(cmd, sysinit_ARG) ? 0 :
+	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 :
 						arg_int_value(cmd, poll_ARG,
 						DEFAULT_BACKGROUND_POLLING));
 
 	/* access permission change */
-	if (arg_count(cmd, permission_ARG)) {
+	if (arg_is_set(cmd, permission_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_permission(cmd, lv);
@@ -1074,7 +1074,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* allocation policy change */
-	if (arg_count(cmd, contiguous_ARG) || arg_count(cmd, alloc_ARG)) {
+	if (arg_is_set(cmd, contiguous_ARG) || arg_is_set(cmd, alloc_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_alloc(cmd, lv);
@@ -1082,7 +1082,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* error when full change */
-	if (arg_count(cmd, errorwhenfull_ARG)) {
+	if (arg_is_set(cmd, errorwhenfull_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_errorwhenfull(cmd, lv);
@@ -1090,7 +1090,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* read ahead sector change */
-	if (arg_count(cmd, readahead_ARG)) {
+	if (arg_is_set(cmd, readahead_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_readahead(cmd, lv);
@@ -1098,15 +1098,15 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* persistent device number change */
-	if (arg_count(cmd, persistent_ARG)) {
+	if (arg_is_set(cmd, persistent_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_persistent(cmd, lv);
 		docmds++;
 	}
 
-	if (arg_count(cmd, discards_ARG) ||
-	    arg_count(cmd, zero_ARG)) {
+	if (arg_is_set(cmd, discards_ARG) ||
+	    arg_is_set(cmd, zero_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_pool_update(cmd, lv);
@@ -1114,7 +1114,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* add tag */
-	if (arg_count(cmd, addtag_ARG)) {
+	if (arg_is_set(cmd, addtag_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_tag(cmd, lv, addtag_ARG);
@@ -1122,7 +1122,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* del tag */
-	if (arg_count(cmd, deltag_ARG)) {
+	if (arg_is_set(cmd, deltag_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_tag(cmd, lv, deltag_ARG);
@@ -1130,7 +1130,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* change writemostly/writebehind */
-	if (arg_count(cmd, writemostly_ARG) || arg_count(cmd, writebehind_ARG)) {
+	if (arg_is_set(cmd, writemostly_ARG) || arg_is_set(cmd, writebehind_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_writemostly(lv);
@@ -1138,8 +1138,8 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* change [min|max]_recovery_rate */
-	if (arg_count(cmd, minrecoveryrate_ARG) ||
-	    arg_count(cmd, maxrecoveryrate_ARG)) {
+	if (arg_is_set(cmd, minrecoveryrate_ARG) ||
+	    arg_is_set(cmd, maxrecoveryrate_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_recovery_rate(lv);
@@ -1147,15 +1147,15 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* change configuration profile */
-	if (arg_count(cmd, profile_ARG) || arg_count(cmd, metadataprofile_ARG) ||
-	    arg_count(cmd, detachprofile_ARG)) {
+	if (arg_is_set(cmd, profile_ARG) || arg_is_set(cmd, metadataprofile_ARG) ||
+	    arg_is_set(cmd, detachprofile_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_profile(lv);
 		docmds++;
 	}
 
-	if (arg_count(cmd, setactivationskip_ARG)) {
+	if (arg_is_set(cmd, setactivationskip_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_activation_skip(lv);
@@ -1163,7 +1163,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (arg_is_set(cmd, cachemode_ARG) ||
-	    arg_count(cmd, cachepolicy_ARG) || arg_count(cmd, cachesettings_ARG)) {
+	    arg_is_set(cmd, cachepolicy_ARG) || arg_is_set(cmd, cachesettings_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += _lvchange_cache(cmd, lv);
@@ -1173,27 +1173,27 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (doit)
 		log_print_unless_silent("Logical volume %s changed.", display_lvname(lv));
 
-	if (arg_count(cmd, resync_ARG) &&
+	if (arg_is_set(cmd, resync_ARG) &&
 	    !_lvchange_resync(cmd, lv))
 		return_ECMD_FAILED;
 
-	if (arg_count(cmd, syncaction_ARG) &&
+	if (arg_is_set(cmd, syncaction_ARG) &&
 	    !lv_raid_message(lv, arg_str_value(cmd, syncaction_ARG, NULL)))
 		return_ECMD_FAILED;
 
 	/* activation change */
-	if (arg_count(cmd, activate_ARG)) {
+	if (arg_is_set(cmd, activate_ARG)) {
 		if (!_lvchange_activate(cmd, lv))
 			return_ECMD_FAILED;
-	} else if (arg_count(cmd, refresh_ARG)) {
+	} else if (arg_is_set(cmd, refresh_ARG)) {
 		if (!_lvchange_refresh(cmd, lv))
 			return_ECMD_FAILED;
 	} else {
-		if (arg_count(cmd, monitor_ARG) &&
+		if (arg_is_set(cmd, monitor_ARG) &&
 		    !_lvchange_monitoring(cmd, lv))
 			return_ECMD_FAILED;
 
-		if (arg_count(cmd, poll_ARG) &&
+		if (arg_is_set(cmd, poll_ARG) &&
 		    !_lvchange_background_polling(cmd, lv))
 			return_ECMD_FAILED;
 	}
@@ -1243,27 +1243,27 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	int update = update_partial_safe || update_partial_unsafe;
 
 	if (!update &&
-	    !arg_count(cmd, activate_ARG) && !arg_count(cmd, refresh_ARG) &&
-	    !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG)) {
+	    !arg_is_set(cmd, activate_ARG) && !arg_is_set(cmd, refresh_ARG) &&
+	    !arg_is_set(cmd, monitor_ARG) && !arg_is_set(cmd, poll_ARG)) {
 		log_error("Need 1 or more of -a, -C, -M, -p, -r, -Z, "
 			  "--resync, --refresh, --alloc, --addtag, --deltag, "
 			  "--monitor, --poll or --discards");
 		return EINVALID_CMD_LINE;
 	}
 
-	if ((arg_count(cmd, profile_ARG) || arg_count(cmd, metadataprofile_ARG)) &&
-	     arg_count(cmd, detachprofile_ARG)) {
+	if ((arg_is_set(cmd, profile_ARG) || arg_is_set(cmd, metadataprofile_ARG)) &&
+	     arg_is_set(cmd, detachprofile_ARG)) {
 		log_error("Only one of --metadataprofile and --detachprofile permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, activate_ARG) && arg_count(cmd, refresh_ARG)) {
+	if (arg_is_set(cmd, activate_ARG) && arg_is_set(cmd, refresh_ARG)) {
 		log_error("Only one of -a and --refresh permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
-	     arg_count(cmd, sysinit_ARG)) && update) {
+	if ((arg_is_set(cmd, ignorelockingfailure_ARG) ||
+	     arg_is_set(cmd, sysinit_ARG)) && update) {
 		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
 		return EINVALID_CMD_LINE;
 	}
@@ -1276,23 +1276,23 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if ((arg_count(cmd, minor_ARG) || arg_count(cmd, major_ARG)) &&
-	    !arg_count(cmd, persistent_ARG)) {
+	if ((arg_is_set(cmd, minor_ARG) || arg_is_set(cmd, major_ARG)) &&
+	    !arg_is_set(cmd, persistent_ARG)) {
 		log_error("--major and --minor require -My");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, minor_ARG) && argc != 1) {
+	if (arg_is_set(cmd, minor_ARG) && argc != 1) {
 		log_error("Only give one logical volume when specifying minor");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, contiguous_ARG) && arg_count(cmd, alloc_ARG)) {
+	if (arg_is_set(cmd, contiguous_ARG) && arg_is_set(cmd, alloc_ARG)) {
 		log_error("Only one of --alloc and --contiguous permitted");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, poll_ARG) && arg_count(cmd, sysinit_ARG)) {
+	if (arg_is_set(cmd, poll_ARG) && arg_is_set(cmd, sysinit_ARG)) {
 		log_error("Only one of --poll and --sysinit permitted");
 		return EINVALID_CMD_LINE;
 	}
@@ -1304,7 +1304,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	 * not neet to be running at this moment yet - it could be
 	 * just too early during system initialization time.
 	 */
-	if (arg_count(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
+	if (arg_is_set(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
 		if (lvmetad_used()) {
 			log_warn("WARNING: lvmetad is active, skipping direct activation during sysinit");
 			return ECMD_PROCESSED;
@@ -1324,7 +1324,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	 * are cases where lvchange does not modify the vg, so they can use
 	 * the sh lock mode.
 	 */
-	if (arg_count(cmd, activate_ARG) || arg_count(cmd, refresh_ARG)) {
+	if (arg_is_set(cmd, activate_ARG) || arg_is_set(cmd, refresh_ARG)) {
 		cmd->lockd_vg_default_sh = 1;
 		/* Allow deactivating if locks fail. */
 		if (is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a711c31..ae9b052 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -191,7 +191,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 
 	if (!lp->merge_mirror &&
 	    !lp->repair &&
-	    !arg_count(cmd, splitmirrors_ARG) &&
+	    !arg_is_set(cmd, splitmirrors_ARG) &&
 	    !strstr(lp->lv_name, "_tdata") &&
 	    !strstr(lp->lv_name, "_tmeta") &&
 	    !strstr(lp->lv_name, "_cdata") &&
@@ -238,7 +238,7 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 		return 1;
 
 	if (!strcmp(type_str, "mirror")) {
-		if (!arg_count(cmd, mirrors_ARG)) {
+		if (!arg_is_set(cmd, mirrors_ARG)) {
 			log_error("Conversions to --type mirror require -m/--mirrors");
 			return 0;
 		}
@@ -258,11 +258,11 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 
 /* -s/--snapshot and --type snapshot are synonyms */
 static int _snapshot_type_requested(struct cmd_context *cmd, const char *type_str) {
-	return (arg_count(cmd, snapshot_ARG) || !strcmp(type_str, "snapshot"));
+	return (arg_is_set(cmd, snapshot_ARG) || !strcmp(type_str, "snapshot"));
 }
 /* mirror/raid* (1,10,4,5,6 and their variants) reshape */
 static int _mirror_or_raid_type_requested(struct cmd_context *cmd, const char *type_str) {
-	return (arg_count(cmd, mirrors_ARG) || !strncmp(type_str, "raid", 4) || !strcmp(type_str, "mirror"));
+	return (arg_is_set(cmd, mirrors_ARG) || !strncmp(type_str, "raid", 4) || !strcmp(type_str, "mirror"));
 }
 
 static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
@@ -379,7 +379,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	if (!_check_conversion_type(cmd, type_str))
 		return_0;
 
-	if (arg_count(cmd, repair_ARG)) {
+	if (arg_is_set(cmd, repair_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --repair",
 					    repair_ARG,
 					    alloc_ARG, usepolicies_ARG,
@@ -432,25 +432,25 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->uncache = 1;
 	}
 
-	if ((_snapshot_type_requested(cmd, type_str) || arg_count(cmd, merge_ARG)) &&
-	    (arg_count(cmd, mirrorlog_ARG) || _mirror_or_raid_type_requested(cmd, type_str) ||
-	     lp->repair || arg_count(cmd, thinpool_ARG))) {
+	if ((_snapshot_type_requested(cmd, type_str) || arg_is_set(cmd, merge_ARG)) &&
+	    (arg_is_set(cmd, mirrorlog_ARG) || _mirror_or_raid_type_requested(cmd, type_str) ||
+	     lp->repair || arg_is_set(cmd, thinpool_ARG))) {
 		log_error("--snapshot/--type snapshot or --merge argument "
 			  "cannot be mixed with --mirrors/--type mirror/--type raid*, "
 			  "--mirrorlog, --repair or --thinpool.");
 		return 0;
 	}
 
-	if ((arg_count(cmd, stripes_long_ARG) || arg_count(cmd, stripesize_ARG)) &&
+	if ((arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)) &&
 	    !(_mirror_or_raid_type_requested(cmd, type_str) ||
 	      lp->repair ||
-	      arg_count(cmd, thinpool_ARG))) {
+	      arg_is_set(cmd, thinpool_ARG))) {
 		log_error("--stripes or --stripesize argument is only valid "
 			  "with --mirrors/--type mirror/--type raid*, --repair and --thinpool");
 		return 0;
 	}
 
-	if (arg_count(cmd, cache_ARG))
+	if (arg_is_set(cmd, cache_ARG))
 		lp->cache = 1;
 
 	if (!strcmp(type_str, "cache"))
@@ -463,7 +463,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		type_str = "cache";
 	}
 
-	if (arg_count(cmd, thin_ARG))
+	if (arg_is_set(cmd, thin_ARG))
 		lp->thin = 1;
 
 	if (!strcmp(type_str, "thin"))
@@ -479,11 +479,11 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	if (!_read_pool_params(cmd, &argc, &argv, type_str, lp))
 		return_0;
 
-	if (!arg_count(cmd, background_ARG))
+	if (!arg_is_set(cmd, background_ARG))
 		lp->wait_completion = 1;
 
 	if (_snapshot_type_requested(cmd, type_str)) {
-		if (arg_count(cmd, merge_ARG)) {
+		if (arg_is_set(cmd, merge_ARG)) {
 			log_error("--snapshot and --merge are mutually exclusive.");
 			return 0;
 		}
@@ -499,14 +499,14 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	 * intent to keep the mimage that is detached, rather than
 	 * discarding it.
 	 */
-	} else if (arg_count(cmd, splitmirrors_ARG)) {
+	} else if (arg_is_set(cmd, splitmirrors_ARG)) {
 		if (_mirror_or_raid_type_requested(cmd, type_str)) {
 			log_error("--mirrors/--type mirror/--type raid* and --splitmirrors are "
 				  "mutually exclusive.");
 			return 0;
 		}
-		if (!arg_count(cmd, name_ARG) &&
-		    !arg_count(cmd, trackchanges_ARG)) {
+		if (!arg_is_set(cmd, name_ARG) &&
+		    !arg_is_set(cmd, trackchanges_ARG)) {
 			log_error("Please name the new logical volume using '--name'");
 			return 0;
 		}
@@ -515,20 +515,20 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->keep_mimages = 1;
 		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);
 		lp->mirrors_sign = SIGN_MINUS;
-	} else if (arg_count(cmd, name_ARG)) {
+	} else if (arg_is_set(cmd, name_ARG)) {
 		log_error("The 'name' argument is only valid"
 			  " with --splitmirrors");
 		return 0;
 	}
 
-	if (arg_count(cmd, merge_ARG)) {
+	if (arg_is_set(cmd, merge_ARG)) {
 		if ((argc == 1) && strstr(argv[0], "_rimage_"))
 			lp->merge_mirror = 1;
 		else
 			lp->merge = 1;
 	}
 
-	if (arg_count(cmd, mirrors_ARG)) {
+	if (arg_is_set(cmd, mirrors_ARG)) {
 		/*
 		 * --splitmirrors has been chosen as the mechanism for
 		 * specifying the intent of detaching and keeping a mimage
@@ -561,17 +561,17 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->origin_name = argv[0];
 		argv++, argc--;
 
-		if (arg_count(cmd, regionsize_ARG)) {
+		if (arg_is_set(cmd, regionsize_ARG)) {
 			log_error("--regionsize is only available with mirrors");
 			return 0;
 		}
 
-		if (arg_count(cmd, stripesize_ARG) || arg_count(cmd, stripes_long_ARG)) {
+		if (arg_is_set(cmd, stripesize_ARG) || arg_is_set(cmd, stripes_long_ARG)) {
 			log_error("--stripes and --stripesize are only available with striped mirrors");
 			return 0;
 		}
 
-		if (arg_count(cmd, chunksize_ARG) &&
+		if (arg_is_set(cmd, chunksize_ARG) &&
 		    (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS)) {
 			log_error("Negative chunk size is invalid.");
 			return 0;
@@ -592,7 +592,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED)
 			? 0 : arg_int_value(cmd, zero_ARG, 1);
 
-	} else if (arg_count(cmd, replace_ARG)) { /* RAID device replacement */
+	} else if (arg_is_set(cmd, replace_ARG)) { /* RAID device replacement */
 		lp->replace_pv_count = arg_count(cmd, replace_ARG);
 		lp->replace_pvs = dm_pool_alloc(cmd->mem, sizeof(char *) * lp->replace_pv_count);
 		if (!lp->replace_pvs)
@@ -616,12 +616,12 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		   arg_is_set(cmd, repair_ARG) ||
 		   arg_is_set(cmd, mirrorlog_ARG) ||
 		   arg_is_set(cmd, corelog_ARG)) { /* Mirrors (and some RAID functions) */
-		if (arg_count(cmd, chunksize_ARG)) {
+		if (arg_is_set(cmd, chunksize_ARG)) {
 			log_error("--chunksize is only available with snapshots or pools.");
 			return 0;
 		}
 
-		if (arg_count(cmd, zero_ARG)) {
+		if (arg_is_set(cmd, zero_ARG)) {
 			log_error("--zero is only available with snapshots or thin pools.");
 			return 0;
 		}
@@ -631,7 +631,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		 * Checked when we know the state of the LV being converted.
 		 */
 
-		if (arg_count(cmd, regionsize_ARG)) {
+		if (arg_is_set(cmd, regionsize_ARG)) {
 			if (arg_sign_value(cmd, regionsize_ARG, SIGN_NONE) ==
 				    SIGN_MINUS) {
 				log_error("Negative regionsize is invalid");
@@ -671,12 +671,12 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
 			return_0;
 
-		if (arg_count(cmd, mirrors_ARG) && !lp->mirrors) {
+		if (arg_is_set(cmd, mirrors_ARG) && !lp->mirrors) {
 			/* down-converting to linear/stripe? */
 			if (!(lp->segtype =
 			      get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
 				return_0;
-		} else if (arg_count(cmd, type_ARG)) {
+		} else if (arg_is_set(cmd, type_ARG)) {
 			/* changing mirror type? */
 			if (!(lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL)))))
 				return_0;
@@ -945,7 +945,7 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 	int force = arg_count(cmd, force_ARG);
 	int yes = arg_count(cmd, yes_ARG);
 
-	if (arg_count(cmd, usepolicies_ARG)) {
+	if (arg_is_set(cmd, usepolicies_ARG)) {
 		leg_policy = find_config_tree_str(cmd, activation_mirror_image_fault_policy_CFG, NULL);
 		log_policy = find_config_tree_str(cmd, activation_mirror_log_fault_policy_CFG, NULL);
 		*replace_mirrors = strcmp(leg_policy, "remove");
@@ -1139,7 +1139,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	*old_mimage_count = lv_mirror_count(lv);
 	*old_log_count = _get_log_count(lv);
 
-	if (is_lockd_type(lv->vg->lock_type) && arg_count(cmd, splitmirrors_ARG)) {
+	if (is_lockd_type(lv->vg->lock_type) && arg_is_set(cmd, splitmirrors_ARG)) {
 		/* FIXME: we need to create a lock for the new LV. */
 		log_error("Unable to split mirrors in VG with lock_type %s", lv->vg->lock_type);
 		return 0;
@@ -1150,9 +1150,9 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	 *
 	 * If called with no argument, try collapsing the resync layers
 	 */
-	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
-	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
-	    !arg_count(cmd, splitmirrors_ARG) && !lp->repair) {
+	if (!arg_is_set(cmd, mirrors_ARG) && !arg_is_set(cmd, mirrorlog_ARG) &&
+	    !arg_is_set(cmd, corelog_ARG) && !arg_is_set(cmd, regionsize_ARG) &&
+	    !arg_is_set(cmd, splitmirrors_ARG) && !lp->repair) {
 		*new_mimage_count = *old_mimage_count;
 		*new_log_count = *old_log_count;
 
@@ -1164,7 +1164,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	/*
 	 * Adjusting mimage count?
 	 */
-	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, splitmirrors_ARG))
+	if (!arg_is_set(cmd, mirrors_ARG) && !arg_is_set(cmd, splitmirrors_ARG))
 		lp->mirrors = *old_mimage_count;
 	else if (lp->mirrors_sign == SIGN_PLUS)
 		lp->mirrors = *old_mimage_count + lp->mirrors;
@@ -1207,7 +1207,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	 * position that the user would like a 'disk' log.
 	 */
 	*new_log_count = (*old_mimage_count > 1) ? *old_log_count : 1;
-	if (!arg_count(cmd, corelog_ARG) && !arg_count(cmd, mirrorlog_ARG))
+	if (!arg_is_set(cmd, corelog_ARG) && !arg_is_set(cmd, mirrorlog_ARG))
 		return 1;
 
 	*new_log_count = arg_int_value(cmd, mirrorlog_ARG,
@@ -1227,7 +1227,7 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	/*
 	 * Region size must not change on existing mirrors
 	 */
-	if (arg_count(cmd, regionsize_ARG) && lv_is_mirrored(lv) &&
+	if (arg_is_set(cmd, regionsize_ARG) && lv_is_mirrored(lv) &&
 	    (lp->region_size != first_seg(lv)->region_size)) {
 		log_error("Mirror log region size cannot be changed on "
 			  "an existing mirror.");
@@ -1395,7 +1395,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 
 		/* Reduce number of mirrors */
 		if (lp->keep_mimages) {
-			if (arg_count(cmd, trackchanges_ARG)) {
+			if (arg_is_set(cmd, trackchanges_ARG)) {
 				log_error("--trackchanges is not available "
 					  "to 'mirror' segment type");
 				return 0;
@@ -1559,7 +1559,7 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 			 original_logs - _get_log_count(lv), original_logs,
 			 display_lvname(lv));
 
-	/* if (!arg_count(cmd, use_policies_ARG) && (lp->mirrors != old_mimage_count
+	/* if (!arg_is_set(cmd, use_policies_ARG) && (lp->mirrors != old_mimage_count
 						  || log_count != old_log_count))
 						  return 0; */
 
@@ -1679,7 +1679,7 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd,
 
 	*replace_dev = 1;
 
-	if (arg_count(cmd, usepolicies_ARG)) {
+	if (arg_is_set(cmd, usepolicies_ARG)) {
 		dev_policy = find_config_tree_str(cmd, activation_raid_fault_policy_CFG, NULL);
 
 		if (!strcmp(dev_policy, "allocate") ||
@@ -1706,11 +1706,11 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	struct lv_segment *seg = first_seg(lv);
 	dm_percent_t sync_percent;
 
-	if (!arg_count(cmd, type_ARG))
+	if (!arg_is_set(cmd, type_ARG))
 		lp->segtype = seg->segtype;
 
 	/* Can only change image count for raid1 and linear */
-	if (arg_count(cmd, mirrors_ARG) &&
+	if (arg_is_set(cmd, mirrors_ARG) &&
 	    !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
 		log_error("'--mirrors/-m' is not compatible with %s",
 			  lvseg_name(seg));
@@ -1727,13 +1727,13 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return 0;
 	}
 
-	if (seg_is_linear(seg) && !lp->merge_mirror && !arg_count(cmd, mirrors_ARG)) {
+	if (seg_is_linear(seg) && !lp->merge_mirror && !arg_is_set(cmd, mirrors_ARG)) {
 		log_error("Raid conversions require -m/--mirrors");
 		return 0;
 	}
 
 	/* Change number of RAID1 images */
-	if (arg_count(cmd, mirrors_ARG) || arg_count(cmd, splitmirrors_ARG)) {
+	if (arg_is_set(cmd, mirrors_ARG) || arg_is_set(cmd, splitmirrors_ARG)) {
 		image_count = lv_raid_image_count(lv);
 		if (lp->mirrors_sign == SIGN_PLUS)
 			image_count += lp->mirrors;
@@ -1744,7 +1744,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 
 		if (image_count < 1) {
 			log_error("Unable to %s images by specified amount",
-				  arg_count(cmd, splitmirrors_ARG) ?
+				  arg_is_set(cmd, splitmirrors_ARG) ?
 				  "split" : "reduce");
 			return 0;
 		}
@@ -1753,20 +1753,20 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (lp->merge_mirror)
 		return lv_raid_merge(lv);
 
-	if (arg_count(cmd, trackchanges_ARG))
+	if (arg_is_set(cmd, trackchanges_ARG))
 		return lv_raid_split_and_track(lv, lp->pvh);
 
-	if (arg_count(cmd, splitmirrors_ARG))
+	if (arg_is_set(cmd, splitmirrors_ARG))
 		return lv_raid_split(lv, lp->lv_split_name,
 				     image_count, lp->pvh);
 
-	if (arg_count(cmd, mirrors_ARG))
+	if (arg_is_set(cmd, mirrors_ARG))
 		return lv_raid_change_image_count(lv, image_count, lp->pvh);
 
-	if (arg_count(cmd, type_ARG))
+	if (arg_is_set(cmd, type_ARG))
 		return lv_raid_reshape(lv, lp->segtype);
 
-	if (arg_count(cmd, replace_ARG))
+	if (arg_is_set(cmd, replace_ARG))
 		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
 
 	if (lp->repair) {
@@ -1815,7 +1815,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		}
 
 		/* "warn" if policy not set to replace */
-		if (arg_count(cmd, usepolicies_ARG))
+		if (arg_is_set(cmd, usepolicies_ARG))
 			log_warn("Use 'lvconvert --repair %s/%s' to replace "
 				 "failed device.", lv->vg->name, lv->name);
 		return 1;
@@ -2905,7 +2905,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		seg = first_seg(pool_lv);
 
 		/* Normally do NOT change chunk size when swapping */
-		if (arg_count(cmd, chunksize_ARG) &&
+		if (arg_is_set(cmd, chunksize_ARG) &&
 		    (lp->chunk_size != seg->chunk_size) &&
 		    !dm_list_empty(&pool_lv->segs_using_this_lv)) {
 			if (lp->force == PROMPT) {
@@ -2934,9 +2934,9 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		if (metadata_lv->le_count < lp->pool_metadata_extents)
 			log_print_unless_silent("Continuing with swap...");
 
-		if (!arg_count(cmd, discards_ARG))
+		if (!arg_is_set(cmd, discards_ARG))
 			lp->discards = seg->discards;
-		if (!arg_count(cmd, zero_ARG))
+		if (!arg_is_set(cmd, zero_ARG))
 			lp->zero = seg->zero_new_blocks;
 
 		if (!lp->yes &&
@@ -3321,7 +3321,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 			return ECMD_PROCESSED;
 		}
 		if (!lv_is_mirrored(lv) && !lv_is_raid(lv)) {
-			if (arg_count(cmd, usepolicies_ARG))
+			if (arg_is_set(cmd, usepolicies_ARG))
 				return ECMD_PROCESSED; /* nothing to be done here */
 			log_error("Cannot repair logical volume %s of segtype %s.",
 				  display_lvname(lv), lvseg_name(first_seg(lv)));
@@ -3331,7 +3331,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* forward splitmirror operations to the cache origin, which may be raid
 	 * or old-style mirror */
-	if (arg_count(cmd, splitmirrors_ARG) && lv_is_cache_type(lv)
+	if (arg_is_set(cmd, splitmirrors_ARG) && lv_is_cache_type(lv)
 	    && (origin = seg_lv(first_seg(lv), 0)) && lv_is_cache_origin(origin)) {
 		log_warn("WARNING: Selected operation does not work with cache-type LVs.");
 		log_warn("WARNING: Proceeding using the cache origin volume %s instead.",
@@ -3348,7 +3348,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		 * the segtype was not specified, then we need
 		 * to consult the default.
 		 */
-		if (arg_count(cmd, mirrors_ARG) && !lv_is_mirrored(lv)) {
+		if (arg_is_set(cmd, mirrors_ARG) && !lv_is_mirrored(lv)) {
 			if (!(lp->segtype = get_segtype_from_string(cmd, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL))))
 				return_ECMD_FAILED;
 		}
@@ -3382,10 +3382,10 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 			return_ECMD_FAILED;
 
 		/* If repairing and using policies, remove missing PVs from VG */
-		if (lp->repair && arg_count(cmd, usepolicies_ARG))
+		if (lp->repair && arg_is_set(cmd, usepolicies_ARG))
 			_remove_missing_empty_pv(lv->vg, failed_pvs);
-	} else if (arg_count(cmd, mirrors_ARG) ||
-		   arg_count(cmd, splitmirrors_ARG) ||
+	} else if (arg_is_set(cmd, mirrors_ARG) ||
+		   arg_is_set(cmd, splitmirrors_ARG) ||
 		   lv_is_mirrored(lv)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
@@ -3397,7 +3397,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 			return_ECMD_FAILED;
 
 		/* If repairing and using policies, remove missing PVs from VG */
-		if (lp->repair && arg_count(cmd, usepolicies_ARG))
+		if (lp->repair && arg_is_set(cmd, usepolicies_ARG))
 			_remove_missing_empty_pv(lv->vg, failed_pvs);
 	}
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 88518d2..6b99717 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -131,7 +131,7 @@ static int _lvcreate_name_params(struct cmd_context *cmd,
 				  "in one command is not yet supported.");
 			return 0;
 		}
-	} else if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
+	} else if (lp->snapshot && !arg_is_set(cmd, virtualsize_ARG)) {
 		/* argv[0] might be [vg/]origin */
 		if (!argc) {
 			log_error("Please specify a logical volume to act as "
@@ -414,14 +414,14 @@ static int _read_size_params(struct cmd_context *cmd,
 
 	lcp->virtual_size = arg_uint64_value(cmd, virtualsize_ARG, UINT64_C(0));
 
-	if (arg_count(cmd, extents_ARG)) {
-		if (arg_count(cmd, size_ARG)) {
+	if (arg_is_set(cmd, extents_ARG)) {
+		if (arg_is_set(cmd, size_ARG)) {
 			log_error("Please specify either size or extents (not both).");
 			return 0;
 		}
 		lp->extents = arg_uint_value(cmd, extents_ARG, 0);
 		lcp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
-	} else if (arg_count(cmd, size_ARG)) {
+	} else if (arg_is_set(cmd, size_ARG)) {
 		lcp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
 		lcp->percent = PERCENT_NONE;
 	} else if (!lp->snapshot && !seg_is_thin_volume(lp)) {
@@ -459,7 +459,7 @@ static int _read_raid_params(struct cmd_context *cmd,
 			     struct lvcreate_params *lp)
 {
 	if ((lp->stripes < 2) && segtype_is_raid10(lp->segtype)) {
-		if (arg_count(cmd, stripes_ARG)) {
+		if (arg_is_set(cmd, stripes_ARG)) {
 			/* User supplied the bad argument */
 			log_error("Segment type 'raid10' requires 2 or more stripes.");
 			return 0;
@@ -479,7 +479,7 @@ static int _read_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, mirrors_ARG) && segtype_is_raid(lp->segtype) &&
+	if (arg_is_set(cmd, mirrors_ARG) && segtype_is_raid(lp->segtype) &&
 	    !segtype_is_raid1(lp->segtype) && !segtype_is_raid10(lp->segtype)) {
 		log_error("Mirror argument cannot be used with segment type, %s",
 			  lp->segtype->name);
@@ -509,7 +509,7 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 	const char *segtype_name;
 
 	/* Common mirror and raid params */
-	if (arg_count(cmd, mirrors_ARG)) {
+	if (arg_is_set(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
 		if (segtype_is_raid1(lp->segtype)) {
 			segtype_name = SEG_TYPE_NAME_RAID1;
@@ -1228,7 +1228,7 @@ static int _check_raid_parameters(struct volume_group *vg,
 		 * If number of devices was not supplied, we can infer from
 		 * the PVs given.
 		 */
-		if (!arg_count(cmd, stripes_ARG) &&
+		if (!arg_is_set(cmd, stripes_ARG) &&
 		    (devs > 2 * lp->segtype->parity_devs))
 			lp->stripes = devs - lp->segtype->parity_devs;
 
@@ -1239,7 +1239,7 @@ static int _check_raid_parameters(struct volume_group *vg,
 			return 0;
 		}
 	} else if (segtype_is_raid10(lp->segtype)) {
-		if (!arg_count(cmd, stripes_ARG))
+		if (!arg_is_set(cmd, stripes_ARG))
 			lp->stripes = devs / lp->mirrors;
 		if (lp->stripes < 2) {
 			log_error("Unable to create RAID10 LV,"
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index e4d8bae..c60b463 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -18,14 +18,14 @@
 static int _lvdisplay_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     struct processing_handle *handle __attribute__ ((unused)))
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+	if (!arg_is_set(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
-	if (arg_count(cmd, colon_ARG))
+	if (arg_is_set(cmd, colon_ARG))
 		lvdisplay_colons(lv);
 	else {
 		lvdisplay_full(cmd, lv, NULL);
-		if (arg_count(cmd, maps_ARG))
+		if (arg_is_set(cmd, maps_ARG))
 			lvdisplay_segments(lv);
 	}
 
@@ -34,26 +34,26 @@ static int _lvdisplay_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (arg_count(cmd, columns_ARG)) {
-		if (arg_count(cmd, colon_ARG) || arg_count(cmd, maps_ARG)) {
+	if (arg_is_set(cmd, columns_ARG)) {
+		if (arg_is_set(cmd, colon_ARG) || arg_is_set(cmd, maps_ARG)) {
 			log_error("Incompatible options selected");
 			return EINVALID_CMD_LINE;
 		}
 		return lvs(cmd, argc, argv);
 	}
 
-	if (arg_count(cmd, aligned_ARG) ||
-	    arg_count(cmd, binary_ARG) ||
-	    arg_count(cmd, noheadings_ARG) ||
-	    arg_count(cmd, options_ARG) ||
-	    arg_count(cmd, separator_ARG) ||
-	    arg_count(cmd, sort_ARG) ||
-	    arg_count(cmd, unbuffered_ARG)) {
+	if (arg_is_set(cmd, aligned_ARG) ||
+	    arg_is_set(cmd, binary_ARG) ||
+	    arg_is_set(cmd, noheadings_ARG) ||
+	    arg_is_set(cmd, options_ARG) ||
+	    arg_is_set(cmd, separator_ARG) ||
+	    arg_is_set(cmd, sort_ARG) ||
+	    arg_is_set(cmd, unbuffered_ARG)) {
 		log_error("Incompatible options selected.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, colon_ARG) && arg_count(cmd, maps_ARG)) {
+	if (arg_is_set(cmd, colon_ARG) && arg_is_set(cmd, maps_ARG)) {
 		log_error("Options -c and -m are incompatible.");
 		return EINVALID_CMD_LINE;
 	}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 870a8c3..fd00ce6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -82,7 +82,7 @@ int arg_from_list_is_set(const struct cmd_context *cmd, const char *err_found, .
 	va_list ap;
 
 	va_start(ap, err_found);
-	while ((arg = va_arg(ap, int)) != -1 && !arg_count(cmd, arg))
+	while ((arg = va_arg(ap, int)) != -1 && !arg_is_set(cmd, arg))
 		/* empty */;
 	va_end(ap);
 
@@ -116,7 +116,7 @@ int arg_outside_list_is_set(const struct cmd_context *cmd, const char *err_found
 		case yes_ARG:
 			continue;
 		}
-		if (!arg_count(cmd, i))
+		if (!arg_is_set(cmd, i))
 			continue; /* unset */
 		va_start(ap, err_found);
 		while (((arg = va_arg(ap, int)) != -1) && (arg != i))
@@ -187,7 +187,7 @@ const char *arg_value(const struct cmd_context *cmd, int a)
 
 const char *arg_str_value(const struct cmd_context *cmd, int a, const char *def)
 {
-	return arg_count(cmd, a) ? cmd->arg_values[a].value : def;
+	return arg_is_set(cmd, a) ? cmd->arg_values[a].value : def;
 }
 
 const char *grouped_arg_str_value(const struct arg_values *av, int a, const char *def)
@@ -217,39 +217,39 @@ int32_t first_grouped_arg_int_value(const struct cmd_context *cmd, int a, const
 int32_t arg_int_value(const struct cmd_context *cmd, int a, const int32_t def)
 {
 	return (_cmdline.arg_props[a].flags & ARG_GROUPABLE) ?
-		first_grouped_arg_int_value(cmd, a, def) : (arg_count(cmd, a) ? cmd->arg_values[a].i_value : def);
+		first_grouped_arg_int_value(cmd, a, def) : (arg_is_set(cmd, a) ? cmd->arg_values[a].i_value : def);
 }
 
 uint32_t arg_uint_value(const struct cmd_context *cmd, int a, const uint32_t def)
 {
-	return arg_count(cmd, a) ? cmd->arg_values[a].ui_value : def;
+	return arg_is_set(cmd, a) ? cmd->arg_values[a].ui_value : def;
 }
 
 int64_t arg_int64_value(const struct cmd_context *cmd, int a, const int64_t def)
 {
-	return arg_count(cmd, a) ? cmd->arg_values[a].i64_value : def;
+	return arg_is_set(cmd, a) ? cmd->arg_values[a].i64_value : def;
 }
 
 uint64_t arg_uint64_value(const struct cmd_context *cmd, int a, const uint64_t def)
 {
-	return arg_count(cmd, a) ? cmd->arg_values[a].ui64_value : def;
+	return arg_is_set(cmd, a) ? cmd->arg_values[a].ui64_value : def;
 }
 
 /* No longer used.
 const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def)
 {
-	return arg_count(cmd, a) ? cmd->arg_values[a].ptr : def;
+	return arg_is_set(cmd, a) ? cmd->arg_values[a].ptr : def;
 }
 */
 
 sign_t arg_sign_value(const struct cmd_context *cmd, int a, const sign_t def)
 {
-	return arg_count(cmd, a) ? cmd->arg_values[a].sign : def;
+	return arg_is_set(cmd, a) ? cmd->arg_values[a].sign : def;
 }
 
 percent_type_t arg_percent_value(const struct cmd_context *cmd, int a, const percent_type_t def)
 {
-	return arg_count(cmd, a) ? cmd->arg_values[a].percent : def;
+	return arg_is_set(cmd, a) ? cmd->arg_values[a].percent : def;
 }
 
 int arg_count_increment(struct cmd_context *cmd, int a)
@@ -993,7 +993,7 @@ static int _merge_synonym(struct cmd_context *cmd, int oldarg, int newarg)
 	struct arg_values *av;
 	struct arg_value_group_list *current_group;
 
-	if (arg_count(cmd, oldarg) && arg_count(cmd, newarg)) {
+	if (arg_is_set(cmd, oldarg) && arg_is_set(cmd, newarg)) {
 		log_error("%s and %s are synonyms.  Please only supply one.",
 			  _cmdline.arg_props[oldarg].long_arg, _cmdline.arg_props[newarg].long_arg);
 		return 0;
@@ -1001,12 +1001,12 @@ static int _merge_synonym(struct cmd_context *cmd, int oldarg, int newarg)
 
 	/* Not groupable? */
 	if (!(_cmdline.arg_props[oldarg].flags & ARG_GROUPABLE)) {
-		if (arg_count(cmd, oldarg))
+		if (arg_is_set(cmd, oldarg))
 			_copy_arg_values(cmd->arg_values, oldarg, newarg);
 		return 1;
 	}
 
-	if (arg_count(cmd, oldarg))
+	if (arg_is_set(cmd, oldarg))
 		cmd->arg_values[newarg].count = cmd->arg_values[oldarg].count;
 
 	/* Groupable */
@@ -1050,23 +1050,23 @@ static int _get_settings(struct cmd_context *cmd)
 
 	cmd->current_settings = cmd->default_settings;
 
-	if (arg_count(cmd, debug_ARG))
+	if (arg_is_set(cmd, debug_ARG))
 		cmd->current_settings.debug = _LOG_FATAL +
 		    (arg_count(cmd, debug_ARG) - 1);
 
-	if (arg_count(cmd, verbose_ARG))
+	if (arg_is_set(cmd, verbose_ARG))
 		cmd->current_settings.verbose = arg_count(cmd, verbose_ARG);
 
-	if (arg_count(cmd, quiet_ARG)) {
+	if (arg_is_set(cmd, quiet_ARG)) {
 		cmd->current_settings.debug = 0;
 		cmd->current_settings.verbose = 0;
 		cmd->current_settings.silent = (arg_count(cmd, quiet_ARG) > 1) ? 1 : 0;
 	}
 
-	if (arg_count(cmd, test_ARG))
-		cmd->current_settings.test = arg_count(cmd, test_ARG);
+	if (arg_is_set(cmd, test_ARG))
+		cmd->current_settings.test = arg_is_set(cmd, test_ARG);
 
-	if (arg_count(cmd, driverloaded_ARG)) {
+	if (arg_is_set(cmd, driverloaded_ARG)) {
 		cmd->current_settings.activation =
 		    arg_int_value(cmd, driverloaded_ARG,
 				  cmd->default_settings.activation);
@@ -1076,7 +1076,7 @@ static int _get_settings(struct cmd_context *cmd)
 	cmd->current_settings.backup = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.backup);
 	cmd->current_settings.cache_vgmetadata = cmd->command->flags & CACHE_VGMETADATA ? 1 : 0;
 
-	if (arg_count(cmd, readonly_ARG)) {
+	if (arg_is_set(cmd, readonly_ARG)) {
 		cmd->current_settings.activation = 0;
 		cmd->current_settings.archive = 0;
 		cmd->current_settings.backup = 0;
@@ -1091,18 +1091,18 @@ static int _get_settings(struct cmd_context *cmd)
 	if (!activation_mode)
 		activation_mode = DEFAULT_ACTIVATION_MODE;
 
-	if (arg_count(cmd, activationmode_ARG)) {
+	if (arg_is_set(cmd, activationmode_ARG)) {
 		activation_mode = arg_str_value(cmd, activationmode_ARG,
 						activation_mode);
 
 		/* complain only if the two arguments conflict */
-		if (arg_count(cmd, partial_ARG) &&
+		if (arg_is_set(cmd, partial_ARG) &&
 		    strcmp(activation_mode, "partial")) {
 			log_error("--partial and --activationmode are mutually"
 				  " exclusive arguments");
 			return EINVALID_CMD_LINE;
 		}
-	} else if (arg_count(cmd, partial_ARG))
+	} else if (arg_is_set(cmd, partial_ARG))
 		activation_mode = "partial";
 
 	if (!strcmp(activation_mode, "partial")) {
@@ -1115,7 +1115,7 @@ static int _get_settings(struct cmd_context *cmd)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, ignorelockingfailure_ARG) || arg_count(cmd, sysinit_ARG))
+	if (arg_is_set(cmd, ignorelockingfailure_ARG) || arg_is_set(cmd, sysinit_ARG))
 		init_ignorelockingfailure(1);
 	else
 		init_ignorelockingfailure(0);
@@ -1133,10 +1133,10 @@ static int _get_settings(struct cmd_context *cmd)
 	 */
 	cmd->vg_read_print_access_error = 1;
 		
-	if (arg_count(cmd, nosuffix_ARG))
+	if (arg_is_set(cmd, nosuffix_ARG))
 		cmd->current_settings.suffix = 0;
 
-	if (arg_count(cmd, units_ARG))
+	if (arg_is_set(cmd, units_ARG))
 		if (!(cmd->current_settings.unit_factor =
 		      dm_units_to_factor(arg_str_value(cmd, units_ARG, ""),
 					 &cmd->current_settings.unit_type, 1, NULL))) {
@@ -1144,11 +1144,11 @@ static int _get_settings(struct cmd_context *cmd)
 			return EINVALID_CMD_LINE;
 		}
 
-	if (arg_count(cmd, binary_ARG))
+	if (arg_is_set(cmd, binary_ARG))
 		cmd->report_binary_values_as_numeric = 1;
 
-	if (arg_count(cmd, trustcache_ARG)) {
-		if (arg_count(cmd, all_ARG)) {
+	if (arg_is_set(cmd, trustcache_ARG)) {
+		if (arg_is_set(cmd, all_ARG)) {
 			log_error("--trustcache is incompatible with --all");
 			return EINVALID_CMD_LINE;
 		}
@@ -1158,7 +1158,7 @@ static int _get_settings(struct cmd_context *cmd)
 	} else
 		init_trust_cache(0);
 
-	if (arg_count(cmd, noudevsync_ARG))
+	if (arg_is_set(cmd, noudevsync_ARG))
 		cmd->current_settings.udev_sync = 0;
 
 	/* Handle synonyms */
@@ -1186,12 +1186,12 @@ static int _get_settings(struct cmd_context *cmd)
 
 static int _process_common_commands(struct cmd_context *cmd)
 {
-	if (arg_count(cmd, help_ARG) || arg_count(cmd, help2_ARG)) {
+	if (arg_is_set(cmd, help_ARG) || arg_is_set(cmd, help2_ARG)) {
 		_usage(cmd->command->name);
 		return ECMD_PROCESSED;
 	}
 
-	if (arg_count(cmd, version_ARG)) {
+	if (arg_is_set(cmd, version_ARG)) {
 		return version(cmd, 0, (char **) NULL);
 	}
 
@@ -1325,14 +1325,14 @@ static int _prepare_profiles(struct cmd_context *cmd)
 				   env_cmd_profile_name);
 	}
 
-	if (!arg_count(cmd, profile_ARG) &&
-	    !arg_count(cmd, commandprofile_ARG) &&
-	    !arg_count(cmd, metadataprofile_ARG) &&
+	if (!arg_is_set(cmd, profile_ARG) &&
+	    !arg_is_set(cmd, commandprofile_ARG) &&
+	    !arg_is_set(cmd, metadataprofile_ARG) &&
 	    !env_cmd_profile_name)
 		/* nothing to do */
 		return 1;
 
-	if (arg_count(cmd, profile_ARG)) {
+	if (arg_is_set(cmd, profile_ARG)) {
 		/*
 		 * If --profile is used with dumpconfig, it's used
 		 * to dump the profile without the profile being applied.
@@ -1351,7 +1351,7 @@ static int _prepare_profiles(struct cmd_context *cmd)
 		    !strcmp(cmd->command->name, "vgcreate") ||
 		    !strcmp(cmd->command->name, "lvchange") ||
 		    !strcmp(cmd->command->name, "vgchange")) {
-			if (arg_count(cmd, metadataprofile_ARG)) {
+			if (arg_is_set(cmd, metadataprofile_ARG)) {
 				log_error("Only one of --profile or "
 					  " --metadataprofile allowed.");
 				return 0;
@@ -1360,7 +1360,7 @@ static int _prepare_profiles(struct cmd_context *cmd)
 			source_name = _metadata_profile_source_name;
 		}
 		else {
-			if (arg_count(cmd, commandprofile_ARG)) {
+			if (arg_is_set(cmd, commandprofile_ARG)) {
 				log_error("Only one of --profile or "
 					  "--commandprofile allowed.");
 				return 0;
@@ -1401,8 +1401,8 @@ static int _prepare_profiles(struct cmd_context *cmd)
 
 	}
 
-	if (arg_count(cmd, commandprofile_ARG) || env_cmd_profile_name) {
-		if (arg_count(cmd, commandprofile_ARG)) {
+	if (arg_is_set(cmd, commandprofile_ARG) || env_cmd_profile_name) {
+		if (arg_is_set(cmd, commandprofile_ARG)) {
 			/*
 			 * Prefer command profile specified on command
 			 * line over the profile specified via
@@ -1429,7 +1429,7 @@ static int _prepare_profiles(struct cmd_context *cmd)
 	}
 
 
-	if (arg_count(cmd, metadataprofile_ARG)) {
+	if (arg_is_set(cmd, metadataprofile_ARG)) {
 		name = arg_str_value(cmd, metadataprofile_ARG, NULL);
 		source_name = _metadata_profile_source_name;
 
@@ -1457,7 +1457,7 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 	const char *lvmlockd_socket;
 	int use_lvmlockd = find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL);
 
-	if (use_lvmlockd && arg_count(cmd, nolocking_ARG)) {
+	if (use_lvmlockd && arg_is_set(cmd, nolocking_ARG)) {
 		/* --nolocking is only allowed with vgs/lvs/pvs commands */
 		cmd->lockd_gl_disable = 1;
 		cmd->lockd_vg_disable = 1;
@@ -1555,7 +1555,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	set_cmd_name(cmd->command->name);
 
-	if (arg_count(cmd, backgroundfork_ARG)) {
+	if (arg_is_set(cmd, backgroundfork_ARG)) {
 		if (!become_daemon(cmd, 1)) {
 			/* parent - quit immediately */
 			ret = ECMD_PROCESSED;
@@ -1563,13 +1563,13 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	if (arg_count(cmd, config_ARG))
+	if (arg_is_set(cmd, config_ARG))
 		if (!override_config_tree_from_string(cmd, arg_str_value(cmd, config_ARG, ""))) {
 			ret = EINVALID_CMD_LINE;
 			goto_out;
 		}
 
-	if (arg_count(cmd, config_ARG) || !cmd->initialized.config || config_files_changed(cmd)) {
+	if (arg_is_set(cmd, config_ARG) || !cmd->initialized.config || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
 			if ((config_string_cft = remove_config_tree_by_source(cmd, CONFIG_STRING)))
@@ -1593,7 +1593,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (!cmd->initialized.filters && !_cmd_no_meta_proc(cmd) && !init_filters(cmd, !refresh_done))
 		return_ECMD_FAILED;
 
-	if (arg_count(cmd, readonly_ARG))
+	if (arg_is_set(cmd, readonly_ARG))
 		cmd->metadata_read_only = 1;
 
 	if ((ret = _get_settings(cmd)))
@@ -1636,7 +1636,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	if (_cmd_no_meta_proc(cmd))
 		locking_type = 0;
-	else if (arg_count(cmd, readonly_ARG)) {
+	else if (arg_is_set(cmd, readonly_ARG)) {
 		if (find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL)) {
 			/*
 			 * FIXME: we could use locking_type 5 here if that didn't
@@ -1654,12 +1654,12 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 			lvmetad_make_unused(cmd);
 			log_verbose("Not using lvmetad because read-only is set.");
 		}
-	} else if (arg_count(cmd, nolocking_ARG))
+	} else if (arg_is_set(cmd, nolocking_ARG))
 		locking_type = 0;
 	else
 		locking_type = -1;
 
-	if (!init_locking(locking_type, cmd, _cmd_no_meta_proc(cmd) || arg_count(cmd, sysinit_ARG))) {
+	if (!init_locking(locking_type, cmd, _cmd_no_meta_proc(cmd) || arg_is_set(cmd, sysinit_ARG))) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}
diff --git a/tools/lvmdiskscan.c b/tools/lvmdiskscan.c
index 402934a..bd0d705 100644
--- a/tools/lvmdiskscan.c
+++ b/tools/lvmdiskscan.c
@@ -108,7 +108,7 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 	pv_disks_found = 0;
 	pv_parts_found = 0;
 
-	if (arg_count(cmd, lvmpartition_ARG))
+	if (arg_is_set(cmd, lvmpartition_ARG))
 		log_warn("WARNING: only considering LVM devices");
 
 	max_len = _get_max_dev_name_len(cmd->full_filter);
@@ -132,7 +132,7 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 			continue;
 		}
 		/* If user just wants PVs we are done */
-		if (arg_count(cmd, lvmpartition_ARG))
+		if (arg_is_set(cmd, lvmpartition_ARG))
 			continue;
 
 		/* What other device is it? */
@@ -142,7 +142,7 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 	dev_iter_destroy(iter);
 
 	/* Display totals */
-	if (!arg_count(cmd, lvmpartition_ARG)) {
+	if (!arg_is_set(cmd, lvmpartition_ARG)) {
 		log_print("%d disk%s",
 			  disks_found, disks_found == 1 ? "" : "s");
 		log_print("%d partition%s",
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 38ad98f..fe200d4 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -20,7 +20,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 {
 	const char *cmd_name;
 	char *st;
-	int use_policy = arg_count(cmd, usepolicies_ARG);
+	int use_policy = arg_is_set(cmd, usepolicies_ARG);
 
 	lp->sign = SIGN_NONE;
 	lp->poolmetadatasign = SIGN_NONE;
@@ -45,7 +45,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		 * If only --poolmetadatasize is specified with list of PVs,
 		 * then metadata will be extended there.
 		 */
-		lp->sizeargs = arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG);
+		lp->sizeargs = arg_is_set(cmd, extents_ARG) + arg_is_set(cmd, size_ARG);
 
 		if (arg_from_list_is_zero(cmd, "may not be zero",
 					  chunksize_ARG, extents_ARG,
@@ -57,7 +57,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 					  -1))
 			return_0;
 
-		if (arg_count(cmd, poolmetadatasize_ARG)) {
+		if (arg_is_set(cmd, poolmetadatasize_ARG)) {
 			lp->poolmetadatasize = arg_uint64_value(cmd, poolmetadatasize_ARG, 0);
 			lp->poolmetadatasign = arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE);
 			if (lp->poolmetadatasign == SIGN_MINUS) {
@@ -73,20 +73,20 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 			lp->sizeargs = !lp->poolmetadatasize ? 1 : 0;
 		} else if ((lp->sizeargs != 1) &&
 			   ((lp->sizeargs == 2) ||
-			    !arg_count(cmd, poolmetadatasize_ARG))) {
+			    !arg_is_set(cmd, poolmetadatasize_ARG))) {
 			log_error("Please specify either size or extents but not "
 				  "both.");
 			return 0;
 		}
 
-		if (arg_count(cmd, extents_ARG)) {
+		if (arg_is_set(cmd, extents_ARG)) {
 			lp->extents = arg_uint_value(cmd, extents_ARG, 0);
 			lp->sign = arg_sign_value(cmd, extents_ARG, SIGN_NONE);
 			lp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
 		}
 
 		/* Size returned in kilobyte units; held in sectors */
-		if (arg_count(cmd, size_ARG)) {
+		if (arg_is_set(cmd, size_ARG)) {
 			lp->size = arg_uint64_value(cmd, size_ARG, 0);
 			lp->sign = arg_sign_value(cmd, size_ARG, SIGN_NONE);
 			lp->percent = PERCENT_NONE;
@@ -134,15 +134,15 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->argc = argc;
 	lp->argv = argv;
 
-	lp->ac_policy = arg_count(cmd, usepolicies_ARG);
-	lp->ac_stripes = arg_count(cmd, stripes_ARG);
+	lp->ac_policy = arg_is_set(cmd, usepolicies_ARG);
+	lp->ac_stripes = arg_is_set(cmd, stripes_ARG);
 	if (lp->ac_stripes) {
 		lp->ac_stripes_value = arg_uint_value(cmd, stripes_ARG, 1);
 	} else {
 		lp->ac_stripes_value = 0;
 	}
 
-	lp->ac_mirrors = arg_count(cmd, mirrors_ARG);
+	lp->ac_mirrors = arg_is_set(cmd, mirrors_ARG);
 
 	if (lp->ac_mirrors) {
 		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
@@ -155,7 +155,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->ac_mirrors_value = 0;
 	}
 
-	lp->ac_stripesize = arg_count(cmd, stripesize_ARG);
+	lp->ac_stripesize = arg_is_set(cmd, stripesize_ARG);
 	if (lp->ac_stripesize) {
 		if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Stripesize may not be negative.");
@@ -165,7 +165,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->ac_stripesize_value = arg_uint64_value(cmd, stripesize_ARG, 0);
 	}
 
-	lp->ac_no_sync = arg_count(cmd, nosync_ARG);
+	lp->ac_no_sync = arg_is_set(cmd, nosync_ARG);
 	lp->ac_alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, 0);
 
 	lp->ac_type = arg_str_value(cmd, type_ARG, NULL);
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 528e54a..4e188d0 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -54,10 +54,10 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	const char *active_str, *snapshot_str;
 
-	if (arg_count(cmd, cache_long_ARG))
+	if (arg_is_set(cmd, cache_long_ARG))
 		return _lvscan_single_lvmetad(cmd, lv);
 
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+	if (!arg_is_set(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	inkernel = lv_info(cmd, lv, 0, &info, 0, 0) && info.exists;
@@ -93,7 +93,7 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *reason = NULL;
 
-	if (argc && !arg_count(cmd, cache_long_ARG)) {
+	if (argc && !arg_is_set(cmd, cache_long_ARG)) {
 		log_error("No additional command line arguments allowed");
 		return EINVALID_CMD_LINE;
 	}
diff --git a/tools/pvchange.c b/tools/pvchange.c
index ed99e7c..e68e181 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -31,7 +31,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 
 	int allocatable = arg_int_value(cmd, allocatable_ARG, 0);
 	int mda_ignore = arg_int_value(cmd, metadataignore_ARG, 0);
-	int tagargs = arg_count(cmd, addtag_ARG) + arg_count(cmd, deltag_ARG);
+	int tagargs = arg_is_set(cmd, addtag_ARG) + arg_is_set(cmd, deltag_ARG);
 
 	params->total++;
 
@@ -51,7 +51,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 				  vg->name);
 			goto bad;
 		}
-		if (arg_count(cmd, uuid_ARG)) {
+		if (arg_is_set(cmd, uuid_ARG)) {
 			log_error("Resolve duplicate PV UUIDs with vgimportclone (or filters).");
 			goto bad;
 		}
@@ -64,7 +64,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 				  "support tags", pv_name);
 			goto bad;
 		}
-		if (arg_count(cmd, uuid_ARG) && lvs_in_vg_activated(vg)) {
+		if (arg_is_set(cmd, uuid_ARG) && lvs_in_vg_activated(vg)) {
 			log_error("Volume group containing %s has active "
 				  "logical volumes", pv_name);
 			goto bad;
@@ -88,7 +88,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		}
 	}
 
-	if (arg_count(cmd, allocatable_ARG)) {
+	if (arg_is_set(cmd, allocatable_ARG)) {
 		if (is_orphan(pv) &&
 		    !(pv->fmt->features & FMT_ORPHAN_ALLOCATABLE)) {
 			log_error("Allocatability not supported by orphan "
@@ -129,16 +129,16 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (tagargs) {
 		/* tag or deltag */
-		if (arg_count(cmd, addtag_ARG) && !change_tag(cmd, NULL, NULL, pv, addtag_ARG))
+		if (arg_is_set(cmd, addtag_ARG) && !change_tag(cmd, NULL, NULL, pv, addtag_ARG))
 			goto_bad;
 
-		if (arg_count(cmd, deltag_ARG) && !change_tag(cmd, NULL, NULL, pv, deltag_ARG))
+		if (arg_is_set(cmd, deltag_ARG) && !change_tag(cmd, NULL, NULL, pv, deltag_ARG))
 			goto_bad;
 	
 		done = 1;
 	}
 
-	if (arg_count(cmd, metadataignore_ARG)) {
+	if (arg_is_set(cmd, metadataignore_ARG)) {
 		if ((vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
 		    (arg_count(cmd, force_ARG) == PROMPT) &&
 		    yes_no_prompt("Override preferred number of copies "
@@ -151,7 +151,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		done = 1;
 	} 
 
-	if (arg_count(cmd, uuid_ARG)) {
+	if (arg_is_set(cmd, uuid_ARG)) {
 		/* --uuid: Change PV ID randomly */
 		memcpy(&pv->old_id, &pv->id, sizeof(pv->id));
 		if (!id_create(&pv->id)) {
@@ -207,9 +207,9 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	struct processing_handle *handle = NULL;
 	int ret;
 
-	if (!(arg_count(cmd, allocatable_ARG) + arg_is_set(cmd, addtag_ARG) +
-	    arg_is_set(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
-	    arg_count(cmd, metadataignore_ARG))) {
+	if (!(arg_is_set(cmd, allocatable_ARG) + arg_is_set(cmd, addtag_ARG) +
+	    arg_is_set(cmd, deltag_ARG) + arg_is_set(cmd, uuid_ARG) +
+	    arg_is_set(cmd, metadataignore_ARG))) {
 		log_error("Please give one or more of -x, -uuid, "
 			  "--addtag, --deltag or --metadataignore");
 		ret = EINVALID_CMD_LINE;
@@ -224,13 +224,13 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &params;
 
-	if (!(arg_count(cmd, all_ARG)) && !argc && !handle->internal_report_for_select) {
+	if (!(arg_is_set(cmd, all_ARG)) && !argc && !handle->internal_report_for_select) {
 		log_error("Please give a physical volume path or use --select for selection.");
 		ret = EINVALID_CMD_LINE;
 		goto out;
 	}
 
-	if (arg_count(cmd, all_ARG) && argc) {
+	if (arg_is_set(cmd, all_ARG) && argc) {
 		log_error("Option --all and PhysicalVolumePath are exclusive.");
 		ret = EINVALID_CMD_LINE;
 		goto out;
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index ae133fa..fe6611f 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -27,25 +27,25 @@ static int pvcreate_restore_params_from_args(struct cmd_context *cmd, int argc,
 {
 	pp->restorefile = arg_str_value(cmd, restorefile_ARG, NULL);
 
-	if (arg_count(cmd, restorefile_ARG) && !arg_count(cmd, uuidstr_ARG)) {
+	if (arg_is_set(cmd, restorefile_ARG) && !arg_is_set(cmd, uuidstr_ARG)) {
 		log_error("--uuid is required with --restorefile");
 		return 0;
 	}
 
-	if (!arg_count(cmd, restorefile_ARG) && arg_count(cmd, uuidstr_ARG)) {
-		if (!arg_count(cmd, norestorefile_ARG) &&
+	if (!arg_is_set(cmd, restorefile_ARG) && arg_is_set(cmd, uuidstr_ARG)) {
+		if (!arg_is_set(cmd, norestorefile_ARG) &&
 		    find_config_tree_bool(cmd, devices_require_restorefile_with_uuid_CFG, NULL)) {
 			log_error("--restorefile is required with --uuid");
 			return 0;
 		}
 	}
 
-	if (arg_count(cmd, uuidstr_ARG) && argc != 1) {
+	if (arg_is_set(cmd, uuidstr_ARG) && argc != 1) {
 		log_error("Can only set uuid on one volume at once");
 		return 0;
 	}
 
-	if (arg_count(cmd, uuidstr_ARG)) {
+	if (arg_is_set(cmd, uuidstr_ARG)) {
 		pp->uuid_str = arg_str_value(cmd, uuidstr_ARG, "");
 		if (!id_read_format(&pp->pva.id, pp->uuid_str))
 			return 0;
@@ -58,7 +58,7 @@ static int pvcreate_restore_params_from_args(struct cmd_context *cmd, int argc,
 	}
 	pp->pva.size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
 
-	if (arg_count(cmd, restorefile_ARG) || arg_count(cmd, uuidstr_ARG))
+	if (arg_is_set(cmd, restorefile_ARG) || arg_is_set(cmd, uuidstr_ARG))
 		pp->zero = 0;
 	return 1;
 }
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 46439c8..404e02b 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -30,7 +30,7 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 		size = (uint64_t)(pv_pe_count(pv) - pv_pe_alloc_count(pv)) *
 			pv_pe_size(pv);
 
-	if (arg_count(cmd, short_ARG)) {
+	if (arg_is_set(cmd, short_ARG)) {
 		log_print("Device \"%s\" has a capacity of %s", pv_name,
 			  display_size(cmd, size));
 		goto out;
@@ -44,14 +44,14 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 		log_print_unless_silent("\"%s\" is a new physical volume of \"%s\"",
 					pv_name, display_size(cmd, size));
 
-	if (arg_count(cmd, colon_ARG)) {
+	if (arg_is_set(cmd, colon_ARG)) {
 		pvdisplay_colons(pv);
 		goto out;
 	}
 
 	pvdisplay_full(cmd, pv, NULL);
 
-	if (arg_count(cmd, maps_ARG))
+	if (arg_is_set(cmd, maps_ARG))
 		pvdisplay_segments(pv);
 
 out:
@@ -63,33 +63,33 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 	int lock_global = 0;
 	int ret;
 
-	if (arg_count(cmd, columns_ARG)) {
-		if (arg_count(cmd, colon_ARG) || arg_count(cmd, maps_ARG) ||
-		    arg_count(cmd, short_ARG)) {
+	if (arg_is_set(cmd, columns_ARG)) {
+		if (arg_is_set(cmd, colon_ARG) || arg_is_set(cmd, maps_ARG) ||
+		    arg_is_set(cmd, short_ARG)) {
 			log_error("Incompatible options selected");
 			return EINVALID_CMD_LINE;
 		}
 		return pvs(cmd, argc, argv);
 	}
 
-	if (arg_count(cmd, aligned_ARG) ||
-	    arg_count(cmd, all_ARG) ||
-	    arg_count(cmd, binary_ARG) ||
-	    arg_count(cmd, noheadings_ARG) ||
-	    arg_count(cmd, options_ARG) ||
-	    arg_count(cmd, separator_ARG) ||
-	    arg_count(cmd, sort_ARG) ||
-	    arg_count(cmd, unbuffered_ARG)) {
+	if (arg_is_set(cmd, aligned_ARG) ||
+	    arg_is_set(cmd, all_ARG) ||
+	    arg_is_set(cmd, binary_ARG) ||
+	    arg_is_set(cmd, noheadings_ARG) ||
+	    arg_is_set(cmd, options_ARG) ||
+	    arg_is_set(cmd, separator_ARG) ||
+	    arg_is_set(cmd, sort_ARG) ||
+	    arg_is_set(cmd, unbuffered_ARG)) {
 		log_error("Incompatible options selected");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, colon_ARG) && arg_count(cmd, maps_ARG)) {
+	if (arg_is_set(cmd, colon_ARG) && arg_is_set(cmd, maps_ARG)) {
 		log_error("Option -c not allowed with option -m");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, colon_ARG) && arg_count(cmd, short_ARG)) {
+	if (arg_is_set(cmd, colon_ARG) && arg_is_set(cmd, short_ARG)) {
 		log_error("Option -c is not allowed with option -s");
 		return EINVALID_CMD_LINE;
 	}
diff --git a/tools/pvmove.c b/tools/pvmove.c
index f5f5654..f937c12 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -493,7 +493,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 
 	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, 0, log_count,
 			    allocatable_pvs, alloc,
-			    (arg_count(cmd, atomic_ARG)) ?
+			    (arg_is_set(cmd, atomic_ARG)) ?
 			    MIRROR_BY_SEGMENTED_LV : MIRROR_BY_SEG)) {
 		log_error("Failed to convert pvmove LV to mirrored");
 		return_NULL;
@@ -862,7 +862,7 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 		pp.pv_count = argc;
 		pp.pv_names = argv;
 
-		if (arg_count(cmd, name_ARG)) {
+		if (arg_is_set(cmd, name_ARG)) {
 			if (!(pp.lv_name_arg = dm_pool_strdup(cmd->mem, arg_value(cmd, name_ARG))))  {
 				log_error("Failed to clone LV name.");
 				return ECMD_FAILED;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index a1f5ef3..c29401c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -46,7 +46,7 @@ static int _pvscan_display_single(struct cmd_context *cmd,
 	const char *pvdevname = pv_dev_name(pv);
 
 	/* short listing? */
-	if (arg_count(cmd, short_ARG) > 0) {
+	if (arg_is_set(cmd, short_ARG)) {
 		log_print_unless_silent("%s", pvdevname);
 		return ECMD_PROCESSED;
 	}
@@ -65,7 +65,7 @@ static int _pvscan_display_single(struct cmd_context *cmd,
 	pv_len = params->pv_max_name_len;
 	memset(params->pv_tmp_name, 0, params->pv_tmp_namelen);
 
-	if (arg_count(cmd, uuid_ARG)) {
+	if (arg_is_set(cmd, uuid_ARG)) {
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
 			stack;
 			return ECMD_FAILED;
@@ -106,8 +106,8 @@ static int _pvscan_single(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct pvscan_params *params = (struct pvscan_params *)handle->custom_handle;
 
-	if ((arg_count(cmd, exported_ARG) && !(pv_status(pv) & EXPORTED_VG)) ||
-	    (arg_count(cmd, novolumegroup_ARG) && (!is_orphan(pv)))) {
+	if ((arg_is_set(cmd, exported_ARG) && !(pv_status(pv) & EXPORTED_VG)) ||
+	    (arg_is_set(cmd, novolumegroup_ARG) && (!is_orphan(pv)))) {
 		return ECMD_PROCESSED;
 
 	}
@@ -332,10 +332,10 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		return ret;
 	}
 
-	if (arg_count(cmd, major_ARG) + arg_count(cmd, minor_ARG))
+	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
 		devno_args = 1;
 
-	if (devno_args && (!arg_count(cmd, major_ARG) || !arg_count(cmd, minor_ARG))) {
+	if (devno_args && (!arg_is_set(cmd, major_ARG) || !arg_is_set(cmd, minor_ARG))) {
 		log_error("Both --major and --minor required to identify devices.");
 		return EINVALID_CMD_LINE;
 	}
@@ -587,7 +587,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 	const char *reason = NULL;
 	int ret;
 
-	if (arg_count(cmd, cache_long_ARG))
+	if (arg_is_set(cmd, cache_long_ARG))
 		return _pvscan_cache(cmd, argc, argv);
 
 	if (argc) {
@@ -595,24 +595,24 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, activate_ARG)) {
+	if (arg_is_set(cmd, activate_ARG)) {
 		log_error("--activate is only valid with --cache.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, major_ARG) || arg_count(cmd, minor_ARG)) {
+	if (arg_is_set(cmd, major_ARG) || arg_is_set(cmd, minor_ARG)) {
 		log_error("--major and --minor are only valid with --cache.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, novolumegroup_ARG) && arg_count(cmd, exported_ARG)) {
+	if (arg_is_set(cmd, novolumegroup_ARG) && arg_is_set(cmd, exported_ARG)) {
 		log_error("Options -e and -n are incompatible");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, exported_ARG) || arg_count(cmd, novolumegroup_ARG))
+	if (arg_is_set(cmd, exported_ARG) || arg_is_set(cmd, novolumegroup_ARG))
 		log_warn("WARNING: only considering physical volumes %s",
-			  arg_count(cmd, exported_ARG) ?
+			  arg_is_set(cmd, exported_ARG) ?
 			  "of exported volume group(s)" : "in no volume group");
 
 	/* Needed because this command has NO_LVMETAD_AUTOSCAN. */
diff --git a/tools/reporter.c b/tools/reporter.c
index 8d213cd..ee2d251 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -235,7 +235,7 @@ static int _segs_with_info_and_status_single(struct cmd_context *cmd, struct lv_
 static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
 			  struct processing_handle *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+	if (!arg_is_set(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	return process_each_segment_in_lv(cmd, lv, handle, _segs_single);
@@ -244,7 +244,7 @@ static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
 static int _lvsegs_with_info_single(struct cmd_context *cmd, struct logical_volume *lv,
 				    struct processing_handle *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+	if (!arg_is_set(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_info_single);
@@ -253,7 +253,7 @@ static int _lvsegs_with_info_single(struct cmd_context *cmd, struct logical_volu
 static int _lvsegs_with_status_single(struct cmd_context *cmd, struct logical_volume *lv,
 				      struct processing_handle *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+	if (!arg_is_set(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_status_single);
@@ -262,7 +262,7 @@ static int _lvsegs_with_status_single(struct cmd_context *cmd, struct logical_vo
 static int _lvsegs_with_info_and_status_single(struct cmd_context *cmd, struct logical_volume *lv,
 					       struct processing_handle *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+	if (!arg_is_set(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
 	return process_each_segment_in_lv(cmd, lv, handle, _segs_with_info_and_status_single);
@@ -810,7 +810,7 @@ static int _get_report_options(struct cmd_context *cmd,
 	report_idx_t idx = REPORT_IDX_SINGLE;
 	int r = ECMD_FAILED;
 
-	if (!arg_count(cmd, options_ARG))
+	if (!arg_is_set(cmd, options_ARG))
 		return ECMD_PROCESSED;
 
 	if (!(mem = dm_pool_create("report_options", 128))) {
@@ -1252,21 +1252,21 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 	switch (single_args->report_type) {
 		case DEVTYPES:
 			single_args->keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
-			if (!arg_count(cmd, verbose_ARG))
+			if (!arg_is_set(cmd, verbose_ARG))
 				single_args->options = find_config_tree_str(cmd, report_devtypes_cols_CFG, NULL);
 			else
 				single_args->options = find_config_tree_str(cmd, report_devtypes_cols_verbose_CFG, NULL);
 			break;
 		case LVS:
 			single_args->keys = find_config_tree_str(cmd, report_lvs_sort_CFG, NULL);
-			if (!arg_count(cmd, verbose_ARG))
+			if (!arg_is_set(cmd, verbose_ARG))
 				single_args->options = find_config_tree_str(cmd, report_lvs_cols_CFG, NULL);
 			else
 				single_args->options = find_config_tree_str(cmd, report_lvs_cols_verbose_CFG, NULL);
 			break;
 		case VGS:
 			single_args->keys = find_config_tree_str(cmd, report_vgs_sort_CFG, NULL);
-			if (!arg_count(cmd, verbose_ARG))
+			if (!arg_is_set(cmd, verbose_ARG))
 				single_args->options = find_config_tree_str(cmd, report_vgs_cols_CFG, NULL);
 			else
 				single_args->options = find_config_tree_str(cmd, report_vgs_cols_verbose_CFG, NULL);
@@ -1274,21 +1274,21 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 		case LABEL:
 		case PVS:
 			single_args->keys = find_config_tree_str(cmd, report_pvs_sort_CFG, NULL);
-			if (!arg_count(cmd, verbose_ARG))
+			if (!arg_is_set(cmd, verbose_ARG))
 				single_args->options = find_config_tree_str(cmd, report_pvs_cols_CFG, NULL);
 			else
 				single_args->options = find_config_tree_str(cmd, report_pvs_cols_verbose_CFG, NULL);
 			break;
 		case SEGS:
 			single_args->keys = find_config_tree_str(cmd, report_segs_sort_CFG, NULL);
-			if (!arg_count(cmd, verbose_ARG))
+			if (!arg_is_set(cmd, verbose_ARG))
 				single_args->options = find_config_tree_str(cmd, report_segs_cols_CFG, NULL);
 			else
 				single_args->options = find_config_tree_str(cmd, report_segs_cols_verbose_CFG, NULL);
 			break;
 		case PVSEGS:
 			single_args->keys = find_config_tree_str(cmd, report_pvsegs_sort_CFG, NULL);
-			if (!arg_count(cmd, verbose_ARG))
+			if (!arg_is_set(cmd, verbose_ARG))
 				single_args->options = find_config_tree_str(cmd, report_pvsegs_cols_CFG, NULL);
 			else
 				single_args->options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
@@ -1325,21 +1325,21 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 		return_0;
 
 	args->separator = arg_str_value(cmd, separator_ARG, args->separator);
-	if (arg_count(cmd, separator_ARG))
+	if (arg_is_set(cmd, separator_ARG))
 		args->aligned = 0;
-	if (arg_count(cmd, aligned_ARG))
+	if (arg_is_set(cmd, aligned_ARG))
 		args->aligned = 1;
-	if (arg_count(cmd, unbuffered_ARG) && !arg_count(cmd, sort_ARG))
+	if (arg_is_set(cmd, unbuffered_ARG) && !arg_is_set(cmd, sort_ARG))
 		args->buffered = 0;
-	if (arg_count(cmd, noheadings_ARG))
+	if (arg_is_set(cmd, noheadings_ARG))
 		args->headings = 0;
-	if (arg_count(cmd, nameprefixes_ARG)) {
+	if (arg_is_set(cmd, nameprefixes_ARG)) {
 		args->aligned = 0;
 		args->field_prefixes = 1;
 	}
-	if (arg_count(cmd, unquoted_ARG))
+	if (arg_is_set(cmd, unquoted_ARG))
 		args->quoted = 0;
-	if (arg_count(cmd, rows_ARG))
+	if (arg_is_set(cmd, rows_ARG))
 		args->columns_as_rows = 1;
 
 	return 1;
@@ -1399,7 +1399,7 @@ int lvs(struct cmd_context *cmd, int argc, char **argv)
 {
 	report_type_t type;
 
-	if (arg_count(cmd, segments_ARG))
+	if (arg_is_set(cmd, segments_ARG))
 		type = SEGS;
 	else
 		type = LVS;
@@ -1416,7 +1416,7 @@ int pvs(struct cmd_context *cmd, int argc, char **argv)
 {
 	report_type_t type;
 
-	if (arg_count(cmd, segments_ARG))
+	if (arg_is_set(cmd, segments_ARG))
 		type = PVSEGS;
 	else
 		type = LABEL;
@@ -1538,7 +1538,7 @@ int lastlog(struct cmd_context *cmd, int argc, char **argv)
 	if (!report_format_init(cmd, NULL, &report_group, &cmd->log_rh, NULL, NULL))
 		goto_out;
 
-	if (arg_count(cmd, select_ARG) &&
+	if (arg_is_set(cmd, select_ARG) &&
 	    !_do_report_get_selection(cmd, NULL, NULL, expected_idxs, &selection))
 		goto_out;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 833d6ce..77c9f01 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -801,10 +801,10 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, metadatacopies_ARG))
+	if (arg_is_set(cmd, metadatacopies_ARG))
 		vp_new->vgmetadatacopies = arg_int_value(cmd, metadatacopies_ARG,
 							DEFAULT_VGMETADATACOPIES);
-	else if (arg_count(cmd, vgmetadatacopies_ARG))
+	else if (arg_is_set(cmd, vgmetadatacopies_ARG))
 		vp_new->vgmetadatacopies = arg_int_value(cmd, vgmetadatacopies_ARG,
 							DEFAULT_VGMETADATACOPIES);
 	else
@@ -1175,18 +1175,18 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 {
 	*monitoring_mode = DEFAULT_DMEVENTD_MONITOR;
 
-	if (arg_count(cmd, monitor_ARG) &&
-	    (arg_count(cmd, ignoremonitoring_ARG) ||
-	     arg_count(cmd, sysinit_ARG))) {
+	if (arg_is_set(cmd, monitor_ARG) &&
+	    (arg_is_set(cmd, ignoremonitoring_ARG) ||
+	     arg_is_set(cmd, sysinit_ARG))) {
 		log_error("--ignoremonitoring or --sysinit option not allowed with --monitor option.");
 		return 0;
 	}
 
-	if (arg_count(cmd, monitor_ARG))
+	if (arg_is_set(cmd, monitor_ARG))
 		*monitoring_mode = arg_int_value(cmd, monitor_ARG,
 						 DEFAULT_DMEVENTD_MONITOR);
-	else if (is_static() || arg_count(cmd, ignoremonitoring_ARG) ||
-		 arg_count(cmd, sysinit_ARG) ||
+	else if (is_static() || arg_is_set(cmd, ignoremonitoring_ARG) ||
+		 arg_is_set(cmd, sysinit_ARG) ||
 		 !find_config_tree_bool(cmd, activation_monitoring_CFG, NULL))
 		*monitoring_mode = DMEVENTD_MONITOR_IGNORE;
 
@@ -1246,13 +1246,13 @@ int get_pool_params(struct cmd_context *cmd,
 				 display_size(cmd, *chunk_size));
 	}
 
-	if (arg_count(cmd, poolmetadatasize_ARG)) {
+	if (arg_is_set(cmd, poolmetadatasize_ARG)) {
 		if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative pool metadata size is invalid.");
 			return 0;
 		}
 
-		if (arg_count(cmd, poolmetadata_ARG)) {
+		if (arg_is_set(cmd, poolmetadata_ARG)) {
 			log_error("Please specify either metadata logical volume or its size.");
 			return 0;
 		}
@@ -1260,7 +1260,7 @@ int get_pool_params(struct cmd_context *cmd,
 		*passed_args |= PASS_ARG_POOL_METADATA_SIZE;
 		*pool_metadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG,
 						       UINT64_C(0));
-	} else if (arg_count(cmd, poolmetadata_ARG))
+	} else if (arg_is_set(cmd, poolmetadata_ARG))
 		*passed_args |= PASS_ARG_POOL_METADATA_SIZE; /* fixed size */
 
 	/* TODO: default in lvm.conf ? */
@@ -1312,7 +1312,7 @@ static int _validate_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stripe_size)
 {
 	/* stripes_long_ARG takes precedence (for lvconvert) */
-	*stripes = arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ? stripes_long_ARG : stripes_ARG, 1);
+	*stripes = arg_uint_value(cmd, arg_is_set(cmd, stripes_long_ARG) ? stripes_long_ARG : stripes_ARG, 1);
 
 	*stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
 	if (*stripe_size) {
@@ -2398,11 +2398,11 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		/* Skip availability change for non-virt snaps when processing all LVs */
 		/* FIXME: pass process_all to process_single_lv() */
-		if (process_all && arg_count(cmd, activate_ARG) &&
+		if (process_all && arg_is_set(cmd, activate_ARG) &&
 		    lv_is_cow(lvl->lv) && !lv_is_virtual_origin(origin_from_cow(lvl->lv)))
 			continue;
 
-		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG)) {
+		if (lv_is_virtual_origin(lvl->lv) && !arg_is_set(cmd, all_ARG)) {
 			if (lvargs_supplied &&
 			    str_list_match_item(arg_lvnames, lvl->lv->name))
 				log_print_unless_silent("Ignoring virtual origin logical volume %s.",
@@ -2414,7 +2414,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		 * Only let hidden LVs through if --all was used or the LVs 
 		 * were specifically named on the command line.
 		 */
-		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
+		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_is_set(cmd, all_ARG))
 			continue;
 
 		/*
@@ -2422,7 +2422,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		 * it is named on the command line.
 		 */
 		if (lv_is_lockd_sanlock_lv(lvl->lv)) {
-			if (arg_count(cmd, all_ARG) ||
+			if (arg_is_set(cmd, all_ARG) ||
 			    (lvargs_supplied && str_list_match_item(arg_lvnames, lvl->lv->name))) {
 				log_very_verbose("Processing lockd_sanlock_lv %s/%s.", vg->name, lvl->lv->name);
 			} else {
@@ -3840,29 +3840,29 @@ int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *p
 	}
 
 	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    (arg_count(cmd, pvmetadatacopies_ARG) ||
-	     arg_count(cmd, metadatasize_ARG)   ||
-	     arg_count(cmd, dataalignment_ARG)  ||
-	     arg_count(cmd, dataalignmentoffset_ARG))) {
+	    (arg_is_set(cmd, pvmetadatacopies_ARG) ||
+	     arg_is_set(cmd, metadatasize_ARG)   ||
+	     arg_is_set(cmd, dataalignment_ARG)  ||
+	     arg_is_set(cmd, dataalignmentoffset_ARG))) {
 		log_error("Metadata and data alignment parameters only "
 			  "apply to text format.");
 		return 0;
 	}
 
 	if (!(cmd->fmt->features & FMT_BAS) &&
-	    arg_count(cmd, bootloaderareasize_ARG)) {
+	    arg_is_set(cmd, bootloaderareasize_ARG)) {
 		log_error("Bootloader area parameters only "
 			  "apply to text format.");
 		return 0;
 	}
 
-	if (arg_count(cmd, metadataignore_ARG))
+	if (arg_is_set(cmd, metadataignore_ARG))
 		pp->pva.metadataignore = arg_int_value(cmd, metadataignore_ARG,
 						   DEFAULT_PVMETADATAIGNORE);
 	else
 		pp->pva.metadataignore = find_config_tree_bool(cmd, metadata_pvmetadataignore_CFG, NULL);
 
-	if (arg_count(cmd, pvmetadatacopies_ARG) &&
+	if (arg_is_set(cmd, pvmetadatacopies_ARG) &&
 	    !arg_int_value(cmd, pvmetadatacopies_ARG, -1) &&
 	    pp->pva.metadataignore) {
 		log_error("metadataignore only applies to metadatacopies > 0");
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 34fe08f..a04c3ab 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -54,7 +54,7 @@ static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 	char **last_filename = (char **)handle->custom_handle;
 	char *filename;
 
-	if (arg_count(cmd, file_ARG)) {
+	if (arg_is_set(cmd, file_ARG)) {
 		if (!(filename = _expand_filename(arg_value(cmd, file_ARG),
 						  vg->name, last_filename)))
 			return_ECMD_FAILED;
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 77c007c..8a60ab3 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -28,7 +28,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 			log_error("Volume group name \"%s\" is invalid", vg_name);
 			return EINVALID_CMD_LINE;
 		}
-	} else if (!(arg_count(cmd, list_ARG) && arg_count(cmd, file_ARG))) {
+	} else if (!(arg_is_set(cmd, list_ARG) && arg_is_set(cmd, file_ARG))) {
 		log_error("Please specify a *single* volume group to restore.");
 		return EINVALID_CMD_LINE;
 	}
@@ -37,8 +37,8 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 	 * FIXME: overloading the -l arg for now to display a
 	 * list of archive files for a particular vg
 	 */
-	if (arg_count(cmd, list_ARG)) {
-		if (!(arg_count(cmd,file_ARG) ?
+	if (arg_is_set(cmd, list_ARG)) {
+		if (!(arg_is_set(cmd,file_ARG) ?
 			    archive_display_file(cmd,
 				arg_str_value(cmd, file_ARG, "")) :
 			    archive_display(cmd, vg_name)))
@@ -76,7 +76,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->handles_unknown_segments = 1;
 
-	if (!(arg_count(cmd, file_ARG) ?
+	if (!(arg_is_set(cmd, file_ARG) ?
 	      backup_restore_from_file(cmd, vg_name,
 				       arg_str_value(cmd, file_ARG, ""),
 				       arg_count(cmd, force_long_ARG)) :
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 4f6d847..fb751a2 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -114,7 +114,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (lv_is_replicator_dev(lv) && (lv != first_replicator_dev(lv)))
 			continue;
 
-		if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG)))
+		if (lv_activation_skip(lv, activate, arg_is_set(cmd, ignoreactivationskip_ARG)))
 			continue;
 
 		if ((activate == CHANGE_AAY) &&
@@ -346,7 +346,7 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 		}
 	}
 
-	if (clustered && !arg_count(cmd, yes_ARG)) {
+	if (clustered && !arg_is_set(cmd, yes_ARG)) {
 		if (!clvmd_is_running()) {
 			if (yes_no_prompt("LVM cluster daemon (clvmd) is not running. "
 					  "Make volume group \"%s\" clustered "
@@ -501,11 +501,11 @@ static int _vgchange_profile(struct cmd_context *cmd,
 
 	old_profile_name = vg->profile ? vg->profile->name : "(no profile)";
 
-	if (arg_count(cmd, detachprofile_ARG)) {
+	if (arg_is_set(cmd, detachprofile_ARG)) {
 		new_profile_name = "(no profile)";
 		vg->profile = NULL;
 	} else {
-		if (arg_count(cmd, metadataprofile_ARG))
+		if (arg_is_set(cmd, metadataprofile_ARG))
 			new_profile_name = arg_str_value(cmd, metadataprofile_ARG, NULL);
 		else
 			new_profile_name = arg_str_value(cmd, profile_ARG, NULL);
@@ -769,7 +769,7 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 	if (!*system_id && cmd->system_id && strcmp(system_id, cmd->system_id)) {
 		log_warn("WARNING: Removing the system ID allows unsafe access from other hosts.");
 
-		if (!arg_count(cmd, yes_ARG) &&
+		if (!arg_is_set(cmd, yes_ARG) &&
 		    yes_no_prompt("Remove system ID %s from volume group %s? [y/n]: ",
 				  vg->system_id, vg->name) == 'n') {
 			log_error("System ID of volume group %s not changed.", vg->name);
@@ -792,7 +792,7 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 		log_warn("WARNING: Volume group %s might become inaccessible from this machine.",
 			 vg->name);
 
-		if (!arg_count(cmd, yes_ARG) &&
+		if (!arg_is_set(cmd, yes_ARG) &&
 		    yes_no_prompt("Set foreign system ID %s on volume group %s? [y/n]: ",
 				  system_id, vg->name) == 'n') {
 			log_error("Volume group %s system ID not changed.", vg->name);
@@ -930,12 +930,12 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	 *
 	 * Do not initiate any polling if --sysinit option is used.
 	 */
-	init_background_polling(arg_count(cmd, sysinit_ARG) ? 0 :
+	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 :
 						arg_int_value(cmd, poll_ARG,
 						DEFAULT_BACKGROUND_POLLING));
 
 	for (i = 0; i < DM_ARRAY_SIZE(_vgchange_args); ++i) {
-		if (arg_count(cmd, _vgchange_args[i].arg)) {
+		if (arg_is_set(cmd, _vgchange_args[i].arg)) {
 			if (!archive(vg))
 				return_ECMD_FAILED;
 			if (!_vgchange_args[i].fn(cmd, vg))
@@ -977,27 +977,27 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			}
 	}
 
-	if (arg_count(cmd, activate_ARG)) {
+	if (arg_is_set(cmd, activate_ARG)) {
 		if (!vgchange_activate(cmd, vg, (activation_change_t)
 				       arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
 			return_ECMD_FAILED;
 	}
 
-	if (arg_count(cmd, refresh_ARG)) {
+	if (arg_is_set(cmd, refresh_ARG)) {
 		/* refreshes the visible LVs (which starts polling) */
 		if (!_vgchange_refresh(cmd, vg))
 			return_ECMD_FAILED;
 	}
 
-	if (!arg_count(cmd, activate_ARG) &&
-	    !arg_count(cmd, refresh_ARG) &&
-	    arg_count(cmd, monitor_ARG)) {
+	if (!arg_is_set(cmd, activate_ARG) &&
+	    !arg_is_set(cmd, refresh_ARG) &&
+	    arg_is_set(cmd, monitor_ARG)) {
 		/* -ay* will have already done monitoring changes */
 		if (!_vgchange_monitoring(cmd, vg))
 			return_ECMD_FAILED;
 	}
 
-	if (!arg_count(cmd, refresh_ARG) &&
+	if (!arg_is_set(cmd, refresh_ARG) &&
 	    !vgchange_background_polling(cmd, vg))
 			return_ECMD_FAILED;
 
@@ -1096,31 +1096,31 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	int ret;
 
 	int noupdate =
-		arg_count(cmd, activate_ARG) ||
-		arg_count(cmd, lockstart_ARG) ||
-		arg_count(cmd, lockstop_ARG) ||
-		arg_count(cmd, monitor_ARG) ||
-		arg_count(cmd, poll_ARG) ||
-		arg_count(cmd, refresh_ARG);
+		arg_is_set(cmd, activate_ARG) ||
+		arg_is_set(cmd, lockstart_ARG) ||
+		arg_is_set(cmd, lockstop_ARG) ||
+		arg_is_set(cmd, monitor_ARG) ||
+		arg_is_set(cmd, poll_ARG) ||
+		arg_is_set(cmd, refresh_ARG);
 
 	int update_partial_safe =
-		arg_count(cmd, deltag_ARG) ||
-		arg_count(cmd, addtag_ARG) ||
-		arg_count(cmd, metadataprofile_ARG) ||
-		arg_count(cmd, profile_ARG) ||
-		arg_count(cmd, detachprofile_ARG);
+		arg_is_set(cmd, deltag_ARG) ||
+		arg_is_set(cmd, addtag_ARG) ||
+		arg_is_set(cmd, metadataprofile_ARG) ||
+		arg_is_set(cmd, profile_ARG) ||
+		arg_is_set(cmd, detachprofile_ARG);
 
 	int update_partial_unsafe =
-		arg_count(cmd, logicalvolume_ARG) ||
-		arg_count(cmd, maxphysicalvolumes_ARG) ||
-		arg_count(cmd, resizeable_ARG) ||
-		arg_count(cmd, uuid_ARG) ||
-		arg_count(cmd, physicalextentsize_ARG) ||
-		arg_count(cmd, clustered_ARG) ||
-		arg_count(cmd, alloc_ARG) ||
-		arg_count(cmd, vgmetadatacopies_ARG) ||
-		arg_count(cmd, locktype_ARG) ||
-		arg_count(cmd, systemid_ARG);
+		arg_is_set(cmd, logicalvolume_ARG) ||
+		arg_is_set(cmd, maxphysicalvolumes_ARG) ||
+		arg_is_set(cmd, resizeable_ARG) ||
+		arg_is_set(cmd, uuid_ARG) ||
+		arg_is_set(cmd, physicalextentsize_ARG) ||
+		arg_is_set(cmd, clustered_ARG) ||
+		arg_is_set(cmd, alloc_ARG) ||
+		arg_is_set(cmd, vgmetadatacopies_ARG) ||
+		arg_is_set(cmd, locktype_ARG) ||
+		arg_is_set(cmd, systemid_ARG);
 
 	int update = update_partial_safe || update_partial_unsafe;
 
@@ -1129,49 +1129,49 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if ((arg_count(cmd, profile_ARG) || arg_count(cmd, metadataprofile_ARG)) &&
-	     arg_count(cmd, detachprofile_ARG)) {
+	if ((arg_is_set(cmd, profile_ARG) || arg_is_set(cmd, metadataprofile_ARG)) &&
+	     arg_is_set(cmd, detachprofile_ARG)) {
 		log_error("Only one of --metadataprofile and --detachprofile permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, activate_ARG) && arg_count(cmd, refresh_ARG)) {
+	if (arg_is_set(cmd, activate_ARG) && arg_is_set(cmd, refresh_ARG)) {
 		log_error("Only one of -a and --refresh permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
-	     arg_count(cmd, sysinit_ARG)) && update) {
+	if ((arg_is_set(cmd, ignorelockingfailure_ARG) ||
+	     arg_is_set(cmd, sysinit_ARG)) && update) {
 		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, activate_ARG) &&
-	    (arg_count(cmd, monitor_ARG) || arg_count(cmd, poll_ARG))) {
+	if (arg_is_set(cmd, activate_ARG) &&
+	    (arg_is_set(cmd, monitor_ARG) || arg_is_set(cmd, poll_ARG))) {
 		if (!is_change_activating((activation_change_t) arg_uint_value(cmd, activate_ARG, 0))) {
 			log_error("Only -ay* allowed with --monitor or --poll.");
 			return EINVALID_CMD_LINE;
 		}
 	}
 
-	if (arg_count(cmd, poll_ARG) && arg_count(cmd, sysinit_ARG)) {
+	if (arg_is_set(cmd, poll_ARG) && arg_is_set(cmd, sysinit_ARG)) {
 		log_error("Only one of --poll and --sysinit permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if ((arg_count(cmd, activate_ARG) == 1) &&
-	    arg_count(cmd, autobackup_ARG)) {
+	if (arg_is_set(cmd, activate_ARG) &&
+	    arg_is_set(cmd, autobackup_ARG)) {
 		log_error("-A option not necessary with -a option");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, maxphysicalvolumes_ARG) &&
+	if (arg_is_set(cmd, maxphysicalvolumes_ARG) &&
 	    arg_sign_value(cmd, maxphysicalvolumes_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("MaxPhysicalVolumes may not be negative");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, physicalextentsize_ARG) &&
+	if (arg_is_set(cmd, physicalextentsize_ARG) &&
 	    arg_sign_value(cmd, physicalextentsize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical extent size may not be negative");
 		return EINVALID_CMD_LINE;
@@ -1184,14 +1184,14 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	 * not neet to be running@this moment yet - it could be
 	 * just too early during system initialization time.
 	 */
-	if (arg_count(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
+	if (arg_is_set(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
 		if (lvmetad_used()) {
 			log_warn("WARNING: lvmetad is active, skipping direct activation during sysinit");
 			return ECMD_PROCESSED;
 		}
 	}
 
-	if (arg_count(cmd, clustered_ARG) && !argc && !arg_count(cmd, yes_ARG) &&
+	if (arg_is_set(cmd, clustered_ARG) && !argc && !arg_is_set(cmd, yes_ARG) &&
 	    (yes_no_prompt("Change clustered property of all volumes groups? [y/n]: ") == 'n')) {
 		log_error("No volume groups changed.");
 		return ECMD_FAILED;
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 4c3d560..4f28ba3 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -157,26 +157,26 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, metadatacopies_ARG)) {
+	if (arg_is_set(cmd, metadatacopies_ARG)) {
 		log_error("Invalid option --metadatacopies, "
 			  "use --pvmetadatacopies instead.");
 		return EINVALID_CMD_LINE;
 	}
 	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    (arg_count(cmd, pvmetadatacopies_ARG) ||
-	     arg_count(cmd, metadatasize_ARG))) {
+	    (arg_is_set(cmd, pvmetadatacopies_ARG) ||
+	     arg_is_set(cmd, metadatasize_ARG))) {
 		log_error("Metadata parameters only apply to text format");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, pvmetadatacopies_ARG) &&
+	if (arg_is_set(cmd, pvmetadatacopies_ARG) &&
 	    arg_int_value(cmd, pvmetadatacopies_ARG, -1) > 2) {
 		log_error("Metadatacopies may only be 0, 1 or 2");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (!(cmd->fmt->features & FMT_BAS) &&
-		arg_count(cmd, bootloaderareasize_ARG)) {
+		arg_is_set(cmd, bootloaderareasize_ARG)) {
 		log_error("Bootloader area parameters only apply to text format");
 		return EINVALID_CMD_LINE;
 	}
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 974d7e7..14e0d53 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -141,7 +141,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		log_warn("WARNING: Setting maxphysicalvolumes to %d "
 			 "(0 means unlimited)", vg->max_pv);
 
-	if (arg_count(cmd, addtag_ARG)) {
+	if (arg_is_set(cmd, addtag_ARG)) {
 		dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
 			if (!grouped_arg_is_set(current_group->arg_values, addtag_ARG))
 				continue;
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index e9482df..7bb2e6a 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -19,22 +19,22 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
 			    struct processing_handle *handle __attribute__((unused)))
 {
-	if (arg_count(cmd, activevolumegroups_ARG) && !lvs_in_vg_activated(vg))
+	if (arg_is_set(cmd, activevolumegroups_ARG) && !lvs_in_vg_activated(vg))
 		return ECMD_PROCESSED;
 
-	if (arg_count(cmd, colon_ARG)) {
+	if (arg_is_set(cmd, colon_ARG)) {
 		vgdisplay_colons(vg);
 		return ECMD_PROCESSED;
 	}
 
-	if (arg_count(cmd, short_ARG)) {
+	if (arg_is_set(cmd, short_ARG)) {
 		vgdisplay_short(vg);
 		return ECMD_PROCESSED;
 	}
 
 	vgdisplay_full(vg);	/* was vg_show */
 
-	if (arg_count(cmd, verbose_ARG)) {
+	if (arg_is_set(cmd, verbose_ARG)) {
 		vgdisplay_extents(vg);
 
 		process_each_lv_in_vg(cmd, vg, NULL, NULL, 0, NULL,
@@ -52,30 +52,30 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 
 int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (arg_count(cmd, columns_ARG)) {
-		if (arg_count(cmd, colon_ARG) ||
-		    arg_count(cmd, activevolumegroups_ARG) ||
-		    arg_count(cmd, short_ARG)) {
+	if (arg_is_set(cmd, columns_ARG)) {
+		if (arg_is_set(cmd, colon_ARG) ||
+		    arg_is_set(cmd, activevolumegroups_ARG) ||
+		    arg_is_set(cmd, short_ARG)) {
 			log_error("Incompatible options selected");
 			return EINVALID_CMD_LINE;
 		}
 		return vgs(cmd, argc, argv);
-	} else if (arg_count(cmd, aligned_ARG) ||
-		   arg_count(cmd, binary_ARG) ||
-		   arg_count(cmd, noheadings_ARG) ||
-		   arg_count(cmd, options_ARG) ||
-		   arg_count(cmd, separator_ARG) ||
-		   arg_count(cmd, sort_ARG) || arg_count(cmd, unbuffered_ARG)) {
+	} else if (arg_is_set(cmd, aligned_ARG) ||
+		   arg_is_set(cmd, binary_ARG) ||
+		   arg_is_set(cmd, noheadings_ARG) ||
+		   arg_is_set(cmd, options_ARG) ||
+		   arg_is_set(cmd, separator_ARG) ||
+		   arg_is_set(cmd, sort_ARG) || arg_is_set(cmd, unbuffered_ARG)) {
 		log_error("Incompatible options selected");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, colon_ARG) && arg_count(cmd, short_ARG)) {
+	if (arg_is_set(cmd, colon_ARG) && arg_is_set(cmd, short_ARG)) {
 		log_error("Option -c is not allowed with option -s");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc && arg_count(cmd, activevolumegroups_ARG)) {
+	if (argc && arg_is_set(cmd, activevolumegroups_ARG)) {
 		log_error("Option -A is not allowed with volume group names");
 		return EINVALID_CMD_LINE;
 	}
@@ -93,11 +93,11 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 			       vgdisplay_single);
 
 /******** FIXME Need to count number processed
-	  Add this to process_each_vg if arg_count(cmd,activevolumegroups_ARG) ?
+	  Add this to process_each_vg if arg_is_set(cmd,activevolumegroups_ARG) ?
 
 	if (opt == argc) {
 		log_print("no ");
-		if (arg_count(cmd,activevolumegroups_ARG))
+		if (arg_is_set(cmd,activevolumegroups_ARG))
 			printf("active ");
 		printf("volume groups found\n\n");
 		return LVM_E_NO_VG;
diff --git a/tools/vgexport.c b/tools/vgexport.c
index 592e145..76cf819 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -70,12 +70,12 @@ bad:
 
 int vgexport(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (!argc && !arg_count(cmd, all_ARG) && !arg_is_set(cmd, select_ARG)) {
+	if (!argc && !arg_is_set(cmd, all_ARG) && !arg_is_set(cmd, select_ARG)) {
 		log_error("Please supply volume groups or use --select for selection or use -a for all.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, all_ARG) && (argc || arg_is_set(cmd, select_ARG))) {
+	if (arg_is_set(cmd, all_ARG) && (argc || arg_is_set(cmd, select_ARG))) {
 		log_error("No arguments permitted when using -a for all.");
 		return EINVALID_CMD_LINE;
 	}
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 1c3743b..4b2a13e 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -82,7 +82,7 @@ static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
 	uint32_t mda_used;
 	int ret = ECMD_FAILED;
 
-	if (arg_count(cmd, metadataignore_ARG) &&
+	if (arg_is_set(cmd, metadataignore_ARG) &&
 	    (pp->force == PROMPT) && !pp->yes &&
 	    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
 	    (yes_no_prompt("Override preferred number of copies of VG %s metadata? [y/n]: ", vg_name) == 'n')) {
@@ -96,7 +96,7 @@ static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
 	if (!vg_extend_each_pv(vg, pp))
 		goto_out;
 
-	if (arg_count(cmd, metadataignore_ARG)) {
+	if (arg_is_set(cmd, metadataignore_ARG)) {
 		mda_copies = vg_mda_copies(vg);
 		mda_used = vg_mda_used_count(vg);
 
@@ -136,7 +136,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, metadatacopies_ARG)) {
+	if (arg_is_set(cmd, metadatacopies_ARG)) {
 		log_error("Invalid option --metadatacopies, "
 			  "use --pvmetadatacopies instead.");
 		return EINVALID_CMD_LINE;
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 07a889b..53eeca5 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -63,17 +63,17 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *reason = NULL;
 
-	if (!argc && !arg_count(cmd, all_ARG) && !arg_is_set(cmd, select_ARG)) {
+	if (!argc && !arg_is_set(cmd, all_ARG) && !arg_is_set(cmd, select_ARG)) {
 		log_error("Please supply volume groups or -S for selection or use -a for all.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, all_ARG) && (argc || arg_is_set(cmd, select_ARG))) {
+	if (arg_is_set(cmd, all_ARG) && (argc || arg_is_set(cmd, select_ARG))) {
 		log_error("No arguments permitted when using -a for all.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, force_ARG)) {
+	if (arg_is_set(cmd, force_ARG)) {
 		/*
 		 * The volume group cannot be repaired unless it is first
 		 * imported.  If we don't allow the user a way to import the
diff --git a/tools/vgmknodes.c b/tools/vgmknodes.c
index 81580b7..f974ff3 100644
--- a/tools/vgmknodes.c
+++ b/tools/vgmknodes.c
@@ -18,7 +18,7 @@
 static int _vgmknodes_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     struct processing_handle *handle __attribute__((unused)))
 {
-	if (arg_count(cmd, refresh_ARG) && lv_is_visible(lv))
+	if (arg_is_set(cmd, refresh_ARG) && lv_is_visible(lv))
 		if (!lv_refresh(cmd, lv))
 			return_ECMD_FAILED;
 
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index bae2b3e..7b9f506 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -107,7 +107,7 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 				goto restart;
 			}
 
-			if (arg_count(cmd, mirrorsonly_ARG) && !lv_is_mirrored(lv)) {
+			if (arg_is_set(cmd, mirrorsonly_ARG) && !lv_is_mirrored(lv)) {
 				log_error("Non-mirror-image LV %s found: can't remove.", lv->name);
 				continue;
 			}
@@ -177,7 +177,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	struct processing_handle *handle;
 	struct vgreduce_params vp = { 0 };
 	const char *vg_name;
-	int repairing = arg_count(cmd, removemissing_ARG);
+	int repairing = arg_is_set(cmd, removemissing_ARG);
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
 	int ret;
 
@@ -192,17 +192,17 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, mirrorsonly_ARG) && !repairing) {
+	if (arg_is_set(cmd, mirrorsonly_ARG) && !repairing) {
 		log_error("--mirrorsonly requires --removemissing");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc == 1 && !arg_count(cmd, all_ARG) && !repairing) {
+	if (argc == 1 && !arg_is_set(cmd, all_ARG) && !repairing) {
 		log_error("Please enter physical volume paths or option -a");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc > 1 && arg_count(cmd, all_ARG)) {
+	if (argc > 1 && arg_is_set(cmd, all_ARG)) {
 		log_error("Option -a and physical volume paths mutually "
 			  "exclusive");
 		return EINVALID_CMD_LINE;
diff --git a/tools/vgscan.c b/tools/vgscan.c
index dfb1d46..e09724a 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -119,7 +119,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 
 	maxret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL, &vgscan_single);
 
-	if (arg_count(cmd, mknodes_ARG)) {
+	if (arg_is_set(cmd, mknodes_ARG)) {
 		ret = vgmknodes(cmd, argc, argv);
 		if (ret > maxret)
 			maxret = ret;
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index e7c6e19..cb6b0ef 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -468,11 +468,11 @@ static struct volume_group *_vgsplit_from(struct cmd_context *cmd,
  */
 static int new_vg_option_specified(struct cmd_context *cmd)
 {
-	return(arg_count(cmd, clustered_ARG) ||
-	       arg_count(cmd, alloc_ARG) ||
-	       arg_count(cmd, maxphysicalvolumes_ARG) ||
-	       arg_count(cmd, maxlogicalvolumes_ARG) ||
-	       arg_count(cmd, vgmetadatacopies_ARG));
+	return(arg_is_set(cmd, clustered_ARG) ||
+	       arg_is_set(cmd, alloc_ARG) ||
+	       arg_is_set(cmd, maxphysicalvolumes_ARG) ||
+	       arg_is_set(cmd, maxlogicalvolumes_ARG) ||
+	       arg_is_set(cmd, vgmetadatacopies_ARG));
 }
 
 int vgsplit(struct cmd_context *cmd, int argc, char **argv)
@@ -487,13 +487,13 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	const char *lv_name;
 	int lock_vg_from_first = 1;
 
-	if ((arg_count(cmd, name_ARG) + argc) < 3) {
+	if ((arg_is_set(cmd, name_ARG) + argc) < 3) {
 		log_error("Existing VG, new VG and either physical volumes "
 			  "or logical volume required.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, name_ARG) && (argc > 2)) {
+	if (arg_is_set(cmd, name_ARG) && (argc > 2)) {
 		log_error("A logical volume name cannot be given with "
 			  "physical volumes.");
 		return ECMD_FAILED;
@@ -503,7 +503,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
 		return_ECMD_FAILED;
 
-	if (arg_count(cmd, name_ARG))
+	if (arg_is_set(cmd, name_ARG))
 		lv_name = arg_value(cmd, name_ARG);
 	else
 		lv_name = NULL;



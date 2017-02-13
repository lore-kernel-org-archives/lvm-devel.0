From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:01 +0000 (UTC)
Subject: master - lvchange: make use of command definitions
Message-ID: <20170213181001.7B95660EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52c60b7e7bba400b2f8fb40f123ca90224c16d27
Commit:        52c60b7e7bba400b2f8fb40f123ca90224c16d27
Parent:        9c6c55c314199a9ba26fe1b864306b2ca8a8dbcd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 16 16:05:47 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvchange: make use of command definitions

Reorganize the lvchange code to take advantage of
the command definition, and remove the validation
that is done by the command definintion rules.
---
 tools/command-lines.in |   16 +-
 tools/lvchange.c       |  848 +++++++++++++++++++++++-------------------------
 tools/lvmcmdline.c     |    9 +
 tools/tools.h          |    9 +
 4 files changed, 430 insertions(+), 452 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index b54f851..c2995c2 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -239,8 +239,12 @@ OO_LVCHANGE_META: --addtag Tag, --deltag Tag,
 --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB,
 --writebehind Number, --writemostly WriteMostlyPV, --persistent n
 
+# It's unfortunate that activate needs to be optionally allowed here;
+# it should only be used explicitly, but it's been previously allowed
+# in combination with unrelated metadata changes.
+
 lvchange OO_LVCHANGE_META VG|LV|Tag|Select ...
-OO: OO_LVCHANGE
+OO: --activate Active, OO_LVCHANGE
 ID: lvchange_properties
 DESC: Change a general LV property.
 RULE: all not lv_is_pvmove lv_is_mirror_log lv_is_mirror_image
@@ -256,8 +260,11 @@ RULE: --permission not lv_is_external_origin lv_is_raid_metadata lv_is_raid_imag
 RULE: --alloc --contiguous --metadataprofile --permission --persistent --profile --readahead not lv_is_thick_origin
 RULE: --alloc --discards --zero --cachemode --cachepolicy --cachesettings not lv_is_partial
 
+# It's unfortunate that acativate needs to be optionally allowed here,
+# like above, it was previouly allowed in combination.
+
 lvchange --resync VG|LV_raid_mirror|Tag|Select ...
-OO: OO_LVCHANGE
+OO: --activate Active, OO_LVCHANGE
 ID: lvchange_resync
 DESC: Resyncronize a mirror or raid LV.
 RULE: all not lv_is_pvmove lv_is_locked
@@ -275,15 +282,14 @@ ID: lvchange_rebuild
 DESC: Reconstruct data on specific PVs of a raid LV.
 RULE: all not LV_raid0
 
-# try removing the META change options from here?
 lvchange --activate Active VG|LV|Tag|Select ...
 OO: --activationmode ActivationMode, --partial, --ignoreactivationskip,
---ignorelockingfailure, --sysinit, OO_LVCHANGE_META, OO_LVCHANGE
+--ignorelockingfailure, --sysinit, OO_LVCHANGE
 ID: lvchange_activate
 DESC: Activate or deactivate an LV.
 
 lvchange --refresh VG|LV|Tag|Select ...
-OO: --partial, OO_LVCHANGE
+OO: --partial, --poll Bool, OO_LVCHANGE
 ID: lvchange_refresh
 DESC: Reactivate an LV using the latest metadata.
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index d75a8ec..b75d058 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -25,12 +25,6 @@ static int _lvchange_permission(struct cmd_context *cmd,
 
 	lv_access = arg_uint_value(cmd, permission_ARG, 0);
 
-	if (lv_is_external_origin(lv)) {
-		log_error("Cannot change permissions of external origin %s.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	if (!(lv_access & LVM_WRITE) && !(lv->status & LVM_WRITE)) {
 		/* Refresh if it's read-only in metadata but read-write in kernel */
 		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists && !info.read_only) {
@@ -63,20 +57,6 @@ static int _lvchange_permission(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/* Not allowed to change permissions on RAID sub-LVs directly */
-	if (lv_is_raid_metadata(lv) || lv_is_raid_image(lv)) {
-		log_error("Cannot change permissions of RAID %s %s.",
-			  lv_is_raid_image(lv) ? "image" : "metadata area",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	if (!(lv_access & LVM_WRITE) && lv_is_thin_pool(lv)) {
-		log_error("Change permissions of thin pool %s not yet supported.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	if (lv_access & LVM_WRITE) {
 		lv->status |= LVM_WRITE;
 		log_verbose("Setting logical volume %s read/write.",
@@ -100,12 +80,6 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 	unsigned val;
 	thin_discards_t discards;
 
-	if (!lv_is_thin_pool(lv)) {
-		log_error("Logical volume %s is not a thin pool.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	if (arg_is_set(cmd, discards_ARG)) {
 		discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_IGNORE);
 		if (discards != first_seg(lv)->discards) {
@@ -153,10 +127,6 @@ static int _lvchange_monitoring(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/* do not monitor pvmove lv's */
-	if (lv_is_pvmove(lv))
-		return 1;
-
 	if ((dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) &&
 	    !monitor_dev_for_events(cmd, lv, 0, dmeventd_monitor_mode()))
 		return_0;
@@ -280,20 +250,6 @@ static int attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 	return 1;
 }
 
-/*
- * lvchange_refresh
- * @cmd
- * @lv
- *
- * Suspend and resume a logical volume.
- */
-static int _lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
-{
-	log_verbose("Refreshing logical volume %s (if active).", display_lvname(lv));
-
-	return lv_refresh(cmd, lv);
-}
-
 static int _reactivate_lv(struct logical_volume *lv,
 			  int active, int exclusive)
 {
@@ -326,23 +282,6 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 	dm_list_init(&device_list);
 
-	if (seg_is_any_raid0(seg) ||
-	    (!seg_is_mirror(seg) && !seg_is_raid(seg))) {
-		log_error("Unable to resync %s.  It is not RAID4/5/6/10 or mirrored.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	if (lv_is_pvmove(lv)) {
-		log_error("Unable to resync pvmove volume %s.", display_lvname(lv));
-		return 0;
-	}
-
-	if (lv_is_locked(lv)) {
-		log_error("Unable to resync locked volume %s.", display_lvname(lv));
-		return 0;
-	}
-
 	if (lv_is_active_locally(lv)) {
 		if (!lv_check_not_in_use(lv, 1)) {
 			log_error("Can't resync open logical volume %s.",
@@ -691,15 +630,6 @@ static int _lvchange_cache(struct cmd_context *cmd, struct logical_volume *lv)
 
 	if (lv_is_cache(lv))
 		pool_seg = first_seg(pool_seg->pool_lv);
-        else if (!lv_is_cache_pool(lv)) {
-		log_error("LV %s is not a cache LV.", display_lvname(lv));
-		(void) arg_from_list_is_set(cmd, "is supported only with cache or cache pool LVs",
-					    cachemode_ARG,
-					    cachepolicy_ARG,
-					    cachesettings_ARG,
-					    -1);
-		goto out;
-	}
 
 	if (!get_cache_params(cmd, &mode, &name, &settings))
 		goto_out;
@@ -759,12 +689,6 @@ static int _lvchange_rebuild(struct logical_volume *lv)
 	struct arg_value_group_list *group;
 	struct volume_group *vg = lv->vg;
 	struct cmd_context *cmd = vg->cmd;
-	struct lv_segment *raid_seg = first_seg(lv);
-
-	if (!seg_is_raid(raid_seg) || seg_is_any_raid0(raid_seg)) {
-		log_error("--rebuild can only be used with 'raid4/5/6/10' segment types.");
-		return 0;
-	}
 
 	if (!(pv_count = arg_count(cmd, rebuild_ARG))) {
 		log_error("No --rebuild found!");
@@ -815,12 +739,6 @@ static int _lvchange_writemostly(struct logical_volume *lv)
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *raid_seg = first_seg(lv);
 
-	if (!seg_is_raid1(raid_seg)) {
-		log_error("--write%s can only be used with 'raid1' segment type.",
-			  arg_is_set(cmd, writemostly_ARG) ? "mostly" : "behind");
-		return 0;
-	}
-
 	if (arg_is_set(cmd, writebehind_ARG))
 		raid_seg->writebehind = arg_uint_value(cmd, writebehind_ARG, 0);
 
@@ -909,12 +827,6 @@ static int _lvchange_recovery_rate(struct logical_volume *lv)
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *raid_seg = first_seg(lv);
 
-	if (!seg_is_raid(raid_seg)) {
-		log_error("Unable to change the recovery rate of non-RAID "
-			  "logical volume %s.", display_lvname(lv));
-		return 0;
-	}
-
 	if (arg_is_set(cmd, minrecoveryrate_ARG))
 		raid_seg->min_recovery_rate =
 			arg_uint_value(cmd, minrecoveryrate_ARG, 0) / 2;
@@ -982,114 +894,194 @@ static int _lvchange_activation_skip(struct logical_volume *lv)
 	return 1;
 }
 
+/*
+ * For each lvchange command definintion:
+ *
+ * lvchange_foo_cmd(cmd, argc, argv);
+ * . set cmd fields that apply to "foo"
+ * . set any other things that affect behavior of process_each
+ * . process_each_lv(_lvchange_foo_single);
+ *
+ * _lvchange_foo_single(lv);
+ * . _lvchange_foo(lv);
+ * . (or all the code could live in the _single fn)
+ */
 
-static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
-			    struct processing_handle *handle __attribute__((unused)))
+static int _lvchange_properties_single(struct cmd_context *cmd,
+			               struct logical_volume *lv,
+			               struct processing_handle *handle)
 {
 	int doit = 0, docmds = 0;
-	struct logical_volume *origin;
-	char snaps_msg[128];
-
-	if (sigint_caught())
-		return_ECMD_FAILED;
+	int i, opt_enum;
 
-	if (!(lv->vg->status & LVM_WRITE) &&
-	    arg_from_list_is_set(cmd, NULL,
-				 alloc_ARG,
-				 contiguous_ARG,
-				 discards_ARG,
-				 metadataprofile_ARG,
-				 permission_ARG,
-				 persistent_ARG,
-				 profile_ARG,
-				 readahead_ARG,
-				 zero_ARG,
-				 -1)) {
-		log_error("Only -a permitted with read-only volume group %s.",
-			  lv->vg->name);
+	/*
+	 * If a persistent lv lock already exists from activation
+	 * (with the needed mode or higher), this will be a no-op.
+	 * Otherwise, the lv lock will be taken as non-persistent
+	 * and released when this command exits.
+	 */
+	if (!lockd_lv(cmd, lv, "ex", 0)) {
+		stack;
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_origin(lv) && !lv_is_thin_volume(lv) &&
-	    arg_from_list_is_set(cmd, NULL,
-				 alloc_ARG,
-				 contiguous_ARG,
-				 metadataprofile_ARG,
-				 permission_ARG,
-				 persistent_ARG,
-				 profile_ARG,
-				 readahead_ARG,
-				 -1)) {
-		log_error("Can't change logical volume %s under snapshot.",
-			  display_lvname(lv));
-		return ECMD_FAILED;
-	}
+	for (i = 0; i < cmd->command->ro_count; i++) {
+		opt_enum = cmd->command->required_opt_args[i].opt;
 
-	if (lv_is_pvmove(lv)) {
-		log_error("Unable to change pvmove LV %s.", display_lvname(lv));
-		if (arg_is_set(cmd, activate_ARG))
-			log_error("Use 'pvmove --abort' to abandon a pvmove");
-		return ECMD_FAILED;
+		if (!arg_is_set(cmd, opt_enum))
+			continue;
+
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+
+		docmds++;
+
+		switch (opt_enum) {
+		case permission_ARG:
+			doit += _lvchange_permission(cmd, lv);
+			break;
+
+		case alloc_ARG:
+		case contiguous_ARG:
+			doit += _lvchange_alloc(cmd, lv);
+			break;
+
+		case errorwhenfull_ARG:
+			doit += _lvchange_errorwhenfull(cmd, lv);
+			break;
+
+		case readahead_ARG:
+			doit += _lvchange_readahead(cmd, lv);
+			break;
+
+		case persistent_ARG:
+			doit += _lvchange_persistent(cmd, lv);
+			break;
+
+		case discards_ARG:
+		case zero_ARG:
+			doit += _lvchange_pool_update(cmd, lv);
+			break;
+
+		case addtag_ARG:
+		case deltag_ARG:
+			doit += _lvchange_tag(cmd, lv, opt_enum);
+			break;
+
+		case writemostly_ARG:
+		case writebehind_ARG:
+			doit += _lvchange_writemostly(lv);
+			break;
+
+		case minrecoveryrate_ARG:
+		case maxrecoveryrate_ARG:
+			doit += _lvchange_recovery_rate(lv);
+			break;
+
+		case profile_ARG:
+		case metadataprofile_ARG:
+		case detachprofile_ARG:
+			doit += _lvchange_profile(lv);
+			break;
+
+		case setactivationskip_ARG:
+			doit += _lvchange_activation_skip(lv);
+			break;
+
+		case cachemode_ARG:
+		case cachepolicy_ARG:
+		case cachesettings_ARG:
+			doit += _lvchange_cache(cmd, lv);
+			break;
+
+		default:
+			log_error(INTERNAL_ERROR "Failed to check for option %s",
+				  arg_long_option_name(i));
+		}
 	}
 
-	if (lv_is_mirror_log(lv)) {
-		log_error("Unable to change mirror log LV %s directly.",
-			  display_lvname(lv));
-		return ECMD_FAILED;
+	if (doit)
+		log_print_unless_silent("Logical volume %s changed.", display_lvname(lv));
+
+	if (doit != docmds)
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+static int _lvchange_properties_check(struct cmd_context *cmd,
+				     struct logical_volume *lv,
+				     struct processing_handle *handle,
+				     int lv_is_named_arg)
+{
+	if (!lv_is_visible(lv)) {
+		if (lv_is_named_arg)
+			log_error("Operation not permitted (%s %d) on hidden LV %s.",
+				  cmd->command->command_line_id, cmd->command->command_line_enum,
+				  display_lvname(lv));
+		return 0;
 	}
 
-	if (lv_is_mirror_image(lv)) {
-		log_error("Unable to change mirror image LV %s directly.",
+	if (vg_is_clustered(lv->vg) && lv_is_cache_origin(lv) && lv_is_raid(lv)) {
+		log_error("Unable to change internal LV %s directly in a cluster.",
 			  display_lvname(lv));
-		return ECMD_FAILED;
+		return 0;
 	}
 
-	/* If LV is sparse, activate origin instead */
-	if (arg_is_set(cmd, activate_ARG) && lv_is_cow(lv) &&
-	    lv_is_virtual_origin(origin = origin_from_cow(lv)))
-		lv = origin;
+	return 1;
+}
 
-	/* Use cache origin LV for 'raid' actions */
-	if (lv_is_cache(lv) &&
-	    arg_from_list_is_set(cmd, NULL,
-				 /* FIXME: we want to support more ops here */
-				 //resync_ARG,
-				 syncaction_ARG,
-				 -1)) {
-		lv = seg_lv(first_seg(lv), 0);
-		log_debug("Using cache origin volume %s for lvchange instead.",
-			  display_lvname(lv));
-	}
+int lvchange_properties_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	int ret;
 
-	if ((lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv) ||
-	     lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) &&
-	    !arg_is_set(cmd, activate_ARG) &&
-	    !arg_is_set(cmd, permission_ARG) &&
-	    !arg_is_set(cmd, setactivationskip_ARG))
-	    /* Rest can be changed for stacked thin pool meta/data volumes */
-	    ;
-	else if (lv_is_cache_origin(lv) && lv_is_raid(lv)) {
-		if (vg_is_clustered(lv->vg)) {
-			log_error("Unable to change internal LV %s directly in a cluster.",
-				  display_lvname(lv));
-			return ECMD_FAILED;
-		}
-		/*
-		 * FIXME:  For now, we don't want to allow all kinds of
-		 * operations on this cache origin sub-LV.  We are going
-		 * to restrict it to non-clustered, RAID.  This way, we
-		 * can change the syncaction as needed (e.g. initiate
-		 * scrubbing).
-		 *
-		 * Later pass all 'cache' actions on cache origin.
-		 */
-	} else if (!lv_is_visible(lv) && !lv_is_virtual_origin(lv)) {
-		log_error("Unable to change internal LV %s directly.",
-			  display_lvname(lv));
-		return ECMD_FAILED;
+	/*
+	 * A command def rule allows only some options when LV is partial,
+	 * so handles_missing_pvs will only affect those.
+	 */
+	cmd->handles_missing_pvs = 1;
+	ret = process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
+			      NULL, &_lvchange_properties_check, &_lvchange_properties_single);
+
+	if (ret != ECMD_PROCESSED)
+		return ret;
+
+	/*
+	 * Unfortunately, lvchange has previously allowed changing an LV
+	 * property and changing LV activation in a single command.  This was
+	 * not a good idea because the behavior/results are hard to predict and
+	 * not possible to sensibly describe.  It's also unnecessary.  So, this
+	 * is here for the sake of compatibility.
+	 *
+	 * This is extremely ugly; activation should always be done separately.
+	 * This is not the full-featured lvchange capability, just the basic
+	 * (the advanced activate options are not provided.)
+	 *
+	 * FIXME: wrap this in a config setting that we can disable by default
+	 * to phase this out?
+	 */
+	if (arg_is_set(cmd, activate_ARG)) {
+		log_warn("WARNING: Combining activation change with other commands is not advised.");
+		ret = lvchange_activate_cmd(cmd, argc, argv);
 	}
 
-	if (lv_is_cow(lv) && arg_is_set(cmd, activate_ARG)) {
+	return ret;
+}
+
+static int _lvchange_activate_single(struct cmd_context *cmd,
+				     struct logical_volume *lv,
+				     struct processing_handle *handle)
+{
+	struct logical_volume *origin;
+	char snaps_msg[128];
+
+	/* FIXME: untangle the proper logic for cow / sparse / virtual origin */
+
+	/* If LV is sparse, activate origin instead */
+	if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
+		lv = origin;
+
+	if (lv_is_cow(lv)) {
 		origin = origin_from_cow(lv);
 		if (origin->origin_count < 2)
 			snaps_msg[0] = '\0';
@@ -1110,329 +1102,291 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (arg_is_set(cmd, errorwhenfull_ARG) && !lv_is_thin_pool(lv)) {
-		log_error("Option --errorwhenfull is only supported with thin pools.");
-		return ECMD_FAILED;
+	/*
+	 * If --sysinit -aay is used and at the same time lvmetad is used,
+	 * we want to rely on autoactivation to take place. Also, we
+	 * need to take special care here as lvmetad service does
+	 * not neet to be running@this moment yet - it could be
+	 * just too early during system initialization time.
+	 */
+	if (arg_is_set(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
+		if (lvmetad_used()) {
+			log_warn("WARNING: lvmetad is active, skipping direct activation during sysinit.");
+			return ECMD_PROCESSED;
+		}
 	}
 
-	if (arg_is_set(cmd, persistent_ARG) && lv_is_pool(lv)) {
-		log_error("Persistent major and minor numbers are not supported with pools.");
-		return ECMD_FAILED;
-	}
+	if (!_lvchange_activate(cmd, lv))
+		return_ECMD_FAILED;
 
-	if (!arg_is_set(cmd, activate_ARG) && !arg_is_set(cmd, refresh_ARG)) {
-		/*
-		 * If a persistent lv lock already exists from activation
-		 * (with the needed mode or higher), this will be a no-op.
-		 * Otherwise, the lv lock will be taken as non-persistent
-		 * and released when this command exits.
-		 *
-		 * FIXME: use "sh" if the options imply that the lvchange
-		 * operation does not modify the LV.
-		 */
-		if (!lockd_lv(cmd, lv, "ex", 0)) {
-			stack;
-			return ECMD_FAILED;
-		}
+	return ECMD_PROCESSED;
+}
+
+static int _lvchange_activate_check(struct cmd_context *cmd,
+				     struct logical_volume *lv,
+				     struct processing_handle *handle,
+				     int lv_is_named_arg)
+{
+	if (!lv_is_visible(lv)) {
+		if (lv_is_named_arg)
+			log_error("Operation not permitted (%s %d) on hidden LV %s.",
+				  cmd->command->command_line_id, cmd->command->command_line_enum,
+				  display_lvname(lv));
+		return 0;
 	}
 
+	return 1;
+}
+
+int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	cmd->handles_missing_pvs = 1;
+	cmd->lockd_vg_default_sh = 1;
+
 	/*
-	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
-	 * If --poll is explicitly provided use it; otherwise polling
-	 * should only be started if the LV is not already active. So:
-	 * 1) change the activation code to say if the LV was actually activated
-	 * 2) make polling of an LV tightly coupled with LV activation
-	 *
-	 * Do not initiate any polling if --sysinit option is used.
+	 * Include foreign VGs that contain active LVs.
+	 * That shouldn't happen in general, but if it does by some
+	 * mistake, then we want to allow those LVs to be deactivated.
 	 */
-	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 :
-						arg_int_value(cmd, poll_ARG,
-						DEFAULT_BACKGROUND_POLLING));
+	cmd->include_active_foreign_vgs = 1;
 
-	/* access permission change */
-	if (arg_is_set(cmd, permission_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_permission(cmd, lv);
-		docmds++;
-	}
+	/* Allow deactivating if locks fail. */
+	if (is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
+		cmd->lockd_vg_enforce_sh = 1;
 
-	/* allocation policy change */
-	if (arg_is_set(cmd, contiguous_ARG) || arg_is_set(cmd, alloc_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_alloc(cmd, lv);
-		docmds++;
-	}
+	return process_each_lv(cmd, argc, argv, NULL, NULL, 0,
+			       NULL, &_lvchange_activate_check, &_lvchange_activate_single);
+}
 
-	/* error when full change */
-	if (arg_is_set(cmd, errorwhenfull_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_errorwhenfull(cmd, lv);
-		docmds++;
-	}
+static int _lvchange_refresh_single(struct cmd_context *cmd,
+				    struct logical_volume *lv,
+				    struct processing_handle *handle)
+{
+	log_verbose("Refreshing logical volume %s (if active).", display_lvname(lv));
 
-	/* read ahead sector change */
-	if (arg_is_set(cmd, readahead_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_readahead(cmd, lv);
-		docmds++;
-	}
+	if (!lv_refresh(cmd, lv))
+		return_ECMD_FAILED;
 
-	/* persistent device number change */
-	if (arg_is_set(cmd, persistent_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_persistent(cmd, lv);
-		docmds++;
-	}
+	/*
+	 * FIXME: In some cases, the lv_refresh() starts polling without
+	 * checking poll arg.  Pull that out of lv_refresh.
+	 */
+	if (arg_is_set(cmd, poll_ARG) &&
+	    !_lvchange_background_polling(cmd, lv))
+		return_ECMD_FAILED;
 
-	if (arg_is_set(cmd, discards_ARG) ||
-	    arg_is_set(cmd, zero_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_pool_update(cmd, lv);
-		docmds++;
-	}
+	return ECMD_PROCESSED;
+}
 
-	/* add tag */
-	if (arg_is_set(cmd, addtag_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_tag(cmd, lv, addtag_ARG);
-		docmds++;
+static int _lvchange_refresh_check(struct cmd_context *cmd,
+				       struct logical_volume *lv,
+				       struct processing_handle *handle,
+				       int lv_is_named_arg)
+{
+	if (!lv_is_visible(lv)) {
+		if (lv_is_named_arg)
+			log_error("Operation not permitted (%s %d) on hidden LV %s.",
+				  cmd->command->command_line_id, cmd->command->command_line_enum,
+				  display_lvname(lv));
+		return 0;
 	}
 
-	/* del tag */
-	if (arg_is_set(cmd, deltag_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_tag(cmd, lv, deltag_ARG);
-		docmds++;
-	}
+	return 1;
+}
 
-	/* rebuild selected PVs */
-	if (arg_is_set(cmd, rebuild_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_rebuild(lv);
-		docmds++;
-	}
+int lvchange_refresh_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	cmd->handles_missing_pvs = 1;
+	cmd->lockd_vg_default_sh = 1;
 
-	/* change writemostly/writebehind */
-	if (arg_is_set(cmd, writemostly_ARG) || arg_is_set(cmd, writebehind_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_writemostly(lv);
-		docmds++;
-	}
+	return process_each_lv(cmd, argc, argv, NULL, NULL, 0,
+			       NULL, &_lvchange_refresh_check, &_lvchange_refresh_single);
+}
 
-	/* change [min|max]_recovery_rate */
-	if (arg_is_set(cmd, minrecoveryrate_ARG) ||
-	    arg_is_set(cmd, maxrecoveryrate_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_recovery_rate(lv);
-		docmds++;
-	}
+static int _lvchange_resync_single(struct cmd_context *cmd,
+				    struct logical_volume *lv,
+				    struct processing_handle *handle)
+{
+	if (!_lvchange_resync(cmd, lv))
+		return_ECMD_FAILED;
 
-	/* change configuration profile */
-	if (arg_is_set(cmd, profile_ARG) || arg_is_set(cmd, metadataprofile_ARG) ||
-	    arg_is_set(cmd, detachprofile_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_profile(lv);
-		docmds++;
-	}
+	return ECMD_PROCESSED;
+}
 
-	if (arg_is_set(cmd, setactivationskip_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_activation_skip(lv);
-		docmds++;
+static int _lvchange_resync_check(struct cmd_context *cmd,
+				       struct logical_volume *lv,
+				       struct processing_handle *handle,
+				       int lv_is_named_arg)
+{
+	if (!lv_is_visible(lv)) {
+		if (lv_is_named_arg)
+			return 1;
+		return 0;
 	}
 
-	if (arg_is_set(cmd, cachemode_ARG) ||
-	    arg_is_set(cmd, cachepolicy_ARG) || arg_is_set(cmd, cachesettings_ARG)) {
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-		doit += _lvchange_cache(cmd, lv);
-		docmds++;
+	return 1;
+}
+
+int lvchange_resync_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	int ret;
+
+	ret = process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
+			      NULL, &_lvchange_resync_check, &_lvchange_resync_single);
+
+	if (ret != ECMD_PROCESSED)
+		return ret;
+
+	/*
+	 * Unfortunately, lvchange has previously allowed resync and changing
+	 * activation to be combined in one command.  activate should be
+	 * done separately, but this is here to avoid breaking commands that
+	 * used this.
+	 *
+	 * FIXME: wrap this in a config setting that we can disable by default
+	 * to phase this out?
+	 */
+	if (arg_is_set(cmd, activate_ARG)) {
+		log_warn("WARNING: Combining activation change with other commands is not advised.");
+		ret = lvchange_activate_cmd(cmd, argc, argv);
 	}
 
-	if (doit)
-		log_print_unless_silent("Logical volume %s changed.", display_lvname(lv));
+	return ret;
+}
 
-	if (arg_is_set(cmd, resync_ARG) &&
-	    !_lvchange_resync(cmd, lv))
+static int _lvchange_syncaction_single(struct cmd_context *cmd,
+				       struct logical_volume *lv,
+				       struct processing_handle *handle)
+{
+	if (!lv_raid_message(lv, arg_str_value(cmd, syncaction_ARG, NULL)))
 		return_ECMD_FAILED;
 
-	if (arg_is_set(cmd, syncaction_ARG)) {
-		struct lv_segment *seg = first_seg(lv);
+	return ECMD_PROCESSED;
+}
 
-		if (seg_is_any_raid0(seg)) {
-			log_error("Unable to sync raid0 LV %s.", display_lvname(lv));
-			return_ECMD_FAILED;
-		}
-		
-		if (!lv_raid_message(lv, arg_str_value(cmd, syncaction_ARG, NULL)))
-			return_ECMD_FAILED;
+static int _lvchange_syncaction_check(struct cmd_context *cmd,
+				       struct logical_volume *lv,
+				       struct processing_handle *handle,
+				       int lv_is_named_arg)
+{
+	if (!lv_is_visible(lv)) {
+		if (lv_is_named_arg)
+			return 1;
+		return 0;
 	}
 
-	/* activation change */
-	if (arg_is_set(cmd, activate_ARG)) {
-		if (!_lvchange_activate(cmd, lv))
-			return_ECMD_FAILED;
-	} else if (arg_is_set(cmd, refresh_ARG)) {
-		if (!_lvchange_refresh(cmd, lv))
-			return_ECMD_FAILED;
-	} else {
-		if (arg_is_set(cmd, monitor_ARG) &&
-		    !_lvchange_monitoring(cmd, lv))
-			return_ECMD_FAILED;
+	return 1;
+}
 
-		if (arg_is_set(cmd, poll_ARG) &&
-		    !_lvchange_background_polling(cmd, lv))
-			return_ECMD_FAILED;
-	}
+int lvchange_syncaction_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, &_lvchange_syncaction_check, &_lvchange_syncaction_single);
+}
 
-	if (doit != docmds)
+static int _lvchange_rebuild_single(struct cmd_context *cmd,
+				    struct logical_volume *lv,
+				    struct processing_handle *handle)
+{
+	if (!_lvchange_rebuild(lv))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
 
-int lvchange(struct cmd_context *cmd, int argc, char **argv)
+static int _lvchange_rebuild_check(struct cmd_context *cmd,
+				     struct logical_volume *lv,
+				     struct processing_handle *handle,
+				     int lv_is_named_arg)
 {
-	/*
-	 * Options that update metadata should be listed in one of
-	 * the two lists below (i.e. options other than -a, --refresh,
-	 * --monitor or --poll).
-	 */
-	int update_partial_safe = /* options safe to update if partial */
-		arg_from_list_is_set(cmd, NULL,
-				     addtag_ARG,
-				     contiguous_ARG,
-				     deltag_ARG,
-				     detachprofile_ARG,
-				     metadataprofile_ARG,
-				     permission_ARG,
-				     persistent_ARG,
-				     profile_ARG,
-				     readahead_ARG,
-				     setactivationskip_ARG,
-				     -1);
-	int update_partial_unsafe =
-		arg_from_list_is_set(cmd, NULL,
-				     alloc_ARG,
-				     cachemode_ARG,
-				     cachepolicy_ARG,
-				     cachesettings_ARG,
-				     discards_ARG,
-				     errorwhenfull_ARG,
-				     maxrecoveryrate_ARG,
-				     minrecoveryrate_ARG,
-				     rebuild_ARG,
-				     resync_ARG,
-				     syncaction_ARG,
-				     writebehind_ARG,
-				     writemostly_ARG,
-				     zero_ARG,
-				     -1);
-	int update = update_partial_safe || update_partial_unsafe;
-
-	if (!update &&
-	    !arg_is_set(cmd, activate_ARG) && !arg_is_set(cmd, refresh_ARG) &&
-	    !arg_is_set(cmd, monitor_ARG) && !arg_is_set(cmd, poll_ARG)) {
-		log_error("Need 1 or more of -a, -C, -M, -p, -r, -Z, "
-			  "--resync, --refresh, --alloc, --addtag, --deltag, "
-			  "--monitor, --poll or --discards");
-		return EINVALID_CMD_LINE;
+	if (!lv_is_visible(lv)) {
+		if (lv_is_named_arg)
+			return 1;
+		return 0;
 	}
 
-	if ((arg_is_set(cmd, profile_ARG) || arg_is_set(cmd, metadataprofile_ARG)) &&
-	     arg_is_set(cmd, detachprofile_ARG)) {
-		log_error("Only one of --metadataprofile and --detachprofile permitted.");
-		return EINVALID_CMD_LINE;
-	}
+	return 1;
+}
 
-	if (arg_is_set(cmd, activate_ARG) && arg_is_set(cmd, refresh_ARG)) {
-		log_error("Only one of -a and --refresh permitted.");
-		return EINVALID_CMD_LINE;
-	}
+int lvchange_rebuild_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, &_lvchange_rebuild_check, &_lvchange_rebuild_single);
+}
 
-	if ((arg_is_set(cmd, ignorelockingfailure_ARG) ||
-	     arg_is_set(cmd, sysinit_ARG)) && update) {
-		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
-		return EINVALID_CMD_LINE;
-	}
+static int _lvchange_monitor_poll_single(struct cmd_context *cmd,
+				         struct logical_volume *lv,
+				         struct processing_handle *handle)
+{
+	if (arg_is_set(cmd, monitor_ARG) &&
+	    !_lvchange_monitoring(cmd, lv))
+		return_ECMD_FAILED;
 
-	if (!update || !update_partial_unsafe)
-		cmd->handles_missing_pvs = 1;
+	if (arg_is_set(cmd, poll_ARG) &&
+	    !_lvchange_background_polling(cmd, lv))
+		return_ECMD_FAILED;
 
-	if (!argc && !arg_is_set(cmd, select_ARG)) {
-		log_error("Please give logical volume path(s) or use --select for selection.");
-		return EINVALID_CMD_LINE;
-	}
+	return ECMD_PROCESSED;
+}
 
-	if ((arg_is_set(cmd, minor_ARG) || arg_is_set(cmd, major_ARG)) &&
-	    !arg_is_set(cmd, persistent_ARG)) {
-		log_error("--major and --minor require -My.");
-		return EINVALID_CMD_LINE;
+static int _lvchange_monitor_poll_check(struct cmd_context *cmd,
+				     struct logical_volume *lv,
+				     struct processing_handle *handle,
+				     int lv_is_named_arg)
+{
+	if (!lv_is_visible(lv)) {
+		if (lv_is_named_arg)
+			return 1;
+		return 0;
 	}
 
-	if (arg_is_set(cmd, minor_ARG) && argc != 1) {
-		log_error("Only give one logical volume when specifying minor.");
-		return EINVALID_CMD_LINE;
-	}
+	return 1;
+}
 
-	if (arg_is_set(cmd, contiguous_ARG) && arg_is_set(cmd, alloc_ARG)) {
-		log_error("Only one of --alloc and --contiguous permitted.");
-		return EINVALID_CMD_LINE;
-	}
+int lvchange_monitor_poll_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	cmd->handles_missing_pvs = 1;
+	return process_each_lv(cmd, argc, argv, NULL, NULL, 0,
+			       NULL, &_lvchange_monitor_poll_check, &_lvchange_monitor_poll_single);
+}
 
-	if (arg_is_set(cmd, poll_ARG) && arg_is_set(cmd, sysinit_ARG)) {
-		log_error("Only one of --poll and --sysinit permitted.");
-		return EINVALID_CMD_LINE;
-	}
+static int _lvchange_persistent_single(struct cmd_context *cmd,
+				       struct logical_volume *lv,
+				       struct processing_handle *handle)
+{
+	if (!_lvchange_persistent(cmd, lv))
+		return_ECMD_FAILED;
 
-	/*
-	 * If --sysinit -aay is used and at the same time lvmetad is used,
-	 * we want to rely on autoactivation to take place. Also, we
-	 * need to take special care here as lvmetad service does
-	 * not neet to be running at this moment yet - it could be
-	 * just too early during system initialization time.
-	 */
-	if (arg_is_set(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
-		if (lvmetad_used()) {
-			log_warn("WARNING: lvmetad is active, skipping direct activation during sysinit.");
-			return ECMD_PROCESSED;
-		}
+	return ECMD_PROCESSED;
+}
+
+static int _lvchange_persistent_check(struct cmd_context *cmd,
+				     struct logical_volume *lv,
+				     struct processing_handle *handle,
+				     int lv_is_named_arg)
+{
+	if (!lv_is_visible(lv)) {
+		if (lv_is_named_arg)
+			log_error("Operation not permitted (%s %d) on hidden LV %s.",
+				  cmd->command->command_line_id, cmd->command->command_line_enum,
+				  display_lvname(lv));
+		return 0;
 	}
 
-	/*
-	 * Include foreign VGs that contain active LVs.
-	 * That shouldn't happen in general, but if it does by some
-	 * mistake, then we want to allow those LVs to be deactivated.
-	 */
-	if (arg_is_set(cmd, activate_ARG))
-		cmd->include_active_foreign_vgs = 1;
+	return 1;
+}
 
-	/*
-	 * The default vg lock mode for lvchange is ex, but these options
-	 * are cases where lvchange does not modify the vg, so they can use
-	 * the sh lock mode.
-	 */
-	if (arg_is_set(cmd, activate_ARG) || arg_is_set(cmd, refresh_ARG)) {
-		cmd->lockd_vg_default_sh = 1;
-		/* Allow deactivating if locks fail. */
-		if (is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
-			cmd->lockd_vg_enforce_sh = 1;
-	}
+int lvchange_persistent_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	cmd->handles_missing_pvs = 1;
+	return process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, &_lvchange_persistent_check, &_lvchange_persistent_single);
+}
 
-	return process_each_lv(cmd, argc, argv, NULL, NULL,
-			       update ? READ_FOR_UPDATE : 0, NULL,
-			       NULL, &_lvchange_single);
+int lvchange(struct cmd_context *cmd, int argc, char **argv)
+{
+	log_error(INTERNAL_ERROR "Missing function for command definition %s.",
+		  cmd->command->command_line_id);
+	return ECMD_FAILED;
 }
+
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 231ef68..d1613e1 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -113,6 +113,15 @@ static struct cmdline_context _cmdline;
  */
 struct command_function command_functions[COMMAND_ID_COUNT] = {
 	{ lvmconfig_general_CMD, lvmconfig },
+	{ lvchange_properties_CMD, lvchange_properties_cmd },
+	{ lvchange_resync_CMD, lvchange_resync_cmd },
+	{ lvchange_syncaction_CMD, lvchange_syncaction_cmd },
+	{ lvchange_rebuild_CMD, lvchange_rebuild_cmd },
+	{ lvchange_activate_CMD, lvchange_activate_cmd },
+	{ lvchange_refresh_CMD, lvchange_refresh_cmd },
+	{ lvchange_monitor_CMD, lvchange_monitor_poll_cmd },
+	{ lvchange_poll_CMD, lvchange_monitor_poll_cmd },
+	{ lvchange_persistent_CMD, lvchange_persistent_cmd },
 };
 #if 0
 	/* all raid-related type conversions */
diff --git a/tools/tools.h b/tools/tools.h
index dbf8a17..c42119c 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -242,4 +242,13 @@ int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg
 struct lv_props *get_lv_prop(int lvp_enum);
 struct lv_types *get_lv_type(int lvt_enum);
 
+int lvchange_properties_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvchange_refresh_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvchange_resync_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvchange_syncaction_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvchange_rebuild_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvchange_monitor_poll_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvchange_persistent_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 #endif



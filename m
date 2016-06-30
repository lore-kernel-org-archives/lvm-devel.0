From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Jun 2016 22:46:09 +0000 (UTC)
Subject: master - cleanup: lvchange uses display_lvname
Message-ID: <20160630224609.47C58611AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fd458488649c27f18f1ddb993ba9360f259d47b
Commit:        3fd458488649c27f18f1ddb993ba9360f259d47b
Parent:        b9d3e8c8a8cd5faf23e30336303f6aeef5c32804
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 30 10:45:58 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 1 00:44:48 2016 +0200

cleanup: lvchange uses display_lvname

Convert messages to report vg/lv name consistently.

Also drop unneeded 'info_obtaned' variable since the
obtained info is not reused in any code path.
---
 tools/lvchange.c |  212 +++++++++++++++++++++++++++---------------------------
 1 files changed, 107 insertions(+), 105 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index b9944f7..c5461f9 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -22,72 +22,69 @@ static int _lvchange_permission(struct cmd_context *cmd,
 {
 	uint32_t lv_access;
 	struct lvinfo info;
-	unsigned info_obtained = 0;
 
 	lv_access = arg_uint_value(cmd, permission_ARG, 0);
 
 	if (lv_is_external_origin(lv)) {
-		log_error("Cannot change permissions of external origin "
-			  "\"%s\".", lv->name);
+		log_error("Cannot change permissions of external origin %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (!(lv_access & LVM_WRITE) && !(lv->status & LVM_WRITE)) {
 		/* Refresh if it's read-only in metadata but read-write in kernel */
-		if (lv_info(cmd, lv, 0, &info, 0, 0) &&
-		    (info_obtained = 1, info.exists) && !info.read_only) {
-			log_print_unless_silent("Logical volume \"%s\" is already read-only.  Refreshing kernel state.",
-						lv->name);
+		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists && !info.read_only) {
+			log_print_unless_silent("Logical volume %s is already read-only.  Refreshing kernel state.",
+						display_lvname(lv));
 			return lv_refresh(cmd, lv);
 		}
-		log_error("Logical volume \"%s\" is already read only",
-			  lv->name);
+		log_error("Logical volume \"%s\" is already read only.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if ((lv_access & LVM_WRITE) && (lv->status & LVM_WRITE)) {
 		/* Refresh if it's read-write in metadata but read-only in kernel */
-		if (lv_info(cmd, lv, 0, &info, 0, 0) &&
-		    (info_obtained = 1, info.exists) && info.read_only) {
-			log_print_unless_silent("Logical volume \"%s\" is already writable.  Refreshing kernel state.",
-						lv->name);
+		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists && info.read_only) {
+			log_print_unless_silent("Logical volume %s is already writable.  Refreshing kernel state.",
+						display_lvname(lv));
 			return lv_refresh(cmd, lv);
 		}
 
-		log_error("Logical volume \"%s\" is already writable",
-			  lv->name);
+		log_error("Logical volume %s is already writable.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_mirrored(lv) && vg_is_clustered(lv->vg) &&
-	    (info_obtained || lv_info(cmd, lv, 0, &info, 0, 0)) && info.exists) {
-		log_error("Cannot change permissions of mirror \"%s\" "
-			  "while active.", lv->name);
+	    lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
+		log_error("Cannot change permissions of mirror %s while active.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	/* Not allowed to change permissions on RAID sub-LVs directly */
 	if (lv_is_raid_metadata(lv) || lv_is_raid_image(lv)) {
-		log_error("Cannot change permissions of RAID %s \"%s\"",
-			  lv_is_raid_image(lv) ? "image" :
-			  "metadata area", lv->name);
+		log_error("Cannot change permissions of RAID %s %s.",
+			  lv_is_raid_image(lv) ? "image" : "metadata area",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (!(lv_access & LVM_WRITE) && lv_is_thin_pool(lv)) {
-		log_error("Change permissions of thin pool \"%s\" not "
-			  "yet supported.", lv->name);
+		log_error("Change permissions of thin pool %s not yet supported.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_access & LVM_WRITE) {
 		lv->status |= LVM_WRITE;
-		log_verbose("Setting logical volume \"%s\" read/write",
-			    lv->name);
+		log_verbose("Setting logical volume %s read/write.",
+			    display_lvname(lv));
 	} else {
 		lv->status &= ~LVM_WRITE;
-		log_verbose("Setting logical volume \"%s\" read-only",
-			    lv->name);
+		log_verbose("Setting logical volume %s read-only.",
+			    display_lvname(lv));
 	}
 
 	if (!lv_update_and_reload(lv))
@@ -104,7 +101,8 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 	thin_discards_t discards;
 
 	if (!lv_is_thin_pool(lv)) {
-		log_error("Logical volume \"%s\" is not a thin pool.", lv->name);
+		log_error("Logical volume %s is not a thin pool.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -114,14 +112,15 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 			if (((discards == THIN_DISCARDS_IGNORE) ||
 			     (first_seg(lv)->discards == THIN_DISCARDS_IGNORE)) &&
 			    pool_is_active(lv))
-				log_error("Cannot change support for discards while pool volume \"%s\" is active.", lv->name);
+				log_error("Cannot change support for discards while pool volume %s is active.",
+					  display_lvname(lv));
 			else {
 				first_seg(lv)->discards = discards;
 				update++;
 			}
 		} else
-			log_error("Logical volume \"%s\" already uses --discards %s.",
-				  lv->name, get_pool_discards_name(discards));
+			log_error("Logical volume %s already uses --discards %s.",
+				  display_lvname(lv), get_pool_discards_name(discards));
 	}
 
 	if (arg_is_set(cmd, zero_ARG)) {
@@ -130,8 +129,8 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 			first_seg(lv)->zero_new_blocks = val;
 			update++;
 		} else
-			log_error("Logical volume \"%s\" already %szero new blocks.",
-				  lv->name, val ? "" : "does not ");
+			log_error("Logical volume %s already %szero new blocks.",
+				  display_lvname(lv), val ? "" : "does not ");
 	}
 
 	if (!update)
@@ -150,7 +149,7 @@ static int _lvchange_monitoring(struct cmd_context *cmd,
 
 	if (!lv_info(cmd, lv, lv_is_thin_pool(lv) ? 1 : 0,
 		     &info, 0, 0) || !info.exists) {
-		log_error("Logical volume, %s, is not active", lv->name);
+		log_error("Logical volume %s is not active.", display_lvname(lv));
 		return 0;
 	}
 
@@ -171,7 +170,7 @@ static int _lvchange_background_polling(struct cmd_context *cmd,
 	struct lvinfo info;
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists) {
-		log_error("Logical volume, %s, is not active", lv->name);
+		log_error("Logical volume %s is not active.", display_lvname(lv));
 		return 0;
 	}
 
@@ -290,7 +289,7 @@ static int attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
  */
 static int _lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	log_verbose("Refreshing logical volume \"%s\" (if active)", lv->name);
+	log_verbose("Refreshing logical volume %s (if active).", display_lvname(lv));
 
 	return lv_refresh(cmd, lv);
 }
@@ -329,33 +328,33 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 	if (!seg_is_mirror(seg) && !seg_is_raid(seg)) {
 		log_error("Unable to resync %s.  It is not RAID or mirrored.",
-			  lv->name);
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_pvmove(lv)) {
-		log_error("Unable to resync pvmove volume %s", lv->name);
+		log_error("Unable to resync pvmove volume %s.", display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_locked(lv)) {
-		log_error("Unable to resync locked volume %s", lv->name);
+		log_error("Unable to resync locked volume %s.", display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_active_locally(lv)) {
 		if (!lv_check_not_in_use(lv, 1)) {
-			log_error("Can't resync open logical volume \"%s\"",
-				  lv->name);
+			log_error("Can't resync open logical volume %s.",
+				  display_lvname(lv));
 			return 0;
 		}
 
 		if (!arg_is_set(cmd, yes_ARG) &&
 		    yes_no_prompt("Do you really want to deactivate "
 				  "logical volume %s to resync it? [y/n]: ",
-				  lv->name) == 'n') {
-			log_error("Logical volume \"%s\" not resynced",
-				  lv->name);
+				  display_lvname(lv)) == 'n') {
+			log_error("Logical volume %s not resynced.",
+				  display_lvname(lv));
 			return 0;
 		}
 
@@ -365,8 +364,8 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	}
 
 	if (seg_is_raid(seg) && active && !exclusive) {
-		log_error("RAID logical volume %s/%s cannot be active remotely.",
-			  lv->vg->name, lv->name);
+		log_error("RAID logical volume %s cannot be active remotely.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -376,13 +375,13 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		init_dmeventd_monitor(0);
 
 	if (!deactivate_lv(cmd, lv)) {
-		log_error("Unable to deactivate %s for resync", lv->name);
+		log_error("Unable to deactivate %s for resync.", display_lvname(lv));
 		return 0;
 	}
 
 	if (vg_is_clustered(lv->vg) && lv_is_active(lv)) {
-		log_error("Can't get exclusive access to clustered volume %s",
-			  lv->name);
+		log_error("Can't get exclusive access to clustered volume %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -390,12 +389,12 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		init_dmeventd_monitor(monitored);
 	init_mirror_in_sync(0);
 
-	log_very_verbose("Starting resync of %s%s%s%s \"%s\"",
+	log_very_verbose("Starting resync of %s%s%s%s %s.",
 			 (active) ? "active " : "",
 			 vg_is_clustered(lv->vg) ? "clustered " : "",
 			 (seg->log_lv) ? "disk-logged " :
 			 seg_is_raid(seg) ? "" : "core-logged ",
-			 lvseg_name(seg), lv->name);
+			 lvseg_name(seg), display_lvname(lv));
 
 	/*
 	 * If this mirror has a core log (i.e. !seg->log_lv),
@@ -406,8 +405,8 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	if (!seg_is_raid(seg) && !seg->log_lv) {
 		if (lv->status & LV_NOTSYNCED) {
 			lv->status &= ~LV_NOTSYNCED;
-			log_very_verbose("Updating logical volume \"%s\""
-					 " on disk(s)", lv->name);
+			log_very_verbose("Updating logical volume %s on disk(s).",
+					 display_lvname(lv));
 			if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
 				log_error("Failed to update metadata on disk.");
 				return 0;
@@ -415,8 +414,8 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		}
 
 		if (!_reactivate_lv(lv, active, exclusive)) {
-			log_error("Failed to reactivate %s to resynchronize "
-				  "mirror", lv->name);
+			log_error("Failed to reactivate %s to resynchronize mirror.",
+				  display_lvname(lv));
 			return 0;
 		}
 
@@ -430,9 +429,9 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 	/* Separate mirror log or metadata devices so we can clear them */
 	if (!detach_metadata_devices(seg, &device_list)) {
-		log_error("Failed to clear %s %s for %s",
+		log_error("Failed to clear %s %s for %s.",
 			  seg->segtype->name, seg_is_raid(seg) ?
-			  "metadata area" : "mirror log", lv->name);
+			  "metadata area" : "mirror log", display_lvname(lv));
 		return 0;
 	}
 
@@ -448,16 +447,16 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 	dm_list_iterate_items(lvl, &device_list) {
 		if (!activate_lv_excl_local(cmd, lvl->lv)) {
-			log_error("Unable to activate %s for %s clearing",
-				  lvl->lv->name, (seg_is_raid(seg)) ?
+			log_error("Unable to activate %s for %s clearing.",
+				  display_lvname(lvl->lv), (seg_is_raid(seg)) ?
 				  "metadata area" : "mirror log");
 			return 0;
 		}
 
 		if (!wipe_lv(lvl->lv, (struct wipe_params)
 			     { .do_zero = 1, .zero_sectors = lvl->lv->size })) {
-			log_error("Unable to reset sync status for %s",
-				  lv->name);
+			log_error("Unable to reset sync status for %s.",
+				  display_lvname(lv));
 			if (!deactivate_lv(cmd, lvl->lv))
 				log_error("Failed to deactivate log LV after "
 					  "wiping failed");
@@ -466,36 +465,37 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 		if (!deactivate_lv(cmd, lvl->lv)) {
 			log_error("Unable to deactivate %s LV %s "
-				  "after wiping for resync",
+				  "after wiping for resync.",
 				  (seg_is_raid(seg)) ? "metadata" : "log",
-				  lvl->lv->name);
+				  display_lvname(lvl->lv));
 			return 0;
 		}
 	}
 
 	/* Wait until devices are away */
 	if (!sync_local_dev_names(lv->vg->cmd)) {
-		log_error("Failed to sync local devices after updating %s",
+		log_error("Failed to sync local devices after updating %s.",
 			  display_lvname(lv));
 		return 0;
 	}
 
 	/* Put metadata sub-LVs back in place */
 	if (!attach_metadata_devices(seg, &device_list)) {
-		log_error("Failed to reattach %s device after clearing",
+		log_error("Failed to reattach %s device after clearing.",
 			  (seg_is_raid(seg)) ? "metadata" : "log");
 		return 0;
 	}
 
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
-		log_error("Failed to update metadata on disk.");
+		log_error("Failed to update metadata on disk for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (!_reactivate_lv(lv, active, exclusive)) {
 		backup(lv->vg);
-		log_error("Failed to reactivate %s after resync",
-			  lv->name);
+		log_error("Failed to reactivate %s after resync.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -512,8 +512,8 @@ static int _lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 			       ? ALLOC_CONTIGUOUS : ALLOC_INHERIT);
 
 	if (alloc == lv->alloc) {
-		log_error("Allocation policy of logical volume \"%s\" is "
-			  "already %s", lv->name, get_alloc_string(alloc));
+		log_error("Allocation policy of logical volume %s is already %s.",
+			  display_lvname(lv), get_alloc_string(alloc));
 		return 0;
 	}
 
@@ -521,10 +521,10 @@ static int _lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 
 	/* FIXME If contiguous, check existing extents already are */
 
-	log_verbose("Setting contiguous allocation policy for \"%s\" to %s",
-		    lv->name, get_alloc_string(alloc));
+	log_verbose("Setting contiguous allocation policy for %s to %s.",
+		    display_lvname(lv), get_alloc_string(alloc));
 
-	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
+	log_very_verbose("Updating logical volume %s on disk(s).", display_lvname(lv));
 
 	/* No need to suspend LV for this change */
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
@@ -584,17 +584,18 @@ static int _lvchange_readahead(struct cmd_context *cmd,
 
 	if (lv->read_ahead == read_ahead) {
 		if (read_ahead == DM_READ_AHEAD_AUTO)
-			log_error("Read ahead is already auto for \"%s\"", lv->name);
+			log_error("Read ahead is already auto for %s.",
+				  display_lvname(lv));
 		else
-			log_error("Read ahead is already %u for \"%s\"",
-				  read_ahead, lv->name);
+			log_error("Read ahead is already %u for %s.",
+				  read_ahead, display_lvname(lv));
 		return 0;
 	}
 
 	lv->read_ahead = read_ahead;
 
-	log_verbose("Setting read ahead to %u for \"%s\"", read_ahead,
-		    lv->name);
+	log_verbose("Setting read ahead to %u for %s.",
+		    read_ahead, display_lvname(lv));
 
 	if (!lv_update_and_reload(lv))
 		return_0;
@@ -629,7 +630,8 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 			    !arg_is_set(cmd, yes_ARG) &&
 			    yes_no_prompt("Logical volume %s will be "
 					  "deactivated temporarily. "
-					  "Continue? [y/n]: ", lv->name) == 'n') {
+					  "Continue? [y/n]: ",
+					  display_lvname(lv)) == 'n') {
 				log_error("%s device number not changed.",
 					  display_lvname(lv));
 				return 0;
@@ -665,9 +667,9 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 		return_0;
 
 	if (activate != CHANGE_AN) {
-		log_verbose("Re-activating logical volume %s", display_lvname(lv));
+		log_verbose("Re-activating logical volume %s.", display_lvname(lv));
 		if (!lv_active_change(cmd, lv, activate, 0)) {
-			log_error("%s: reactivation failed", display_lvname(lv));
+			log_error("%s: reactivation failed.", display_lvname(lv));
 			backup(lv->vg);
 			return 0;
 		}
@@ -736,7 +738,7 @@ static int _lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv, int
 	if (!change_tag(cmd, NULL, lv, NULL, arg))
 		return_0;
 
-	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
+	log_very_verbose("Updating logical volume %s on disk(s).", display_lvname(lv));
 
 	/* No need to suspend LV for this change */
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
@@ -759,7 +761,7 @@ static int _lvchange_writemostly(struct logical_volume *lv)
 	struct lv_segment *raid_seg = first_seg(lv);
 
 	if (!seg_is_raid1(raid_seg)) {
-		log_error("--write%s can only be used with 'raid1' segment type",
+		log_error("--write%s can only be used with 'raid1' segment type.",
 			  arg_is_set(cmd, writemostly_ARG) ? "mostly" : "behind");
 		return 0;
 	}
@@ -853,8 +855,8 @@ static int _lvchange_recovery_rate(struct logical_volume *lv)
 	struct lv_segment *raid_seg = first_seg(lv);
 
 	if (!seg_is_raid(raid_seg)) {
-		log_error("Unable to change the recovery rate of non-RAID"
-			  " logical volume.");
+		log_error("Unable to change the recovery rate of non-RAID "
+			  "logical volume %s.", display_lvname(lv));
 		return 0;
 	}
 
@@ -867,8 +869,7 @@ static int _lvchange_recovery_rate(struct logical_volume *lv)
 
 	if (raid_seg->max_recovery_rate &&
 	    (raid_seg->max_recovery_rate < raid_seg->min_recovery_rate)) {
-		log_error("Minumum recovery rate cannot"
-			  " be higher than maximum.");
+		log_error("Minimum recovery rate cannot be higher than maximum.");
 		return 0;
 	}
 
@@ -899,7 +900,7 @@ static int _lvchange_profile(struct logical_volume *lv)
 	}
 
 	log_verbose("Changing configuration profile for LV %s: %s -> %s.",
-		    lv->name, old_profile_name, new_profile_name);
+		    display_lvname(lv), old_profile_name, new_profile_name);
 
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
@@ -916,7 +917,7 @@ static int _lvchange_activation_skip(struct logical_volume *lv)
 	lv_set_activation_skip(lv, 1, skip);
 
 	log_verbose("Changing activation skip flag to %s for LV %s.",
-		    lv->name, skip ? "enabled" : "disabled");
+		    display_lvname(lv), skip ? "enabled" : "disabled");
 
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
@@ -949,8 +950,8 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 				 readahead_ARG,
 				 zero_ARG,
 				 -1)) {
-		log_error("Only -a permitted with read-only volume "
-			  "group \"%s\"", lv->vg->name);
+		log_error("Only -a permitted with read-only volume group %s.",
+			  lv->vg->name);
 		return ECMD_FAILED;
 	}
 
@@ -964,26 +965,27 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 				 profile_ARG,
 				 readahead_ARG,
 				 -1)) {
-		log_error("Can't change logical volume \"%s\" under snapshot",
-			  lv->name);
+		log_error("Can't change logical volume %s under snapshot.",
+			  display_lvname(lv));
 		return ECMD_FAILED;
 	}
 
 	if (lv_is_pvmove(lv)) {
-		log_error("Unable to change pvmove LV %s", lv->name);
+		log_error("Unable to change pvmove LV %s.", display_lvname(lv));
 		if (arg_is_set(cmd, activate_ARG))
 			log_error("Use 'pvmove --abort' to abandon a pvmove");
 		return ECMD_FAILED;
 	}
 
 	if (lv_is_mirror_log(lv)) {
-		log_error("Unable to change mirror log LV %s directly", lv->name);
+		log_error("Unable to change mirror log LV %s directly.",
+			  display_lvname(lv));
 		return ECMD_FAILED;
 	}
 
 	if (lv_is_mirror_image(lv)) {
-		log_error("Unable to change mirror image LV %s directly",
-			  lv->name);
+		log_error("Unable to change mirror image LV %s directly.",
+			  display_lvname(lv));
 		return ECMD_FAILED;
 	}
 
@@ -1000,8 +1002,8 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    /* Rest can be changed for stacked thin pool meta/data volumes */
 	    ;
 	else if (!lv_is_visible(lv) && !lv_is_virtual_origin(lv)) {
-		log_error("Unable to change internal LV %s directly",
-			  lv->name);
+		log_error("Unable to change internal LV %s directly.",
+			  display_lvname(lv));
 		return ECMD_FAILED;
 	}
 
@@ -1278,22 +1280,22 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 
 	if ((arg_is_set(cmd, minor_ARG) || arg_is_set(cmd, major_ARG)) &&
 	    !arg_is_set(cmd, persistent_ARG)) {
-		log_error("--major and --minor require -My");
+		log_error("--major and --minor require -My.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_is_set(cmd, minor_ARG) && argc != 1) {
-		log_error("Only give one logical volume when specifying minor");
+		log_error("Only give one logical volume when specifying minor.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_is_set(cmd, contiguous_ARG) && arg_is_set(cmd, alloc_ARG)) {
-		log_error("Only one of --alloc and --contiguous permitted");
+		log_error("Only one of --alloc and --contiguous permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_is_set(cmd, poll_ARG) && arg_is_set(cmd, sysinit_ARG)) {
-		log_error("Only one of --poll and --sysinit permitted");
+		log_error("Only one of --poll and --sysinit permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -1306,7 +1308,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	if (arg_is_set(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
 		if (lvmetad_used()) {
-			log_warn("WARNING: lvmetad is active, skipping direct activation during sysinit");
+			log_warn("WARNING: lvmetad is active, skipping direct activation during sysinit.");
 			return ECMD_PROCESSED;
 		}
 	}



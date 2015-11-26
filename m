From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Nov 2015 08:48:51 +0000 (UTC)
Subject: master - cleanup: using display_lvname
Message-ID: <20151126084851.348F361041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=922fccc6560706f5026d59e383b694f9d7f85945
Commit:        922fccc6560706f5026d59e383b694f9d7f85945
Parent:        b7b59ad9323cd38889e78068813c311170920d9d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 25 16:06:31 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 26 09:27:37 2015 +0100

cleanup: using display_lvname

Use for showing vgname/lvname in messages.
No functional change.
---
 lib/activate/activate.c    |  154 +++++++++++++++++++++++---------------------
 lib/activate/dev_manager.c |   79 +++++++++++++---------
 2 files changed, 127 insertions(+), 106 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 47c675c..8f5b72b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -118,8 +118,8 @@ static int _lv_passes_volumes_filter(struct cmd_context *cmd, const struct logic
 
 	config_def_get_path(config_path, sizeof(config_path), cfg_id);
 	log_verbose("%s configuration setting defined: "
-		    "Checking the list to match %s/%s",
-		    config_path, lv->vg->name, lv->name);
+		    "Checking the list to match %s.",
+		    config_path, display_lvname(lv));
 
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type == DM_CFG_EMPTY_ARRAY)
@@ -170,8 +170,8 @@ static int _lv_passes_volumes_filter(struct cmd_context *cmd, const struct logic
 	}
 
 out:
-	log_verbose("No item supplied in %s configuration setting "
-		    "matches %s/%s", config_path, lv->vg->name, lv->name);
+	log_verbose("No item supplied in %s configuration setting matches %s.",
+		    config_path, display_lvname(lv));
 
 	return 0;
 }
@@ -469,8 +469,8 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 
 	if (!(cn = find_config_tree_array(cmd, activation_volume_list_CFG, NULL))) {
 		log_verbose("activation/volume_list configuration setting "
-			    "not defined: Checking only host tags for %s/%s",
-			    lv->vg->name, lv->name);
+			    "not defined: Checking only host tags for %s.",
+			    display_lvname(lv));
 
 		/* If no host tags defined, activate */
 		if (dm_list_empty(&cmd->tags))
@@ -481,8 +481,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 		    str_list_match_list(&cmd->tags, &lv->vg->tags, NULL))
 			return 1;
 
-		log_verbose("No host tag matches %s/%s",
-			    lv->vg->name, lv->name);
+		log_verbose("No host tag matches %s", display_lvname(lv));
 
 		/* Don't activate */
 		return 0;
@@ -771,14 +770,14 @@ int lv_check_not_in_use(const struct logical_volume *lv)
 	/* If sysfs is not used, use open_count information only. */
 	if (dm_sysfs_dir()) {
 		if (dm_device_has_holders(info.major, info.minor)) {
-			log_error("Logical volume %s/%s is used by another device.",
-				  lv->vg->name, lv->name);
+			log_error("Logical volume %s is used by another device.",
+				  display_lvname(lv));
 			return 0;
 		}
 
 		if (dm_device_has_mounted_fs(info.major, info.minor)) {
-			log_error("Logical volume %s/%s contains a filesystem in use.",
-				  lv->vg->name, lv->name);
+			log_error("Logical volume %s contains a filesystem in use.",
+				  display_lvname(lv));
 			return 0;
 		}
 	}
@@ -786,14 +785,14 @@ int lv_check_not_in_use(const struct logical_volume *lv)
 	open_count_check_retries = retry_deactivation() ? OPEN_COUNT_CHECK_RETRIES : 1;
 	while (info.open_count > 0 && open_count_check_retries--) {
 		if (!open_count_check_retries) {
-			log_error("Logical volume %s/%s in use.",
-				  lv->vg->name, lv->name);
+			log_error("Logical volume %s in use.",
+				  display_lvname(lv));
 			return 0;
 		}
 
 		usleep(OPEN_COUNT_CHECK_USLEEP_DELAY);
-		log_debug_activation("Retrying open_count check for %s/%s.",
-				     lv->vg->name, lv->name);
+		log_debug_activation("Retrying open_count check for %s.",
+				     display_lvname(lv));
 		if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)) {
 			stack; /* device dissappeared? */
 			break;
@@ -814,7 +813,8 @@ int lv_check_transient(struct logical_volume *lv)
 	if (!activation())
 		return 0;
 
-	log_debug_activation("Checking transient status for LV %s/%s", lv->vg->name, lv->name);
+	log_debug_activation("Checking transient status for LV %s.",
+			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -838,7 +838,8 @@ int lv_snapshot_percent(const struct logical_volume *lv, dm_percent_t *percent)
 	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking snapshot percent for LV %s/%s", lv->vg->name, lv->name);
+	log_debug_activation("Checking snapshot percent for LV %s.",
+			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -868,7 +869,8 @@ int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 	if (!lv_info(cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking mirror percent for LV %s/%s", lv->vg->name, lv->name);
+	log_debug_activation("Checking mirror percent for LV %s.",
+			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -897,8 +899,8 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking raid device health for LV %s/%s",
-			     lv->vg->name, lv->name);
+	log_debug_activation("Checking raid device health for LV %s.",
+			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -925,8 +927,8 @@ int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
 	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking raid mismatch count for LV %s/%s",
-			     lv->vg->name, lv->name);
+	log_debug_activation("Checking raid mismatch count for LV %s.",
+			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -953,8 +955,8 @@ int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action)
 	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking raid sync_action for LV %s/%s",
-			     lv->vg->name, lv->name);
+	log_debug_activation("Checking raid sync_action for LV %s.",
+			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -990,12 +992,12 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 		    (lv_is_raid(seg_lv(first_seg(lv), 0)) ||
 		     lv_is_raid(first_seg(lv)->metadata_lv))) {
 			log_error("Thin pool data or metadata volume "
-				  "must be specified. (E.g. \"%s/%s_tdata\")",
-				  lv->vg->name, lv->name);
+				  "must be specified. (E.g. \"%s_tdata\")",
+				  display_lvname(lv));
 			return 0;
 		}
-		log_error("%s/%s must be a RAID logical volume to"
-			  " perform this action.", lv->vg->name, lv->name);
+		log_error("%s must be a RAID logical volume to perform this action.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -1008,8 +1010,8 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 		return_0;
 
 	if (!(r = dev_manager_raid_status(dm, lv, &status))) {
-		log_error("Failed to retrieve status of %s/%s",
-			  lv->vg->name, lv->name);
+		log_error("Failed to retrieve status of %s.",
+			  display_lvname(lv));
 		goto out;
 	}
 
@@ -1036,8 +1038,8 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 		goto out;
 	}
 	if (strcmp(status->sync_action, "idle")) {
-		log_error("%s/%s state is currently \"%s\".  Unable to switch to \"%s\".",
-			  lv->vg->name, lv->name, status->sync_action, msg);
+		log_error("%s state is currently \"%s\".  Unable to switch to \"%s\".",
+			  display_lvname(lv), status->sync_action, msg);
 		goto out;
 	}
 
@@ -1101,8 +1103,8 @@ int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking thin %sdata percent for LV %s/%s",
-			     (metadata) ? "meta" : "", lv->vg->name, lv->name);
+	log_debug_activation("Checking thin %sdata percent for LV %s.",
+			     (metadata) ? "meta" : "", display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -1127,8 +1129,8 @@ int lv_thin_percent(const struct logical_volume *lv,
 	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking thin percent for LV %s/%s",
-			     lv->vg->name, lv->name);
+	log_debug_activation("Checking thin percent for LV %s.",
+			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -1154,8 +1156,8 @@ int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking thin percent for LV %s/%s",
-			     lv->vg->name, lv->name);
+	log_debug_activation("Checking thin percent for LV %s.",
+			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -1178,8 +1180,8 @@ int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id)
 	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
-	log_debug_activation("Checking device id for LV %s/%s",
-			     lv->vg->name, lv->name);
+	log_debug_activation("Checking device id for LV %s.",
+			     display_lvname(lv));
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -1381,7 +1383,7 @@ static int _lv_is_active(const struct logical_volume *lv,
 	 * New users of this function who specifically ask for 'exclusive'
 	 * will be given an error message.
 	 */
-	log_error("Unable to determine exclusivity of %s", lv->name);
+	log_error("Unable to determine exclusivity of %s.", display_lvname(lv));
 
 	e = 0;
 
@@ -1396,8 +1398,8 @@ out:
 	if (exclusive)
 		*exclusive = e;
 
-	log_very_verbose("%s/%s is %sactive%s%s",
-			 lv->vg->name, lv->name,
+	log_very_verbose("%s is %sactive%s%s",
+			 display_lvname(lv),
 			 (r || l) ? "" : "not ",
 			 (exclusive && e) ? " exclusive" : "",
 			 e ? (l ? " locally" : " remotely") : "");
@@ -1606,14 +1608,14 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	if (laopts->skip_in_use && lv_is_thin_pool(lv) &&
 	    lv_info(lv->vg->cmd, lv, 1, &info, 1, 0) && (info.open_count > 1)) {
 		log_debug_activation("Skipping unmonitor of opened %s (open:%d)",
-				     lv->name, info.open_count);
+				     display_lvname(lv), info.open_count);
 		return 1;
 	}
 
 	/* Do not monitor snapshot that already covers origin */
 	if (monitor && lv_is_cow_covering_origin(lv)) {
 		log_debug_activation("Skipping monitor of snapshot larger "
-				     "then origin %s.", lv->name);
+				     "then origin %s.", display_lvname(lv));
 		return 1;
 	}
 
@@ -1661,7 +1663,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 						    monitor)) {
 				log_error("Failed to %smonitor %s",
 					  monitor ? "" : "un",
-					  seg_lv(seg, s)->name);
+					  display_lvname(seg_lv(seg, s)));
 				r = 0;
 			}
 		}
@@ -1698,12 +1700,12 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 
 		if (monitor) {
 			if (monitored)
-				log_verbose("%s/%s already monitored.", lv->vg->name, lv->name);
+				log_verbose("%s already monitored.", display_lvname(lv));
 			else if (seg->segtype->ops->target_monitor_events)
 				monitor_fn = seg->segtype->ops->target_monitor_events;
 		} else {
 			if (!monitored)
-				log_verbose("%s/%s already not monitored.", lv->vg->name, lv->name);
+				log_verbose("%s already not monitored.", display_lvname(lv));
 			else if (seg->segtype->ops->target_unmonitor_events)
 				monitor_fn = seg->segtype->ops->target_unmonitor_events;
 		}
@@ -1712,7 +1714,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		if (!monitor_fn)
 			continue;
 
-		log_verbose("%sonitoring %s/%s%s", monitor ? "M" : "Not m", lv->vg->name, lv->name,
+		log_verbose("%sonitoring %s%s", monitor ? "M" : "Not m", display_lvname(lv),
 			    test_mode() ? " [Test mode: skipping this]" : "");
 
 		/* FIXME Test mode should really continue a bit further. */
@@ -1721,8 +1723,8 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 
 		/* FIXME specify events */
 		if (!monitor_fn(seg, 0)) {
-			log_error("%s/%s: %s segment monitoring function failed.",
-				  lv->vg->name, lv->name, seg->segtype->name);
+			log_error("%s: %s segment monitoring function failed.",
+				  display_lvname(lv), seg->segtype->name);
 			return 0;
 		}
 
@@ -1734,8 +1736,8 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 			if (pending ||
 			    (!monitored && monitor) ||
 			    (monitored && !monitor))
-				log_very_verbose("%s/%s %smonitoring still pending: waiting...",
-						 lv->vg->name, lv->name, monitor ? "" : "un");
+				log_very_verbose("%s %smonitoring still pending: waiting...",
+						 display_lvname(lv), monitor ? "" : "un");
 			else
 				break;
 			usleep(10000 * i);
@@ -1746,8 +1748,8 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	}
 
 	if (!r && !error_message_produced())
-		log_error("%sonitoring %s/%s failed.", monitor ? "M" : "Not m",
-			  lv->vg->name, lv->name);
+		log_error("%sonitoring %s failed.", monitor ? "M" : "Not m",
+			  display_lvname(lv));
 	return r;
 #else
 	return 1;
@@ -1858,7 +1860,8 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		/* Preload all the LVs above the PVMOVE LV */
 		dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
 			if (!(lv_pre_tmp = find_lv(lv_pre->vg, sl->seg->lv->name))) {
-				log_error(INTERNAL_ERROR "LV %s missing from preload metadata", sl->seg->lv->name);
+				log_error(INTERNAL_ERROR "LV %s missing from preload metadata.",
+					  display_lvname(sl->seg->lv));
 				goto out;
 			}
 			if (!_lv_preload(lv_pre_tmp, laopts, &flush_required))
@@ -1866,7 +1869,8 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		}
 		/* Now preload the PVMOVE LV itself */
 		if (!(lv_pre_tmp = find_lv(lv_pre->vg, pvmove_lv->name))) {
-			log_error(INTERNAL_ERROR "LV %s missing from preload metadata", pvmove_lv->name);
+			log_error(INTERNAL_ERROR "LV %s missing from preload metadata.",
+				  display_lvname(pvmove_lv));
 			goto out;
 		}
 		if (!_lv_preload(lv_pre_tmp, laopts, &flush_required))
@@ -1892,8 +1896,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		if (!laopts->origin_only && lv_is_origin(lv)) {
 			dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list) {
 				if (!(lv_pre_tmp = find_lv_in_vg_by_lvid(lv_pre->vg, &snap_seg->cow->lvid))) {
-					log_error(INTERNAL_ERROR "LV %s (%s) missing from preload metadata",
-						  snap_seg->cow->name, snap_seg->cow->lvid.id[1].uuid);
+					log_error(INTERNAL_ERROR "LV %s (%s) missing from preload metadata.",
+						  display_lvname(snap_seg->cow),
+						  snap_seg->cow->lvid.id[1].uuid);
 					goto out;
 				}
 				if (!lv_is_cow(lv_pre_tmp) &&
@@ -1996,13 +2001,14 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		laopts->origin_only = 0;
 
 	if (test_mode()) {
-		_skip("Resuming %s%s%s.", lv->name, laopts->origin_only ? " without snapshots" : "",
+		_skip("Resuming %s%s%s.", display_lvname(lv),
+		      laopts->origin_only ? " without snapshots" : "",
 		      laopts->revert ? " (reverting)" : "");
 		r = 1;
 		goto out;
 	}
 
-	log_debug_activation("Resuming LV %s/%s%s%s%s.", lv->vg->name, lv->name,
+	log_debug_activation("Resuming LV %s%s%s%s.", display_lvname(lv),
 			     error_if_not_active ? "" : " if active",
 			     laopts->origin_only ?
 			     (lv_is_thin_pool(lv) ? " pool only" :
@@ -2080,8 +2086,8 @@ static int _lv_has_open_snapshots(const struct logical_volume *lv)
 			r++;
 
 	if (r)
-		log_error("LV %s/%s has open %d snapshot(s), not deactivating.",
-			  lv->vg->name, lv->name, r);
+		log_error("LV %s has open %d snapshot(s), not deactivating.",
+			  display_lvname(lv), r);
 
 	return r;
 }
@@ -2101,12 +2107,12 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 		goto out;
 
 	if (test_mode()) {
-		_skip("Deactivating '%s'.", lv->name);
+		_skip("Deactivating %s.", display_lvname(lv));
 		r = 1;
 		goto out;
 	}
 
-	log_debug_activation("Deactivating %s/%s.", lv->vg->name, lv->name);
+	log_debug_activation("Deactivating %s.", display_lvname(lv));
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		goto_out;
@@ -2175,11 +2181,11 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 	}
 
 	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
-		goto out;
+		goto_out;
 
 	if (!_passes_activation_filter(cmd, lv)) {
-		log_verbose("Not activating %s/%s since it does not pass "
-			    "activation filter.", lv->vg->name, lv->name);
+		log_verbose("Not activating %s since it does not pass "
+			    "activation filter.", display_lvname(lv));
 		*activate_lv = 0;
 	} else
 		*activate_lv = 1;
@@ -2206,8 +2212,8 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 
 	if (filter && !_passes_activation_filter(cmd, lv)) {
-		log_verbose("Not activating %s/%s since it does not pass "
-			    "activation filter.", lv->vg->name, lv->name);
+		log_verbose("Not activating %s since it does not pass "
+			    "activation filter.", display_lvname(lv));
 		r = 1;
 		goto out;
 	}
@@ -2230,7 +2236,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 
 	if (lv_has_unknown_segments(lv)) {
 		log_error("Refusing activation of LV %s containing "
-			  "an unrecognised segment.", lv->name);
+			  "an unrecognised segment.", display_lvname(lv));
 		goto out;
 	}
 
@@ -2245,7 +2251,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	}
 
 	if (test_mode()) {
-		_skip("Activating '%s'.", lv->name);
+		_skip("Activating %s.", display_lvname(lv));
 		r = 1;
 		goto out;
 	}
@@ -2253,7 +2259,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (filter)
 		laopts->read_only = _passes_readonly_filter(cmd, lv);
 
-	log_debug_activation("Activating %s/%s%s%s%s%s.", lv->vg->name, lv->name,
+	log_debug_activation("Activating %s%s%s%s%s.", display_lvname(lv),
 			     laopts->exclusive ? " exclusively" : "",
 			     laopts->read_only ? " read-only" : "",
 			     laopts->noscan ? " noscan" : "",
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 328d8ac..4b37845 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -827,7 +827,8 @@ static const struct dm_info *_cached_dm_info(struct dm_pool *mem,
 		goto_out;
 
 	if (!(dinfo = dm_tree_node_get_info(dnode))) {
-		log_error("Failed to get info from tree node for %s.", lv->name);
+		log_error("Failed to get info from tree node for %s.",
+			  display_lvname(lv));
 		goto out;
 	}
 
@@ -983,7 +984,8 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 		if (lv) {
 			if (!(segh = dm_list_next(&lv->segments, segh))) {
 				log_error("Number of segments in active LV %s "
-					  "does not match metadata", lv->name);
+					  "does not match metadata.",
+					  display_lvname(lv));
 				goto out;
 			}
 			seg = dm_list_item(segh, struct lv_segment);
@@ -1023,7 +1025,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 
 	if (lv && dm_list_next(&lv->segments, segh)) {
 		log_error("Number of segments in active LV %s does not "
-			  "match metadata", lv->name);
+			  "match metadata.", display_lvname(lv));
 		goto out;
 	}
 
@@ -1098,7 +1100,7 @@ int dev_manager_transient(struct dev_manager *dm, const struct logical_volume *l
 
 		if (!(segh = dm_list_next(&lv->segments, segh))) {
 		    log_error("Number of segments in active LV %s "
-			      "does not match metadata", lv->name);
+			      "does not match metadata.", display_lvname(lv));
 		    goto out;
 		}
 		seg = dm_list_item(segh, struct lv_segment);
@@ -1119,7 +1121,7 @@ int dev_manager_transient(struct dev_manager *dm, const struct logical_volume *l
 
 	if (dm_list_next(&lv->segments, segh)) {
 		log_error("Number of segments in active LV %s does not "
-			  "match metadata", lv->name);
+			  "match metadata.", display_lvname(lv));
 		goto out;
 	}
 
@@ -1318,8 +1320,8 @@ int dev_manager_raid_message(struct dev_manager *dm,
 	const char *layer = lv_layer(lv);
 
 	if (!lv_is_raid(lv)) {
-		log_error(INTERNAL_ERROR "%s/%s is not a RAID logical volume",
-			  lv->vg->name, lv->name);
+		log_error(INTERNAL_ERROR "%s is not a RAID logical volume",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -1528,17 +1530,20 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 
 	if (dm_get_next_target(dmt, NULL, &start, &length,
 			       &target_type, &params)) {
-		log_error("More then one table line found for %s.", lv->name);
+		log_error("More then one table line found for %s.",
+			  display_lvname(lv));
 		goto out;
 	}
 
 	if (!target_type || strcmp(target_type, "thin")) {
-		log_error("Unexpected target type %s found for thin %s.", target_type, lv->name);
+		log_error("Unexpected target type %s found for thin %s.",
+			  target_type, display_lvname(lv));
 		goto out;
 	}
 
 	if (!params || sscanf(params, "%*u:%*u %u", device_id) != 1) {
-		log_error("Cannot parse table like parameters %s for %s.", params, lv->name);
+		log_error("Cannot parse table like parameters %s for %s.",
+			  params, display_lvname(lv));
 		goto out;
 	}
 
@@ -1559,7 +1564,7 @@ static int _dev_manager_lv_mknodes(const struct logical_volume *lv)
 	char *name;
 
 	if (!(name = dm_build_dm_name(lv->vg->cmd->mem, lv->vg->name,
-				   lv->name, NULL)))
+				      lv->name, NULL)))
 		return_0;
 
 	return fs_add_lv(lv, name);
@@ -1738,7 +1743,8 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			log_error("Volume %s (%" PRIu32 ":%" PRIu32")"
 				  " differs from already active device "
 				  "(%" PRIu32 ":%" PRIu32")",
-				  lv->name, lv->major, lv->minor, info.major, info.minor);
+				  display_lvname(lv), lv->major, lv->minor,
+				  info.major, info.minor);
 			return 0;
 		}
 		if (!info.exists && _info_by_dev(lv->major, lv->minor, &info2) &&
@@ -1758,7 +1764,8 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	}
 
 	if (info.exists && dm->track_pending_delete) {
-		log_debug_activation("Tracking pending delete for %s (%s).", lv->name, dlid);
+		log_debug_activation("Tracking pending delete for %s (%s).",
+				     display_lvname(lv), dlid);
 		if (!str_list_add(dm->mem, &dm->pending_delete, dlid))
 			return_0;
 	}
@@ -2194,7 +2201,8 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, const struc
 	struct dm_tree *dtree;
 
 	if (!(dtree = dm_tree_create())) {
-		log_debug_activation("Partial dtree creation failed for %s.", lv->name);
+		log_debug_activation("Partial dtree creation failed for %s.",
+				     display_lvname(lv));
 		return NULL;
 	}
 
@@ -2238,7 +2246,7 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 		return_NULL;
 
 	if (!(name = dm_build_dm_name(dm->mem, seg->lv->vg->name,
-				   seg->lv->name, errid)))
+				      seg->lv->name, errid)))
 		return_NULL;
 
 	log_debug_activation("Getting device info for %s [%s]", name, dlid);
@@ -2311,7 +2319,8 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 				if (!seg->lv->vg->cmd->degraded_activation ||
 				    !lv_is_raid_type(seg->lv)) {
 					log_error("Aborting.  LV %s is now incomplete "
-						  "and '--activationmode partial' was not specified.", seg->lv->name);
+						  "and '--activationmode partial' was not specified.",
+						  display_lvname(seg->lv));
 					return 0;
 				}
 			}
@@ -2362,7 +2371,7 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 				return_0;
 		} else {
 			log_error(INTERNAL_ERROR "Unassigned area found in LV %s.",
-				  seg->lv->name);
+				  display_lvname(seg->lv));
 			return 0;
 		}
 	}
@@ -2370,8 +2379,8 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
         if (num_error_areas) {
 		/* Thins currently do not support partial activation */
 		if (lv_is_thin_type(seg->lv)) {
-			log_error("Cannot activate %s%s: pool incomplete.",
-				  seg->lv->vg->name, seg->lv->name);
+			log_error("Cannot activate %s: pool incomplete.",
+				  display_lvname(seg->lv));
 			return 0;
 		}
 	}
@@ -2421,7 +2430,8 @@ static int _add_snapshot_merge_target_to_dtree(struct dev_manager *dm,
 	struct lv_segment *merging_snap_seg = find_snapshot(lv);
 
 	if (!lv_is_merging_origin(lv)) {
-		log_error(INTERNAL_ERROR "LV %s is not merging snapshot.", lv->name);
+		log_error(INTERNAL_ERROR "LV %s is not merging snapshot.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2453,7 +2463,8 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 	uint64_t size;
 
 	if (!(snap_seg = find_snapshot(lv))) {
-		log_error("Couldn't find snapshot for '%s'.", lv->name);
+		log_error("Couldn't find snapshot for '%s'.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2578,8 +2589,8 @@ static int _add_new_external_lv_to_dtree(struct dev_manager *dm,
 	 */
 	dm->skip_external_lv = 1;
 
-	log_debug_activation("Adding external origin lv %s and all active users.",
-			     external_lv->name);
+	log_debug_activation("Adding external origin LV %s and all active users.",
+			     display_lvname(external_lv));
 
 	if (!_add_new_lv_to_dtree(dm, dtree, external_lv, laopts,
 				  lv_layer(external_lv)))
@@ -2599,8 +2610,9 @@ static int _add_new_external_lv_to_dtree(struct dev_manager *dm,
 					  laopts, lv_layer(sl->seg->lv)))
 			return_0;
 
-	log_debug_activation("Finished adding  external origin lv %s and all active users.",
-			     external_lv->name);
+	log_debug_activation("Finished adding external origin LV %s and all active users.",
+			     display_lvname(external_lv));
+
 	dm->skip_external_lv = 0;
 
 	return 1;
@@ -2627,14 +2639,14 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		       segtype->name);
 
 	log_debug_activation("Checking kernel supports %s segment type for %s%s%s",
-			     target_name, seg->lv->name,
+			     target_name, display_lvname(seg->lv),
 			     layer ? "-" : "", layer ? : "");
 
 	if (segtype->ops->target_present &&
 	    !segtype->ops->target_present(seg_present->lv->vg->cmd,
 					  seg_present, NULL)) {
 		log_error("Can't process LV %s: %s target support missing "
-			  "from kernel?", seg->lv->name, target_name);
+			  "from kernel?", display_lvname(seg->lv), target_name);
 		return 0;
 	}
 
@@ -2681,7 +2693,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	if (dm->track_pending_delete) {
 		/* Replace target and all its used devs with error mapping */
 		log_debug_activation("Using error for pending delete %s.",
-				     seg->lv->name);
+				     display_lvname(seg->lv));
 		if (!dm_tree_node_add_error_target(dnode, (uint64_t)seg->lv->vg->extent_size * seg->len))
 			return_0;
 	} else if (!_add_target_to_dtree(dm, dnode, seg, laopts))
@@ -2762,7 +2774,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
 		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.",
-			  lv->name, layer);
+			  display_lvname(lv), layer);
 		return 0;
 	}
 
@@ -3032,7 +3044,8 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 	/* Some LV can be used for top level tree */
 	/* TODO: add more.... */
 	if (lv_is_cache_pool(lv) && !dm_list_empty(&lv->segs_using_this_lv)) {
-		log_error(INTERNAL_ERROR "Cannot create tree for %s.", lv->name);
+		log_error(INTERNAL_ERROR "Cannot create tree for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 	/* Some targets may build bigger tree for activation */
@@ -3068,7 +3081,8 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		if (!dm_tree_deactivate_children(root, dlid, DLID_SIZE))
 			goto_out;
 		if (!_remove_lv_symlinks(dm, root))
-			log_warn("Failed to remove all device symlinks associated with %s.", lv->name);
+			log_warn("Failed to remove all device symlinks associated with %s.",
+				 display_lvname(lv));
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
@@ -3105,7 +3119,8 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 			if (!dm_tree_activate_children(root, dlid, DLID_SIZE))
 				goto_out;
 			if (!_create_lv_symlinks(dm, root))
-				log_warn("Failed to create symlinks for %s.", lv->name);
+				log_warn("Failed to create symlinks for %s.",
+					 display_lvname(lv));
 		}
 
 		break;



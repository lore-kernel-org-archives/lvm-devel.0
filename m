From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:45 +0000 (UTC)
Subject: master - cleanup: use display_lvname
Message-ID: <20160623130145.697196066C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=698082e67875fe71970fb932ffe2170d777f2807
Commit:        698082e67875fe71970fb932ffe2170d777f2807
Parent:        6268d0a080f61c85c2681b3dcfdd5b00f849ace1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 23 13:04:37 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:08 2016 +0200

cleanup: use display_lvname

---
 lib/metadata/lv.c         |   30 ++++++++++++-----------
 lib/metadata/lv_manip.c   |   57 ++++++++++++++++++++++++--------------------
 lib/metadata/thin_manip.c |    6 +++-
 3 files changed, 51 insertions(+), 42 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 06f47f4..cdf658e 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1432,49 +1432,50 @@ int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 	
 	if (is_change_activating(activate) &&
 	    !lockd_lv(cmd, lv, ay_with_mode, LDLV_PERSISTENT)) {
-		log_error("Failed to lock logical volume %s/%s", lv->vg->name, lv->name);
+		log_error("Failed to lock logical volume %s.", display_lvname(lv));
 		return 0;
 	}
 
 	switch (activate) {
 	case CHANGE_AN:
 deactivate:
-		log_verbose("Deactivating logical volume \"%s\"", lv->name);
+		log_verbose("Deactivating logical volume %s.", display_lvname(lv));
 		if (!deactivate_lv(cmd, lv))
 			return_0;
 		break;
 	case CHANGE_ALN:
 		if (vg_is_clustered(lv->vg) && (needs_exclusive || _lv_is_exclusive(lv))) {
 			if (!lv_is_active_locally(lv)) {
-				log_error("Cannot deactivate remotely exclusive device locally.");
+				log_error("Cannot deactivate remotely exclusive device %s locally.",
+					  display_lvname(lv));
 				return 0;
 			}
 			/* Unlock whole exclusive activation */
 			goto deactivate;
 		}
-		log_verbose("Deactivating logical volume \"%s\" locally.",
-			    lv->name);
+		log_verbose("Deactivating logical volume %s locally.",
+			    display_lvname(lv));
 		if (!deactivate_lv_local(cmd, lv))
 			return_0;
 		break;
 	case CHANGE_ALY:
 	case CHANGE_AAY:
 		if (needs_exclusive || _lv_is_exclusive(lv)) {
-			log_verbose("Activating logical volume \"%s\" exclusively locally.",
-				    lv->name);
+			log_verbose("Activating logical volume %s exclusively locally.",
+				    display_lvname(lv));
 			if (!activate_lv_excl_local(cmd, lv))
 				return_0;
 		} else {
-			log_verbose("Activating logical volume \"%s\" locally.",
-				    lv->name);
+			log_verbose("Activating logical volume %s locally.",
+				    display_lvname(lv));
 			if (!activate_lv_local(cmd, lv))
 				return_0;
 		}
 		break;
 	case CHANGE_AEY:
 exclusive:
-		log_verbose("Activating logical volume \"%s\" exclusively.",
-			    lv->name);
+		log_verbose("Activating logical volume %s exclusively.",
+			    display_lvname(lv));
 		if (!activate_lv_excl(cmd, lv))
 			return_0;
 		break;
@@ -1483,14 +1484,14 @@ exclusive:
 	default:
 		if (needs_exclusive || _lv_is_exclusive(lv))
 			goto exclusive;
-		log_verbose("Activating logical volume \"%s\".", lv->name);
+		log_verbose("Activating logical volume %s.", display_lvname(lv));
 		if (!activate_lv(cmd, lv))
 			return_0;
 	}
 
 	if (!is_change_activating(activate) &&
 	    !lockd_lv(cmd, lv, "un", LDLV_PERSISTENT))
-		log_error("Failed to unlock logical volume %s/%s", lv->vg->name, lv->name);
+		log_error("Failed to unlock logical volume %s.", display_lvname(lv));
 
 	return 1;
 }
@@ -1549,7 +1550,8 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 		/* Find any active LV from the pool */
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
 			if (lv_is_active(sl->seg->lv)) {
-				log_debug("Thin volume \"%s\" is active.", sl->seg->lv->name);
+				log_debug_activation("Thin volume %s is active.",
+						     display_lvname(lv));
 				return sl->seg->lv;
 			}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6cf7323..9f0d06d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5000,7 +5000,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 
 		if (seg_size >= (MAX_EXTENT_COUNT - existing_logical_extents)) {
 			log_error("Unable to extend %s by %u logical extents: exceeds limit (%u).",
-				  lp->lv_name, seg_size, MAX_EXTENT_COUNT);
+				  display_lvname(lv), seg_size, MAX_EXTENT_COUNT);
 			return 0;
 		}
 
@@ -5029,7 +5029,8 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 
 		if (lp->sign == SIGN_MINUS)  {
 			if (lp->extents >= existing_extents) {
-				log_error("Unable to reduce %s below 1 extent.", lp->lv_name);
+				log_error("Unable to reduce %s below 1 extent.",
+					  display_lvname(lv));
 				return 0;
 			}
 			new_extents = existing_extents - lp->extents;
@@ -5407,7 +5408,8 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	log_print_unless_silent("Logical volume %s successfully resized.", lp->lv_name);
+	log_print_unless_silent("Logical volume %s successfully resized.",
+				display_lvname(lv));
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
 	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL))
@@ -6068,19 +6070,22 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 			if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
 			    info.exists && info.live_table) {
 				if (!lv_snapshot_percent(lv, &snap_percent)) {
-					log_error("Failed to obtain merging snapshot progress percentage for logical volume %s.",
-						  lv->name);
+					log_error("Failed to obtain merging snapshot progress "
+						  "percentage for logical volume %s.",
+						  display_lvname(lv));
 					return 0;
 				}
 				if ((snap_percent != DM_PERCENT_INVALID) &&
 				     (snap_percent != LVM_PERCENT_MERGE_FAILED)) {
-					log_error("Can't remove merging snapshot logical volume \"%s\"",
-						  lv->name);
+					log_error("Can't remove merging snapshot logical volume %s.",
+						  display_lvname(lv));
 					return 0;
 				} else if ((snap_percent == LVM_PERCENT_MERGE_FAILED) &&
-					 (force == PROMPT) &&
-					 yes_no_prompt("Removing snapshot \"%s\" that failed to merge may leave origin \"%s\" inconsistent. "
-						       "Proceed? [y/n]: ", lv->name, origin_from_cow(lv)->name) == 'n')
+					   (force == PROMPT) &&
+					   yes_no_prompt("Removing snapshot %s that failed to merge "
+							 "may leave origin %s inconsistent. Proceed? [y/n]: ",
+							 display_lvname(lv),
+							 display_lvname(origin_from_cow(lv))) == 'n')
                                         goto no_remove;
 			}
 		} else if (!level && lv_is_virtual_origin(origin = origin_from_cow(lv)))
@@ -6108,22 +6113,22 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 
 	if (lv_is_merging_origin(lv)) {
 		if (!deactivate_lv(cmd, lv)) {
-			log_error("Unable to fully deactivate merging origin \"%s\".",
-				  lv->name);
+			log_error("Unable to fully deactivate merging origin %s.",
+				  display_lvname(lv));
 			return 0;
 		}
 		if (!lv_remove_with_dependencies(cmd, find_snapshot(lv)->lv,
 						 force, level + 1)) {
-			log_error("Unable to remove merging origin \"%s\".",
-				  lv->name);
+			log_error("Unable to remove merging origin %s.",
+				  display_lvname(lv));
 			return 0;
 		}
 	}
 
 	if (!level && lv_is_merging_thin_snapshot(lv)) {
 		/* Merged snapshot LV is no longer available for the user */
-		log_error("Unable to remove \"%s\", volume is merged to \"%s\".",
-			  lv->name, first_seg(lv)->merge_lv->name);
+		log_error("Unable to remove %s, volume is merged to %s.",
+			  display_lvname(lv), display_lvname(first_seg(lv)->merge_lv));
 		return 0;
 	}
 
@@ -6139,10 +6144,10 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	    (force == PROMPT)) {
 		dm_list_iterate_items(lvl, &lv->vg->lvs)
 			if (lv_is_pool_metadata(lvl->lv)) {
-				if (yes_no_prompt("Removal of pool metadata spare logical volume"
-						  " \"%s\" disables automatic recovery attempts"
-						  " after damage to a thin or cache pool."
-						  " Proceed? [y/n]: ", lv->name) == 'n')
+				if (yes_no_prompt("Removal of pool metadata spare logical volume "
+						  "%s disables automatic recovery attempts "
+						  "after damage to a thin or cache pool. "
+						  "Proceed? [y/n]: ", display_lvname(lv)) == 'n')
 					goto no_remove;
 				break;
 			}
@@ -6151,7 +6156,7 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	return lv_remove_single(cmd, lv, force, 0);
 
 no_remove:
-	log_error("Logical volume \"%s\" not removed.", lv->name);
+	log_error("Logical volume %s not removed.", display_lvname(lv));
 
 	return 0;
 }
@@ -6229,16 +6234,16 @@ static int _split_parent_area(struct lv_segment *seg, uint32_t s,
 	while (parent_area_len > 0) {
 		/* Find the layer segment pointed at */
 		if (!(spvs = _find_seg_pvs_by_le(layer_seg_pvs, layer_le))) {
-			log_error("layer segment for %s:%" PRIu32 " not found",
-				  seg->lv->name, parent_le);
+			log_error("layer segment for %s:" FMTu32 " not found.",
+				  display_lvname(seg->lv), parent_le);
 			return 0;
 		}
 
 		if (spvs->le != layer_le) {
 			log_error("Incompatible layer boundary: "
-				  "%s:%" PRIu32 "[%" PRIu32 "] on %s:%" PRIu32,
-				  seg->lv->name, parent_le, s,
-				  seg_lv(seg, s)->name, layer_le);
+				  "%s:" FMTu32 "[" FMTu32 "] on %s:" FMTu32 ".",
+				  display_lvname(seg->lv), parent_le, s,
+				  display_lvname(seg_lv(seg, s)), layer_le);
 			return 0;
 		}
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 2f66675..06d4242 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -171,7 +171,8 @@ int pool_is_active(const struct logical_volume *lv)
 	const struct seg_list *sl;
 
 	if (!lv_is_thin_pool(lv)) {
-		log_error(INTERNAL_ERROR "pool_is_active called with non-pool LV %s.", lv->name);
+		log_error(INTERNAL_ERROR "pool_is_active called with non-pool volume %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -182,7 +183,8 @@ int pool_is_active(const struct logical_volume *lv)
 
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
 			if (lv_is_active(sl->seg->lv)) {
-				log_debug("Thin volume \"%s\" is active.", sl->seg->lv->name);
+				log_debug_activation("Pool's thin volume %s is active.",
+						     display_lvname(sl->seg->lv));
 				return 1;
 			}
 	} else if (lv_info(lv->vg->cmd, lv, 1, &info, 0, 0) && info.exists)



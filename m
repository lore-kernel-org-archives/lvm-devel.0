From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  1 Jul 2013 21:13:32 +0000 (UTC)
Subject: master - cleanup: introduce return_ECMD_FAILED macro
Message-ID: <20130701211332.04B5160DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b90450b8a082b349297eac23f50cf4ac2e0ed8f6
Commit:        b90450b8a082b349297eac23f50cf4ac2e0ed8f6
Parent:        4d9ed81075729936666b151f981461f91e8f7437
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 1 11:27:22 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 1 23:10:33 2013 +0200

cleanup: introduce return_ECMD_FAILED macro

Use shortening macro for common code sequence
stack;
return ECMD_FAILED;
---
 lib/log/log.h        |    1 +
 tools/lvchange.c     |  122 ++++++++++++++++---------------------------------
 tools/lvconvert.c    |   73 ++++++++++++------------------
 tools/lvcreate.c     |    3 +-
 tools/lvmcmdline.c   |    6 +--
 tools/lvremove.c     |    6 +--
 tools/lvrename.c     |    9 +---
 tools/lvresize.c     |   58 ++++++++---------------
 tools/pvmove.c       |    3 +-
 tools/pvresize.c     |    8 +--
 tools/pvscan.c       |    3 +-
 tools/reporter.c     |   39 +++++-----------
 tools/toollib.c      |    6 +--
 tools/vgcfgbackup.c  |   18 +++-----
 tools/vgcfgrestore.c |    7 +--
 tools/vgchange.c     |   28 +++++-------
 tools/vgck.c         |   12 ++---
 tools/vgconvert.c    |   12 ++---
 tools/vgextend.c     |    3 +-
 tools/vgmerge.c      |   26 +++-------
 tools/vgmknodes.c    |   18 +++-----
 tools/vgremove.c     |   24 +++-------
 tools/vgrename.c     |    6 +--
 tools/vgsplit.c      |   27 ++++-------
 24 files changed, 180 insertions(+), 338 deletions(-)

diff --git a/lib/log/log.h b/lib/log/log.h
index 2e1c515..064ba0a 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -109,6 +109,7 @@
 
 #define return_0	do { stack; return 0; } while (0)
 #define return_NULL	do { stack; return NULL; } while (0)
+#define return_ECMD_FAILED do { stack; return ECMD_FAILED; } while (0)
 #define goto_out	do { stack; goto out; } while (0)
 #define goto_bad	do { stack; goto bad; } while (0)
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index f4706d1..5fc3585 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -950,84 +950,66 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* access permission change */
 	if (arg_count(cmd, permission_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 		doit += lvchange_permission(cmd, lv);
 		docmds++;
 	}
 
 	/* allocation policy change */
 	if (arg_count(cmd, contiguous_ARG) || arg_count(cmd, alloc_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 		doit += lvchange_alloc(cmd, lv);
 		docmds++;
 	}
 
 	/* read ahead sector change */
 	if (arg_count(cmd, readahead_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 		doit += lvchange_readahead(cmd, lv);
 		docmds++;
 	}
 
 	/* persistent device number change */
 	if (arg_count(cmd, persistent_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 		doit += lvchange_persistent(cmd, lv);
 		docmds++;
-		if (sigint_caught()) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (sigint_caught())
+			return_ECMD_FAILED;
 	}
 
 	if (arg_count(cmd, discards_ARG) ||
 	    arg_count(cmd, zero_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 		doit += lvchange_pool_update(cmd, lv);
 		docmds++;
 	}
 
 	/* add tag */
 	if (arg_count(cmd, addtag_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 		doit += lvchange_tag(cmd, lv, addtag_ARG);
 		docmds++;
 	}
 
 	/* del tag */
 	if (arg_count(cmd, deltag_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 		doit += lvchange_tag(cmd, lv, deltag_ARG);
 		docmds++;
 	}
 
 	/* change writemostly/writebehind */
 	if (arg_count(cmd, writemostly_ARG) || arg_count(cmd, writebehind_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 		doit += lvchange_writemostly(lv);
 		docmds++;
 	}
@@ -1035,10 +1017,8 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* change [min|max]_recovery_rate */
 	if (arg_count(cmd, minrecoveryrate_ARG) ||
 	    arg_count(cmd, maxrecoveryrate_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 		doit += lvchange_recovery_rate(lv);
 		docmds++;
 	}
@@ -1046,55 +1026,33 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (doit)
 		log_print_unless_silent("Logical volume \"%s\" changed.", lv->name);
 
-	if (arg_count(cmd, resync_ARG))
-		if (!lvchange_resync(cmd, lv)) {
-			stack;
-			return ECMD_FAILED;
-		}
+	if (arg_count(cmd, resync_ARG) &&
+	    !lvchange_resync(cmd, lv))
+		return_ECMD_FAILED;
 
-	if (arg_count(cmd, syncaction_ARG)) {
-		if (!lv_raid_message(lv, arg_str_value(cmd, syncaction_ARG, NULL))) {
-			stack;
-			return ECMD_FAILED;
-		}
-	}
+	if (arg_count(cmd, syncaction_ARG) &&
+	    !lv_raid_message(lv, arg_str_value(cmd, syncaction_ARG, NULL)))
+		return_ECMD_FAILED;
 
 	/* activation change */
 	if (arg_count(cmd, activate_ARG)) {
-		if (!_lvchange_activate(cmd, lv)) {
-			stack;
-			return ECMD_FAILED;
-		}
-	}
-
-	if (arg_count(cmd, refresh_ARG))
-		if (!lvchange_refresh(cmd, lv)) {
-			stack;
-			return ECMD_FAILED;
-		}
-
-	if (!arg_count(cmd, activate_ARG) &&
-	    !arg_count(cmd, refresh_ARG) &&
-	    arg_count(cmd, monitor_ARG)) {
-		if (!lvchange_monitoring(cmd, lv)) {
-			stack;
-			return ECMD_FAILED;
-		}
-	}
+		if (!_lvchange_activate(cmd, lv))
+			return_ECMD_FAILED;
+	} else if (arg_count(cmd, refresh_ARG)) {
+		if (!lvchange_refresh(cmd, lv))
+			return_ECMD_FAILED;
+	} else {
+		if (arg_count(cmd, monitor_ARG) &&
+		    !lvchange_monitoring(cmd, lv))
+			return_ECMD_FAILED;
 
-	if (!arg_count(cmd, activate_ARG) &&
-	    !arg_count(cmd, refresh_ARG) &&
-	    arg_count(cmd, poll_ARG)) {
-		if (!lvchange_background_polling(cmd, lv)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (arg_count(cmd, poll_ARG) &&
+		    !lvchange_background_polling(cmd, lv))
+			return_ECMD_FAILED;
 	}
 
-	if (doit != docmds) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (doit != docmds)
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index be6b55f..ac84aa6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2303,10 +2303,9 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			log_error("Unable to merge invalidated snapshot LV \"%s\"", lv->name);
 			return ECMD_FAILED;
 		}
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+
 		if (!lvconvert_merge(cmd, lv, lp)) {
 			log_error("Unable to merge LV \"%s\" into its origin.", lv->name);
 			return ECMD_FAILED;
@@ -2316,38 +2315,29 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
 			return ECMD_FAILED;
 		}
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
-		if (!lvconvert_snapshot(cmd, lv, lp)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+
+		if (!lvconvert_snapshot(cmd, lv, lp))
+			return_ECMD_FAILED;
+
 	} else if (arg_count(cmd, thinpool_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
-		if (!_lvconvert_thinpool(cmd, lv, lp)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+
+		if (!_lvconvert_thinpool(cmd, lv, lp))
+			return_ECMD_FAILED;
+
 	} else if (segtype_is_raid(lp->segtype) ||
 		   (lv->status & RAID) || lp->merge_mirror) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
-		if (!lvconvert_raid(lv, lp)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 
-		if (!(failed_pvs = _failed_pv_list(lv->vg))) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!lvconvert_raid(lv, lp))
+			return_ECMD_FAILED;
+
+		if (!(failed_pvs = _failed_pv_list(lv->vg)))
+			return_ECMD_FAILED;
 
 		/* If repairing and using policies, remove missing PVs from VG */
 		if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
@@ -2355,19 +2345,14 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	} else if (arg_count(cmd, mirrors_ARG) ||
 		   arg_count(cmd, splitmirrors_ARG) ||
 		   (lv->status & MIRRORED)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
-		if (!_lvconvert_mirrors(cmd, lv, lp)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
 
-		if (!(failed_pvs = _failed_pv_list(lv->vg))) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!_lvconvert_mirrors(cmd, lv, lp))
+			return_ECMD_FAILED;
+
+		if (!(failed_pvs = _failed_pv_list(lv->vg)))
+			return_ECMD_FAILED;
 
 		/* If repairing and using policies, remove missing PVs from VG */
 		if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 80ca1bc..69f8de0 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1057,8 +1057,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
-		stack;
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 	}
 
 	if (lp.snapshot && lp.origin && !_determine_snapshot_type(vg, &lp)) {
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 89ead2c..9c50918 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1057,10 +1057,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	/* each command should start out with sigint flag cleared */
 	sigint_clear();
 
-	if (!(cmd->cmd_line = _copy_command_line(cmd, argc, argv))) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!(cmd->cmd_line = _copy_command_line(cmd, argc, argv)))
+		return_ECMD_FAILED;
 
 	log_debug("Parsing: %s", cmd->cmd_line);
 
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 54094b1..4f48746 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -26,10 +26,8 @@ static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
         if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
                 lv = origin;
 
-	if (!lv_remove_with_dependencies(cmd, lv, (force_t) arg_count(cmd, force_ARG), 0)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!lv_remove_with_dependencies(cmd, lv, (force_t) arg_count(cmd, force_ARG), 0))
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 3dc21dc..a2182e8 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -85,10 +85,8 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (!apply_lvname_restrictions(lv_name_new)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!apply_lvname_restrictions(lv_name_new))
+		return_ECMD_FAILED;
 
 	if (!validate_name(lv_name_new)) {
 		log_error("New logical volume name \"%s\" is invalid",
@@ -105,8 +103,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
-		stack;
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 	}
 
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 9139228..1ba5a5c 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -533,7 +533,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			return ECMD_FAILED;
 		}
 		if (!_adjust_policy_params(cmd, lv, lp))
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 	}
 
 	if (!lv_is_visible(lv) &&
@@ -576,10 +576,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (!(pvh = lp->argc ? create_pv_list(cmd->mem, vg, lp->argc,
-						     lp->argv, 1) : &vg->pvs)) {
-		stack;
-		return ECMD_FAILED;
-	}
+						     lp->argv, 1) : &vg->pvs))
+		return_ECMD_FAILED;
 
 	if (lp->sizeargs) { /* TODO: reindent or move to function */
 
@@ -891,10 +889,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* Request confirmation before operations that are often mistakes. */
 	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
-	    !_request_confirmation(cmd, vg, lv, lp)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	    !_request_confirmation(cmd, vg, lv, lp))
+		return_ECMD_FAILED;
 
 	if (lp->resizefs) {
 		if (!lp->nofsck &&
@@ -913,10 +909,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		}
 	}
 
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!archive(vg))
+		return_ECMD_FAILED;
 
 	log_print_unless_silent("%sing logical volume %s to %s",
 				(lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
@@ -924,19 +918,15 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 				display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
 
 	if (lp->resize == LV_REDUCE) {
-		if (!lv_reduce(lv, lv->le_count - lp->extents)) {
-			stack;
+		if (!lv_reduce(lv, lv->le_count - lp->extents))
 			return ECMD_FAILED;
-		}
 	} else if ((lp->extents > lv->le_count) && /* Ensure we extend */
 		   !lv_extend(lv, lp->segtype,
 			      lp->stripes, lp->stripe_size,
 			      lp->mirrors, first_seg(lv)->region_size,
 			      lp->extents - lv->le_count, NULL,
-			      pvh, alloc)) {
-		stack;
-		return ECMD_FAILED;
-	}
+			      pvh, alloc))
+		return_ECMD_FAILED;
 
 	/* If thin metadata, must suspend thin pool */
 	if (lv_is_thin_pool_metadata(lv)) {
@@ -952,10 +942,9 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (lp->poolmetadatasize) {
 metadata_resize:
-		if (!(status = _lvresize_poolmetadata(cmd, vg, lp, lv, pvh, alloc))) {
-			stack;
-			return ECMD_FAILED;
-		} else if ((status == 2) && !lp->sizeargs)
+		if (!(status = _lvresize_poolmetadata(cmd, vg, lp, lv, pvh, alloc)))
+			return_ECMD_FAILED;
+		else if ((status == 2) && !lp->sizeargs)
 			return ECMD_PROCESSED;
 		lock_lv = lv;
 	}
@@ -964,10 +953,8 @@ metadata_resize:
 		return ECMD_PROCESSED; /* Nothing to do */
 
 	/* store vg on disk(s) */
-	if (!vg_write(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_write(vg))
+		return_ECMD_FAILED;
 
 	if (!suspend_lv(cmd, lock_lv)) {
 		log_error("Failed to suspend %s", lock_lv->name);
@@ -1005,18 +992,14 @@ metadata_resize:
 	 * FIXME: Activate only when thin volume is active
 	 */
 	if (lv_is_thin_pool(lv) &&
-	    !update_pool_lv(lv, !lv_is_active(lv))) {
-		stack;
-		return ECMD_FAILED;
-	}
+	    !update_pool_lv(lv, !lv_is_active(lv)))
+		return_ECMD_FAILED;
 
 	log_print_unless_silent("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
-	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL))
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
@@ -1034,8 +1017,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
-		stack;
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 	}
 
 	if (!(r = _lvresize(cmd, vg, &lp)))
diff --git a/tools/pvmove.c b/tools/pvmove.c
index cbfed3c..cb5c9ec 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -527,8 +527,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	vg = _get_vg(cmd, pv_vg_name(pv));
 	if (vg_read_error(vg)) {
 		release_vg(vg);
-		stack;
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 	}
 
 	exclusive = _pvmove_is_exclusive(cmd, vg);
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 26959e8..251cf9a 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -142,11 +142,9 @@ static int _pvresize_single(struct cmd_context *cmd,
 
 	params->total++;
 
-	if (!_pv_resize_single(cmd, vg, pv, params->new_size)) {
-		stack;
-		return ECMD_FAILED;
-	}
-	
+	if (!_pv_resize_single(cmd, vg, pv, params->new_size))
+		return_ECMD_FAILED;
+
 	params->done++;
 
 	return ECMD_PROCESSED;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 12b9a2d..a194c68 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -304,8 +304,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Walking through all physical volumes");
 	if (!(pvslist = get_pvs(cmd))) {
 		unlock_vg(cmd, VG_GLOBAL);
-		stack;
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 	}
 
 	/* eliminate exported/new if required */
diff --git a/tools/reporter.c b/tools/reporter.c
index 2744fcd..e8ecf98 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -20,10 +20,8 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name, struct volume_group *vg,
 		       void *handle)
 {
-	if (!report_object(handle, vg, NULL, NULL, NULL, NULL)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!report_object(handle, vg, NULL, NULL, NULL, NULL))
+		return_ECMD_FAILED;
 
 	check_current_backup(vg);
 
@@ -33,10 +31,8 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL))
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
@@ -44,10 +40,8 @@ static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 static int _segs_single(struct cmd_context *cmd __attribute__((unused)),
 			struct lv_segment *seg, void *handle)
 {
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL))
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
@@ -190,10 +184,8 @@ out:
 static int _label_single(struct cmd_context *cmd, struct volume_group *vg,
 		       struct physical_volume *pv, void *handle)
 {
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL))
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
@@ -202,10 +194,8 @@ static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		      struct volume_group *vg,
 		      void *handle)
 {
-	if (vg_read_error(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (vg_read_error(vg))
+		return_ECMD_FAILED;
 
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
 }
@@ -214,10 +204,8 @@ static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
 			 void *handle)
 {
-	if (vg_read_error(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (vg_read_error(vg))
+		return_ECMD_FAILED;
 
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvsegs_single);
 }
@@ -334,8 +322,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 					  columns_as_rows))) {
 		if (!strcasecmp(options, "help") || !strcmp(options, "?"))
 			return r;
-		stack;
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 	}
 
 	/* Ensure options selected are compatible */
diff --git a/tools/toollib.c b/tools/toollib.c
index b238a61..5853800 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -321,10 +321,8 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		vgname = strl->str;
 		dm_list_init(&cmd_vgs);
 		if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs,
-					  vgname, NULL, flags))) {
-			stack;
-			return ECMD_FAILED;
-		}
+					  vgname, NULL, flags)))
+			return_ECMD_FAILED;
 
 		if (!cmd_vg_read(cmd, &cmd_vgs)) {
 			free_cmd_vgs(&cmd_vgs);
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 32948d8..bee1b04 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -56,15 +56,11 @@ static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 
 	if (arg_count(cmd, file_ARG)) {
 		if (!(filename = _expand_filename(arg_value(cmd, file_ARG),
-						  vg->name, last_filename))) {
-			stack;
-			return ECMD_FAILED;
-		}
+						  vg->name, last_filename)))
+			return_ECMD_FAILED;
 
-		if (!backup_to_file(filename, vg->cmd->cmd_line, vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!backup_to_file(filename, vg->cmd->cmd_line, vg))
+			return_ECMD_FAILED;
 	} else {
 		if (vg_read_error(vg) == FAILED_INCONSISTENT) {
 			log_error("No backup taken: specify filename with -f "
@@ -75,10 +71,8 @@ static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 
 		/* just use the normal backup code */
 		backup_enable(cmd, 1);	/* force a backup */
-		if (!backup(vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!backup(vg))
+			return_ECMD_FAILED;
 	}
 
 	log_print_unless_silent("Volume group \"%s\" successfully backed up.", vg_name);
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 618fa7e..36396c3 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -38,10 +38,9 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		if (!(arg_count(cmd,file_ARG) ?
 			    archive_display_file(cmd,
 				arg_str_value(cmd, file_ARG, "")) :
-			    archive_display(cmd, vg_name))) {
-			stack;
-			return ECMD_FAILED;
-		}
+			    archive_display(cmd, vg_name)))
+			return_ECMD_FAILED;
+
 		return ECMD_PROCESSED;
 	}
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e9093f5..28747f6 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -464,22 +464,16 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 
 	for (i = 0; _vgchange_args[i].arg >= 0; i++) {
 		if (arg_count(cmd, _vgchange_args[i].arg)) {
-			if (!archive(vg)) {
-				stack;
-				return ECMD_FAILED;
-			}
-			if (!_vgchange_args[i].fn(cmd, vg)) {
-				stack;
-				return ECMD_FAILED;
-			}
+			if (!archive(vg))
+				return_ECMD_FAILED;
+			if (!_vgchange_args[i].fn(cmd, vg))
+				return_ECMD_FAILED;
 		}
 	}
 
 	if (vg_is_archived(vg)) {
-		if (!vg_write(vg) || !vg_commit(vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!vg_write(vg) || !vg_commit(vg))
+			return_ECMD_FAILED;
 
 		backup(vg);
 
@@ -489,13 +483,13 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	if (arg_count(cmd, activate_ARG)) {
 		if (!vgchange_activate(cmd, vg, (activation_change_t)
 				       arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 	}
 
 	if (arg_count(cmd, refresh_ARG)) {
 		/* refreshes the visible LVs (which starts polling) */
 		if (!_vgchange_refresh(cmd, vg))
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 	}
 
 	if (!arg_count(cmd, activate_ARG) &&
@@ -503,13 +497,13 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	    arg_count(cmd, monitor_ARG)) {
 		/* -ay* will have already done monitoring changes */
 		if (!_vgchange_monitoring(cmd, vg))
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 	}
 
 	if (!arg_count(cmd, refresh_ARG) &&
 	    background_polling())
 		if (!_vgchange_background_polling(cmd, vg))
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 
         return ECMD_PROCESSED;
 }
diff --git a/tools/vgck.c b/tools/vgck.c
index bdfee05..2a009db 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -21,15 +21,11 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 		       struct volume_group *vg,
 		       void *handle __attribute__((unused)))
 {
-	if (!vg_check_status(vg, EXPORTED_VG)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_check_status(vg, EXPORTED_VG))
+		return_ECMD_FAILED;
 
-	if (!vg_validate(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_validate(vg))
+		return_ECMD_FAILED;
 
 	if (vg_missing_pv_count(vg)) {
 		log_error("The volume group is missing %d physical volumes.",
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index b06fe34..3c984d7 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -30,10 +30,8 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	struct lvinfo info;
 	int active = 0;
 
-	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG))
+		return_ECMD_FAILED;
 
 	if (vg->fid->fmt == cmd->fmt) {
 		log_error("Volume group \"%s\" already uses format %s",
@@ -113,10 +111,8 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 		}
 	}
 
-	if (active) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (active)
+		return_ECMD_FAILED;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		existing_pv = pvl->pv;
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 1f482b4..0c00b7f 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -78,8 +78,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
-		stack;
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 	}
 
 	if (!archive(vg))
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 2cecb05..fb3321d 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -46,29 +46,19 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		lock_vg_from_first = 1;
 
 	if (lock_vg_from_first) {
-		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
-		if (!vg_from) {
-			stack;
-			return ECMD_FAILED;
-		}
-		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
-		if (!vg_to) {
-			stack;
+		if (!(vg_from = _vgmerge_vg_read(cmd, vg_name_from)))
+			return_ECMD_FAILED;
+		if (!(vg_to = _vgmerge_vg_read(cmd, vg_name_to))) {
 			unlock_and_release_vg(cmd, vg_from, vg_name_from);
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 		}
 	} else {
-		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
-		if (!vg_to) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!(vg_to = _vgmerge_vg_read(cmd, vg_name_to)))
+			return_ECMD_FAILED;
 
-		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
-		if (!vg_from) {
-			stack;
+		if (!(vg_from = _vgmerge_vg_read(cmd, vg_name_from))) {
 			unlock_and_release_vg(cmd, vg_to, vg_name_to);
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 		}
 	}
 
diff --git a/tools/vgmknodes.c b/tools/vgmknodes.c
index 0fd273f..9ba0677 100644
--- a/tools/vgmknodes.c
+++ b/tools/vgmknodes.c
@@ -19,25 +19,19 @@ static int _vgmknodes_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     void *handle __attribute__((unused)))
 {
 	if (arg_count(cmd, refresh_ARG) && lv_is_visible(lv))
-		if (!lv_refresh(cmd, lv)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!lv_refresh(cmd, lv))
+			return_ECMD_FAILED;
 
-	if (!lv_mknodes(cmd, lv)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!lv_mknodes(cmd, lv))
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
 
 int vgmknodes(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (!lv_mknodes(cmd, NULL)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!lv_mknodes(cmd, NULL))
+		return_ECMD_FAILED;
 
 	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
 			    &_vgmknodes_single);
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 6804f2a..52bdd2b 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -22,10 +22,8 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 	unsigned lv_count, missing;
 	force_t force;
 
-	if (!vg_check_status(vg, EXPORTED_VG)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_check_status(vg, EXPORTED_VG))
+		return_ECMD_FAILED;
 
 	lv_count = vg_visible_lvs(vg);
 
@@ -43,23 +41,17 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 				return ECMD_FAILED;
 			}
 		}
-		if (!remove_lvs_in_vg(cmd, vg, force)) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!remove_lvs_in_vg(cmd, vg, force))
+			return_ECMD_FAILED;
 	}
 
-	if (!force && !vg_remove_check(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!force && !vg_remove_check(vg))
+		return_ECMD_FAILED;
 
 	vg_remove_pvs(vg);
 
-	if (!vg_remove(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_remove(vg))
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
diff --git a/tools/vgrename.c b/tools/vgrename.c
index b476602..154a6f3 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -205,10 +205,8 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!vg_rename_path(cmd, argv[0], argv[1])) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_rename_path(cmd, argv[0], argv[1]))
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 6beaf34..a204b26 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -384,11 +384,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		lock_vg_from_first = 0;
 
 	if (lock_vg_from_first) {
-		vg_from = _vgsplit_from(cmd, vg_name_from);
-		if (!vg_from) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!(vg_from = _vgsplit_from(cmd, vg_name_from)))
+			return_ECMD_FAILED;
 		/*
 		 * Set metadata format of original VG.
 		 * NOTE: We must set the format before calling vg_create()
@@ -396,23 +393,17 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		 */
 		cmd->fmt = vg_from->fid->fmt;
 
-		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
-		if (!vg_to) {
+		if (!(vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg))) {
 			unlock_and_release_vg(cmd, vg_from, vg_name_from);
-			stack;
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 		}
 	} else {
-		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
-		if (!vg_to) {
-			stack;
-			return ECMD_FAILED;
-		}
-		vg_from = _vgsplit_from(cmd, vg_name_from);
-		if (!vg_from) {
+		if (!(vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg)))
+			return_ECMD_FAILED;
+
+		if (!(vg_from = _vgsplit_from(cmd, vg_name_from))) {
 			unlock_and_release_vg(cmd, vg_to, vg_name_to);
-			stack;
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 		}
 
 		if (cmd->fmt != vg_from->fid->fmt) {



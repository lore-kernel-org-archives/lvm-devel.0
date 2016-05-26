From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 26 May 2016 13:54:17 +0000 (UTC)
Subject: master - lvconvert: use process_each_lv
Message-ID: <20160526135417.BF68D60E61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f2b3c9100443593d94ed4ed2ed014b56537c0e0
Commit:        2f2b3c9100443593d94ed4ed2ed014b56537c0e0
Parent:        7fffcce9247cba8ecb40a1c7b0c6d18a5cde2165
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 23 13:42:17 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 25 15:05:49 2016 -0500

lvconvert: use process_each_lv

In the same way that process_each_vg() can be passed
a single VG name to process, also allow process_each_lv()
to be passed a single VG name and LV name to process.
---
 tools/lvchange.c  |    2 +-
 tools/lvconvert.c |   98 +++++++++++++++++-----------------------------------
 tools/lvdisplay.c |    2 +-
 tools/lvremove.c  |    2 +-
 tools/lvscan.c    |    3 +-
 tools/reporter.c  |    4 +-
 tools/toollib.c   |   39 +++++++++++++++++++--
 tools/toollib.h   |    1 +
 tools/vgmknodes.c |    3 +-
 9 files changed, 76 insertions(+), 78 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 1ce19c5..ad27786 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1330,7 +1330,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 			cmd->lockd_vg_enforce_sh = 1;
 	}
 
-	return process_each_lv(cmd, argc, argv,
+	return process_each_lv(cmd, argc, argv, NULL, NULL,
 			       update ? READ_FOR_UPDATE : 0, NULL,
 			       &_lvchange_single);
 }
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 39ce759..a4e7023 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3245,11 +3245,10 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
-			     void *handle)
+static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
+		      struct lvconvert_params *lp)
 {
 	struct logical_volume *origin = NULL;
-	struct lvconvert_params *lp = handle;
 	struct dm_list *failed_pvs;
 
 	if (lv_is_locked(lv)) {
@@ -3426,16 +3425,16 @@ static struct convert_poll_id_list* _convert_poll_id_list_create(struct cmd_cont
 	return idl;
 }
 
-static int _convert_and_add_to_poll_list(struct cmd_context *cmd,
-					 struct lvconvert_params *lp,
-					 struct logical_volume *lv)
+static int _lvconvert_and_add_to_poll_list(struct cmd_context *cmd,
+					    struct lvconvert_params *lp,
+					    struct logical_volume *lv)
 {
 	int ret;
 	struct lvinfo info;
 	struct convert_poll_id_list *idl;
 
-	/* _lvconvert_single() call may alter the reference in lp->lv_to_poll */
-	if ((ret = _lvconvert_single(cmd, lv, lp)) != ECMD_PROCESSED)
+	/* _lvconvert() call may alter the reference in lp->lv_to_poll */
+	if ((ret = _lvconvert(cmd, lv, lp)) != ECMD_PROCESSED)
 		stack;
 	else if (lp->need_polling) {
 		if (!lv_info(cmd, lp->lv_to_poll, 0, &info, 0, 0) || !info.exists)
@@ -3450,57 +3449,24 @@ static int _convert_and_add_to_poll_list(struct cmd_context *cmd,
 	return ret;
 }
 
-static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp)
+static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
+			     struct processing_handle *handle)
 {
-	struct logical_volume *lv;
-	struct volume_group *vg;
-	int ret = ECMD_FAILED;
-	int saved_ignore_suspended_devices = ignore_suspended_devices();
-	uint32_t lockd_state = 0;
-
-	if (lp->repair || lp->uncache) {
-		init_ignore_suspended_devices(1);
-		cmd->handles_missing_pvs = 1;
-	}
-
-	/* Unlock on error paths not required, it's automatic when command exits. */
-	if (!lockd_vg(cmd, lp->vg_name, "ex", 0, &lockd_state))
-		goto_out;
-
-	vg = vg_read(cmd, lp->vg_name, NULL, READ_FOR_UPDATE, lockd_state);
-	if (vg_read_error(vg)) {
-		release_vg(vg);
-		goto_out;
-	}
+	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
+	struct volume_group *vg = lv->vg;
 
 	if (test_mode() && is_lockd_type(vg->lock_type)) {
 		log_error("Test mode is not yet supported with lock type %s",
 			  vg->lock_type);
-		unlock_and_release_vg(cmd, vg, lp->vg_name);
-		goto_out;
-	}
-
-	if (!(lv = find_lv(vg, lp->lv_name))) {
-		log_error("Can't find LV %s in VG %s", lp->lv_name, lp->vg_name);
-		unlock_and_release_vg(cmd, vg, lp->vg_name);
-		goto_out;
+		return ECMD_FAILED;
 	}
 
 	/*
-	 * Request a transient lock.  If the LV is active, it has a persistent
-	 * lock already, and this request does nothing.  If the LV is not
-	 * active, this acquires a transient lock that will be released when
-	 * the command exits.
-	 */
-	if (!lockd_lv(cmd, lv, "ex", 0))
-		goto_bad;
-
-	/*
 	 * lp->pvh holds the list of PVs available for allocation or removal
 	 */
 	if (lp->pv_count) {
 		if (!(lp->pvh = create_pv_list(cmd->mem, vg, lp->pv_count, lp->pvs, 0)))
-			goto_bad;
+			return_ECMD_FAILED;
 	} else
 		lp->pvh = &vg->pvs;
 
@@ -3508,22 +3474,11 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 	    !(lp->replace_pvh = create_pv_list(cmd->mem, vg,
 					       lp->replace_pv_count,
 					       lp->replace_pvs, 0)))
-			goto_bad;
+			return_ECMD_FAILED;
 
 	lp->lv_to_poll = lv;
-	ret = _convert_and_add_to_poll_list(cmd, lp, lv);
 
-bad:
-	unlock_vg(cmd, lp->vg_name);
-
-	/* Unlock here so it's not held during polling. */
-	if (!lockd_vg(cmd, lp->vg_name, "un", 0, &lockd_state))
-		stack;
-
-	release_vg(vg);
-out:
-	init_ignore_suspended_devices(saved_ignore_suspended_devices);
-	return ret;
+	return _lvconvert_and_add_to_poll_list(cmd, lp, lv);
 }
 
 static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volume *lv,
@@ -3533,7 +3488,7 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 
 	lp->lv_to_poll = lv;
 
-	return _convert_and_add_to_poll_list(cmd, lp, lv);
+	return _lvconvert_and_add_to_poll_list(cmd, lp, lv);
 }
 
 int lvconvert(struct cmd_context * cmd, int argc, char **argv)
@@ -3558,11 +3513,22 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		goto_out;
 	}
 
-	if (lp.merge)
-		ret = process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, handle,
-				      &_lvconvert_merge_single);
-	else
-		ret = lvconvert_single(cmd, &lp);
+	if (lp.merge) {
+		ret = process_each_lv(cmd, argc, argv, NULL, NULL,
+				      READ_FOR_UPDATE, handle, &_lvconvert_merge_single);
+	} else {
+		int saved_ignore_suspended_devices = ignore_suspended_devices();
+
+		if (lp.repair || lp.uncache) {
+			init_ignore_suspended_devices(1);
+			cmd->handles_missing_pvs = 1;
+		}
+
+		ret = process_each_lv(cmd, 0, NULL, lp.vg_name, lp.lv_name,
+				      READ_FOR_UPDATE, handle, &_lvconvert_single);
+
+		init_ignore_suspended_devices(saved_ignore_suspended_devices);
+	}
 
 	dm_list_iterate_items(idl, &lp.idls) {
 		poll_ret = _lvconvert_poll_by_id(cmd, idl->id,
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index dd0ba48..e4d8bae 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -58,5 +58,5 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, 0, NULL, &_lvdisplay_single);
+	return process_each_lv(cmd, argc, argv, NULL, NULL, 0, NULL, &_lvdisplay_single);
 }
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 18da1fa..d807d04 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -26,6 +26,6 @@ int lvremove(struct cmd_context *cmd, int argc, char **argv)
 	cmd->handles_missing_pvs = 1;
 	cmd->include_historical_lvs = 1;
 
-	return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, NULL,
+	return process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, NULL,
 			       &lvremove_single);
 }
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 23d3d7f..528e54a 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -119,6 +119,5 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 		 */
 	}
 
-	return process_each_lv(cmd, argc, argv, 0, NULL,
-			       &lvscan_single);
+	return process_each_lv(cmd, argc, argv, NULL, NULL, 0, NULL, &lvscan_single);
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index 04ef8f2..bd77513 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -833,7 +833,7 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 		case LVSINFOSTATUS:
 			/* fall through */
 		case LVS:
-			r = process_each_lv(cmd, args->argc, args->argv, 0, handle,
+			r = process_each_lv(cmd, args->argc, args->argv, NULL, NULL, 0, handle,
 					    lv_info_needed && !lv_segment_status_needed ? &_lvs_with_info_single :
 					    !lv_info_needed && lv_segment_status_needed ? &_lvs_with_status_single :
 					    lv_info_needed && lv_segment_status_needed ? &_lvs_with_info_and_status_single :
@@ -857,7 +857,7 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 						    0, handle, &_pvs_in_vg);
 			break;
 		case SEGS:
-			r = process_each_lv(cmd, args->argc, args->argv, 0, handle,
+			r = process_each_lv(cmd, args->argc, args->argv, NULL, NULL, 0, handle,
 					    lv_info_needed && !lv_segment_status_needed ? &_lvsegs_with_info_single :
 					    !lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_status_single :
 					    lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_info_and_status_single :
diff --git a/tools/toollib.c b/tools/toollib.c
index 5383734..12dddc8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2489,6 +2489,7 @@ out:
  */
 static int _get_arg_lvnames(struct cmd_context *cmd,
 			    int argc, char **argv,
+			    const char *one_vgname, const char *one_lvname,
 			    struct dm_list *arg_vgnames,
 			    struct dm_list *arg_lvnames,
 			    struct dm_list *arg_tags)
@@ -2503,6 +2504,34 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 	const char *vgname_def;
 	unsigned dev_dir_found;
 
+	if (one_vgname) {
+		if (!str_list_add(cmd->mem, arg_vgnames,
+				  dm_pool_strdup(cmd->mem, one_vgname))) {
+			log_error("strlist allocation failed.");
+			return ECMD_FAILED;
+		}
+
+		if (!one_lvname) {
+			if (!str_list_add(cmd->mem, arg_lvnames,
+					  dm_pool_strdup(cmd->mem, one_vgname))) {
+				log_error("strlist allocation failed.");
+				return ECMD_FAILED;
+			}
+		} else {
+			vglv_sz = strlen(one_vgname) + strlen(one_lvname) + 2;
+			if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
+			    dm_snprintf(vglv, vglv_sz, "%s/%s", one_vgname, one_lvname) < 0) {
+				log_error("vg/lv string alloc failed.");
+				return ECMD_FAILED;
+			}
+			if (!str_list_add(cmd->mem, arg_lvnames, vglv)) {
+				log_error("strlist allocation failed.");
+				return ECMD_FAILED;
+			}
+		}
+		return ret_max;
+	}
+
 	for (; opt < argc; opt++) {
 		lv_name = argv[opt];
 		dev_dir_found = 0;
@@ -2687,8 +2716,12 @@ endvg:
 /*
  * Call process_single_lv() for each LV selected by the command line arguments.
  */
-int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t read_flags,
-		    struct processing_handle *handle, process_single_lv_fn_t process_single_lv)
+int process_each_lv(struct cmd_context *cmd,
+		    int argc, char **argv,
+		    const char *one_vgname, const char *one_lvname,
+		    uint32_t read_flags,
+		    struct processing_handle *handle,
+		    process_single_lv_fn_t process_single_lv)
 {
 	int handle_supplied = handle != NULL;
 	struct dm_list arg_tags;		/* str_list */
@@ -2713,7 +2746,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t rea
 	/*
 	 * Find any LVs, VGs or tags explicitly provided on the command line.
 	 */
-	if ((ret = _get_arg_lvnames(cmd, argc, argv, &arg_vgnames, &arg_lvnames, &arg_tags) != ECMD_PROCESSED)) {
+	if ((ret = _get_arg_lvnames(cmd, argc, argv, one_vgname, one_lvname, &arg_vgnames, &arg_lvnames, &arg_tags) != ECMD_PROCESSED)) {
 		ret_max = ret;
 		goto_out;
 	}
diff --git a/tools/toollib.h b/tools/toollib.h
index a79c426..a366e68 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -121,6 +121,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 			       process_single_pvseg_fn_t process_single_pvseg);
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
+		    const char *one_vgname, const char *one_lvname,
 		    uint32_t flags, struct processing_handle *handle,
 		    process_single_lv_fn_t process_single_lv);
 
diff --git a/tools/vgmknodes.c b/tools/vgmknodes.c
index 41b1c6a..81580b7 100644
--- a/tools/vgmknodes.c
+++ b/tools/vgmknodes.c
@@ -33,6 +33,5 @@ int vgmknodes(struct cmd_context *cmd, int argc, char **argv)
 	if (!lv_mknodes(cmd, NULL))
 		return_ECMD_FAILED;
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
-			    &_vgmknodes_single);
+	return process_each_lv(cmd, argc, argv, NULL, NULL, LCK_VG_READ, NULL, &_vgmknodes_single);
 }



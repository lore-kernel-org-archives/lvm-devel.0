From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:09:59 +0000 (UTC)
Subject: master - process_each_lv: add check_single_lv function
Message-ID: <20170213180959.68CB060EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c6c55c314199a9ba26fe1b864306b2ca8a8dbcd
Commit:        9c6c55c314199a9ba26fe1b864306b2ca8a8dbcd
Parent:        1e2420bca85da9a37570871cd70192e9ae831786
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 29 12:00:15 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

process_each_lv: add check_single_lv function

The new check_single_lv() function is called prior to the
existing process_single_lv().  If the check function returns 0,
the LV will not be processed.

The check_single_lv function is meant to be a standard method
to validate the combination of specific command + specific LV,
and decide if the combination is allowed.  The check_single
function can be used by anything that calls process_each_lv.

As commands are migrated to take advantage of command
definitions, each command definition gets its own entry
point which calls process_each for itself, passing a
pair of check_single/process_single functions which can
be specific to the narrowly defined command def.
---
 tools/lvchange.c  |    2 +-
 tools/lvconvert.c |    4 ++--
 tools/lvdisplay.c |    2 +-
 tools/lvremove.c  |    2 +-
 tools/lvscan.c    |    2 +-
 tools/reporter.c  |    8 ++++----
 tools/toollib.c   |   13 +++++++++++--
 tools/toollib.h   |   14 ++++++++++++++
 tools/vgdisplay.c |    2 +-
 tools/vgmknodes.c |    2 +-
 tools/vgremove.c  |    2 +-
 11 files changed, 38 insertions(+), 15 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 9fec436..d75a8ec 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1434,5 +1434,5 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 
 	return process_each_lv(cmd, argc, argv, NULL, NULL,
 			       update ? READ_FOR_UPDATE : 0, NULL,
-			       &_lvchange_single);
+			       NULL, &_lvchange_single);
 }
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 382f170..132d66d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4834,7 +4834,7 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 
 	if (lp.merge) {
 		ret = process_each_lv(cmd, argc, argv, NULL, NULL,
-				      READ_FOR_UPDATE, handle, &_lvconvert_merge_single);
+				      READ_FOR_UPDATE, handle, NULL, &_lvconvert_merge_single);
 	} else {
 		int saved_ignore_suspended_devices = ignore_suspended_devices();
 
@@ -4844,7 +4844,7 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		}
 
 		ret = process_each_lv(cmd, 0, NULL, lp.vg_name, lp.lv_name,
-				      READ_FOR_UPDATE, handle, &_lvconvert_single);
+				      READ_FOR_UPDATE, handle, NULL, &_lvconvert_single);
 
 		init_ignore_suspended_devices(saved_ignore_suspended_devices);
 	}
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index c60b463..b8c4b46 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -58,5 +58,5 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, NULL, NULL, 0, NULL, &_lvdisplay_single);
+	return process_each_lv(cmd, argc, argv, NULL, NULL, 0, NULL, NULL, &_lvdisplay_single);
 }
diff --git a/tools/lvremove.c b/tools/lvremove.c
index d807d04..4653817 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -27,5 +27,5 @@ int lvremove(struct cmd_context *cmd, int argc, char **argv)
 	cmd->include_historical_lvs = 1;
 
 	return process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, NULL,
-			       &lvremove_single);
+			       NULL, &lvremove_single);
 }
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 4e188d0..ab3238b 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -119,5 +119,5 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 		 */
 	}
 
-	return process_each_lv(cmd, argc, argv, NULL, NULL, 0, NULL, &lvscan_single);
+	return process_each_lv(cmd, argc, argv, NULL, NULL, 0, NULL, NULL, &lvscan_single);
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index 00606ed..980f39c 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -545,14 +545,14 @@ static int _report_all_in_vg(struct cmd_context *cmd, struct processing_handle *
 			r = _vgs_single(cmd, vg->name, vg, handle);
 			break;
 		case LVS:
-			r = process_each_lv_in_vg(cmd, vg, NULL, NULL, 0, handle,
+			r = process_each_lv_in_vg(cmd, vg, NULL, NULL, 0, handle, NULL,
 						  do_lv_info && !do_lv_seg_status ? &_lvs_with_info_single :
 						  !do_lv_info && do_lv_seg_status ? &_lvs_with_status_single :
 						  do_lv_info && do_lv_seg_status ? &_lvs_with_info_and_status_single :
 										   &_lvs_single);
 			break;
 		case SEGS:
-			r = process_each_lv_in_vg(cmd, vg, NULL, NULL, 0, handle,
+			r = process_each_lv_in_vg(cmd, vg, NULL, NULL, 0, handle, NULL,
 						  do_lv_info && !do_lv_seg_status ? &_lvsegs_with_info_single :
 						  !do_lv_info && do_lv_seg_status ? &_lvsegs_with_status_single :
 						  do_lv_info && do_lv_seg_status ? &_lvsegs_with_info_and_status_single :
@@ -1127,7 +1127,7 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 			if (args->full_report_vg)
 				r = _report_all_in_vg(cmd, handle, args->full_report_vg, LVS, lv_info_needed, lv_segment_status_needed);
 			else
-				r = process_each_lv(cmd, args->argc, args->argv, NULL, NULL, 0, handle,
+				r = process_each_lv(cmd, args->argc, args->argv, NULL, NULL, 0, handle, NULL,
 						    lv_info_needed && !lv_segment_status_needed ? &_lvs_with_info_single :
 						    !lv_info_needed && lv_segment_status_needed ? &_lvs_with_status_single :
 						    lv_info_needed && lv_segment_status_needed ? &_lvs_with_info_and_status_single :
@@ -1161,7 +1161,7 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 			if (args->full_report_vg)
 				r = _report_all_in_vg(cmd, handle, args->full_report_vg, SEGS, lv_info_needed, lv_segment_status_needed);
 			else
-				r = process_each_lv(cmd, args->argc, args->argv, NULL, NULL, 0, handle,
+				r = process_each_lv(cmd, args->argc, args->argv, NULL, NULL, 0, handle, NULL,
 						    lv_info_needed && !lv_segment_status_needed ? &_lvsegs_with_info_single :
 						    !lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_status_single :
 						    lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_info_and_status_single :
diff --git a/tools/toollib.c b/tools/toollib.c
index 06d4066..13e9b6f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2924,6 +2924,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  struct dm_list *arg_lvnames, const struct dm_list *tags_in,
 			  int stop_on_error,
 			  struct processing_handle *handle,
+			  check_single_lv_fn_t check_single_lv,
 			  process_single_lv_fn_t process_single_lv)
 {
 	log_report_t saved_log_report_state = log_get_report_state();
@@ -3127,6 +3128,12 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			continue;
 		}
 
+		if (check_single_lv && !check_single_lv(cmd, lvl->lv, handle, lv_is_named_arg)) {
+			if (lv_is_named_arg)
+				ret_max = ECMD_FAILED;
+			continue;
+		}
+
 		log_very_verbose("Processing LV %s in VG %s.", lvl->lv->name, vg->name);
 
 		ret = process_single_lv(cmd, lvl->lv, handle);
@@ -3363,6 +3370,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 				     struct dm_list *arg_lvnames,
 				     struct dm_list *arg_tags,
 				     struct processing_handle *handle,
+				     check_single_lv_fn_t check_single_lv,
 				     process_single_lv_fn_t process_single_lv)
 {
 	log_report_t saved_log_report_state = log_get_report_state();
@@ -3455,7 +3463,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 			goto endvg;
 
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, 0,
-					    handle, process_single_lv);
+					    handle, check_single_lv, process_single_lv);
 		if (ret != ECMD_PROCESSED)
 			stack;
 		report_log_ret_code(ret);
@@ -3486,6 +3494,7 @@ int process_each_lv(struct cmd_context *cmd,
 		    const char *one_vgname, const char *one_lvname,
 		    uint32_t read_flags,
 		    struct processing_handle *handle,
+		    check_single_lv_fn_t check_single_lv,
 		    process_single_lv_fn_t process_single_lv)
 {
 	log_report_t saved_log_report_state = log_get_report_state();
@@ -3601,7 +3610,7 @@ int process_each_lv(struct cmd_context *cmd,
 		_choose_vgs_to_process(cmd, &arg_vgnames, &vgnameids_on_system, &vgnameids_to_process);
 
 	ret = _process_lv_vgnameid_list(cmd, read_flags, &vgnameids_to_process, &arg_vgnames, &arg_lvnames,
-					&arg_tags, handle, process_single_lv);
+					&arg_tags, handle, check_single_lv, process_single_lv);
 
 	if (ret > ret_max)
 		ret_max = ret;
diff --git a/tools/toollib.h b/tools/toollib.h
index d44b825..67e45a2 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -98,6 +98,18 @@ typedef int (*process_single_pvseg_fn_t) (struct cmd_context * cmd,
 					  struct pv_segment * pvseg,
 					  struct processing_handle *handle);
 
+/*
+ * Called prior to process_single_lv() to decide if the LV should be
+ * processed.  If this returns 0, the LV is not processed.
+ *
+ * This can evaluate the combination of command definition and
+ * the LV object to decide if the combination is allowed.
+ */
+typedef int (*check_single_lv_fn_t) (struct cmd_context *cmd,
+				     struct logical_volume *lv,
+				     struct processing_handle *handle,
+				     int lv_is_named_arg);
+
 int process_each_vg(struct cmd_context *cmd,
 	            int argc, char **argv,
 		    const char *one_vgname,
@@ -125,6 +137,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		    const char *one_vgname, const char *one_lvname,
 		    uint32_t flags, struct processing_handle *handle,
+		    check_single_lv_fn_t check_single_lv,
 		    process_single_lv_fn_t process_single_lv);
 
 
@@ -141,6 +154,7 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  struct dm_list *arg_lvnames, const struct dm_list *tagsl,
 			  int stop_on_error, struct processing_handle *handle,
+			  check_single_lv_fn_t check_single_lv,
 			  process_single_lv_fn_t process_single_lv);
 
 struct processing_handle *init_processing_handle(struct cmd_context *cmd, struct processing_handle *parent_handle);
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 7bb2e6a..7fc64b0 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -38,7 +38,7 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 		vgdisplay_extents(vg);
 
 		process_each_lv_in_vg(cmd, vg, NULL, NULL, 0, NULL,
-				      (process_single_lv_fn_t)lvdisplay_full);
+				      NULL, (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");
 		process_each_pv_in_vg(cmd, vg, NULL,
diff --git a/tools/vgmknodes.c b/tools/vgmknodes.c
index f974ff3..9942af7 100644
--- a/tools/vgmknodes.c
+++ b/tools/vgmknodes.c
@@ -33,5 +33,5 @@ int vgmknodes(struct cmd_context *cmd, int argc, char **argv)
 	if (!lv_mknodes(cmd, NULL))
 		return_ECMD_FAILED;
 
-	return process_each_lv(cmd, argc, argv, NULL, NULL, LCK_VG_READ, NULL, &_vgmknodes_single);
+	return process_each_lv(cmd, argc, argv, NULL, NULL, LCK_VG_READ, NULL, NULL, &_vgmknodes_single);
 }
diff --git a/tools/vgremove.c b/tools/vgremove.c
index f0da2f8..d105fc6 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -62,7 +62,7 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 		}
 
 		if ((ret = process_each_lv_in_vg(cmd, vg, NULL, NULL, 1, &void_handle,
-						 (process_single_lv_fn_t)lvremove_single)) != ECMD_PROCESSED) {
+						 NULL, (process_single_lv_fn_t)lvremove_single)) != ECMD_PROCESSED) {
 			stack;
 			return ret;
 		}



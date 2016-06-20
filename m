From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:33 +0000 (UTC)
Subject: master - toollib: add 'parent' field to processing_handle; init report format only if there's no parent
Message-ID: <20160620094033.B74936031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f752a953022387cc7e5c4da11d118c12e3716ce4
Commit:        f752a953022387cc7e5c4da11d118c12e3716ce4
Parent:        c099f531fbb1702ea0aed16e5deec0368e7e7250
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 31 12:24:05 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:41 2016 +0200

toollib: add 'parent' field to processing_handle; init report format only if there's no parent

If there's parent processing handle, we don't need to create completely
new report group and status report - we'll just reuse the one already
initialized for the parent.

Currently, the situation where this matter is when doing internal report
to do the selection for processing commands where we have parent processing
handle for the command itself and processing handle for the selection
part (that is selection for non-reporting tools).
---
 tools/lvconvert.c   |    2 +-
 tools/lvcreate.c    |    2 +-
 tools/lvrename.c    |    2 +-
 tools/lvresize.c    |    2 +-
 tools/polldaemon.c  |    4 ++--
 tools/pvchange.c    |    2 +-
 tools/pvcreate.c    |    2 +-
 tools/pvmove.c      |    2 +-
 tools/pvremove.c    |    2 +-
 tools/pvresize.c    |    2 +-
 tools/pvscan.c      |    4 ++--
 tools/reporter.c    |    4 ++--
 tools/toollib.c     |   22 +++++++++++++---------
 tools/toollib.h     |    3 ++-
 tools/vgcfgbackup.c |    2 +-
 tools/vgcreate.c    |    2 +-
 tools/vgextend.c    |    2 +-
 tools/vgreduce.c    |    2 +-
 tools/vgrename.c    |    2 +-
 19 files changed, 35 insertions(+), 30 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a4e7023..a711c31 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3499,7 +3499,7 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		.target_attr = ~0,
 		.idls = DM_LIST_HEAD_INIT(lp.idls),
 	};
-	struct processing_handle *handle = init_processing_handle(cmd);
+	struct processing_handle *handle = init_processing_handle(cmd, NULL);
 
 	if (!handle) {
 		log_error("Failed to initialize processing handle.");
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index b1bf1af..fb28dc5 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1557,7 +1557,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	pp.lp = &lp;
 	pp.lcp = &lcp;
 
-        if (!(handle = init_processing_handle(cmd))) {
+        if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/lvrename.c b/tools/lvrename.c
index e9dd061..4dfcda2 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -210,7 +210,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	if (!(lp.lv_name_new = dm_pool_strdup(cmd->mem, lv_name_new)))
 		return ECMD_FAILED;
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 7a86178..05e386f 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -216,7 +216,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index f8aa49c..e12a694 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -561,7 +561,7 @@ static int _lvmpoll_daemon(struct cmd_context *cmd, struct poll_operation_id *id
 		return r ? ECMD_PROCESSED : ECMD_FAILED;
 	} else {
 		/* process all in-flight operations */
-		if (!(handle = init_processing_handle(cmd))) {
+		if (!(handle = init_processing_handle(cmd, NULL))) {
 			log_error("Failed to initialize processing handle.");
 			return ECMD_FAILED;
 		} else {
@@ -614,7 +614,7 @@ static int _poll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
 	} else {
 		if (!parms->interval)
 			parms->interval = find_config_tree_int(cmd, activation_polling_interval_CFG, NULL);
-		if (!(handle = init_processing_handle(cmd))) {
+		if (!(handle = init_processing_handle(cmd, NULL))) {
 			log_error("Failed to initialize processing handle.");
 			ret = ECMD_FAILED;
 		} else {
diff --git a/tools/pvchange.c b/tools/pvchange.c
index e100b80..ed99e7c 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -216,7 +216,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		ret = ECMD_FAILED;
 		goto out;
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 77f5969..ae133fa 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -147,7 +147,7 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	cmd->lockd_gl_disable = 1;
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/pvmove.c b/tools/pvmove.c
index b5df45a..f5f5654 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -877,7 +877,7 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 		if (is_abort)
 			cmd->lockd_vg_default_sh = 1;
 
-		if (!(handle = init_processing_handle(cmd))) {
+		if (!(handle = init_processing_handle(cmd, NULL))) {
 			log_error("Failed to initialize processing handle.");
 			return ECMD_FAILED;
 		}
diff --git a/tools/pvremove.c b/tools/pvremove.c
index dd9a4e8..e262eb0 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -43,7 +43,7 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	cmd->lockd_gl_disable = 1;
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 9931cc6..ddff520 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -86,7 +86,7 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 
 	set_pv_notify(cmd);
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		ret = ECMD_FAILED;
 		goto out;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 9b50374..db678d1 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -273,7 +273,7 @@ static int _pvscan_autoactivate(struct cmd_context *cmd, struct pvscan_aa_params
 	if (!lvmetad_used())
 		log_warn("WARNING: Autoactivation reading from disk instead of lvmetad.");
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
@@ -633,7 +633,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		ret = ECMD_FAILED;
 		goto out;
diff --git a/tools/reporter.c b/tools/reporter.c
index d8aac68..7bd5d36 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -581,7 +581,7 @@ int report_for_selection(struct cmd_context *cmd,
 				    &sh->report_type))
 		return_0;
 
-	if (!(handle = init_processing_handle(cmd)))
+	if (!(handle = init_processing_handle(cmd, parent_handle)))
 		return_0;
 
 	/*
@@ -832,7 +832,7 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args, struct
 	int lv_segment_status_needed;
 	int r = ECMD_FAILED;
 
-	if (!(handle = init_processing_handle(cmd)))
+	if (!(handle = init_processing_handle(cmd, NULL)))
 		goto_out;
 
 	if (!(report_handle = report_init(cmd, single_args->options, single_args->keys, &report_type,
diff --git a/tools/toollib.c b/tools/toollib.c
index e091467..3b2ad6a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1705,7 +1705,7 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 	return ret_max;
 }
 
-struct processing_handle *init_processing_handle(struct cmd_context *cmd)
+struct processing_handle *init_processing_handle(struct cmd_context *cmd, struct processing_handle *parent_handle)
 {
 	struct processing_handle *handle;
 
@@ -1714,6 +1714,8 @@ struct processing_handle *init_processing_handle(struct cmd_context *cmd)
 		return NULL;
 	}
 
+	handle->parent = parent_handle;
+
 	/*
 	 * For any reporting tool, the internal_report_for_select is reset to 0
 	 * automatically because the internal reporting/selection is simply not
@@ -1725,10 +1727,12 @@ struct processing_handle *init_processing_handle(struct cmd_context *cmd)
 	handle->internal_report_for_select = arg_is_set(cmd, select_ARG);
 	handle->include_historical_lvs = cmd->include_historical_lvs;
 
-	if (!report_format_init(cmd, &handle->report_group_type, &handle->report_group,
-				&handle->log_rh)) {
-		dm_pool_free(cmd->mem, handle);
-		return NULL;
+	if (!parent_handle) {
+		if (!report_format_init(cmd, &handle->report_group_type, &handle->report_group,
+					&handle->log_rh)) {
+			dm_pool_free(cmd->mem, handle);
+			return NULL;
+		}
 	}
 
 	return handle;
@@ -2189,7 +2193,7 @@ int process_each_vg(struct cmd_context *cmd,
 	else
 		_choose_vgs_to_process(cmd, &arg_vgnames, &vgnameids_on_system, &vgnameids_to_process);
 
-	if (!handle && !(handle = init_processing_handle(cmd))) {
+	if (!handle && !(handle = init_processing_handle(cmd, NULL))) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
@@ -2286,7 +2290,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	if (arg_lvnames && !dm_list_empty(arg_lvnames))
 		lvargs_supplied = 1;
 
-	if (!handle && !(handle = init_processing_handle(cmd))) {
+	if (!handle && !(handle = init_processing_handle(cmd, NULL))) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
@@ -2747,7 +2751,7 @@ int process_each_lv(struct cmd_context *cmd,
 		goto_out;
 	}
 
-	if (!handle && !(handle = init_processing_handle(cmd))) {
+	if (!handle && !(handle = init_processing_handle(cmd, NULL))) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
@@ -3168,7 +3172,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
-	if (!handle && (!(handle = init_processing_handle(cmd)))) {
+	if (!handle && (!(handle = init_processing_handle(cmd, NULL)))) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
diff --git a/tools/toollib.h b/tools/toollib.h
index 622badc..8cd9087 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -69,6 +69,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm);
  * a part of that reporting for display (dm_report_object).
  */
 struct processing_handle {
+	struct processing_handle *parent;
 	int internal_report_for_select;
 	int include_historical_lvs;
 	struct selection_handle *selection_handle;
@@ -144,7 +145,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  int stop_on_error, struct processing_handle *handle,
 			  process_single_lv_fn_t process_single_lv);
 
-struct processing_handle *init_processing_handle(struct cmd_context *cmd);
+struct processing_handle *init_processing_handle(struct cmd_context *cmd, struct processing_handle *parent_handle);
 int init_selection_handle(struct cmd_context *cmd, struct processing_handle *handle,
 			  report_type_t initial_report_type);
 void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle *handle);
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 554317e..c47c1ef 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -85,7 +85,7 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 	char *last_filename = NULL;
 	struct processing_handle *handle = NULL;
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 3811583..974d7e7 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -92,7 +92,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	unlock_vg(cmd, vp_new.vg_name);
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 24b51cf..8f44672 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -169,7 +169,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	cmd->lockd_gl_disable = 1;
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 3176a0e..ae86a67 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -222,7 +222,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	cmd->lockd_gl_disable = 1;
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgrename.c b/tools/vgrename.c
index ee6a91f..3dceeab 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -237,7 +237,7 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	if (!(handle = init_processing_handle(cmd))) {
+	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}



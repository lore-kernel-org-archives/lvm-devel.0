From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 23 May 2016 17:05:10 +0000 (UTC)
Subject: master - toollib: add vg name list arg to process_each_vg
Message-ID: <20160523170510.F2D9360D7B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55683a659f9bf6875dd930e2dff62f1e1bdb88aa
Commit:        55683a659f9bf6875dd930e2dff62f1e1bdb88aa
Parent:        bf8d00985ada723778701530c7ea863c617dda8a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 28 16:18:20 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 23 11:18:16 2016 -0500

toollib: add vg name list arg to process_each_vg

---
 tools/lvcreate.c    |    2 +-
 tools/lvrename.c    |    2 +-
 tools/lvresize.c    |    2 +-
 tools/polldaemon.c  |    4 ++--
 tools/reporter.c    |    6 +++---
 tools/toollib.c     |   17 +++++++++++++----
 tools/toollib.h     |    7 +++++--
 tools/vgcfgbackup.c |    2 +-
 tools/vgchange.c    |    2 +-
 tools/vgck.c        |    2 +-
 tools/vgconvert.c   |    2 +-
 tools/vgdisplay.c   |    2 +-
 tools/vgexport.c    |    2 +-
 tools/vgextend.c    |    2 +-
 tools/vgimport.c    |    2 +-
 tools/vgremove.c    |    2 +-
 tools/vgrename.c    |    2 +-
 tools/vgscan.c      |    2 +-
 18 files changed, 37 insertions(+), 25 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8ddecae..b1bf1af 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1564,7 +1564,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &pp;
 
-	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, READ_FOR_UPDATE, handle,
+	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, NULL, READ_FOR_UPDATE, handle,
 			      &_lvcreate_single);
 
 	_destroy_lvcreate_params(&lp);
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 56c19fd..e9dd061 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -217,7 +217,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &lp;
 
-	ret = process_each_vg(cmd, 0, NULL, vg_name, READ_FOR_UPDATE, handle,
+	ret = process_each_vg(cmd, 0, NULL, vg_name, NULL, READ_FOR_UPDATE, handle,
 			      _lvrename_single);
 
 	destroy_processing_handle(cmd, handle);
diff --git a/tools/lvresize.c b/tools/lvresize.c
index a35a03d..7a86178 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -223,7 +223,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &lp;
 
-	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, READ_FOR_UPDATE, handle,
+	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, NULL, READ_FOR_UPDATE, handle,
 			      &_lvresize_single);
 
 	destroy_processing_handle(cmd, handle);
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 6b15a0d..f8aa49c 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -364,7 +364,7 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 
 	while (1) {
 		parms->outstanding_count = 0;
-		process_each_vg(cmd, 0, NULL, NULL, READ_FOR_UPDATE, handle, _poll_vg);
+		process_each_vg(cmd, 0, NULL, NULL, NULL, READ_FOR_UPDATE, handle, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
 		if (parms->interval)
@@ -508,7 +508,7 @@ static void _lvmpolld_poll_for_all_vgs(struct cmd_context *cmd,
 
 	handle->custom_handle = &lpdp;
 
-	process_each_vg(cmd, 0, NULL, NULL, 0, handle, _lvmpolld_init_poll_vg);
+	process_each_vg(cmd, 0, NULL, NULL, NULL, 0, handle, _lvmpolld_init_poll_vg);
 
 	first = dm_list_first(&lpdp.idls);
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 4e27159..4004f9b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -837,7 +837,7 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 											 &_lvs_single);
 			break;
 		case VGS:
-			r = process_each_vg(cmd, args->argc, args->argv, NULL, 0,
+			r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL, 0,
 					    handle, &_vgs_single);
 			break;
 		case LABEL:
@@ -850,7 +850,7 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 						    arg_is_set(cmd, all_ARG), 0,
 						    handle, &_pvs_single);
 			else
-				r = process_each_vg(cmd, args->argc, args->argv, NULL,
+				r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL,
 						    0, handle, &_pvs_in_vg);
 			break;
 		case SEGS:
@@ -870,7 +870,7 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 						    lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_info_and_status_single :
 												 &_pvsegs_single);
 			else
-				r = process_each_vg(cmd, args->argc, args->argv, NULL,
+				r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL,
 						    0, handle, &_pvsegs_in_vg);
 			break;
 		default:
diff --git a/tools/toollib.c b/tools/toollib.c
index 17a29e0..e879850 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1645,6 +1645,7 @@ int validate_restricted_lvname_param(struct cmd_context *cmd, const char **vg_na
 static int _get_arg_vgnames(struct cmd_context *cmd,
 			    int argc, char **argv,
 			    const char *one_vgname,
+			    struct dm_list *use_vgnames,
 			    struct dm_list *arg_vgnames,
 			    struct dm_list *arg_tags)
 {
@@ -1661,6 +1662,11 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 		return ret_max;
 	}
 
+	if (use_vgnames && !dm_list_empty(use_vgnames)) {
+		dm_list_splice(arg_vgnames, use_vgnames);
+		return ret_max;
+	}
+
 	for (; opt < argc; opt++) {
 		vg_name = argv[opt];
 
@@ -2073,11 +2079,14 @@ static void _choose_vgs_to_process(struct cmd_context *cmd,
 
 /*
  * Call process_single_vg() for each VG selected by the command line arguments.
- * If one_vgname is set, process only that VG and ignore argc/argv (which should be 0/NULL)..
+ * If one_vgname is set, process only that VG and ignore argc/argv (which should be 0/NULL).
  * If one_vgname is not set, get VG names to process from argc/argv.
  */
-int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    const char *one_vgname, uint32_t read_flags,
+int process_each_vg(struct cmd_context *cmd,
+		    int argc, char **argv,
+		    const char *one_vgname,
+		    struct dm_list *use_vgnames,
+		    uint32_t read_flags,
 		    struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg)
 {
@@ -2104,7 +2113,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	/*
 	 * Find any VGs or tags explicitly provided on the command line.
 	 */
-	if ((ret = _get_arg_vgnames(cmd, argc, argv, one_vgname, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED) {
+	if ((ret = _get_arg_vgnames(cmd, argc, argv, one_vgname, use_vgnames, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED) {
 		ret_max = ret;
 		goto_out;
 	}
diff --git a/tools/toollib.h b/tools/toollib.h
index 2b3ca6e..a79c426 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -97,8 +97,11 @@ typedef int (*process_single_pvseg_fn_t) (struct cmd_context * cmd,
 					  struct pv_segment * pvseg,
 					  struct processing_handle *handle);
 
-int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    const char *one_vgname, uint32_t flags,
+int process_each_vg(struct cmd_context *cmd,
+	            int argc, char **argv,
+		    const char *one_vgname,
+		    struct dm_list *use_vgnames,
+		    uint32_t flags,
 		    struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg);
 
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 1b256c5..554317e 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -94,7 +94,7 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, NULL, READ_ALLOW_INCONSISTENT,
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_ALLOW_INCONSISTENT,
 			      handle, &vg_backup_single);
 
 	dm_free(last_filename);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 49c64b9..bbd9e1f 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1216,7 +1216,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, lockstart_ARG) || arg_is_set(cmd, lockstop_ARG))
 		flags |= READ_ALLOW_EXPORTED;
 
-	ret = process_each_vg(cmd, argc, argv, NULL, flags, NULL, &vgchange_single);
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, flags, NULL, &vgchange_single);
 
 	/* Wait for lock-start ops that were initiated in vgchange_lockstart. */
 
diff --git a/tools/vgck.c b/tools/vgck.c
index 15f7bc3..27a1d00 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -38,6 +38,6 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
 	lvmetad_make_unused(cmd);
-	return process_each_vg(cmd, argc, argv, NULL, 0, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, NULL, 0, NULL,
 			       &vgck_single);
 }
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 666b484..6ae675f 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -181,6 +181,6 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, NULL, READ_FOR_UPDATE, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, NULL,
 			       &vgconvert_single);
 }
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 85e5185..c805e68 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -89,7 +89,7 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 	}
 **********/
 
-	return process_each_vg(cmd, argc, argv, NULL, 0, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, NULL, 0, NULL,
 			       vgdisplay_single);
 
 /******** FIXME Need to count number processed
diff --git a/tools/vgexport.c b/tools/vgexport.c
index 8f5db9c..afe9a14 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -80,6 +80,6 @@ int vgexport(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, NULL, READ_FOR_UPDATE, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, NULL,
 			       &vgexport_single);
 }
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 9cfd3a7..24b51cf 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -197,7 +197,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &vp;
 
-	ret = process_each_vg(cmd, 0, NULL, vg_name,
+	ret = process_each_vg(cmd, 0, NULL, vg_name, NULL,
 			      READ_FOR_UPDATE, handle,
 			      restoremissing ? &_vgextend_restoremissing : &_vgextend_single);
 
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 5bcf7e0..c499f8b 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -107,7 +107,7 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	return process_each_vg(cmd, argc, argv, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, NULL,
 			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
 			       NULL,
 			       &vgimport_single);
diff --git a/tools/vgremove.c b/tools/vgremove.c
index f030a20..1d1a40f 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -109,7 +109,7 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 	cmd->lockd_gl_disable = 1;
 
 	cmd->handles_missing_pvs = 1;
-	ret = process_each_vg(cmd, argc, argv, NULL,
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL,
 			      READ_FOR_UPDATE,
 			      NULL, &vgremove_single);
 
diff --git a/tools/vgrename.c b/tools/vgrename.c
index e5af820..ee6a91f 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -244,7 +244,7 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &vp;
 
-	ret = process_each_vg(cmd, 0, NULL, vg_name_old,
+	ret = process_each_vg(cmd, 0, NULL, vg_name_old, NULL,
 			      READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
 			      handle, _vgrename_single);
 
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 59a0f6a..67797f5 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -117,7 +117,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 	else
 		log_print_unless_silent("Reading volume groups from cache.");
 
-	maxret = process_each_vg(cmd, argc, argv, NULL, 0, NULL,
+	maxret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, NULL,
 				 &vgscan_single);
 
 	if (arg_count(cmd, mknodes_ARG)) {



From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:01 +0000 (UTC)
Subject: master - toollib: make it possible to also process internal VGs, add 'include_internal' switch to process_each_vg fn
Message-ID: <20160620094101.11E5060FE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8cfc385491484e71d66e5991e09c3d0a47570a13
Commit:        8cfc385491484e71d66e5991e09c3d0a47570a13
Parent:        31aaa3be71597ec53262177bea76365605e9199f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 3 11:46:28 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

toollib: make it possible to also process internal VGs, add 'include_internal' switch to process_each_vg fn

The lvm fullreport works per VG and as such, the vg, lv, pv, seg and
pvseg subreport is done for each VG. However, if the PV is not part of
any VG yet, we still want to display pv and pvseg subreports for these
"orphan" PVs - so enable this for lvm fullreport's process_each_vg call.
---
 WHATS_NEW           |    1 +
 tools/lvcreate.c    |    2 +-
 tools/lvrename.c    |    2 +-
 tools/lvresize.c    |    2 +-
 tools/polldaemon.c  |    4 ++--
 tools/pvscan.c      |    2 +-
 tools/reporter.c    |   10 +++++-----
 tools/toollib.c     |    6 ++++--
 tools/toollib.h     |    1 +
 tools/vgcfgbackup.c |    2 +-
 tools/vgchange.c    |    2 +-
 tools/vgck.c        |    2 +-
 tools/vgconvert.c   |    2 +-
 tools/vgdisplay.c   |    2 +-
 tools/vgexport.c    |    2 +-
 tools/vgextend.c    |    2 +-
 tools/vgimport.c    |    2 +-
 tools/vgreduce.c    |    2 +-
 tools/vgremove.c    |    2 +-
 tools/vgrename.c    |    2 +-
 tools/vgscan.c      |    2 +-
 21 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 01d6bbc..edbc0f3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Make it possible to iterate over internal 'orphan' VGs in process_each_vg fn.
   Make -S|--select option groupable that allows this option to be repeated.
   Make -O|--sort option groupable that allows this option to be repeated.
   Add --configreport option to select report for which next options are applied.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index fb28dc5..88518d2 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1564,7 +1564,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &pp;
 
-	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, NULL, READ_FOR_UPDATE, handle,
+	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, NULL, READ_FOR_UPDATE, 0, handle,
 			      &_lvcreate_single);
 
 	_destroy_lvcreate_params(&lp);
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 4dfcda2..74248ee 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -217,7 +217,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &lp;
 
-	ret = process_each_vg(cmd, 0, NULL, vg_name, NULL, READ_FOR_UPDATE, handle,
+	ret = process_each_vg(cmd, 0, NULL, vg_name, NULL, READ_FOR_UPDATE, 0, handle,
 			      _lvrename_single);
 
 	destroy_processing_handle(cmd, handle);
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 05e386f..38ad98f 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -223,7 +223,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &lp;
 
-	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, NULL, READ_FOR_UPDATE, handle,
+	ret = process_each_vg(cmd, 0, NULL, lp.vg_name, NULL, READ_FOR_UPDATE, 0, handle,
 			      &_lvresize_single);
 
 	destroy_processing_handle(cmd, handle);
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index e12a694..2b64c4e 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -364,7 +364,7 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 
 	while (1) {
 		parms->outstanding_count = 0;
-		process_each_vg(cmd, 0, NULL, NULL, NULL, READ_FOR_UPDATE, handle, _poll_vg);
+		process_each_vg(cmd, 0, NULL, NULL, NULL, READ_FOR_UPDATE, 0, handle, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
 		if (parms->interval)
@@ -508,7 +508,7 @@ static void _lvmpolld_poll_for_all_vgs(struct cmd_context *cmd,
 
 	handle->custom_handle = &lpdp;
 
-	process_each_vg(cmd, 0, NULL, NULL, NULL, 0, handle, _lvmpolld_init_poll_vg);
+	process_each_vg(cmd, 0, NULL, NULL, NULL, 0, 0, handle, _lvmpolld_init_poll_vg);
 
 	first = dm_list_first(&lpdp.idls);
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index db678d1..a1f5ef3 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -287,7 +287,7 @@ static int _pvscan_autoactivate(struct cmd_context *cmd, struct pvscan_aa_params
 
 	dev_cache_full_scan(cmd->full_filter);
 
-	ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, 0, handle, _pvscan_autoactivate_single);
+	ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, 0, 0, handle, _pvscan_autoactivate_single);
 
 	destroy_processing_handle(cmd, handle);
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 1fcb338..0509c88 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1084,8 +1084,8 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 			if (args->full_report_vg)
 				r = _report_all_in_vg(cmd, handle, args->full_report_vg, VGS, lv_info_needed, lv_segment_status_needed);
 			else
-				r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL, 0,
-						    handle, &_vgs_single);
+				r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL,
+						    0, 0, handle, &_vgs_single);
 			break;
 		case LABEL:
 			r = process_each_label(cmd, args->argc, args->argv,
@@ -1101,7 +1101,7 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 							    handle, &_pvs_single);
 				else
 					r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL,
-							    0, handle, &_pvs_in_vg);
+							    0, 0, handle, &_pvs_in_vg);
 			}
 			break;
 		case SEGS:
@@ -1128,7 +1128,7 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 												 &_pvsegs_single);
 				else
 					r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL,
-							    0, handle, &_pvsegs_in_vg);
+							    0, 0, handle, &_pvsegs_in_vg);
 			}
 			break;
 		case FULL:
@@ -1367,7 +1367,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 
 	if (single_args->report_type == FULL) {
 		handle->custom_handle = &args;
-		r = process_each_vg(cmd, argc, argv, NULL, NULL, 0, handle, &_full_report_single);
+		r = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 1, handle, &_full_report_single);
 	} else
 		r = _do_report(cmd, handle, &args, single_args);
 
diff --git a/tools/toollib.c b/tools/toollib.c
index e67e47a..925157d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1875,7 +1875,8 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		skip = 0;
 		notfound = 0;
 
-		if (vg_uuid && !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
+		if (vg_uuid && !is_orphan_vg(vg_name) &&
+		    !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
 			stack;
 
 		log_very_verbose("Processing VG %s %s", vg_name, vg_uuid ? uuid : "");
@@ -2091,6 +2092,7 @@ int process_each_vg(struct cmd_context *cmd,
 		    const char *one_vgname,
 		    struct dm_list *use_vgnames,
 		    uint32_t read_flags,
+		    int include_internal,
 		    struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg)
 {
@@ -2158,7 +2160,7 @@ int process_each_vg(struct cmd_context *cmd,
 	 */
 	log_debug("Get list of VGs on system");
 
-	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0)) {
+	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, include_internal)) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
diff --git a/tools/toollib.h b/tools/toollib.h
index 8cd9087..179efe5 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -106,6 +106,7 @@ int process_each_vg(struct cmd_context *cmd,
 		    const char *one_vgname,
 		    struct dm_list *use_vgnames,
 		    uint32_t flags,
+		    int include_internal,
 		    struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg);
 
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index c47c1ef..34fe08f 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -94,7 +94,7 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_ALLOW_INCONSISTENT,
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_ALLOW_INCONSISTENT, 0,
 			      handle, &vg_backup_single);
 
 	dm_free(last_filename);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index bbd9e1f..4f6d847 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1216,7 +1216,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, lockstart_ARG) || arg_is_set(cmd, lockstop_ARG))
 		flags |= READ_ALLOW_EXPORTED;
 
-	ret = process_each_vg(cmd, argc, argv, NULL, NULL, flags, NULL, &vgchange_single);
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, flags, 0, NULL, &vgchange_single);
 
 	/* Wait for lock-start ops that were initiated in vgchange_lockstart. */
 
diff --git a/tools/vgck.c b/tools/vgck.c
index 27a1d00..54bc9d6 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -38,6 +38,6 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
 	lvmetad_make_unused(cmd);
-	return process_each_vg(cmd, argc, argv, NULL, NULL, 0, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL,
 			       &vgck_single);
 }
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 6ae675f..846db05 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -181,6 +181,6 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, 0, NULL,
 			       &vgconvert_single);
 }
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index c805e68..e9482df 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -89,7 +89,7 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 	}
 **********/
 
-	return process_each_vg(cmd, argc, argv, NULL, NULL, 0, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL,
 			       vgdisplay_single);
 
 /******** FIXME Need to count number processed
diff --git a/tools/vgexport.c b/tools/vgexport.c
index afe9a14..592e145 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -80,6 +80,6 @@ int vgexport(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, 0, NULL,
 			       &vgexport_single);
 }
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 8f44672..1c3743b 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -198,7 +198,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	handle->custom_handle = &vp;
 
 	ret = process_each_vg(cmd, 0, NULL, vg_name, NULL,
-			      READ_FOR_UPDATE, handle,
+			      READ_FOR_UPDATE, 0, handle,
 			      restoremissing ? &_vgextend_restoremissing : &_vgextend_single);
 
 	destroy_processing_handle(cmd, handle);
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 1f2e14d..07a889b 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -109,6 +109,6 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 
 	return process_each_vg(cmd, argc, argv, NULL, NULL,
 			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
-			       NULL,
+			       0, NULL,
 			       &vgimport_single);
 }
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index ae86a67..bae2b3e 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -247,7 +247,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 
 	process_each_vg(cmd, 0, NULL, vg_name, NULL,
 			READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
-			handle, &_vgreduce_repair_single);
+			0, handle, &_vgreduce_repair_single);
 
 	if (vp.already_consistent) {
 		log_print_unless_silent("Volume group \"%s\" is already consistent", vg_name);
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 1d1a40f..f0da2f8 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -110,7 +110,7 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->handles_missing_pvs = 1;
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL,
-			      READ_FOR_UPDATE,
+			      READ_FOR_UPDATE, 0,
 			      NULL, &vgremove_single);
 
 	return ret;
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 3dceeab..2006193 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -246,7 +246,7 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 
 	ret = process_each_vg(cmd, 0, NULL, vg_name_old, NULL,
 			      READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
-			      handle, _vgrename_single);
+			      0, handle, _vgrename_single);
 
 	/* Needed if process_each_vg returns error before calling _single. */
 	if (vp.unlock_new_name)
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 688e361..45a2d7e 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -117,7 +117,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 	else
 		log_print_unless_silent("Reading volume groups from cache.");
 
-	maxret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, NULL,
+	maxret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, NULL, 0,
 				 &vgscan_single);
 
 	if (arg_count(cmd, mknodes_ARG)) {



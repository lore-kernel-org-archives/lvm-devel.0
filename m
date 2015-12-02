From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  2 Dec 2015 00:08:22 +0000 (UTC)
Subject: master - vgextend: pass single vgname as process_each_vg arg
Message-ID: <20151202000822.4E78B60AC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea74215fa1f76cc965efd4f4656ad74321827161
Commit:        ea74215fa1f76cc965efd4f4656ad74321827161
Parent:        3bcdf5d14b930ba71c4dc5b03fcde0b19a5c8515
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 30 17:00:26 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 09:36:45 2015 -0600

vgextend: pass single vgname as process_each_vg arg

Pass the single vgname as a new process_each_vg arg
instead of setting a cmd flag to tell process_each_vg
to take only the first vgname arg from argv.

Other commands with different argv formats will be
able to use it this way.
---
 tools/commands.h    |    2 +-
 tools/polldaemon.c  |    4 ++--
 tools/reporter.c    |    6 +++---
 tools/toollib.c     |   31 ++++++++++++++++---------------
 tools/toollib.h     |    3 ++-
 tools/tools.h       |    2 --
 tools/vgcfgbackup.c |    2 +-
 tools/vgchange.c    |    2 +-
 tools/vgck.c        |    2 +-
 tools/vgconvert.c   |    2 +-
 tools/vgdisplay.c   |    2 +-
 tools/vgexport.c    |    2 +-
 tools/vgextend.c    |    5 ++++-
 tools/vgimport.c    |    2 +-
 tools/vgremove.c    |    2 +-
 tools/vgscan.c      |    2 +-
 16 files changed, 37 insertions(+), 34 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index b232a7d..5770bf3 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1214,7 +1214,7 @@ xx(vgexport,
 
 xx(vgextend,
    "Add physical volumes to a volume group",
-   ONE_VGNAME_ARG,
+   0,
    "vgextend\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--restoremissing]\n"
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index ccfaa7d..9172d71 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -364,7 +364,7 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 
 	while (1) {
 		parms->outstanding_count = 0;
-		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, handle, _poll_vg);
+		process_each_vg(cmd, 0, NULL, NULL, READ_FOR_UPDATE, handle, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
 		if (parms->interval)
@@ -508,7 +508,7 @@ static void _lvmpolld_poll_for_all_vgs(struct cmd_context *cmd,
 
 	handle->custom_handle = &lpdp;
 
-	process_each_vg(cmd, 0, NULL, 0, handle, _lvmpolld_init_poll_vg);
+	process_each_vg(cmd, 0, NULL, NULL, 0, handle, _lvmpolld_init_poll_vg);
 
 	first = dm_list_first(&lpdp.idls);
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 71f20a3..88025ec 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -884,7 +884,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 										 &_lvs_single);
 		break;
 	case VGS:
-		r = process_each_vg(cmd, argc, argv, 0,
+		r = process_each_vg(cmd, argc, argv, NULL, 0,
 				    &handle, &_vgs_single);
 		break;
 	case LABEL:
@@ -896,7 +896,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			r = process_each_pv(cmd, argc, argv, NULL, 0,
 					    &handle, &_pvs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, 0,
+			r = process_each_vg(cmd, argc, argv, NULL, 0,
 					    &handle, &_pvs_in_vg);
 		break;
 	case SEGSSTATUS:
@@ -917,7 +917,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 					    lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_info_and_status_single :
 											 &_pvsegs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, 0,
+			r = process_each_vg(cmd, argc, argv, NULL, 0,
 					    &handle, &_pvsegs_in_vg);
 		break;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index f979475..e49356f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1729,7 +1729,7 @@ int validate_restricted_lvname_param(struct cmd_context *cmd, const char **vg_na
  */
 static int _get_arg_vgnames(struct cmd_context *cmd,
 			    int argc, char **argv,
-			    unsigned one_vgname_arg,
+			    const char *one_vgname,
 			    struct dm_list *arg_vgnames,
 			    struct dm_list *arg_tags)
 {
@@ -1739,15 +1739,19 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 
 	log_verbose("Using volume group(s) on command line.");
 
+	if (one_vgname) {
+		if (!str_list_add(cmd->mem, arg_vgnames,
+				  dm_pool_strdup(cmd->mem, one_vgname))) {
+			log_error("strlist allocation failed.");
+			return ECMD_FAILED;
+		}
+		return ret_max;
+	}
+
 	for (; opt < argc; opt++) {
 		vg_name = argv[opt];
 
 		if (*vg_name == '@') {
-			if (one_vgname_arg) {
-				log_error("This command does not yet support a tag to identify a Volume Group.");
-				return EINVALID_CMD_LINE;
-			}
-
 			if (!validate_tag(vg_name + 1)) {
 				log_error("Skipping invalid tag: %s", vg_name);
 				if (ret_max < EINVALID_CMD_LINE)
@@ -1769,8 +1773,6 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 			log_error("Invalid volume group name %s.", vg_name);
 			if (ret_max < EINVALID_CMD_LINE)
 				ret_max = EINVALID_CMD_LINE;
-			if (one_vgname_arg)
-				break;
 			continue;
 		}
 
@@ -1779,9 +1781,6 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 			log_error("strlist allocation failed.");
 			return ECMD_FAILED;
 		}
-
-		if (one_vgname_arg)
-			break;
 	}
 
 	return ret_max;
@@ -1937,7 +1936,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		process_all = 1;
 
 	/*
-	 * FIXME If one_vgname_arg, only proceed if exactly one VG matches tags or selection.
+	 * FIXME If one_vgname, only proceed if exactly one VG matches tags or selection.
 	 */
 	dm_list_iterate_items(vgnl, vgnameids_to_process) {
 		if (sigint_caught())
@@ -2120,9 +2119,12 @@ static void _choose_vgs_to_process(struct cmd_context *cmd,
 
 /*
  * Call process_single_vg() for each VG selected by the command line arguments.
+ * If one_vgname is set, process only that VG and ignore argc/argv (which should be 0/NULL)..
+ * If one_vgname is not set, get VG names to process from argc/argv.
  */
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t read_flags, struct processing_handle *handle,
+		    const char *one_vgname, uint32_t read_flags,
+		    struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg)
 {
 	int handle_supplied = handle != NULL;
@@ -2131,7 +2133,6 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	struct dm_list vgnameids_on_system;	/* vgnameid_list */
 	struct dm_list vgnameids_to_process;	/* vgnameid_list */
 	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
-	int one_vgname_arg = (cmd->command->flags & ONE_VGNAME_ARG);
 	int process_all_vgs_on_system = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
@@ -2147,7 +2148,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	/*
 	 * Find any VGs or tags explicitly provided on the command line.
 	 */
-	if ((ret = _get_arg_vgnames(cmd, argc, argv, one_vgname_arg, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED) {
+	if ((ret = _get_arg_vgnames(cmd, argc, argv, one_vgname, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED) {
 		ret_max = ret;
 		goto_out;
 	}
diff --git a/tools/toollib.h b/tools/toollib.h
index 2dc5ad7..400bac5 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -97,7 +97,8 @@ typedef int (*process_single_pvseg_fn_t) (struct cmd_context * cmd,
 					  struct processing_handle *handle);
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t flags, struct processing_handle *handle,
+		    const char *one_vgname, uint32_t flags,
+		    struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg);
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
diff --git a/tools/tools.h b/tools/tools.h
index 4ed893f..27061fc 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -99,8 +99,6 @@ struct arg_value_group_list {
 #define ALL_VGS_IS_DEFAULT	0x00000004
 /* Process all devices with --all if none are specified on the command line. */
 #define ENABLE_ALL_DEVS		0x00000008	
-/* Exactly one VG name argument required. */
-#define ONE_VGNAME_ARG		0x00000010
 /* Command needs a shared lock on a VG; it only reads the VG. */
 #define LOCKD_VG_SH		0x00000020
 /* Command does not process any metadata. */
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 5e80c80..be4dbb0 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -94,7 +94,7 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, READ_ALLOW_INCONSISTENT,
+	ret = process_each_vg(cmd, argc, argv, NULL, READ_ALLOW_INCONSISTENT,
 			      handle, &vg_backup_single);
 
 	dm_free(last_filename);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 81e4bf3..9e1b09e 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1227,7 +1227,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, lockstart_ARG) || arg_is_set(cmd, lockstop_ARG))
 		flags |= READ_ALLOW_EXPORTED;
 
-	ret = process_each_vg(cmd, argc, argv, flags, NULL, &vgchange_single);
+	ret = process_each_vg(cmd, argc, argv, NULL, flags, NULL, &vgchange_single);
 
 	/* Wait for lock-start ops that were initiated in vgchange_lockstart. */
 
diff --git a/tools/vgck.c b/tools/vgck.c
index 1631289..b73544b 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -38,6 +38,6 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
 	lvmetad_set_active(cmd, 0);
-	return process_each_vg(cmd, argc, argv, 0, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, 0, NULL,
 			       &vgck_single);
 }
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index c4bb37a..9e6cb57 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -249,6 +249,6 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, READ_FOR_UPDATE, NULL,
 			       &vgconvert_single);
 }
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 1acb3ec..f232a83 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -89,7 +89,7 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 	}
 **********/
 
-	return process_each_vg(cmd, argc, argv, 0, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, 0, NULL,
 			       vgdisplay_single);
 
 /******** FIXME Need to count number processed
diff --git a/tools/vgexport.c b/tools/vgexport.c
index 566cc96..59ad123 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -80,6 +80,6 @@ int vgexport(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
+	return process_each_vg(cmd, argc, argv, NULL, READ_FOR_UPDATE, NULL,
 			       &vgexport_single);
 }
diff --git a/tools/vgextend.c b/tools/vgextend.c
index bddc22f..a747113 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -129,6 +129,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	struct vgextend_params vp;
 	unsigned restoremissing = arg_is_set(cmd, restoremissing_ARG);
 	struct processing_handle *handle;
+	const char *one_vgname;
 	int ret;
 
 	if (!argc) {
@@ -137,6 +138,8 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	one_vgname = skip_dev_dir(cmd, argv[0], NULL);
+
 	if (arg_count(cmd, metadatacopies_ARG)) {
 		log_error("Invalid option --metadatacopies, "
 			  "use --pvmetadatacopies instead.");
@@ -169,7 +172,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	if (!lockd_gl(cmd, "ex", 0))
 		return_ECMD_FAILED;
 
-	ret = process_each_vg(cmd, argc, argv,
+	ret = process_each_vg(cmd, 0, NULL, one_vgname,
 			      READ_FOR_UPDATE, handle,
 			      restoremissing ? &_vgextend_restoremissing : &_vgextend_single);
 
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 04a59dc..9e27ca3 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -98,7 +98,7 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv,
+	return process_each_vg(cmd, argc, argv, NULL,
 			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
 			       NULL,
 			       &vgimport_single);
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 219149e..3bf2b70 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -109,7 +109,7 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 	cmd->lockd_gl_disable = 1;
 
 	cmd->handles_missing_pvs = 1;
-	ret = process_each_vg(cmd, argc, argv,
+	ret = process_each_vg(cmd, argc, argv, NULL,
 			      READ_FOR_UPDATE,
 			      NULL, &vgremove_single);
 
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 7328a09..45841ec 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -62,7 +62,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 
 	log_print_unless_silent("Reading all physical volumes.  This may take a while...");
 
-	maxret = process_each_vg(cmd, argc, argv, 0, NULL,
+	maxret = process_each_vg(cmd, argc, argv, NULL, 0, NULL,
 				 &vgscan_single);
 
 	if (arg_count(cmd, mknodes_ARG)) {



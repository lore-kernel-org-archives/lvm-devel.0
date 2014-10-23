From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 23 Oct 2014 20:48:21 +0000 (UTC)
Subject: next - vgextend: use process_each_vg
Message-ID: <20141023204821.7496B610ED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=848dbe9644000792086b615b9fbb4d3848054437
Commit:        848dbe9644000792086b615b9fbb4d3848054437
Parent:        71ac7e22cdd6886f8121d098e3dc12b1aa3a0fc4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 22 15:32:49 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 23 15:47:25 2014 -0500

vgextend: use process_each_vg

---
 tools/pvcreate.c |    2 +-
 tools/toollib.c  |   27 ++++++---
 tools/toollib.h  |    4 +-
 tools/tools.h    |    2 +
 tools/vgcreate.c |    2 +-
 tools/vgextend.c |  178 ++++++++++++++++++++++++++++++------------------------
 6 files changed, 122 insertions(+), 93 deletions(-)

diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 958e353..1398198 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -101,7 +101,7 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (!pvcreate_restore_params_validate(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
-	if (!pvcreate_params_validate(cmd, argc, argv, &pp)) {
+	if (!pvcreate_params_validate(cmd, argc, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 99204c9..355bb04 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -861,11 +861,10 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
  * Output arguments:
  * pp: structure allocated by caller, fields written / validated here
  */
-int pvcreate_params_validate(struct cmd_context *cmd,
-			     int argc, char **argv,
+int pvcreate_params_validate(struct cmd_context *cmd, int pv_count,
 			     struct pvcreate_params *pp)
 {
-	if (!argc) {
+	if (!pv_count) {
 		log_error("Please enter a physical volume path");
 		return 0;
 	}
@@ -1354,6 +1353,7 @@ struct vgnameid_list {
  */
 static int _get_arg_vgnames(struct cmd_context *cmd,
 			    int argc, char **argv,
+			    int only_first_name,
 			    struct dm_list *arg_vgnames,
 			    struct dm_list *arg_tags)
 {
@@ -1365,7 +1365,8 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 
 	for (; opt < argc; opt++) {
 		vg_name = argv[opt];
-		if (*vg_name == '@') {
+
+		if (!only_first_name && (*vg_name == '@')) {
 			if (!validate_tag(vg_name + 1)) {
 				log_error("Skipping invalid tag: %s", vg_name);
 				if (ret_max < EINVALID_CMD_LINE)
@@ -1385,13 +1386,19 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 			log_error("Invalid volume group name: %s", vg_name);
 			if (ret_max < EINVALID_CMD_LINE)
 				ret_max = EINVALID_CMD_LINE;
+			if (only_first_name)
+				break;
 			continue;
 		}
+
 		if (!str_list_add(cmd->mem, arg_vgnames,
 				  dm_pool_strdup(cmd->mem, vg_name))) {
 			log_error("strlist allocation failed");
 			return ECMD_FAILED;
 		}
+
+		if (only_first_name)
+			break;
 	}
 
 	return ret_max;
@@ -1555,6 +1562,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	struct dm_list vgnameids_to_process;	/* vgnameid_list */
 
 	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
+	int only_first_name = (flags & ONLY_FIRST_NAME);
 	int ret;
 
 	dm_list_init(&arg_tags);
@@ -1565,7 +1573,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	/*
 	 * Find any VGs or tags explicitly provided on the command line.
 	 */
-	if ((ret = _get_arg_vgnames(cmd, argc, argv, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED) {
+	if ((ret = _get_arg_vgnames(cmd, argc, argv, only_first_name, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED) {
 		stack;
 		return ret;
 	}
@@ -1575,10 +1583,11 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	 *   any tags were supplied and need resolving; or
 	 *   no VG names were given and the command defaults to processing all VGs.
 	 */
-	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
-	    ((ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, NULL, 0)) != ECMD_PROCESSED)) {
-		stack;
-		return ret;
+	if ((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) {
+		if ((ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, NULL, 0)) != ECMD_PROCESSED) {
+			stack;
+			return ret;
+		}
 	}
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
diff --git a/tools/toollib.h b/tools/toollib.h
index 81d445b..d3d2140 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -103,8 +103,8 @@ int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
 void lv_spawn_background_polling(struct cmd_context *cmd,
 				 struct logical_volume *lv);
 int pvcreate_params_validate(struct cmd_context *cmd,
-			     int argc, char **argv,
-			     struct pvcreate_params *pp);
+                             int pv_count,
+                             struct pvcreate_params *pp);
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
 				   int *monitoring_mode);
diff --git a/tools/tools.h b/tools/tools.h
index 5fa1ab6..ffd8f0c 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -106,6 +106,8 @@ struct arg_value_group_list {
 #define ALL_VGS_IS_DEFAULT	0x00000004
 /* Process all devices with --all if none are specified on the command line. */
 #define ENABLE_ALL_DEVS		0x00000008	
+/* Use only the first free arg as the vg name. */
+#define ONLY_FIRST_NAME		0x00000010
  
 /* a register of the lvm commands */
 struct command {
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index b494148..5e03845 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -37,7 +37,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	argv++;
 
 	pvcreate_params_set_defaults(&pp);
-	if (!pvcreate_params_validate(cmd, argc, argv, &pp)) {
+	if (!pvcreate_params_validate(cmd, argc, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 2dc1699..29ffa7b 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -15,7 +15,13 @@
 
 #include "tools.h"
 
-static int _restore_pv(struct volume_group *vg, char *pv_name)
+struct pvcreate_params_args {
+	struct pvcreate_params pp;
+	int pv_count;
+	const char *const *pv_names;
+};
+
+static int _restore_pv(struct volume_group *vg, const char *pv_name)
 {
 	struct pv_list *pvl = NULL;
 	pvl = find_pv_in_vg(vg, pv_name);
@@ -38,13 +44,90 @@ static int _restore_pv(struct volume_group *vg, char *pv_name)
 	return 1;
 }
 
+static int vgextend_restore(struct cmd_context *cmd __attribute__((unused)), const char *vg_name,
+			    struct volume_group *vg, void *handle)
+{
+	struct pvcreate_params_args *ppa = handle;
+	int fixed = 0;
+	int i;
+
+	for (i = 0; i < ppa->pv_count; i++) {
+		if (_restore_pv(vg, ppa->pv_names[i]))
+			fixed++;
+	}
+
+	if (!fixed) {
+		log_error("No PV has been restored.");
+		return ECMD_FAILED;
+	}
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		return ECMD_FAILED;
+
+	backup(vg);
+
+	log_print_unless_silent("Volume group \"%s\" successfully extended", vg_name);
+
+	return ECMD_PROCESSED;
+}
+
+static int vgextend_single(struct cmd_context *cmd, const char *vg_name,
+			   struct volume_group *vg, void *handle)
+{
+	struct pvcreate_params_args *ppa = handle;
+	struct pvcreate_params *pp = &ppa->pp;
+	uint32_t mda_copies;
+	uint32_t mda_used;
+	int ret = ECMD_FAILED;
+
+	if (arg_count(cmd, metadataignore_ARG) &&
+	    (pp->force == PROMPT) && !pp->yes &&
+	    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
+	    (yes_no_prompt("Override preferred number of copies of VG %s metadata? [y/n]: ", vg_name) == 'n')) {
+		log_error("Volume group %s not changed", vg_name);
+		return ECMD_FAILED;
+	}
+
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for orphan PVs");
+		return ECMD_FAILED;
+	}
+
+	if (!vg_extend(vg, ppa->pv_count, ppa->pv_names, pp))
+		goto done;
+
+	if (arg_count(cmd, metadataignore_ARG)) {
+		mda_copies = vg_mda_copies(vg);
+		mda_used = vg_mda_used_count(vg);
+
+		if ((mda_copies != VGMETADATACOPIES_UNMANAGED) &&
+		    (mda_copies != mda_used)) {
+			log_warn("WARNING: Changing preferred number of copies of VG %s metadata from %"PRIu32" to %"PRIu32,
+				 vg_name, mda_copies, mda_used);
+			vg_set_mda_copies(vg, mda_used);
+		}
+
+	}
+
+	log_verbose("Volume group \"%s\" will be extended by %d new physical volumes", vg_name, ppa->pv_count);
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		goto done;
+
+	backup(vg);
+
+	log_print_unless_silent("Volume group \"%s\" successfully extended", vg_name);
+	ret = ECMD_PROCESSED;
+done:
+	unlock_vg(cmd, VG_ORPHANS);
+	return ret;
+
+}
+
 int vgextend(struct cmd_context *cmd, int argc, char **argv)
 {
-	const char *vg_name;
-	struct volume_group *vg = NULL;
-	int r = ECMD_FAILED;
-	struct pvcreate_params pp;
-	int fixed = 0, i = 0;
+	struct pvcreate_params_args ppa;
+	int restore = arg_is_set(cmd, restoremissing_ARG);
 
 	if (!argc) {
 		log_error("Please enter volume group name and "
@@ -52,19 +135,18 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	vg_name = skip_dev_dir(cmd, argv[0], NULL);
-	argc--;
-	argv++;
-
 	if (arg_count(cmd, metadatacopies_ARG)) {
 		log_error("Invalid option --metadatacopies, "
 			  "use --pvmetadatacopies instead.");
 		return EINVALID_CMD_LINE;
 	}
-	pvcreate_params_set_defaults(&pp);
-	if (!pvcreate_params_validate(cmd, argc, argv, &pp)) {
+
+	pvcreate_params_set_defaults(&ppa.pp);
+	ppa.pv_count = argc - 1;
+	ppa.pv_names = (const char* const*)(argv + 1);
+
+	if (!pvcreate_params_validate(cmd, ppa.pv_count, &ppa.pp))
 		return EINVALID_CMD_LINE;
-	}
 
 	/*
 	 * It is always ok to add new PVs to a VG - even if there are
@@ -74,71 +156,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	cmd->handles_missing_pvs = 1;
 
-	log_verbose("Checking for volume group \"%s\"", vg_name);
-	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-	if (vg_read_error(vg)) {
-		release_vg(vg);
-		return_ECMD_FAILED;
-	}
-
-	if (!archive(vg))
-		goto_bad;
-
-	if (arg_count(cmd, restoremissing_ARG)) {
-		for (i = 0; i < argc; ++i) {
-			if (_restore_pv(vg, argv[i]))
-				++ fixed;
-		}
-		if (!fixed) {
-			log_error("No PV has been restored.");
-			goto bad;
-		}
-	} else { /* no --restore, normal vgextend */
-		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-			log_error("Can't get lock for orphan PVs");
-			unlock_and_release_vg(cmd, vg, vg_name);
-			return ECMD_FAILED;
-		}
-
-		if (arg_count(cmd, metadataignore_ARG) &&
-		    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
-		    (pp.force == PROMPT) && !pp.yes &&
-		    yes_no_prompt("Override preferred number of copies "
-				  "of VG %s metadata? [y/n]: ",
-				  vg_name) == 'n') {
-			log_error("Volume group %s not changed", vg_name);
-			goto bad;
-		}
-
-		/* extend vg */
-		if (!vg_extend(vg, argc, (const char* const*)argv, &pp))
-			goto_bad;
-
-		if (arg_count(cmd, metadataignore_ARG) &&
-		    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
-		    (vg_mda_copies(vg) != vg_mda_used_count(vg))) {
-			log_warn("WARNING: Changing preferred number of copies of VG %s "
-			 "metadata from %"PRIu32" to %"PRIu32, vg_name,
-				 vg_mda_copies(vg), vg_mda_used_count(vg));
-			vg_set_mda_copies(vg, vg_mda_used_count(vg));
-		}
-
-		/* ret > 0 */
-		log_verbose("Volume group \"%s\" will be extended by %d new "
-			    "physical volumes", vg_name, argc);
-	}
-
-	/* store vg on disk(s) */
-	if (!vg_write(vg) || !vg_commit(vg))
-		goto_bad;
-
-	backup(vg);
-	log_print_unless_silent("Volume group \"%s\" successfully extended", vg_name);
-	r = ECMD_PROCESSED;
-
-bad:
-	if (!arg_count(cmd, restoremissing_ARG))
-		unlock_vg(cmd, VG_ORPHANS);
-	unlock_and_release_vg(cmd, vg, vg_name);
-	return r;
+	return process_each_vg(cmd, argc, argv,
+			       READ_FOR_UPDATE | ONLY_FIRST_NAME, &ppa,
+			       restore ? &vgextend_restore : &vgextend_single);
 }



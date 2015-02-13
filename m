From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 13 Feb 2015 15:01:12 +0000 (UTC)
Subject: master - vgextend: Use process_each_vg.
Message-ID: <20150213150112.41E686114E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5d06efbab4c7c77298b18b95c23111575a8db1a
Commit:        f5d06efbab4c7c77298b18b95c23111575a8db1a
Parent:        1ced5562cddb38b0eda1be1e1657b5eee2500f37
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 13 14:58:51 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Feb 13 14:58:51 2015 +0000

vgextend: Use process_each_vg.

Tags and --select are not yet supported because new code is needed
to ensure exactly one VG matches before the VG starts to be processed.
---
 WHATS_NEW        |    1 +
 lib/log/log.h    |    2 +
 tools/pvcreate.c |    2 +-
 tools/toollib.c  |   25 ++++++-
 tools/toollib.h  |    3 +-
 tools/tools.h    |    4 +-
 tools/vgcreate.c |    2 +-
 tools/vgextend.c |  189 +++++++++++++++++++++++++++++++----------------------
 8 files changed, 141 insertions(+), 87 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2c50c78..1aba0ac 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Update vgextend to use process_each_vg.
   Add --ignoreskippedcluster to pvchange.
   Allow pvchange to modify several properties at once.
   Update pvchange to use process_each_pv.
diff --git a/lib/log/log.h b/lib/log/log.h
index 99e7623..75a6220 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -109,6 +109,8 @@
 
 #define return_0	do { stack; return 0; } while (0)
 #define return_NULL	do { stack; return NULL; } while (0)
+#define return_EINVALID_CMD_LINE \
+			do { stack; return EINVALID_CMD_LINE; } while (0)
 #define return_ECMD_FAILED do { stack; return ECMD_FAILED; } while (0)
 #define goto_out	do { stack; goto out; } while (0)
 #define goto_bad	do { stack; goto bad; } while (0)
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
index 22fd9a6..df3f479 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -881,8 +881,7 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
  * Output arguments:
  * pp: structure allocated by caller, fields written / validated here
  */
-int pvcreate_params_validate(struct cmd_context *cmd,
-			     int argc, char **argv,
+int pvcreate_params_validate(struct cmd_context *cmd, int argc,
 			     struct pvcreate_params *pp)
 {
 	if (!argc) {
@@ -1468,6 +1467,7 @@ struct vgnameid_list {
  */
 static int _get_arg_vgnames(struct cmd_context *cmd,
 			    int argc, char **argv,
+			    unsigned one_vgname_arg,
 			    struct dm_list *arg_vgnames,
 			    struct dm_list *arg_tags)
 {
@@ -1479,18 +1479,26 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 
 	for (; opt < argc; opt++) {
 		vg_name = argv[opt];
+
 		if (*vg_name == '@') {
+			if (one_vgname_arg) {
+				log_error("This command does not yet support a tag to identify a Volume Group.");
+				return EINVALID_CMD_LINE;
+			}
+
 			if (!validate_tag(vg_name + 1)) {
 				log_error("Skipping invalid tag: %s", vg_name);
 				if (ret_max < EINVALID_CMD_LINE)
 					ret_max = EINVALID_CMD_LINE;
 				continue;
 			}
+
 			if (!str_list_add(cmd->mem, arg_tags,
 					  dm_pool_strdup(cmd->mem, vg_name + 1))) {
 				log_error("strlist allocation failed.");
 				return ECMD_FAILED;
 			}
+
 			continue;
 		}
 
@@ -1499,13 +1507,19 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 			log_error("Invalid volume group name %s.", vg_name);
 			if (ret_max < EINVALID_CMD_LINE)
 				ret_max = EINVALID_CMD_LINE;
+			if (one_vgname_arg)
+				break;
 			continue;
 		}
+
 		if (!str_list_add(cmd->mem, arg_vgnames,
 				  dm_pool_strdup(cmd->mem, vg_name))) {
 			log_error("strlist allocation failed.");
 			return ECMD_FAILED;
 		}
+
+		if (one_vgname_arg)
+			break;
 	}
 
 	return ret_max;
@@ -1718,6 +1732,9 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	if (dm_list_empty(arg_vgnames) && dm_list_empty(arg_tags))
 		process_all = 1;
 
+	/*
+	 * FIXME If one_vgname_arg, only proceed if exactly one VG matches tags or selection.
+	 */
 	dm_list_iterate_items(vgnl, vgnameids_to_process) {
 		if (sigint_caught())
 			return_ECMD_FAILED;
@@ -1805,6 +1822,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	struct dm_list vgnameids_to_process;	/* vgnameid_list */
 
 	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
+	unsigned one_vgname_arg = (flags & ONE_VGNAME_ARG);
 	int ret;
 
 	dm_list_init(&arg_tags);
@@ -1815,7 +1833,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	/*
 	 * Find any VGs or tags explicitly provided on the command line.
 	 */
-	if ((ret = _get_arg_vgnames(cmd, argc, argv, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED)
+	if ((ret = _get_arg_vgnames(cmd, argc, argv, one_vgname_arg, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED)
 		goto_out;
 
 	/*
@@ -1855,6 +1873,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 out:
 	if (!handle_supplied)
 		destroy_processing_handle(cmd, handle);
+
 	return ret;
 }
 
diff --git a/tools/toollib.h b/tools/toollib.h
index 7486d44..b9d4680 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -174,8 +174,7 @@ int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv);
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
 void lv_spawn_background_polling(struct cmd_context *cmd,
 				 struct logical_volume *lv);
-int pvcreate_params_validate(struct cmd_context *cmd,
-			     int argc, char **argv,
+int pvcreate_params_validate(struct cmd_context *cmd, int argc,
 			     struct pvcreate_params *pp);
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
diff --git a/tools/tools.h b/tools/tools.h
index 2196dba..109834a 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -102,10 +102,12 @@ struct arg_value_group_list {
 
 #define CACHE_VGMETADATA	0x00000001
 #define PERMITTED_READ_ONLY 	0x00000002
-/* Process all vgs if none specified on the command line. */
+/* Process all VGs if none specified on the command line. */
 #define ALL_VGS_IS_DEFAULT	0x00000004
 /* Process all devices with --all if none are specified on the command line. */
 #define ENABLE_ALL_DEVS		0x00000008	
+/* Exactly one VG name argument required. */
+#define ONE_VGNAME_ARG		0x00000010
  
 /* a register of the lvm commands */
 struct command {
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 01bf421..ed6c4d9 100644
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
index 2dc1699..de6d862 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -15,7 +15,13 @@
 
 #include "tools.h"
 
-static int _restore_pv(struct volume_group *vg, char *pv_name)
+struct vgextend_params {
+	struct pvcreate_params pp;
+	int pv_count;
+	const char *const *pv_names;
+};
+
+static int _restore_pv(struct volume_group *vg, const char *pv_name)
 {
 	struct pv_list *pvl = NULL;
 	pvl = find_pv_in_vg(vg, pv_name);
@@ -38,13 +44,92 @@ static int _restore_pv(struct volume_group *vg, char *pv_name)
 	return 1;
 }
 
+static int _vgextend_restoremissing(struct cmd_context *cmd __attribute__((unused)),
+				    const char *vg_name, struct volume_group *vg,
+				    struct processing_handle *handle)
+{
+	struct vgextend_params *vp = (struct vgextend_params *) handle->custom_handle;
+	int fixed = 0;
+	int i;
+
+	for (i = 0; i < vp->pv_count; i++)
+		if (_restore_pv(vg, vp->pv_names[i]))
+			fixed++;
+
+	if (!fixed) {
+		log_error("No PV has been restored.");
+		return ECMD_FAILED;
+	}
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_ECMD_FAILED;
+
+	backup(vg);
+
+	log_print_unless_silent("Volume group \"%s\" successfully extended", vg_name);
+
+	return ECMD_PROCESSED;
+}
+
+static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
+			    struct volume_group *vg, struct processing_handle *handle)
+{
+	struct vgextend_params *vp = (struct vgextend_params *) handle->custom_handle;
+	struct pvcreate_params *pp = &vp->pp;
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
+	if (!vg_extend(vg, vp->pv_count, vp->pv_names, pp))
+		goto_out;
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
+	}
+
+	log_verbose("Volume group \"%s\" will be extended by %d new physical volumes", vg_name, vp->pv_count);
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		goto_out;
+
+	backup(vg);
+
+	log_print_unless_silent("Volume group \"%s\" successfully extended", vg_name);
+	ret = ECMD_PROCESSED;
+
+out:
+	unlock_vg(cmd, VG_ORPHANS);
+
+	return ret;
+}
+
 int vgextend(struct cmd_context *cmd, int argc, char **argv)
 {
-	const char *vg_name;
-	struct volume_group *vg = NULL;
-	int r = ECMD_FAILED;
-	struct pvcreate_params pp;
-	int fixed = 0, i = 0;
+	struct vgextend_params vp;
+	unsigned restoremissing = arg_is_set(cmd, restoremissing_ARG);
+	struct processing_handle *handle;
+	int ret;
 
 	if (!argc) {
 		log_error("Please enter volume group name and "
@@ -52,19 +137,25 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
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
-		return EINVALID_CMD_LINE;
-	}
+
+	pvcreate_params_set_defaults(&vp.pp);
+	vp.pv_count = argc - 1;
+	vp.pv_names = (const char* const*)(argv + 1);
+
+	if (!pvcreate_params_validate(cmd, vp.pv_count, &vp.pp))
+		return_EINVALID_CMD_LINE;
+
+        if (!(handle = init_processing_handle(cmd))) {
+                log_error("Failed to initialize processing handle.");
+                return ECMD_FAILED;
+        }
+
+	handle->custom_handle = &vp;
 
 	/*
 	 * It is always ok to add new PVs to a VG - even if there are
@@ -74,71 +165,11 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
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
+	ret = process_each_vg(cmd, argc, argv,
+			      READ_FOR_UPDATE | ONE_VGNAME_ARG, handle,
+			      restoremissing ? &_vgextend_restoremissing : &_vgextend_single);
 
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
+	destroy_processing_handle(cmd, handle);
 
-bad:
-	if (!arg_count(cmd, restoremissing_ARG))
-		unlock_vg(cmd, VG_ORPHANS);
-	unlock_and_release_vg(cmd, vg, vg_name);
-	return r;
+	return ret;
 }



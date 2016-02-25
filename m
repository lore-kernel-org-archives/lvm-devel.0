From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:38 +0000 (UTC)
Subject: master - pvcreate: use the common toollib pv create
Message-ID: <20160225151538.1B5E861BB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a1c22aadf26bfa60782537968d1a03b535cd555
Commit:        6a1c22aadf26bfa60782537968d1a03b535cd555
Parent:        71671778ab0b2ae4f9f014b37372939b00e90e1d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 15 14:09:42 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

pvcreate: use the common toollib pv create

---
 tools/pvcreate.c |  143 ++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 92 insertions(+), 51 deletions(-)

diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 31657c7..47eb85c 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -22,13 +22,10 @@
  * Output arguments:
  * pp: structure allocated by caller, fields written / validated here
  */
-static int pvcreate_restore_params_validate(struct cmd_context *cmd,
-					    int argc, char **argv,
-					    struct pvcreate_params *pp)
+static int pvcreate_each_restore_params_from_args(struct cmd_context *cmd, int argc,
+					          struct pvcreate_each_params *pp)
 {
-	const char *uuid = NULL;
-	struct volume_group *vg;
-	struct pv_list *existing_pvl;
+	pp->restorefile = arg_str_value(cmd, restorefile_ARG, NULL);
 
 	if (arg_count(cmd, restorefile_ARG) && !arg_count(cmd, uuidstr_ARG)) {
 		log_error("--uuid is required with --restorefile");
@@ -48,35 +45,10 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
- 	if (arg_count(cmd, uuidstr_ARG)) {
-		uuid = arg_str_value(cmd, uuidstr_ARG, "");
-		if (!id_read_format(&pp->rp.id, uuid))
-			return 0;
-		pp->rp.idp = &pp->rp.id;
-		lvmcache_seed_infos_from_lvmetad(cmd); /* need to check for UUID dups */
-	}
-
-	if (arg_count(cmd, restorefile_ARG)) {
-		pp->rp.restorefile = arg_str_value(cmd, restorefile_ARG, "");
-		/* The uuid won't already exist */
-		if (!(vg = backup_read_vg(cmd, NULL, pp->rp.restorefile))) {
-			log_error("Unable to read volume group from %s",
-				  pp->rp.restorefile);
+	if (arg_count(cmd, uuidstr_ARG)) {
+		pp->uuid_str = arg_str_value(cmd, uuidstr_ARG, "");
+		if (!id_read_format(&pp->id, pp->uuid_str))
 			return 0;
-		}
-		if (!(existing_pvl = find_pv_in_vg_by_uuid(vg, pp->rp.idp))) {
-			release_vg(vg);
-			log_error("Can't find uuid %s in backup file %s",
-				  uuid, pp->rp.restorefile);
-			return 0;
-		}
-		pp->rp.ba_start = pv_ba_start(existing_pvl->pv);
-		pp->rp.ba_size = pv_ba_size(existing_pvl->pv);
-		pp->rp.pe_start = pv_pe_start(existing_pvl->pv);
-		pp->rp.extent_size = pv_pe_size(existing_pvl->pv);
-		pp->rp.extent_count = pv_pe_count(existing_pvl->pv);
-
-		release_vg(vg);
 	}
 
 	if (arg_sign_value(cmd, physicalvolumesize_ARG, SIGN_NONE) == SIGN_MINUS) {
@@ -90,34 +62,103 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 	return 1;
 }
 
+static int pvcreate_each_restore_params_from_backup(struct cmd_context *cmd,
+					            struct pvcreate_each_params *pp)
+{
+	struct volume_group *vg;
+	struct pv_list *existing_pvl;
+
+	/*
+	 * When restoring a PV, params need to be read from a backup file.
+	 */
+	if (!pp->restorefile)
+		return 1;
+
+	if (!(vg = backup_read_vg(cmd, NULL, pp->restorefile))) {
+		log_error("Unable to read volume group from %s", pp->restorefile);
+		return 0;
+	}
+
+	if (!(existing_pvl = find_pv_in_vg_by_uuid(vg, &pp->id))) {
+		release_vg(vg);
+		log_error("Can't find uuid %s in backup file %s",
+			  pp->uuid_str, pp->restorefile);
+		return 0;
+	}
+
+	pp->ba_start = pv_ba_start(existing_pvl->pv);
+	pp->ba_size = pv_ba_size(existing_pvl->pv);
+	pp->pe_start = pv_pe_start(existing_pvl->pv);
+	pp->extent_size = pv_pe_size(existing_pvl->pv);
+	pp->extent_count = pv_pe_count(existing_pvl->pv);
+
+	release_vg(vg);
+	return 1;
+}
+
 int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
-	int i;
-	int ret = ECMD_PROCESSED;
-	struct pvcreate_params pp;
+	struct processing_handle *handle;
+	struct pvcreate_each_params pp;
+	int ret;
 
-	/* Needed to change the set of orphan PVs. */
-	if (!lockd_gl(cmd, "ex", 0))
-		return_ECMD_FAILED;
+	if (!argc) {
+		log_error("Please enter a physical volume path.");
+		return 0;
+	}
 
-	pvcreate_params_set_defaults(&pp);
+	/*
+	 * Device info needs to be available for reading the VG backup file in
+	 * pvcreate_each_restore_params_from_backup.
+	 */
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
+	/*
+	 * Five kinds of pvcreate param values:
+	 * 1. defaults
+	 * 2. recovery-related command line args
+	 * 3. recovery-related args from backup file
+	 * 4. normal command line args
+	 *    (this also checks some settings from 2 & 3)
+	 * 5. argc/argv free args specifying devices
+	 */
+
+	pvcreate_each_params_set_defaults(&pp);
+
+	if (!pvcreate_each_restore_params_from_args(cmd, argc, &pp))
+		return EINVALID_CMD_LINE;
 
-	if (!pvcreate_restore_params_validate(cmd, argc, argv, &pp)) {
+	if (!pvcreate_each_restore_params_from_backup(cmd, &pp))
 		return EINVALID_CMD_LINE;
-	}
-	if (!pvcreate_params_validate(cmd, argc, &pp)) {
+
+	if (!pvcreate_each_params_from_args(cmd, &pp))
 		return EINVALID_CMD_LINE;
-	}
 
-	for (i = 0; i < argc; i++) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
+	pp.pv_count = argc;
+	pp.pv_names = argv;
 
-		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
+	/*
+	 * Needed to change the set of orphan PVs.
+	 * (disable afterward to prevent process_each_pv from doing
+	 * a shared global lock since it's already acquired it ex.)
+	 */
+	if (!lockd_gl(cmd, "ex", 0))
+		return_ECMD_FAILED;
+	cmd->lockd_gl_disable = 1;
+
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
 
-		if (!pvcreate_single(cmd, argv[i], &pp))
-			ret = ECMD_FAILED;
+	if (!pvcreate_each_device(cmd, handle, &pp))
+		ret = ECMD_FAILED;
+	else {
+		/* pvcreate_each_device returns with orphans locked */
+		unlock_vg(cmd, VG_ORPHANS);
+		ret = ECMD_PROCESSED;
 	}
 
+	destroy_processing_handle(cmd, handle);
 	return ret;
 }



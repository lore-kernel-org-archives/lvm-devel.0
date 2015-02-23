From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 23:29:07 +0000 (UTC)
Subject: master - systemid: Fix access restrictions.
Message-ID: <20150223232907.1060060C92@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b18feb98e50093d66f03ff63120b6a0f14d7fddd
Commit:        b18feb98e50093d66f03ff63120b6a0f14d7fddd
Parent:        df227be37cb113a1093b2ed092af582c5a900315
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 23:19:36 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 23:19:36 2015 +0000

systemid: Fix access restrictions.

When checking whether the system ID permits access to a VG, check for
each permitted situation first, and only then issue the appropriate
error message.  Always issue a message for now.  (We'll try to
suppress some of those later when the VG concerned wasn't explicitly
requested.)
Add more messages to try to ensure every return code is checked and
every error path (and only an error path) contains a log_error().
Add self-correction to vgchange -c to deal with situations where
the cluster state and system ID state are out-of-sync (e.g. if
old tools were used).
---
 lib/format_text/import_vsn1.c |    9 ++--
 lib/metadata/metadata.c       |   46 ++++++++++------------
 tools/toollib.c               |   49 +++++++++++------------
 tools/vgchange.c              |   85 +++++++++++++++++++++++++++--------------
 4 files changed, 106 insertions(+), 83 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index c6a0cf9..42ff451 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -737,6 +737,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
 	unsigned scan_done_once = use_cached_pvs;
+	char *system_id;
 
 	/* skip any top-level values */
 	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib)
@@ -750,8 +751,9 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	if (!(vg = alloc_vg("read_vg", fid->fmt->cmd, vgn->key)))
 		return_NULL;
 
-	if (!(vg->system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
+	if (!(system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
 		goto_bad;
+	vg->system_id = system_id;
 
 	/*
 	 * The pv hash memorises the pv section names -> pv
@@ -773,9 +775,8 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	vgn = vgn->child;
 
-	if (dm_config_get_str(vgn, "system_id", &str)) {
-		strncpy(vg->system_id, str, NAME_LEN);
-	}
+	if (dm_config_get_str(vgn, "system_id", &str))
+		strncpy(system_id, str, NAME_LEN);
 
 	if (!_read_id(&vg->id, vgn, "id")) {
 		log_error("Couldn't read uuid for volume group %s.", vg->name);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9fb289d..71197ba 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4338,7 +4338,7 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 	return (struct volume_group *)vg;
 }
 
-static int allow_system_id(struct cmd_context *cmd, const char *system_id)
+static int _allow_system_id(struct cmd_context *cmd, const char *system_id)
 {
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
@@ -4395,16 +4395,28 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 		return 1;
 
 	/*
-	 * We sometimes want to report foreign vgs.
+	 * A few commands allow read-only access to foreign VGs.
 	 */
 	if (cmd->include_foreign_vgs)
 		return 1;
 
 	/*
+	 * A host can access a VG with a matching system_id.
+	 */
+	if (cmd->system_id && !strcmp(vg->system_id, cmd->system_id))
+		return 1;
+
+	/*
+	 * A host can access a VG if the VG's system_id is in extra_system_ids list.
+	 */
+	if (cmd->system_id && _allow_system_id(cmd, vg->system_id))
+		return 1;
+
+	/*
 	 * Allow VG access if the local host has active LVs in it.
 	 */
 	if (lvs_in_vg_activated(vg)) {
-		log_error("LVs should not be active in VG %s with foreign system id \"%s\"",
+		log_warn("WARNING: Found LVs active in VG %s with foreign system ID \"%s\".  Possible data corruption.",
 			  vg->name, vg->system_id);
 		return 1;
 	}
@@ -4413,29 +4425,13 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	 * A host without a system_id cannot access a VG with a system_id.
 	 */
 	if (!cmd->system_id || cmd->unknown_system_id) {
-		log_warn("Cannot access VG %s with system id \"%s\" with unknown local system id.",
-			 vg->name, vg->system_id);
+		log_error("Cannot access VG %s with system id \"%s\" with unknown local system ID.",
+			  vg->name, vg->system_id);
 		return 0;
 	}
 
-	/*
-	 * A host can access a VG with a matching system_id.
-	 */
-	if (!strcmp(vg->system_id, cmd->system_id))
-		return 1;
-
-	/*
-	 * A host can access a VG if the VG's system_id is in the allow list.
-	 */
-	if (allow_system_id(cmd, vg->system_id))
-		return 1;
-
-	/*
-	 * Silently ignore foreign VGs.  They will only cause the
-	 * command to fail if they were named as explicit command
-	 * args, in which case the command will fail indicating the
-	 * VG was not found.
-	 */
+	log_error("Cannot access VG %s with system id \"%s\" with local system ID %s.",
+		  vg->name, vg->system_id, cmd->system_id);
 
 	return 0;
 }
@@ -4443,7 +4439,7 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 /*
  * FIXME: move _vg_bad_status_bits() checks in here.
  */
-static int _access_vg(struct cmd_context *cmd, struct volume_group *vg, uint32_t *failure)
+static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg, uint32_t *failure)
 {
 	if (!is_real_vg(vg->name)) {
 		/* Disallow use of LVM1 orphans when a host system ID is set. */
@@ -4526,7 +4522,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		goto bad;
 	}
 
-	if (!_access_vg(cmd, vg, &failure))
+	if (!_vg_access_permitted(cmd, vg, &failure))
 		goto bad;
 
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
diff --git a/tools/toollib.c b/tools/toollib.c
index 659eab5..b1795e7 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -200,12 +200,12 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 	 */
 	if (read_error & FAILED_SYSTEMID) {
 		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
-			log_error("Skipping volume group %s with system id %s",
-				  vg->name, vg->system_id);
+			log_error("Skipping volume group %s with system ID %s",
+				  vg->name, vg->system_id ? : vg->lvm1_system_id ? : "");
 			return 1;
 		} else {
 			read_error &= ~FAILED_SYSTEMID; /* Check for other errors */
-			log_verbose("Skipping volume group %s", vg_name);
+			log_verbose("Skipping foreign volume group %s", vg_name);
 			*skip = 1;
 		}
 	}
@@ -666,6 +666,7 @@ int vgcreate_params_set_defaults(struct cmd_context *cmd,
 {
 	int64_t extent_size;
 
+	/* Only vgsplit sets vg */
 	if (vg) {
 		vp_def->vg_name = NULL;
 		vp_def->extent_size = vg->extent_size;
@@ -674,7 +675,7 @@ int vgcreate_params_set_defaults(struct cmd_context *cmd,
 		vp_def->alloc = vg->alloc;
 		vp_def->clustered = vg_is_clustered(vg);
 		vp_def->vgmetadatacopies = vg->mda_copies;
-		vp_def->system_id = vg->system_id ? dm_pool_strdup(cmd->mem, vg->system_id) : NULL;
+		vp_def->system_id = vg->system_id;	/* No need to clone this */
 	} else {
 		vp_def->vg_name = NULL;
 		extent_size = find_config_tree_int64(cmd,
@@ -689,7 +690,7 @@ int vgcreate_params_set_defaults(struct cmd_context *cmd,
 		vp_def->alloc = DEFAULT_ALLOC_POLICY;
 		vp_def->clustered = DEFAULT_CLUSTERED;
 		vp_def->vgmetadatacopies = DEFAULT_VGMETADATACOPIES;
-		vp_def->system_id = cmd->system_id ? dm_pool_strdup(cmd->mem, cmd->system_id) : NULL;
+		vp_def->system_id = cmd->system_id;
 	}
 
 	return 1;
@@ -705,7 +706,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 				  struct vgcreate_params *vp_new,
 				  struct vgcreate_params *vp_def)
 {
-	const char *arg_str;
+	const char *system_id_arg_str;
 
 	vp_new->vg_name = skip_dev_dir(cmd, vp_def->vg_name, NULL);
 	vp_new->max_lv = arg_uint_value(cmd, maxlogicalvolumes_ARG,
@@ -745,37 +746,35 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, metadatacopies_ARG)) {
+	if (arg_count(cmd, metadatacopies_ARG))
 		vp_new->vgmetadatacopies = arg_int_value(cmd, metadatacopies_ARG,
 							DEFAULT_VGMETADATACOPIES);
-	} else if (arg_count(cmd, vgmetadatacopies_ARG)) {
+	else if (arg_count(cmd, vgmetadatacopies_ARG))
 		vp_new->vgmetadatacopies = arg_int_value(cmd, vgmetadatacopies_ARG,
 							DEFAULT_VGMETADATACOPIES);
-	} else {
+	else
 		vp_new->vgmetadatacopies = find_config_tree_int(cmd, metadata_vgmetadatacopies_CFG, NULL);
-	}
 
-	if ((arg_str = arg_str_value(cmd, systemid_ARG, NULL))) {
-		vp_new->system_id = system_id_from_string(cmd, arg_str);
-	} else {
+	/* A clustered VG has no system ID. */
+	if (vp_new->clustered) {
+		if (arg_is_set(cmd, systemid_ARG)) {
+			log_error("System ID cannot be set on clustered Volume Groups.");
+			return 0;
+		}
+		vp_new->system_id = NULL;
+	} else if (!(system_id_arg_str = arg_str_value(cmd, systemid_ARG, NULL)))
 		vp_new->system_id = vp_def->system_id;
-	}
-
-	if (arg_str) {
-		if (!vp_new->system_id)
-			log_warn("No local system id found, VG will not have a system id.");
+	else {
+		if (!(vp_new->system_id = system_id_from_string(cmd, system_id_arg_str)))
+			return_0;
 
+		/* FIXME Take local/extra_system_ids into account */
 		if (vp_new->system_id && cmd->system_id &&
-		    strcmp(vp_new->system_id, cmd->system_id)) {
-			log_warn("VG system id \"%s\" will not be accessible to local system id \"%s\"",
+		    strcmp(vp_new->system_id, cmd->system_id))
+			log_warn("VG with system ID \"%s\" might become inaccessible as local system ID is \"%s\"",
 				 vp_new->system_id, cmd->system_id);
-		}
 	}
 
-	/* A clustered vg has no system_id. */
-	if (vp_new->clustered)
-		vp_new->system_id = NULL;
-
 	return 1;
 }
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 19aeee7..0b78230 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -301,41 +301,47 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 {
 	int clustered = arg_int_value(cmd, clustered_ARG, 0);
 
-	if (clustered && (vg_is_clustered(vg))) {
-		log_error("Volume group \"%s\" is already clustered",
-			  vg->name);
-		return 0;
+	if (clustered && vg_is_clustered(vg)) {
+		if (vg->system_id && *vg->system_id)
+			log_warn("WARNING: Clearing invalid system ID %s from volume group %s.",
+				 vg->system_id, vg->name);
+		else {
+			log_error("Volume group \"%s\" is already clustered", vg->name);
+			return 0;
+		}
 	}
 
-	if (!clustered && !(vg_is_clustered(vg))) {
-		log_error("Volume group \"%s\" is already not clustered",
-			  vg->name);
-		return 0;
+	if (!clustered && !vg_is_clustered(vg)) {
+		if ((!vg->system_id || !*vg->system_id) && cmd->system_id && *cmd->system_id)
+			log_warn("Setting missing system ID on Volume Group %s to %s.",
+				 vg->name, cmd->system_id);
+		else {
+			log_error("Volume group \"%s\" is already not clustered",
+				  vg->name);
+			return 0;
+		}
 	}
 
 	if (clustered && !arg_count(cmd, yes_ARG)) {
 		if (!clvmd_is_running()) {
-			if (yes_no_prompt("LVM cluster daemon (clvmd) is not"
-					  " running.\n"
-					  "Make volume group \"%s\" clustered"
-					  " anyway? [y/n]: ", vg->name) == 'n') {
+			if (yes_no_prompt("LVM cluster daemon (clvmd) is not running. "
+					  "Make volume group \"%s\" clustered "
+					  "anyway? [y/n]: ", vg->name) == 'n') {
 				log_error("No volume groups changed.");
 				return 0;
 			}
 
 		} else if (!locking_is_clustered() &&
-			   (yes_no_prompt("LVM locking type is not clustered.\n"
-					  "Make volume group \"%s\" clustered"
-					  " anyway? [y/n]: ", vg->name) == 'n')) {
+			   (yes_no_prompt("LVM locking type is not clustered. "
+					  "Make volume group \"%s\" clustered "
+					  "anyway? [y/n]: ", vg->name) == 'n')) {
 			log_error("No volume groups changed.");
 			return 0;
 		}
 	}
 
-	if (clustered)
-		vg->system_id = NULL;
-	else if (cmd->system_id && cmd->system_id[0])
-		vg->system_id = dm_pool_strdup(cmd->mem, cmd->system_id);
+	if (!vg_set_system_id(vg, clustered ? NULL : cmd->system_id))
+		return_0;
 
 	if (!vg_set_clustered(vg, clustered))
 		return_0;
@@ -483,28 +489,49 @@ static int _vgchange_profile(struct cmd_context *cmd,
  * extra_system_ids list.  This function is not allowed to change the system_id
  * of a foreign VG (VG owned by another host).
  */
-
 static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 {
-	const char *arg_str = arg_str_value(cmd, systemid_ARG, NULL);
-	char *system_id;
+	const char *system_id;
+	const char *system_id_arg_str = arg_str_value(cmd, systemid_ARG, NULL);
 
-	if (!arg_str)
+	if (!system_id_arg_str || !*system_id_arg_str) {
+		log_error("Invalid system ID supplied: %s", system_id_arg_str);
 		return 0;
+	}
+
+	if (!(system_id = system_id_from_string(cmd, system_id_arg_str)))
+		return_0;
+
+	if (!strcmp(vg->system_id, system_id)) {
+		log_error("Volume Group system ID is already \"%s\"", vg->system_id);
+		return 0;
+	}
 
-	system_id = system_id_from_string(cmd, arg_str);
+	if (cmd->system_id && strcmp(system_id, cmd->system_id)) {
+		if (lvs_in_vg_activated(vg)) {
+			log_error("Logical Volumes in VG %s must be deactivated before system ID can be changed.",
+				  vg->name);
+			return 0;
+		}
 
-	if (system_id && cmd->system_id && strcmp(system_id, cmd->system_id)) {
-		log_warn("VG \"%s\" system id \"%s\" does not match local system id \"%s\"",
-			 vg->name, system_id, cmd->system_id);
+		log_warn("WARNING: Requested system ID \"%s\" does not match local system ID \"%s\"",
+			 system_id, cmd->system_id);
+		log_warn("WARNING: Volume group %s might become inaccessible from this machine.",
+			 vg->name);
 
-		if (yes_no_prompt("Change system id? [y/n]: ") == 'n') {
-			log_error("Volume group \"%s\" not changed.", vg->name);
+		if (!arg_count(cmd, yes_ARG) &&
+		    yes_no_prompt("Set foreign system ID %s on volume group %s? [y/n]: ",
+				  system_id, vg->name) == 'n') {
+			log_error("Volume group \"%s\" system ID not changed.", vg->name);
 			return 0;
 		}
 	}
 
+	log_verbose("Changing system ID for VG %s: %s -> %s.",
+		    vg->name, vg->system_id, system_id);
+
 	vg->system_id = system_id;
+
 	return 1;
 }
 



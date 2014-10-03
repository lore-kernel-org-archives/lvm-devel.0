From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  3 Oct 2014 19:51:22 +0000 (UTC)
Subject: master - toollib: Rewrite process_each_vg.
Message-ID: <20141003195122.A874F6061D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bfb6a4ecc6ad7bb06649ffd026d9c997443dd684
Commit:        bfb6a4ecc6ad7bb06649ffd026d9c997443dd684
Parent:        91198ac13e61c66b65884660410311ffc8b8c24e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 3 20:47:19 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 3 20:47:19 2014 +0100

toollib: Rewrite process_each_vg.

Split VG argument collection from processing.
This allows the two different loops through VGs to
be replaced by a single loop.
Replace unused struct cmd_vg and cmd_vg_read() replicator
code with struct vg and vg_read() directly.

[Committed by agk with cosmetic changes and tweaks.]
---
 WHATS_NEW       |    1 +
 tools/toollib.c |  391 ++++++++++++++++++++++++++++++++++---------------------
 2 files changed, 246 insertions(+), 146 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a94edc6..ad7bafb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Refactor process_each_vg in toollib.
   Pools cannot be used as external origin.
   Use lv_update_and_reload() for snapshot reload.
   Don't print message in adjusted_mirror_region_size() in activation.
diff --git a/tools/toollib.c b/tools/toollib.c
index c5395ba..8049b1f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -169,7 +169,9 @@ int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsiste
 	if ((read_error == FAILED_INCONSISTENT) && allow_inconsistent)
 		return 0;
 
-	if (read_error == FAILED_CLUSTERED && vg->cmd->ignore_clustered_vgs)
+	if (read_error == FAILED_NOTFOUND)
+		*ret = ECMD_FAILED;
+	else if (read_error == FAILED_CLUSTERED && vg->cmd->ignore_clustered_vgs)
 		log_verbose("Skipping volume group %s", vg_name);
 	else {
 		log_error("Skipping volume group %s", vg_name);
@@ -566,151 +568,6 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 	return ret_max;
 }
 
-static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
-			   const char *vgid,
-			   struct dm_list *tagsl, struct dm_list *arg_vgnames,
-			   uint32_t flags, void *handle, int ret_max,
-			   process_single_vg_fn_t process_single_vg)
-{
-	struct dm_list cmd_vgs;
-	struct cmd_vg *cvl_vg;
-	int ret = ECMD_PROCESSED;
-
-	log_verbose("Finding volume group \"%s\"", vg_name);
-
-	dm_list_init(&cmd_vgs);
-	if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs, vg_name, vgid, flags)))
-		return_ECMD_FAILED;
-
-	for (;;) {
-		if (sigint_caught()) {
-			ret = ECMD_FAILED;
-			stack;
-			break;
-		}
-
-		if (!cmd_vg_read(cmd, &cmd_vgs)) {
-			/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
-			if (ignore_vg(cvl_vg->vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &ret)) {
-				stack;
-				break;
-			}
-		}
-
-		if (!dm_list_empty(tagsl) &&
-		    /* Only process if a tag matches or it's on arg_vgnames */
-		    !str_list_match_item(arg_vgnames, vg_name) &&
-		    !str_list_match_list(tagsl, &cvl_vg->vg->tags, NULL))
-			break;
-
-		ret = process_single_vg(cmd, vg_name, cvl_vg->vg, handle);
-
-		if (vg_read_error(cvl_vg->vg)) /* FAILED_INCONSISTENT */
-			break;
-
-		if (!cvl_vg->vg->cmd_missing_vgs)
-			break;
-
-		free_cmd_vgs(&cmd_vgs);
-	}
-
-	free_cmd_vgs(&cmd_vgs);
-
-	return (ret > ret_max) ? ret : ret_max;
-}
-
-int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t flags, void *handle,
-		    process_single_vg_fn_t process_single_vg)
-{
-	int opt = 0;
-	int ret_max = ECMD_PROCESSED;
-
-	struct dm_str_list *sl;
-	struct dm_list *vgnames, *vgids;
-	struct dm_list arg_vgnames, tagsl;
-
-	const char *vg_name, *vgid;
-
-	dm_list_init(&tagsl);
-	dm_list_init(&arg_vgnames);
-
-	if (argc) {
-		log_verbose("Using volume group(s) on command line");
-
-		for (; opt < argc; opt++) {
-			vg_name = argv[opt];
-			if (*vg_name == '@') {
-				if (!validate_tag(vg_name + 1)) {
-					log_error("Skipping invalid tag %s",
-						  vg_name);
-					if (ret_max < EINVALID_CMD_LINE)
-						ret_max = EINVALID_CMD_LINE;
-					continue;
-				}
-				if (!str_list_add(cmd->mem, &tagsl,
-						  dm_pool_strdup(cmd->mem,
-							      vg_name + 1))) {
-					log_error("strlist allocation failed");
-					return ECMD_FAILED;
-				}
-				continue;
-			}
-
-			vg_name = skip_dev_dir(cmd, vg_name, NULL);
-			if (strchr(vg_name, '/')) {
-				log_error("Invalid volume group name: %s",
-					  vg_name);
-				if (ret_max < EINVALID_CMD_LINE)
-					ret_max = EINVALID_CMD_LINE;
-				continue;
-			}
-			if (!str_list_add(cmd->mem, &arg_vgnames,
-					  dm_pool_strdup(cmd->mem, vg_name))) {
-				log_error("strlist allocation failed");
-				return ECMD_FAILED;
-			}
-		}
-
-		vgnames = &arg_vgnames;
-	}
-
-	if (!argc || !dm_list_empty(&tagsl)) {
-		log_verbose("Finding all volume groups");
-		if (!lvmetad_vg_list_to_lvmcache(cmd))
-			stack;
-		if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
-			log_error("No volume groups found");
-			return ret_max;
-		}
-		dm_list_iterate_items(sl, vgids) {
-			if (sigint_caught())
-				return_ECMD_FAILED;
-			vgid = sl->str;
-			if (!vgid || !(vg_name = lvmcache_vgname_from_vgid(cmd->mem, vgid)))
-				continue;
-			ret_max = _process_one_vg(cmd, vg_name, vgid, &tagsl,
-						  &arg_vgnames,
-						  flags, handle,
-					  	  ret_max, process_single_vg);
-		}
-	} else {
-		dm_list_iterate_items(sl, vgnames) {
-			if (sigint_caught())
-				return_ECMD_FAILED;
-			vg_name = sl->str;
-			if (is_orphan_vg(vg_name))
-				continue;	/* FIXME Unnecessary? */
-			ret_max = _process_one_vg(cmd, vg_name, NULL, &tagsl,
-						  &arg_vgnames,
-						  flags, handle,
-					  	  ret_max, process_single_vg);
-		}
-	}
-
-	return ret_max;
-}
-
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  const struct dm_list *tagsl, void *handle,
 			  process_single_pv_fn_t process_single_pv)
@@ -1986,3 +1843,245 @@ int validate_lvname_param(struct cmd_context *cmd, const char **vg_name,
 
 	return 1;
 }
+
+struct vgnameid_list {
+	struct dm_list list;
+	const char *vg_name;
+	const char *vgid;
+};
+
+/*
+ * Extract list of VG names and list of tags from command line arguments.
+ */
+static int _get_arg_vgnames(struct cmd_context *cmd,
+			    int argc, char **argv,
+			    struct dm_list *arg_vgnames,
+			    struct dm_list *arg_tags)
+{
+	int opt = 0;
+	int ret_max = ECMD_PROCESSED;
+	const char *vg_name;
+
+	log_verbose("Using volume group(s) on command line");
+
+	for (; opt < argc; opt++) {
+		vg_name = argv[opt];
+		if (*vg_name == '@') {
+			if (!validate_tag(vg_name + 1)) {
+				log_error("Skipping invalid tag: %s", vg_name);
+				if (ret_max < EINVALID_CMD_LINE)
+					ret_max = EINVALID_CMD_LINE;
+				continue;
+			}
+			if (!str_list_add(cmd->mem, arg_tags,
+					  dm_pool_strdup(cmd->mem, vg_name + 1))) {
+				log_error("strlist allocation failed");
+				return ECMD_FAILED;
+			}
+			continue;
+		}
+
+		vg_name = skip_dev_dir(cmd, vg_name, NULL);
+		if (strchr(vg_name, '/')) {
+			log_error("Invalid volume group name: %s", vg_name);
+			if (ret_max < EINVALID_CMD_LINE)
+				ret_max = EINVALID_CMD_LINE;
+			continue;
+		}
+		if (!str_list_add(cmd->mem, arg_vgnames,
+				  dm_pool_strdup(cmd->mem, vg_name))) {
+			log_error("strlist allocation failed");
+			return ECMD_FAILED;
+		}
+	}
+
+	return ret_max;
+}
+
+/*
+ * FIXME Add arg to include (or not) entries with duplicate vg names?
+ *
+ * Obtain complete list of VG name/vgid pairs known on the system.
+ */
+static int _get_vgnameids_on_system(struct cmd_context *cmd,
+				    struct dm_list *vgnameids_on_system)
+{
+	struct vgnameid_list *vgnl;
+	struct dm_list *vgids;
+	struct dm_str_list *sl;
+	const char *vgid;
+
+	log_verbose("Finding all volume groups");
+
+	if (!lvmetad_vg_list_to_lvmcache(cmd))
+		stack;
+
+	/*
+	 * Start with complete vgid list because multiple VGs might have same name.
+	 */
+	vgids = get_vgids(cmd, 0);
+	if (!vgids || dm_list_empty(vgids)) {
+		stack;
+		return ECMD_PROCESSED;
+	}
+
+	/* FIXME get_vgids() should provide these pairings directly */
+	dm_list_iterate_items(sl, vgids) {
+		if (!(vgid = sl->str))
+			continue;
+
+		if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
+			log_error("vgnameid_list allocation failed");
+			return ECMD_FAILED;
+		}
+
+		vgnl->vgid = dm_pool_strdup(cmd->mem, vgid);
+		vgnl->vg_name = lvmcache_vgname_from_vgid(cmd->mem, vgid);
+
+		dm_list_add(vgnameids_on_system, &vgnl->list);
+	}
+
+	return ECMD_PROCESSED;
+}
+
+static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
+				  struct dm_list *vgnameids_to_process,
+				  struct dm_list *arg_vgnames,
+				  struct dm_list *arg_tags, void *handle,
+				  process_single_vg_fn_t process_single_vg)
+{
+	struct volume_group *vg;
+	struct vgnameid_list *vgnl;
+	const char *vg_name;
+	const char *vg_uuid;
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+	int process_all = 0;
+
+	/*
+	 * If no VG names or tags were supplied, then process all VGs.
+	 */
+	if (dm_list_empty(arg_vgnames) && dm_list_empty(arg_tags))
+		process_all = 1;
+
+	dm_list_iterate_items(vgnl, vgnameids_to_process) {
+		vg_name = vgnl->vg_name;
+		vg_uuid = vgnl->vgid;
+		ret = 0;
+
+		vg = vg_read(cmd, vg_name, vg_uuid, flags);
+		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &ret)) {
+			if (ret > ret_max)
+				ret_max = ret;
+			release_vg(vg);
+			stack;
+			continue;
+		}
+
+		/* Process this VG? */
+		if (process_all ||
+		    (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
+		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL)))
+			ret = process_single_vg(cmd, vg_name, vg, handle);
+
+		if (vg_read_error(vg))
+			release_vg(vg);
+		else
+			unlock_and_release_vg(cmd, vg, vg_name);
+
+		if (ret > ret_max)
+			ret_max = ret;
+		if (sigint_caught())
+			break;
+	}
+
+	return ret_max;
+}
+
+/*
+ * Copy the contents of a str_list of VG names to a name list, filling
+ * in the vgid with NULL (unknown).
+ */
+static int _copy_str_to_name_list(struct cmd_context *cmd, struct dm_list *sll,
+				  struct dm_list *vgnll)
+{
+	const char *vgname;
+	struct dm_str_list *sl;
+	struct vgnameid_list *vgnl;
+
+	dm_list_iterate_items(sl, sll) {
+		vgname = sl->str;
+
+		vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl));
+		if (!vgnl) {
+			log_error("vgnameid_list allocation failed");
+			return ECMD_FAILED;
+		}
+
+		vgnl->vgid = NULL;
+		vgnl->vg_name = dm_pool_strdup(cmd->mem, vgname);
+
+		dm_list_add(vgnll, &vgnl->list);
+	}
+
+	return ECMD_PROCESSED;
+}
+
+/*
+ * Call process_single_vg() for each VG selected by the command line arguments.
+ */
+int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
+		    uint32_t flags, void *handle,
+		    process_single_vg_fn_t process_single_vg)
+{
+	struct dm_list arg_tags;		/* str_list */
+	struct dm_list arg_vgnames;		/* str_list */
+	struct dm_list vgnameids_on_system;	/* vgnameid_list */
+	struct dm_list vgnameids_to_process;	/* vgnameid_list */
+
+	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
+	int ret;
+
+	dm_list_init(&arg_tags);
+	dm_list_init(&arg_vgnames);
+	dm_list_init(&vgnameids_on_system);
+	dm_list_init(&vgnameids_to_process);
+
+	/*
+	 * Find any VGs or tags explicitly provided on the command line.
+	 */
+	if ((ret = _get_arg_vgnames(cmd, argc, argv, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED) {
+		stack;
+		return ret;
+	}
+
+	/*
+	 * Obtain the complete list of VGs present on the system if it is needed because:
+	 *   any tags were supplied and need resolving; or
+	 *   no VG names were given and the command defaults to processing all VGs.
+	 */
+	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
+	    ((ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system)) != ECMD_PROCESSED)) {
+		stack;
+		return ret;
+	}
+
+	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
+		log_error("No volume groups found");
+		return ECMD_PROCESSED;
+	}
+
+	/*
+	 * If we obtained a full list of VGs on the system, we need to work through them all;
+	 * otherwise we can merely work through the VG names provided.
+	 */
+	if (!dm_list_empty(&vgnameids_on_system))
+		dm_list_splice(&vgnameids_to_process, &vgnameids_on_system);
+	else if ((ret = _copy_str_to_name_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED) {
+		stack;
+		return ret;
+	}
+
+	return _process_vgnameid_list(cmd, flags, &vgnameids_to_process,
+				      &arg_vgnames, &arg_tags, handle, process_single_vg);
+}



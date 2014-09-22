From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:52 +0000 (UTC)
Subject: dev-dct-process-latest - toollib: rewrite process_each_vg
Message-ID: <20140922153952.E387B60228@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e500a07ef25302969d37785a9e99fe2be678f42b
Commit:        e500a07ef25302969d37785a9e99fe2be678f42b
Parent:        35fb6744e08b67463b9d48d3e7e140c78f44d0c9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 17 13:19:15 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:23 2014 -0500

toollib: rewrite process_each_vg

- Split the collecting of arguments from processing them.
- The split allows the two different loops through vgs to
  be replaced by a single loop.
- Replace unused struct cmd_vg and cmd_vg_read() replicator
  code with struct vg and vg_read() directly.
---
 tools/toollib.c |  378 ++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 233 insertions(+), 145 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 03d83e5..0a44eaa 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -561,151 +561,6 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
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
@@ -1893,3 +1748,236 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
 
 	return ret_max;
 }
+
+struct name_id_list {
+	struct dm_list list;
+	const char *name;
+	const char *uuid;
+};
+
+static int get_arg_vgnames(struct cmd_context *cmd,
+			   int argc, char **argv,
+			   struct dm_list *arg_vgnames,
+			   struct dm_list *arg_tags)
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
+				log_error("Skipping invalid tag %s", vg_name);
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
+ * This needs to start with the vgid list because there may be multiple vgs
+ * with the same name and all need to be included.
+ *
+ * (An arg could be added to this function to include (or not) entries with
+ * duplicate vg names.)
+ */
+
+static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames)
+{
+	int ret_max = ECMD_PROCESSED;
+	struct name_id_list *nl;
+	struct dm_list *vgids;
+	struct dm_str_list *sl;
+	const char *vgid;
+
+	log_verbose("Finding all volume groups");
+
+	if (!lvmetad_vg_list_to_lvmcache(cmd))
+		stack;
+
+	vgids = get_vgids(cmd, 0);
+
+	if (!vgids || dm_list_empty(vgids))
+		goto out;
+
+	dm_list_iterate_items(sl, vgids) {
+		vgid = sl->str;
+		if (!vgid)
+			continue;
+
+		nl = dm_pool_alloc(cmd->mem, sizeof(struct name_id_list));
+		if (!nl) {
+			log_error("name_id_list allocation failed");
+			return ECMD_FAILED;
+		}
+
+		nl->uuid = dm_pool_strdup(cmd->mem, vgid);
+		nl->name = lvmcache_vgname_from_vgid(cmd->mem, vgid);
+
+		dm_list_add(all_vgnames, &nl->list);
+	}
+out:
+	return ret_max;
+}
+
+static int process_vg_name_list(struct cmd_context *cmd, uint32_t flags,
+				struct dm_list *use_vgnames,
+				struct dm_list *arg_vgnames,
+				struct dm_list *arg_tags,
+				void *handle,
+				process_single_vg_fn_t process_single_vg)
+{
+	struct volume_group *vg;
+	struct name_id_list *nl;
+	const char *vg_name;
+	const char *vg_uuid;
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+	int process_all = 0;
+	int process_vg;
+
+	if (dm_list_empty(arg_vgnames) && dm_list_empty(arg_tags))
+		process_all = 1;
+
+	dm_list_iterate_items(nl, use_vgnames) {
+		vg_name = nl->name;
+		vg_uuid = nl->uuid;
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
+		process_vg = 0;
+
+		if (process_all)
+			process_vg = 1;
+
+		if (!process_vg && !dm_list_empty(arg_vgnames) &&
+		    str_list_match_item(arg_vgnames, vg_name))
+			process_vg = 1;
+
+		if (!process_vg && !dm_list_empty(arg_tags) &&
+		    str_list_match_list(arg_tags, &vg->tags, NULL))
+			process_vg = 1;
+
+		if (process_vg)
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
+static int copy_str_to_name_list(struct cmd_context *cmd,
+				 struct dm_list *sl_list,
+				 struct dm_list *nl_list)
+{
+	const char *name;
+	struct dm_str_list *sl;
+	struct name_id_list *nl;
+
+	dm_list_iterate_items(sl, sl_list) {
+		name = sl->str;
+
+		nl = dm_pool_alloc(cmd->mem, sizeof(struct name_id_list));
+		if (!nl) {
+			log_error("name_id_list allocation failed");
+			return ECMD_FAILED;
+		}
+
+		nl->uuid = NULL;
+		nl->name = dm_pool_strdup(cmd->mem, name);
+
+		dm_list_add(nl_list, &nl->list);
+	}
+	return ECMD_PROCESSED;
+}
+
+int process_each_vg(struct cmd_context *cmd,
+		    int argc, char **argv, uint32_t flags,
+		    void *handle,
+		    process_single_vg_fn_t process_single_vg)
+{
+	struct dm_list arg_tags;    /* str_list */
+	struct dm_list arg_vgnames; /* str_list */
+	struct dm_list all_vgnames; /* name_id_list */
+	struct dm_list use_vgnames; /* name_id_list */
+	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
+	int ret;
+
+	dm_list_init(&arg_tags);
+	dm_list_init(&arg_vgnames);
+	dm_list_init(&all_vgnames);
+	dm_list_init(&use_vgnames);
+
+	ret = get_arg_vgnames(cmd, argc, argv, &arg_vgnames, &arg_tags);
+	if (ret != ECMD_PROCESSED)
+		return ret;
+
+	if ((dm_list_empty(&arg_vgnames) && enable_all_vgs) ||
+	    !dm_list_empty(&arg_tags)) {
+		ret = get_all_vgnames(cmd, &all_vgnames);
+		if (ret != ECMD_PROCESSED)
+			return ret;
+	}
+
+	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&all_vgnames)) {
+		log_error("No volume groups found");
+		return ECMD_PROCESSED;
+	}
+
+	if (!dm_list_empty(&all_vgnames)) {
+		dm_list_splice(&use_vgnames, &all_vgnames);
+	} else {
+		ret = copy_str_to_name_list(cmd, &arg_vgnames, &use_vgnames);
+		if (ret != ECMD_PROCESSED)
+			return ret;
+	}
+
+	ret = process_vg_name_list(cmd, flags, &use_vgnames,
+				   &arg_vgnames, &arg_tags,
+				   handle, process_single_vg);
+	return ret;
+}
+



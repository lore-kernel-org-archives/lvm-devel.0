From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  3 Oct 2014 22:39:20 +0000 (UTC)
Subject: master - toollib: Rewrite process_each_lv.
Message-ID: <20141003223920.6987660DDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91615603cdc7974047103c4c6f6af7e56f97437b
Commit:        91615603cdc7974047103c4c6f6af7e56f97437b
Parent:        bfb6a4ecc6ad7bb06649ffd026d9c997443dd684
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 3 23:37:49 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 3 23:37:49 2014 +0100

toollib: Rewrite process_each_lv.

Copy the same form as the new process_each_vg.
Replace unused struct cmd_vg and cmd_vg_read() replicator
code with struct vg and vg_read() directly.
The failed_lvnames arg is no longer used since the
cmd_vg replicator wrapper was removed.

[Committed by agk with cosmetic changes and tweaks.]
---
 tools/toollib.c   |  643 ++++++++++++++++++++++++++++-------------------------
 tools/toollib.h   |    3 +-
 tools/vgdisplay.c |    2 +-
 3 files changed, 340 insertions(+), 308 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 8049b1f..721c727 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -184,308 +184,6 @@ int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsiste
 /*
  * Metadata iteration functions
  */
-int process_each_lv_in_vg(struct cmd_context *cmd,
-			  struct volume_group *vg,
-			  const struct dm_list *arg_lvnames,
-			  const struct dm_list *tagsl,
-			  struct dm_list *failed_lvnames,
-			  void *handle,
-			  process_single_lv_fn_t process_single_lv)
-{
-	int ret_max = ECMD_PROCESSED;
-	int ret;
-	unsigned process_all = 0;
-	unsigned tags_supplied = 0;
-	unsigned lvargs_supplied = 0;
-	unsigned lvargs_matched = 0;
-	char *lv_name;
-	struct lv_list *lvl;
-
-	if (!vg_check_status(vg, EXPORTED_VG))
-		return ECMD_FAILED;
-
-	if (tagsl && !dm_list_empty(tagsl))
-		tags_supplied = 1;
-
-	if (arg_lvnames && !dm_list_empty(arg_lvnames))
-		lvargs_supplied = 1;
-
-	/* Process all LVs in this VG if no restrictions given */
-	if (!tags_supplied && !lvargs_supplied)
-		process_all = 1;
-	/* Or if VG tags match */
-	else if (tags_supplied &&
-		 str_list_match_list(tagsl, &vg->tags, NULL))
-		process_all = 1;
-
-	/*
-	 * FIXME: In case of remove it goes through deleted entries,
-	 * but it works since entries are allocated from vg mem pool.
-	 */
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lvl->lv->status & SNAPSHOT)
-			continue;
-
-		/* Skip availability change for non-virt snaps when processing all LVs */
-		/* FIXME: pass process_all to process_single_lv() */
-		if (process_all && arg_count(cmd, activate_ARG) &&
-		    lv_is_cow(lvl->lv) && !lv_is_virtual_origin(origin_from_cow(lvl->lv)))
-			continue;
-
-		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG)) {
-			if (lvargs_supplied &&
-			    str_list_match_item(arg_lvnames, lvl->lv->name))
-				log_print_unless_silent("Ignoring virtual origin logical volume %s.",
-							display_lvname(lvl->lv));
-			continue;
-		}
-
-		/*
-		 * Only let hidden LVs through it --all was used or the LVs 
-		 * were specifically named on the command line.
-		 */
-		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
-			continue;
-
-		/* LV name match? */
-		if (lvargs_supplied &&
-		    str_list_match_item(arg_lvnames, lvl->lv->name))
-			/* Check even when process_all for counter */
-			lvargs_matched++;
-		/* LV tag match?   skip test, when process_all */
-		else if (!process_all &&
-			 (!tags_supplied ||
-			  !str_list_match_list(tagsl, &lvl->lv->tags, NULL)))
-			continue;
-
-		if (sigint_caught())
-			return_ECMD_FAILED;
-
-		lvl->lv->vg->cmd_missing_vgs = 0;
-		ret = process_single_lv(cmd, lvl->lv, handle);
-		if (ret != ECMD_PROCESSED && failed_lvnames) {
-			lv_name = dm_pool_strdup(cmd->mem, lvl->lv->name);
-			if (!lv_name ||
-			    !str_list_add(cmd->mem, failed_lvnames, lv_name)) {
-				log_error("Allocation failed for str_list.");
-				return ECMD_FAILED;
-			}
-			if (lvl->lv->vg->cmd_missing_vgs)
-				ret = ECMD_PROCESSED;
-		}
-		if (ret > ret_max)
-			ret_max = ret;
-	}
-
-	if (lvargs_supplied && lvargs_matched != dm_list_size(arg_lvnames)) {
-		/*
-		 * FIXME: lvm supports removal of LV with all its dependencies
-		 * this leads to miscalculation that depends on the order of args.
-		 */
-		log_error("One or more specified logical volume(s) not found.");
-		if (ret_max < ECMD_FAILED)
-			ret_max = ECMD_FAILED;
-	}
-
-	return ret_max;
-}
-
-int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t flags, void *handle,
-		    process_single_lv_fn_t process_single_lv)
-{
-	int opt = 0;
-	int ret_max = ECMD_PROCESSED;
-	int ret;
-
-	struct dm_list *tags_arg;
-	struct dm_list *vgnames;	/* VGs to process */
-	struct dm_str_list *sll, *strl;
-	struct cmd_vg *cvl_vg;
-	struct dm_list cmd_vgs;
-	struct dm_list failed_lvnames;
-	struct dm_list tagsl, lvnames;
-	struct dm_list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
-	struct dm_list arg_vgnames;
-	char *vglv;
-	size_t vglv_sz;
-
-	const char *vgname;
-
-	dm_list_init(&tagsl);
-	dm_list_init(&arg_lvnames);
-	dm_list_init(&failed_lvnames);
-
-	if (argc) {
-		log_verbose("Using logical volume(s) on command line");
-		dm_list_init(&arg_vgnames);
-
-		for (; opt < argc; opt++) {
-			const char *lv_name = argv[opt];
-			const char *tmp_lv_name;
-			char *vgname_def;
-			unsigned dev_dir_found = 0;
-
-			/* Do we have a tag or vgname or lvname? */
-			vgname = lv_name;
-
-			if (*vgname == '@') {
-				if (!validate_tag(vgname + 1)) {
-					log_error("Skipping invalid tag %s",
-						  vgname);
-					continue;
-				}
-				if (!str_list_add(cmd->mem, &tagsl,
-						  dm_pool_strdup(cmd->mem,
-							      vgname + 1))) {
-					log_error("strlist allocation failed");
-					return ECMD_FAILED;
-				}
-				continue;
-			}
-
-			/* FIXME Jumbled parsing */
-			vgname = skip_dev_dir(cmd, vgname, &dev_dir_found);
-
-			if (*vgname == '/') {
-				log_error("\"%s\": Invalid path for Logical "
-					  "Volume", argv[opt]);
-				if (ret_max < ECMD_FAILED)
-					ret_max = ECMD_FAILED;
-				continue;
-			}
-			lv_name = vgname;
-			if ((tmp_lv_name = strchr(vgname, '/'))) {
-				/* Must be an LV */
-				lv_name = tmp_lv_name;
-				while (*lv_name == '/')
-					lv_name++;
-				if (!(vgname = extract_vgname(cmd, vgname))) {
-					if (ret_max < ECMD_FAILED) {
-						stack;
-						ret_max = ECMD_FAILED;
-					}
-					continue;
-				}
-			} else if (!dev_dir_found &&
-				   (vgname_def = default_vgname(cmd))) {
-				vgname = vgname_def;
-			} else
-				lv_name = NULL;
-
-			if (!str_list_add(cmd->mem, &arg_vgnames,
-					  dm_pool_strdup(cmd->mem, vgname))) {
-				log_error("strlist allocation failed");
-				return ECMD_FAILED;
-			}
-
-			if (!lv_name) {
-				if (!str_list_add(cmd->mem, &arg_lvnames,
-						  dm_pool_strdup(cmd->mem,
-							      vgname))) {
-					log_error("strlist allocation failed");
-					return ECMD_FAILED;
-				}
-			} else {
-				vglv_sz = strlen(vgname) + strlen(lv_name) + 2;
-				if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
-				    dm_snprintf(vglv, vglv_sz, "%s/%s", vgname,
-						 lv_name) < 0) {
-					log_error("vg/lv string alloc failed");
-					return ECMD_FAILED;
-				}
-				if (!str_list_add(cmd->mem, &arg_lvnames, vglv)) {
-					log_error("strlist allocation failed");
-					return ECMD_FAILED;
-				}
-			}
-		}
-		vgnames = &arg_vgnames;
-	}
-
-	if (!argc || !dm_list_empty(&tagsl)) {
-		log_verbose("Finding all logical volumes");
-		if (!lvmetad_vg_list_to_lvmcache(cmd))
-			stack;
-		if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames)) {
-			log_error("No volume groups found");
-			return ret_max;
-		}
-	}
-
-	dm_list_iterate_items(strl, vgnames) {
-		vgname = strl->str;
-		dm_list_init(&cmd_vgs);
-		if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs,
-					  vgname, NULL, flags)))
-			return_ECMD_FAILED;
-
-		if (!cmd_vg_read(cmd, &cmd_vgs)) {
-			if (ignore_vg(cvl_vg->vg, vgname, 0, &ret_max))
-				stack;
-
-			free_cmd_vgs(&cmd_vgs);
-			continue;
-		}
-
-		tags_arg = &tagsl;
-		dm_list_init(&lvnames);	/* LVs to be processed in this VG */
-		dm_list_iterate_items(sll, &arg_lvnames) {
-			const char *vg_name = sll->str;
-			const char *lv_name = strchr(vg_name, '/');
-
-			if ((!lv_name && !strcmp(vg_name, vgname))) {
-				/* Process all LVs in this VG */
-				tags_arg = NULL;
-				dm_list_init(&lvnames);
-				break;
-			} else if (!strncmp(vg_name, vgname, strlen(vgname)) && lv_name &&
-				   strlen(vgname) == (size_t) (lv_name - vg_name)) {
-				if (!str_list_add(cmd->mem, &lvnames,
-						  dm_pool_strdup(cmd->mem,
-								 lv_name + 1))) {
-					log_error("strlist allocation failed");
-					free_cmd_vgs(&cmd_vgs);
-					return ECMD_FAILED;
-				}
-			}
-		}
-
-		for (;;) {
-			if (sigint_caught())
-				return_ECMD_FAILED;
-
-			ret = process_each_lv_in_vg(cmd, cvl_vg->vg, &lvnames,
-						    tags_arg, &failed_lvnames,
-						    handle, process_single_lv);
-			if (ret != ECMD_PROCESSED) {
-				stack;
-				break;
-			}
-
-			if (dm_list_empty(&failed_lvnames))
-				break;
-
-			/* Try again with failed LVs in this VG */
-			dm_list_init(&lvnames);
-			dm_list_splice(&lvnames, &failed_lvnames);
-
-			free_cmd_vgs(&cmd_vgs);
-			if (!cmd_vg_read(cmd, &cmd_vgs)) {
-				stack;
-				ret = ECMD_FAILED; /* break */
-				break;
-			}
-		}
-		if (ret > ret_max)
-			ret_max = ret;
-
-		free_cmd_vgs(&cmd_vgs);
-	}
-
-	return ret_max;
-}
-
 int process_each_segment_in_pv(struct cmd_context *cmd,
 			       struct volume_group *vg,
 			       struct physical_volume *pv,
@@ -2002,8 +1700,8 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
  * Copy the contents of a str_list of VG names to a name list, filling
  * in the vgid with NULL (unknown).
  */
-static int _copy_str_to_name_list(struct cmd_context *cmd, struct dm_list *sll,
-				  struct dm_list *vgnll)
+static int _copy_str_to_vgnameid_list(struct cmd_context *cmd, struct dm_list *sll,
+				      struct dm_list *vgnll)
 {
 	const char *vgname;
 	struct dm_str_list *sl;
@@ -2067,6 +1765,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
+		/* FIXME Should be log_print, but suppressed for reporting cmds */
 		log_error("No volume groups found");
 		return ECMD_PROCESSED;
 	}
@@ -2077,7 +1776,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	 */
 	if (!dm_list_empty(&vgnameids_on_system))
 		dm_list_splice(&vgnameids_to_process, &vgnameids_on_system);
-	else if ((ret = _copy_str_to_name_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED) {
+	else if ((ret = _copy_str_to_vgnameid_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED) {
 		stack;
 		return ret;
 	}
@@ -2085,3 +1784,337 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	return _process_vgnameid_list(cmd, flags, &vgnameids_to_process,
 				      &arg_vgnames, &arg_tags, handle, process_single_vg);
 }
+
+int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
+			  struct dm_list *arg_lvnames, const struct dm_list *tags_in,
+			  void *handle, process_single_lv_fn_t process_single_lv)
+{
+	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+	unsigned process_all = 0;
+	unsigned tags_supplied = 0;
+	unsigned lvargs_supplied = 0;
+	struct lv_list *lvl;
+	struct dm_str_list *sl;
+
+	if (!vg_check_status(vg, EXPORTED_VG))
+		return_ECMD_FAILED;
+
+	if (tags_in && !dm_list_empty(tags_in))
+		tags_supplied = 1;
+
+	if (arg_lvnames && !dm_list_empty(arg_lvnames))
+		lvargs_supplied = 1;
+
+	/* Process all LVs in this VG if no restrictions given 
+	 * or if VG tags match. */
+	if ((!tags_supplied && !lvargs_supplied) ||
+	    (tags_supplied && str_list_match_list(tags_in, &vg->tags, NULL)))
+		process_all = 1;
+
+	/*
+	 * FIXME: In case of remove it goes through deleted entries,
+	 * but it works since entries are allocated from vg mem pool.
+	 */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lvl->lv->status & SNAPSHOT)
+			continue;
+
+		/* Skip availability change for non-virt snaps when processing all LVs */
+		/* FIXME: pass process_all to process_single_lv() */
+		if (process_all && arg_count(cmd, activate_ARG) &&
+		    lv_is_cow(lvl->lv) && !lv_is_virtual_origin(origin_from_cow(lvl->lv)))
+			continue;
+
+		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG)) {
+			if (lvargs_supplied &&
+			    str_list_match_item(arg_lvnames, lvl->lv->name))
+				log_print_unless_silent("Ignoring virtual origin logical volume %s.",
+							display_lvname(lvl->lv));
+			continue;
+		}
+
+		/*
+		 * Only let hidden LVs through it --all was used or the LVs 
+		 * were specifically named on the command line.
+		 */
+		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
+			continue;
+
+		/* Only process the LV if the name matches or process_all is set or if an LV tag matches */
+		if (lvargs_supplied && str_list_match_item(arg_lvnames, lvl->lv->name))
+			/* Remove LV from list of unprocessed LV names */
+			str_list_del(arg_lvnames, lvl->lv->name);
+		else if (!process_all &&
+			 (!tags_supplied || !str_list_match_list(tags_in, &lvl->lv->tags, NULL)))
+			continue;
+
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
+		log_very_verbose("Processing LV %s in VG %s", lvl->lv->name, vg->name);
+
+		ret = process_single_lv(cmd, lvl->lv, handle);
+
+		if (ret > ret_max)
+			ret_max = ret;
+	}
+
+	if (lvargs_supplied) {
+		/*
+		 * FIXME: lvm supports removal of LV with all its dependencies
+		 * this leads to miscalculation that depends on the order of args.
+		 */
+		dm_list_iterate_items(sl, arg_lvnames) {
+			log_error("Failed to find logical volume \"%s/%s\"",
+				  vg->name, sl->str);
+			if (ret_max < ECMD_FAILED)
+				ret_max = ECMD_FAILED;
+		}
+	}
+
+	return ret_max;
+}
+
+/*
+ * If arg is tag, add it to arg_tags
+ * else the arg is either vgname or vgname/lvname:
+ * - add the vgname of each arg to arg_vgnames
+ * - if arg has no lvname, add just vgname arg_lvnames,
+ *   it represents all lvs in the vg
+ * - if arg has lvname, add vgname/lvname to arg_lvnames
+ */
+static int _get_arg_lvnames(struct cmd_context *cmd,
+			    int argc, char **argv,
+			    struct dm_list *arg_vgnames,
+			    struct dm_list *arg_lvnames,
+			    struct dm_list *arg_tags)
+{
+	int opt = 0;
+	int ret_max = ECMD_PROCESSED;
+	char *vglv;
+	size_t vglv_sz;
+	const char *vgname;
+	const char *lv_name;
+	const char *tmp_lv_name;
+	char *vgname_def;
+	unsigned dev_dir_found;
+
+	log_verbose("Using logical volume(s) on command line");
+
+	for (; opt < argc; opt++) {
+		lv_name = argv[opt];
+		dev_dir_found = 0;
+
+		/* Do we have a tag or vgname or lvname? */
+		vgname = lv_name;
+
+		if (*vgname == '@') {
+			if (!validate_tag(vgname + 1)) {
+				log_error("Skipping invalid tag %s", vgname);
+				continue;
+			}
+			if (!str_list_add(cmd->mem, arg_tags,
+					  dm_pool_strdup(cmd->mem, vgname + 1))) {
+				log_error("strlist allocation failed");
+				return ECMD_FAILED;
+			}
+			continue;
+		}
+
+		/* FIXME Jumbled parsing */
+		vgname = skip_dev_dir(cmd, vgname, &dev_dir_found);
+
+		if (*vgname == '/') {
+			log_error("\"%s\": Invalid path for Logical Volume",
+				  argv[opt]);
+			if (ret_max < ECMD_FAILED)
+				ret_max = ECMD_FAILED;
+			continue;
+		}
+		lv_name = vgname;
+		if ((tmp_lv_name = strchr(vgname, '/'))) {
+			/* Must be an LV */
+			lv_name = tmp_lv_name;
+			while (*lv_name == '/')
+				lv_name++;
+			if (!(vgname = extract_vgname(cmd, vgname))) {
+				if (ret_max < ECMD_FAILED) {
+					stack;
+					ret_max = ECMD_FAILED;
+				}
+				continue;
+			}
+		} else if (!dev_dir_found &&
+			   (vgname_def = default_vgname(cmd)))
+			vgname = vgname_def;
+		else
+			lv_name = NULL;
+
+		if (!str_list_add(cmd->mem, arg_vgnames,
+				  dm_pool_strdup(cmd->mem, vgname))) {
+			log_error("strlist allocation failed");
+			return ECMD_FAILED;
+		}
+
+		if (!lv_name) {
+			if (!str_list_add(cmd->mem, arg_lvnames,
+					  dm_pool_strdup(cmd->mem, vgname))) {
+				log_error("strlist allocation failed");
+				return ECMD_FAILED;
+			}
+		} else {
+			vglv_sz = strlen(vgname) + strlen(lv_name) + 2;
+			if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
+			    dm_snprintf(vglv, vglv_sz, "%s/%s", vgname, lv_name) < 0) {
+				log_error("vg/lv string alloc failed");
+				return ECMD_FAILED;
+			}
+			if (!str_list_add(cmd->mem, arg_lvnames, vglv)) {
+				log_error("strlist allocation failed");
+				return ECMD_FAILED;
+			}
+		}
+	}
+
+	return ret_max;
+}
+
+static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
+				     struct dm_list *vgnameids_to_process,
+				     struct dm_list *arg_vgnames,
+				     struct dm_list *arg_lvnames,
+				     struct dm_list *arg_tags,
+				     void *handle,
+				     process_single_lv_fn_t process_single_lv)
+{
+	struct volume_group *vg;
+	struct vgnameid_list *nl;
+	struct dm_str_list *sl;
+	struct dm_list *tags_arg;
+	struct dm_list lvnames;
+	const char *vg_name;
+	const char *vg_uuid;
+	const char *vgn;
+	const char *lvn;
+	int ret_max = ECMD_PROCESSED;
+	int ret;
+
+	dm_list_iterate_items(nl, vgnameids_to_process) {
+		vg_name = nl->vg_name;
+		vg_uuid = nl->vgid;
+		ret = 0;
+
+		/*
+		 * arg_lvnames contains some elements that are just "vgname"
+		 * which means process all lvs in the vg.  Other elements
+		 * are "vgname/lvname" which means process only the select
+		 * lvs in the vg.
+		 */
+		tags_arg = arg_tags;
+		dm_list_init(&lvnames);	/* LVs to be processed in this VG */
+
+		dm_list_iterate_items(sl, arg_lvnames) {
+			vgn = sl->str;
+			lvn = strchr(vgn, '/');
+
+			if (!lvn && !strcmp(vgn, vg_name)) {
+				/* Process all LVs in this VG */
+				tags_arg = NULL;
+				dm_list_init(&lvnames);
+				break;
+			}
+			
+			if (lvn && !strncmp(vgn, vg_name, strlen(vg_name)) &&
+			    strlen(vg_name) == (size_t) (lvn - vgn)) {
+				if (!str_list_add(cmd->mem, &lvnames,
+						  dm_pool_strdup(cmd->mem, lvn + 1))) {
+					log_error("strlist allocation failed");
+					return ECMD_FAILED;
+				}
+			}
+		}
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
+		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
+					    handle, process_single_lv);
+		unlock_and_release_vg(cmd, vg, vg_name);
+
+		if (ret > ret_max)
+			ret_max = ret;
+
+		if (sigint_caught())
+			break;
+	}
+
+	return ret_max;
+}
+
+/*
+ * Call process_single_lv() for each LV selected by the command line arguments.
+ */
+int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t flags,
+		    void *handle, process_single_lv_fn_t process_single_lv)
+{
+	struct dm_list arg_tags;		/* str_list */
+	struct dm_list arg_vgnames;		/* str_list */
+	struct dm_list arg_lvnames;		/* str_list */
+	struct dm_list vgnameids_on_system;	/* vgnameid_list */
+	struct dm_list vgnameids_to_process;	/* vgnameid_list */
+
+	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
+	int ret;
+
+	dm_list_init(&arg_tags);
+	dm_list_init(&arg_vgnames);
+	dm_list_init(&arg_lvnames);
+	dm_list_init(&vgnameids_on_system);
+	dm_list_init(&vgnameids_to_process);
+
+	/*
+	 * Find any LVs, VGs or tags explicitly provided on the command line.
+	 */
+	if ((ret = _get_arg_lvnames(cmd, argc, argv, &arg_vgnames, &arg_lvnames, &arg_tags) != ECMD_PROCESSED)) {
+		stack;
+		return ret;
+	}
+
+	/*
+	 * Obtain the complete list of VGs present on the system if it is needed because:
+	 *   any tags were supplied and need resolving; or
+	 *   no VG names were given and the command defaults to processing all VGs.
+	*/
+	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
+	    (ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system) != ECMD_PROCESSED)) {
+		stack;
+		return ret;
+	}
+
+	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
+		/* FIXME Should be log_print, but suppressed for reporting cmds */
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
+	else if ((ret = _copy_str_to_vgnameid_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED) {
+		stack;
+		return ret;
+	}
+
+	return _process_lv_vgnameid_list(cmd, flags, &vgnameids_to_process, &arg_vgnames, &arg_lvnames,
+					 &arg_tags, handle, process_single_lv);
+}
diff --git a/tools/toollib.h b/tools/toollib.h
index 8aa82e0..1a14d60 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -86,9 +86,8 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
-			  const struct dm_list *arg_lvnames,
+			  struct dm_list *arg_lvnames,
 			  const struct dm_list *tagsl,
-			  struct dm_list *failed_lvnames,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv);
 
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index a739d11..39cdaf3 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -39,7 +39,7 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 	if (arg_count(cmd, verbose_ARG)) {
 		vgdisplay_extents(vg);
 
-		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL, NULL,
+		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
 				      (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");



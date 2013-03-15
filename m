From: David Teigland <teigland@redhat.com>
Date: Fri, 15 Mar 2013 14:49:21 -0500
Subject: [PATCH 2/5] toollib: rework process_each_lv
Message-ID: <1363376964-23100-3-git-send-email-teigland@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A new flag from commands makes explicit when
process_each_lv may query for "all vgs" and
run the command on each.  A command is run
against all vgs only when this flag is
provided and no vg/lv names or tags are provided.

When vg/lv names or tags are explicitly named
on the command line, the command is only run
against named vgs/lvs, or vgs/lvs with tags
matching one provided.

There should be no functional change.
---
 tools/lvdisplay.c |   4 +-
 tools/lvscan.c    |   4 +-
 tools/reporter.c  |   8 +-
 tools/toollib.c   | 459 ++++++++++++++++++++++++++++++------------------------
 tools/vgmknodes.c |   4 +-
 5 files changed, 267 insertions(+), 212 deletions(-)

diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index f5531cb..a899b1e 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -54,6 +54,6 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, 0, NULL,
-			       &_lvdisplay_single);
+	return process_each_lv(cmd, argc, argv, ENABLE_ALL_VGNAMES,
+			       NULL, &_lvdisplay_single);
 }
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 636ac45..af82bbb 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -74,6 +74,6 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, 0, NULL,
-			       &lvscan_single);
+	return process_each_lv(cmd, argc, argv, ENABLE_ALL_VGNAMES,
+			       NULL, &lvscan_single);
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index ead401b..0e6cbe4 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -366,8 +366,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	switch (report_type) {
 	case LVS:
-		r = process_each_lv(cmd, argc, argv, 0, report_handle,
-				    &_lvs_single);
+		r = process_each_lv(cmd, argc, argv, ENABLE_ALL_VGNAMES,
+				    report_handle, &_lvs_single);
 		break;
 	case VGS:
 		r = process_each_vg(cmd, argc, argv, ENABLE_ALL_VGNAMES,
@@ -386,8 +386,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 					    report_handle, &_pvs_in_vg);
 		break;
 	case SEGS:
-		r = process_each_lv(cmd, argc, argv, 0, report_handle,
-				    &_lvsegs_single);
+		r = process_each_lv(cmd, argc, argv, ENABLE_ALL_VGNAMES,
+				    report_handle, &_lvsegs_single);
 		break;
 	case PVSEGS:
 		if (args_are_pvs)
diff --git a/tools/toollib.c b/tools/toollib.c
index 247462b..e38e20c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -194,208 +194,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 	return ret_max;
 }
 
-int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t flags, void *handle,
-		    process_single_lv_fn_t process_single_lv)
-{
-	int opt = 0;
-	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
-
-	struct dm_list *tags_arg;
-	struct dm_list *vgnames;	/* VGs to process */
-	struct str_list *sll, *strl;
-	struct cmd_vg *cvl_vg;
-	struct dm_list cmd_vgs;
-	struct dm_list failed_lvnames;
-	struct dm_list tags, lvnames;
-	struct dm_list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
-	struct dm_list arg_vgnames;
-	char *vglv;
-	size_t vglv_sz;
-
-	const char *vgname;
-
-	dm_list_init(&tags);
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
-				if (!str_list_add(cmd->mem, &tags,
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
-	if (!argc || !dm_list_empty(&tags)) {
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
-					  vgname, NULL, flags))) {
-			stack;
-			return ECMD_FAILED;
-		}
-
-		if (!cmd_vg_read(cmd, &cmd_vgs)) {
-			free_cmd_vgs(&cmd_vgs);
-			if (ret_max < ECMD_FAILED) {
-				log_error("Skipping volume group %s", vgname);
-				ret_max = ECMD_FAILED;
-			} else
-				stack;
-			continue;
-		}
-
-		tags_arg = &tags;
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
-		while (!sigint_caught()) {
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
-		/* FIXME: logic for breaking command is not consistent */
-		if (sigint_caught()) {
-			stack;
-			return ECMD_FAILED;
-		}
-	}
-
-	return ret_max;
-}
-
 int process_each_segment_in_pv(struct cmd_context *cmd,
 			       struct volume_group *vg,
 			       struct physical_volume *pv,
@@ -1792,3 +1590,260 @@ int process_each_vg(struct cmd_context *cmd,
 	return ret;
 }
 
+/*
+ * If arg is tag, add it to arg_tags
+ * else the arg is either vgname or vgname/lvname:
+ * - add the vgname of each arg to arg_vgnames
+ * - if arg has no lvname, add just vgname arg_lvnames,
+ *   it represents all lvs in the vg
+ * - if arg has lvname, add vgname/lvname to arg_lvnames
+ */
+
+static int get_arg_lvnames(struct cmd_context *cmd,
+			   int argc, char **argv,
+			   struct dm_list *arg_vgnames,
+			   struct dm_list *arg_lvnames,
+			   struct dm_list *arg_tags)
+{
+	int opt = 0;
+	int ret_max = ECMD_PROCESSED;
+	char *vglv;
+	size_t vglv_sz;
+	const char *vgname;
+
+	log_verbose("Using logical volume(s) on command line");
+
+	for (; opt < argc; opt++) {
+		const char *lv_name = argv[opt];
+		const char *tmp_lv_name;
+		char *vgname_def;
+		unsigned dev_dir_found = 0;
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
+			   (vgname_def = default_vgname(cmd))) {
+			vgname = vgname_def;
+		} else
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
+static int process_lv_vg_name_list(struct cmd_context *cmd, uint32_t flags,
+				   struct dm_list *vg_name_list,
+				   struct dm_list *arg_vgnames,
+				   struct dm_list *arg_lvnames,
+				   struct dm_list *arg_tags,
+				   void *handle,
+				   process_single_lv_fn_t process_single_lv)
+{
+	struct str_list *sl, *sll;
+	struct cmd_vg *cvl_vg;
+	struct dm_list *tags_arg;
+	struct dm_list cmd_vgs;
+	struct dm_list failed_lvnames;
+	struct dm_list lvnames;
+	const char *vgname;
+	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+
+	dm_list_init(&failed_lvnames);
+
+	dm_list_iterate_items(sl, vg_name_list) {
+		vgname = sl->str;
+
+		dm_list_init(&cmd_vgs);
+		if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs,
+					  vgname, NULL, flags))) {
+			stack;
+			return ECMD_FAILED;
+		}
+
+		if (!cmd_vg_read(cmd, &cmd_vgs)) {
+			free_cmd_vgs(&cmd_vgs);
+			if (ret_max < ECMD_FAILED) {
+				log_error("Skipping volume group %s", vgname);
+				ret_max = ECMD_FAILED;
+			} else
+				stack;
+			continue;
+		}
+
+		/*
+		 * arg_lvnames contains some elements that are just "vgname"
+		 * which means process all lvs in the vg.  Other elements
+		 * are "vgname/lvname" which means process only the select
+		 * lvs in the vg.
+		 */
+
+		tags_arg = arg_tags;
+		dm_list_init(&lvnames);	/* LVs to be processed in this VG */
+
+		dm_list_iterate_items(sll, arg_lvnames) {
+			const char *vg_name = sll->str;
+			const char *lv_name = strchr(vg_name, '/');
+
+			if (!lv_name && !strcmp(vg_name, vgname)) {
+				/* Process all LVs in this VG */
+				tags_arg = NULL;
+				dm_list_init(&lvnames);
+				break;
+			}
+			
+			if (lv_name && !strncmp(vg_name, vgname, strlen(vgname)) &&
+			    strlen(vgname) == (size_t) (lv_name - vg_name)) {
+				if (!str_list_add(cmd->mem, &lvnames,
+						  dm_pool_strdup(cmd->mem, lv_name + 1))) {
+					log_error("strlist allocation failed");
+					free_cmd_vgs(&cmd_vgs);
+					return ECMD_FAILED;
+				}
+			}
+		}
+
+		while (!sigint_caught()) {
+			ret = process_each_lv_in_vg(cmd, cvl_vg->vg, &lvnames,
+						    tags_arg, &failed_lvnames,
+						    handle, process_single_lv);
+			if (ret != ECMD_PROCESSED) {
+				stack;
+				break;
+			}
+
+			if (dm_list_empty(&failed_lvnames))
+				break;
+
+			/* Try again with failed LVs in this VG */
+			dm_list_init(&lvnames);
+			dm_list_splice(&lvnames, &failed_lvnames);
+
+			free_cmd_vgs(&cmd_vgs);
+			if (!cmd_vg_read(cmd, &cmd_vgs)) {
+				stack;
+				ret = ECMD_FAILED; /* break */
+				break;
+			}
+		}
+		if (ret > ret_max)
+			ret_max = ret;
+
+		free_cmd_vgs(&cmd_vgs);
+		/* FIXME: logic for breaking command is not consistent */
+		if (sigint_caught()) {
+			stack;
+			return ECMD_FAILED;
+		}
+	}
+
+	return ret_max;
+}
+
+int process_each_lv(struct cmd_context *cmd,
+		    int argc, char **argv, uint32_t flags,
+		    void *handle,
+		    process_single_lv_fn_t process_single_lv)
+{
+	struct dm_list all_vgnames;
+	struct dm_list arg_vgnames;
+	struct dm_list arg_lvnames;
+	struct dm_list arg_tags;
+	struct dm_list *vg_name_list;
+	int ret;
+
+	dm_list_init(&all_vgnames);
+	dm_list_init(&arg_vgnames);
+	dm_list_init(&arg_lvnames);
+	dm_list_init(&arg_tags);
+
+	ret = get_arg_lvnames(cmd, argc, argv,
+			      &arg_vgnames, &arg_lvnames, &arg_tags);
+	if (ret != ECMD_PROCESSED)
+		return ret;
+
+	if ((dm_list_empty(&arg_vgnames) && (flags & ENABLE_ALL_VGNAMES)) ||
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
+	if (!dm_list_empty(&all_vgnames))
+		vg_name_list = &all_vgnames;
+	else
+		vg_name_list = &arg_vgnames;
+
+	ret = process_lv_vg_name_list(cmd, flags, vg_name_list,
+				      &arg_vgnames, &arg_lvnames, &arg_tags,
+				      handle, process_single_lv);
+	return ret;
+}
+
diff --git a/tools/vgmknodes.c b/tools/vgmknodes.c
index 0fd273f..a012230 100644
--- a/tools/vgmknodes.c
+++ b/tools/vgmknodes.c
@@ -39,6 +39,6 @@ int vgmknodes(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
-			    &_vgmknodes_single);
+	return process_each_lv(cmd, argc, argv, LCK_VG_READ | ENABLE_ALL_VGNAMES,
+			       NULL, &_vgmknodes_single);
 }
-- 
1.8.1.rc1.5.g7e0651a



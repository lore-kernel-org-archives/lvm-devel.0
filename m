From: David Teigland <teigland@redhat.com>
Date: Fri, 15 Mar 2013 14:49:20 -0500
Subject: [PATCH 1/5] toollib: rework process_each_vg
Message-ID: <1363376964-23100-2-git-send-email-teigland@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A new flag from commands makes explicit when
process_each_vg may query for "all vgs" and
run the command on each.  A command is run
against all vgs only when this flag is
provided and no vg names or tags are provided.

When vg names or tags are explicitly named
on the command line, the command is only run
against named vgs, or vgs with tags matching
one provided.

There should be no functional change.
---
 lib/metadata/metadata-exported.h |   3 +-
 tools/polldaemon.c               |   3 +-
 tools/reporter.c                 |   6 +-
 tools/toollib.c                  | 244 ++++++++++++++++++++++++---------------
 tools/vgcfgbackup.c              |   2 +-
 tools/vgchange.c                 |   8 +-
 tools/vgck.c                     |   2 +-
 tools/vgdisplay.c                |   2 +-
 tools/vgexport.c                 |   7 +-
 tools/vgscan.c                   |   2 +-
 10 files changed, 174 insertions(+), 105 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c2728d5..7db0e68 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -119,8 +119,9 @@
 #define READ_ALLOW_EXPORTED	0x00020000U
 #define READ_WITHOUT_LOCK	0x00040000U
 
-/* A meta-flag, useful with toollib for_each_* functions. */
+/* meta-flags, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE		0x00100000U
+#define ENABLE_ALL_VGNAMES	0x00200000U	/* run cmd on all vg names if none are named */
 
 /* vg's "read_status" field */
 #define FAILED_INCONSISTENT	0x00000001U
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 5724623..95f048b 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -290,7 +290,8 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 {
 	while (1) {
 		parms->outstanding_count = 0;
-		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, parms, _poll_vg);
+		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE | ENABLE_ALL_VGNAMES,
+				parms, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
 		sleep(parms->interval);
diff --git a/tools/reporter.c b/tools/reporter.c
index 3db8b83..ead401b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -370,7 +370,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 				    &_lvs_single);
 		break;
 	case VGS:
-		r = process_each_vg(cmd, argc, argv, 0,
+		r = process_each_vg(cmd, argc, argv, ENABLE_ALL_VGNAMES,
 				    report_handle, &_vgs_single);
 		break;
 	case LABEL:
@@ -382,7 +382,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			r = process_each_pv(cmd, argc, argv, NULL, 0,
 					    0, report_handle, &_pvs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, 0,
+			r = process_each_vg(cmd, argc, argv, ENABLE_ALL_VGNAMES,
 					    report_handle, &_pvs_in_vg);
 		break;
 	case SEGS:
@@ -394,7 +394,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			r = process_each_pv(cmd, argc, argv, NULL, 0,
 					    0, report_handle, &_pvsegs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, 0,
+			r = process_each_vg(cmd, argc, argv, ENABLE_ALL_VGNAMES,
 					    report_handle, &_pvsegs_in_vg);
 		break;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index f00988a..247462b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -477,7 +477,6 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 }
 
 static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
-			   const char *vgid,
 			   struct dm_list *tags, struct dm_list *arg_vgnames,
 			   uint32_t flags, void *handle, int ret_max,
 			   process_single_vg_fn_t process_single_vg)
@@ -489,7 +488,7 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 	log_verbose("Finding volume group \"%s\"", vg_name);
 
 	dm_list_init(&cmd_vgs);
-	if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs, vg_name, vgid, flags)))
+	if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs, vg_name, NULL, flags)))
 		return_0;
 
 	for (;;) {
@@ -529,98 +528,6 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 	return (ret > ret_max) ? ret : ret_max;
 }
 
-int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t flags, void *handle,
-		    process_single_vg_fn_t process_single_vg)
-{
-	int opt = 0;
-	int ret_max = ECMD_PROCESSED;
-
-	struct str_list *sl;
-	struct dm_list *vgnames, *vgids;
-	struct dm_list arg_vgnames, tags;
-
-	const char *vg_name, *vgid;
-
-	dm_list_init(&tags);
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
-				if (!str_list_add(cmd->mem, &tags,
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
-	if (!argc || !dm_list_empty(&tags)) {
-		log_verbose("Finding all volume groups");
-		if (!lvmetad_vg_list_to_lvmcache(cmd))
-			stack;
-		if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
-			log_error("No volume groups found");
-			return ret_max;
-		}
-		dm_list_iterate_items(sl, vgids) {
-			vgid = sl->str;
-			if (!(vgid) || !(vg_name = lvmcache_vgname_from_vgid(cmd->mem, vgid)))
-				continue;
-			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
-						  &arg_vgnames,
-						  flags, handle,
-					  	  ret_max, process_single_vg);
-			if (sigint_caught())
-				return ret_max;
-		}
-	} else {
-		dm_list_iterate_items(sl, vgnames) {
-			vg_name = sl->str;
-			if (is_orphan_vg(vg_name))
-				continue;	/* FIXME Unnecessary? */
-			ret_max = _process_one_vg(cmd, vg_name, NULL, &tags,
-						  &arg_vgnames,
-						  flags, handle,
-					  	  ret_max, process_single_vg);
-			if (sigint_caught())
-				return ret_max;
-		}
-	}
-
-	return ret_max;
-}
-
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  const struct dm_list *tags, void *handle,
 			  process_single_pv_fn_t process_single_pv)
@@ -1736,3 +1643,152 @@ uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup)
 	return (uint32_t)(((uint64_t)percents * (uint64_t)count +
 			   ((roundup) ? 99 : 0)) / 100);
 }
+
+/*
+ * If arg is tag, add it to arg_tags.
+ * Else the arg is vgname, add the vgname
+ * from each arg to arg_vgnames.
+ */
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
+static int get_all_vgnames(struct cmd_context *cmd, struct dm_list *all_vgnames)
+{
+	int ret_max = ECMD_PROCESSED;
+	struct dm_list *vgnames;
+	struct str_list *sl;
+	const char *vg_name;
+
+	log_verbose("Finding all volume groups");
+
+	if (!lvmetad_vg_list_to_lvmcache(cmd))
+		stack;
+
+	if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames))
+		goto out;
+
+	dm_list_iterate_items(sl, vgnames) {
+		vg_name = sl->str;
+		if (!vg_name)
+			continue;
+
+		if (!str_list_add(cmd->mem, all_vgnames,
+				  dm_pool_strdup(cmd->mem, vg_name))) {
+			log_error("strlist allocation failed");
+			return ECMD_FAILED;
+		}
+	}
+out:
+	return ret_max;
+}
+
+static int process_vg_name_list(struct cmd_context *cmd, uint32_t flags,
+				struct dm_list *vg_name_list,
+				struct dm_list *arg_vgnames,
+				struct dm_list *arg_tags,
+				void *handle,
+				process_single_vg_fn_t process_single_vg)
+{
+	struct str_list *sl;
+	const char *vgname;
+	int ret_max = ECMD_PROCESSED;
+
+	dm_list_iterate_items(sl, vg_name_list) {
+		vgname = sl->str;
+		ret_max = _process_one_vg(cmd, vgname,
+					  arg_tags, arg_vgnames,
+					  flags, handle, ret_max,
+					  process_single_vg);
+
+		if (sigint_caught())
+			break;
+	}
+
+	return ret_max;
+}
+
+int process_each_vg(struct cmd_context *cmd,
+		    int argc, char **argv, uint32_t flags,
+		    void *handle,
+		    process_single_vg_fn_t process_single_vg)
+{
+	struct dm_list all_vgnames;
+	struct dm_list arg_vgnames;
+	struct dm_list arg_tags;
+	struct dm_list *vg_name_list;
+	int ret;
+
+	dm_list_init(&all_vgnames);
+	dm_list_init(&arg_vgnames);
+	dm_list_init(&arg_tags);
+
+	ret = get_arg_vgnames(cmd, argc, argv, &arg_vgnames, &arg_tags);
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
+	ret = process_vg_name_list(cmd, flags, vg_name_list,
+				   &arg_vgnames, &arg_tags,
+				   handle, process_single_vg);
+	return ret;
+}
+
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 32948d8..84f85cc 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -92,7 +92,7 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, READ_ALLOW_INCONSISTENT,
+	ret = process_each_vg(cmd, argc, argv, READ_ALLOW_INCONSISTENT | ENABLE_ALL_VGNAMES,
 			      &last_filename, &vg_backup_single);
 
 	dm_free(last_filename);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index ccf31da..d359af0 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -538,6 +538,8 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 
 int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
+	uint32_t flags = 0;
+
 	/* Update commands that can be combined */
 	int update_partial_safe =
 		arg_count(cmd, deltag_ARG) ||
@@ -618,6 +620,10 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (!update || !update_partial_unsafe)
 		cmd->handles_missing_pvs = 1;
 
-	return process_each_vg(cmd, argc, argv, update ? READ_FOR_UPDATE : 0,
+	flags = ENABLE_ALL_VGNAMES;
+	if (update)
+		flags |= READ_FOR_UPDATE;
+
+	return process_each_vg(cmd, argc, argv, flags,
 			       NULL, &vgchange_single);
 }
diff --git a/tools/vgck.c b/tools/vgck.c
index bdfee05..3583ebb 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -42,6 +42,6 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
-	return process_each_vg(cmd, argc, argv, 0, NULL,
+	return process_each_vg(cmd, argc, argv, ENABLE_ALL_VGNAMES, NULL,
 			       &vgck_single);
 }
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index afc92fe..6efbab7 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -88,7 +88,7 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 	}
 **********/
 
-	return process_each_vg(cmd, argc, argv, 0, NULL,
+	return process_each_vg(cmd, argc, argv, ENABLE_ALL_VGNAMES, NULL,
 			       vgdisplay_single);
 
 /******** FIXME Need to count number processed
diff --git a/tools/vgexport.c b/tools/vgexport.c
index c573619..26eb4fb 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -54,6 +54,8 @@ bad:
 
 int vgexport(struct cmd_context *cmd, int argc, char **argv)
 {
+	uint32_t flags = READ_FOR_UPDATE;
+
 	if (!argc && !arg_count(cmd, all_ARG)) {
 		log_error("Please supply volume groups or use -a for all.");
 		return ECMD_FAILED;
@@ -64,6 +66,9 @@ int vgexport(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
+	if (!argc && arg_count(cmd, all_ARG))
+		flags |= ENABLE_ALL_VGNAMES;
+
+	return process_each_vg(cmd, argc, argv, flags, NULL,
 			       &vgexport_single);
 }
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 99124ef..b960960 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -60,7 +60,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 
 	log_print_unless_silent("Reading all physical volumes.  This may take a while...");
 
-	maxret = process_each_vg(cmd, argc, argv, 0, NULL,
+	maxret = process_each_vg(cmd, argc, argv, ENABLE_ALL_VGNAMES, NULL,
 				 &vgscan_single);
 
 	if (arg_count(cmd, mknodes_ARG)) {
-- 
1.8.1.rc1.5.g7e0651a



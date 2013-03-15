From: David Teigland <teigland@redhat.com>
Date: Fri, 15 Mar 2013 14:49:23 -0500
Subject: [PATCH 4/5] toollib: remove replicator wrappers in lv processing
Message-ID: <1363376964-23100-5-git-send-email-teigland@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The cmd_vg wrappers were not serving any purpose
because a single vg was only ever added to the
cmd_vg set.  Remove the cmd_vg layer in
process_each_lv to simplify the code.
---
 tools/toollib.c   | 77 ++++++++++---------------------------------------------
 tools/toollib.h   |  1 -
 tools/vgdisplay.c |  2 +-
 3 files changed, 15 insertions(+), 65 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 8d6ba2e..b593b93 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -82,7 +82,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
-			  struct dm_list *failed_lvnames,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv)
 {
@@ -93,7 +92,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 	unsigned tags_supplied = 0;
 	unsigned lvargs_supplied = 0;
 	unsigned lvargs_matched = 0;
-	char *lv_name;
 	struct lv_list *lvl;
 
 	if (!vg_check_status(vg, EXPORTED_VG))
@@ -161,18 +159,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (!process_lv)
 			continue;
 
-		lvl->lv->vg->cmd_missing_vgs = 0;
 		ret = process_single_lv(cmd, lvl->lv, handle);
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
+
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught()) {
@@ -1686,38 +1674,17 @@ static int process_lv_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 				   void *handle,
 				   process_single_lv_fn_t process_single_lv)
 {
+	struct volume_group *vg;
 	struct str_list *sl, *sll;
-	struct cmd_vg *cvl_vg;
 	struct dm_list *tags_arg;
-	struct dm_list cmd_vgs;
-	struct dm_list failed_lvnames;
 	struct dm_list lvnames;
 	const char *vgname;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
-	dm_list_init(&failed_lvnames);
-
 	dm_list_iterate_items(sl, vg_name_list) {
 		vgname = sl->str;
 
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
 		/*
 		 * arg_lvnames contains some elements that are just "vgname"
 		 * which means process all lvs in the vg.  Other elements
@@ -1744,44 +1711,28 @@ static int process_lv_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 				if (!str_list_add(cmd->mem, &lvnames,
 						  dm_pool_strdup(cmd->mem, lv_name + 1))) {
 					log_error("strlist allocation failed");
-					free_cmd_vgs(&cmd_vgs);
 					return ECMD_FAILED;
 				}
 			}
 		}
 
-		while (!sigint_caught()) {
-			ret = process_each_lv_in_vg(cmd, cvl_vg->vg, &lvnames,
-						    tags_arg, &failed_lvnames,
-						    handle, process_single_lv);
-			if (ret != ECMD_PROCESSED) {
-				stack;
-				break;
-			}
+		vg = vg_read(cmd, vgname, NULL, flags);
+		if (vg_read_error(vg)) {
+			ret_max = ECMD_FAILED;
+			release_vg(vg);
+			stack;
+			continue;
+		}
 
-			if (dm_list_empty(&failed_lvnames))
-				break;
+		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
+					    handle, process_single_lv);
 
-			/* Try again with failed LVs in this VG */
-			dm_list_init(&lvnames);
-			dm_list_splice(&lvnames, &failed_lvnames);
+		unlock_and_release_vg(cmd, vg, vgname);
 
-			free_cmd_vgs(&cmd_vgs);
-			if (!cmd_vg_read(cmd, &cmd_vgs)) {
-				stack;
-				ret = ECMD_FAILED; /* break */
-				break;
-			}
-		}
 		if (ret > ret_max)
 			ret_max = ret;
-
-		free_cmd_vgs(&cmd_vgs);
-		/* FIXME: logic for breaking command is not consistent */
-		if (sigint_caught()) {
-			stack;
-			return ECMD_FAILED;
-		}
+		if (sigint_caught())
+			break;
 	}
 
 	return ret_max;
diff --git a/tools/toollib.h b/tools/toollib.h
index 2ca7951..e71b08a 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -78,7 +78,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
-			  struct dm_list *failed_lvnames,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv);
 
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 6efbab7..e03118a 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -37,7 +37,7 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 	if (arg_count(cmd, verbose_ARG)) {
 		vgdisplay_extents(vg);
 
-		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL, NULL,
+		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
 				      (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");
-- 
1.8.1.rc1.5.g7e0651a



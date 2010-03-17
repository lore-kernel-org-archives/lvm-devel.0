From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 14:47:05 +0100
Subject: [PATCH 12/25] Replicator: use str_list for process_each_lv_in_vg
In-Reply-To: <cover.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
Message-ID: <0cd3d2066bf9d7380c50dac4ce66e76b0d8de3ec.1268833246.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As for _process_one_vg() we need similar retry loop for
process_each_lv_in_vg(). This patch tries to collect missed LVs and
then reopens collected VGs and process only selected LVs again.

Patch does not add any extra repeated invocations if there is not
missing VG during LV processing.

cmd_context is extended to avoid API change with vgs_lvs_retry list.
FIXME: modify process_each_lv_in_vg() API to avoid this change

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.c |    1 +
 lib/commands/toolcontext.h |    2 +
 tools/toollib.c            |   61 ++++++++++++++++++++++++++++++++++++-------
 3 files changed, 54 insertions(+), 10 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 118f09c..b61f37a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1109,6 +1109,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	dm_list_init(&cmd->segtypes);
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
+	dm_list_init(&cmd->vgs_lvs_retry);
 
 	/* FIXME Make this configurable? */
 	reset_lvm_errno(1);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index eac5721..a72d76d 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -96,6 +96,8 @@ struct cmd_context {
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
 	char sysfs_dir[PATH_MAX];
+
+	struct dm_list vgs_lvs_retry;	/* Retry LVs with more VGs */
 };
 
 /*
diff --git a/tools/toollib.c b/tools/toollib.c
index 066fbfd..1cff219 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -118,6 +118,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		process_all = 1;
 	}
 
+	dm_list_init(&cmd->vgs_lvs_retry);
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
@@ -147,7 +148,17 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (!process_lv)
 			continue;
 
+		lvl->lv->vg->missing_vgs = 0;
 		ret = process_single(cmd, lvl->lv, handle);
+		if (lvl->lv->vg->missing_vgs) {
+			if (!str_list_add(cmd->mem, &cmd->vgs_lvs_retry,
+					  dm_pool_strdup(cmd->mem,
+							 lvl->lv->name))) {
+				log_error("Allocation failed for str_list.");
+				return ECMD_FAILED;
+			}
+			ret = 0;
+		}
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -175,8 +186,9 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 	struct dm_list *tags_arg;
 	struct dm_list *vgnames;	/* VGs to process */
-	struct str_list *sll, *strl;
-	struct volume_group *vg;
+	struct str_list *sll, *strl, *sllt;
+	struct vg_name_list *vnl_vg;
+	struct dm_list vgs_list;
 	struct dm_list tags, lvnames;
 	struct dm_list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
 	char *vglv;
@@ -281,13 +293,17 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		}
 	}
 
-	vg = NULL;
 	dm_list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
-		vg = vg_read(cmd, vgname, NULL, flags);
+		dm_list_init(&vgs_list);
+		if (!(vnl_vg = vg_name_list_add(cmd->mem, &vgs_list,
+						vgname, NULL, flags))) {
+			stack;
+			return ECMD_FAILED;
+		}
 
-		if (vg_read_error(vg)) {
-			vg_release(vg);
+		if (!vg_name_list_read(cmd, &vgs_list, vnl_vg)) {
+			vg_name_list_release(&vgs_list,vnl_vg);
 			if (ret_max < ECMD_FAILED) {
 				log_error("Skipping volume group %s", vgname);
 				ret_max = ECMD_FAILED;
@@ -313,17 +329,42 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 						  dm_pool_strdup(cmd->mem,
 							      lv_name + 1))) {
 					log_error("strlist allocation failed");
-					unlock_and_release_vg(cmd, vg, vgname);
+					vg_name_list_release(&vgs_list,vnl_vg);
 					return ECMD_FAILED;
 				}
 			}
 		}
 
-		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
-					    handle, process_single);
-		unlock_and_release_vg(cmd, vg, vgname);
+		ret = process_each_lv_in_vg(cmd, vnl_vg->vg, &lvnames,
+					    tags_arg, handle, process_single);
 		if (ret > ret_max)
 			ret_max = ret;
+
+		while (vnl_vg->vg && vnl_vg->vg->missing_vgs &&
+		       !sigint_caught() &&
+		       !dm_list_empty(&cmd->vgs_lvs_retry)) {
+			/*
+			 * Try again with missed LVs in this VG
+			 * Move retry list to list of processed LVs
+			 */
+			dm_list_init(&lvnames);
+			dm_list_iterate_items_safe(sll, sllt,
+						   &cmd->vgs_lvs_retry)
+				dm_list_move(&lvnames, &sll->list);
+
+			vg_name_list_release(&vgs_list, vnl_vg);
+			if (!vg_name_list_read(cmd, &vgs_list, vnl_vg))
+				ret = ECMD_FAILED; /* empty retry list breaks loop */
+			else
+				ret = process_each_lv_in_vg(cmd, vnl_vg->vg,
+							    &lvnames,
+							    tags_arg, handle,
+							    process_single);
+			if (ret > ret_max)
+				ret_max = ret;
+		}
+
+		vg_name_list_release(&vgs_list, vnl_vg);
 		if (sigint_caught())
 			break;
 	}
-- 
1.7.0.1



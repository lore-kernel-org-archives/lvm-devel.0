From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Apr 2010 14:57:42 +0200
Subject: [PATCH 14/23] Replicator: use cmd_vg for process_each_lv_in_vg()
In-Reply-To: <cover.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
Message-ID: <e09508bb663543cc061398fa2c041d585fdcf51f.1272457502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-ID: <20100428125742.DlxHm8VEE0cJgnaAP143lx5tBH6EGsijfyZOoWZJZrE@z>

As for _process_one_vg() we need similar retry loop for
process_each_lv_in_vg(). This patch retries to process
failed LVs with reopened VGs.

Patch does not add any extra repeated invocations if there is not
found any missing VG during LV processing.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |   45 ++++++++++++++++++++++++++++++++++++---------
 1 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index d5d7fc6..83cca3b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -158,6 +158,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (!process_lv)
 			continue;
 
+		lvl->lv->vg->cmd_missing_vgs = 0;
 		ret = process_single_lv(cmd, lvl->lv, handle);
 		if (ret != ECMD_PROCESSED && failed_lvnames) {
 			if (!str_list_add(cmd->mem, failed_lvnames,
@@ -166,6 +167,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 				log_error("Allocation failed for str_list.");
 				return ECMD_FAILED;
 			}
+			if (lvl->lv->vg->cmd_missing_vgs)
+				ret = ECMD_PROCESSED;
 		}
 		if (ret > ret_max)
 			ret_max = ret;
@@ -193,7 +196,9 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 	struct dm_list *tags_arg;
 	struct dm_list *vgnames;	/* VGs to process */
 	struct str_list *sll, *strl;
-	struct volume_group *vg;
+	struct cmd_vg *cvl_vg;
+	struct dm_list cmd_vgs;
+	struct dm_list failed_lvnames;
 	struct dm_list tags, lvnames;
 	struct dm_list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
 	char *vglv;
@@ -203,6 +208,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 	dm_list_init(&tags);
 	dm_list_init(&arg_lvnames);
+	dm_list_init(&failed_lvnames);
 
 	if (argc) {
 		struct dm_list arg_vgnames;
@@ -298,13 +304,17 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		}
 	}
 
-	vg = NULL;
 	dm_list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
-		vg = vg_read(cmd, vgname, NULL, flags);
+		dm_list_init(&cmd_vgs);
+		if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs,
+					  vgname, NULL, flags))) {
+			stack;
+			return ECMD_FAILED;
+		}
 
-		if (vg_read_error(vg)) {
-			vg_release(vg);
+		if (!cmd_vg_read(cmd, &cmd_vgs)) {
+			cmd_vg_release(&cmd_vgs);
 			if (ret_max < ECMD_FAILED) {
 				log_error("Skipping volume group %s", vgname);
 				ret_max = ECMD_FAILED;
@@ -330,17 +340,34 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 						  dm_pool_strdup(cmd->mem,
 								 lv_name + 1))) {
 					log_error("strlist allocation failed");
-					unlock_and_release_vg(cmd, vg, vgname);
+					cmd_vg_release(&cmd_vgs);
 					return ECMD_FAILED;
 				}
 			}
 		}
 
-		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
-					    NULL, handle, process_single_lv);
-		unlock_and_release_vg(cmd, vg, vgname);
+		while (!sigint_caught()) {
+			ret = process_each_lv_in_vg(cmd, cvl_vg->vg, &lvnames,
+						    tags_arg, &failed_lvnames,
+						    handle, process_single_lv);
+			if (ret != ECMD_PROCESSED ||
+			    dm_list_empty(&failed_lvnames))
+				break;
+
+			/* Try again with failed LVs in this VG */
+			dm_list_init(&lvnames);
+			dm_list_splice(&lvnames, &failed_lvnames);
+
+			cmd_vg_release(&cmd_vgs);
+			if (!cmd_vg_read(cmd, &cmd_vgs)) {
+				ret = ECMD_FAILED; /* break */
+				break;
+			}
+		}
 		if (ret > ret_max)
 			ret_max = ret;
+
+		cmd_vg_release(&cmd_vgs);
 		if (sigint_caught())
 			return ECMD_FAILED;
 	}
-- 
1.7.0.1



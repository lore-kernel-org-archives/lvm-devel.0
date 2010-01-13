From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:42:11 +0100
Subject: [PATCH 07/18] Replicator: use str_list for process_each_lv_in_vg
In-Reply-To: <cover.1263389894.git.zkabelac@redhat.com>
References: <cover.1263389894.git.zkabelac@redhat.com>
Message-ID: <807c525f475978c69cfb96ada998ccd31f680463.1263389894.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As for _process_one_vg() we need similar retry loop for
process_each_lv_in_vg(). This patch tries to collect missed LVs and
then reopens collected VGs and process only selected LVs again.

Patch does not add any extra repeated invocations if there is no missed VG
during LV processing.

cmd_context is extended to avoid API change with vgs_lvs_retry list.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.c |    1 +
 lib/commands/toolcontext.h |    1 +
 tools/toollib.c            |   74 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 74 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 8af765e..e0ffcd1 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1103,6 +1103,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
 	dm_list_init(&cmd->vgs_list);
+	dm_list_init(&cmd->vgs_lvs_retry);
 
 	/* FIXME Make this configurable? */
 	reset_lvm_errno(1);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 0fe8eac..c7333f6 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -62,6 +62,7 @@ struct cmd_context {
 	struct dm_list formats;	/* Available formats */
 	struct dm_list segtypes;	/* Available segment types */
 	struct dm_list vgs_list;	/* Required read-only VGs */
+	struct dm_list vgs_lvs_retry;	/* Retry LVs with more VGs */
 	int vgs_missed;			/* Missed VGs */
 	const char *hostname;
 	const char *kernel_vsn;
diff --git a/tools/toollib.c b/tools/toollib.c
index 343b417..6243600 100644
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
 
+		cmd->vgs_missed = 0;
 		ret = process_single(cmd, lvl->lv, handle);
+		if (cmd->vgs_missed) {
+			if (!str_list_add(cmd->mem, &cmd->vgs_lvs_retry,
+					  dm_pool_strdup(cmd->mem,
+							 lvl->lv->name))) {
+				log_error("Allocation failed for str_list .");
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
+	struct volume_group *vg, *rvg;
+	struct vg_name_list *vnl;
 	struct dm_list tags, lvnames;
 	struct dm_list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
 	char *vglv;
@@ -321,11 +333,69 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 			}
 		}
 
+		dm_list_init(&cmd->vgs_list);
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
 					    handle, process_single);
 		unlock_and_release_vg(cmd, vg, vgname);
 		if (ret > ret_max)
 			ret_max = ret;
+
+		while (!sigint_caught() &&
+		       !dm_list_empty(&cmd->vgs_lvs_retry)) {
+			/*
+			 * Try again with missed LVs in this VG
+			 * Use retry list as list of LVs to be processed
+			 * CHECKME: maybe add support dm_list_splice()
+			 */
+			dm_list_init(&lvnames);
+			dm_list_iterate_items_safe(sll, sllt,
+						   &cmd->vgs_lvs_retry)
+				dm_list_move(&lvnames, &sll->list);
+
+			if (!vg_name_list_add(cmd->mem, &cmd->vgs_list,
+					      vgname)) {
+				stack;
+				return ECMD_FAILED;
+			}
+
+			vg = NULL;
+			dm_list_iterate_items(vnl, &cmd->vgs_list) {
+				if (!vg && strcmp(vnl->name, vgname) == 0)
+					rvg = vg = vg_read(cmd, vgname,
+							   NULL, flags);
+				else
+					/*
+					 * CHECKME: Use different flags
+					 *          for remote vg ??
+					 */
+					rvg = vg_read(cmd, vnl->name,
+						      NULL, flags);
+
+				if (vg_read_error(rvg)) {
+					vg_release(rvg);
+					log_error("Skipping volume group %s.",
+						  vnl->name);
+					vg = NULL;
+					break;
+				}
+				vnl->vg = rvg; /* Only correctly opened */
+			}
+
+			ret = (!vg) ? ECMD_FAILED :
+				process_each_lv_in_vg(cmd, vg, &lvnames,
+						      tags_arg, handle,
+						      process_single);
+
+			dm_list_iterate_back_items(vnl, &cmd->vgs_list)
+				if (vnl->vg) {
+					unlock_and_release_vg(cmd, vnl->vg,
+							      vnl->name);
+					vnl->vg = NULL;
+				}
+			if (ret > ret_max)
+				ret_max = ret;
+		}
+
 		if (sigint_caught())
 			break;
 	}
-- 
1.6.6



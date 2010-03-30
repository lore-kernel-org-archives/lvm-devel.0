From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Mar 2010 17:17:14 +0200
Subject: [PATCH 13/22] Replicator: use str_list for process_each_lv_in_vg
In-Reply-To: <cover.1269961680.git.zkabelac@redhat.com>
References: <cover.1269961680.git.zkabelac@redhat.com>
Message-ID: <21f7d8e56b7453f174ce8b2848e420c8283dc898.1269961680.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As for _process_one_vg() we need similar retry loop for
process_each_lv_in_vg(). This patch tries to collect missed LVs and
then reopens collected VGs and process only selected LVs again.

Patch does not add any extra repeated invocations if there is not
a missing VG during LV processing.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |   47 +++++++++++++++++++++++++++++++++++++----------
 1 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 2bea696..1ba1e0e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -151,6 +151,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (!process_lv)
 			continue;
 
+		lvl->lv->vg->missing_vgs = 0;
 		ret = process_single(cmd, lvl->lv, handle);
 		if (ret != ECMD_PROCESSED && failed_lvs) {
 			if (!str_list_add(cmd->mem, failed_lvs,
@@ -159,6 +160,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 				log_error("Allocation failed for str_list.");
 				return ECMD_FAILED;
 			}
+			if (lvl->lv->vg->missing_vgs)
+				ret = ECMD_PROCESSED;
 		}
 		if (ret > ret_max)
 			ret_max = ret;
@@ -188,7 +191,9 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 	struct dm_list *tags_arg;
 	struct dm_list *vgnames;	/* VGs to process */
 	struct str_list *sll, *strl;
-	struct volume_group *vg;
+	struct vg_name_list *vnl_vg;
+	struct dm_list vgs_list;
+	struct dm_list failed_lvs;
 	struct dm_list tags, lvnames;
 	struct dm_list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
 	char *vglv;
@@ -198,6 +203,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 	dm_list_init(&tags);
 	dm_list_init(&arg_lvnames);
+	dm_list_init(&failed_lvs);
 
 	if (argc) {
 		struct dm_list arg_vgnames;
@@ -293,13 +299,17 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
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
+			vg_name_list_release(&vgs_list, vnl_vg);
 			if (ret_max < ECMD_FAILED) {
 				log_error("Skipping volume group %s", vgname);
 				ret_max = ECMD_FAILED;
@@ -325,19 +335,36 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
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
-					    NULL, handle, process_single);
-		unlock_and_release_vg(cmd, vg, vgname);
+		while (!sigint_caught()) {
+			ret = process_each_lv_in_vg(cmd, vnl_vg->vg, &lvnames,
+						    tags_arg, &failed_lvs,
+						    handle, process_single);
+			if (ret != ECMD_PROCESSED ||
+			    dm_list_empty(&failed_lvs))
+				break;
+
+			/* Try again with failed LVs in this VG */
+			dm_list_init(&lvnames);
+			dm_list_splice(&failed_lvs, &lvnames);
+
+			vg_name_list_release(&vgs_list, vnl_vg);
+			if (!vg_name_list_read(cmd, &vgs_list, vnl_vg)) {
+				ret = ECMD_FAILED; /* break */
+				break;
+			}
+		}
 		if (ret > ret_max)
 			ret_max = ret;
+
+		vg_name_list_release(&vgs_list, vnl_vg);
 		if (sigint_caught())
-			break;
+			return ECMD_FAILED;
 	}
 
 	return ret_max;
-- 
1.7.0.1



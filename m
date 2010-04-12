From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 12 Apr 2010 17:21:30 +0200
Subject: [PATCH 02/22] API change for args of process_each_lv_in_vg()
In-Reply-To: <cover.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
Message-ID: <a8d5213653f20de8cc203ef59651c9ea912dd26b.1271085009.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch adds failed_lvs to the list of parameters for process_each_lv_in_vg().
If the list is not NULL it will be filled with lv_names of failing LVs
during function execution.

Application could later reiterate only on failed LVs.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c   |   14 +++++++++++++-
 tools/toollib.h   |    1 +
 tools/vgdisplay.c |    2 +-
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 52ea4a6..c31315c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -86,6 +86,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
+			  struct dm_list *failed_lvs,
 			  void *handle,
 			  process_single_lv_fn_t process_single)
 {
@@ -99,6 +100,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 
 	struct lv_list *lvl;
 
+	if (failed_lvs)
+		dm_list_init(failed_lvs);
+
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
 
@@ -148,6 +152,14 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			continue;
 
 		ret = process_single(cmd, lvl->lv, handle);
+		if (ret != ECMD_PROCESSED && failed_lvs) {
+			if (!str_list_add(cmd->mem, failed_lvs,
+					  dm_pool_strdup(cmd->mem,
+							 lvl->lv->name))) {
+				log_error("Allocation failed for str_list.");
+				return ECMD_FAILED;
+			}
+		}
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -320,7 +332,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		}
 
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
-					    handle, process_single);
+					    NULL, handle, process_single);
 		unlock_and_release_vg(cmd, vg, vgname);
 		if (ret > ret_max)
 			ret_max = ret;
diff --git a/tools/toollib.h b/tools/toollib.h
index 0ea7eba..8f22cc4 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -79,6 +79,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
+			  struct dm_list *failed_lvs,
 			  void *handle,
 			  process_single_lv_fn_t process_single);
 
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 29bc7f1..954e456 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -37,7 +37,7 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 	if (arg_count(cmd, verbose_ARG)) {
 		vgdisplay_extents(vg);
 
-		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
+		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL, NULL,
 				      (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");
-- 
1.7.0.1



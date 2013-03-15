From: David Teigland <teigland@redhat.com>
Date: Fri, 15 Mar 2013 14:49:22 -0500
Subject: [PATCH 3/5] toollib: remove replicator wrappers in vg processing
Message-ID: <1363376964-23100-4-git-send-email-teigland@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The cmd_vg wrappers were not serving any purpose
because a single vg was only ever added to the
cmd_vg set.  Remove the cmd_vg layer in
process_each_vg to simplify the code.

Pull the previous _process_one_vg into the calling
function and clarify some of the logic.
---
 tools/toollib.c | 97 ++++++++++++++++++++++++---------------------------------
 1 file changed, 41 insertions(+), 56 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index e38e20c..8d6ba2e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -274,58 +274,6 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 	return ret_max;
 }
 
-static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
-			   struct dm_list *tags, struct dm_list *arg_vgnames,
-			   uint32_t flags, void *handle, int ret_max,
-			   process_single_vg_fn_t process_single_vg)
-{
-	struct dm_list cmd_vgs;
-	struct cmd_vg *cvl_vg;
-	int ret = 0;
-
-	log_verbose("Finding volume group \"%s\"", vg_name);
-
-	dm_list_init(&cmd_vgs);
-	if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs, vg_name, NULL, flags)))
-		return_0;
-
-	for (;;) {
-		/* FIXME: consistent handling of command break */
-		if (sigint_caught()) {
-			ret = ECMD_FAILED;
-			break;
-		}
-		if (!cmd_vg_read(cmd, &cmd_vgs))
-			/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
-			if (vg_read_error(cvl_vg->vg) &&
-			    (!((flags & READ_ALLOW_INCONSISTENT) &&
-			       (vg_read_error(cvl_vg->vg) == FAILED_INCONSISTENT)))) {
-				ret = ECMD_FAILED;
-				break;
-			}
-
-		if (!dm_list_empty(tags) &&
-		    /* Only process if a tag matches or it's on arg_vgnames */
-		    !str_list_match_item(arg_vgnames, vg_name) &&
-		    !str_list_match_list(tags, &cvl_vg->vg->tags, NULL))
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
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  const struct dm_list *tags, void *handle,
 			  process_single_pv_fn_t process_single_pv)
@@ -1530,17 +1478,54 @@ static int process_vg_name_list(struct cmd_context *cmd, uint32_t flags,
 				void *handle,
 				process_single_vg_fn_t process_single_vg)
 {
+	struct volume_group *vg;
 	struct str_list *sl;
 	const char *vgname;
 	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+	int process_all = 0;
+	int process_vg;
+
+	if (dm_list_empty(arg_vgnames) && dm_list_empty(arg_tags))
+		process_all = 1;
 
 	dm_list_iterate_items(sl, vg_name_list) {
 		vgname = sl->str;
-		ret_max = _process_one_vg(cmd, vgname,
-					  arg_tags, arg_vgnames,
-					  flags, handle, ret_max,
-					  process_single_vg);
 
+		vg = vg_read(cmd, vgname, NULL, flags);
+		if (vg_read_error(vg)) {
+			if (!((flags & READ_ALLOW_INCONSISTENT) &&
+			     (vg_read_error(vg) == FAILED_INCONSISTENT))) {
+				ret_max = ECMD_FAILED;
+				release_vg(vg);
+				stack;
+				continue;
+			}
+		}
+
+		process_vg = 0;
+
+		if (process_all)
+			process_vg = 1;
+
+		if (!process_vg && !dm_list_empty(arg_vgnames) &&
+		    str_list_match_item(arg_vgnames, vgname))
+			process_vg = 1;
+
+		if (!process_vg && !dm_list_empty(arg_tags) &&
+		    str_list_match_list(arg_tags, &vg->tags, NULL))
+			process_vg = 1;
+
+		if (process_vg)
+			ret = process_single_vg(cmd, vgname, vg, handle);
+
+		if (vg_read_error(vg))
+			release_vg(vg);
+		else
+			unlock_and_release_vg(cmd, vg, vgname);
+
+		if (ret > ret_max)
+			ret_max = ret;
 		if (sigint_caught())
 			break;
 	}
-- 
1.8.1.rc1.5.g7e0651a



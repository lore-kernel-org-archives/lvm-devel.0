From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Apr 2010 14:34:28 +0200
Subject: [PATCH 13/23] Replicator: use cmd_vg list for _process_one_vg()
In-Reply-To: <cover.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
Message-ID: <71d0893d16c8cb68dd53dd3b0d1751633f1b9bc8.1272457502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch modifes behavior of _process_one_vg().

In the first pass vg_read() collect for replicator sorted list of
additional VGs during lock_vol().
If any VG needed by a replicator is not yet opened then next iteration
loop is taken with all collected VGs.

Flag vg->cmd_missing_vgs detects missing VGs.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |   55 ++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 9aaaa61..d5d7fc6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -433,37 +433,46 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			   uint32_t flags, void *handle, int ret_max,
 			   process_single_vg_fn_t process_single_vg)
 {
-	struct volume_group *vg;
+	struct dm_list cmd_vgs;
+	struct cmd_vg *cvl_vg;
 	int ret = 0;
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
 
-	vg = vg_read(cmd, vg_name, vgid, flags);
-	/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
-	if (vg_read_error(vg) &&
-	    !((vg_read_error(vg) == FAILED_INCONSISTENT) &&
-	      (flags & READ_ALLOW_INCONSISTENT))) {
-		ret_max = ECMD_FAILED;
-		goto_out;
-	}
+	dm_list_init(&cmd_vgs);
+	if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs, vg_name, vgid, flags)))
+		return_0;
+
+	while (!sigint_caught()) {
+		if (!cmd_vg_read(cmd, &cmd_vgs))
+			/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
+			if (vg_read_error(cvl_vg->vg) &&
+			    (!((flags & READ_ALLOW_INCONSISTENT) &&
+			       (vg_read_error(cvl_vg->vg) == FAILED_INCONSISTENT)))) {
+				ret = ECMD_FAILED;
+				break;
+			}
+
+		if (!dm_list_empty(tags) &&
+		    /* Only process if a tag matches or it's on arg_vgnames */
+		    !str_list_match_item(arg_vgnames, vg_name) &&
+		    !str_list_match_list(tags, &cvl_vg->vg->tags))
+			break;
 
-	if (!dm_list_empty(tags)) {
-		/* Only process if a tag matches or it's on arg_vgnames */
-		if (!str_list_match_item(arg_vgnames, vg_name) &&
-		    !str_list_match_list(tags, &vg->tags))
-			goto out;
+		ret = process_single_vg(cmd, vg_name, cvl_vg->vg, handle);
+
+		if (vg_read_error(cvl_vg->vg)) /* FAILED_INCONSISTENT */
+			break;
+
+		if (!cvl_vg->vg->cmd_missing_vgs)
+			break;
+
+		cmd_vg_release(&cmd_vgs);
 	}
 
-	if ((ret = process_single_vg(cmd, vg_name, vg,
-				  handle)) > ret_max)
-		ret_max = ret;
+	cmd_vg_release(&cmd_vgs);
 
-out:
-	if (vg_read_error(vg))
-		vg_release(vg);
-	else
-		unlock_and_release_vg(cmd, vg, vg_name);
-	return ret_max;
+	return (ret > ret_max) ? ret : ret_max;
 }
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-- 
1.7.0.1



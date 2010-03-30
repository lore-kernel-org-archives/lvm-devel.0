From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Mar 2010 17:17:13 +0200
Subject: [PATCH 12/22] Replicator: use vg_name_list for _process_one_vg()
In-Reply-To: <cover.1269961680.git.zkabelac@redhat.com>
References: <cover.1269961680.git.zkabelac@redhat.com>
Message-ID: <aefa6816394a419c8f38725487a0e5021f491ffd.1269961680.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch modifes behavior of _process_one_vg().

In the first pass the plain vg_read() for the given VG is used.
Replicator collects sorted list of additional VGs during lock_vol.
If any needed VG is not yet opened the next iteration loop is taken
with collected VGs.

Flag vg->missing_vgs detects missing VGs.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |   56 ++++++++++++++++++++++++++++++++----------------------
 1 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index c31315c..2bea696 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -436,37 +436,47 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 						  struct volume_group * vg,
 						  void *handle))
 {
-	struct volume_group *vg;
+	struct dm_list vgs_list;
+	struct vg_name_list *vnl_vg;
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
+	dm_list_init(&vgs_list);
+	vnl_vg = vg_name_list_add(cmd->mem, &vgs_list, vg_name, vgid, flags);
+	if (!vnl_vg)
+		return_0;
+
+	while (!sigint_caught()) {
+		if (!vg_name_list_read(cmd, &vgs_list, vnl_vg))
+			/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
+			if (vg_read_error(vnl_vg->vg) &&
+			    (!((flags & READ_ALLOW_INCONSISTENT) &&
+			       (vg_read_error(vnl_vg->vg) == FAILED_INCONSISTENT)))) {
+				ret = ECMD_FAILED;
+				break;
+			}
+
+		if (!dm_list_empty(tags) &&
+		    /* Only process if a tag matches or it's on arg_vgnames */
+		    !str_list_match_item(arg_vgnames, vg_name) &&
+		    !str_list_match_list(tags, &vnl_vg->vg->tags))
+			break;
 
-	if (!dm_list_empty(tags)) {
-		/* Only process if a tag matches or it's on arg_vgnames */
-		if (!str_list_match_item(arg_vgnames, vg_name) &&
-		    !str_list_match_list(tags, &vg->tags))
-			goto out;
+		ret = process_single(cmd, vg_name, vnl_vg->vg, handle);
+
+		if (vg_read_error(vnl_vg->vg)) /* FAILED_INCONSISTENT */
+			break;
+
+		if (!vnl_vg->vg->missing_vgs)
+			break;
+
+		vg_name_list_release(&vgs_list, vnl_vg);
 	}
 
-	if ((ret = process_single(cmd, vg_name, vg,
-				  handle)) > ret_max)
-		ret_max = ret;
+	vg_name_list_release(&vgs_list, vnl_vg);
 
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



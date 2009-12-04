From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  4 Dec 2009 15:04:49 +0100
Subject: [PATCH 10/22] Replicator: use vg_name_list for _process_one_vg()
In-Reply-To: <cover.1259934415.git.zkabelac@redhat.com>
References: <cover.1259934415.git.zkabelac@redhat.com>
Message-ID: <3e0814ee4de3d4d6c757228843b180d4b812dbdb.1259934415.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use list of sorted VG names from cmd_context structure.

Patch modifes behavior of _process_one_vg() by handling error case
from vg_read() immeditaly and not in the 'out:' path.

For the first pass plain vg_read() for the given name is used. Replicator
collects sorted list of required VG names in this run. If any of them
is not yet opened next loop is taken with alphabetically opened VGs.
VGs are released in reversed order from their open order.

Extra flag vgs_missed is used to detect state, when some of VGs are
missing.

CHECKME: flags for external VGs could be probably different.
         memory release from cmd_context list.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.c |    1 +
 lib/commands/toolcontext.h |    2 +
 tools/toollib.c            |   89 +++++++++++++++++++++++++++++++++-----------
 3 files changed, 70 insertions(+), 22 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4b68851..55cc46e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1098,6 +1098,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	dm_list_init(&cmd->segtypes);
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
+	dm_list_init(&cmd->vgs_list);
 
 	/* FIXME Make this configurable? */
 	reset_lvm_errno(1);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 2ffc86d..d01c4f7 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -60,6 +60,8 @@ struct cmd_context {
 
 	struct dm_list formats;	/* Available formats */
 	struct dm_list segtypes;	/* Available segment types */
+	struct dm_list vgs_list;	/* Required read-only VGs */
+	int vgs_missed;			/* Missed VGs */
 	const char *hostname;
 	const char *kernel_vsn;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 33daf30..bea7a98 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -426,36 +426,81 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 						  struct volume_group * vg,
 						  void *handle))
 {
-	struct volume_group *vg;
+	struct volume_group *vg, *rvg;
+	struct vg_name_list *vnl;
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
+	dm_list_init(&cmd->vgs_list);
+	if (!vg_name_list_add(cmd->mem, &cmd->vgs_list, vg_name))
+		return_0;
 
-	if (!dm_list_empty(tags)) {
-		/* Only process if a tag matches or it's on arg_vgnames */
-		if (!str_list_match_item(arg_vgnames, vg_name) &&
-		    !str_list_match_list(tags, &vg->tags))
-			goto out;
-	}
+	while (!sigint_caught()) {
+		vg = NULL;
+		/* Iterate through alphabeticaly ordered list */
+		dm_list_iterate_items(vnl, &cmd->vgs_list) {
+			if (!vg && strcmp(vnl->name, vg_name) == 0)
+				rvg = vg = vg_read(cmd, vg_name, vgid, flags);
+			else /* CHECKME: use different flags for remote VG? */
+				rvg = vg_read(cmd, vnl->name, NULL, flags);
+
+			if (vg_read_error(rvg)) {
+				if ((vg != rvg) ||
+				    /* Allow FAILED_INCONSISTENT through
+				     * only for vgcfgrestore */
+				    !((flags & READ_ALLOW_INCONSISTENT) &&
+				      (vg_read_error(vg) == FAILED_INCONSISTENT))) {
+					vg_release(vg);
+					ret_max = ECMD_FAILED;
+					goto_out;
+				}
+			} else
+				vnl->vg = rvg; /* Only correctly opened */
+
+			if (rvg == vg &&
+			    !dm_list_empty(tags) &&
+			    /* Only process if a tag matches or it's on arg_vgnames */
+			    !str_list_match_item(arg_vgnames, vg_name) &&
+			    !str_list_match_list(tags, &vg->tags)) {
+				if (vg_read_error(vg))
+					vg_release(vg);
+				break;
+			}
+		}
+
+		cmd->vgs_missed = 0;
+		if ((ret = process_single(cmd, vg_name, vg,
+					  handle)) > ret_max)
+			ret_max = ret;
 
-	if ((ret = process_single(cmd, vg_name, vg,
-				  handle)) > ret_max)
-		ret_max = ret;
+		if (vg_read_error(vg)) {
+			/* Leave for inconsistent case */
+			vg_release(vg);
+			break;
+		}
+
+		if (!cmd->vgs_missed)
+			break;
 
+		/* Release opened VGs in reverse order */
+		dm_list_iterate_back_items(vnl, &cmd->vgs_list)
+			if (vnl->vg) {
+				unlock_and_release_vg(cmd, vnl->vg, vnl->name);
+				vnl->vg = NULL;
+			}
+	}
 out:
-	if (vg_read_error(vg))
-		vg_release(vg);
-	else
-		unlock_and_release_vg(cmd, vg, vg_name);
+	dm_list_iterate_back_items(vnl, &cmd->vgs_list)
+		if (vnl->vg) {
+			unlock_and_release_vg(cmd, vnl->vg, vnl->name);
+			vnl->vg = NULL;
+		}
+	/*
+	 * CHECKME: empty cmd->vgs_list?
+	 * using dm_malloc instead of dm_pool, as the list is reordered?
+	 */
+
 	return ret_max;
 }
 
-- 
1.6.5.3



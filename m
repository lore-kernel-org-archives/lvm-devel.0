From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:56:53 +0100
Subject: [PATCH 07/19] Replicator: use vg_name_list for _process_one_vg()
In-Reply-To: <cover.1265813098.git.zkabelac@redhat.com>
References: <cover.1265813098.git.zkabelac@redhat.com>
Message-ID: <ae93ebe34651e4aba68e5fe00e4e970d7917f91a.1265813098.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use the list of sorted VG names from replication_info structure
inside cmd_context structure.

Patch modifes behavior of _process_one_vg() by handling error case
from vg_read() immeditaly and not in the 'out:' path.

In the first pass the plain vg_read() for the given name is used.
Replicator collects sorted list of required VG names in this run.
If any of them is not yet opened the next loop is taken with
alphabetically opened collected VGs.

Openned VGs are released in reversed order from their open order.

Extra flag vgs_missed is used to detect state, when some of VGs are
missing.

CHECKME: flags for external VGs could be probably different.
         memory release from cmd_context list.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.c |    1 +
 lib/commands/toolcontext.h |   12 ++++++
 tools/toollib.c            |   89 +++++++++++++++++++++++++++++++++-----------
 3 files changed, 80 insertions(+), 22 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index b0f8fd4..52be49b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1102,6 +1102,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	dm_list_init(&cmd->segtypes);
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
+	dm_list_init(&cmd->rep_info.vgs_list);
 
 	/* FIXME Make this configurable? */
 	reset_lvm_errno(1);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index eac5721..2349e64 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -46,6 +46,16 @@ struct config_info {
 	char _padding[1];
 };
 
+/*
+ * FIXME  This structure is currently used for passing parameters
+ *        between tools command and activation code
+ *        this is not functional in clustered environment
+ */
+struct replicator_info {
+	struct dm_list vgs_list;	/* Required read-only VGs */
+	int vgs_missed;			/* Missed VGs */
+};
+
 struct config_tree;
 struct archive_params;
 struct backup_params;
@@ -96,6 +106,8 @@ struct cmd_context {
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
 	char sysfs_dir[PATH_MAX];
+
+	struct replicator_info rep_info;
 };
 
 /*
diff --git a/tools/toollib.c b/tools/toollib.c
index e4040f8..cb7105a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -424,36 +424,81 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
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
+	dm_list_init(&cmd->rep_info.vgs_list);
+	if (!vg_name_list_add(cmd->mem, &cmd->rep_info.vgs_list, vg_name))
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
+		dm_list_iterate_items(vnl, &cmd->rep_info.vgs_list) {
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
 
-	if ((ret = process_single(cmd, vg_name, vg,
-				  handle)) > ret_max)
-		ret_max = ret;
+		cmd->rep_info.vgs_missed = 0;
+		if ((ret = process_single(cmd, vg_name, vg,
+					  handle)) > ret_max)
+			ret_max = ret;
 
+		if (vg_read_error(vg)) {
+			/* Leave for inconsistent case */
+			vg_release(vg);
+			break;
+		}
+
+		if (!cmd->rep_info.vgs_missed)
+			break;
+
+		/* Release opened VGs in reverse order */
+		dm_list_iterate_back_items(vnl, &cmd->rep_info.vgs_list)
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
+	dm_list_iterate_back_items(vnl, &cmd->rep_info.vgs_list)
+		if (vnl->vg) {
+			unlock_and_release_vg(cmd, vnl->vg, vnl->name);
+			vnl->vg = NULL;
+		}
+	/*
+	 * CHECKME: empty cmd->rep_info.vgs_list?
+	 * using dm_malloc instead of dm_pool, as the list is reordered?
+	 */
+
 	return ret_max;
 }
 
-- 
1.6.6.1



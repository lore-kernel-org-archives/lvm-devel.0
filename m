From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Aug 2019 09:59:23 -0400
Subject: master - activation: use cmd pending mem for pending_delete
Message-ID: <201908271359.x7RDxNbe022884@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2885b7103049b11ca3e98fe0c8898df2ce5f9ac
Commit:        b2885b7103049b11ca3e98fe0c8898df2ce5f9ac
Parent:        aefd177b047eb548e63ac94c9eb442604175d3bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 27 12:18:47 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 27 15:54:42 2019 +0200

activation: use cmd pending mem for pending_delete

Since we need to preserve allocated strings across 2 separate
activation calls of '_tree_action()' we need to use other mem
pool them dm->mem - but since cmd->mem is released between
individual lvm2 locking calls, we rather introduce a new separate
mem pool just for pending deletes with easy to see life-span.
(not using 'libmem' as it would basicaly keep allocations over
the whole lifetime of clvmd)

This patch is fixing previous commmit where the memory was
improperly used after pool release.
---
 lib/activate/dev_manager.c |   31 ++++++++++++-------------------
 lib/commands/toolcontext.c |   10 ++++++++++
 lib/commands/toolcontext.h |    1 +
 3 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 74dbc60..3a6f11f 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -64,7 +64,6 @@ struct dev_manager {
 	int activation;                 /* building activation tree */
 	int suspend;			/* building suspend tree */
 	unsigned track_external_lv_deps;
-	struct dm_list pending_delete;	/* str_list of dlid(s) with pending delete */
 	unsigned track_pending_delete;
 	unsigned track_pvmove_deps;
 
@@ -1387,8 +1386,6 @@ struct dev_manager *dev_manager_create(struct cmd_context *cmd,
 
 	dm_udev_set_sync_support(cmd->current_settings.udev_sync);
 
-	dm_list_init(&dm->pending_delete);
-
 	return dm;
 
       bad:
@@ -2165,7 +2162,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
+	if (!(dlid = build_dm_uuid(dm->track_pending_delete ? dm->cmd->pending_delete_mem : dm->mem, lv, layer)))
 		return_0;
 
 	if (!_info(dm->cmd, name, dlid, 1, 0, &info, NULL, NULL))
@@ -2207,7 +2204,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (info.exists && dm->track_pending_delete) {
 		log_debug_activation("Tracking pending delete for %s (%s).",
 				     display_lvname(lv), dlid);
-		if (!str_list_add(dm->mem, &dm->pending_delete, dlid))
+		if (!str_list_add(dm->cmd->pending_delete_mem, &dm->cmd->pending_delete, dlid))
 			return_0;
 	}
 
@@ -3599,20 +3596,26 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, const
 		if (non_toplevel_tree_dlid && !strcmp(non_toplevel_tree_dlid, uuid))
 			continue;
 
-		if (!str_list_add(dm->mem, &dm->pending_delete, uuid))
+		if (!(uuid = dm_pool_strdup(dm->cmd->pending_delete_mem, uuid))) {
+			log_error("_clean_tree: Failed to duplicate uuid.");
+			return 0;
+		}
+
+		if (!str_list_add(dm->cmd->pending_delete_mem, &dm->cmd->pending_delete, uuid))
 			return_0;
 	}
 
 	/* Deactivate any tracked pending delete nodes */
-	if (!dm_list_empty(&dm->pending_delete) && !dm_get_suspended_counter()) {
+	if (!dm_list_empty(&dm->cmd->pending_delete) && !dm_get_suspended_counter()) {
 		fs_unlock();
 		dm_tree_set_cookie(root, fs_get_cookie());
-		dm_list_iterate_items(dl, &dm->pending_delete) {
+		dm_list_iterate_items(dl, &dm->cmd->pending_delete) {
 			log_debug_activation("Deleting tracked UUID %s.", dl->str);
 			if (!dm_tree_deactivate_children(root, dl->str, strlen(dl->str)))
 				return_0;
 		}
-		dm_list_init(&dm->pending_delete);
+		dm_list_init(&dm->cmd->pending_delete);
+		dm_pool_empty(dm->cmd->pending_delete_mem);
 	}
 
 	return 1;
@@ -3739,22 +3742,12 @@ out_no_root:
 int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv,
 			 struct lv_activate_opts *laopts)
 {
-	dm_list_splice(&dm->pending_delete, &lv->vg->cmd->pending_delete);
-
 	if (!_tree_action(dm, lv, laopts, ACTIVATE))
 		return_0;
 
 	if (!_tree_action(dm, lv, laopts, CLEAN))
 		return_0;
 
-	if (!dm_list_empty(&dm->pending_delete)) {
-		log_debug("Preserving %d device(s) for removal while being suspended.",
-			  dm_list_size(&dm->pending_delete));
-		if (!(str_list_dup(lv->vg->cmd->mem, &lv->vg->cmd->pending_delete,
-				   &dm->pending_delete)))
-			return_0;
-	}
-
 	return 1;
 }
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0a93553..479d499 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1492,6 +1492,8 @@ void destroy_config_context(struct cmd_context *cmd)
 		dm_pool_destroy(cmd->mem);
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
+	if (cmd->pending_delete_mem)
+		dm_pool_destroy(cmd->pending_delete_mem);
 
 	free(cmd);
 }
@@ -1520,6 +1522,9 @@ struct cmd_context *create_config_context(void)
 	if (!(cmd->mem = dm_pool_create("command", 4 * 1024)))
 		goto out;
 
+	if (!(cmd->pending_delete_mem = dm_pool_create("pending_delete", 1024)))
+		goto_out;
+
 	dm_list_init(&cmd->config_files);
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->hints);
@@ -1667,6 +1672,9 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 		goto out;
 	}
 
+	if (!(cmd->pending_delete_mem = dm_pool_create("pending_delete", 1024)))
+		goto_out;
+
 	if (!_init_lvm_conf(cmd))
 		goto_out;
 
@@ -1970,6 +1978,8 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
 
+	if (cmd->pending_delete_mem)
+		dm_pool_destroy(cmd->pending_delete_mem);
 #ifndef VALGRIND_POOL
 	if (cmd->linebuffer) {
 		/* Reset stream buffering to defaults */
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 8a20d1f..c09558a 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -240,6 +240,7 @@ struct cmd_context {
 	const char *time_format;
 	unsigned rand_seed;
 	struct dm_list pending_delete;		/* list of LVs for removal */
+	struct dm_pool *pending_delete_mem;	/* memory pool for pending deletes */
 };
 
 /*



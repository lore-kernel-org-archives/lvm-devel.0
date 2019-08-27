From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Aug 2019 09:59:49 -0400
Subject: stable-2.02 - activation: use cmd pending mem for pending_delete
Message-ID: <201908271359.x7RDxnCB022906@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad86cda4d79704dcce13d98cd9579baab56b7e7b
Commit:        ad86cda4d79704dcce13d98cd9579baab56b7e7b
Parent:        36523a398d50381f8355e719b98c3ce584b81a23
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 27 12:18:47 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 27 15:59:33 2019 +0200

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
index dd585da..dc64159 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -64,7 +64,6 @@ struct dev_manager {
 	int activation;                 /* building activation tree */
 	int suspend;			/* building suspend tree */
 	unsigned track_external_lv_deps;
-	struct dm_list pending_delete;	/* str_list of dlid(s) with pending delete */
 	unsigned track_pending_delete;
 	unsigned track_pvmove_deps;
 
@@ -1251,8 +1250,6 @@ struct dev_manager *dev_manager_create(struct cmd_context *cmd,
 
 	dm_udev_set_sync_support(cmd->current_settings.udev_sync);
 
-	dm_list_init(&dm->pending_delete);
-
 	return dm;
 
       bad:
@@ -1939,7 +1936,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
+	if (!(dlid = build_dm_uuid(dm->track_pending_delete ? dm->cmd->pending_delete_mem : dm->mem, lv, layer)))
 		return_0;
 
 	if (!_info(dm->cmd, name, dlid, 1, 0, &info, NULL, NULL))
@@ -1981,7 +1978,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (info.exists && dm->track_pending_delete) {
 		log_debug_activation("Tracking pending delete for %s (%s).",
 				     display_lvname(lv), dlid);
-		if (!str_list_add(dm->mem, &dm->pending_delete, dlid))
+		if (!str_list_add(dm->cmd->pending_delete_mem, &dm->cmd->pending_delete, dlid))
 			return_0;
 	}
 
@@ -3218,20 +3215,26 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, const
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
@@ -3358,22 +3361,12 @@ out_no_root:
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
index c90cb57..95fb343 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1761,6 +1761,8 @@ void destroy_config_context(struct cmd_context *cmd)
 		dm_pool_destroy(cmd->mem);
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
+	if (cmd->pending_delete_mem)
+		dm_pool_destroy(cmd->pending_delete_mem);
 
 	dm_free(cmd);
 }
@@ -1789,6 +1791,9 @@ struct cmd_context *create_config_context(void)
 	if (!(cmd->mem = dm_pool_create("command", 4 * 1024)))
 		goto out;
 
+	if (!(cmd->pending_delete_mem = dm_pool_create("pending_delete", 1024)))
+		goto_out;
+
 	dm_list_init(&cmd->config_files);
 	dm_list_init(&cmd->tags);
 
@@ -1937,6 +1942,9 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 		goto out;
 	}
 
+	if (!(cmd->pending_delete_mem = dm_pool_create("pending_delete", 1024)))
+		goto_out;
+
 	if (!_init_lvm_conf(cmd))
 		goto_out;
 
@@ -2264,6 +2272,8 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
 
+	if (cmd->pending_delete_mem)
+		dm_pool_destroy(cmd->pending_delete_mem);
 #ifndef VALGRIND_POOL
 	if (cmd->linebuffer) {
 		/* Reset stream buffering to defaults */
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 9c225b8..4b2a079 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -232,6 +232,7 @@ struct cmd_context {
 	const char *time_format;
 	unsigned rand_seed;
 	struct dm_list pending_delete;		/* list of LVs for removal */
+	struct dm_pool *pending_delete_mem;	/* memory pool for pending deletes */
 };
 
 /*



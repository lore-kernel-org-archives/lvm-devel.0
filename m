From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 Jan 2011 12:17:35 +0100
Subject: [PATCH 7/8] Stop calling fs_unlock() and dm_udev_wait()
In-Reply-To: <cover.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
Message-ID: <82f127caaf42958f462a16c3981527b7a925a42d.1294398815.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Stop calling fs_unlock() from lv_de/activate()

Start using internal lvm fs cookie for dm_tree.

Stop directly calling dm_udev_wait() and
dm_tree_set/get_cookie() from activate code -
it's now called through fs_unlock() function.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c    |    2 --
 lib/activate/dev_manager.c |   25 ++++++++-----------------
 2 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 174f09e..e199fbb 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1206,7 +1206,6 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	memlock_inc(cmd);
 	r = _lv_deactivate(lv);
 	memlock_dec(cmd);
-	fs_unlock();
 
 	if (!lv_info(cmd, lv, 0, &info, 1, 0) || info.exists)
 		r = 0;
@@ -1305,7 +1304,6 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (!(r = _lv_activate_lv(lv, 0)))
 		stack;
 	memlock_dec(cmd);
-	fs_unlock();
 
 	if (r && !monitor_dev_for_events(cmd, lv, 0, 1))
 		stack;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6d7d905..1fbefc4 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1622,7 +1622,6 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 	struct dm_tree_node *child;
 	char *vgname, *lvname, *layer;
 	const char *name, *uuid;
-	int r;
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!(name = dm_tree_node_get_name(child)))
@@ -1644,12 +1643,7 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 		if (non_toplevel_tree_dlid && !strcmp(non_toplevel_tree_dlid, uuid))
 			continue;
 
-		dm_tree_set_cookie(root, 0);
-		r = dm_tree_deactivate_children(root, uuid, strlen(uuid));
-		if (!dm_udev_wait(dm_tree_get_cookie(root)))
-			stack;
-
-		if (!r)
+		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid)))
 			return_0;
 	}
 
@@ -1669,9 +1663,12 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
 		log_error("Lost dependency tree root node");
-		goto out;
+		goto out_no_root;
 	}
 
+	/* Restore fs cookie */
+	dm_tree_set_cookie(root, fs_get_cookie());
+
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, origin_only ? "real" : NULL)))
 		goto_out;
 
@@ -1684,10 +1681,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 		break;
 	case DEACTIVATE:
  		/* Deactivate LV and all devices it references that nothing else has open. */
-		dm_tree_set_cookie(root, 0);
 		r = dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-		if (!dm_udev_wait(dm_tree_get_cookie(root)))
-			stack;
 		if (!r)
 			goto_out;
 		if (!_remove_lv_symlinks(dm, root))
@@ -1708,10 +1702,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
-		dm_tree_set_cookie(root, 0);
 		r = dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-		if (!dm_udev_wait(dm_tree_get_cookie(root)))
-			stack;
 		if (!r)
 			goto_out;
 
@@ -1719,10 +1710,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {
-			dm_tree_set_cookie(root, 0);
 			r = dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-			if (!dm_udev_wait(dm_tree_get_cookie(root)))
-				stack;
 			if (!r)
 				goto_out;
 			if (!_create_lv_symlinks(dm, root)) {
@@ -1740,6 +1728,9 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 	r = 1;
 
 out:
+	/* Save fs cookie for udev settle, do not wait here */
+	fs_set_cookie(dm_tree_get_cookie(root));
+out_no_root:
 	dm_tree_free(dtree);
 
 	return r;
-- 
1.7.3.4



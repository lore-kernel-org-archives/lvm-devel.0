From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:56:20 +0100
Subject: [PATCH 2/3] Stop calling fs_unlock() and dm_udev_wait()
In-Reply-To: <cover.1292496056.git.zkabelac@redhat.com>
References: <cover.1292496056.git.zkabelac@redhat.com>
Message-ID: <72f39c1bd8ababe16da15d94ced7128bbc7a6e8b.1292496056.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Stop calling fs_unlock() from lv_de/activate()

Start using internal fs cookie for dm_tree

Stop directly calling dm_udev_wait() and
dm_tree_set/get_cookie() from activate code -
it's now handled through fs_unlock function.

define HAVE_UNLOCK_FS is used for quick compare of how the perfomace
is improved when it is in use - commit will be without define and
remove fs_unlock() from lv_deactivate() and _lv_activate().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c    |    5 +++++
 lib/activate/dev_manager.c |   23 ++++++-----------------
 2 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 88cb184..8f4953b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -35,6 +35,7 @@
 #include <unistd.h>
 
 #define _skip(fmt, args...) log_very_verbose("Skipping: " fmt , ## args)
+#define HAVE_UNLOCK_FS 1
 
 int lvm1_present(struct cmd_context *cmd)
 {
@@ -1206,7 +1207,9 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	memlock_inc(cmd);
 	r = _lv_deactivate(lv);
 	memlock_dec(cmd);
+#ifndef HAVE_UNLOCK_FS
 	fs_unlock();
+#endif
 
 	if (!lv_info(cmd, lv, 0, &info, 1, 0) || info.exists)
 		r = 0;
@@ -1305,7 +1308,9 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (!(r = _lv_activate_lv(lv, 0)))
 		stack;
 	memlock_dec(cmd);
+#ifndef HAVE_UNLOCK_FS
 	fs_unlock();
+#endif
 
 	if (r && !monitor_dev_for_events(cmd, lv, 0, 1))
 		stack;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2a72bb2..0bc658b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1617,7 +1617,6 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 	struct dm_tree_node *child;
 	char *vgname, *lvname, *layer;
 	const char *name, *uuid;
-	int r;
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!(name = dm_tree_node_get_name(child)))
@@ -1639,12 +1638,7 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
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
 
@@ -1664,9 +1658,11 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
 		log_error("Lost dependency tree root node");
-		goto out;
+		goto out_no_root;
 	}
 
+	dm_tree_set_cookie(root, fs_get_cookie());
+
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, origin_only ? "real" : NULL)))
 		goto_out;
 
@@ -1679,10 +1675,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
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
@@ -1703,10 +1696,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
-		dm_tree_set_cookie(root, 0);
 		r = dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-		if (!dm_udev_wait(dm_tree_get_cookie(root)))
-			stack;
 		if (!r)
 			goto_out;
 
@@ -1714,10 +1704,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {
-			dm_tree_set_cookie(root, 0);
 			r = dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-			if (!dm_udev_wait(dm_tree_get_cookie(root)))
-				stack;
 			if (!r)
 				goto_out;
 			if (!_create_lv_symlinks(dm, root)) {
@@ -1735,6 +1722,8 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 	r = 1;
 
 out:
+	fs_set_cookie(dm_tree_get_cookie(root));
+out_no_root:
 	dm_tree_free(dtree);
 
 	return r;
-- 
1.7.3.3



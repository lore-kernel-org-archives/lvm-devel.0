From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  8 Dec 2010 13:57:51 +0100
Subject: [PATCH 5/9] Stop calling fs_unlock() and dm_udev_wait()
In-Reply-To: <cover.1291802397.git.zkabelac@redhat.com>
References: <cover.1291802397.git.zkabelac@redhat.com>
Message-ID: <1fb1776ab31cc970fcf2029c2581df3c8fb9140e.1291802397.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Stop calling fs_unlock() from lv_de/activate()

Stop directly calling dm_udev_wait() and
dm_tree_set/get_cookie() from lvm code -
it's now handled internaly by  libdm.
(in fact dm_tree_set/get_cookie is not used any more
and could have been removed - but as it's already public API
I'm not sure if we could remove it ?)

define HAVE_UNLOCK_FS is used for quick compare of how the perfomace
is improved when it's in use.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c    |    5 +++++
 lib/activate/dev_manager.c |   17 +----------------
 2 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a19d556..9372033 100644
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
index a58b7c5..3b95419 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1615,7 +1615,6 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 	struct dm_tree_node *child;
 	char *vgname, *lvname, *layer;
 	const char *name, *uuid;
-	int r;
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!(name = dm_tree_node_get_name(child)))
@@ -1637,12 +1636,7 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
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
 
@@ -1677,10 +1671,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
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
@@ -1701,10 +1692,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
-		dm_tree_set_cookie(root, 0);
 		r = dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-		if (!dm_udev_wait(dm_tree_get_cookie(root)))
-			stack;
 		if (!r)
 			goto_out;
 
@@ -1712,10 +1700,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 			dm->flush_required = 1;
 
 		if (action == ACTIVATE) {
-			dm_tree_set_cookie(root, 0);
 			r = dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
-			if (!dm_udev_wait(dm_tree_get_cookie(root)))
-				stack;
 			if (!r)
 				goto_out;
 			if (!_create_lv_symlinks(dm, root)) {
-- 
1.7.3.3



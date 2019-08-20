From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Aug 2019 06:53:24 -0400
Subject: master - activation: add synchronization point
Message-ID: <201908201053.x7KArOVf017980@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30a98e4d6710a543692d40d11428ae4baea11b7b
Commit:        30a98e4d6710a543692d40d11428ae4baea11b7b
Parent:        0bdd6d6240251996694a8581432f726e5442c4a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 16 23:49:59 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 20 12:46:11 2019 +0200

activation: add synchronization point

Resuming of 'error' table entry followed with it's dirrect removal
is now troublesame with latest udev as it may skip processing of
udev rules for already 'dropped' device nodes.

As we cannot 'synchronize' with udev while we know we have devices
in suspended state - rework 'cleanup' so it collects nodes
for removal into pending_delete list and process the list with
synchronization once we are without any suspended nodes.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   20 ++++++++++++--------
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2c1bc16..0b48e03 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Synchronize with udev when dropping snapshot.
   Add missing device synchronization point before removing pvmove node.
   Correctly set read_ahead for LVs when pvmove is finished.
   Remove unsupported OPTIONS+="event_timeout" udev rule from 11-dm-lvm.rules.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b218225..3168e88 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3579,13 +3579,6 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, const
 	const char *name, *uuid;
 	struct dm_str_list *dl;
 
-	/* Deactivate any tracked pending delete nodes */
-	dm_list_iterate_items(dl, &dm->pending_delete) {
-		log_debug_activation("Deleting tracked UUID %s.", dl->str);
-		if (!dm_tree_deactivate_children(root, dl->str, strlen(dl->str)))
-			return_0;
-	}
-
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!(name = dm_tree_node_get_name(child)))
 			continue;
@@ -3606,10 +3599,21 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, const
 		if (non_toplevel_tree_dlid && !strcmp(non_toplevel_tree_dlid, uuid))
 			continue;
 
-		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid)))
+		if (!str_list_add(dm->mem, &dm->pending_delete, uuid))
 			return_0;
 	}
 
+	/* Deactivate any tracked pending delete nodes */
+	if (!dm_list_empty(&dm->pending_delete) && !dm_get_suspended_counter()) {
+		fs_unlock();
+		dm_tree_set_cookie(root, fs_get_cookie());
+		dm_list_iterate_items(dl, &dm->pending_delete) {
+			log_debug_activation("Deleting tracked UUID %s.", dl->str);
+			if (!dm_tree_deactivate_children(root, dl->str, strlen(dl->str)))
+				return_0;
+		}
+	}
+
 	return 1;
 }
 



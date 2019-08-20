From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Aug 2019 07:02:21 -0400
Subject: stable-2.02 - activation: add synchronization point
Message-ID: <201908201102.x7KB2LaZ018472@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba629ceea194cc964a6dddb84641254776e58e16
Commit:        ba629ceea194cc964a6dddb84641254776e58e16
Parent:        e5cdb114a6aa5d211e25a0919a28968d64e7cf01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 16 23:49:59 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 20 12:59:05 2019 +0200

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
index fa8508f..549366c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.186 - 
 ================================
+  Synchronize with udev when dropping snapshot.
   Add missing device synchronization point before removing pvmove node.
   Correctly set read_ahead for LVs when pvmove is finished.
   Fix metadata writes from corrupting with large physical block size.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3e5c0a8..1dfd42b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3198,13 +3198,6 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, const
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
@@ -3225,10 +3218,21 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, const
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
 



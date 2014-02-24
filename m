From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:16:57 +0000 (UTC)
Subject: master - libdm: proper traversion of revert list
Message-ID: <20140224201657.C37CD611FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6116333ccc4969e69bfd10aa0fe64238dc7f4dab
Commit:        6116333ccc4969e69bfd10aa0fe64238dc7f4dab
Parent:        1911c61639164296d953eef6f1476a040648d5ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 24 09:36:38 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:01:59 2014 +0100

libdm: proper traversion of revert list

Deactivation of top level node has to happen,
before traversing subtree.

Swap list logic and rather append new nodes to the head
and then use normal iteration.

(in-release update)
---
 libdm/libdm-deptree.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 7fcc7ed..764074d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2625,13 +2625,16 @@ out:
 	return r;
 }
 
+/*
+ * Currently try to deactivate only nodes created during preload.
+ * New node is always attached to the front of activated_list
+ */
 static int _dm_tree_revert_activated(struct dm_tree_node *parent)
 {
 	struct dm_tree_node *child;
 
-	dm_list_iterate_back_items_gen(child, &parent->activated, activated_list) {
-		_dm_tree_revert_activated(child);
-		log_debug("Reverting preloaded %s.", child->name);
+	dm_list_iterate_items_gen(child, &parent->activated, activated_list) {
+		log_debug_activation("Reverting %s.", child->name);
 		if (!_deactivate_node(child->name, child->info.major, child->info.minor,
 				      &child->dtree->cookie, child->udev_flags, 0)) {
 			log_error("Unable to deactivate %s (%" PRIu32
@@ -2639,6 +2642,8 @@ static int _dm_tree_revert_activated(struct dm_tree_node *parent)
 				  child->info.minor);
 			return 0;
 		}
+		if (!_dm_tree_revert_activated(child))
+			return_0;
 	}
 
 	return 1;
@@ -2708,9 +2713,10 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			continue;
 		}
 
-		if (!child->info.live_table)
+		if (!child->info.live_table) {
 			/* Collect newly introduced devices for revert */
-			dm_list_add(&dnode->activated, &child->activated_list);
+			dm_list_add_h(&dnode->activated, &child->activated_list);
+		}
 
 		/* Update cached info */
 		child->info = newinfo;



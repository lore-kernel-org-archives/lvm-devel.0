From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:05 +0000 (GMT)
Subject: main - libdm: enhance tracking of activated LVs
Message-ID: <20210913103605.D1EFC3858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8ee82ed51696b63381442106cb2298c4501fb72
Commit:        a8ee82ed51696b63381442106cb2298c4501fb72
Parent:        d489445e5accf550177141bf3b95283d2821386e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 12 21:15:31 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

libdm: enhance tracking of activated LVs

Existing mechanism was not able to trace root volume issue.
Simplify the functionality by using simply using activated flag
and trace the dtree in reverse order.
---
 WHATS_NEW_DM                  |  1 +
 device_mapper/libdm-deptree.c | 50 ++++++++++++++++++-------------------------
 libdm/libdm-deptree.c         | 50 ++++++++++++++++++-------------------------
 3 files changed, 43 insertions(+), 58 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7632ae4fd..c4a22441c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.181 - 
 ===================================
+  Enhance tracking of activated devices when preloading dm tree.
   Fix bug in construction of cache table line (regression from 1.02.159).
 
 Version 1.02.179 - 11th August 2021
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 4f2d79ee1..a0f386e77 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -330,16 +330,7 @@ struct dm_tree_node {
 	dm_node_callback_fn callback;
 	void *callback_data;
 
-	/*
-	 * TODO:
-	 *	Add advanced code which tracks of send ioctls and their
-	 *	proper revert operation for more advanced recovery
-	 *	Current code serves mostly only to recovery when
-	 *	thin pool metadata check fails and command would
-	 *	have left active thin data and metadata subvolumes.
-	 */
-	struct dm_list activated;	/* Head of activated nodes for preload revert */
-	struct dm_list activated_list;	/* List of activated nodes for preload revert */
+	int activated;                  /* tracks activation during preload */
 };
 
 struct dm_tree {
@@ -374,7 +365,6 @@ struct dm_tree *dm_tree_create(void)
 	dtree->root.dtree = dtree;
 	dm_list_init(&dtree->root.uses);
 	dm_list_init(&dtree->root.used_by);
-	dm_list_init(&dtree->root.activated);
 	dtree->skip_lockfs = 0;
 	dtree->no_flush = 0;
 	dtree->mem = dmem;
@@ -559,7 +549,6 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 
 	dm_list_init(&node->uses);
 	dm_list_init(&node->used_by);
-	dm_list_init(&node->activated);
 	dm_list_init(&node->props.segs);
 
 	dev = MKDEV(info->major, info->minor);
@@ -2187,7 +2176,7 @@ static int _create_node(struct dm_tree_node *dnode, struct dm_tree_node *parent)
 	}
 
 	if (r)
-		dm_list_add_h(&parent->activated, &dnode->activated_list);
+		dnode->activated = 1;
 out:
 	dm_task_destroy(dmt);
 
@@ -3180,26 +3169,29 @@ out:
 	return r;
 }
 
-/*
- * Currently try to deactivate only nodes created during preload.
- * New node is always attached to the front of activated_list
- */
-static int _dm_tree_revert_activated(struct dm_tree_node *parent)
+/* Try to deactivate only nodes created during preload. */
+static int _dm_tree_revert_activated(struct dm_tree_node *dnode)
 {
+	void *handle = NULL;
 	struct dm_tree_node *child;
 
-	dm_list_iterate_items_gen(child, &parent->activated, activated_list) {
-		log_debug_activation("Reverting %s.", _node_name(child));
-		if (child->callback) {
-			log_debug_activation("Dropping callback for %s.", _node_name(child));
-			child->callback = NULL;
-		}
-		if (!_deactivate_node(child->name, child->info.major, child->info.minor,
-				      &child->dtree->cookie, child->udev_flags, 0)) {
-			log_error("Unable to deactivate %s.", _node_name(child));
-			return 0;
+	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
+		if (child->activated) {
+			if (child->callback) {
+				log_debug_activation("Dropping callback for %s.", _node_name(child));
+				child->callback = NULL;
+			}
+
+			log_debug_activation("Reverting %s.", _node_name(child));
+			if (!_deactivate_node(child->name, child->info.major, child->info.minor,
+					      &child->dtree->cookie, child->udev_flags, 0)) {
+				log_debug_activation("Unable to deactivate %s.", _node_name(child));
+				return 0;
+			}
 		}
-		if (!_dm_tree_revert_activated(child))
+
+		if (dm_tree_node_num_children(child, 0) &&
+		    !_dm_tree_revert_activated(child))
 			return_0;
 	}
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 881558e44..d7fb5ef13 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -292,16 +292,7 @@ struct dm_tree_node {
 	dm_node_callback_fn callback;
 	void *callback_data;
 
-	/*
-	 * TODO:
-	 *	Add advanced code which tracks of send ioctls and their
-	 *	proper revert operation for more advanced recovery
-	 *	Current code serves mostly only to recovery when
-	 *	thin pool metadata check fails and command would
-	 *	have left active thin data and metadata subvolumes.
-	 */
-	struct dm_list activated;	/* Head of activated nodes for preload revert */
-	struct dm_list activated_list;	/* List of activated nodes for preload revert */
+	int activated;                  /* tracks activation during preload */
 };
 
 struct dm_tree {
@@ -336,7 +327,6 @@ struct dm_tree *dm_tree_create(void)
 	dtree->root.dtree = dtree;
 	dm_list_init(&dtree->root.uses);
 	dm_list_init(&dtree->root.used_by);
-	dm_list_init(&dtree->root.activated);
 	dtree->skip_lockfs = 0;
 	dtree->no_flush = 0;
 	dtree->mem = dmem;
@@ -521,7 +511,6 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 
 	dm_list_init(&node->uses);
 	dm_list_init(&node->used_by);
-	dm_list_init(&node->activated);
 	dm_list_init(&node->props.segs);
 
 	dev = MKDEV(info->major, info->minor);
@@ -2036,7 +2025,7 @@ static int _create_node(struct dm_tree_node *dnode, struct dm_tree_node *parent)
 	}
 
 	if (r)
-		dm_list_add_h(&parent->activated, &dnode->activated_list);
+		dnode->activated = 1;
 out:
 	dm_task_destroy(dmt);
 
@@ -2793,26 +2782,29 @@ out:
 	return r;
 }
 
-/*
- * Currently try to deactivate only nodes created during preload.
- * New node is always attached to the front of activated_list
- */
-static int _dm_tree_revert_activated(struct dm_tree_node *parent)
+/* Try to deactivate only nodes created during preload. */
+static int _dm_tree_revert_activated(struct dm_tree_node *dnode)
 {
+	void *handle = NULL;
 	struct dm_tree_node *child;
 
-	dm_list_iterate_items_gen(child, &parent->activated, activated_list) {
-		log_debug_activation("Reverting %s.", _node_name(child));
-		if (child->callback) {
-			log_debug_activation("Dropping callback for %s.", _node_name(child));
-			child->callback = NULL;
-		}
-		if (!_deactivate_node(child->name, child->info.major, child->info.minor,
-				      &child->dtree->cookie, child->udev_flags, 0)) {
-			log_error("Unable to deactivate %s.", _node_name(child));
-			return 0;
+	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
+		if (child->activated) {
+			if (child->callback) {
+				log_debug_activation("Dropping callback for %s.", _node_name(child));
+				child->callback = NULL;
+			}
+
+			log_debug_activation("Reverting %s.", _node_name(child));
+			if (!_deactivate_node(child->name, child->info.major, child->info.minor,
+					      &child->dtree->cookie, child->udev_flags, 0)) {
+				log_debug_activation("Unable to deactivate %s.", _node_name(child));
+				return 0;
+			}
 		}
-		if (!_dm_tree_revert_activated(child))
+
+		if (dm_tree_node_num_children(child, 0) &&
+		    !_dm_tree_revert_activated(child))
 			return_0;
 	}
 



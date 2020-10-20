From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 20:34:12 +0000 (GMT)
Subject: master - dm: remove created devices on error path
Message-ID: <20201020203412.8A4773861893@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a17ec7e0baa737b45900cc4f97823c95f9dd8c56
Commit:        a17ec7e0baa737b45900cc4f97823c95f9dd8c56
Parent:        b75c2dfe1b28efae08be9c7b55e904b8b695a8cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 16 20:58:58 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 19 16:53:19 2020 +0200

dm: remove created devices on error path

DM tree keeps track of created device while preloading a device tree.
When fail occures during such preload, it will now try to remove
all created and preloaded device. This makes it easier to maintain
stacking of device, since we do not need to check in-depth for
existance of all possible created devices during the failure.
---
 WHATS_NEW_DM                  |  1 +
 device_mapper/libdm-deptree.c | 81 +++++++++++++------------------------------
 libdm/libdm-deptree.c         | 75 +++++++++++++--------------------------
 3 files changed, 51 insertions(+), 106 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2600ca308..9624c0d78 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -7,6 +7,7 @@ Version 1.02.173 - 09th August 2020
 
 Version 1.02.171 - 26th March 2020
 ==================================
+  Try to remove all created devices on dm preload tree error path.
   Fix dm_list interators with gcc 10 optimization (-ftree-pta).
   Dmeventd handles timer without looping on short intervals.
 
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index d9e1683ca..6ce956fa2 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2136,7 +2136,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	return r;
 }
 
-static int _create_node(struct dm_tree_node *dnode)
+static int _create_node(struct dm_tree_node *dnode, struct dm_tree_node *parent)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -2185,38 +2185,15 @@ static int _create_node(struct dm_tree_node *dnode)
 				  "Unable to get DM task info for %s.",
 				  dnode->name);
 	}
+
+	if (r)
+		dm_list_add_h(&parent->activated, &dnode->activated_list);
 out:
 	dm_task_destroy(dmt);
 
 	return r;
 }
 
-/*
- * _remove_node
- *
- * This function is only used to remove a DM device that has failed
- * to load any table.
- */
-static int _remove_node(struct dm_tree_node *dnode)
-{
-	if (!dnode->info.exists)
-		return 1;
-
-	if (dnode->info.live_table || dnode->info.inactive_table) {
-		log_error(INTERNAL_ERROR
-			  "_remove_node called on device with loaded table(s).");
-		return 0;
-	}
-
-	if (!_deactivate_node(dnode->name, dnode->info.major, dnode->info.minor,
-			      &dnode->dtree->cookie, dnode->udev_flags, 0)) {
-		log_error("Failed to clean-up device with no table: %s.",
-			  _node_name(dnode));
-		return 0;
-	}
-	return 1;
-}
-
 static int _build_dev_string(char *devbuf, size_t bufsize, struct dm_tree_node *node)
 {
 	if (!dm_format_dev(devbuf, bufsize, node->info.major, node->info.minor)) {
@@ -3229,6 +3206,16 @@ static int _dm_tree_revert_activated(struct dm_tree_node *parent)
 	return 1;
 }
 
+static int _dm_tree_wait_and_revert_activated(struct dm_tree_node *dnode)
+{
+	if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
+		stack;
+
+	dm_tree_set_cookie(dnode, 0);
+
+	return _dm_tree_revert_activated(dnode);
+}
+
 int dm_tree_preload_children(struct dm_tree_node *dnode,
 			     const char *uuid_prefix,
 			     size_t uuid_prefix_len)
@@ -3258,7 +3245,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 				return_0;
 
 		/* FIXME Cope if name exists with no uuid? */
-		if (!child->info.exists && !(node_created = _create_node(child)))
+		if (!child->info.exists && !(node_created = _create_node(child, dnode)))
 			return_0;
 
 		/* Propagate delayed resume from exteded child node */
@@ -3268,24 +3255,15 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		if (!child->info.inactive_table &&
 		    child->props.segment_count &&
 		    !_load_node(child)) {
+			stack;
 			/*
-			 * If the table load does not succeed, we remove the
-			 * device in the kernel that would otherwise have an
-			 * empty table.  This makes the create + load of the
-			 * device atomic.  However, if other dependencies have
-			 * already been created and loaded; this code is
-			 * insufficient to remove those - only the node
-			 * encountering the table load failure is removed.
+			 * If the table load fails, try to device in the kernel
+			 * together with other created and preloaded devices.
 			 */
-			if (node_created) {
-				if (!_remove_node(child))
-					return_0;
-				if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
-					stack;
-				dm_tree_set_cookie(dnode, 0);
-				(void) _dm_tree_revert_activated(child);
-			}
-			return_0;
+			if (!_dm_tree_wait_and_revert_activated(dnode))
+				stack;
+			r = 0;
+			continue;
 		}
 
 		/* No resume for a device without parents or with unchanged or smaller size */
@@ -3303,28 +3281,19 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 				  &child->info, &child->dtree->cookie, child->udev_flags,
 				  child->info.suspended)) {
 			log_error("Unable to resume %s.", _node_name(child));
-			/* If the device was not previously active, we might as well remove this node. */
-			if (!child->info.live_table &&
-			    !_deactivate_node(child->name, child->info.major, child->info.minor,
-					      &child->dtree->cookie, child->udev_flags, 0))
-				log_error("Unable to deactivate %s.", _node_name(child));
+			if (!_dm_tree_wait_and_revert_activated(dnode))
+				stack;
 			r = 0;
-			/* Each child is handled independently */
 			continue;
 		}
 
 		if (node_created) {
-			/* Collect newly introduced devices for revert */
-			dm_list_add_h(&dnode->activated, &child->activated_list);
-
 			/* When creating new node also check transaction_id. */
 			if (child->props.send_messages &&
 			    !_node_send_messages(child, uuid_prefix, uuid_prefix_len, 0)) {
 				stack;
-				if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
+				if (!_dm_tree_wait_and_revert_activated(dnode))
 					stack;
-				dm_tree_set_cookie(dnode, 0);
-				(void) _dm_tree_revert_activated(dnode);
 				r = 0;
 				continue;
 			}
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 59616eb3a..e784cbc9c 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1985,7 +1985,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	return r;
 }
 
-static int _create_node(struct dm_tree_node *dnode)
+static int _create_node(struct dm_tree_node *dnode, struct dm_tree_node *parent)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -2034,38 +2034,15 @@ static int _create_node(struct dm_tree_node *dnode)
 				  "Unable to get DM task info for %s.",
 				  dnode->name);
 	}
+
+	if (r)
+		dm_list_add_h(&parent->activated, &dnode->activated_list);
 out:
 	dm_task_destroy(dmt);
 
 	return r;
 }
 
-/*
- * _remove_node
- *
- * This function is only used to remove a DM device that has failed
- * to load any table.
- */
-static int _remove_node(struct dm_tree_node *dnode)
-{
-	if (!dnode->info.exists)
-		return 1;
-
-	if (dnode->info.live_table || dnode->info.inactive_table) {
-		log_error(INTERNAL_ERROR
-			  "_remove_node called on device with loaded table(s).");
-		return 0;
-	}
-
-	if (!_deactivate_node(dnode->name, dnode->info.major, dnode->info.minor,
-			      &dnode->dtree->cookie, dnode->udev_flags, 0)) {
-		log_error("Failed to clean-up device with no table: %s.",
-			  _node_name(dnode));
-		return 0;
-	}
-	return 1;
-}
-
 static int _build_dev_string(char *devbuf, size_t bufsize, struct dm_tree_node *node)
 {
 	if (!dm_format_dev(devbuf, bufsize, node->info.major, node->info.minor)) {
@@ -2846,6 +2823,16 @@ static int _dm_tree_revert_activated(struct dm_tree_node *parent)
 	return 1;
 }
 
+static int _dm_tree_wait_and_revert_activated(struct dm_tree_node *dnode)
+{
+	if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
+		stack;
+
+	dm_tree_set_cookie(dnode, 0);
+
+	return _dm_tree_revert_activated(dnode);
+}
+
 int dm_tree_preload_children(struct dm_tree_node *dnode,
 			     const char *uuid_prefix,
 			     size_t uuid_prefix_len)
@@ -2875,7 +2862,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 				return_0;
 
 		/* FIXME Cope if name exists with no uuid? */
-		if (!child->info.exists && !(node_created = _create_node(child)))
+		if (!child->info.exists && !(node_created = _create_node(child, dnode)))
 			return_0;
 
 		/* Propagate delayed resume from exteded child node */
@@ -2885,18 +2872,15 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		if (!child->info.inactive_table &&
 		    child->props.segment_count &&
 		    !_load_node(child)) {
+			stack;
 			/*
-			 * If the table load does not succeed, we remove the
-			 * device in the kernel that would otherwise have an
-			 * empty table.  This makes the create + load of the
-			 * device atomic.  However, if other dependencies have
-			 * already been created and loaded; this code is
-			 * insufficient to remove those - only the node
-			 * encountering the table load failure is removed.
+			 * If the table load fails, try to device in the kernel
+			 * together with other created and preloaded devices.
 			 */
-			if (node_created && !_remove_node(child))
-				return_0;
-			return_0;
+			if (!_dm_tree_wait_and_revert_activated(dnode))
+				stack;
+			r = 0;
+			continue;
 		}
 
 		/* No resume for a device without parents or with unchanged or smaller size */
@@ -2911,28 +2895,19 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 				  &child->info, &child->dtree->cookie, child->udev_flags,
 				  child->info.suspended)) {
 			log_error("Unable to resume %s.", _node_name(child));
-			/* If the device was not previously active, we might as well remove this node. */
-			if (!child->info.live_table &&
-			    !_deactivate_node(child->name, child->info.major, child->info.minor,
-					      &child->dtree->cookie, child->udev_flags, 0))
-				log_error("Unable to deactivate %s.", _node_name(child));
+			if (!_dm_tree_wait_and_revert_activated(dnode))
+				stack;
 			r = 0;
-			/* Each child is handled independently */
 			continue;
 		}
 
 		if (node_created) {
-			/* Collect newly introduced devices for revert */
-			dm_list_add_h(&dnode->activated, &child->activated_list);
-
 			/* When creating new node also check transaction_id. */
 			if (child->props.send_messages &&
 			    !_node_send_messages(child, uuid_prefix, uuid_prefix_len, 0)) {
 				stack;
-				if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
+				if (!_dm_tree_wait_and_revert_activated(dnode))
 					stack;
-				dm_tree_set_cookie(dnode, 0);
-				(void) _dm_tree_revert_activated(dnode);
 				r = 0;
 				continue;
 			}



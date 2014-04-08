From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:28 +0000 (UTC)
Subject: master - libdm: track implicit dependecies
Message-ID: <20140408090228.1EC7160CE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd2500e62ea66984d4c3669a4429afa459165178
Commit:        bd2500e62ea66984d4c3669a4429afa459165178
Parent:        05a421960f5770e1047cc5212d2a11deef730152
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 7 20:21:20 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:12 2014 +0200

libdm: track implicit dependecies

When the node enters dtree with implicit dependency, it
automatically has udev flags from parent node
and could not be changed later when the node has been
entered again via i.e lvm's preload tracking.

Resolve this by tracking whether the node has been
created by implicit dependency tracking or has been
entered explicitely. Implicit node could be later
upgraded by an explicit _add_dev() with proper udev_flags.

For implicit devices add special udev flags to avoid
any scan and udev rule processing if we resume such device.

Patch allows easier removing of orphan nodes.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   20 +++++++++++++++-----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4f67bc3..d6bebb1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Add tracking flag about implicitly added devices into dm_tree.
   Stop timeout thread immediately when the last worker thread is finished.
   Fix dmeventd logging with parallel wait event processing.
   Reuse _node_send_messages() for validation of transaction_id in preload.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 03ec9cb..8336249 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -263,6 +263,7 @@ struct dm_tree_node {
 	struct dm_list used_by;    	/* Nodes that use this node */
 
 	int activation_priority;	/* 0 gets activated first */
+	int implicit_deps;		/* 1 device only implicitly referenced */
 
 	uint16_t udev_flags;		/* Udev control flags */
 
@@ -1171,7 +1172,8 @@ struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *dtree, const char *name
 static struct dm_tree_node *_add_dev(struct dm_tree *dtree,
 				     struct dm_tree_node *parent,
 				     uint32_t major, uint32_t minor,
-				     uint16_t udev_flags)
+				     uint16_t udev_flags,
+				     int implicit_deps)
 {
 	struct dm_task *dmt = NULL;
 	struct dm_info info;
@@ -1191,6 +1193,10 @@ static struct dm_tree_node *_add_dev(struct dm_tree *dtree,
 						  NULL, udev_flags)))
 			goto_out;
 		new = 1;
+		node->implicit_deps = implicit_deps;
+	} else if (!implicit_deps && node->implicit_deps) {
+		node->udev_flags = udev_flags;
+		node->implicit_deps = 0;
 	}
 
 	if (!_link_tree_nodes(parent, node)) {
@@ -1213,8 +1219,12 @@ static struct dm_tree_node *_add_dev(struct dm_tree *dtree,
 
 	/* Add dependencies to tree */
 	for (i = 0; i < deps->count; i++)
+		/* Implicit devices are by default temporary */
 		if (!_add_dev(dtree, node, MAJOR(deps->device[i]),
-			      MINOR(deps->device[i]), udev_flags)) {
+			      MINOR(deps->device[i]), udev_flags |
+			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG |
+			      DM_UDEV_DISABLE_DISK_RULES_FLAG |
+			      DM_UDEV_DISABLE_OTHER_RULES_FLAG, 1)) {
 			node = NULL;
 			goto_out;
 		}
@@ -1228,13 +1238,13 @@ out:
 
 int dm_tree_add_dev(struct dm_tree *dtree, uint32_t major, uint32_t minor)
 {
-	return _add_dev(dtree, &dtree->root, major, minor, 0) ? 1 : 0;
+	return _add_dev(dtree, &dtree->root, major, minor, 0, 0) ? 1 : 0;
 }
 
 int dm_tree_add_dev_with_udev_flags(struct dm_tree *dtree, uint32_t major,
 				    uint32_t minor, uint16_t udev_flags)
 {
-	return _add_dev(dtree, &dtree->root, major, minor, udev_flags) ? 1 : 0;
+	return _add_dev(dtree, &dtree->root, major, minor, udev_flags, 0) ? 1 : 0;
 }
 
 static int _rename_node(const char *old_name, const char *new_name, uint32_t major,
@@ -3939,7 +3949,7 @@ int dm_tree_node_add_target_area(struct dm_tree_node *node,
 
 		/* FIXME Check correct macro use */
 		if (!(dev_node = _add_dev(node->dtree, node, MAJOR(info.st_rdev),
-					  MINOR(info.st_rdev), 0)))
+					  MINOR(info.st_rdev), 0, 0)))
 			return_0;
 	}
 



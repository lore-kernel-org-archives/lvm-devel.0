From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 7 Dec 2017 15:03:47 -0500
Subject: master - libdm: drop extra structure copy
Message-ID: <201712072003.vB7K3ljc005645@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=820b1b98fce4a370e9b54ffbc8cbe4b3d0e962f3
Commit:        820b1b98fce4a370e9b54ffbc8cbe4b3d0e962f3
Parent:        82ae02bc6a6788aabb10ac8a95287feea37ab88c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 7 17:47:06 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 7 21:00:39 2017 +0100

libdm: drop extra structure copy

When doing resume, directly pass location where new updated info
needs to be stored.

_resume_node() ensures the info is ONLY updated when the function
is successful and never changes it on error path.
---
 libdm/libdm-deptree.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 745fec3..6ba20a4 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1848,7 +1848,6 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	int resolvable_name_conflict, awaiting_peer_rename = 0;
 	void *handle = NULL;
 	struct dm_tree_node *child = dnode;
-	struct dm_info newinfo;
 	const char *name;
 	const char *uuid;
 	int priority;
@@ -1913,14 +1912,11 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 
 			if (!_resume_node(child->name, child->info.major, child->info.minor,
 					  child->props.read_ahead, child->props.read_ahead_flags,
-					  &newinfo, &child->dtree->cookie, child->udev_flags, child->info.suspended)) {
+					  &child->info, &child->dtree->cookie, child->udev_flags, child->info.suspended)) {
 				log_error("Unable to resume %s.", _node_name(child));
 				r = 0;
 				continue;
 			}
-
-			/* Update cached info */
-			child->info = newinfo;
 		}
 		if (awaiting_peer_rename)
 			priority--; /* redo priority level */
@@ -2814,7 +2810,6 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 	int r = 1, node_created = 0;
 	void *handle = NULL;
 	struct dm_tree_node *child;
-	struct dm_info newinfo;
 	int update_devs_flag = 0;
 
 	/* Preload children first */
@@ -2870,7 +2865,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 
 		if (!_resume_node(child->name, child->info.major, child->info.minor,
 				  child->props.read_ahead, child->props.read_ahead_flags,
-				  &newinfo, &child->dtree->cookie, child->udev_flags,
+				  &child->info, &child->dtree->cookie, child->udev_flags,
 				  child->info.suspended)) {
 			log_error("Unable to resume %s.", _node_name(child));
 			/* If the device was not previously active, we might as well remove this node. */
@@ -2883,7 +2878,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			continue;
 		}
 
-		if (!child->info.live_table) {
+		if (node_created) {
 			/* Collect newly introduced devices for revert */
 			dm_list_add_h(&dnode->activated, &child->activated_list);
 
@@ -2900,8 +2895,6 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			}
 		}
 
-		/* Update cached info */
-		child->info = newinfo;
 		/*
 		 * Prepare for immediate synchronization with udev and flush all stacked
 		 * dev node operations if requested by immediate_dev_node property. But



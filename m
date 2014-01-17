From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Jan 2014 10:01:02 +0000 (UTC)
Subject: master - libdm: preload revert after failing callback
Message-ID: <20140117100102.CA67B602FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0638d1d82e349c332ea2e7e6be96f4b1f4fc5c2e
Commit:        0638d1d82e349c332ea2e7e6be96f4b1f4fc5c2e
Parent:        d98511c717d64f111208e647e861620e310118d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 15 12:42:47 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 17 10:48:49 2014 +0100

libdm: preload revert after failing callback

Revert activated volumes if callback fails.
This is currently used only for thin_check failure support.

When thin_check detects failure in thin metadata device, it deactivate
volumes in reversed order that have been preloaded for thin pool activation.
After this change lvm command will not leave active pool subvolumes
in dm table.
---
 libdm/libdm-deptree.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index db88d9d..42bb9e7 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -271,6 +271,17 @@ struct dm_tree_node {
 	/* Callback */
 	dm_node_callback_fn callback;
 	void *callback_data;
+
+	/*
+	 * TODO:
+	 *	Add advanced code which tracks of send ioctls and their
+	 *	proper revert operation for more advanced recovery
+	 *	Current code serves mostly only to recovery when
+	 *	thin pool metadata check fails and command would
+	 *	have left active thin data and metadata subvolumes.
+	 */
+	struct dm_list activated;	/* Head of activated nodes for preload revert */
+	struct dm_list activated_list;	/* List of activated nodes for preload revert */
 };
 
 struct dm_tree {
@@ -303,6 +314,7 @@ struct dm_tree *dm_tree_create(void)
 	dtree->root.dtree = dtree;
 	dm_list_init(&dtree->root.uses);
 	dm_list_init(&dtree->root.used_by);
+	dm_list_init(&dtree->root.activated);
 	dtree->skip_lockfs = 0;
 	dtree->no_flush = 0;
 	dtree->mem = dmem;
@@ -488,6 +500,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 
 	dm_list_init(&node->uses);
 	dm_list_init(&node->used_by);
+	dm_list_init(&node->activated);
 	dm_list_init(&node->props.segs);
 
 	dev = MKDEV((dev_t)info->major, info->minor);
@@ -2537,6 +2550,25 @@ out:
 	return r;
 }
 
+static int _dm_tree_revert_activated(struct dm_tree_node *parent)
+{
+	struct dm_tree_node *child;
+
+	dm_list_iterate_back_items_gen(child, &parent->activated, activated_list) {
+		_dm_tree_revert_activated(child);
+		log_debug("Reverting preloaded %s.", child->name);
+		if (!_deactivate_node(child->name, child->info.major, child->info.minor,
+				      &child->dtree->cookie, child->udev_flags, 0)) {
+			log_error("Unable to deactivate %s (%" PRIu32
+				  ":%" PRIu32 ")", child->name, child->info.major,
+				  child->info.minor);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 int dm_tree_preload_children(struct dm_tree_node *dnode,
 			     const char *uuid_prefix,
 			     size_t uuid_prefix_len)
@@ -2601,6 +2633,10 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			continue;
 		}
 
+		if (!child->info.live_table)
+			/* Collect newly introduced devices for revert */
+			dm_list_add(&dnode->activated, &child->activated_list);
+
 		/* Update cached info */
 		child->info = newinfo;
 		/*
@@ -2621,7 +2657,11 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		if (!dnode->info.exists && dnode->callback &&
 		    !dnode->callback(dnode, DM_NODE_CALLBACK_PRELOADED,
 				     dnode->callback_data))
+		{
+			/* Try to deactivate what has been activated in preload phase */
+			(void) _dm_tree_revert_activated(dnode);
 			return_0;
+		}
 	}
 
 	return r;



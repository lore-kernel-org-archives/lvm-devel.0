From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 17:31:25 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20120302173125.20135.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 17:31:22

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Added dm_tree_node_set_callback() for preload and deactivation hooks
	
	Run users hook after preload for the node is finished,
	or after the node has been deactivated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.581&r2=1.582
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.158&r2=1.159

--- LVM2/WHATS_NEW_DM	2012/03/02 13:26:08	1.581
+++ LVM2/WHATS_NEW_DM	2012/03/02 17:31:21	1.582
@@ -1,5 +1,6 @@
 Version 1.02.73 - 
 ====================================
+  Added dm_tree_node_set_callback() for preload and deactivation hooks.
   Drop unsupported TRIM message for thin pool.
   Improve logging for fifo startup in dmeventd.
   Add few pointer validation in dmsetup.
--- LVM2/libdm/libdevmapper.h	2012/03/02 13:26:10	1.186
+++ LVM2/libdm/libdevmapper.h	2012/03/02 17:31:22	1.187
@@ -688,6 +688,20 @@
 				 uint32_t read_ahead,
 				 uint32_t read_ahead_flags);
 
+/*
+ * Set node callback hook before de/activation.
+ * Callback is called before 'activation' of node for activation tree,
+ * or 'deactivation' of node for deactivation tree.
+ */
+typedef enum {
+	DM_NODE_CALLBACK_PRELOADED,   /* Node has preload deps */
+	DM_NODE_CALLBACK_DEACTIVATED, /* Node is deactivated */
+} dm_node_callback_t;
+typedef int (*dm_node_callback_fn) (struct dm_tree_node *node,
+				    dm_node_callback_t type, void *cb_data);
+void dm_tree_node_set_callback(struct dm_tree_node *node,
+			       dm_node_callback_fn cb, void *cb_data);
+
 void dm_tree_set_cookie(struct dm_tree_node *node, uint32_t cookie);
 uint32_t dm_tree_get_cookie(struct dm_tree_node *node);
 
--- LVM2/libdm/libdm-deptree.c	2012/03/02 13:26:10	1.158
+++ LVM2/libdm/libdm-deptree.c	2012/03/02 17:31:22	1.159
@@ -263,6 +263,10 @@
 	 * Note: only direct child is allowed
 	 */
 	struct dm_tree_node *presuspend_node;
+
+	/* Callback */
+	dm_node_callback_fn callback;
+	void *callback_data;
 };
 
 struct dm_tree {
@@ -1588,6 +1592,14 @@
 		} else if (info.suspended)
 			dec_suspended();
 
+		if (child->callback &&
+		    !child->callback(child, DM_NODE_CALLBACK_DEACTIVATED,
+				     child->callback_data)) {
+			r = 0;
+			// FIXME: break tree shutdown or continue?
+			// hmm what about _node_clear_table()?
+		}
+
 		if (dm_tree_node_num_children(child, 0)) {
 			if (!_dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len, level + 1))
 				return_0;
@@ -2445,10 +2457,16 @@
 			update_devs_flag = 1;
 	}
 
-	if (update_devs_flag) {
+	if (update_devs_flag ||
+	    (!dnode->info.exists && dnode->callback)) {
 		if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
 			stack;
 		dm_tree_set_cookie(dnode, 0);
+
+		if (!dnode->info.exists && dnode->callback &&
+		    !dnode->callback(child, DM_NODE_CALLBACK_PRELOADED,
+				     dnode->callback_data))
+			return_0;
 	}
 
 	return r;
@@ -3245,3 +3263,10 @@
 
 	return 1;
 }
+
+void dm_tree_node_set_callback(struct dm_tree_node *dnode,
+			       dm_node_callback_fn cb, void *data)
+{
+	dnode->callback = cb;
+	dnode->callback_data = data;
+}



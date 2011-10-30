From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Oct 2011 22:04:58 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20111030220458.7249.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-30 22:04:57

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Thin segment transaction_id moved
	
	Add a new node flag send_messages that is used to simplify
	test when to call _node_send_messages().
	
	Add call to _node_send_messages when pool is deeper in the tree.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141

--- LVM2/libdm/libdm-deptree.c	2011/10/28 20:19:26	1.140
+++ LVM2/libdm/libdm-deptree.c	2011/10/30 22:04:57	1.141
@@ -170,6 +170,7 @@
 	struct dm_tree_node *metadata;	/* Thin_pool */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
 	struct dm_list thin_messages;	/* Thin_pool */
+	uint64_t transaction_id;	/* Thin_pool */
 	uint64_t low_water_mark;	/* Thin_pool */
 	uint32_t data_block_size;       /* Thin_pool */
 	unsigned skip_block_zeroing;	/* Thin_pool */
@@ -186,8 +187,6 @@
 	uint32_t read_ahead;
 	uint32_t read_ahead_flags;
 
-	uint64_t thin_pool_transaction_id; /* Thin_pool */
-
 	unsigned segment_count;
 	unsigned size_changed;
 	struct dm_list segs;
@@ -209,6 +208,9 @@
 	 * avoid starting the mirror resync operation too early.
 	 */
 	unsigned delay_resume_if_new;
+
+	/* Send messages for this node in preload */
+	unsigned send_messages;
 };
 
 /* Two of these used to join two nodes with uses and used_by. */
@@ -1335,8 +1337,7 @@
 	uint64_t trans_id;
 	const char *uuid;
 
-	if ((dnode == &dnode->dtree->root) || /* root has props.segs uninitialized */
-	    !dnode->info.exists || (dm_list_size(&dnode->props.segs) != 1))
+	if (!dnode->info.exists || (dm_list_size(&dnode->props.segs) != 1))
 		return 1;
 
 	seg = dm_list_item(dm_list_last(&dnode->props.segs), struct load_segment);
@@ -1352,22 +1353,28 @@
 	}
 
 	if (!_thin_pool_status_transaction_id(dnode, &trans_id))
-		return_0;
+		goto_bad;
 
-	if (trans_id == dnode->props.thin_pool_transaction_id)
+	if (trans_id == seg->transaction_id)
 		return 1; /* In sync - skip messages */
 
-	if (trans_id != (dnode->props.thin_pool_transaction_id - 1)) {
+	if (trans_id != (seg->transaction_id - 1)) {
 		log_error("Thin pool transaction_id=%" PRIu64 ", while expected: %" PRIu64 ".",
-			  trans_id, dnode->props.thin_pool_transaction_id - 1);
-		return 0; /* Nothing to send */
+			  trans_id, seg->transaction_id - 1);
+		goto bad; /* Nothing to send */
 	}
 
 	dm_list_iterate_items(tmsg, &seg->thin_messages)
 		if (!(_thin_pool_node_message(dnode, tmsg)))
-			return_0;
+			goto_bad;
 
 	return 1;
+bad:
+	/* Try to deactivate */
+	if (!(dm_tree_deactivate_children(dnode, uuid_prefix, uuid_prefix_len)))
+		log_error("Failed to deactivate %s", dnode->name);
+
+	return 0;
 }
 
 /*
@@ -2315,7 +2322,11 @@
 
 		/* Update cached info */
 		child->info = newinfo;
-
+		if (child->props.send_messages &&
+		    !(r = _node_send_messages(child, uuid_prefix, uuid_prefix_len))) {
+			stack;
+			continue;
+		}
 		/*
 		 * Prepare for immediate synchronization with udev and flush all stacked
 		 * dev node operations if requested by immediate_dev_node property. But
@@ -2325,7 +2336,9 @@
 			update_devs_flag = 1;
 	}
 
-	handle = NULL;
+	if (r && dnode->props.send_messages &&
+	    !(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len)))
+		stack;
 
 	if (update_devs_flag) {
 		if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
@@ -2875,7 +2888,8 @@
 	if (!_link_tree_nodes(node, seg->pool))
 		return_0;
 
-	node->props.thin_pool_transaction_id = transaction_id; // compare on resume
+	node->props.send_messages = 1;
+	seg->transaction_id = transaction_id;
 	seg->low_water_mark = low_water_mark;
 	seg->data_block_size = data_block_size;
 	seg->skip_block_zeroing = skip_block_zeroing;



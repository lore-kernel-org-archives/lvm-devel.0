From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Oct 2011 16:40:59 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20111019164059.31399.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-19 16:40:59

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Use generic name for message sending function
	
	Drop _thin_pool prefix for _node_send_message so it could be extended later.
	Replace current_id with trans_id name.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/libdm/libdm-deptree.c	2011/10/19 16:36:40	1.130
+++ LVM2/libdm/libdm-deptree.c	2011/10/19 16:40:59	1.131
@@ -1328,17 +1328,17 @@
 	return r;
 }
 
-static int _thin_pool_node_send_messages(struct dm_tree_node *dnode,
-					 const char *uuid_prefix,
-					 size_t uuid_prefix_len)
+static int _node_send_messages(struct dm_tree_node *dnode,
+			       const char *uuid_prefix,
+			       size_t uuid_prefix_len)
 {
 	struct load_segment *seg;
 	struct thin_message *tmsg;
-	uint64_t current_id;
+	uint64_t trans_id;
 	const char *uuid;
 
-	if ((dnode == &dnode->dtree->root) || /* root has rops.segs uninitialized */
-	    (dm_list_size(&dnode->props.segs) != 1))
+	if ((dnode == &dnode->dtree->root) || /* root has props.segs uninitialized */
+	    !dnode->info.exists || (dm_list_size(&dnode->props.segs) != 1))
 		return 1;
 
 	seg = dm_list_item(dm_list_last(&dnode->props.segs), struct load_segment);
@@ -1353,16 +1353,15 @@
 		return 1;
 	}
 
-	if (!_thin_pool_status_transaction_id(dnode, &current_id))
+	if (!_thin_pool_status_transaction_id(dnode, &trans_id))
 		return_0;
 
-	log_debug("Expecting transaction_id: %" PRIu64, dnode->props.thin_pool_transaction_id);
-	if (current_id == dnode->props.thin_pool_transaction_id)
+	if (trans_id == dnode->props.thin_pool_transaction_id)
 		return 1; /* In sync - skip messages */
 
-	if (current_id != (dnode->props.thin_pool_transaction_id - 1)) {
+	if (trans_id != (dnode->props.thin_pool_transaction_id - 1)) {
 		log_error("Thin pool transaction_id=%" PRIu64 ", while expected: %" PRIu64 ".",
-			  current_id, dnode->props.thin_pool_transaction_id - 1);
+			  trans_id, dnode->props.thin_pool_transaction_id - 1);
 		return 0; /* Nothing to send */
 	}
 
@@ -2323,7 +2322,7 @@
 		dm_tree_set_cookie(dnode, 0);
 	}
 
-	if (r && !_thin_pool_node_send_messages(dnode, uuid_prefix, uuid_prefix_len)) {
+	if (r && !_node_send_messages(dnode, uuid_prefix, uuid_prefix_len)) {
 		stack;
 		if (!(dm_tree_deactivate_children(dnode, uuid_prefix, uuid_prefix_len)))
 			log_error("Failed to deactivate %s", dnode->name);



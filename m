From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Oct 2011 18:34:52 -0000
Subject: LVM2/libdm libdevmapper.h libdm-deptree.c
Message-ID: <20111003183452.20293.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-03 18:34:52

Modified files:
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Add intial code to check transaction_id
	
	Fix typy in transaction_id.
	Add this as node property, so it could be easily checked on resume.
	
	Code is not yet finished.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/libdm/libdevmapper.h	2011/10/03 18:26:07	1.155
+++ LVM2/libdm/libdevmapper.h	2011/10/03 18:34:52	1.156
@@ -538,7 +538,7 @@
 /* API for thin provisioning is experimental, DO NOT USE. */
 int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t size,
-				      uint64_t transation_id,
+				      uint64_t transaction_id,
 				      const char *pool_uuid,
 				      const char *metadata_uuid,
 				      uint32_t data_block_size,
--- LVM2/libdm/libdm-deptree.c	2011/10/03 18:29:48	1.118
+++ LVM2/libdm/libdm-deptree.c	2011/10/03 18:34:52	1.119
@@ -169,8 +169,8 @@
 
 	struct dm_tree_node *metadata;	/* Thin_pool */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
-	uint32_t data_block_size;       /* Thin_pool */
 	uint64_t low_water_mark;	/* Thin_pool */
+	uint32_t data_block_size;       /* Thin_pool */
 	unsigned skip_block_zeroeing;	/* Thin_pool */
 	uint32_t device_id;		/* Thin */
 
@@ -185,6 +185,8 @@
 	uint32_t read_ahead;
 	uint32_t read_ahead_flags;
 
+	uint64_t thin_pool_transaction_id; /* Thin_pool */
+
 	unsigned segment_count;
 	unsigned size_changed;
 	struct dm_list segs;
@@ -1207,6 +1209,50 @@
 	return r;
 }
 
+static int _check_thin_pool_transaction_id(const char *name, uint32_t major, uint32_t minor,
+					   uint64_t transaction_id)
+{
+	struct dm_task *dmt;
+	int r = 0;
+	uint64_t start, length;
+	char *type = NULL;
+	char *params = NULL;
+	uint64_t t_id = transaction_id; // FIXME: fake
+
+	log_verbose("Checking transaction id %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
+
+	if (!(dmt = dm_task_create(DM_DEVICE_STATUS))) {
+		log_debug("Device status dm_task creation failed for %s.", name);
+		return 0;
+	}
+
+	if (!dm_task_set_name(dmt, name)) {
+		log_debug("Failed to set device name for %s status.", name);
+		goto out;
+	}
+
+	if (!dm_task_set_major_minor(dmt, major, minor, 1)) {
+		log_error("Failed to set device number for %s status.", name);
+		goto out;
+	}
+
+	if (!dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count");
+
+	if (!(r = dm_task_run(dmt)))
+		goto_out;
+
+	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
+	log_verbose("PARSE params %s", params); // FIXME: parse status
+
+	r = (transaction_id == t_id);
+
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 /*
  * FIXME Don't attempt to deactivate known internal dependencies.
  */
@@ -1464,6 +1510,18 @@
 
 			/* Update cached info */
 			child->info = newinfo;
+
+			/* FIXME: trial version - to avoid use of unsynchronized thin_pool transaction_id */
+			if (child->props.thin_pool_transaction_id &&
+			    !_check_thin_pool_transaction_id(child->name, child->info.major,
+							     child->info.minor,
+							     child->props.thin_pool_transaction_id)) {
+				stack;
+				if (!(dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len)))
+					log_error("Failed to deactivate %s", child->name);
+				r = 0;
+				continue;
+			}
 		}
 	}
 
@@ -2148,6 +2206,17 @@
 		if (child->props.immediate_dev_node)
 			update_devs_flag = 1;
 
+		/* FIXME: trial version - to avoid use of unsynchronized thin_pool transaction_id */
+		if (child->props.thin_pool_transaction_id &&
+		    !_check_thin_pool_transaction_id(child->name, child->info.major,
+						     child->info.minor,
+						     child->props.thin_pool_transaction_id)) {
+			stack;
+			if (!(dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len)))
+				log_error("Failed to deactivate %s", child->name);
+			r = 0;
+			continue;
+		}
 	}
 
 	handle = NULL;
@@ -2642,7 +2711,7 @@
 
 int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t size,
-				      uint64_t transation_id,
+				      uint64_t transaction_id,
 				      const char *pool_uuid,
 				      const char *metadata_uuid,
 				      uint32_t data_block_size,
@@ -2684,8 +2753,9 @@
 	if (!_link_tree_nodes(node, seg->pool))
 		return_0;
 
-	seg->data_block_size = data_block_size;
+	node->props.thin_pool_transaction_id = transaction_id; // compare on resume
 	seg->low_water_mark = low_water_mark;
+	seg->data_block_size = data_block_size;
 	seg->skip_block_zeroeing = skip_block_zeroeing;
 
 	return 1;



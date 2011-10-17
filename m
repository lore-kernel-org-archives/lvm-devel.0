From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Oct 2011 14:16:26 -0000
Subject: LVM2/libdm libdevmapper.h libdm-deptree.c
Message-ID: <20111017141626.24728.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-17 14:16:25

Modified files:
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Add thin_pool dm message support
	
	Experimental support for kernel message via resume sequence.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/libdm/libdevmapper.h	2011/10/17 14:15:01	1.160
+++ LVM2/libdm/libdevmapper.h	2011/10/17 14:16:25	1.161
@@ -555,6 +555,42 @@
 				      uint64_t low_water_mark_size,
 				      unsigned skip_block_zeroing);
 
+/* Supported messages for thin provision target */
+typedef enum {
+	DM_THIN_MESSAGE_CREATE_SNAP,
+	DM_THIN_MESSAGE_CREATE_THIN,
+	DM_THIN_MESSAGE_DELETE,
+	DM_THIN_MESSAGE_SET_TRANSACTION_ID,
+	DM_THIN_MESSAGE_TRIM
+} dm_thin_message_t;
+
+struct dm_thin_message {
+	dm_thin_message_t type;
+	union {
+		struct {
+			uint32_t device_id;
+			uint32_t origin_id;
+		} m_create_snap;
+		struct {
+			uint32_t device_id;
+		} m_create_thin;
+		struct {
+			uint32_t device_id;
+		} m_delete;
+		struct {
+			uint64_t current_id;
+			uint64_t new_id;
+		} m_set_transaction_id;
+		struct {
+			uint32_t device_id;
+			uint64_t new_size;
+		} m_trim;
+	} u;
+};
+
+int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
+                                       struct dm_thin_message *message);
+
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
 				 const char *thin_pool_uuid,
--- LVM2/libdm/libdm-deptree.c	2011/10/17 14:15:26	1.127
+++ LVM2/libdm/libdm-deptree.c	2011/10/17 14:16:25	1.128
@@ -108,6 +108,11 @@
 	uint32_t flags;			/* Replicator sync log flags */
 };
 
+struct thin_message {
+	struct dm_list list;
+	struct dm_thin_message message;
+};
+
 /* Replicator-log has a list of sites */
 /* FIXME: maybe move to seg_area too? */
 struct replicator_site {
@@ -163,6 +168,7 @@
 
 	struct dm_tree_node *metadata;	/* Thin_pool */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
+	struct dm_list thin_messages;	/* Thin_pool */
 	uint64_t low_water_mark_size;	/* Thin_pool */
 	uint32_t data_block_size;       /* Thin_pool */
 	unsigned skip_block_zeroing;	/* Thin_pool */
@@ -1211,50 +1217,159 @@
 	return r;
 }
 
-static int _check_thin_pool_transaction_id(const char *name, uint32_t major, uint32_t minor,
-					   uint64_t transaction_id)
+static int _thin_pool_status_transaction_id(struct dm_tree_node *dnode, uint64_t *transaction_id)
 {
 	struct dm_task *dmt;
 	int r = 0;
 	uint64_t start, length;
 	char *type = NULL;
 	char *params = NULL;
-	uint64_t t_id = transaction_id; // FIXME: fake
 
-	log_verbose("Checking transaction id %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
+	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
+		return_0;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_STATUS))) {
-		log_debug("Device status dm_task creation failed for %s.", name);
-		return 0;
+	if (!dm_task_set_major(dmt, dnode->info.major) ||
+	    !dm_task_set_minor(dmt, dnode->info.minor)) {
+		log_error("Failed to set major minor.");
+		goto out;
 	}
 
-	if (!dm_task_set_name(dmt, name)) {
-		log_debug("Failed to set device name for %s status.", name);
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
+
+	if (type && (strcmp(type, "thin-pool") != 0)) {
+		log_error(INTERNAL_ERROR
+			  "Expected thin-pool target for %d:%d and got %s.",
+			  dnode->info.major, dnode->info.minor, type);
 		goto out;
 	}
 
-	if (!dm_task_set_major_minor(dmt, major, minor, 1)) {
-		log_error("Failed to set device number for %s status.", name);
+	if (!params || (sscanf(params, "%" PRIu64, transaction_id) != 1)) {
+		log_error(INTERNAL_ERROR
+			  "Failed to parse transaction_id from %s.", params);
 		goto out;
 	}
 
-	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+	log_debug("Thin pool transaction id: %" PRIu64 " status: %s.", *transaction_id, params);
 
-	if (!(r = dm_task_run(dmt)))
-		goto_out;
+	r = 1;
+out:
+	dm_task_destroy(dmt);
 
-	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
-	log_verbose("PARSE params %s", params); // FIXME: parse status
+	return r;
+}
 
-	r = (transaction_id == t_id);
+static int _thin_pool_node_message(struct dm_tree_node *dnode, struct thin_message *tm)
+{
+	struct dm_task *dmt;
+	struct dm_thin_message *m = &tm->message;
+	char buf[64];
+	int r;
 
+	switch (m->type) {
+	case DM_THIN_MESSAGE_CREATE_SNAP:
+		r = dm_snprintf(buf, sizeof(buf), "create_snap %u %u",
+				m->u.m_create_snap.device_id,
+				m->u.m_create_snap.origin_id);
+		break;
+	case DM_THIN_MESSAGE_CREATE_THIN:
+		r = dm_snprintf(buf, sizeof(buf), "create_thin %u",
+				m->u.m_create_thin.device_id);
+		break;
+	case DM_THIN_MESSAGE_DELETE:
+		r = dm_snprintf(buf, sizeof(buf), "delete %u",
+				m->u.m_delete.device_id);
+		break;
+	case DM_THIN_MESSAGE_TRIM:
+		r = dm_snprintf(buf, sizeof(buf), "trim %u %" PRIu64,
+				m->u.m_trim.device_id,
+				m->u.m_trim.new_size);
+		break;
+	case DM_THIN_MESSAGE_SET_TRANSACTION_ID:
+		r = dm_snprintf(buf, sizeof(buf),
+				"set_transaction_id %" PRIu64 " %" PRIu64,
+				m->u.m_set_transaction_id.current_id,
+				m->u.m_set_transaction_id.new_id);
+		break;
+	}
+
+	if (!r) {
+		log_error("Failed to prepare message.");
+		return 0;
+	}
+
+	r = 0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_TARGET_MSG)))
+		return_0;
+
+	if (!dm_task_set_major(dmt, dnode->info.major) ||
+	    !dm_task_set_minor(dmt, dnode->info.minor)) {
+		log_error("Failed to set message major minor.");
+		goto out;
+	}
+
+	if (!dm_task_set_message(dmt, buf))
+		goto_out;
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	r = 1;
 out:
 	dm_task_destroy(dmt);
 
 	return r;
 }
 
+static int _thin_pool_node_send_messages(struct dm_tree_node *dnode,
+					 const char *uuid_prefix,
+					 size_t uuid_prefix_len)
+{
+	struct load_segment *seg;
+	struct thin_message *tmsg;
+	uint64_t current_id;
+	const char *uuid;
+
+	if ((dnode == &dnode->dtree->root) || /* root has rops.segs uninitialized */
+	    (dm_list_size(&dnode->props.segs) != 1))
+		return 1;
+
+	seg = dm_list_item(dm_list_last(&dnode->props.segs), struct load_segment);
+
+	if (seg->type != SEG_THIN_POOL)
+		return 1;
+
+	if (!(uuid = dm_tree_node_get_uuid(dnode)))
+		return_0;
+
+	if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len)) {
+		log_debug("UUID \"%s\" does not match.", uuid);
+		return 1;
+	}
+
+	if (!_thin_pool_status_transaction_id(dnode, &current_id))
+		return_0;
+
+	log_debug("Expecting transaction_id: %" PRIu64, dnode->props.thin_pool_transaction_id);
+	if (current_id == dnode->props.thin_pool_transaction_id)
+		return 1; /* In sync - skip messages */
+
+	if (current_id != (dnode->props.thin_pool_transaction_id - 1)) {
+		log_error("Thin pool transaction_id=%" PRIu64 ", while expected: %" PRIu64 ".",
+			  current_id, dnode->props.thin_pool_transaction_id - 1);
+		return 0; /* Nothing to send */
+	}
+
+	dm_list_iterate_items(tmsg, &seg->thin_messages)
+		if (!(_thin_pool_node_message(dnode, tmsg)))
+			return_0;
+
+	return 1;
+}
+
 /*
  * FIXME Don't attempt to deactivate known internal dependencies.
  */
@@ -2205,6 +2320,13 @@
 		dm_tree_set_cookie(dnode, 0);
 	}
 
+	if (r && !_thin_pool_node_send_messages(dnode, uuid_prefix, uuid_prefix_len)) {
+		stack;
+		if (!(dm_tree_deactivate_children(dnode, uuid_prefix, uuid_prefix_len)))
+			log_error("Failed to deactivate %s", dnode->name);
+		r = 0;
+	}
+
 	return r;
 }
 
@@ -2744,6 +2866,82 @@
 	seg->low_water_mark_size = low_water_mark_size;
 	seg->data_block_size = data_block_size;
 	seg->skip_block_zeroing = skip_block_zeroing;
+	dm_list_init(&seg->thin_messages);
+
+	return 1;
+}
+
+int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
+				       struct dm_thin_message *message)
+{
+	struct load_segment *seg;
+	struct thin_message *tm;
+
+	if (node->props.segment_count != 1) {
+		log_error(INTERNAL_ERROR "Attempt to use non thin pool segment.");
+		return 0;
+	}
+
+	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+
+	if (seg->type != SEG_THIN_POOL) {
+		log_error(INTERNAL_ERROR "Attempt to use non thin pool segment %s.",
+			  dm_segtypes[seg->type].target);
+		return 0;
+	}
+
+	if (!(tm = dm_pool_zalloc(node->dtree->mem, sizeof (*tm)))) {
+		log_error("Failed to allocate thin message.");
+		return 0;
+	}
+
+	switch (message->type) {
+	case DM_THIN_MESSAGE_CREATE_SNAP:
+		/* Origin MUST be suspend! */
+		if (message->u.m_create_snap.device_id == message->u.m_create_snap.origin_id) {
+			log_error("Same origin used for thin snapshot.");
+			return 0;
+		}
+		if (!_thin_validate_device_id(message->u.m_create_snap.device_id) ||
+		    !_thin_validate_device_id(message->u.m_create_snap.origin_id))
+			return_0;
+		tm->message.u.m_create_snap.device_id = message->u.m_create_snap.device_id;
+		tm->message.u.m_create_snap.origin_id = message->u.m_create_snap.origin_id;
+		break;
+	case DM_THIN_MESSAGE_CREATE_THIN:
+		if (!_thin_validate_device_id(message->u.m_create_thin.device_id))
+			return_0;
+		tm->message.u.m_create_thin.device_id = message->u.m_create_thin.device_id;
+		break;
+	case DM_THIN_MESSAGE_DELETE:
+		if (!_thin_validate_device_id(message->u.m_delete.device_id))
+			return_0;
+		tm->message.u.m_delete.device_id = message->u.m_delete.device_id;
+		break;
+	case DM_THIN_MESSAGE_TRIM:
+		if (!_thin_validate_device_id(message->u.m_trim.device_id))
+			return_0;
+		tm->message.u.m_trim.device_id = message->u.m_trim.device_id;
+		tm->message.u.m_trim.new_size = message->u.m_trim.new_size;
+		break;
+	case DM_THIN_MESSAGE_SET_TRANSACTION_ID:
+		if (message->u.m_set_transaction_id.current_id !=
+		    (message->u.m_set_transaction_id.new_id - 1)) {
+			log_error("New transaction_id must be sequential.");
+			return 0; /* FIXME: Maybe too strict here? */
+		}
+		tm->message.u.m_set_transaction_id.current_id =
+			message->u.m_set_transaction_id.current_id;
+		tm->message.u.m_set_transaction_id.new_id =
+			message->u.m_set_transaction_id.new_id;
+		break;
+	default:
+		log_error("Unsupported message type %d.", (int) message->type);
+		return 0;
+	}
+
+	tm->message.type = message->type;
+	dm_list_add(&seg->thin_messages, &tm->list);
 
 	return 1;
 }



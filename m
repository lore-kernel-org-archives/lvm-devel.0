From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:45:03 -0000
Subject: LVM2 lib/thin/thin.c libdm/libdevmapper.h libd ...
Message-ID: <20111103144503.21750.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:45:01

Modified files:
	lib/thin       : thin.c 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Thin api change for passing message into libdm
	
	Avoid exposing another struct to the libdm user and
	use only simple dm_tree_node_add_thin_pool_message with
	2 overloaded uint64_t values.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/lib/thin/thin.c	2011/11/03 14:37:23	1.28
+++ LVM2/lib/thin/thin.c	2011/11/03 14:45:01	1.29
@@ -222,7 +222,6 @@
 {
 	char *metadata_dlid, *pool_dlid;
 	const struct lv_thin_message *lmsg;
-	struct dm_thin_message dmsg;
 
 	if (!(metadata_dlid = build_dm_uuid(mem, seg->pool_metadata_lv->lvid.s, NULL))) {
 		log_error("Failed to build uuid for metadata LV %s.",
@@ -243,27 +242,30 @@
 		return_0;
 
 	dm_list_iterate_items(lmsg, &seg->thin_messages) {
-		dmsg.type = lmsg->type;
 		switch (lmsg->type) {
 		case DM_THIN_MESSAGE_CREATE_SNAP:
 			/* FIXME: to be implemented */
 			log_debug("Thin pool create_snap %s.", lmsg->u.lv->name);
-			dmsg.u.m_create_snap.device_id = first_seg(lmsg->u.lv)->device_id;
-			dmsg.u.m_create_snap.origin_id = 0;//first_seg(first_seg(lmsg->u.lv)->origin)->device_id;
-			if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+			if (!dm_tree_node_add_thin_pool_message(node,
+								lmsg->type,
+								first_seg(lmsg->u.lv)->device_id,
+								0))//first_seg(first_seg(lmsg->u.lv)->origin)->device_id;
 				return_0;
 			log_error("Sorry SNAPSHOT is not yet supported.");
 			return 0;
 		case DM_THIN_MESSAGE_CREATE_THIN:
 			log_debug("Thin pool create_thin %s.", lmsg->u.lv->name);
-			dmsg.u.m_create_thin.device_id = first_seg(lmsg->u.lv)->device_id;
-			if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+			if (!dm_tree_node_add_thin_pool_message(node,
+								lmsg->type,
+								first_seg(lmsg->u.lv)->device_id,
+								0))
 				return_0;
 			break;
 		case DM_THIN_MESSAGE_DELETE:
 			log_debug("Thin pool delete %u.", lmsg->u.delete_id);
-			dmsg.u.m_delete.device_id = lmsg->u.delete_id;
-			if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+			if (!dm_tree_node_add_thin_pool_message(node,
+								lmsg->type,
+								lmsg->u.delete_id, 0))
 				return_0;
 			break;
 		case DM_THIN_MESSAGE_TRIM:
@@ -278,11 +280,11 @@
 
 	if (!dm_list_empty(&seg->thin_messages)) {
 		/* Messages were passed, modify transaction_id as the last one */
-		log_debug("Thin pool set_transaction_id %" PRIu64 ".", seg->transaction_id);
-		dmsg.type = DM_THIN_MESSAGE_SET_TRANSACTION_ID;
-		dmsg.u.m_set_transaction_id.current_id = seg->transaction_id - 1;
-		dmsg.u.m_set_transaction_id.new_id = seg->transaction_id;
-		if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+		log_debug("Thin pool set transaction id %" PRIu64 ".", seg->transaction_id);
+		if (!dm_tree_node_add_thin_pool_message(node,
+							DM_THIN_MESSAGE_SET_TRANSACTION_ID,
+							seg->transaction_id - 1,
+							seg->transaction_id))
 			return_0;
 	}
 
--- LVM2/libdm/libdevmapper.h	2011/11/03 14:43:21	1.167
+++ LVM2/libdm/libdevmapper.h	2011/11/03 14:45:01	1.168
@@ -555,39 +555,16 @@
 
 /* Supported messages for thin provision target */
 typedef enum {
-	DM_THIN_MESSAGE_CREATE_SNAP,
-	DM_THIN_MESSAGE_CREATE_THIN,
-	DM_THIN_MESSAGE_DELETE,
-	DM_THIN_MESSAGE_SET_TRANSACTION_ID,
-	DM_THIN_MESSAGE_TRIM
+	DM_THIN_MESSAGE_CREATE_SNAP,		/* device_id, origin_id */
+	DM_THIN_MESSAGE_CREATE_THIN,		/* device_id */
+	DM_THIN_MESSAGE_DELETE,			/* device_id */
+	DM_THIN_MESSAGE_SET_TRANSACTION_ID,	/* current_id, new_id */
+	DM_THIN_MESSAGE_TRIM			/* device_id, new_size */
 } dm_thin_message_t;
 
-struct dm_thin_message {
-	dm_thin_message_t type;
-	union {
-		struct {
-			uint32_t device_id;
-			uint32_t origin_id;
-		} m_create_snap;
-		struct {
-			uint32_t device_id;
-		} m_create_thin;
-		struct {
-			uint32_t device_id;
-		} m_delete;
-		struct {
-			uint64_t current_id;
-			uint64_t new_id;
-		} m_set_transaction_id;
-		struct {
-			uint32_t device_id;
-			uint64_t new_size;
-		} m_trim;
-	} u;
-};
-
 int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
-                                       const struct dm_thin_message *message);
+				       dm_thin_message_t type,
+				       uint64_t id1, uint64_t id2);
 
 /*
  * FIXME: Defines bellow are based on kernel's dm-thin.c defines
--- LVM2/libdm/libdm-deptree.c	2011/11/03 14:43:21	1.143
+++ LVM2/libdm/libdm-deptree.c	2011/11/03 14:45:01	1.144
@@ -108,6 +108,30 @@
 	uint32_t flags;			/* Replicator sync log flags */
 };
 
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
 struct thin_message {
 	struct dm_list list;
 	struct dm_thin_message message;
@@ -2901,7 +2925,8 @@
 }
 
 int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
-				       const struct dm_thin_message *message)
+				       dm_thin_message_t type,
+				       uint64_t id1, uint64_t id2)
 {
 	struct load_segment *seg;
 	struct thin_message *tm;
@@ -2923,49 +2948,55 @@
 		return 0;
 	}
 
-	switch (message->type) {
+	switch (type) {
 	case DM_THIN_MESSAGE_CREATE_SNAP:
 		/* If the thin origin is active, it must be suspend first! */
-		if (message->u.m_create_snap.device_id == message->u.m_create_snap.origin_id) {
+		if (id1 == id2) {
 			log_error("Cannot use same device id for origin and its snapshot.");
 			return 0;
 		}
-		if (!_thin_validate_device_id(message->u.m_create_snap.device_id) ||
-		    !_thin_validate_device_id(message->u.m_create_snap.origin_id))
+		if (!_thin_validate_device_id(id1) ||
+		    !_thin_validate_device_id(id2))
 			return_0;
-		tm->message.u.m_create_snap = message->u.m_create_snap;
+		tm->message.u.m_create_snap.device_id = id1;
+		tm->message.u.m_create_snap.origin_id = id2;
 		break;
 	case DM_THIN_MESSAGE_CREATE_THIN:
-		if (!_thin_validate_device_id(message->u.m_create_thin.device_id))
+		if (!_thin_validate_device_id(id1))
 			return_0;
-		tm->message.u.m_create_thin = message->u.m_create_thin;
+		tm->message.u.m_create_thin.device_id = id1;
 		tm->expected_errno = EEXIST;
 		break;
 	case DM_THIN_MESSAGE_DELETE:
-		if (!_thin_validate_device_id(message->u.m_delete.device_id))
+		if (!_thin_validate_device_id(id1))
 			return_0;
-		tm->message.u.m_delete = message->u.m_delete;
+		tm->message.u.m_delete.device_id = id1;
 		tm->expected_errno = ENODATA;
 		break;
 	case DM_THIN_MESSAGE_TRIM:
-		if (!_thin_validate_device_id(message->u.m_trim.device_id))
+		if (!_thin_validate_device_id(id1))
 			return_0;
-		tm->message.u.m_trim = message->u.m_trim;
+		tm->message.u.m_trim.device_id = id1;
+		tm->message.u.m_trim.new_size = id2;
 		break;
 	case DM_THIN_MESSAGE_SET_TRANSACTION_ID:
-		if (message->u.m_set_transaction_id.current_id !=
-		    (message->u.m_set_transaction_id.new_id - 1)) {
-			log_error("New transaction_id must be sequential.");
+		if ((id1 + 1) !=  id2) {
+			log_error("New transaction id must be sequential.");
+			return 0; /* FIXME: Maybe too strict here? */
+		}
+		if (id1 !=  seg->transaction_id) {
+			log_error("Current transaction id is different from thin pool.");
 			return 0; /* FIXME: Maybe too strict here? */
 		}
-		tm->message.u.m_set_transaction_id = message->u.m_set_transaction_id;
+		tm->message.u.m_set_transaction_id.current_id = id1;
+		tm->message.u.m_set_transaction_id.new_id = id2;
 		break;
 	default:
-		log_error("Unsupported message type %d.", (int) message->type);
+		log_error("Unsupported message type %d.", (int) type);
 		return 0;
 	}
 
-	tm->message.type = message->type;
+	tm->message.type = type;
 	dm_list_add(&seg->thin_messages, &tm->list);
 
 	return 1;



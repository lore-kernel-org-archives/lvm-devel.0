From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 10:32:29 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20111020103229.30713.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 10:32:29

Modified files:
	lib/thin       : thin.c 

Log message:
	Reindent code
	
	Avoid 1 indent level and use check for empty list only for
	add of transaction_id message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/lib/thin/thin.c	2011/10/20 10:31:27	1.21
+++ LVM2/lib/thin/thin.c	2011/10/20 10:32:29	1.22
@@ -241,41 +241,42 @@
 					       seg->zero_new_blocks ? 0 : 1))
 		return_0;
 
-	if (!dm_list_empty(&seg->thin_messages)) {
-		dm_list_iterate_items(lmsg, &seg->thin_messages) {
-			dmsg.type = lmsg->type;
-			switch (lmsg->type) {
-			case DM_THIN_MESSAGE_CREATE_SNAP:
-				/* FIXME: to be implemented */
-				log_debug("Thin pool create_snap %s.", lmsg->u.lv->name);
-				dmsg.u.m_create_snap.device_id = first_seg(lmsg->u.lv)->device_id;
-				dmsg.u.m_create_snap.origin_id = 0;//first_seg(first_seg(lmsg->u.lv)->origin)->device_id;
-				if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
-					return_0;
-				log_error(INTERNAL_ERROR "Sorry, not implemented yet.");
-				return 0;
-			case DM_THIN_MESSAGE_CREATE_THIN:
-				log_debug("Thin pool create_thin %s.", lmsg->u.lv->name);
-				dmsg.u.m_create_thin.device_id = first_seg(lmsg->u.lv)->device_id;
-				if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
-					return_0;
-				break;
-			case DM_THIN_MESSAGE_DELETE:
-				log_debug("Thin pool delete %u.", lmsg->u.delete_id);
-				dmsg.u.m_delete.device_id = lmsg->u.delete_id;
-				if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
-					return_0;
-				break;
-			case DM_THIN_MESSAGE_TRIM:
-				/* FIXME: to be implemented */
-				log_error(INTERNAL_ERROR "Sorry, not implemented yet.");
-				return 0;
-			default:
-				log_error(INTERNAL_ERROR "Unsupported message.");
-				return 0;
-			}
+	dm_list_iterate_items(lmsg, &seg->thin_messages) {
+		dmsg.type = lmsg->type;
+		switch (lmsg->type) {
+		case DM_THIN_MESSAGE_CREATE_SNAP:
+			/* FIXME: to be implemented */
+			log_debug("Thin pool create_snap %s.", lmsg->u.lv->name);
+			dmsg.u.m_create_snap.device_id = first_seg(lmsg->u.lv)->device_id;
+			dmsg.u.m_create_snap.origin_id = 0;//first_seg(first_seg(lmsg->u.lv)->origin)->device_id;
+			if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+				return_0;
+			log_error("Sorry SNAPSHOTS is not yet supported.");
+			return 0;
+		case DM_THIN_MESSAGE_CREATE_THIN:
+			log_debug("Thin pool create_thin %s.", lmsg->u.lv->name);
+			dmsg.u.m_create_thin.device_id = first_seg(lmsg->u.lv)->device_id;
+			if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+				return_0;
+			break;
+		case DM_THIN_MESSAGE_DELETE:
+			log_debug("Thin pool delete %u.", lmsg->u.delete_id);
+			dmsg.u.m_delete.device_id = lmsg->u.delete_id;
+			if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+				return_0;
+			break;
+		case DM_THIN_MESSAGE_TRIM:
+			/* FIXME: to be implemented */
+			log_error("Sorry TRIM is not yes supported.");
+			return 0;
+		default:
+			log_error(INTERNAL_ERROR "Unsupported message.");
+			return 0;
 		}
+	}
 
+	if (!dm_list_empty(&seg->thin_messages)) {
+		/* Messages were passed, modify transaction_id as the last one */
 		log_debug("Thin pool set_transaction_id %" PRIu64 ".", seg->transaction_id);
 		dmsg.type = DM_THIN_MESSAGE_SET_TRANSACTION_ID;
 		dmsg.u.m_set_transaction_id.current_id = seg->transaction_id - 1;



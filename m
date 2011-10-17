From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Oct 2011 14:17:10 -0000
Subject: LVM2/lib metadata/lv_manip.c metadata/metadata ...
Message-ID: <20111017141710.25102.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-17 14:17:10

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h metadata.h 
	                 thin_manip.c 
	lib/thin       : thin.c 

Log message:
	Message support for thin provisiong
	
	lvm part of messaging.
	
	Each message is now stored it's own thin pool section:
	
	message1 {
	create = lv
	}
	
	Messages are queued to thin pool dm target when this target
	is going to be resumed or used through some dependency.
	
	Currently  'delete' message are purely queued and processed
	with next thin pool resume operation (i.e. create_thin).
	
	WARNING - thin provisioning support is developmental code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.294&r2=1.295
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.214&r2=1.215
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.257&r2=1.258
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/lib/metadata/lv_manip.c	2011/10/06 15:32:26	1.294
+++ LVM2/lib/metadata/lv_manip.c	2011/10/17 14:17:09	1.295
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -251,6 +251,7 @@
 	seg->extents_copied = extents_copied;
 	seg->pvmove_source_seg = pvmove_source_seg;
 	dm_list_init(&seg->tags);
+	dm_list_init(&seg->thin_messages);
 
 	if (thin_pool_lv && !attach_pool_lv(seg, thin_pool_lv))
 		return_NULL;
@@ -4173,9 +4174,9 @@
 			return NULL;
 		}
 
-		if (!lv_send_message(pool_lv, "create_thin %u", first_seg(lv)->device_id))
+		if (!attach_pool_message(first_seg(pool_lv),
+					 DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0))
 			return_NULL;
-
 		/*
 		 * FIXME: Skipping deactivate_lv(pool_lv) as it is going to be needed anyway
 		 * but revert_new_lv should revert to deactivated state.
@@ -4238,6 +4239,15 @@
 		if (!set_lv(cmd, first_seg(lv)->pool_metadata_lv, UINT64_C(0), 0))
 			log_error("Aborting. Failed to wipe pool metadata %s.",
 				  lv->name);
+	} else if (seg_is_thin_volume(lp)) {
+		/* since we've got here, we may drop any queued thin messages */
+		if (!detach_pool_messages(first_seg(first_seg(lv)->pool_lv)))
+			goto deactivate_and_revert_new_lv;
+
+		if (!vg_write(vg) || !vg_commit(vg))
+			goto deactivate_and_revert_new_lv;
+
+		backup(vg);
 	}
 
 	if (lp->snapshot) {
--- LVM2/lib/metadata/metadata-exported.h	2011/10/07 14:56:01	1.214
+++ LVM2/lib/metadata/metadata-exported.h	2011/10/17 14:17:09	1.215
@@ -256,6 +256,15 @@
 	} u;
 };
 
+struct lv_thin_message {
+	struct dm_list list;		/* Chained list of messages */
+	dm_thin_message_t type;		/* Use dm thin message datatype */
+	union {
+		struct logical_volume *lv; /* For: create_thin, create_snap, trim */
+		uint32_t delete_id;	/* For delete, needs device_id */
+	} u;
+};
+
 struct segment_type;
 
 /* List with vg_name, vgid and flags */
@@ -338,6 +347,7 @@
 	uint64_t low_water_mark;		/* For thin_pool */
 	uint32_t data_block_size;		/* For thin_pool, 128..2097152 */
 	unsigned zero_new_blocks;		/* For thin_pool */
+	struct dm_list thin_messages;		/* For thin_pool */
 	struct logical_volume *pool_lv;		/* For thin */
 	uint32_t device_id;			/* For thin, 24bit */
 
--- LVM2/lib/metadata/metadata.h	2011/10/03 18:39:17	1.257
+++ LVM2/lib/metadata/metadata.h	2011/10/17 14:17:09	1.258
@@ -454,6 +454,10 @@
 			struct logical_volume *pool_data_lv);
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv);
 int detach_pool_lv(struct lv_segment *seg);
+int attach_pool_message(struct lv_segment *seg, dm_thin_message_t type,
+			struct logical_volume *lv, uint32_t device_id,
+			int read_only);
+int detach_pool_messages(struct lv_segment *seg);
 
 /*
  * Begin skeleton for external LVM library
--- LVM2/lib/metadata/thin_manip.c	2011/10/03 19:10:52	1.6
+++ LVM2/lib/metadata/thin_manip.c	2011/10/17 14:17:09	1.7
@@ -58,9 +58,75 @@
 		return 0;
 	}
 
+	if (!attach_pool_message(first_seg(seg->pool_lv),
+				 DM_THIN_MESSAGE_DELETE,
+				 NULL, seg->device_id, 0))
+		return_0;
+
 	return remove_seg_from_segs_using_this_lv(seg->pool_lv, seg);
 }
 
+int attach_pool_message(struct lv_segment *seg, dm_thin_message_t type,
+			struct logical_volume *lv, uint32_t device_id,
+			int read_only)
+{
+	struct lv_thin_message *tmsg;
+
+	if (!lv_is_thin_pool(seg->lv)) {
+		log_error(INTERNAL_ERROR "LV %s is not a thin pool.",
+			  seg->lv->name);
+		return 0;
+	}
+
+	if (!(tmsg = dm_pool_alloc(seg->lv->vg->vgmem, sizeof(*tmsg)))) {
+		log_error("Failed to allocate memory for message.");
+		return 0;
+	}
+
+	switch (type) {
+	case DM_THIN_MESSAGE_CREATE_SNAP:
+	case DM_THIN_MESSAGE_CREATE_THIN:
+	case DM_THIN_MESSAGE_TRIM:
+		tmsg->u.lv = lv;
+		break;
+	case DM_THIN_MESSAGE_DELETE:
+		tmsg->u.delete_id = device_id;
+		break;
+	default:
+		log_error(INTERNAL_ERROR "Unsupported message type %d", type);
+		return 0;
+	}
+
+	tmsg->type = type;
+
+	/* If the 1st message is add in non-read-only mode, modify transaction_id */
+	if (!read_only && dm_list_empty(&seg->thin_messages))
+		seg->transaction_id++;
+
+	dm_list_add(&seg->thin_messages, &tmsg->list);
+
+	log_debug("Added %s message",
+		  (type == DM_THIN_MESSAGE_CREATE_SNAP ||
+		   type == DM_THIN_MESSAGE_CREATE_THIN) ? "create" :
+		  (type == DM_THIN_MESSAGE_TRIM) ? "trim" :
+		  (type == DM_THIN_MESSAGE_DELETE) ? "delete" : "unknown");
+
+	return 1;
+}
+
+int detach_pool_messages(struct lv_segment *seg)
+{
+	if (!lv_is_thin_pool(seg->lv)) {
+		log_error(INTERNAL_ERROR "LV %s is not a thin pool.",
+			  seg->lv->name);
+		return 0;
+	}
+
+	dm_list_init(&seg->thin_messages);
+
+	return 1;
+}
+
 struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 {
         struct lv_segment *pool_seg;
--- LVM2/lib/thin/thin.c	2011/10/11 08:51:56	1.16
+++ LVM2/lib/thin/thin.c	2011/10/17 14:17:09	1.17
@@ -43,6 +43,48 @@
 	return seg->segtype->name;
 }
 
+static int _thin_pool_add_message(struct lv_segment *seg,
+				  const char *key,
+				  const struct dm_config_node *sn)
+{
+	const char *lv_name = NULL;
+	struct logical_volume *lv = NULL;
+	uint32_t device_id = 0;
+	dm_thin_message_t type;
+
+	/* Message must have only one from: create, trim, delete */
+	if (dm_config_get_str(sn, "create", &lv_name)) {
+		if (!(lv = find_lv(seg->lv->vg, lv_name)))
+			return SEG_LOG_ERROR("Unknown LV %s for create message in",
+					     lv_name);
+		/* FIXME: switch to _SNAP later, if the created LV has an origin */
+		type = DM_THIN_MESSAGE_CREATE_THIN;
+	}
+
+	if (dm_config_get_str(sn, "trim", &lv_name)) {
+		if (lv)
+			return SEG_LOG_ERROR("Unsupported message format in");
+		if (!(lv = find_lv(seg->lv->vg, lv_name)))
+			return SEG_LOG_ERROR("Unknown LV %s for trim message in",
+					     lv_name);
+		type = DM_THIN_MESSAGE_TRIM;
+	}
+
+	if (!dm_config_get_uint32(sn, "delete", &device_id)) {
+		if (!lv)
+			return SEG_LOG_ERROR("Unknown message in");
+	} else {
+		if (lv)
+			return SEG_LOG_ERROR("Unsupported message format in");
+		type = DM_THIN_MESSAGE_DELETE;
+	}
+
+	if (!attach_pool_message(seg, type, lv, device_id, 1))
+		return_0;
+
+	return 1;
+}
+
 static int _thin_pool_text_import(struct lv_segment *seg,
 				  const struct dm_config_node *sn,
 				  struct dm_hash_table *pv_hash __attribute__((unused)))
@@ -88,6 +130,11 @@
 
 	seg->lv->status |= THIN_POOL;
 
+	/* Read messages */
+	for (; sn; sn = sn->sib)
+		if (!(sn->v) && !_thin_pool_add_message(seg, sn->key, sn->child))
+			return_0;
+
 	return 1;
 }
 
@@ -101,14 +148,61 @@
 
 static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter *f)
 {
+	unsigned cnt = 0;
+	struct lv_thin_message *tmsg;
+
 	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->pool_metadata_lv->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
 	outf(f, "low_water_mark = %" PRIu64, seg->low_water_mark);
 	outf(f, "data_block_size = %d", seg->data_block_size);
+
 	if (seg->zero_new_blocks)
 		outf(f, "zero_new_blocks = 1");
 
+	dm_list_iterate_items(tmsg, &seg->thin_messages) {
+		/* Extra validation */
+		switch (tmsg->type) {
+		case DM_THIN_MESSAGE_CREATE_SNAP:
+		case DM_THIN_MESSAGE_CREATE_THIN:
+		case DM_THIN_MESSAGE_TRIM:
+			if (!lv_is_thin_volume(tmsg->u.lv)) {
+				log_error(INTERNAL_ERROR
+					  "LV %s is not a thin volume.",
+					  tmsg->u.lv->name);
+				return 0;
+			}
+			break;
+		default:
+			break;
+		}
+
+		if (!cnt)
+			outnl(f);
+
+		outf(f, "message%d {", ++cnt);
+		out_inc_indent(f);
+
+		switch (tmsg->type) {
+		case DM_THIN_MESSAGE_CREATE_SNAP:
+		case DM_THIN_MESSAGE_CREATE_THIN:
+			outf(f, "create = \"%s\"", tmsg->u.lv->name);
+			break;
+		case DM_THIN_MESSAGE_TRIM:
+			outf(f, "trim = \"%s\"", tmsg->u.lv->name);
+			break;
+		case DM_THIN_MESSAGE_DELETE:
+			outf(f, "delete = %d", tmsg->u.delete_id);
+			break;
+		default:
+			log_error(INTERNAL_ERROR "Passed unsupported message.");
+			return 0;
+		}
+
+		out_dec_indent(f);
+		outf(f, "}");
+	}
+
 	return 1;
 }
 
@@ -123,6 +217,8 @@
 				      uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	char *metadata_dlid, *pool_dlid;
+	struct lv_thin_message *lmsg;
+	struct dm_thin_message dmsg;
 
 	if (!(metadata_dlid = build_dm_uuid(mem, seg->pool_metadata_lv->lvid.s, NULL))) {
 		log_error("Failed to build uuid for metadata LV %s.", seg->pool_metadata_lv->name);
@@ -134,11 +230,55 @@
 		return 0;
 	}
 
-	if (!dm_tree_node_add_thin_pool_target(node, len, 0, metadata_dlid, pool_dlid,
+	if (!dm_tree_node_add_thin_pool_target(node, len, seg->transaction_id,
+					       metadata_dlid, pool_dlid,
 					       seg->data_block_size, seg->low_water_mark,
 					       seg->zero_new_blocks ? 0 : 1))
 		return_0;
 
+	if (!dm_list_empty(&seg->thin_messages)) {
+		dm_list_iterate_items(lmsg, &seg->thin_messages) {
+			dmsg.type = lmsg->type;
+			switch (lmsg->type) {
+			case DM_THIN_MESSAGE_CREATE_SNAP:
+				/* FIXME: to be implemented */
+				log_debug("Thin pool create_snap %s.", lmsg->u.lv->name);
+				dmsg.u.m_create_snap.device_id = first_seg(lmsg->u.lv)->device_id;
+				dmsg.u.m_create_snap.origin_id = 0;//first_seg(first_seg(lmsg->u.lv)->origin)->device_id;
+				if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+					return_0;
+				log_error(INTERNAL_ERROR "Sorry, not implemented yet.");
+				return 0;
+			case DM_THIN_MESSAGE_CREATE_THIN:
+				log_debug("Thin pool create_thin %s.", lmsg->u.lv->name);
+				dmsg.u.m_create_thin.device_id = first_seg(lmsg->u.lv)->device_id;
+				if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+					return_0;
+				break;
+			case DM_THIN_MESSAGE_DELETE:
+				log_debug("Thin pool delete %u.", lmsg->u.delete_id);
+				dmsg.u.m_delete.device_id = lmsg->u.delete_id;
+				if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+					return_0;
+				break;
+			case DM_THIN_MESSAGE_TRIM:
+				/* FIXME: to be implemented */
+				log_error(INTERNAL_ERROR "Sorry, not implemented yet.");
+				return 0;
+			default:
+				log_error(INTERNAL_ERROR "Unsupported message.");
+				return 0;
+			}
+		}
+
+		log_debug("Thin pool set_transaction_id %" PRIu64 ".", seg->transaction_id);
+		dmsg.type = DM_THIN_MESSAGE_SET_TRANSACTION_ID;
+		dmsg.u.m_set_transaction_id.current_id = seg->transaction_id - 1;
+		dmsg.u.m_set_transaction_id.new_id = seg->transaction_id;
+		if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
+			return_0;
+	}
+
 	return 1;
 }
 #endif



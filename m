From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 08:55:20 -0000
Subject: LVM2/lib/metadata metadata.h thin_manip.c
Message-ID: <20120125085520.26223.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 08:55:20

Modified files:
	lib/metadata   : metadata.h thin_manip.c 

Log message:
	Thin fix transaction_id incrementation and code refactoring
	
	Add pool_has_message and use it in attach_pool_message.
	Also update header to make more obvious which segment type is
	expected as parameter.
	Rename  'read_only' to  'no_update' (no auto update transaction_id)
	to better fit how it's used.
	Fix problem when there was only one stacked message replaced with delete
	message that caused unwanted transaction_id increase.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.264&r2=1.265
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/lib/metadata/metadata.h	2011/11/07 11:03:47	1.264
+++ LVM2/lib/metadata/metadata.h	2012/01/25 08:55:19	1.265
@@ -452,16 +452,18 @@
 /*
  * From thin_manip.c
  */
-int attach_pool_metadata_lv(struct lv_segment *seg,
+int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 			    struct logical_volume *pool_metadata_lv);
-int attach_pool_data_lv(struct lv_segment *seg,
+int attach_pool_data_lv(struct lv_segment *pool_seg,
 			struct logical_volume *pool_data_lv);
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
 		   struct logical_volume *origin_lv);
 int detach_pool_lv(struct lv_segment *seg);
-int attach_pool_message(struct lv_segment *seg, dm_thin_message_t type,
+int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 			struct logical_volume *lv, uint32_t delete_id,
-			int read_only);
+			int auto_increment);
+int pool_has_message(const struct lv_segment *seg,
+		     const struct logical_volume *lv, uint32_t device_id);
 int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
 
--- LVM2/lib/metadata/thin_manip.c	2012/01/23 17:46:31	1.29
+++ LVM2/lib/metadata/thin_manip.c	2012/01/25 08:55:19	1.30
@@ -20,18 +20,18 @@
 #include "lv_alloc.h"
 #include "archiver.h"
 
-int attach_pool_metadata_lv(struct lv_segment *seg, struct logical_volume *metadata_lv)
+int attach_pool_metadata_lv(struct lv_segment *pool_seg, struct logical_volume *metadata_lv)
 {
-	seg->metadata_lv = metadata_lv;
+	pool_seg->metadata_lv = metadata_lv;
 	metadata_lv->status |= THIN_POOL_METADATA;
 	lv_set_hidden(metadata_lv);
 
-	return add_seg_to_segs_using_this_lv(metadata_lv, seg);
+	return add_seg_to_segs_using_this_lv(metadata_lv, pool_seg);
 }
 
-int attach_pool_data_lv(struct lv_segment *seg, struct logical_volume *pool_data_lv)
+int attach_pool_data_lv(struct lv_segment *pool_seg, struct logical_volume *pool_data_lv)
 {
-	if (!set_lv_segment_area_lv(seg, 0, pool_data_lv, 0, THIN_POOL_DATA))
+	if (!set_lv_segment_area_lv(pool_seg, 0, pool_data_lv, 0, THIN_POOL_DATA))
 		return_0;
 
 	lv_set_hidden(pool_data_lv);
@@ -56,6 +56,7 @@
 {
 	struct lv_thin_message *tmsg, *tmp;
 	struct seg_list *sl, *tsl;
+	int no_update = 0;
 
 	if (!seg->pool_lv || !lv_is_thin_pool(seg->pool_lv)) {
 		log_error(INTERNAL_ERROR "LV %s is not a thin volume",
@@ -64,15 +65,16 @@
 	}
 
 	/* Drop any message referencing removed segment */
-	dm_list_iterate_items_safe(tmsg, tmp, &first_seg(seg->pool_lv)->thin_messages) {
+	dm_list_iterate_items_safe(tmsg, tmp, &(first_seg(seg->pool_lv)->thin_messages)) {
 		switch (tmsg->type) {
 		case DM_THIN_MESSAGE_CREATE_SNAP:
 		case DM_THIN_MESSAGE_CREATE_THIN:
 		case DM_THIN_MESSAGE_TRIM:
-			if (first_seg(tmsg->u.lv) == seg) {
+			if (tmsg->u.lv == seg->lv) {
 				log_debug("Discarding message for LV %s.",
 					  tmsg->u.lv->name);
 				dm_list_del(&tmsg->list);
+				no_update = 1; /* Replacing existing */
 			}
 			break;
 		case DM_THIN_MESSAGE_DELETE:
@@ -90,7 +92,7 @@
 
 	if (!attach_pool_message(first_seg(seg->pool_lv),
 				 DM_THIN_MESSAGE_DELETE,
-				 NULL, seg->device_id, 0))
+				 NULL, seg->device_id, no_update))
 		return_0;
 
 	if (!remove_seg_from_segs_using_this_lv(seg->pool_lv, seg))
@@ -119,40 +121,28 @@
 	return 1;
 }
 
-int attach_pool_message(struct lv_segment *seg, dm_thin_message_t type,
+int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 			struct logical_volume *lv, uint32_t delete_id,
-			int read_only)
+			int no_update)
 {
 	struct lv_thin_message *tmsg;
 
-	dm_list_iterate_items(tmsg, &seg->thin_messages) {
-		if (tmsg->type != type)
-			continue;
+	if (!seg_is_thin_pool(pool_seg)) {
+		log_error(INTERNAL_ERROR "LV %s is not pool.", pool_seg->lv->name);
+		return 0;
+	}
 
-		switch (tmsg->type) {
-		case DM_THIN_MESSAGE_CREATE_SNAP:
-		case DM_THIN_MESSAGE_CREATE_THIN:
-		case DM_THIN_MESSAGE_TRIM:
-			if (tmsg->u.lv == lv) {
-				log_error("Message referring LV %s already queued for %s.",
-					  tmsg->u.lv->name, seg->lv->name);
-				return 0;
-			}
-			break;
-		case DM_THIN_MESSAGE_DELETE:
-			if (tmsg->u.delete_id == delete_id) {
-				log_error("Delete of device %u already queued for %s.",
-					  tmsg->u.delete_id, seg->lv->name);
-				return 0;
-			}
-			break;
-		default:
-			log_error(INTERNAL_ERROR "Unsupported message type %u.", tmsg->type);
-			return 0;
-		}
+	if (pool_has_message(pool_seg, lv, delete_id)) {
+		if (lv)
+			log_error("Message referring LV %s already queued in pool %s.",
+				  lv->name, pool_seg->lv->name);
+		else
+			log_error("Delete for device %u already queued in pool %s.",
+				  delete_id, pool_seg->lv->name);
+		return 0;
 	}
 
-	if (!(tmsg = dm_pool_alloc(seg->lv->vg->vgmem, sizeof(*tmsg)))) {
+	if (!(tmsg = dm_pool_alloc(pool_seg->lv->vg->vgmem, sizeof(*tmsg)))) {
 		log_error("Failed to allocate memory for message.");
 		return 0;
 	}
@@ -174,10 +164,10 @@
 	tmsg->type = type;
 
 	/* If the 1st message is add in non-read-only mode, modify transaction_id */
-	if (!read_only && dm_list_empty(&seg->thin_messages))
-		seg->transaction_id++;
+	if (!no_update && dm_list_empty(&pool_seg->thin_messages))
+		pool_seg->transaction_id++;
 
-	dm_list_add(&seg->thin_messages, &tmsg->list);
+	dm_list_add(&pool_seg->thin_messages, &tmsg->list);
 
 	log_debug("Added %s message",
 		  (type == DM_THIN_MESSAGE_CREATE_SNAP ||
@@ -188,6 +178,43 @@
 	return 1;
 }
 
+/*
+ * Check whether pool has some message queued for LV or for device_id
+ * When LV is NULL and device_id is 0 it just checks for any message.
+ */
+int pool_has_message(const struct lv_segment *seg,
+		     const struct logical_volume *lv, uint32_t device_id)
+{
+	const struct lv_thin_message *tmsg;
+
+	if (!seg_is_thin_pool(seg)) {
+		log_error(INTERNAL_ERROR "LV %s is not pool.", seg->lv->name);
+		return 0;
+	}
+
+	if (!lv && !device_id)
+		return dm_list_empty(&seg->thin_messages);
+
+	dm_list_iterate_items(tmsg, &seg->thin_messages) {
+		switch (tmsg->type) {
+		case DM_THIN_MESSAGE_CREATE_SNAP:
+		case DM_THIN_MESSAGE_CREATE_THIN:
+		case DM_THIN_MESSAGE_TRIM:
+			if (tmsg->u.lv == lv)
+				return 1;
+			break;
+		case DM_THIN_MESSAGE_DELETE:
+			if (tmsg->u.delete_id == device_id)
+				return 1;
+			break;
+		default:
+			break;
+		}
+	}
+
+	return 0;
+}
+
 struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 {
 	struct lv_segment *pool_seg;



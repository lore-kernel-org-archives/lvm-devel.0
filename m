From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Oct 2011 16:39:09 -0000
Subject: LVM2/lib/metadata metadata.h thin_manip.c
Message-ID: <20111019163909.17834.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-19 16:39:09

Modified files:
	lib/metadata   : metadata.h thin_manip.c 

Log message:
	Simple validation of messages in mda
	
	Check we do not combine multiple messages for same LV target
	and switch to use  'delete_id' to make it clear for what this device_id
	is being used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.258&r2=1.259
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/lib/metadata/metadata.h	2011/10/17 14:17:09	1.258
+++ LVM2/lib/metadata/metadata.h	2011/10/19 16:39:09	1.259
@@ -455,7 +455,7 @@
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv);
 int detach_pool_lv(struct lv_segment *seg);
 int attach_pool_message(struct lv_segment *seg, dm_thin_message_t type,
-			struct logical_volume *lv, uint32_t device_id,
+			struct logical_volume *lv, uint32_t delete_id,
 			int read_only);
 int detach_pool_messages(struct lv_segment *seg);
 
--- LVM2/lib/metadata/thin_manip.c	2011/10/19 16:37:30	1.10
+++ LVM2/lib/metadata/thin_manip.c	2011/10/19 16:39:09	1.11
@@ -81,11 +81,36 @@
 }
 
 int attach_pool_message(struct lv_segment *seg, dm_thin_message_t type,
-			struct logical_volume *lv, uint32_t device_id,
+			struct logical_volume *lv, uint32_t delete_id,
 			int read_only)
 {
 	struct lv_thin_message *tmsg;
 
+	dm_list_iterate_items(tmsg, &seg->thin_messages) {
+		if (tmsg->type == type) {
+			switch (tmsg->type) {
+			case DM_THIN_MESSAGE_CREATE_SNAP:
+			case DM_THIN_MESSAGE_CREATE_THIN:
+			case DM_THIN_MESSAGE_TRIM:
+				if (tmsg->u.lv == lv) {
+					log_error("Message referring LV %s already queued for %s.",
+						  tmsg->u.lv->name, seg->lv->name);
+					return 0;
+				}
+				break;
+			case DM_THIN_MESSAGE_DELETE:
+				if (tmsg->u.delete_id == delete_id) {
+					log_error("Delete of device %u already queued for %s.",
+						  tmsg->u.delete_id, seg->lv->name);
+					return 0;
+				}
+				break;
+			default:
+				break;
+			}
+		}
+	}
+
 	if (!(tmsg = dm_pool_alloc(seg->lv->vg->vgmem, sizeof(*tmsg)))) {
 		log_error("Failed to allocate memory for message.");
 		return 0;
@@ -98,7 +123,7 @@
 		tmsg->u.lv = lv;
 		break;
 	case DM_THIN_MESSAGE_DELETE:
-		tmsg->u.delete_id = device_id;
+		tmsg->u.delete_id = delete_id;
 		break;
 	default:
 		log_error(INTERNAL_ERROR "Unsupported message type %d", type);



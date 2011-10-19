From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Oct 2011 16:37:31 -0000
Subject: LVM2/lib/metadata thin_manip.c
Message-ID: <20111019163731.4586.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-19 16:37:30

Modified files:
	lib/metadata   : thin_manip.c 

Log message:
	Drop messages referencing deleted LV
	
	lvremove may remove problematic LV for thin target.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/lib/metadata/thin_manip.c	2011/10/19 16:36:40	1.9
+++ LVM2/lib/metadata/thin_manip.c	2011/10/19 16:37:30	1.10
@@ -46,12 +46,32 @@
 
 int detach_pool_lv(struct lv_segment *seg)
 {
+	struct lv_thin_message *tmsg;
+	struct dm_list *l, *lt;
+
 	if (!lv_is_thin_pool(seg->pool_lv)) {
 		log_error(INTERNAL_ERROR "LV %s is not a thin pool",
 			  seg->pool_lv->name);
 		return 0;
 	}
 
+	/* Drop any message referencing removed segment */
+	dm_list_iterate_safe(l, lt, &first_seg(seg->pool_lv)->thin_messages) {
+		tmsg = dm_list_item(l, struct lv_thin_message);
+		switch (tmsg->type) {
+		case DM_THIN_MESSAGE_CREATE_SNAP:
+		case DM_THIN_MESSAGE_CREATE_THIN:
+		case DM_THIN_MESSAGE_TRIM:
+			if (first_seg(tmsg->u.lv) == seg) {
+				log_debug("Discarding message for LV %s.",
+					  tmsg->u.lv->name);
+				dm_list_del(&tmsg->list);
+			}
+		default:
+			break;
+		}
+	}
+
 	if (!attach_pool_message(first_seg(seg->pool_lv),
 				 DM_THIN_MESSAGE_DELETE,
 				 NULL, seg->device_id, 0))



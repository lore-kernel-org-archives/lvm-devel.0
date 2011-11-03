From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:36:42 -0000
Subject: LVM2/lib/metadata lv_manip.c thin_manip.c
Message-ID: <20111103143642.12128.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:36:41

Modified files:
	lib/metadata   : lv_manip.c thin_manip.c 

Log message:
	Thin code cleanup
	
	Use iterate_items for list processing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.316&r2=1.317
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/lib/metadata/lv_manip.c	2011/10/30 22:07:38	1.316
+++ LVM2/lib/metadata/lv_manip.c	2011/11/03 14:36:40	1.317
@@ -137,7 +137,8 @@
 		return NULL;
 	}
 
-	sl = dm_list_item(dm_list_first(&lv->segs_using_this_lv), struct seg_list);
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+		break; /* first item */
 
 	if (sl->count != 1) {
 		log_error("%s is expected to have only one segment using it, "
--- LVM2/lib/metadata/thin_manip.c	2011/10/30 22:52:08	1.17
+++ LVM2/lib/metadata/thin_manip.c	2011/11/03 14:36:40	1.18
@@ -49,18 +49,16 @@
 
 int detach_pool_lv(struct lv_segment *seg)
 {
-	struct lv_thin_message *tmsg;
-	struct dm_list *l, *lt;
+	struct lv_thin_message *tmsg, *tmp;
 
-	if (!lv_is_thin_pool(seg->pool_lv)) {
-		log_error(INTERNAL_ERROR "LV %s is not a thin pool",
-			  seg->pool_lv->name);
+	if (!seg->pool_lv || !lv_is_thin_pool(seg->pool_lv)) {
+		log_error(INTERNAL_ERROR "LV %s is not a thin volume",
+			  seg->lv->name);
 		return 0;
 	}
 
 	/* Drop any message referencing removed segment */
-	dm_list_iterate_safe(l, lt, &first_seg(seg->pool_lv)->thin_messages) {
-		tmsg = dm_list_item(l, struct lv_thin_message);
+	dm_list_iterate_items_safe(tmsg, tmp, &first_seg(seg->pool_lv)->thin_messages) {
 		switch (tmsg->type) {
 		case DM_THIN_MESSAGE_CREATE_SNAP:
 		case DM_THIN_MESSAGE_CREATE_THIN:
@@ -201,8 +199,8 @@
  */
 uint32_t get_free_pool_device_id(struct lv_segment *thin_pool_seg)
 {
-	uint32_t dev_id, max_id = 0;
-	struct dm_list *h;
+	uint32_t max_id = 0;
+	struct seg_list *sl;
 
 	if (!seg_is_thin_pool(thin_pool_seg)) {
 		log_error(INTERNAL_ERROR
@@ -211,11 +209,9 @@
 		return 0;
 	}
 
-	dm_list_iterate(h, &thin_pool_seg->lv->segs_using_this_lv) {
-		dev_id = dm_list_item(h, struct seg_list)->seg->device_id;
-		if (dev_id > max_id)
-			max_id = dev_id;
-	}
+	dm_list_iterate_items(sl, &thin_pool_seg->lv->segs_using_this_lv)
+		if (sl->seg->device_id > max_id)
+			max_id = sl->seg->device_id;
 
 	if (++max_id > DM_THIN_MAX_DEVICE_ID) {
 		// FIXME: try to find empty holes....



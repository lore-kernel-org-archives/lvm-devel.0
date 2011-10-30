From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Oct 2011 22:01:42 -0000
Subject: LVM2/lib/metadata lv_manip.c metadata-exported ...
Message-ID: <20111030220142.5430.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-30 22:01:40

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h metadata.h 
	                 thin_manip.c 

Log message:
	Make detach_pool_message visible for tools
	
	Move there also vg_write and vg_commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.313&r2=1.314
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.218&r2=1.219
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.262&r2=1.263
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/lib/metadata/lv_manip.c	2011/10/30 22:00:57	1.313
+++ LVM2/lib/metadata/lv_manip.c	2011/10/30 22:01:39	1.314
@@ -4221,13 +4221,10 @@
 	} else if (seg_is_thin_volume(lp)) {
 		/* FIXME: for now we may drop any queued thin messages
 		 * since we are sure everything was activated already */
-		if (!detach_pool_messages(first_seg(first_seg(lv)->pool_lv)))
+		if (!detach_pool_messages(first_seg(lv)->pool_lv)) {
+			stack;
 			goto deactivate_and_revert_new_lv;
-
-		if (!vg_write(vg) || !vg_commit(vg))
-			goto deactivate_and_revert_new_lv;
-
-		backup(vg);
+		}
 	}
 
 	if (lp->snapshot) {
--- LVM2/lib/metadata/metadata-exported.h	2011/10/28 20:28:01	1.218
+++ LVM2/lib/metadata/metadata-exported.h	2011/10/30 22:01:39	1.219
@@ -558,6 +558,8 @@
 uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
 
+int detach_pool_messages(struct logical_volume *pool_lv);
+
 /*
  * Activation options
  */
--- LVM2/lib/metadata/metadata.h	2011/10/28 20:32:54	1.262
+++ LVM2/lib/metadata/metadata.h	2011/10/30 22:01:39	1.263
@@ -461,7 +461,6 @@
 int attach_pool_message(struct lv_segment *seg, dm_thin_message_t type,
 			struct logical_volume *lv, uint32_t delete_id,
 			int read_only);
-int detach_pool_messages(struct lv_segment *seg);
 int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
 
--- LVM2/lib/metadata/thin_manip.c	2011/10/30 22:00:57	1.15
+++ LVM2/lib/metadata/thin_manip.c	2011/10/30 22:01:39	1.16
@@ -149,15 +149,22 @@
 	return 1;
 }
 
-int detach_pool_messages(struct lv_segment *seg)
+int detach_pool_messages(struct logical_volume *pool_lv)
 {
-	if (!lv_is_thin_pool(seg->lv)) {
+	if (!lv_is_thin_pool(pool_lv)) {
 		log_error(INTERNAL_ERROR "LV %s is not a thin pool.",
-			  seg->lv->name);
+			  pool_lv->name);
 		return 0;
 	}
 
-	dm_list_init(&seg->thin_messages);
+	if (!dm_list_empty(&first_seg(pool_lv)->thin_messages)) {
+		dm_list_init(&first_seg(pool_lv)->thin_messages);
+
+		if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
+			return_0;
+
+		backup(pool_lv->vg);
+	}
 
 	return 1;
 }



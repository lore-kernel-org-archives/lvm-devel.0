From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Oct 2011 16:36:41 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/thin ...
Message-ID: <20111019163641.32196.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-19 16:36:40

Modified files:
	lib/metadata   : lv_manip.c thin_manip.c 
	libdm          : libdm-deptree.c 

Log message:
	Just indent changes
	
	Some tabs & spaces.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.295&r2=1.296
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130

--- LVM2/lib/metadata/lv_manip.c	2011/10/17 14:17:09	1.295
+++ LVM2/lib/metadata/lv_manip.c	2011/10/19 16:36:39	1.296
@@ -511,6 +511,7 @@
 			/* FIXME Check this is safe */
 			if (seg->log_lv && !lv_remove(seg->log_lv))
 				return_0;
+
 			if (seg->pool_metadata_lv && !lv_remove(seg->pool_metadata_lv))
 				return_0;
 
--- LVM2/lib/metadata/thin_manip.c	2011/10/19 16:32:34	1.8
+++ LVM2/lib/metadata/thin_manip.c	2011/10/19 16:36:40	1.9
@@ -21,9 +21,9 @@
 {
 	seg->pool_metadata_lv = pool_metadata_lv;
 	pool_metadata_lv->status |= THIN_POOL_METADATA;
-        lv_set_hidden(pool_metadata_lv);
+	lv_set_hidden(pool_metadata_lv);
 
-        return add_seg_to_segs_using_this_lv(pool_metadata_lv, seg);
+	return add_seg_to_segs_using_this_lv(pool_metadata_lv, seg);
 }
 
 int attach_pool_data_lv(struct lv_segment *seg, struct logical_volume *pool_data_lv)
@@ -31,9 +31,9 @@
 	if (!set_lv_segment_area_lv(seg, 0, pool_data_lv, 0, THIN_POOL_DATA))
 		return_0;
 
-        lv_set_hidden(pool_data_lv);
+	lv_set_hidden(pool_data_lv);
 
-        return 1;
+	return 1;
 }
 
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv)
@@ -41,7 +41,7 @@
 	seg->pool_lv = pool_lv;
 	seg->lv->status |= THIN_VOLUME;
 
-        return add_seg_to_segs_using_this_lv(pool_lv, seg);
+	return add_seg_to_segs_using_this_lv(pool_lv, seg);
 }
 
 int detach_pool_lv(struct lv_segment *seg)
@@ -117,22 +117,22 @@
 
 struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 {
-        struct lv_segment *pool_seg;
+	struct lv_segment *pool_seg;
+
+	pool_seg = get_only_segment_using_this_lv(seg->lv);
 
-        pool_seg = get_only_segment_using_this_lv(seg->lv);
+	if (!pool_seg) {
+		log_error("Failed to find pool_seg for %s", seg->lv->name);
+		return NULL;
+	}
 
-        if (!pool_seg) {
-                log_error("Failed to find pool_seg for %s", seg->lv->name);
-                return NULL;
-        }
-
-        if (!seg_is_thin_pool(pool_seg)) {
-                log_error("%s on %s is not a pool segment",
-                          pool_seg->lv->name, seg->lv->name);
-                return NULL;
-        }
+	if (!seg_is_thin_pool(pool_seg)) {
+		log_error("%s on %s is not a pool segment",
+			  pool_seg->lv->name, seg->lv->name);
+		return NULL;
+	}
 
-        return pool_seg;
+	return pool_seg;
 }
 
 /*
--- LVM2/libdm/libdm-deptree.c	2011/10/19 16:36:01	1.129
+++ LVM2/libdm/libdm-deptree.c	2011/10/19 16:36:40	1.130
@@ -1342,7 +1342,6 @@
 		return 1;
 
 	seg = dm_list_item(dm_list_last(&dnode->props.segs), struct load_segment);
-
 	if (seg->type != SEG_THIN_POOL)
 		return 1;
 
@@ -2887,7 +2886,6 @@
 	}
 
 	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
-
 	if (seg->type != SEG_THIN_POOL) {
 		log_error(INTERNAL_ERROR "Attempt to use non thin pool segment %s.",
 			  dm_segtypes[seg->type].target);



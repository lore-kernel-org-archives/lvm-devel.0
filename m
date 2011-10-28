From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:32:55 -0000
Subject: LVM2/lib/metadata lv_manip.c metadata.h thin_m ...
Message-ID: <20111028203255.10555.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:32:54

Modified files:
	lib/metadata   : lv_manip.c metadata.h thin_manip.c 

Log message:
	Thin support for stripe
	
	Support stripe options to create thin data pool LV.
	
	TODO: combine chunk size and stripe size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.311&r2=1.312
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.261&r2=1.262
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/lib/metadata/lv_manip.c	2011/10/28 20:31:01	1.311
+++ LVM2/lib/metadata/lv_manip.c	2011/10/28 20:32:54	1.312
@@ -2570,7 +2570,7 @@
 
 	if (segtype_is_thin_pool(segtype)) {
 		if (!lv->le_count) {
-			if (!(r = extend_pool(lv, segtype, ah)))
+			if (!(r = extend_pool(lv, segtype, ah, stripes, stripe_size)))
 				stack;
 		} else if (!(r = _lv_extend_layered_lv(ah, lv, extents, 0,
 						       stripes, stripe_size)))
--- LVM2/lib/metadata/metadata.h	2011/10/22 16:44:23	1.261
+++ LVM2/lib/metadata/metadata.h	2011/10/28 20:32:54	1.262
@@ -463,7 +463,7 @@
 			int read_only);
 int detach_pool_messages(struct lv_segment *seg);
 int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
-		struct alloc_handle *ah);
+		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
 
 /*
  * Begin skeleton for external LVM library
--- LVM2/lib/metadata/thin_manip.c	2011/10/22 16:44:23	1.13
+++ LVM2/lib/metadata/thin_manip.c	2011/10/28 20:32:54	1.14
@@ -220,7 +220,7 @@
 }
 
 int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segtype,
-		struct alloc_handle *ah)
+		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size)
 {
 	const struct segment_type *striped;
 	struct logical_volume *meta_lv, *data_lv;
@@ -245,7 +245,7 @@
 	}
 
 	/* Metadata segment */
-	if (!lv_add_segment(ah, 1, 1, pool_lv, striped, 1, 0, 0))
+	if (!lv_add_segment(ah, stripes, 1, pool_lv, striped, 1, 0, 0))
 		return_0;
 
 	if (activation()) {
@@ -290,7 +290,7 @@
 		return_0;
 
 	/* Pool data segment */
-	if (!lv_add_segment(ah, 0, 1, pool_lv, striped, 1, 0, 0))
+	if (!lv_add_segment(ah, 0, stripes, pool_lv, striped, stripe_size, 0, 0))
 		return_0;
 
 	if (!(data_lv = insert_layer_for_lv(pool_lv->vg->cmd, pool_lv,



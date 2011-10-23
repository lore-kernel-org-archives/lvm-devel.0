From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Oct 2011 16:02:04 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/import-extents.c ...
Message-ID: <20111023160204.28767.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-23 16:02:02

Modified files:
	.              : WHATS_NEW 
	lib/format1    : import-extents.c 
	lib/format_pool: import_export.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : lv_alloc.h lv_manip.c merge.c 

Log message:
	Always use vg memory pool for allocated lv segment
	
	Remove mem pool parameter from alloc_lv_segment()
	Since we should always allocate LV segment from the vg mempool.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2168&r2=1.2169
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.303&r2=1.304
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2011/10/22 16:52:00	1.2168
+++ LVM2/WHATS_NEW	2011/10/23 16:02:01	1.2169
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Always use vg memory pool for allocated lv segment.
   Remove extra 4kB buffer allocated on stack in print_log().
   Make move_lv_segment non-static function and use dm_list function.
   Pass exclusive LV locks to all nodes in the cluster.
--- LVM2/lib/format1/import-extents.c	2011/09/06 00:26:42	1.41
+++ LVM2/lib/format1/import-extents.c	2011/10/23 16:02:01	1.42
@@ -222,8 +222,8 @@
 	while (le < lvm->lv->le_count) {
 		len = _area_length(lvm, le);
 
-		if (!(seg = alloc_lv_segment(cmd->mem, segtype, lvm->lv, le,
-					     len, 0, 0, NULL, NULL, 1, len, 0, 0, 0, NULL))) {
+		if (!(seg = alloc_lv_segment(segtype, lvm->lv, le, len, 0, 0,
+					     NULL, NULL, 1, len, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate linear segment.");
 			return 0;
 		}
@@ -292,7 +292,7 @@
 				     area_len, first_area_le, total_area_len))
 			area_len++;
 
-		if (!(seg = alloc_lv_segment(cmd->mem, segtype, lvm->lv,
+		if (!(seg = alloc_lv_segment(segtype, lvm->lv,
 					     lvm->stripes * first_area_le,
 					     lvm->stripes * area_len,
 					     0, lvm->stripe_size, NULL, NULL,
--- LVM2/lib/format_pool/import_export.c	2011/09/06 00:26:42	1.34
+++ LVM2/lib/format_pool/import_export.c	2011/10/23 16:02:01	1.35
@@ -193,7 +193,7 @@
 						     "striped")))
 		return_0;
 
-	if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur,
+	if (!(seg = alloc_lv_segment(segtype, lv, *le_cur,
 				     area_len * usp->num_devs, 0,
 				     usp->striping, NULL, NULL, usp->num_devs,
 				     area_len, 0, 0, 0, NULL))) {
@@ -233,7 +233,7 @@
 	for (j = 0; j < usp->num_devs; j++) {
 		area_len = (usp->devs[j].blocks) / POOL_PE_SIZE;
 
-		if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur,
+		if (!(seg = alloc_lv_segment(segtype, lv, *le_cur,
 					     area_len, 0, usp->striping,
 					     NULL, NULL, 1, area_len,
 					     POOL_PE_SIZE, 0, 0, NULL))) {
--- LVM2/lib/format_text/import_vsn1.c	2011/09/06 00:26:43	1.93
+++ LVM2/lib/format_text/import_vsn1.c	2011/10/23 16:02:02	1.94
@@ -328,7 +328,7 @@
 	    !segtype->ops->text_import_area_count(sn_child, &area_count))
 		return_0;
 
-	if (!(seg = alloc_lv_segment(mem, segtype, lv, start_extent,
+	if (!(seg = alloc_lv_segment(segtype, lv, start_extent,
 				     extent_count, 0, 0, NULL, NULL, area_count,
 				     extent_count, 0, 0, 0, NULL))) {
 		log_error("Segment allocation failed");
--- LVM2/lib/metadata/lv_alloc.h	2011/09/06 00:26:43	1.30
+++ LVM2/lib/metadata/lv_alloc.h	2011/10/23 16:02:02	1.31
@@ -15,8 +15,7 @@
 
 #ifndef _LVM_LV_ALLOC_H
 
-struct lv_segment *alloc_lv_segment(struct dm_pool *mem,
-				    const struct segment_type *segtype,
+struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 				    struct logical_volume *lv,
 				    uint32_t le, uint32_t len,
 				    uint64_t status,
--- LVM2/lib/metadata/lv_manip.c	2011/10/22 16:48:59	1.303
+++ LVM2/lib/metadata/lv_manip.c	2011/10/23 16:02:02	1.304
@@ -201,8 +201,7 @@
 /*
  * All lv_segments get created here.
  */
-struct lv_segment *alloc_lv_segment(struct dm_pool *mem,
-				    const struct segment_type *segtype,
+struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 				    struct logical_volume *lv,
 				    uint32_t le, uint32_t len,
 				    uint64_t status,
@@ -217,6 +216,7 @@
 				    struct lv_segment *pvmove_source_seg)
 {
 	struct lv_segment *seg;
+	struct dm_pool *mem = lv->vg->vgmem;
 	uint32_t areas_sz = area_count * sizeof(*seg->areas);
 
 	if (!segtype) {
@@ -277,7 +277,7 @@
 		return NULL;
 	}
 
-	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv, old_le_count,
+	if (!(seg = alloc_lv_segment(segtype, lv, old_le_count,
 				     lv->le_count - old_le_count, status, 0,
 				     NULL, NULL, 0, lv->le_count - old_le_count,
 				     0, 0, 0, NULL))) {
@@ -954,8 +954,7 @@
 
 	area_multiple = _calc_area_multiple(segtype, area_count, 0);
 
-	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
-				     lv->le_count,
+	if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count,
 				     aa[0].len * area_multiple,
 				     status, stripe_size, NULL, NULL,
 				     area_count,
@@ -2044,9 +2043,9 @@
 		thin_pool_lv = lvl->lv;
 	}
 
-	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
-				     lv->le_count, extents, status, 0,
-				     NULL, thin_pool_lv, 0, extents, 0, 0, 0, NULL))) {
+	if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents,
+				     status, 0, NULL, thin_pool_lv, 0,
+				     extents, 0, 0, 0, NULL))) {
 		log_error("Couldn't allocate new zero segment.");
 		return 0;
 	}
@@ -2178,8 +2177,7 @@
 		return NULL;
 	}
 
-	if (!(newseg = alloc_lv_segment(seg->lv->vg->cmd->mem,
-					get_segtype_from_string(seg->lv->vg->cmd, "mirror"),
+	if (!(newseg = alloc_lv_segment(get_segtype_from_string(seg->lv->vg->cmd, "mirror"),
 					seg->lv, seg->le, seg->len,
 					seg->status, seg->stripe_size,
 					log_lv, NULL,
@@ -2375,8 +2373,8 @@
 	/*
 	 * First, create our top-level segment for our top-level LV
 	 */
-	if (!(mapseg = alloc_lv_segment(lv->vg->cmd->mem, segtype,
-					lv, 0, 0, lv->status, stripe_size, NULL, NULL,
+	if (!(mapseg = alloc_lv_segment(segtype, lv, 0, 0, lv->status,
+					stripe_size, NULL, NULL,
 					devices, 0, 0, region_size, 0, NULL))) {
 		log_error("Failed to create mapping segment for %s", lv->name);
 		return 0;
@@ -3593,8 +3591,7 @@
 		return_NULL;
 
 	/* allocate a new linear segment */
-	if (!(mapseg = alloc_lv_segment(cmd->mem, segtype,
-					lv_where, 0, layer_lv->le_count,
+	if (!(mapseg = alloc_lv_segment(segtype, lv_where, 0, layer_lv->le_count,
 					status, 0, NULL, NULL, 1, layer_lv->le_count,
 					0, 0, 0, NULL)))
 		return_NULL;
@@ -3636,8 +3633,7 @@
 			 seg->lv->vg->name, seg->lv->name);
 
 	/* allocate a new segment */
-	if (!(mapseg = alloc_lv_segment(layer_lv->vg->cmd->mem, segtype,
-					layer_lv, layer_lv->le_count,
+	if (!(mapseg = alloc_lv_segment(segtype, layer_lv, layer_lv->le_count,
 					seg->area_len, status, 0,
 					NULL, NULL, 1, seg->area_len, 0, 0, 0, seg)))
 		return_0;
--- LVM2/lib/metadata/merge.c	2011/10/20 10:28:41	1.53
+++ LVM2/lib/metadata/merge.c	2011/10/23 16:02:02	1.54
@@ -433,7 +433,7 @@
 	}
 
 	/* Clone the existing segment */
-	if (!(split_seg = alloc_lv_segment(lv->vg->vgmem, seg->segtype,
+	if (!(split_seg = alloc_lv_segment(seg->segtype,
 					   seg->lv, seg->le, seg->len,
 					   seg->status, seg->stripe_size,
 					   seg->log_lv, seg->pool_lv,



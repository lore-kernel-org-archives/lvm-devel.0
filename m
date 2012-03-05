From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Mar 2012 15:05:26 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20120305150526.24433.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-05 15:05:25

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/metadata   : lv_manip.c pv_manip.c 
	tools          : lvresize.c 

Log message:
	Some more missing supposedly 64bit operations.
	
	Avoid use 32bit math for extent_size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2344&r2=1.2345
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.274&r2=1.275
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.371&r2=1.372
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151

--- LVM2/WHATS_NEW	2012/03/05 14:19:13	1.2344
+++ LVM2/WHATS_NEW	2012/03/05 15:05:24	1.2345
@@ -2,7 +2,7 @@
 ================================
   Try to fit thin pool metadata size into 128MB.
   Print just warning on thin pool check callback path for failing check.
-  Use 64bit math for verification of thin pool and snapshot chunk size.
+  Always use 64bit math with VG extent_size expression.
   Validate udev structures in _insert_udev_dir().
   Scan all devices for lvmetad if 'pvscan --cache' used without device list.
   Populate lvmcache from lvmetad before displaying PVs in pvscan. (2.02.94)
--- LVM2/lib/activate/dev_manager.c	2012/03/05 14:15:50	1.274
+++ LVM2/lib/activate/dev_manager.c	2012/03/05 15:05:25	1.275
@@ -1412,7 +1412,7 @@
 	struct dm_tree_node *node;
 	struct lv_segment *seg_i;
 	int segno = -1, i = 0;
-	uint64_t size = seg->len * seg->lv->vg->extent_size;
+	uint64_t size = (uint64_t) seg->len * seg->lv->vg->extent_size;
 
 	dm_list_iterate_items(seg_i, &seg->lv->segments) {
 		if (seg == seg_i)
--- LVM2/lib/metadata/lv_manip.c	2012/03/05 14:12:57	1.371
+++ LVM2/lib/metadata/lv_manip.c	2012/03/05 15:05:25	1.372
@@ -3768,7 +3768,7 @@
 	/* add the new segment to the layer LV */
 	dm_list_add(&lv_where->segments, &mapseg->list);
 	lv_where->le_count = layer_lv->le_count;
-	lv_where->size = lv_where->le_count * lv_where->vg->extent_size;
+	lv_where->size = (uint64_t) lv_where->le_count * lv_where->vg->extent_size;
 
 	return layer_lv;
 }
@@ -3810,7 +3810,7 @@
 	/* add the new segment to the layer LV */
 	dm_list_add(&layer_lv->segments, &mapseg->list);
 	layer_lv->le_count += seg->area_len;
-	layer_lv->size += seg->area_len * layer_lv->vg->extent_size;
+	layer_lv->size += (uint64_t) seg->area_len * layer_lv->vg->extent_size;
 
 	/* map the original area to the new segment */
 	if (!set_lv_segment_area_lv(seg, s, layer_lv, mapseg->le, 0))
--- LVM2/lib/metadata/pv_manip.c	2012/03/01 21:49:32	1.32
+++ LVM2/lib/metadata/pv_manip.c	2012/03/05 15:05:25	1.33
@@ -210,7 +210,7 @@
 	    dev_discard_max_bytes(peg->pv->fmt->cmd->sysfs_dir, peg->pv->dev) &&
 	    dev_discard_granularity(peg->pv->fmt->cmd->sysfs_dir, peg->pv->dev)) {
 		discard_offset_sectors = (peg->pe + peg->lvseg->area_len - area_reduction) *
-			peg->pv->vg->extent_size + pe_start;
+			(uint64_t) peg->pv->vg->extent_size + pe_start;
 		if (!discard_offset_sectors) {
 			/*
 			 * pe_start=0 and the PV's first extent contains the label.
@@ -223,7 +223,7 @@
 			  discard_area_reduction, discard_offset_sectors, dev_name(peg->pv->dev));
 		if (discard_area_reduction &&
 		    !dev_discard_blocks(peg->pv->dev, discard_offset_sectors << SECTOR_SHIFT,
-					discard_area_reduction * peg->pv->vg->extent_size * SECTOR_SIZE))
+					discard_area_reduction * (uint64_t) peg->pv->vg->extent_size * SECTOR_SIZE))
 			return_0;
 	}
 
--- LVM2/tools/lvresize.c	2012/02/28 14:24:58	1.150
+++ LVM2/tools/lvresize.c	2012/03/05 15:05:25	1.151
@@ -63,7 +63,7 @@
 
 	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
 		log_warn("Varied stripesize not supported. Ignoring.");
-	else if (arg_uint_value(cmd, stripesize_ARG, 0) > vg->extent_size * 2) {
+	else if (arg_uint_value(cmd, stripesize_ARG, 0) > (uint64_t) vg->extent_size * 2) {
 		log_error("Reducing stripe size %s to maximum, "
 			  "physical extent size %s",
 			  display_size(cmd,
@@ -463,7 +463,7 @@
 				    (lp->size % vg->extent_size);
 
 			log_print("Rounding up size to full physical extent %s",
-				  display_size(cmd, (uint64_t) lp->size));
+				  display_size(cmd, lp->size));
 		}
 
 		lp->extents = lp->size / vg->extent_size;



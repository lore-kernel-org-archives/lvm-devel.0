From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jan 2012 00:55:05 -0000
Subject: LVM2/lib display/display.c metadata/lv.c metad ...
Message-ID: <20120124005505.18327.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-24 00:55:04

Modified files:
	lib/display    : display.c 
	lib/metadata   : lv.c lv_manip.c merge.c metadata-exported.h 
	lib/thin       : thin.c 

Log message:
	Use chunk_size consistently for thin_pool within LVM.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.345&r2=1.346
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.226&r2=1.227
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/lib/display/display.c	2012/01/20 16:59:59	1.125
+++ LVM2/lib/display/display.c	2012/01/24 00:55:03	1.126
@@ -607,7 +607,7 @@
 		log_print("LV Pool metadata       %s", seg->metadata_lv->name);
 		log_print("LV Pool data           %s", seg_lv(seg, 0)->name);
 		log_print("LV Pool chunk size     %s",
-			  display_size(cmd, seg->data_block_size));
+			  display_size(cmd, seg->chunk_size));
 		log_print("LV Zero new blocks     %s",
 			  seg->zero_new_blocks ? "yes" : "no");
 	}
--- LVM2/lib/metadata/lv.c	2012/01/20 22:03:04	1.35
+++ LVM2/lib/metadata/lv.c	2012/01/24 00:55:03	1.36
@@ -126,7 +126,7 @@
 	if (lv_is_cow(seg->lv))
 		size = (uint64_t) find_cow(seg->lv)->chunk_size;
 	else if (lv_is_thin_pool(seg->lv))
-		size = (uint64_t) seg->data_block_size;
+		size = (uint64_t) seg->chunk_size;
 	else
 		size = UINT64_C(0);
 
--- LVM2/lib/metadata/lv_manip.c	2012/01/20 22:04:16	1.345
+++ LVM2/lib/metadata/lv_manip.c	2012/01/24 00:55:03	1.346
@@ -2060,7 +2060,7 @@
 			return 0;
 		}
 		thin_pool_lv = lvl->lv;
-		size = first_seg(thin_pool_lv)->data_block_size;
+		size = first_seg(thin_pool_lv)->chunk_size;
 		if (lv->vg->extent_size < size) {
 			/* Align extents on chunk boundary size */
 			size = ((uint64_t)lv->vg->extent_size * extents + size - 1) /
@@ -4290,7 +4290,7 @@
 
 	if (seg_is_thin_pool(lp)) {
 		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
-		first_seg(lv)->data_block_size = lp->chunk_size;
+		first_seg(lv)->chunk_size = lp->chunk_size;
 		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
 		first_seg(lv)->low_water_mark = 0;
 	} else if (seg_is_thin_volume(lp)) {
--- LVM2/lib/metadata/merge.c	2012/01/19 15:23:51	1.56
+++ LVM2/lib/metadata/merge.c	2012/01/24 00:55:03	1.57
@@ -202,10 +202,10 @@
 					inc_error_count;
 				}
 
-				if (seg->data_block_size < DM_THIN_MIN_DATA_BLOCK_SIZE ||
-				    seg->data_block_size > DM_THIN_MAX_DATA_BLOCK_SIZE) {
-					log_error("LV %s: thin pool segment %u  data block size %d is out of range",
-						  lv->name, seg_count, seg->data_block_size);
+				if (seg->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE ||
+				    seg->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE) {
+					log_error("LV %s: thin pool segment %u  chunk size %d is out of range",
+						  lv->name, seg_count, seg->chunk_size);
 					inc_error_count;
 				}
 			} else {
--- LVM2/lib/metadata/metadata-exported.h	2012/01/19 15:23:51	1.226
+++ LVM2/lib/metadata/metadata-exported.h	2012/01/24 00:55:04	1.227
@@ -331,7 +331,8 @@
 	uint32_t stripe_size;	/* For stripe and RAID - in sectors */
 	uint32_t area_count;
 	uint32_t area_len;
-	uint32_t chunk_size;	/* For snapshots - in sectors */
+	uint32_t chunk_size;	/* For snapshots/thin_pool.  In sectors. */
+				/* For thin_pool, 128..2097152. */
 	struct logical_volume *origin;	/* snap and thin */
 	struct logical_volume *cow;
 	struct dm_list origin_list;
@@ -348,7 +349,6 @@
 	struct logical_volume *metadata_lv;	/* For thin_pool */
 	uint64_t transaction_id;		/* For thin_pool, thin */
 	uint64_t low_water_mark;		/* For thin_pool */
-	uint32_t data_block_size;		/* For thin_pool, 128..2097152 */
 	unsigned zero_new_blocks;		/* For thin_pool */
 	struct dm_list thin_messages;		/* For thin_pool */
 	struct logical_volume *pool_lv;		/* For thin */
--- LVM2/lib/thin/thin.c	2012/01/19 15:42:18	1.41
+++ LVM2/lib/thin/thin.c	2012/01/24 00:55:04	1.42
@@ -115,16 +115,16 @@
 	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
 		return SEG_LOG_ERROR("Could not read transaction_id for");
 
-	if (!dm_config_get_uint32(sn, "data_block_size", &seg->data_block_size))
-		return SEG_LOG_ERROR("Could not read data_block_size");
+	if (!dm_config_get_uint32(sn, "chunk_size", &seg->chunk_size))
+		return SEG_LOG_ERROR("Could not read chunk_size");
 
 	if (dm_config_has_node(sn, "low_water_mark") &&
 	    !dm_config_get_uint64(sn, "low_water_mark", &seg->low_water_mark))
 		return SEG_LOG_ERROR("Could not read low_water_mark");
 
-	if ((seg->data_block_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
-	    (seg->data_block_size > DM_THIN_MAX_DATA_BLOCK_SIZE))
-		return SEG_LOG_ERROR("Unsupported value %u for data_block_size",
+	if ((seg->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
+	    (seg->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE))
+		return SEG_LOG_ERROR("Unsupported value %u for chunk_size",
 				     seg->device_id);
 
 	if (dm_config_has_node(sn, "zero_new_blocks") &&
@@ -155,9 +155,8 @@
 	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
 	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
-// FIXME  maybe switch to use  chunksize (as with snapshot ??)
-	outsize(f, (uint64_t) seg->data_block_size,
-		"data_block_size = %u", seg->data_block_size);
+	outsize(f, (uint64_t) seg->chunk_size,
+		"chunk_size = %u", seg->chunk_size);
 
 	if (seg->low_water_mark)
 		outf(f, "low_water_mark = %" PRIu64, seg->low_water_mark);
@@ -254,7 +253,7 @@
 
 	if (!dm_tree_node_add_thin_pool_target(node, len, seg->transaction_id,
 					       metadata_dlid, pool_dlid,
-					       seg->data_block_size, seg->low_water_mark,
+					       seg->chunk_size, seg->low_water_mark,
 					       seg->zero_new_blocks ? 0 : 1))
 		return_0;
 



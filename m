From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Oct 2011 09:55:08 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/thin/thin.c m ...
Message-ID: <20111021095508.23497.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-21 09:55:07

Modified files:
	lib/metadata   : lv_manip.c 
	lib/thin       : thin.c 
	man            : lvcreate.8.in 
	tools          : lvcreate.c 

Log message:
	Thin pool now support chunk size as well
	
	Use chunksize option to specify data_block_size for thin pool target.
	Drop low_water_mark to zero.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.297&r2=1.298
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.243&r2=1.244

--- LVM2/lib/metadata/lv_manip.c	2011/10/20 10:35:14	1.297
+++ LVM2/lib/metadata/lv_manip.c	2011/10/21 09:55:07	1.298
@@ -4160,9 +4160,12 @@
 		       seg_is_thin_volume(lp) ? lp->pool : NULL, lp->pvh, lp->alloc))
 		return_NULL;
 
-	if (seg_is_thin_pool(lp) && lp->zero)
-		first_seg(lv)->zero_new_blocks = 1;
-	else if (seg_is_thin_volume(lp)) {
+	if (seg_is_thin_pool(lp)) {
+		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
+		first_seg(lv)->data_block_size = lp->chunk_size;
+		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
+		first_seg(lv)->low_water_mark = 0;
+	} else if (seg_is_thin_volume(lp)) {
 		pool_lv = first_seg(lv)->pool_lv;
 
 		if (!(first_seg(lv)->device_id =
@@ -4184,13 +4187,6 @@
 		 */
 	}
 
-	if (seg_is_thin_pool(lp)) {
-		/* FIXME: add lvcreate params - maybe -c/--chunksize?,
-		 * use lowwatermark  via lvm.conf global for all thinpools ?*/
-		first_seg(lv)->data_block_size = 128;
-		first_seg(lv)->low_water_mark = 4096;
-	}
-
 	if (lp->log_count &&
 	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
 		if (!add_mirror_log(cmd, lv, lp->log_count,
@@ -4217,7 +4213,9 @@
 	if (seg_is_thin_pool(lp)) {
 		/* FIXME: skipping in test mode is not going work */
 		if (!activate_lv_excl(cmd, first_seg(lv)->pool_metadata_lv) ||
-		    /* First 4KB of metadata device must be cleared. */
+		    /* Clear 4KB of metadata device for new thin-pool. */
+		    // FIXME: maybe -zero n  should  allow to recreate same thin pool
+		    // and different option should be used for zero_new_blocks
 		    !set_lv(cmd, first_seg(lv)->pool_metadata_lv, UINT64_C(0), 0)) {
 			log_error("Aborting. Failed to wipe pool metadata %s.",
 				  lv->name);
--- LVM2/lib/thin/thin.c	2011/10/20 10:32:29	1.22
+++ LVM2/lib/thin/thin.c	2011/10/21 09:55:07	1.23
@@ -155,7 +155,7 @@
 	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->pool_metadata_lv->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
-	outf(f, "data_block_size = %d", seg->data_block_size);
+	outf(f, "data_block_size = %u", seg->data_block_size);
 
 	if (seg->low_water_mark)
 		outf(f, "low_water_mark = %" PRIu64, seg->low_water_mark);
--- LVM2/man/lvcreate.8.in	2011/10/21 09:53:16	1.24
+++ LVM2/man/lvcreate.8.in	2011/10/21 09:55:07	1.25
@@ -132,6 +132,8 @@
 Power of 2 chunk size in sector units (512b).
 For snapshot logical volume the value must be between 8 (4KB) and 1024 (512KB)
 and the default value is 8.
+For thin pool logical volume the value must be between 128 (64KB) and
+2097152 (1MB) and the default value is 128.
 .TP
 .BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
 Sets or resets the contiguous allocation policy for
--- LVM2/tools/lvcreate.c	2011/09/27 12:37:07	1.243
+++ LVM2/tools/lvcreate.c	2011/10/21 09:55:07	1.244
@@ -690,14 +690,26 @@
 			log_error("Negative chunk size is invalid");
 			return 0;
 		}
-		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
-		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
-		    (lp->chunk_size & (lp->chunk_size - 1))) {
-			log_error("Chunk size must be a power of 2 in the "
-				  "range 4K to 512K");
-			return 0;
+		if (lp->snapshot) {
+			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
+			if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
+			    (lp->chunk_size & (lp->chunk_size - 1))) {
+				log_error("Chunk size must be a power of 2 in the "
+					  "range 4K to 512K");
+				return 0;
+			}
+		} else {
+			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, DM_THIN_MIN_DATA_BLOCK_SIZE);
+			if ((lp->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
+			    (lp->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE) ||
+			    (lp->chunk_size & (lp->chunk_size - 1))) {
+				log_error("Chunk size must be a power of 2 in the "
+					  "range %uK to %uK", (DM_THIN_MIN_DATA_BLOCK_SIZE / 2),
+					  (DM_THIN_MIN_DATA_BLOCK_SIZE / 2));
+				return 0;
+			}
 		}
-		log_verbose("Setting chunksize to %d sectors.", lp->chunk_size);
+		log_verbose("Setting chunksize to %u sectors.", lp->chunk_size);
 
 		if (!lp->thin && lp->snapshot && !(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
 			return_0;



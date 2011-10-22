From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Oct 2011 16:45:26 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20111022164526.8793.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-22 16:45:25

Modified files:
	lib/thin       : thin.c 

Log message:
	Consistently use metadata LV as the first in MDA
	
	Cosmetic cleanup.
	Mark LV as thin pool before calling attach_pool functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/lib/thin/thin.c	2011/10/21 11:38:36	1.24
+++ LVM2/lib/thin/thin.c	2011/10/22 16:45:25	1.25
@@ -92,34 +92,35 @@
 	const char *lv_name;
 	struct logical_volume *pool_data_lv, *pool_metadata_lv;
 
-	if (!dm_config_get_str(sn, "pool", &lv_name))
-		return SEG_LOG_ERROR("Pool must be a string in");
-
-	if (!(pool_data_lv = find_lv(seg->lv->vg, lv_name)))
-		return SEG_LOG_ERROR("Unknown pool %s in", lv_name);
-
 	if (!dm_config_get_str(sn, "metadata", &lv_name))
 		return SEG_LOG_ERROR("Metadata must be a string in");
 
 	if (!(pool_metadata_lv = find_lv(seg->lv->vg, lv_name)))
 		return SEG_LOG_ERROR("Unknown metadata %s in", lv_name);
 
-	if (!attach_pool_data_lv(seg, pool_data_lv))
-		return_0;
+	if (!dm_config_get_str(sn, "pool", &lv_name))
+		return SEG_LOG_ERROR("Pool must be a string in");
 
+	if (!(pool_data_lv = find_lv(seg->lv->vg, lv_name)))
+		return SEG_LOG_ERROR("Unknown pool %s in", lv_name);
+
+	seg->lv->status |= THIN_POOL;
 	if (!attach_pool_metadata_lv(seg, pool_metadata_lv))
 		return_0;
 
+	if (!attach_pool_data_lv(seg, pool_data_lv))
+		return_0;
+
 	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
 		return SEG_LOG_ERROR("Could not read transaction_id for");
 
+	if (!dm_config_get_uint32(sn, "data_block_size", &seg->data_block_size))
+		return SEG_LOG_ERROR("Could not read data_block_size");
+
 	if (dm_config_has_node(sn, "low_water_mark") &&
 	    !dm_config_get_uint64(sn, "low_water_mark", &seg->low_water_mark))
 		return SEG_LOG_ERROR("Could not read low_water_mark");
 
-	if (!dm_config_get_uint32(sn, "data_block_size", &seg->data_block_size))
-		return SEG_LOG_ERROR("Could not read data_block_size");
-
 	if ((seg->data_block_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
 	    (seg->data_block_size > DM_THIN_MAX_DATA_BLOCK_SIZE))
 		return SEG_LOG_ERROR("Unsupported value %u for data_block_size",
@@ -129,8 +130,6 @@
 	    !dm_config_get_uint32(sn, "zero_new_blocks", &seg->zero_new_blocks))
 		return SEG_LOG_ERROR("Could not read zero_new_blocks for");
 
-	seg->lv->status |= THIN_POOL;
-
 	/* Read messages */
 	for (; sn; sn = sn->sib)
 		if (!(sn->v) && !_thin_pool_add_message(seg, sn->key, sn->child))
@@ -152,9 +151,10 @@
 	unsigned cnt = 0;
 	const struct lv_thin_message *tmsg;
 
-	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->pool_metadata_lv->name);
+	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
+// FIXME  maybe switch to use  chunksize (as with snapshot ??)
 	outf(f, "data_block_size = %u", seg->data_block_size);
 
 	if (seg->low_water_mark)



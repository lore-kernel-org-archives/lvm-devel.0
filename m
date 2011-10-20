From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 10:30:39 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20111020103039.29421.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 10:30:39

Modified files:
	lib/thin       : thin.c 

Log message:
	Print low_water_mark only when it has some value
	
	Do not expose low_water_mark in mda yet, if it has no use.
	We do not allow to be set via current lvm tool code.
	Usage needs to be clarified first.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/lib/thin/thin.c	2011/10/20 10:28:41	1.19
+++ LVM2/lib/thin/thin.c	2011/10/20 10:30:39	1.20
@@ -113,7 +113,8 @@
 	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
 		return SEG_LOG_ERROR("Could not read transaction_id for");
 
-	if (!dm_config_get_uint64(sn, "low_water_mark", &seg->low_water_mark))
+	if (dm_config_has_node(sn, "low_water_mark") &&
+	    !dm_config_get_uint64(sn, "low_water_mark", &seg->low_water_mark))
 		return SEG_LOG_ERROR("Could not read low_water_mark");
 
 	if (!dm_config_get_uint32(sn, "data_block_size", &seg->data_block_size))
@@ -154,9 +155,11 @@
 	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->pool_metadata_lv->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
-	outf(f, "low_water_mark = %" PRIu64, seg->low_water_mark);
 	outf(f, "data_block_size = %d", seg->data_block_size);
 
+	if (seg->low_water_mark)
+		outf(f, "low_water_mark = %" PRIu64, seg->low_water_mark);
+
 	if (seg->zero_new_blocks)
 		outf(f, "zero_new_blocks = 1");
 



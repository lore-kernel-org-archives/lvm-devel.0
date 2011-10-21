From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Oct 2011 11:38:36 -0000
Subject: LVM2/lib metadata/lv_manip.c metadata/metadata ...
Message-ID: <20111021113836.13836.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-21 11:38:36

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h 
	lib/thin       : thin.c 

Log message:
	Store transaction_id with created thin lv
	
	So we know the creation history and this should be useful with vgcfgrestore.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.299&r2=1.300
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.215&r2=1.216
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/lib/metadata/lv_manip.c	2011/10/21 09:55:50	1.299
+++ LVM2/lib/metadata/lv_manip.c	2011/10/21 11:38:35	1.300
@@ -253,8 +253,11 @@
 	dm_list_init(&seg->tags);
 	dm_list_init(&seg->thin_messages);
 
-	if (thin_pool_lv && !attach_pool_lv(seg, thin_pool_lv))
-		return_NULL;
+	if (thin_pool_lv) {
+		seg->transaction_id = first_seg(thin_pool_lv)->transaction_id;
+		if (!attach_pool_lv(seg, thin_pool_lv))
+			return_NULL;
+	}
 
 	if (log_lv && !attach_mirror_log(seg, log_lv))
 		return_NULL;
--- LVM2/lib/metadata/metadata-exported.h	2011/10/17 14:17:09	1.215
+++ LVM2/lib/metadata/metadata-exported.h	2011/10/21 11:38:35	1.216
@@ -343,7 +343,7 @@
 	struct lv_segment_area *areas;
 	struct lv_segment_area *meta_areas;	/* For RAID */
 	struct logical_volume *pool_metadata_lv;/* For thin_pool */
-	uint64_t transaction_id;		/* For thin_pool */
+	uint64_t transaction_id;		/* For thin_pool, thin */
 	uint64_t low_water_mark;		/* For thin_pool */
 	uint32_t data_block_size;		/* For thin_pool, 128..2097152 */
 	unsigned zero_new_blocks;		/* For thin_pool */
--- LVM2/lib/thin/thin.c	2011/10/21 09:55:07	1.23
+++ LVM2/lib/thin/thin.c	2011/10/21 11:38:36	1.24
@@ -310,6 +310,9 @@
 	if (!attach_pool_lv(seg, pool_lv))
 		return_0;
 
+	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
+		return SEG_LOG_ERROR("Could not read transaction_id for");
+
 	if (dm_config_has_node(sn, "origin")) {
 		if (!dm_config_get_str(sn, "origin", &lv_name))
 			return SEG_LOG_ERROR("Origin must be a string in");
@@ -331,6 +334,7 @@
 static int _thin_text_export(const struct lv_segment *seg, struct formatter *f)
 {
 	outf(f, "thin_pool = \"%s\"", seg->pool_lv->name);
+	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
 	outf(f, "device_id = %d", seg->device_id);
 
 	if (seg->origin)



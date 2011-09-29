From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Sep 2011 08:56:40 -0000
Subject: LVM2/lib activate/dev_manager.c metadata/lv_ma ...
Message-ID: <20110929085640.15316.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-29 08:56:39

Modified files:
	lib/activate   : dev_manager.c 
	lib/metadata   : lv_manip.c merge.c metadata-exported.h 
	lib/thin       : thin.c 

Log message:
	Add experimental code for activation of thinp targets
	
	No dm messages yes - just a base functionality in the steps of other targets.
	For now usable only for debugging and tracing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.233&r2=1.234
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.291&r2=1.292
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.212&r2=1.213
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/lib/activate/dev_manager.c	2011/09/27 22:43:41	1.233
+++ LVM2/lib/activate/dev_manager.c	2011/09/29 08:56:38	1.234
@@ -1485,7 +1485,13 @@
 	} else if (lv_is_cow(seg->lv) && !layer) {
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
+	} else if (lv_is_thin_volume(seg->lv)) {
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->pool_lv, laopts, NULL))
+			return_0;
 	} else {
+		if (lv_is_thin_pool(seg->lv) &&
+		    !_add_new_lv_to_dtree(dm, dtree, seg->pool_metadata_lv, laopts, NULL))
+			return_0;
 		/* Add any LVs used by this segment */
 		for (s = 0; s < seg->area_count; s++) {
 			if ((seg_type(seg, s) == AREA_LV) &&
--- LVM2/lib/metadata/lv_manip.c	2011/09/27 17:09:43	1.291
+++ LVM2/lib/metadata/lv_manip.c	2011/09/29 08:56:38	1.292
@@ -2602,9 +2602,17 @@
 		r = _lv_extend_layered_lv(ah, lv, extents, 0,
 					  stripes, stripe_size);
 
-		if (r && segtype_is_thin_pool(segtype))
-			r = lv_add_segment(ah, ah->area_count, 1, first_seg(lv)->pool_metadata_lv,
-					   get_segtype_from_string(lv->vg->cmd, "striped"), 0, 0, 0);
+		if (r && segtype_is_thin_pool(segtype)) {
+			/* FIXME: resize metadata size here for now */
+			struct logical_volume *tmeta = first_seg(lv)->pool_metadata_lv;
+			if ((r = lv_add_segment(ah, ah->area_count, 1, tmeta,
+						get_segtype_from_string(lv->vg->cmd, "striped"), 0, 0, 0))) {
+				if (!(r = lv_extend(tmeta, first_seg(tmeta)->segtype,
+						    1, 0, 1, 0, 10, NULL, allocatable_pvs, ALLOC_INHERIT)))
+					stack;
+			} else
+				stack;
+		}
 	}
 	alloc_destroy(ah);
 	return r;
@@ -4106,6 +4114,13 @@
 	if (seg_is_thin_pool(lp) && lp->zero)
 		first_seg(lv)->zero_new_blocks = 1;
 
+	if (seg_is_thin_pool(lp)) {
+		/* FIXME: add lvcreate params - maybe -c/--chunksize?,
+		 * use lowwatermark  via lvm.conf global for all thinpools ?*/
+		first_seg(lv)->data_block_size = 128;
+		first_seg(lv)->low_water_mark = 4096;
+	}
+
 	if (lp->log_count &&
 	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
 		if (!add_mirror_log(cmd, lv, lp->log_count,
--- LVM2/lib/metadata/merge.c	2011/09/16 11:53:14	1.49
+++ LVM2/lib/metadata/merge.c	2011/09/29 08:56:39	1.50
@@ -201,6 +201,12 @@
 						  lv->name, seg_count);
 					inc_error_count;
 				}
+
+				if (seg->data_block_size < 128 || seg->data_block_size > 2097152) {
+					log_error("LV %s: thin pool segment %u  data block size %d is out of range",
+						  lv->name, seg_count, seg->data_block_size);
+					inc_error_count;
+				}
 			} else {
 				if (seg->pool_metadata_lv) {
 					log_error("LV %s: segment %u must not have thin pool metadata LV set",
@@ -231,6 +237,12 @@
 						  lv->name, seg_count);
 					inc_error_count;
 				}
+
+				if (seg->device_id >= (1 << 24)) {
+					log_error("LV %s: thin volume segment %u pool LV to large device id %d",
+						  lv->name, seg_count, seg->device_id);
+					inc_error_count;
+				}
 			} else {
 				if (seg->pool_lv) {
 					log_error("LV %s: segment %u must not have thin pool LV set",
--- LVM2/lib/metadata/metadata-exported.h	2011/09/27 17:09:43	1.212
+++ LVM2/lib/metadata/metadata-exported.h	2011/09/29 08:56:39	1.213
@@ -335,9 +335,11 @@
 	struct lv_segment_area *meta_areas;	/* For RAID */
 	struct logical_volume *pool_metadata_lv;/* For thin_pool */
 	uint64_t transaction_id;		/* For thin_pool */
-	uint32_t zero_new_blocks;		/* For thin_pool */
+	uint64_t low_water_mark;		/* For thin_pool */
+	uint32_t data_block_size;		/* For thin_pool, 128..2097152 */
+	unsigned zero_new_blocks;		/* For thin_pool */
 	struct logical_volume *pool_lv;		/* For thin */
-	uint64_t device_id;			/* For thin */
+	uint32_t device_id;			/* For thin, 24bit */
 
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
 	struct logical_volume *rlog_lv;	/* For replicators */
--- LVM2/lib/thin/thin.c	2011/09/08 16:41:19	1.12
+++ LVM2/lib/thin/thin.c	2011/09/29 08:56:39	1.13
@@ -70,6 +70,12 @@
 	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
 		return SEG_LOG_ERROR("Could not read transaction_id for");
 
+	if (!dm_config_get_uint64(sn, "low_water_mark", &seg->low_water_mark))
+		return SEG_LOG_ERROR("Could not read low_water_mark");
+
+	if (!dm_config_get_uint32(sn, "data_block_size", &seg->data_block_size))
+		return SEG_LOG_ERROR("Could not read data_block_size");
+
 	if (dm_config_has_node(sn, "zero_new_blocks") &&
 	    !dm_config_get_uint32(sn, "zero_new_blocks", &seg->zero_new_blocks))
 		return SEG_LOG_ERROR("Could not read zero_new_blocks for");
@@ -92,12 +98,45 @@
 	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->pool_metadata_lv->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
+	outf(f, "low_water_mark = %" PRIu64, seg->low_water_mark);
+	outf(f, "data_block_size = %d", seg->data_block_size);
 	if (seg->zero_new_blocks)
 		outf(f, "zero_new_blocks = 1");
 
 	return 1;
 }
 
+#ifdef DEVMAPPER_SUPPORT
+static int _thin_pool_add_target_line(struct dev_manager *dm,
+				 struct dm_pool *mem __attribute__((unused)),
+				 struct cmd_context *cmd __attribute__((unused)),
+				 void **target_state __attribute__((unused)),
+				 struct lv_segment *seg,
+				 const struct lv_activate_opts *laopts __attribute__((unused)),
+				 struct dm_tree_node *node, uint64_t len,
+				 uint32_t *pvmove_mirror_count __attribute__((unused)))
+{
+	char *metadata_dlid, *pool_dlid;
+
+	if (!(metadata_dlid = build_dm_uuid(mem, seg->pool_metadata_lv->lvid.s, NULL))) {
+		log_error("Failed to build uuid for metadata LV %s.", seg->pool_metadata_lv->name);
+		return 0;
+	}
+
+	if (!(pool_dlid = build_dm_uuid(mem, seg_lv(seg, 0)->lvid.s, NULL))) {
+		log_error("Failed to build uuid for pool LV %s.", seg_lv(seg, 0)->name);
+		return 0;
+	}
+
+	if (!dm_tree_node_add_thin_pool_target(node, len, 0, metadata_dlid, pool_dlid,
+					       seg->data_block_size, seg->low_water_mark,
+					       seg->zero_new_blocks ? 0 : 1))
+		return_0;
+
+	return 1;
+}
+#endif
+
 static const char *_thin_name(const struct lv_segment *seg)
 {
 	return seg->segtype->name;
@@ -126,7 +165,7 @@
 			return SEG_LOG_ERROR("Unknown origin %s in", lv_name);
 	}
 
-	if (!dm_config_get_uint64(sn, "device_id", &seg->device_id))
+	if (!dm_config_get_uint32(sn, "device_id", &seg->device_id))
 		return SEG_LOG_ERROR("Could not read device_id for");
 
 	return 1;
@@ -135,7 +174,7 @@
 static int _thin_text_export(const struct lv_segment *seg, struct formatter *f)
 {
 	outf(f, "thin_pool = \"%s\"", seg->pool_lv->name);
-	outf(f, "device_id = %" PRIu64, seg->device_id);
+	outf(f, "device_id = %d", seg->device_id);
 
 	if (seg->origin)
 		outf(f, "origin = \"%s\"", seg->origin->name);
@@ -144,6 +183,28 @@
 }
 
 #ifdef DEVMAPPER_SUPPORT
+static int _thin_add_target_line(struct dev_manager *dm,
+				 struct dm_pool *mem __attribute__((unused)),
+				 struct cmd_context *cmd __attribute__((unused)),
+				 void **target_state __attribute__((unused)),
+				 struct lv_segment *seg,
+				 const struct lv_activate_opts *laopts __attribute__((unused)),
+				 struct dm_tree_node *node, uint64_t len,
+				 uint32_t *pvmove_mirror_count __attribute__((unused)))
+{
+	char *thin_pool_dlid;
+
+	if (!(thin_pool_dlid = build_dm_uuid(mem, seg->pool_lv->lvid.s, NULL))) {
+		log_error("Failed to build uuid for thin pool LV %s.", seg->pool_lv->name);
+		return 0;
+	}
+
+	if (!dm_tree_node_add_thin_target(node, len, 0, thin_pool_dlid, seg->device_id))
+		return_0;
+
+	return 1;
+}
+
 static int _thin_target_percent(void **target_state __attribute__((unused)),
 				percent_t *percent,
 				struct dm_pool *mem __attribute__((unused)),
@@ -194,6 +255,10 @@
 	.text_import = _thin_pool_text_import,
 	.text_import_area_count = _thin_pool_text_import_area_count,
 	.text_export = _thin_pool_text_export,
+#ifdef DEVMAPPER_SUPPORT
+	.add_target_line = _thin_pool_add_target_line,
+	.target_present = _thin_target_present,
+#endif
 	.modules_needed = _thin_modules_needed,
 	.destroy = _thin_destroy,
 };
@@ -203,6 +268,7 @@
 	.text_import = _thin_text_import,
 	.text_export = _thin_text_export,
 #ifdef DEVMAPPER_SUPPORT
+	.add_target_line = _thin_add_target_line,
 	.target_percent = _thin_target_percent,
 	.target_present = _thin_target_present,
 #endif



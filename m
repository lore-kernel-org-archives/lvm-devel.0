From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Sep 2011 22:43:59 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/merg ...
Message-ID: <20110906224359.24695.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-06 22:43:58

Modified files:
	lib/metadata   : lv_manip.c merge.c metadata-exported.h 
	                 metadata.h thin_manip.c 
	lib/thin       : thin.c 
	tools          : lvcreate.c 

Log message:
	pool attach fns & more field renaming

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.281&r2=1.282
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.206&r2=1.207
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.253&r2=1.254
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.237&r2=1.238

--- LVM2/lib/metadata/lv_manip.c	2011/09/06 19:25:43	1.281
+++ LVM2/lib/metadata/lv_manip.c	2011/09/06 22:43:56	1.282
@@ -257,7 +257,7 @@
 
 	if (log_lv) {
 		if (thin_pool_lv) {
-			if (!attach_pool_metadata(seg, log_lv))
+			if (!attach_pool_metadata_lv(seg, log_lv))
 				return_NULL;
 		} else if (!attach_mirror_log(seg, log_lv))
 			return_NULL;
--- LVM2/lib/metadata/merge.c	2011/09/06 00:26:43	1.46
+++ LVM2/lib/metadata/merge.c	2011/09/06 22:43:57	1.47
@@ -313,7 +313,7 @@
 	if (!(split_seg = alloc_lv_segment(lv->vg->vgmem, seg->segtype,
 					   seg->lv, seg->le, seg->len,
 					   seg->status, seg->stripe_size,
-					   seg->log_lv, seg->thin_pool_lv,
+					   seg->log_lv, seg->pool_lv,
 					   seg->area_count, seg->area_len,
 					   seg->chunk_size, seg->region_size,
 					   seg->extents_copied, seg->pvmove_source_seg))) {
--- LVM2/lib/metadata/metadata-exported.h	2011/09/06 19:25:43	1.206
+++ LVM2/lib/metadata/metadata-exported.h	2011/09/06 22:43:57	1.207
@@ -85,6 +85,8 @@
 
 #define THIN_VOLUME		UINT64_C(0x0000001000000000)	/* LV */
 #define THIN_POOL		UINT64_C(0x0000002000000000)	/* LV */
+#define THIN_POOL_DATA		UINT64_C(0x0000002000000000)	/* LV */
+#define THIN_POOL_METADATA	UINT64_C(0x0000004000000000)	/* LV */
 
 #define LVM_READ		0x00000100U	/* LV VG 32-bit */
 #define LVM_WRITE		0x00000200U	/* LV VG 32-bit */
@@ -134,6 +136,8 @@
 
 #define lv_is_thin_volume(lv)	((lv)->status & THIN_VOLUME ? 1 : 0)
 #define lv_is_thin_pool(lv)	((lv)->status & THIN_POOL ? 1 : 0)
+#define lv_is_thin_pool_data(lv)	((lv)->status & THIN_POOL_DATA ? 1 : 0)
+#define lv_is_thin_pool_metadata(lv)	((lv)->status & THIN_POOL_METADATA ? 1 : 0)
 #define lv_is_mirrored(lv)	((lv)->status & MIRRORED ? 1 : 0)
 #define lv_is_rlog(lv)		((lv)->status & REPLICATOR_LOG ? 1 : 0)
 
@@ -322,12 +326,12 @@
 	struct dm_list tags;
 
 	struct lv_segment_area *areas;
-	struct lv_segment_area *meta_areas; /* For RAID */
-	struct logical_volume *pool_lv;		/* For thin_pool */
-	struct logical_volume *metadata_lv;	/* For thin_pool */
+	struct lv_segment_area *meta_areas;	/* For RAID */
+	struct logical_volume *pool_data_lv;	/* For thin_pool */
+	struct logical_volume *pool_metadata_lv;/* For thin_pool */
 	uint64_t transaction_id;		/* For thin_pool */
 	uint32_t zero_new_blocks;		/* For thin_pool */
-	struct logical_volume *thin_pool_lv;	/* For thin */
+	struct logical_volume *pool_lv;		/* For thin */
 	uint64_t device_id;			/* For thin */
 
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
--- LVM2/lib/metadata/metadata.h	2011/09/06 19:25:43	1.253
+++ LVM2/lib/metadata/metadata.h	2011/09/06 22:43:57	1.254
@@ -442,9 +442,11 @@
 /*
  * From thin_manip.c
  */
-int attach_pool_metadata(struct lv_segment *seg,
-			 struct logical_volume *thin_pool_metadata);
-int attach_pool_lv(struct lv_segment *seg, struct logical_volume *thin_pool_lv);
+int attach_pool_metadata_lv(struct lv_segment *seg,
+			    struct logical_volume *pool_metadata_lv);
+int attach_pool_data_lv(struct lv_segment *seg,
+			struct logical_volume *pool_data_lv);
+int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv);
 
 /*
  * Begin skeleton for external LVM library
--- LVM2/lib/metadata/thin_manip.c	2011/09/06 19:25:43	1.1
+++ LVM2/lib/metadata/thin_manip.c	2011/09/06 22:43:57	1.2
@@ -15,19 +15,28 @@
 #include "lib.h"
 #include "metadata.h"
 
-int attach_pool_metadata(struct lv_segment *seg, struct logical_volume *thin_pool_metadata)
+int attach_pool_metadata_lv(struct lv_segment *seg, struct logical_volume *pool_metadata_lv)
 {
-	// FIXME Housekeeping needed here (cf attach_mirror_log)
-	seg->metadata_lv = thin_pool_metadata;
+	seg->pool_metadata_lv = pool_metadata_lv;
+	pool_metadata_lv->status |= THIN_POOL_METADATA;
+        lv_set_hidden(pool_metadata_lv);
 
-	return 1;
+        return add_seg_to_segs_using_this_lv(pool_metadata_lv, seg);
 }
 
-int attach_pool_lv(struct lv_segment *seg, struct logical_volume *thin_pool_lv)
+int attach_pool_data_lv(struct lv_segment *seg, struct logical_volume *pool_data_lv)
 {
-	// FIXME Housekeeping needed here (cf attach_mirror_log)
-	seg->thin_pool_lv = thin_pool_lv;
+	seg->pool_data_lv = pool_data_lv;
+	pool_data_lv->status |= THIN_POOL_DATA;
+        lv_set_hidden(pool_data_lv);
 
-	return 1;
+        return add_seg_to_segs_using_this_lv(pool_data_lv, seg);
 }
 
+int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv)
+{
+	seg->pool_lv = pool_lv;
+	pool_lv->status |= THIN_POOL;
+
+        return add_seg_to_segs_using_this_lv(pool_lv, seg);
+}
--- LVM2/lib/thin/thin.c	2011/09/06 22:35:44	1.10
+++ LVM2/lib/thin/thin.c	2011/09/06 22:43:57	1.11
@@ -47,21 +47,26 @@
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const char *lv_name;
+	struct logical_volume *pool_data_lv, *pool_metadata_lv;
 
 	if (!dm_config_get_str(sn, "pool", &lv_name))
 		return SEG_LOG_ERROR("Pool must be a string in");
 
-// Use attach_pool_lv
-	if (!(seg->pool_lv = find_lv(seg->lv->vg, lv_name)))
+	if (!(pool_data_lv = find_lv(seg->lv->vg, lv_name)))
 		return SEG_LOG_ERROR("Unknown pool %s in", lv_name);
 
 	if (!dm_config_get_str(sn, "metadata", &lv_name))
 		return SEG_LOG_ERROR("Metadata must be a string in");
 
-// Use attach_pool_metadata()
-	if (!(seg->metadata_lv = find_lv(seg->lv->vg, lv_name)))
+	if (!(pool_metadata_lv = find_lv(seg->lv->vg, lv_name)))
 		return SEG_LOG_ERROR("Unknown metadata %s in", lv_name);
 
+	if (!attach_pool_metadata_lv(seg, pool_metadata_lv))
+		return_0;
+
+	if (!attach_pool_data_lv(seg, pool_data_lv))
+		return_0;
+
 	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
 		return SEG_LOG_ERROR("Could not read transaction_id for");
 
@@ -74,8 +79,8 @@
 
 static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter *f)
 {
-	outf(f, "pool = \"%s\"", seg->pool_lv->name);
-	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
+	outf(f, "pool = \"%s\"", seg->pool_data_lv->name);
+	outf(f, "metadata = \"%s\"", seg->pool_metadata_lv->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
 	if (seg->zero_new_blocks)
 		outf(f, "zero_new_blocks = 1");
@@ -92,13 +97,17 @@
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const char *lv_name;
+	struct logical_volume *pool_lv;
 
 	if (!dm_config_get_str(sn, "thin_pool", &lv_name))
 		return SEG_LOG_ERROR("Thin pool must be a string in");
 
-	if (!(seg->thin_pool_lv = find_lv(seg->lv->vg, lv_name)))
+	if (!(pool_lv = find_lv(seg->lv->vg, lv_name)))
 		return SEG_LOG_ERROR("Unknown thin pool %s in", lv_name);
 
+	if (!attach_pool_lv(seg, pool_lv))
+		return_0;
+
 	if (dm_config_has_node(sn, "origin")) {
 		if (!dm_config_get_str(sn, "origin", &lv_name))
 			return SEG_LOG_ERROR("Origin must be a string in");
@@ -115,7 +124,7 @@
 
 static int _thin_text_export(const struct lv_segment *seg, struct formatter *f)
 {
-	outf(f, "thin_pool = \"%s\"", seg->thin_pool_lv->name);
+	outf(f, "thin_pool = \"%s\"", seg->pool_lv->name);
 	outf(f, "device_id = %" PRIu64, seg->device_id);
 
 	if (seg->origin)
--- LVM2/tools/lvcreate.c	2011/09/06 19:25:42	1.237
+++ LVM2/tools/lvcreate.c	2011/09/06 22:43:58	1.238
@@ -198,13 +198,12 @@
 		return 0;
 	}
 
-	/* FIXME Replace with lv_is_thin_volume() once more flags are added */
 	if (lv_is_thin_volume(lvl->lv)) {
 		lp->thin = 1;
 		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
 			return_0;
 
-		lp->pool = first_seg(lvl->lv)->thin_pool_lv->name;
+		lp->pool = first_seg(lvl->lv)->pool_lv->name;
 	}
 
 	if (!lp->thin && !arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {



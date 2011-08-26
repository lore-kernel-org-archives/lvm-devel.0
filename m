From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Aug 2011 13:37:48 -0000
Subject: LVM2/lib metadata/metadata-exported.h thin/thin.c
Message-ID: <20110826133748.19205.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-26 13:37:47

Modified files:
	lib/metadata   : metadata-exported.h 
	lib/thin       : thin.c 

Log message:
	Initial code for read/write of thin metadata lv segments

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.201&r2=1.202
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/metadata/metadata-exported.h	2011/08/18 19:43:08	1.201
+++ LVM2/lib/metadata/metadata-exported.h	2011/08/26 13:37:47	1.202
@@ -318,6 +318,13 @@
 
 	struct lv_segment_area *areas;
 	struct lv_segment_area *meta_areas; /* For RAID */
+	struct logical_volume *data_lv;		/* For thin_pool */
+	struct logical_volume *metadata_lv;	/* For thin_pool */
+	uint64_t transaction_id;		/* For thin_pool */
+	uint32_t zero_new_blocks;		/* For thin_pool */
+	struct logical_volume *thin_pool_lv;	/* For thin */
+	struct logical_volume *origin_lv;	/* For thin */
+	uint64_t device_id;			/* For thin */
 
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
 	struct logical_volume *rlog_lv;	/* For replicators */
--- LVM2/lib/thin/thin.c	2011/08/25 10:00:09	1.2
+++ LVM2/lib/thin/thin.c	2011/08/26 13:37:47	1.3
@@ -30,20 +30,58 @@
 /* Dm kernel module name for thin provisiong */
 #define THIN_MODULE "thin-pool"
 
+/*
+ * Macro used as return argument - returns 0.
+ * return is left to be written in the function for better readability.
+ */
+#define SEG_LOG_ERROR(t, p...) \
+	log_error(t " segment %s of logical volume %s.", ## p, \
+		  config_parent_name(sn), seg->lv->name), 0;
+
 static const char *_thin_pool_name(const struct lv_segment *seg)
 {
 	return seg->segtype->name;
 }
 
-
 static int _thin_pool_text_import(struct lv_segment *seg, const struct config_node *sn,
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
+	const struct config_node *cn;
+
+	if (!(cn = find_config_node(sn, "data")) ||
+	    !cn->v || cn->v->type != CFG_STRING)
+		return SEG_LOG_ERROR("Thin pool data must be a string in");
+
+	if (!(seg->data_lv = find_lv(seg->lv->vg, cn->v->v.str)))
+		return SEG_LOG_ERROR("Unknown pool data %s in",
+				     cn->v->v.str);
+
+	if (!(cn = find_config_node(sn, "metadata")) ||
+	    !cn->v || cn->v->type != CFG_STRING)
+		return SEG_LOG_ERROR("Thin pool metadata must be a string in");
+
+	if (!(seg->metadata_lv = find_lv(seg->lv->vg, cn->v->v.str)))
+		return SEG_LOG_ERROR("Unknown pool metadata %s in",
+				     cn->v->v.str);
+
+	if (!get_config_uint64(sn, "transaction_id", &seg->transaction_id))
+		return SEG_LOG_ERROR("Could not read transaction_id for");
+
+	if (find_config_node(sn, "zero_new_blocks") &&
+	    !get_config_uint32(sn, "zero_new_blocks", &seg->zero_new_blocks))
+		return SEG_LOG_ERROR("Could not read zero_new_blocks for");
+
 	return 1;
 }
 
 static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter *f)
 {
+	outf(f, "data = \"%s\"", seg->data_lv->name);
+	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
+	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
+	if (seg->zero_new_blocks)
+		outf(f, "zero_new_blocks = 1");
+
 	return 1;
 }
 
@@ -55,11 +93,39 @@
 static int _thin_text_import(struct lv_segment *seg, const struct config_node *sn,
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
+	const struct config_node *cn;
+
+	if (!(cn = find_config_node(sn, "thin_pool")) ||
+	    !cn->v || cn->v->type != CFG_STRING)
+		return SEG_LOG_ERROR("Thin pool must be a string in");
+
+	if (!(seg->thin_pool_lv = find_lv(seg->lv->vg, cn->v->v.str)))
+		return SEG_LOG_ERROR("Unknown thin pool %s in",
+				     cn->v->v.str);
+
+	if ((cn = find_config_node(sn, "origin"))) {
+                if (!cn->v || cn->v->type != CFG_STRING)
+			return SEG_LOG_ERROR("Thin pool origin must be a string in");
+
+		if (!(seg->origin_lv = find_lv(seg->lv->vg, cn->v->v.str)))
+			return SEG_LOG_ERROR("Unknown origin %s in",
+					     cn->v->v.str);
+	}
+
+	if (!get_config_uint64(sn, "device_id", &seg->device_id))
+		return SEG_LOG_ERROR("Could not read device_id for");
+
 	return 1;
 }
 
 static int _thin_text_export(const struct lv_segment *seg, struct formatter *f)
 {
+	outf(f, "thin_pool = \"%s\"", seg->thin_pool_lv->name);
+	outf(f, "device_id = %" PRIu64, seg->device_id);
+
+	if (seg->origin_lv)
+		outf(f, "origin = \"%s\"", seg->origin_lv->name);
+
 	return 1;
 }
 



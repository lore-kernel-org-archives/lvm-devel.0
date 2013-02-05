From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  5 Feb 2013 14:56:02 +0100
Subject: [PATCH 1/6] thin: add support for external origin
In-Reply-To: <cover.1360072297.git.zkabelac@redhat.com>
References: <cover.1360072297.git.zkabelac@redhat.com>
Message-ID: <d2fa5115588a6f394ad69d69b93562f5a7ca29d3.1360072297.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add internal support for thin volume's external origin.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c       | 40 ++++++++++++++++++++++++++++++++
 lib/format_text/flags.c          |  3 ++-
 lib/metadata/lv.c                |  2 +-
 lib/metadata/lv_manip.c          |  5 +++-
 lib/metadata/merge.c             |  7 +++++-
 lib/metadata/metadata-exported.h |  5 +++-
 lib/metadata/metadata.h          |  5 +++-
 lib/metadata/thin_manip.c        | 50 ++++++++++++++++++++++++++++++++++++++++
 lib/thin/thin.c                  | 33 ++++++++++++++++++++++----
 9 files changed, 140 insertions(+), 10 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e8f449c..db64f26 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1565,6 +1565,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	/* FIXME Can we avoid doing this every time? */
+	/* Reused also for lv_is_external_origin(lv) */
 	if (!_add_dev_to_dtree(dm, dtree, lv, "real"))
 		return_0;
 
@@ -1605,6 +1606,11 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				dm_tree_node_skip_children(thin_node, 1);
 #endif
 		} else {
+			/* Add external origin */
+			if (seg->external_lv &&
+			    !_add_dev_to_dtree(dm, dtree, seg->external_lv,
+					       lv_layer(seg->external_lv)))
+				return_0;
 			/* Add thin pool LV layer */
 			lv = seg->pool_lv;
 			seg = first_seg(lv);
@@ -1832,6 +1838,28 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 	return 1;
 }
 
+static int _add_external_origin_target_to_dtree(struct dev_manager *dm,
+						struct dm_tree_node *dnode,
+						struct logical_volume *lv)
+{
+	const char *layer_dlid;
+
+	if (!(layer_dlid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+		return_0;
+
+	/* Add linear mapping to layered external origin */
+	if (!add_linear_area_to_dtree(dnode,
+				      (uint64_t)lv->vg->extent_size * lv->le_count,
+				      lv->vg->extent_size,
+				      lv->vg->cmd->use_linear_target,
+				      lv->vg->name, lv->name) ||
+	    !dm_tree_node_add_target_area(dnode, NULL, layer_dlid, 0))
+		return_0;
+
+	return 1;
+}
+
+
 static int _add_origin_target_to_dtree(struct dev_manager *dm,
 					 struct dm_tree_node *dnode,
 					 struct logical_volume *lv)
@@ -2020,6 +2048,18 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		return 0;
 	}
 
+	/* Add external origin */
+	if (seg->external_lv &&
+	    !_add_new_lv_to_dtree(dm, dtree, seg->external_lv, laopts,
+				  lv_layer(seg->external_lv)))
+		return_0;
+	else if (!layer && lv_is_external_origin(seg->lv)) {
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts,
+					  lv_layer(seg->lv)))
+			return_0;
+		return _add_external_origin_target_to_dtree(dm, dnode, seg->lv);
+	}
+
 	/* Add mirror log */
 	if (seg->log_lv &&
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, laopts, NULL))
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index a3a3d0e..66e4bde 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -58,6 +58,7 @@ static const struct flag _lv_flags[] = {
 	{LOCKED, "LOCKED", STATUS_FLAG},
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
+	{EXTERNAL_ORIGIN, NULL, 0},
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},
 	{RAID_IMAGE, NULL, 0},
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index c27ef08..9f6b327 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -229,7 +229,7 @@ const char *lv_layer(const struct logical_volume *lv)
 {
 	if (lv_is_thin_pool(lv))
 		return "tpool";
-	else if (lv_is_origin(lv))
+	else if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		return "real";
 
 	return NULL;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 50e42dc..07d3fd7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -278,6 +278,9 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 			seg->transaction_id = first_seg(first_seg(thin_pool_lv)->pool_lv)->transaction_id;
 			if (!attach_pool_lv(seg, first_seg(thin_pool_lv)->pool_lv, thin_pool_lv))
 				return_NULL;
+			/* Use the same external origin */
+			if (!attach_thin_external_origin(seg, first_seg(thin_pool_lv)->external_lv))
+				return_NULL;
 		} else {
 			seg->transaction_id = first_seg(thin_pool_lv)->transaction_id;
 			if (!attach_pool_lv(seg, thin_pool_lv, NULL))
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index a4563f8..477d7bb 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -243,6 +243,11 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 						  lv->name, seg_count, seg->device_id);
 					inc_error_count;
 				}
+				if (seg->external_lv && (seg->external_lv->status & LVM_WRITE)) {
+					log_error("LV %s: external origin %s is writable.",
+						  lv->name, seg->external_lv->name);
+					inc_error_count;
+				}
 			} else {
 				if (seg->pool_lv) {
 					log_error("LV %s: segment %u must not have thin pool LV set",
@@ -372,7 +377,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			seg_found++;
 		if (seg->metadata_lv == lv || seg->pool_lv == lv)
 			seg_found++;
-		if (seg_is_thin_volume(seg) && seg->origin == lv)
+		if (seg_is_thin_volume(seg) && (seg->origin == lv || seg->external_lv == lv))
 			seg_found++;
 		if (!seg_found) {
 			log_error("LV %s is used by LV %s:%" PRIu32 "-%" PRIu32
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ffec129..202ab2d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -89,6 +89,7 @@
 #define THIN_POOL		UINT64_C(0x0000002000000000)	/* LV */
 #define THIN_POOL_DATA		UINT64_C(0x0000004000000000)	/* LV */
 #define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV */
+#define EXTERNAL_ORIGIN		UINT64_C(0x0000010000000000)	/* LV */
 
 #define LVM_READ		UINT64_C(0x00000100)	/* LV, VG */
 #define LVM_WRITE		UINT64_C(0x00000200)	/* LV, VG */
@@ -141,6 +142,7 @@
 #define lv_is_used_thin_pool(lv)	(lv_is_thin_pool(lv) && !dm_list_empty(&(lv)->segs_using_this_lv))
 #define lv_is_thin_pool_data(lv)	((lv)->status & THIN_POOL_DATA ? 1 : 0)
 #define lv_is_thin_pool_metadata(lv)	((lv)->status & THIN_POOL_METADATA ? 1 : 0)
+#define lv_is_external_origin(lv)	((lv)->status & EXTERNAL_ORIGIN ? 1 : 0)
 #define lv_is_mirrored(lv)	((lv)->status & MIRRORED ? 1 : 0)
 #define lv_is_rlog(lv)		((lv)->status & REPLICATOR_LOG ? 1 : 0)
 
@@ -355,6 +357,7 @@ struct lv_segment {
 	unsigned zero_new_blocks;		/* For thin_pool */
 	thin_discards_t discards;		/* For thin_pool */
 	struct dm_list thin_messages;		/* For thin_pool */
+	struct logical_volume *external_lv;	/* For thin */
 	struct logical_volume *pool_lv;		/* For thin */
 	uint32_t device_id;			/* For thin, 24bit */
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 8a80147..9ee455c 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -476,6 +476,9 @@ int pool_is_active(const struct lv_segment *pool_seg);
 int pool_below_threshold(const struct lv_segment *pool_seg);
 int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
+int attach_thin_external_origin(struct lv_segment *seg,
+				struct logical_volume *external_lv);
+int detach_thin_external_origin(struct lv_segment *seg);
 
 /*
  * Begin skeleton for external LVM library
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 6ec97d4..3eca06b 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -108,6 +108,9 @@ int detach_pool_lv(struct lv_segment *seg)
 		}
 	}
 
+	if (!detach_thin_external_origin(seg))
+		return_0;
+
 	if (!attach_pool_message(first_seg(seg->pool_lv),
 				 DM_THIN_MESSAGE_DELETE,
 				 NULL, seg->device_id, no_update))
@@ -198,6 +201,53 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 	return 1;
 }
 
+int attach_thin_external_origin(struct lv_segment *seg,
+				struct logical_volume *external_lv)
+{
+	seg->external_lv = external_lv;
+
+	if (external_lv) {
+		if (!add_seg_to_segs_using_this_lv(external_lv, seg))
+			return_0;
+
+		external_lv->status |= EXTERNAL_ORIGIN;
+
+		if (external_lv->status & LVM_WRITE) {
+			log_verbose("Setting logical volume \"%s\" read-only.",
+				    external_lv->name);
+			external_lv->status &= ~LVM_WRITE;
+		}
+	}
+
+	return 1;
+}
+
+int detach_thin_external_origin(struct lv_segment *seg)
+{
+	if (seg->external_lv) {
+		if (!lv_is_external_origin(seg->external_lv)) {
+			log_error(INTERNAL_ERROR "Inconsitent external origin.");
+			return 0;
+		}
+
+		if (!remove_seg_from_segs_using_this_lv(seg->external_lv, seg))
+			return_0;
+
+		if (dm_list_empty(&seg->external_lv->segs_using_this_lv)) {
+			seg->external_lv->status &= ~EXTERNAL_ORIGIN;
+
+			/* FIXME -  we do not keep original state */
+			//log_verbose("Setting logical volume \"%s\" writable",
+			//	    seg->external_lv->name);
+			//seg->external_lv->status |= LVM_WRITE;
+		}
+
+		seg->external_lv = NULL;
+	}
+
+	return 1;
+}
+
 /*
  * Check whether pool has some message queued for LV or for device_id
  * When LV is NULL and device_id is 0 it just checks for any message.
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 8c0ec82..807e0ee 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -439,7 +439,7 @@ static int _thin_text_import(struct lv_segment *seg,
 			     struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const char *lv_name;
-	struct logical_volume *pool_lv, *origin = NULL;
+	struct logical_volume *pool_lv, *origin = NULL, *external_lv = NULL;
 
 	if (!dm_config_get_str(sn, "thin_pool", &lv_name))
 		return SEG_LOG_ERROR("Thin pool must be a string in");
@@ -465,9 +465,20 @@ static int _thin_text_import(struct lv_segment *seg,
 		return SEG_LOG_ERROR("Unsupported value %u for device_id",
 				     seg->device_id);
 
+	if (dm_config_has_node(sn, "external_origin")) {
+		if (!dm_config_get_str(sn, "external_origin", &lv_name))
+			return SEG_LOG_ERROR("External origin must be a string in");
+
+		if (!(external_lv = find_lv(seg->lv->vg, lv_name)))
+			return SEG_LOG_ERROR("Unknown external origin %s in", lv_name);
+	}
+
 	if (!attach_pool_lv(seg, pool_lv, origin))
 		return_0;
 
+	if (!attach_thin_external_origin(seg, external_lv))
+		return_0;
+
 	return 1;
 }
 
@@ -477,6 +488,8 @@ static int _thin_text_export(const struct lv_segment *seg, struct formatter *f)
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
 	outf(f, "device_id = %d", seg->device_id);
 
+	if (seg->external_lv)
+		outf(f, "external_origin = \"%s\"", seg->external_lv->name);
 	if (seg->origin)
 		outf(f, "origin = \"%s\"", seg->origin->name);
 
@@ -493,10 +506,10 @@ static int _thin_add_target_line(struct dev_manager *dm,
 				 struct dm_tree_node *node, uint64_t len,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
-	char *pool_dlid;
+	char *pool_dlid, *external_dlid;
 	uint32_t device_id = seg->device_id;
 
-	if (!(pool_dlid = build_dm_uuid(mem, seg->pool_lv->lvid.s, "tpool"))) {
+	if (!(pool_dlid = build_dm_uuid(mem, seg->pool_lv->lvid.s, lv_layer(seg->pool_lv)))) {
 		log_error("Failed to build uuid for pool LV %s.",
 			  seg->pool_lv->name);
 		return 0;
@@ -505,6 +518,18 @@ static int _thin_add_target_line(struct dev_manager *dm,
 	if (!dm_tree_node_add_thin_target(node, len, pool_dlid, device_id))
 		return_0;
 
+	/* Add external origin LV */
+	if (seg->external_lv) {
+		if (!(external_dlid = build_dm_uuid(mem, seg->external_lv->lvid.s,
+						    lv_layer(seg->external_lv)))) {
+			log_error("Failed to build uuid for external origin LV %s.",
+				  seg->external_lv->name);
+			return 0;
+		}
+		if (!dm_tree_node_set_thin_external_origin(node, external_dlid))
+			return_0;
+	}
+
 	return 1;
 }
 
-- 
1.8.1.2



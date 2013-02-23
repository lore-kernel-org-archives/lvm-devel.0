From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 23 Feb 2013 09:41:59 +0000 (UTC)
Subject: master - thin: add support for external origin
Message-ID: <20130223094159.E570740A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87331dc41979b649d0b0603c26ff421516fe944e
Commit:        87331dc41979b649d0b0603c26ff421516fe944e
Parent:        d023b2d12f31700956bca3b274e88c42f2d65d7a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 21 10:25:44 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 23 10:36:58 2013 +0100

thin: add support for external origin

Add internal support for thin volume's external origin.
---
 lib/activate/dev_manager.c       |   60 ++++++++++++++++++++++++++++++++++++--
 lib/format_text/flags.c          |    2 +-
 lib/metadata/lv.c                |    2 +-
 lib/metadata/lv.h                |    1 +
 lib/metadata/lv_manip.c          |    5 ++-
 lib/metadata/merge.c             |    7 ++++-
 lib/metadata/metadata-exported.h |    4 ++-
 lib/metadata/metadata.h          |    5 ++-
 lib/metadata/thin_manip.c        |   48 ++++++++++++++++++++++++++++++
 lib/thin/thin.c                  |   31 +++++++++++++++++--
 10 files changed, 153 insertions(+), 12 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5ce099e..e326929 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1565,6 +1565,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return_0;
 
 	/* FIXME Can we avoid doing this every time? */
+	/* Reused also for lv_is_external_origin(lv) */
 	if (!_add_dev_to_dtree(dm, dtree, lv, "real"))
 		return_0;
 
@@ -1596,7 +1597,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	}
 
 	/* Add any snapshots of this LV */
-	if (lv_is_origin(lv) && !origin_only)
+	if (lv_is_origin(lv) && (lv_is_external_origin(lv) || !origin_only))
 		dm_list_iterate(snh, &lv->snapshot_segs)
 			if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, 0))
 				return_0;
@@ -1614,6 +1615,9 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	/* Add any LVs used by segments in this LV */
 	dm_list_iterate_items(seg, &lv->segments) {
+		if (seg->external_lv &&
+		    !_add_lv_to_dtree(dm, dtree, seg->external_lv, 1)) /* stack */
+			return_0;
 		if (seg->log_lv &&
 		    !_add_lv_to_dtree(dm, dtree, seg->log_lv, origin_only))
 			return_0;
@@ -2001,6 +2005,45 @@ static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
 	return 1;
 }
 
+static int _add_active_externals_to_dtree(struct dev_manager *dm,
+					  struct dm_tree *dtree,
+					  struct lv_segment *seg,
+					  struct lv_activate_opts *laopts)
+{
+	struct seg_list *sl;
+
+	/* Add any ACTIVE LVs using this external origin LV */
+	log_debug_activation("Adding active users of external lv %s",
+			     seg->external_lv->name);
+	dm_list_iterate_items(sl, &seg->external_lv->segs_using_this_lv) {
+		if (sl->seg->external_lv != seg->external_lv ||
+		    sl->seg == seg)
+			continue;
+
+		/*
+		 * Find if the LV is active
+		 * These LVs are not scanned the generic partial dtree
+		 * since in most cases we do not want to work with them.
+		 * However when new EO user is added all users must be known.
+		 *
+		 * As EO could have been chained and passed to a new
+		 * volume, whole device needs to be tested, so the
+		 * removal of layered EO (-real) happens.
+		 */
+		if (!_add_lv_to_dtree(dm, dtree, sl->seg->lv, 0))
+			return_0;
+
+		/* Only layer check is needed here (also avoids loop) */
+		if (_cached_info(dm->mem, dtree, sl->seg->lv,
+				 lv_layer(sl->seg->lv)) &&
+		    !_add_new_lv_to_dtree(dm, dtree, sl->seg->lv,
+					  laopts, lv_layer(sl->seg->lv)))
+			return_0;
+	}
+
+	return 1;
+}
+
 static int _add_segment_to_dtree(struct dev_manager *dm,
 				 struct dm_tree *dtree,
 				 struct dm_tree_node *dnode,
@@ -2009,7 +2052,6 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 				 const char *layer)
 {
 	uint32_t s;
-	struct seg_list *sl;
 	struct lv_segment *seg_present;
 	const char *target_name;
 
@@ -2031,6 +2073,17 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		return 0;
 	}
 
+	/* Add external origin layer */
+	if (seg->external_lv) {
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->external_lv, laopts,
+					  lv_layer(seg->external_lv)))
+			return_0;
+
+		if (!layer &&
+		    !_add_active_externals_to_dtree(dm, dtree, seg, laopts))
+			return_0;
+	}
+
 	/* Add mirror log */
 	if (seg->log_lv &&
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, laopts, NULL))
@@ -2200,6 +2253,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	/* If this is a snapshot origin, add real LV */
 	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
+	/* Snapshot origin could be also external origin */
 	if (lv_is_origin(lv) && !layer) {
 		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, "real"))
 			return_0;
@@ -2228,7 +2282,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			return_0;
 		if (!_add_snapshot_target_to_dtree(dm, dnode, lv, laopts))
 			return_0;
-	} else if (lv_is_thin_pool(lv) && !layer) {
+	} else if ((lv_is_external_origin(lv) || lv_is_thin_pool(lv)) && !layer) {
 		/* External origin or Thin pool is using layer */
 		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, lv_layer(lv)))
 			return_0;
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index a3a3d0e..2a6b7a5 100644
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
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index b1078bb..03255fb 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -37,6 +37,7 @@ struct logical_volume {
 	uint32_t le_count;
 
 	uint32_t origin_count;
+	uint32_t external_count;
 	struct dm_list snapshot_segs;
 	struct lv_segment *snapshot;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 58c1e26..72516ea 100644
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
@@ -321,6 +321,9 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
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
index 890aa18..b37d64c 100644
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
@@ -136,6 +136,7 @@
 #define VGMETADATACOPIES_ALL UINT32_MAX
 #define VGMETADATACOPIES_UNMANAGED 0
 
+#define lv_is_external_origin(lv)	(((lv)->external_count > 0) ? 1 : 0)
 #define lv_is_thin_volume(lv)	((lv)->status & THIN_VOLUME ? 1 : 0)
 #define lv_is_thin_pool(lv)	((lv)->status & THIN_POOL ? 1 : 0)
 #define lv_is_used_thin_pool(lv)	(lv_is_thin_pool(lv) && !dm_list_empty(&(lv)->segs_using_this_lv))
@@ -355,6 +356,7 @@ struct lv_segment {
 	unsigned zero_new_blocks;		/* For thin_pool */
 	thin_discards_t discards;		/* For thin_pool */
 	struct dm_list thin_messages;		/* For thin_pool */
+	struct logical_volume *external_lv;	/* For thin */
 	struct logical_volume *pool_lv;		/* For thin */
 	uint32_t device_id;			/* For thin, 24bit */
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 19bf742..830c0e1 100644
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
@@ -475,6 +475,9 @@ int pool_has_message(const struct lv_segment *seg,
 int pool_below_threshold(const struct lv_segment *pool_seg);
 int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
+int attach_thin_external_origin(struct lv_segment *seg,
+				struct logical_volume *external_lv);
+int detach_thin_external_origin(struct lv_segment *seg);
 
 /*
  * Begin skeleton for external LVM library
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 05fc052..59748de 100644
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
@@ -198,6 +201,51 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 	return 1;
 }
 
+int attach_thin_external_origin(struct lv_segment *seg,
+				struct logical_volume *external_lv)
+{
+	if (seg->external_lv) {
+		log_error(INTERNAL_ERROR "LV \"%s\" already has external origin.",
+			  seg->lv->name);
+		return 0;
+	}
+
+	seg->external_lv = external_lv;
+
+	if (external_lv) {
+		if (!add_seg_to_segs_using_this_lv(external_lv, seg))
+			return_0;
+
+		external_lv->external_count++;
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
+		seg->external_lv->external_count--;
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
index 4b9bb8b..3e1da91 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -424,7 +424,7 @@ static int _thin_text_import(struct lv_segment *seg,
 			     struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const char *lv_name;
-	struct logical_volume *pool_lv, *origin = NULL;
+	struct logical_volume *pool_lv, *origin = NULL, *external_lv = NULL;
 
 	if (!dm_config_get_str(sn, "thin_pool", &lv_name))
 		return SEG_LOG_ERROR("Thin pool must be a string in");
@@ -450,9 +450,20 @@ static int _thin_text_import(struct lv_segment *seg,
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
 
@@ -462,6 +473,8 @@ static int _thin_text_export(const struct lv_segment *seg, struct formatter *f)
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
 	outf(f, "device_id = %d", seg->device_id);
 
+	if (seg->external_lv)
+		outf(f, "external_origin = \"%s\"", seg->external_lv->name);
 	if (seg->origin)
 		outf(f, "origin = \"%s\"", seg->origin->name);
 
@@ -478,7 +491,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 				 struct dm_tree_node *node, uint64_t len,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
-	char *pool_dlid;
+	char *pool_dlid, *external_dlid;
 	uint32_t device_id = seg->device_id;
 
 	if (!(pool_dlid = build_dm_uuid(mem, seg->pool_lv->lvid.s, lv_layer(seg->pool_lv)))) {
@@ -490,6 +503,18 @@ static int _thin_add_target_line(struct dev_manager *dm,
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
 



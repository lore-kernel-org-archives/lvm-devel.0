From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Mar 2014 23:34:21 +0000 (UTC)
Subject: master - lvm: change build_dm_uuid API
Message-ID: <20140311233421.0834A60EDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a0d97a65c793e5875fc6c4f0a815c37ed4b6d38
Commit:        6a0d97a65c793e5875fc6c4f0a815c37ed4b6d38
Parent:        4d64e91efde5335eeae6f2e0fcdf4992b054644a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 11 17:13:47 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 12 00:16:20 2014 +0100

lvm: change build_dm_uuid API

Pass directly 'lv' into this build routine,
so we can eventually add more private UUID suffixes.
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |    2 +-
 lib/activate/dev_manager.c |   62 ++++++++++++++++++++++----------------------
 lib/cache_segtype/cache.c  |    6 ++--
 lib/mirror/mirrored.c      |    4 +-
 lib/misc/lvm-string.c      |    5 +++-
 lib/misc/lvm-string.h      |    3 +-
 lib/thin/thin.c            |    8 +++---
 8 files changed, 48 insertions(+), 43 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7814826..21413aa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Update API for internal function build_dm_uuid().
   Do not try to check empty pool with scheduled messages.
   Fix return value in pool_has_message() when quering for any message.
   Cleanup all client resources on clvmd exit.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 26dc0e1..565634f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1546,7 +1546,7 @@ static char *_build_target_uuid(struct cmd_context *cmd, struct logical_volume *
 	else
 		layer = NULL;
 
-	return build_dm_uuid(cmd->mem, lv->lvid.s, layer);
+	return build_dm_uuid(cmd->mem, lv, layer);
 }
 
 int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 006588c..e9729d4 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -505,7 +505,7 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, layer))) {
+	if (!(dlid = build_dm_uuid(mem, lv, layer))) {
 		log_error("dlid build failed for %s", name);
 		r = 0;
 		goto out;
@@ -528,7 +528,7 @@ static const struct dm_info *_cached_info(struct dm_pool *mem,
 	const struct dm_tree_node *dnode;
 	const struct dm_info *dinfo = NULL;
 
-	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, layer))) {
+	if (!(dlid = build_dm_uuid(mem, lv, layer))) {
 		log_error("Failed to build dlid for %s.", lv->name);
 		return NULL;
 	}
@@ -641,7 +641,7 @@ int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 	char *type = NULL;
 	char *params = NULL;
 
-	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(mem, lv, layer)))
 		return_0;
 
 	if (!(dmt = _setup_task(NULL, dlid, 0,
@@ -872,7 +872,7 @@ int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
 	const struct dm_list *segh = &lv->segments;
 	struct lv_segment *seg = NULL;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
 	if (!(dmt = _setup_task(0, dlid, NULL, DM_DEVICE_STATUS, 0, 0)))
@@ -1015,7 +1015,7 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 	if (!(name = dm_build_dm_name(dm->mem, snap_lv->vg->name, snap_lv->name, NULL)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, snap_lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, snap_lv, NULL)))
 		return_0;
 
 	/*
@@ -1047,7 +1047,7 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer))) {
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;
 	}
@@ -1074,7 +1074,7 @@ int dev_manager_raid_status(struct dev_manager *dm,
 	char *params = NULL;
 	const char *layer = lv_layer(lv);
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
 	log_debug_activation("Getting raid device status for %s.", lv->name);
@@ -1138,7 +1138,7 @@ int dev_manager_raid_message(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
 	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TARGET_MSG, 0, 0)))
@@ -1173,7 +1173,7 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	char *params = NULL;
 	const char *layer = lv_layer(lv);
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
 	log_debug_activation("Getting cache device status for %s.", lv->name);
@@ -1282,7 +1282,7 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 	int r = 0;
 
 	/* Build dlid for the thin pool layer */
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
 	log_debug_activation("Getting thin pool device status for %s.", lv->name);
@@ -1328,7 +1328,7 @@ int dev_manager_thin_pool_percent(struct dev_manager *dm,
 				      lv_layer(lv))))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
 	log_debug_activation("Getting device status percentage for %s", name);
@@ -1351,7 +1351,7 @@ int dev_manager_thin_percent(struct dev_manager *dm,
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
 	log_debug_activation("Getting device status percentage for %s", name);
@@ -1374,7 +1374,7 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 	int r = 0;
 
 	/* Build dlid for the thin layer */
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
 	log_debug_activation("Getting device id for %s.", dlid);
@@ -1575,7 +1575,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
 	log_debug_activation("Getting device info for %s [%s]", name, dlid);
@@ -1648,7 +1648,7 @@ static int _add_partial_replicator_to_dtree(struct dev_manager *dm,
 	if (!_add_dev_to_dtree(dm, dtree, rlv, NULL))
 		return_0;
 
-	if (!(uuid = build_dm_uuid(dm->mem, rlv->lvid.s, NULL)))
+	if (!(uuid = build_dm_uuid(dm->mem, rlv, NULL)))
 		return_0;
 
 	rep_node = dm_tree_find_node_by_uuid(dtree, uuid);
@@ -1670,7 +1670,7 @@ static int _add_partial_replicator_to_dtree(struct dev_manager *dm,
 				/* If replicator exists - try connect existing heads */
 				if (rep_node) {
 					uuid = build_dm_uuid(dm->mem,
-							     rdev->replicator_dev->lv->lvid.s,
+							     rdev->replicator_dev->lv,
 							     NULL);
 					if (!uuid)
 						return_0;
@@ -1838,7 +1838,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 #if 0
 		/* ? Use origin_only to avoid 'deep' thin pool suspend ? */
 		/* FIXME Implement dm_tree_node_skip_childrens optimisation */
-		if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+		if (!(uuid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 			return_0;
 		if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)))
 			dm_tree_node_skip_childrens(thin_node, 1);
@@ -1868,7 +1868,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			/* Setup callback for non-activation partial tree */
 			/* Activation gets own callback when needed */
 			/* TODO: extend _cached_info() to return dnode */
-			if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+			if (!(uuid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 				return_0;
 			if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
 			    !_thin_pool_register_callback(dm, thin_node, lv))
@@ -1979,7 +1979,7 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 
 	sprintf(errid, "missing_%d_%d", segno, s);
 
-	if (!(dlid = build_dm_uuid(dm->mem, seg->lv->lvid.s, errid)))
+	if (!(dlid = build_dm_uuid(dm->mem, seg->lv, errid)))
 		return_NULL;
 
 	if (!(name = dm_build_dm_name(dm->mem, seg->lv->vg->name,
@@ -2087,18 +2087,18 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 					return_0;
 				continue;
 			}
-			if (!(dlid = build_dm_uuid(dm->mem, seg_metalv(seg, s)->lvid.s, NULL)))
+			if (!(dlid = build_dm_uuid(dm->mem, seg_metalv(seg, s), NULL)))
 				return_0;
 			if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_metale(seg, s)))
 				return_0;
 
-			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s)->lvid.s, NULL)))
+			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s), NULL)))
 				return_0;
 			if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_le(seg, s)))
 				return_0;
 		} else if (seg_type(seg, s) == AREA_LV) {
 
-			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s)->lvid.s, NULL)))
+			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s), NULL)))
 				return_0;
 			if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_le(seg, s)))
 				return_0;
@@ -2127,7 +2127,7 @@ static int _add_layer_target_to_dtree(struct dev_manager *dm,
 {
 	const char *layer_dlid;
 
-	if (!(layer_dlid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
+	if (!(layer_dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
 	/* Add linear mapping over layered LV */
@@ -2146,7 +2146,7 @@ static int _add_origin_target_to_dtree(struct dev_manager *dm,
 {
 	const char *real_dlid;
 
-	if (!(real_dlid = build_dm_uuid(dm->mem, lv->lvid.s, "real")))
+	if (!(real_dlid = build_dm_uuid(dm->mem, lv, "real")))
 		return_0;
 
 	if (!dm_tree_node_add_snapshot_origin_target(dnode, lv->size, real_dlid))
@@ -2167,13 +2167,13 @@ static int _add_snapshot_merge_target_to_dtree(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (!(origin_dlid = build_dm_uuid(dm->mem, lv->lvid.s, "real")))
+	if (!(origin_dlid = build_dm_uuid(dm->mem, lv, "real")))
 		return_0;
 
-	if (!(cow_dlid = build_dm_uuid(dm->mem, merging_snap_seg->cow->lvid.s, "cow")))
+	if (!(cow_dlid = build_dm_uuid(dm->mem, merging_snap_seg->cow, "cow")))
 		return_0;
 
-	if (!(merge_dlid = build_dm_uuid(dm->mem, merging_snap_seg->cow->lvid.s, NULL)))
+	if (!(merge_dlid = build_dm_uuid(dm->mem, merging_snap_seg->cow, NULL)))
 		return_0;
 
 	if (!dm_tree_node_add_snapshot_merge_target(dnode, lv->size, origin_dlid,
@@ -2199,10 +2199,10 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (!(origin_dlid = build_dm_uuid(dm->mem, snap_seg->origin->lvid.s, "real")))
+	if (!(origin_dlid = build_dm_uuid(dm->mem, snap_seg->origin, "real")))
 		return_0;
 
-	if (!(cow_dlid = build_dm_uuid(dm->mem, snap_seg->cow->lvid.s, "cow")))
+	if (!(cow_dlid = build_dm_uuid(dm->mem, snap_seg->cow, "cow")))
 		return_0;
 
 	size = (uint64_t) snap_seg->len * snap_seg->origin->vg->extent_size;
@@ -2516,7 +2516,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
 	/* We've already processed this node if it already has a context ptr */
@@ -2776,7 +2776,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 	/* Restore fs cookie */
 	dm_tree_set_cookie(root, fs_get_cookie());
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, laopts->origin_only ? lv_layer(lv) : NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, laopts->origin_only ? lv_layer(lv) : NULL)))
 		goto_out;
 
 	/* Only process nodes with uuid of "LVM-" plus VG id. */
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 57c7a5c..df521c4 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -360,13 +360,13 @@ static int _cache_add_target_line(struct dev_manager *dm,
 	struct lv_segment *cache_pool_seg = first_seg(seg->pool_lv);
 	char *metadata_uuid, *data_uuid, *origin_uuid;
 
-	if (!(metadata_uuid = build_dm_uuid(mem, cache_pool_seg->metadata_lv->lvid.s, NULL)))
+	if (!(metadata_uuid = build_dm_uuid(mem, cache_pool_seg->metadata_lv, NULL)))
 		return_0;
 
-	if (!(data_uuid = build_dm_uuid(mem, seg_lv(cache_pool_seg, 0)->lvid.s, NULL)))
+	if (!(data_uuid = build_dm_uuid(mem, seg_lv(cache_pool_seg, 0), NULL)))
 		return_0;
 
-	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0)->lvid.s, NULL)))
+	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), NULL)))
 		return_0;
 
 	if (!dm_tree_node_add_cache_target(node, len,
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 5088173..e35a372 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -356,14 +356,14 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 
 	if (seg->log_lv) {
 		/* If disk log, use its UUID */
-		if (!(log_dlid = build_dm_uuid(mem, seg->log_lv->lvid.s, NULL))) {
+		if (!(log_dlid = build_dm_uuid(mem, seg->log_lv, NULL))) {
 			log_error("Failed to build uuid for log LV %s.",
 				  seg->log_lv->name);
 			return 0;
 		}
 	} else {
 		/* If core log, use mirror's UUID and set DM_CORELOG flag */
-		if (!(log_dlid = build_dm_uuid(mem, seg->lv->lvid.s, NULL))) {
+		if (!(log_dlid = build_dm_uuid(mem, seg->lv, NULL))) {
 			log_error("Failed to build uuid for mirror LV %s.",
 				  seg->lv->name);
 			return 0;
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 380fe81..329dee5 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "lvm-string.h"
+#include "metadata-exported.h"
 
 #include <ctype.h>
 
@@ -160,8 +161,10 @@ int is_reserved_lvname(const char *name)
 	return rc;
 }
 
-char *build_dm_uuid(struct dm_pool *mem, const char *lvid,
+char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		    const char *layer)
 {
+	const char *lvid = lv->lvid.s;
+
 	return dm_build_dm_uuid(mem, UUID_PREFIX, lvid, layer);
 }
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index 13aacf8..82ebb12 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -23,6 +23,7 @@
 #define UUID_PREFIX "LVM-"
 
 struct pool;
+struct logical_volume;
 
 typedef enum name_error { NAME_VALID = 0, NAME_INVALID_EMPTY = -1,
 					NAME_INVALID_HYPEN = -2, NAME_INVALID_DOTS = -3,
@@ -32,7 +33,7 @@ typedef enum name_error { NAME_VALID = 0, NAME_INVALID_EMPTY = -1,
 int emit_to_buffer(char **buffer, size_t *size, const char *fmt, ...)
   __attribute__ ((format(printf, 3, 4)));
 
-char *build_dm_uuid(struct dm_pool *mem, const char *lvid,
+char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lvid,
 		    const char *layer);
 
 int validate_name(const char *n);
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 7c989f8..494fa92 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -277,13 +277,13 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (!(metadata_dlid = build_dm_uuid(mem, seg->metadata_lv->lvid.s, NULL))) {
+	if (!(metadata_dlid = build_dm_uuid(mem, seg->metadata_lv, NULL))) {
 		log_error("Failed to build uuid for metadata LV %s.",
 			  seg->metadata_lv->name);
 		return 0;
 	}
 
-	if (!(pool_dlid = build_dm_uuid(mem, seg_lv(seg, 0)->lvid.s, NULL))) {
+	if (!(pool_dlid = build_dm_uuid(mem, seg_lv(seg, 0), NULL))) {
 		log_error("Failed to build uuid for pool LV %s.",
 			  seg_lv(seg, 0)->name);
 		return 0;
@@ -535,7 +535,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 			  seg->lv->name);
 		return 0;
 	}
-	if (!(pool_dlid = build_dm_uuid(mem, seg->pool_lv->lvid.s, lv_layer(seg->pool_lv)))) {
+	if (!(pool_dlid = build_dm_uuid(mem, seg->pool_lv, lv_layer(seg->pool_lv)))) {
 		log_error("Failed to build uuid for pool LV %s.",
 			  seg->pool_lv->name);
 		return 0;
@@ -573,7 +573,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 				return 0;
 			}
 		}
-		if (!(external_dlid = build_dm_uuid(mem, seg->external_lv->lvid.s,
+		if (!(external_dlid = build_dm_uuid(mem, seg->external_lv,
 						    lv_layer(seg->external_lv)))) {
 			log_error("Failed to build uuid for external origin LV %s.",
 				  seg->external_lv->name);



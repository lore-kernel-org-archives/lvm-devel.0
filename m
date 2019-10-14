From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:36 -0400
Subject: master - cachevol: improve manipulation with dm tree
Message-ID: <201910141322.x9EDMa1Z018833@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2825ad9dd20a4f34693666d1efaa4ceb1c8e2b8f
Commit:        2825ad9dd20a4f34693666d1efaa4ceb1c8e2b8f
Parent:        a454a1b4ea478ce117808c8b2dd480ff4d5eb2d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 14 10:31:38 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:17:50 2019 +0200

cachevol: improve manipulation with dm tree

Enhance activation of cached devices using cachevol.
Correctly instatiace  cachevol -cdata & -cmeta devices with
'-' in name (as they are only layered devices).
Code is also a bit more compacted (although still not ideal,
as the usage of extra UUIDs stored in metadata is troublesome
and will be repaired later).

NOTE: this patch my brink potentially minor incompatiblity for 'runtime' upgrade
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |  158 ++++++++++++++++++++++++-------------------
 2 files changed, 89 insertions(+), 70 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6458f4c..e4106c1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Enhance activation of cache devices with cachevols.
   Add _cvol in list of protected suffixes and start use it with DM UUID.
   Rename LV converted to cachevol to use _cvol suffix.
   Use normal LVs for wiping of cachevols.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index dfcccce..e7aa6b1 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2447,6 +2447,49 @@ static int _pool_register_callback(struct dev_manager *dm,
 	return 1;
 }
 
+/* Add special devices _cmeta & _cdata on top of CacheVol to dm tree */
+static int _add_cvol_subdev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
+				     const struct logical_volume *lv, int meta_or_data)
+{
+	const char *layer = meta_or_data ? "cmeta" : "cdata";
+	struct dm_pool *mem = dm->track_pending_delete ? dm->cmd->pending_delete_mem : dm->mem;
+	const struct logical_volume *pool_lv = first_seg(lv)->pool_lv;
+	struct lv_segment *lvseg = first_seg(lv);
+	struct dm_info info;
+	char *name ,*dlid;
+	union lvid lvid = { 0 };
+
+	/* TODO: Convert to use just  CVOL UUID with suffix */
+	memcpy(&lvid.id[0], &lv->vg->id, sizeof(struct id));
+	memcpy(&lvid.id[1], (meta_or_data) ? &lvseg->metadata_id : &lvseg->data_id, sizeof(struct id));
+
+	if (!(dlid = dm_build_dm_uuid(mem, UUID_PREFIX, (const char *)&lvid.s, layer)))
+		return_0;
+
+	/* Name is actually not really needed here, but aids debugging... */
+	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, pool_lv->name, layer)))
+		return_0;
+
+	if (!_info(dm->cmd, name, dlid, 1, 0, &info, NULL, NULL))
+		return_0;
+
+	if (info.exists) {
+		if (!dm_tree_add_dev_with_udev_flags(dtree, info.major, info.minor,
+						     _get_udev_flags(dm, lv, layer, 0, 0, 0))) {
+			log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree.", info.major, info.minor);
+			return 0;
+		}
+		if (dm->track_pending_delete) {
+			log_debug_activation("Tracking pending delete for %s %s (%s).",
+					     layer, display_lvname(lv), dlid);
+			if (!str_list_add(mem, &dm->cmd->pending_delete, dlid))
+				return_0;
+		}
+	}
+
+	return 1;
+}
+
 /* Declaration to resolve suspend tree and message passing for thin-pool */
 static int _add_target_to_dtree(struct dev_manager *dm,
 				struct dm_tree_node *dnode,
@@ -2481,51 +2524,11 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/* Unused cache pool is activated as metadata */
 	}
 
-	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv) && dm->activation) {
-		struct logical_volume *pool_lv = first_seg(lv)->pool_lv;
-		struct lv_segment *lvseg = first_seg(lv);
-		struct dm_info info_meta;
-		struct dm_info info_data;
-		union lvid lvid_meta;
-		union lvid lvid_data;
-		char *name_meta;
-		char *name_data;
-		char *dlid_meta;
-		char *dlid_data;
-
-		memset(&lvid_meta, 0, sizeof(lvid_meta));
-		memset(&lvid_data, 0, sizeof(lvid_meta));
-		memcpy(&lvid_meta.id[0], &lv->vg->id, sizeof(struct id));
-		memcpy(&lvid_meta.id[1], &lvseg->metadata_id, sizeof(struct id));
-		memcpy(&lvid_data.id[0], &lv->vg->id, sizeof(struct id));
-		memcpy(&lvid_data.id[1], &lvseg->data_id, sizeof(struct id));
-
-		if (!(dlid_meta = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_meta.s, "cmeta")))
+	if (lv_is_cache(lv) && (plv = (first_seg(lv)->pool_lv)) && lv_is_cache_vol(plv)) {
+		if (!_add_cvol_subdev_to_dtree(dm, dtree, lv, 0) ||
+		    !_add_cvol_subdev_to_dtree(dm, dtree, lv, 1) ||
+		    !_add_dev_to_dtree(dm, dtree, plv, lv_layer(plv)))
 			return_0;
-		if (!(dlid_data = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_data.s, "cdata")))
-			return_0;
-		if (!(name_meta = dm_build_dm_name(dm->mem, lv->vg->name, pool_lv->name, "_cmeta")))
-			return_0;
-		if (!(name_data = dm_build_dm_name(dm->mem, lv->vg->name, pool_lv->name, "_cdata")))
-			return_0;
-
-		if (!_info(dm->cmd, name_meta, dlid_meta, 1, 0, &info_meta, NULL, NULL))
-			return_0;
-
-		if (!_info(dm->cmd, name_data, dlid_data, 1, 0, &info_data, NULL, NULL))
-			return_0;
-
-		if (info_meta.exists &&
-		    !dm_tree_add_dev_with_udev_flags(dtree, info_meta.major, info_meta.minor,
-						     _get_udev_flags(dm, lv, NULL, 0, 0, 0))) {
-			log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree.", info_meta.major, info_meta.minor);
-		}
-
-		if (info_data.exists &&
-		    !dm_tree_add_dev_with_udev_flags(dtree, info_data.major, info_data.minor,
-						     _get_udev_flags(dm, lv, NULL, 0, 0, 0))) {
-			log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree.", info_data.major, info_data.minor);
-		}
 	}
 
 	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, NULL))
@@ -3228,11 +3231,14 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 					     laopts->noscan, laopts->temporary,
 					     0);
 
-		log_debug("Add cache pool %s to dtree before cache %s", pool_lv->name, lv->name);
+		if (lv_is_pending_delete(lvseg->lv))
+			dm->track_pending_delete = 1;
 
-		if (!_add_new_lv_to_dtree(dm, dtree, pool_lv, laopts, NULL)) {
-			log_error("Failed to add cachepool to dtree before cache");
-			return_0;
+		log_debug("Add cachevol %s to dtree before cache %s.", pool_lv->name, lv->name);
+
+		if (!_add_new_lv_to_dtree(dm, dtree, pool_lv, laopts, lv_layer(pool_lv))) {
+			log_error("Failed to add cachevol to dtree before cache.");
+			return 0;
 		}
 
 		memset(&lvid_meta, 0, sizeof(lvid_meta));
@@ -3247,9 +3253,9 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		if (!(dlid_data = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_data.s, "cdata")))
 			return_0;
 
-		if (!(name_meta = dm_build_dm_name(dm->mem, vg->name, pool_lv->name, "_cmeta")))
+		if (!(name_meta = dm_build_dm_name(dm->mem, vg->name, pool_lv->name, "cmeta")))
 			return_0;
-		if (!(name_data = dm_build_dm_name(dm->mem, vg->name, pool_lv->name, "_cdata")))
+		if (!(name_data = dm_build_dm_name(dm->mem, vg->name, pool_lv->name, "cdata")))
 			return_0;
 
 		if (!(dlid_pool = build_dm_uuid(dm->mem, pool_lv, NULL)))
@@ -3266,17 +3272,23 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 								  udev_flags)))
 			return_0;
 
-		/* add load_segment to meta dnode: linear, size of meta area */
-		if (!add_linear_area_to_dtree(dnode_meta,
-					      meta_len,
-					      lv->vg->extent_size,
-					      lv->vg->cmd->use_linear_target,
-					      lv->vg->name, lv->name))
-			return_0;
+		if (dm->track_pending_delete) {
+			log_debug_activation("Using error for pending meta delete %s.", display_lvname(lv));
+			if (!dm_tree_node_add_error_target(dnode_meta, (uint64_t)lv->vg->extent_size * meta_len))
+				return_0;
+		} else {
+			/* add load_segment to meta dnode: linear, size of meta area */
+			if (!add_linear_area_to_dtree(dnode_meta,
+						      meta_len,
+						      lv->vg->extent_size,
+						      lv->vg->cmd->use_linear_target,
+						      lv->vg->name, lv->name))
+				return_0;
 
-		/* add seg_area to prev load_seg: offset 0 maps to cachepool lv offset 0 */
-		if (!dm_tree_node_add_target_area(dnode_meta, NULL, dlid_pool, 0))
-			return_0;
+			/* add seg_area to prev load_seg: offset 0 maps to cachepool lv offset 0 */
+			if (!dm_tree_node_add_target_area(dnode_meta, NULL, dlid_pool, 0))
+				return_0;
+		}
 
 		/* add data dnode */
 		if (!(dnode_data = dm_tree_add_new_dev_with_udev_flags(dtree,
@@ -3289,17 +3301,23 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 								  udev_flags)))
 			return_0;
 
-		/* add load_segment to data dnode: linear, size of data area */
-		if (!add_linear_area_to_dtree(dnode_data,
-					      data_len,
-					      lv->vg->extent_size,
-					      lv->vg->cmd->use_linear_target,
-					      lv->vg->name, lv->name))
-			return_0;
+		if (dm->track_pending_delete) {
+			log_debug_activation("Using error for pending data delete %s.", display_lvname(lv));
+			if (!dm_tree_node_add_error_target(dnode_data, (uint64_t)lv->vg->extent_size * data_len))
+				return_0;
+		} else {
+			/* add load_segment to data dnode: linear, size of data area */
+			if (!add_linear_area_to_dtree(dnode_data,
+						      data_len,
+						      lv->vg->extent_size,
+						      lv->vg->cmd->use_linear_target,
+						      lv->vg->name, lv->name))
+				return_0;
 
-		/* add seg_area to prev load_seg: offset 0 maps to cachepool lv after meta */
-		if (!dm_tree_node_add_target_area(dnode_data, NULL, dlid_pool, meta_len))
-			return_0;
+			/* add seg_area to prev load_seg: offset 0 maps to cachepool lv after meta */
+			if (!dm_tree_node_add_target_area(dnode_data, NULL, dlid_pool, meta_len))
+				return_0;
+		}
 	}
 
 	/* FIXME Seek a simpler way to lay out the snapshot-merge tree. */



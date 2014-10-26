From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 26 Oct 2014 17:37:51 +0000 (UTC)
Subject: master - thin: simplify thin volume creation
Message-ID: <20141026173751.DA9B560282@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff2e8b0de6aafcf304b30e5f90501f3638ead22f
Commit:        ff2e8b0de6aafcf304b30e5f90501f3638ead22f
Parent:        52dfa6dd4491fd6f584b83d0924b82bea3bc1092
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 08:13:59 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 26 18:37:13 2014 +0100

thin: simplify thin volume creation

Move code for creation of thin volume into a single place
out of lv_extend().  This allows to drop extra pool arg
for alloc_lv_segment() && lv_extend() and makes code
more easier to read and follow.
---
 lib/format1/import-extents.c     |    4 +-
 lib/format_pool/import_export.c  |    4 +-
 lib/format_text/import_vsn1.c    |    2 +-
 lib/metadata/lv_alloc.h          |    5 +-
 lib/metadata/lv_manip.c          |  135 ++++++++++++-------------------------
 lib/metadata/merge.c             |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/pool_manip.c        |    2 +-
 tools/lvconvert.c                |    2 +-
 9 files changed, 54 insertions(+), 104 deletions(-)

diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
index f0f4f65..bfcf0de 100644
--- a/lib/format1/import-extents.c
+++ b/lib/format1/import-extents.c
@@ -226,7 +226,7 @@ static int _read_linear(struct cmd_context *cmd, struct lv_map *lvm)
 		len = _area_length(lvm, le);
 
 		if (!(seg = alloc_lv_segment(segtype, lvm->lv, le, len, 0, 0,
-					     NULL, NULL, 1, len, 0, 0, 0, NULL))) {
+					     NULL, 1, len, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate linear segment.");
 			return 0;
 		}
@@ -298,7 +298,7 @@ static int _read_stripes(struct cmd_context *cmd, struct lv_map *lvm)
 		if (!(seg = alloc_lv_segment(segtype, lvm->lv,
 					     lvm->stripes * first_area_le,
 					     lvm->stripes * area_len,
-					     0, lvm->stripe_size, NULL, NULL,
+					     0, lvm->stripe_size, NULL,
 					     lvm->stripes,
 					     area_len, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate striped segment.");
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 6ef0757..1aeabe2 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -194,7 +194,7 @@ static int _add_stripe_seg(struct dm_pool *mem,
 
 	if (!(seg = alloc_lv_segment(segtype, lv, *le_cur,
 				     area_len * usp->num_devs, 0,
-				     usp->striping, NULL, NULL, usp->num_devs,
+				     usp->striping, NULL, usp->num_devs,
 				     area_len, 0, 0, 0, NULL))) {
 		log_error("Unable to allocate striped lv_segment structure");
 		return 0;
@@ -234,7 +234,7 @@ static int _add_linear_seg(struct dm_pool *mem,
 
 		if (!(seg = alloc_lv_segment(segtype, lv, *le_cur,
 					     area_len, 0, usp->striping,
-					     NULL, NULL, 1, area_len,
+					     NULL, 1, area_len,
 					     POOL_PE_SIZE, 0, 0, NULL))) {
 			log_error("Unable to allocate linear lv_segment "
 				  "structure");
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 1783b1e..c6a0cf9 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -363,7 +363,7 @@ static int _read_segment(struct logical_volume *lv, const struct dm_config_node
 		return_0;
 
 	if (!(seg = alloc_lv_segment(segtype, lv, start_extent,
-				     extent_count, 0, 0, NULL, NULL, area_count,
+				     extent_count, 0, 0, NULL, area_count,
 				     extent_count, 0, 0, 0, NULL))) {
 		log_error("Segment allocation failed");
 		return 0;
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index 9824c67..1ac3f1f 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -24,7 +24,6 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 				    uint64_t status,
 				    uint32_t stripe_size,
 				    struct logical_volume *log_lv,
-				    struct logical_volume *thin_pool_lv,
 				    uint32_t area_count,
 				    uint32_t area_len,
 				    uint32_t chunk_size,
@@ -79,9 +78,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 int lv_add_log_segment(struct alloc_handle *ah, uint32_t first_area,
 		       struct logical_volume *log_lv, uint64_t status);
 int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
-                           uint32_t extents,
-			   const struct segment_type *segtype,
-			   const char *thin_pool_name);
+			   uint32_t extents, const struct segment_type *segtype);
 
 void alloc_destroy(struct alloc_handle *ah);
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b12af6c..1e9d1c6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -921,7 +921,6 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 				    uint64_t status,
 				    uint32_t stripe_size,
 				    struct logical_volume *log_lv,
-				    struct logical_volume *thin_pool_lv,
 				    uint32_t area_count,
 				    uint32_t area_len,
 				    uint32_t chunk_size,
@@ -967,26 +966,6 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	dm_list_init(&seg->tags);
 	dm_list_init(&seg->thin_messages);
 
-	if (thin_pool_lv) {
-		/* If this is thin volume, thin snapshot is being created */
-		if (lv_is_thin_volume(thin_pool_lv)) {
-			seg->transaction_id = first_seg(first_seg(thin_pool_lv)->pool_lv)->transaction_id;
-			if (!attach_pool_lv(seg, first_seg(thin_pool_lv)->pool_lv, thin_pool_lv, NULL))
-				return_NULL;
-			/* Use the same external origin */
-			if (!attach_thin_external_origin(seg, first_seg(thin_pool_lv)->external_lv))
-				return_NULL;
-		} else if (lv_is_thin_pool(thin_pool_lv)) {
-			seg->transaction_id = first_seg(thin_pool_lv)->transaction_id;
-			if (!attach_pool_lv(seg, thin_pool_lv, NULL, NULL))
-				return_NULL;
-		} else {
-			log_error(INTERNAL_ERROR "Volume %s is not thin volume or thin pool",
-				  thin_pool_lv->name);
-			return NULL;
-		}
-	}
-
 	if (log_lv && !attach_mirror_log(seg, log_lv))
 		return_NULL;
 
@@ -1013,7 +992,7 @@ struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 
 	if (!(seg = alloc_lv_segment(segtype, lv, old_le_count,
 				     lv->le_count - old_le_count, status, 0,
-				     NULL, NULL, 0, lv->le_count - old_le_count,
+				     NULL, 0, lv->le_count - old_le_count,
 				     0, 0, 0, NULL))) {
 		log_error("Couldn't allocate new snapshot segment.");
 		return NULL;
@@ -1369,7 +1348,7 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 
 	/* FIXME Check for any attached LVs that will become orphans e.g. mirror logs */
 
-	if (!lv_add_virtual_segment(lv, 0, len, get_segtype_from_string(lv->vg->cmd, "error"), NULL))
+	if (!lv_add_virtual_segment(lv, 0, len, get_segtype_from_string(lv->vg->cmd, "error")))
 		return_0;
 
 	return 1;
@@ -1859,7 +1838,7 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 
 	if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count,
 				     aa[0].len * area_multiple,
-				     status, stripe_size, NULL, NULL,
+				     status, stripe_size, NULL,
 				     area_count,
 				     aa[0].len, 0u, region_size, 0u, NULL))) {
 		log_error("Couldn't allocate new LV segment.");
@@ -3011,21 +2990,9 @@ static int _allocate(struct alloc_handle *ah,
 }
 
 int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
-			   uint32_t extents, const struct segment_type *segtype,
-			   const char *thin_pool_name)
+			   uint32_t extents, const struct segment_type *segtype)
 {
 	struct lv_segment *seg;
-	struct logical_volume *thin_pool_lv = NULL;
-	struct lv_list *lvl;
-
-	if (thin_pool_name) {
-		if (!(lvl = find_lv_in_vg(lv->vg, thin_pool_name))) {
-			log_error("Unable to find existing pool LV %s in VG %s.",
-				  thin_pool_name, lv->vg->name);
-			return 0;
-		}
-		thin_pool_lv = lvl->lv;
-	}
 
 	if (!dm_list_empty(&lv->segments) &&
 	    (seg = last_seg(lv)) && (seg->segtype == segtype)) {
@@ -3033,9 +3000,9 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 		seg->len += extents;
 	} else {
 		if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents,
-					     status, 0, NULL, thin_pool_lv, 0,
+					     status, 0, NULL, 0,
 					     extents, 0, 0, 0, NULL))) {
-			log_error("Couldn't allocate new zero segment.");
+			log_error("Couldn't allocate new %s segment.", segtype->name);
 			return 0;
 		}
 		lv->status |= VIRTUAL;
@@ -3171,7 +3138,7 @@ static struct lv_segment *_convert_seg_to_mirror(struct lv_segment *seg,
 	if (!(newseg = alloc_lv_segment(get_segtype_from_string(seg->lv->vg->cmd, "mirror"),
 					seg->lv, seg->le, seg->len,
 					seg->status, seg->stripe_size,
-					log_lv, NULL,
+					log_lv,
 					seg->area_count, seg->area_len,
 					seg->chunk_size, region_size,
 					seg->extents_copied, NULL))) {
@@ -3273,7 +3240,7 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 
 		if (!(new_seg = alloc_lv_segment(segtype, copy_lv,
 						 seg->le, seg->len, PVMOVE, 0,
-						 NULL, NULL, 1, seg->len,
+						 NULL, 1, seg->len,
 						 0, 0, 0, NULL)))
 			return_0;
 
@@ -3473,7 +3440,7 @@ static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 	 * First, create our top-level segment for our top-level LV
 	 */
 	if (!(mapseg = alloc_lv_segment(segtype, lv, 0, 0, lv->status,
-					stripe_size, NULL, NULL,
+					stripe_size, NULL,
 					devices, 0, 0, region_size, 0, NULL))) {
 		log_error("Failed to create mapping segment for %s", lv->name);
 		return 0;
@@ -3665,7 +3632,7 @@ int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t region_size,
-	      uint32_t extents, const char *thin_pool_name,
+	      uint32_t extents,
 	      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
 	      int approx_alloc)
 {
@@ -3679,16 +3646,12 @@ int lv_extend(struct logical_volume *lv,
 	log_very_verbose("Adding segment of type %s to LV %s.", segtype->name, lv->name);
 
 	if (segtype_is_virtual(segtype))
-		return lv_add_virtual_segment(lv, 0u, extents, segtype, thin_pool_name);
+		return lv_add_virtual_segment(lv, 0u, extents, segtype);
 
-	if (!lv->le_count &&
-	    (segtype_is_thin_pool(segtype) ||
-	     segtype_is_cache_pool(segtype))) {
+	if (!lv->le_count && segtype_is_pool(segtype)) {
 		/*
-		 * Thinpool and cache_pool allocations treat the metadata
-		 * device like a mirror log.
+		 * Pool allocations treat the metadata device like a mirror log.
 		 */
-		/* FIXME Allow pool and data on same device with NORMAL */
 		/* FIXME Support striped metadata pool */
 		log_count = 1;
 	} else if (segtype_is_raid(segtype) && !lv->le_count)
@@ -3704,7 +3667,7 @@ int lv_extend(struct logical_volume *lv,
 	if (segtype_is_raid(segtype))
 		new_extents -= ah->log_len * ah->area_multiple;
 
-	if (segtype_is_thin_pool(segtype) || segtype_is_cache_pool(segtype)) {
+	if (segtype_is_pool(segtype)) {
 		if (!(r = create_pool(lv, segtype, ah, stripes, stripe_size)))
 			stack;
 	} else if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype)) {
@@ -4293,7 +4256,7 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 		       mseg->stripe_size,
 		       seg_mirrors,
 		       mseg->region_size,
-		       lp->poolmetadataextents - lv->le_count, NULL,
+		       lp->poolmetadataextents - lv->le_count,
 		       pvh, alloc, 0))
 		return_0;
 
@@ -4932,7 +4895,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 		   !lv_extend(lv, lp->segtype,
 			      lp->stripes, lp->stripe_size,
 			      lp->mirrors, first_seg(lv)->region_size,
-			      lp->extents - lv->le_count, NULL,
+			      lp->extents - lv->le_count,
 			      pvh, alloc, lp->approx_alloc))
 		return_NULL;
 
@@ -6017,7 +5980,7 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	/* Replace the empty layer with error segment */
 	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "error")))
 		return_0;
-	if (!lv_add_virtual_segment(layer_lv, 0, parent->le_count, segtype, NULL))
+	if (!lv_add_virtual_segment(layer_lv, 0, parent->le_count, segtype))
 		return_0;
 
 	return 1;
@@ -6066,7 +6029,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 
 		segtype = get_segtype_from_string(cmd, "error");
 
-		if (!lv_add_virtual_segment(layer_lv, 0, lv_where->le_count, segtype, NULL)) {
+		if (!lv_add_virtual_segment(layer_lv, 0, lv_where->le_count, segtype)) {
 			log_error("Creation of transient LV %s for mirror conversion in VG %s failed.", name, lv_where->vg->name);
 			return NULL;
 		}
@@ -6117,7 +6080,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 
 	/* allocate a new linear segment */
 	if (!(mapseg = alloc_lv_segment(segtype, lv_where, 0, layer_lv->le_count,
-					status, 0, NULL, NULL, 1, layer_lv->le_count,
+					status, 0, NULL, 1, layer_lv->le_count,
 					0, 0, 0, NULL)))
 		return_NULL;
 
@@ -6174,7 +6137,7 @@ static int _extend_layer_lv_for_segment(struct logical_volume *layer_lv,
 	/* allocate a new segment */
 	if (!(mapseg = alloc_lv_segment(segtype, layer_lv, layer_lv->le_count,
 					seg->area_len, status, 0,
-					NULL, NULL, 1, seg->area_len, 0, 0, 0, seg)))
+					NULL, 1, seg->area_len, 0, 0, 0, seg)))
 		return_0;
 
 	/* map the new segment to the original underlying are */
@@ -6445,7 +6408,7 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 		return_NULL;
 
 	if (!lv_extend(lv, segtype, 1, 0, 1, 0, voriginextents,
-		       NULL, NULL, ALLOC_INHERIT, 0))
+		       NULL, ALLOC_INHERIT, 0))
 		return_NULL;
 
 	/* store vg on disk(s) */
@@ -6594,9 +6557,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	uint64_t status = lp->permission | VISIBLE_LV;
 	const struct segment_type *create_segtype = lp->segtype;
 	struct logical_volume *lv, *origin_lv = NULL;
-	struct logical_volume *pool_lv;
+	struct logical_volume *pool_lv = NULL;
 	struct logical_volume *tmp_lv;
-	const char *thin_name = NULL;
+	struct lv_segment *seg, *pool_seg;
 
 	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
@@ -6785,19 +6748,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		thin_name = lp->pool_name;
-
 		if (origin_lv) {
 			if (lv_is_locked(origin_lv)) {
 				log_error("Snapshots of locked devices are not supported.");
 				return NULL;
 			}
 
-			/* For thin snapshot we must have matching pool */
-			if (lv_is_thin_volume(origin_lv) &&
-			    (strcmp(first_seg(origin_lv)->pool_lv->name, lp->pool_name) == 0))
-				thin_name = origin_lv->name;
-
 			lp->voriginextents = origin_lv->le_count;
 
 			/*
@@ -6883,7 +6839,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!archive(vg))
 		return_NULL;
 
-	if (seg_is_thin_volume(lp)) {
+	if (pool_lv && seg_is_thin_volume(lp)) {
 		/* Ensure all stacked messages are submitted */
 		if ((pool_is_active(pool_lv) || is_change_activating(lp->activate)) &&
 		    !update_pool_lv(pool_lv, 1))
@@ -6914,7 +6870,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		       lp->mirrors,
 		       seg_is_pool(lp) ? lp->pool_metadata_extents : lp->region_size,
 		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
-		       thin_name, lp->pvh, lp->alloc, lp->approx_alloc))
+		       lp->pvh, lp->alloc, lp->approx_alloc))
 		return_NULL;
 
 	/* Unlock memory if possible */
@@ -6943,32 +6899,29 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			stack;
 			goto revert_new_lv;
 		}
-	} else if (seg_is_thin_volume(lp)) {
-		pool_lv = first_seg(lv)->pool_lv;
-		if (!(first_seg(lv)->device_id =
-		      get_free_pool_device_id(first_seg(pool_lv))))
+	} else if (pool_lv && seg_is_thin_volume(lp)) {
+		seg = first_seg(lv);
+		pool_seg = first_seg(pool_lv);
+		if (!(seg->device_id = get_free_pool_device_id(pool_seg)))
 			return_NULL;
-		/*
-		 * Check if using 'external origin' or the 'normal' snapshot
-		 * within the same thin pool
-		 */
-		if (origin_lv && (first_seg(origin_lv)->pool_lv != pool_lv)) {
-			if (!pool_supports_external_origin(first_seg(pool_lv), origin_lv))
-				return_0;
-			if (origin_lv->status & LVM_WRITE) {
-				log_error("Cannot use writable LV as the external origin.");
-				return 0; // TODO conversion for inactive
-			}
-			if (lv_is_active(origin_lv) && !lv_is_external_origin(origin_lv)) {
-				log_error("Cannot use active LV for the external origin.");
-				return 0; // We can't be sure device is read-only
-			}
-			if (!attach_thin_external_origin(first_seg(lv), origin_lv))
+		seg->transaction_id = pool_seg->transaction_id;
+		if (origin_lv && lv_is_thin_volume(origin_lv) &&
+		    (first_seg(origin_lv)->pool_lv == pool_lv)) {
+			/* For thin snapshot pool must match */
+			if (!attach_pool_lv(seg, pool_lv, origin_lv, NULL))
+				return_NULL;
+			/* Use the same external origin */
+			if (!attach_thin_external_origin(seg, first_seg(origin_lv)->external_lv))
+				return_NULL;
+		} else {
+			if (!attach_pool_lv(seg, pool_lv, NULL, NULL))
+				return_NULL;
+			/* If there is an external origin... */
+			if (!attach_thin_external_origin(seg, origin_lv))
 				return_NULL;
 		}
 
-		if (!attach_pool_message(first_seg(pool_lv),
-					 DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0))
+		if (!attach_pool_message(pool_seg, DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0))
 			return_NULL;
 	}
 
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index c8c9543..5e09123 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -489,7 +489,7 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 	if (!(split_seg = alloc_lv_segment(seg->segtype,
 					   seg->lv, seg->le, seg->len,
 					   seg->status, seg->stripe_size,
-					   seg->log_lv, seg->pool_lv,
+					   seg->log_lv,
 					   seg->area_count, seg->area_len,
 					   seg->chunk_size, seg->region_size,
 					   seg->extents_copied, seg->pvmove_source_seg))) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d05333c..5ac68bf 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -709,7 +709,7 @@ int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t region_size,
-	      uint32_t extents, const char *thin_pool_name,
+	      uint32_t extents,
 	      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
 	      int approx_alloc);
 
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index b4259a8..b84950c 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -638,7 +638,7 @@ int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
 		       seg->stripe_size,
 		       seg_mirrors,
 		       seg->region_size,
-		       extents - lv->le_count, NULL,
+		       extents - lv->le_count,
 		       pvh, lv->alloc, 0))
 		return_0;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6d6d305..f22c84b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3088,7 +3088,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 
 	/* Allocate a new pool segment */
 	if (!(seg = alloc_lv_segment(lp->segtype, pool_lv, 0, data_lv->le_count,
-				     pool_lv->status, 0, NULL, NULL, 1,
+				     pool_lv->status, 0, NULL, 1,
 				     data_lv->le_count, 0, 0, 0, NULL)))
 		return_0;
 



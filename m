From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:13 -0400
Subject: [PATCH 01/20] Refactor metadata.[ch] into vg.[ch] for vg functions.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The metadata.[ch] files are very large.  This patch makes a first
attempt at separating out vg functions and data, particularly
related to the reporting fields calculations.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks.in             |    1 +
 lib/Makefile.in                  |    1 +
 lib/metadata/metadata-exported.h |   99 +---------
 lib/metadata/metadata.c          |  418 ------------------------------------
 lib/metadata/metadata.h          |    7 -
 lib/metadata/vg.c                |  436 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/vg.h                |  127 +++++++++++
 7 files changed, 567 insertions(+), 522 deletions(-)
 create mode 100644 lib/metadata/vg.c
 create mode 100644 lib/metadata/vg.h

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 2b15844..4dca46f 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -35,6 +35,7 @@
 @top_srcdir@/lib/metadata/metadata-exported.h
 @top_srcdir@/lib/metadata/pv_alloc.h
 @top_srcdir@/lib/metadata/segtype.h
+ at top_srcdir@/lib/metadata/vg.h
 @top_srcdir@/lib/mm/memlock.h
 @top_srcdir@/lib/mm/xlate.h
 @top_builddir@/lib/misc/configure.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 2f31c04..172a0fd 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -82,6 +82,7 @@ SOURCES =\
 	metadata/replicator_manip.c \
 	metadata/segtype.c \
 	metadata/snapshot_manip.c \
+	metadata/vg.c \
 	misc/crc.c \
 	misc/lvm-exec.c \
 	misc/lvm-file.c \
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a72a6bf..fef6903 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -22,6 +22,7 @@
 #define _LVM_METADATA_EXPORTED_H
 
 #include "uuid.h"
+#include "vg.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
@@ -122,15 +123,6 @@
 
 /* Ordered list - see lv_manip.c */
 typedef enum {
-	ALLOC_INVALID,
-	ALLOC_CONTIGUOUS,
-	ALLOC_CLING,
-	ALLOC_NORMAL,
-	ALLOC_ANYWHERE,
-	ALLOC_INHERIT
-} alloc_policy_t;
-
-typedef enum {
 	AREA_UNASSIGNED,
 	AREA_PV,
 	AREA_LV
@@ -229,70 +221,6 @@ struct format_instance {
 	void *private;
 };
 
-struct volume_group {
-	struct cmd_context *cmd;
-	struct dm_pool *vgmem;
-	struct format_instance *fid;
-	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
-	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
-	uint32_t seqno;		/* Metadata sequence number */
-
-	alloc_policy_t alloc;
-	uint64_t status;
-
-	struct id id;
-	char *name;
-	char *old_name;		/* Set during vgrename and vgcfgrestore */
-	char *system_id;
-
-	uint32_t extent_size;
-	uint32_t extent_count;
-	uint32_t free_count;
-
-	uint32_t max_lv;
-	uint32_t max_pv;
-
-	/* physical volumes */
-	uint32_t pv_count;
-	struct dm_list pvs;
-
-	/*
-	 * logical volumes
-	 * The following relationship should always hold:
-	 * dm_list_size(lvs) = user visible lv_count + snapshot_count + other invisible LVs
-	 *
-	 * Snapshots consist of 2 instances of "struct logical_volume":
-	 * - cow (lv_name is visible to the user)
-	 * - snapshot (lv_name is 'snapshotN')
-	 *
-	 * Mirrors consist of multiple instances of "struct logical_volume":
-	 * - one for the mirror log
-	 * - one for each mirror leg
-	 * - one for the user-visible mirror LV
-	 */
-	struct dm_list lvs;
-
-	struct dm_list tags;
-
-	/*
-	 * FIXME: Move the next fields into a different struct?
-	 */
-
-	/*
-	 * List of removed physical volumes by pvreduce.
-	 * They have to get cleared on vg_commit.
-	 */
-	struct dm_list removed_pvs;
-	uint32_t open_mode; /* FIXME: read or write - check lock type? */
-
-	/*
-	 * Store result of the last vg_read().
-	 * 0 for success else appropriate FAILURE_* bits set.
-	 */
-	uint32_t read_status;
-	uint32_t mda_copies; /* target number of mdas for this VG */
-};
-
 /* There will be one area for each stripe */
 struct lv_segment_area {
 	area_type_t type;
@@ -501,6 +429,7 @@ int is_global_vg(const char *vg_name);
 int is_orphan_vg(const char *vg_name);
 int is_orphan(const struct physical_volume *pv);
 int is_missing_pv(const struct physical_volume *pv);
+int vg_missing_pv_count(const struct volume_group *vg);
 int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_from,
 		       struct volume_group *vg_to);
@@ -552,11 +481,6 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
 	      struct pvcreate_params *pp);
 int vg_reduce(struct volume_group *vg, char *pv_name);
 int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag);
-int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size);
-int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv);
-int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv);
-int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc);
-int vg_set_clustered(struct volume_group *vg, int clustered);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 /* FIXME: Investigate refactoring these functions to take a pv ISO pv_list */
@@ -746,10 +670,6 @@ int vg_remove_snapshot(struct logical_volume *cow);
 
 int vg_check_status(const struct volume_group *vg, uint64_t status);
 
-/*
- * Returns visible LV count - number of LVs from user perspective
- */
-unsigned vg_visible_lvs(const struct volume_group *vg);
 
 /*
  * Check if the VG reached maximal LVs count (if set)
@@ -876,21 +796,6 @@ int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignore);
 
 uint64_t lv_size(const struct logical_volume *lv);
 
-int vg_missing_pv_count(const struct volume_group *vg);
-uint32_t vg_seqno(const struct volume_group *vg);
-uint64_t vg_status(const struct volume_group *vg);
-uint64_t vg_size(const struct volume_group *vg);
-uint64_t vg_free(const struct volume_group *vg);
-uint64_t vg_extent_size(const struct volume_group *vg);
-uint64_t vg_extent_count(const struct volume_group *vg);
-uint64_t vg_free_count(const struct volume_group *vg);
-uint64_t vg_pv_count(const struct volume_group *vg);
-uint64_t vg_max_pv(const struct volume_group *vg);
-uint64_t vg_max_lv(const struct volume_group *vg);
-uint32_t vg_mda_count(const struct volume_group *vg);
-uint32_t vg_mda_used_count(const struct volume_group *vg);
-uint32_t vg_mda_copies(const struct volume_group *vg);
-int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d14c33c..ca741b2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1020,31 +1020,6 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 	return (uint64_t) size / extent_size;
 }
 
-static int _recalc_extents(uint32_t *extents, const char *desc1,
-			   const char *desc2, uint32_t old_size,
-			   uint32_t new_size)
-{
-	uint64_t size = (uint64_t) old_size * (*extents);
-
-	if (size % new_size) {
-		log_error("New size %" PRIu64 " for %s%s not an exact number "
-			  "of new extents.", size, desc1, desc2);
-		return 0;
-	}
-
-	size /= new_size;
-
-	if (size > UINT32_MAX) {
-		log_error("New extent count %" PRIu64 " for %s%s exceeds "
-			  "32 bits.", size, desc1, desc2);
-		return 0;
-	}
-
-	*extents = (uint32_t) size;
-
-	return 1;
-}
-
 static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bits,
 					    uint32_t num_set_bits, unsigned *seed)
 {
@@ -1219,22 +1194,6 @@ static int _vg_adjust_ignored_mdas(struct volume_group *vg)
 	return 1;
 }
 
-uint32_t vg_mda_copies(const struct volume_group *vg)
-{
-	return vg->mda_copies;
-}
-
-int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies)
-{
-	vg->mda_copies = mda_copies;
-
-	/* FIXME Use log_verbose when this is due to specific cmdline request. */
-	log_debug("Setting mda_copies to %"PRIu32" for VG %s",
-		    mda_copies, vg->name);
-
-	return 1;
-}
-
 uint64_t find_min_mda_size(struct dm_list *mdas)
 {
 	uint64_t min_mda_size = UINT64_MAX, mda_size;
@@ -1254,285 +1213,6 @@ uint64_t find_min_mda_size(struct dm_list *mdas)
 	return min_mda_size;
 }
 
-uint64_t vg_mda_size(const struct volume_group *vg)
-{
-	return find_min_mda_size(&vg->fid->metadata_areas_in_use);
-}
-
-uint64_t vg_mda_free(const struct volume_group *vg)
-{
-	uint64_t freespace = UINT64_MAX, mda_free;
-	struct metadata_area *mda;
-
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
-		if (!mda->ops->mda_free_sectors)
-			continue;
-		mda_free = mda->ops->mda_free_sectors(mda);
-		if (mda_free < freespace)
-			freespace = mda_free;
-	}
-
-	if (freespace == UINT64_MAX)
-		freespace = UINT64_C(0);
-	return freespace;
-}
-
-int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
-{
-	uint32_t old_size = vg->extent_size;
-	struct pv_list *pvl;
-	struct lv_list *lvl;
-	struct physical_volume *pv;
-	struct logical_volume *lv;
-	struct lv_segment *seg;
-	struct pv_segment *pvseg;
-	uint32_t s;
-
-	if (!vg_is_resizeable(vg)) {
-		log_error("Volume group \"%s\" must be resizeable "
-			  "to change PE size", vg->name);
-		return 0;
-	}
-
-	if (!new_size) {
-		log_error("Physical extent size may not be zero");
-		return 0;
-	}
-
-	if (new_size == vg->extent_size)
-		return 1;
-
-	if (new_size & (new_size - 1)) {
-		log_error("Physical extent size must be a power of 2.");
-		return 0;
-	}
-
-	if (new_size > vg->extent_size) {
-		if ((uint64_t) vg_size(vg) % new_size) {
-			/* FIXME Adjust used PV sizes instead */
-			log_error("New extent size is not a perfect fit");
-			return 0;
-		}
-	}
-
-	vg->extent_size = new_size;
-
-	if (vg->fid->fmt->ops->vg_setup &&
-	    !vg->fid->fmt->ops->vg_setup(vg->fid, vg))
-		return_0;
-
-	if (!_recalc_extents(&vg->extent_count, vg->name, "", old_size,
-			     new_size))
-		return_0;
-
-	if (!_recalc_extents(&vg->free_count, vg->name, " free space",
-			     old_size, new_size))
-		return_0;
-
-	/* foreach PV */
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		pv = pvl->pv;
-
-		pv->pe_size = new_size;
-		if (!_recalc_extents(&pv->pe_count, pv_dev_name(pv), "",
-				     old_size, new_size))
-			return_0;
-
-		if (!_recalc_extents(&pv->pe_alloc_count, pv_dev_name(pv),
-				     " allocated space", old_size, new_size))
-			return_0;
-
-		/* foreach free PV Segment */
-		dm_list_iterate_items(pvseg, &pv->segments) {
-			if (pvseg_is_allocated(pvseg))
-				continue;
-
-			if (!_recalc_extents(&pvseg->pe, pv_dev_name(pv),
-					     " PV segment start", old_size,
-					     new_size))
-				return_0;
-			if (!_recalc_extents(&pvseg->len, pv_dev_name(pv),
-					     " PV segment length", old_size,
-					     new_size))
-				return_0;
-		}
-	}
-
-	/* foreach LV */
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		lv = lvl->lv;
-
-		if (!_recalc_extents(&lv->le_count, lv->name, "", old_size,
-				     new_size))
-			return_0;
-
-		dm_list_iterate_items(seg, &lv->segments) {
-			if (!_recalc_extents(&seg->le, lv->name,
-					     " segment start", old_size,
-					     new_size))
-				return_0;
-
-			if (!_recalc_extents(&seg->len, lv->name,
-					     " segment length", old_size,
-					     new_size))
-				return_0;
-
-			if (!_recalc_extents(&seg->area_len, lv->name,
-					     " area length", old_size,
-					     new_size))
-				return_0;
-
-			if (!_recalc_extents(&seg->extents_copied, lv->name,
-					     " extents moved", old_size,
-					     new_size))
-				return_0;
-
-			/* foreach area */
-			for (s = 0; s < seg->area_count; s++) {
-				switch (seg_type(seg, s)) {
-				case AREA_PV:
-					if (!_recalc_extents
-					    (&seg_pe(seg, s),
-					     lv->name,
-					     " pvseg start", old_size,
-					     new_size))
-						return_0;
-					if (!_recalc_extents
-					    (&seg_pvseg(seg, s)->len,
-					     lv->name,
-					     " pvseg length", old_size,
-					     new_size))
-						return_0;
-					break;
-				case AREA_LV:
-					if (!_recalc_extents
-					    (&seg_le(seg, s), lv->name,
-					     " area start", old_size,
-					     new_size))
-						return_0;
-					break;
-				case AREA_UNASSIGNED:
-					log_error("Unassigned area %u found in "
-						  "segment", s);
-					return 0;
-				}
-			}
-		}
-
-	}
-
-	return 1;
-}
-
-int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv)
-{
-	if (!vg_is_resizeable(vg)) {
-		log_error("Volume group \"%s\" must be resizeable "
-			  "to change MaxLogicalVolume", vg->name);
-		return 0;
-	}
-
-	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
-		if (!max_lv)
-			max_lv = 255;
-		else if (max_lv > 255) {
-			log_error("MaxLogicalVolume limit is 255");
-			return 0;
-		}
-	}
-
-	if (max_lv && max_lv < vg_visible_lvs(vg)) {
-		log_error("MaxLogicalVolume is less than the current number "
-			  "%d of LVs for %s", vg_visible_lvs(vg),
-			  vg->name);
-		return 0;
-	}
-	vg->max_lv = max_lv;
-
-	return 1;
-}
-
-int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv)
-{
-	if (!vg_is_resizeable(vg)) {
-		log_error("Volume group \"%s\" must be resizeable "
-			  "to change MaxPhysicalVolumes", vg->name);
-		return 0;
-	}
-
-	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
-		if (!max_pv)
-			max_pv = 255;
-		else if (max_pv > 255) {
-			log_error("MaxPhysicalVolume limit is 255");
-			return 0;
-		}
-	}
-
-	if (max_pv && max_pv < vg->pv_count) {
-		log_error("MaxPhysicalVolumes is less than the current number "
-			  "%d of PVs for \"%s\"", vg->pv_count,
-			  vg->name);
-		return 0;
-	}
-	vg->max_pv = max_pv;
-	return 1;
-}
-
-int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc)
-{
-	if (alloc == ALLOC_INHERIT) {
-		log_error("Volume Group allocation policy cannot inherit "
-			  "from anything");
-		return 0;
-	}
-
-	if (alloc == vg->alloc)
-		return 1;
-
-	vg->alloc = alloc;
-	return 1;
-}
-
-int vg_set_clustered(struct volume_group *vg, int clustered)
-{
-	struct lv_list *lvl;
-
-	/*
-	 * We do not currently support switching the cluster attribute
-	 * on active mirrors or snapshots.
-	 */
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lv_is_mirrored(lvl->lv) && lv_is_active(lvl->lv)) {
-			log_error("Mirror logical volumes must be inactive "
-				  "when changing the cluster attribute.");
-			return 0;
-		}
-
-		if (clustered) {
-			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
-				log_error("Volume group %s contains snapshots "
-					  "that are not yet supported.",
-					  vg->name);
-				return 0;
-			}
-		}
-
-		if ((lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) &&
-		    lv_is_active(lvl->lv)) {
-			log_error("Snapshot logical volumes must be inactive "
-				  "when changing the cluster attribute.");
-			return 0;
-		}
-	}
-
-	if (clustered)
-		vg->status |= CLUSTERED;
-	else
-		vg->status &= ~CLUSTERED;
-	return 1;
-}
-
 static int _move_mdas(struct volume_group *vg_from, struct volume_group *vg_to,
 		      struct dm_list *mdas_from, struct dm_list *mdas_to)
 {
@@ -2167,31 +1847,6 @@ int vg_remove_mdas(struct volume_group *vg)
 	return 1;
 }
 
-unsigned snapshot_count(const struct volume_group *vg)
-{
-	struct lv_list *lvl;
-	unsigned num_snapshots = 0;
-
-	dm_list_iterate_items(lvl, &vg->lvs)
-		if (lv_is_cow(lvl->lv))
-			num_snapshots++;
-
-	return num_snapshots;
-}
-
-unsigned vg_visible_lvs(const struct volume_group *vg)
-{
-	struct lv_list *lvl;
-	unsigned lv_count = 0;
-
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lv_is_visible(lvl->lv))
-			lv_count++;
-	}
-
-	return lv_count;
-}
-
 /*
  * Determine whether two vgs are compatible for merging.
  */
@@ -4471,79 +4126,6 @@ int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignored)
 	return 1;
 }
 
-uint32_t vg_seqno(const struct volume_group *vg)
-{
-	return vg->seqno;
-}
-
-uint64_t vg_status(const struct volume_group *vg)
-{
-	return vg->status;
-}
-
-uint64_t vg_size(const struct volume_group *vg)
-{
-	return (uint64_t) vg->extent_count * vg->extent_size;
-}
-
-uint64_t vg_free(const struct volume_group *vg)
-{
-	return (uint64_t) vg->free_count * vg->extent_size;
-}
-
-uint64_t vg_extent_size(const struct volume_group *vg)
-{
-	return (uint64_t) vg->extent_size;
-}
-
-uint64_t vg_extent_count(const struct volume_group *vg)
-{
-	return (uint64_t) vg->extent_count;
-}
-
-uint64_t vg_free_count(const struct volume_group *vg)
-{
-	return (uint64_t) vg->free_count;
-}
-
-uint64_t vg_pv_count(const struct volume_group *vg)
-{
-	return (uint64_t) vg->pv_count;
-}
-
-uint64_t vg_max_pv(const struct volume_group *vg)
-{
-	return (uint64_t) vg->max_pv;
-}
-
-uint64_t vg_max_lv(const struct volume_group *vg)
-{
-	return (uint64_t) vg->max_lv;
-}
-
-uint32_t vg_mda_count(const struct volume_group *vg)
-{
-	return dm_list_size(&vg->fid->metadata_areas_in_use) +
-		dm_list_size(&vg->fid->metadata_areas_ignored);
-}
-
-uint32_t vg_mda_used_count(const struct volume_group *vg)
-{
-       uint32_t used_count = 0;
-       struct metadata_area *mda;
-
-	/*
-	 * Ignored mdas could be on either list - the reason being the state
-	 * may have changed from ignored to un-ignored and we need to write
-	 * the state to disk.
-	 */
-       dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use)
-	       if (!mda_is_ignored(mda))
-		       used_count++;
-
-       return used_count;
-}
-
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index b570cee..f0f0732 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -378,11 +378,6 @@ int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segm
 struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
 
 /*
- * Count snapshot LVs.
- */
-unsigned snapshot_count(const struct volume_group *vg);
-
-/*
  * Calculate readahead from underlying PV devices
  */
 void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahead);
@@ -417,7 +412,5 @@ int vg_mark_partial_lvs(struct volume_group *vg);
 int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
-uint64_t vg_mda_size(const struct volume_group *vg);
-uint64_t vg_mda_free(const struct volume_group *vg);
 
 #endif
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
new file mode 100644
index 0000000..40270ec
--- /dev/null
+++ b/lib/metadata/vg.c
@@ -0,0 +1,436 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "metadata.h"
+#include "activate.h"
+
+uint32_t vg_seqno(const struct volume_group *vg)
+{
+	return vg->seqno;
+}
+
+uint64_t vg_status(const struct volume_group *vg)
+{
+	return vg->status;
+}
+
+uint64_t vg_size(const struct volume_group *vg)
+{
+	return (uint64_t) vg->extent_count * vg->extent_size;
+}
+
+uint64_t vg_free(const struct volume_group *vg)
+{
+	return (uint64_t) vg->free_count * vg->extent_size;
+}
+
+uint64_t vg_extent_size(const struct volume_group *vg)
+{
+	return (uint64_t) vg->extent_size;
+}
+
+uint64_t vg_extent_count(const struct volume_group *vg)
+{
+	return (uint64_t) vg->extent_count;
+}
+
+uint64_t vg_free_count(const struct volume_group *vg)
+{
+	return (uint64_t) vg->free_count;
+}
+
+uint64_t vg_pv_count(const struct volume_group *vg)
+{
+	return (uint64_t) vg->pv_count;
+}
+
+uint64_t vg_max_pv(const struct volume_group *vg)
+{
+	return (uint64_t) vg->max_pv;
+}
+
+uint64_t vg_max_lv(const struct volume_group *vg)
+{
+	return (uint64_t) vg->max_lv;
+}
+
+unsigned snapshot_count(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	unsigned num_snapshots = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_cow(lvl->lv))
+			num_snapshots++;
+
+	return num_snapshots;
+}
+
+unsigned vg_visible_lvs(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	unsigned lv_count = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lv_is_visible(lvl->lv))
+			lv_count++;
+	}
+
+	return lv_count;
+}
+
+uint32_t vg_mda_count(const struct volume_group *vg)
+{
+	return dm_list_size(&vg->fid->metadata_areas_in_use) +
+		dm_list_size(&vg->fid->metadata_areas_ignored);
+}
+
+uint32_t vg_mda_used_count(const struct volume_group *vg)
+{
+       uint32_t used_count = 0;
+       struct metadata_area *mda;
+
+	/*
+	 * Ignored mdas could be on either list - the reason being the state
+	 * may have changed from ignored to un-ignored and we need to write
+	 * the state to disk.
+	 */
+       dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use)
+	       if (!mda_is_ignored(mda))
+		       used_count++;
+
+       return used_count;
+}
+
+uint32_t vg_mda_copies(const struct volume_group *vg)
+{
+	return vg->mda_copies;
+}
+
+uint64_t vg_mda_size(const struct volume_group *vg)
+{
+	return find_min_mda_size(&vg->fid->metadata_areas_in_use);
+}
+
+uint64_t vg_mda_free(const struct volume_group *vg)
+{
+	uint64_t freespace = UINT64_MAX, mda_free;
+	struct metadata_area *mda;
+
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		if (!mda->ops->mda_free_sectors)
+			continue;
+		mda_free = mda->ops->mda_free_sectors(mda);
+		if (mda_free < freespace)
+			freespace = mda_free;
+	}
+
+	if (freespace == UINT64_MAX)
+		freespace = UINT64_C(0);
+	return freespace;
+}
+
+int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies)
+{
+	vg->mda_copies = mda_copies;
+
+	/* FIXME Use log_verbose when this is due to specific cmdline request. */
+	log_debug("Setting mda_copies to %"PRIu32" for VG %s",
+		    mda_copies, vg->name);
+
+	return 1;
+}
+
+static int _recalc_extents(uint32_t *extents, const char *desc1,
+			   const char *desc2, uint32_t old_size,
+			   uint32_t new_size)
+{
+	uint64_t size = (uint64_t) old_size * (*extents);
+
+	if (size % new_size) {
+		log_error("New size %" PRIu64 " for %s%s not an exact number "
+			  "of new extents.", size, desc1, desc2);
+		return 0;
+	}
+
+	size /= new_size;
+
+	if (size > UINT32_MAX) {
+		log_error("New extent count %" PRIu64 " for %s%s exceeds "
+			  "32 bits.", size, desc1, desc2);
+		return 0;
+	}
+
+	*extents = (uint32_t) size;
+
+	return 1;
+}
+
+int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
+{
+	uint32_t old_size = vg->extent_size;
+	struct pv_list *pvl;
+	struct lv_list *lvl;
+	struct physical_volume *pv;
+	struct logical_volume *lv;
+	struct lv_segment *seg;
+	struct pv_segment *pvseg;
+	uint32_t s;
+
+	if (!vg_is_resizeable(vg)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change PE size", vg->name);
+		return 0;
+	}
+
+	if (!new_size) {
+		log_error("Physical extent size may not be zero");
+		return 0;
+	}
+
+	if (new_size == vg->extent_size)
+		return 1;
+
+	if (new_size & (new_size - 1)) {
+		log_error("Physical extent size must be a power of 2.");
+		return 0;
+	}
+
+	if (new_size > vg->extent_size) {
+		if ((uint64_t) vg_size(vg) % new_size) {
+			/* FIXME Adjust used PV sizes instead */
+			log_error("New extent size is not a perfect fit");
+			return 0;
+		}
+	}
+
+	vg->extent_size = new_size;
+
+	if (vg->fid->fmt->ops->vg_setup &&
+	    !vg->fid->fmt->ops->vg_setup(vg->fid, vg))
+		return_0;
+
+	if (!_recalc_extents(&vg->extent_count, vg->name, "", old_size,
+			     new_size))
+		return_0;
+
+	if (!_recalc_extents(&vg->free_count, vg->name, " free space",
+			     old_size, new_size))
+		return_0;
+
+	/* foreach PV */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		pv = pvl->pv;
+
+		pv->pe_size = new_size;
+		if (!_recalc_extents(&pv->pe_count, pv_dev_name(pv), "",
+				     old_size, new_size))
+			return_0;
+
+		if (!_recalc_extents(&pv->pe_alloc_count, pv_dev_name(pv),
+				     " allocated space", old_size, new_size))
+			return_0;
+
+		/* foreach free PV Segment */
+		dm_list_iterate_items(pvseg, &pv->segments) {
+			if (pvseg_is_allocated(pvseg))
+				continue;
+
+			if (!_recalc_extents(&pvseg->pe, pv_dev_name(pv),
+					     " PV segment start", old_size,
+					     new_size))
+				return_0;
+			if (!_recalc_extents(&pvseg->len, pv_dev_name(pv),
+					     " PV segment length", old_size,
+					     new_size))
+				return_0;
+		}
+	}
+
+	/* foreach LV */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		lv = lvl->lv;
+
+		if (!_recalc_extents(&lv->le_count, lv->name, "", old_size,
+				     new_size))
+			return_0;
+
+		dm_list_iterate_items(seg, &lv->segments) {
+			if (!_recalc_extents(&seg->le, lv->name,
+					     " segment start", old_size,
+					     new_size))
+				return_0;
+
+			if (!_recalc_extents(&seg->len, lv->name,
+					     " segment length", old_size,
+					     new_size))
+				return_0;
+
+			if (!_recalc_extents(&seg->area_len, lv->name,
+					     " area length", old_size,
+					     new_size))
+				return_0;
+
+			if (!_recalc_extents(&seg->extents_copied, lv->name,
+					     " extents moved", old_size,
+					     new_size))
+				return_0;
+
+			/* foreach area */
+			for (s = 0; s < seg->area_count; s++) {
+				switch (seg_type(seg, s)) {
+				case AREA_PV:
+					if (!_recalc_extents
+					    (&seg_pe(seg, s),
+					     lv->name,
+					     " pvseg start", old_size,
+					     new_size))
+						return_0;
+					if (!_recalc_extents
+					    (&seg_pvseg(seg, s)->len,
+					     lv->name,
+					     " pvseg length", old_size,
+					     new_size))
+						return_0;
+					break;
+				case AREA_LV:
+					if (!_recalc_extents
+					    (&seg_le(seg, s), lv->name,
+					     " area start", old_size,
+					     new_size))
+						return_0;
+					break;
+				case AREA_UNASSIGNED:
+					log_error("Unassigned area %u found in "
+						  "segment", s);
+					return 0;
+				}
+			}
+		}
+
+	}
+
+	return 1;
+}
+
+int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv)
+{
+	if (!vg_is_resizeable(vg)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change MaxLogicalVolume", vg->name);
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!max_lv)
+			max_lv = 255;
+		else if (max_lv > 255) {
+			log_error("MaxLogicalVolume limit is 255");
+			return 0;
+		}
+	}
+
+	if (max_lv && max_lv < vg_visible_lvs(vg)) {
+		log_error("MaxLogicalVolume is less than the current number "
+			  "%d of LVs for %s", vg_visible_lvs(vg),
+			  vg->name);
+		return 0;
+	}
+	vg->max_lv = max_lv;
+
+	return 1;
+}
+
+int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv)
+{
+	if (!vg_is_resizeable(vg)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change MaxPhysicalVolumes", vg->name);
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!max_pv)
+			max_pv = 255;
+		else if (max_pv > 255) {
+			log_error("MaxPhysicalVolume limit is 255");
+			return 0;
+		}
+	}
+
+	if (max_pv && max_pv < vg->pv_count) {
+		log_error("MaxPhysicalVolumes is less than the current number "
+			  "%d of PVs for \"%s\"", vg->pv_count,
+			  vg->name);
+		return 0;
+	}
+	vg->max_pv = max_pv;
+	return 1;
+}
+
+int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc)
+{
+	if (alloc == ALLOC_INHERIT) {
+		log_error("Volume Group allocation policy cannot inherit "
+			  "from anything");
+		return 0;
+	}
+
+	if (alloc == vg->alloc)
+		return 1;
+
+	vg->alloc = alloc;
+	return 1;
+}
+
+int vg_set_clustered(struct volume_group *vg, int clustered)
+{
+	struct lv_list *lvl;
+
+	/*
+	 * We do not currently support switching the cluster attribute
+	 * on active mirrors or snapshots.
+	 */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lv_is_mirrored(lvl->lv) && lv_is_active(lvl->lv)) {
+			log_error("Mirror logical volumes must be inactive "
+				  "when changing the cluster attribute.");
+			return 0;
+		}
+
+		if (clustered) {
+			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
+				log_error("Volume group %s contains snapshots "
+					  "that are not yet supported.",
+					  vg->name);
+				return 0;
+			}
+		}
+
+		if ((lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) &&
+		    lv_is_active(lvl->lv)) {
+			log_error("Snapshot logical volumes must be inactive "
+				  "when changing the cluster attribute.");
+			return 0;
+		}
+	}
+
+	if (clustered)
+		vg->status |= CLUSTERED;
+	else
+		vg->status &= ~CLUSTERED;
+	return 1;
+}
+
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
new file mode 100644
index 0000000..1610087
--- /dev/null
+++ b/lib/metadata/vg.h
@@ -0,0 +1,127 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#ifndef _VG_H
+#define _VG_H
+
+struct cmd_context;
+struct dm_pool;
+struct format_instance;
+struct dm_list;
+struct id;
+
+typedef enum {
+	ALLOC_INVALID,
+	ALLOC_CONTIGUOUS,
+	ALLOC_CLING,
+	ALLOC_NORMAL,
+	ALLOC_ANYWHERE,
+	ALLOC_INHERIT
+} alloc_policy_t;
+
+struct volume_group {
+	struct cmd_context *cmd;
+	struct dm_pool *vgmem;
+	struct format_instance *fid;
+	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
+	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
+	uint32_t seqno;		/* Metadata sequence number */
+
+	alloc_policy_t alloc;
+	uint64_t status;
+
+	struct id id;
+	char *name;
+	char *old_name;		/* Set during vgrename and vgcfgrestore */
+	char *system_id;
+
+	uint32_t extent_size;
+	uint32_t extent_count;
+	uint32_t free_count;
+
+	uint32_t max_lv;
+	uint32_t max_pv;
+
+	/* physical volumes */
+	uint32_t pv_count;
+	struct dm_list pvs;
+
+	/*
+	 * logical volumes
+	 * The following relationship should always hold:
+	 * dm_list_size(lvs) = user visible lv_count + snapshot_count + other invisible LVs
+	 *
+	 * Snapshots consist of 2 instances of "struct logical_volume":
+	 * - cow (lv_name is visible to the user)
+	 * - snapshot (lv_name is 'snapshotN')
+	 *
+	 * Mirrors consist of multiple instances of "struct logical_volume":
+	 * - one for the mirror log
+	 * - one for each mirror leg
+	 * - one for the user-visible mirror LV
+	 */
+	struct dm_list lvs;
+
+	struct dm_list tags;
+
+	/*
+	 * FIXME: Move the next fields into a different struct?
+	 */
+
+	/*
+	 * List of removed physical volumes by pvreduce.
+	 * They have to get cleared on vg_commit.
+	 */
+	struct dm_list removed_pvs;
+	uint32_t open_mode; /* FIXME: read or write - check lock type? */
+
+	/*
+	 * Store result of the last vg_read().
+	 * 0 for success else appropriate FAILURE_* bits set.
+	 */
+	uint32_t read_status;
+	uint32_t mda_copies; /* target number of mdas for this VG */
+};
+
+uint32_t vg_seqno(const struct volume_group *vg);
+uint64_t vg_status(const struct volume_group *vg);
+int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc);
+int vg_set_clustered(struct volume_group *vg, int clustered);
+uint64_t vg_size(const struct volume_group *vg);
+uint64_t vg_free(const struct volume_group *vg);
+uint64_t vg_extent_size(const struct volume_group *vg);
+int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size);
+uint64_t vg_extent_count(const struct volume_group *vg);
+uint64_t vg_free_count(const struct volume_group *vg);
+uint64_t vg_pv_count(const struct volume_group *vg);
+uint64_t vg_max_pv(const struct volume_group *vg);
+int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv);
+uint64_t vg_max_lv(const struct volume_group *vg);
+int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv);
+uint32_t vg_mda_count(const struct volume_group *vg);
+uint32_t vg_mda_used_count(const struct volume_group *vg);
+uint32_t vg_mda_copies(const struct volume_group *vg);
+int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies);
+/*
+ * Returns visible LV count - number of LVs from user perspective
+ */
+unsigned vg_visible_lvs(const struct volume_group *vg);
+/*
+ * Count snapshot LVs.
+ */
+unsigned snapshot_count(const struct volume_group *vg);
+
+uint64_t vg_mda_size(const struct volume_group *vg);
+uint64_t vg_mda_free(const struct volume_group *vg);
+
+#endif
-- 
1.7.2.2



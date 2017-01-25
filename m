From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 25 Jan 2017 16:22:30 +0000 (UTC)
Subject: master - libdm: add dm_stats_update_regions_from_fd()
Message-ID: <20170125162230.169A560E3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0d19feb85ce8e143c7f107d7bf1c668d667a57c
Commit:        e0d19feb85ce8e143c7f107d7bf1c668d667a57c
Parent:        1c00bb5da3a53152c5f9e0c9d3382afdec1b2455
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 11 12:53:04 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jan 25 16:15:21 2017 +0000

libdm: add dm_stats_update_regions_from_fd()

Add a call to update the regions corresponding to a file mapped
group of regions. The regions to be updated must be grouped, to
allow us to correctly identify extents that have been deallocated
since the map was created.

Tables are built of the file extents, and the extents currently
mapped to dmstats regions: if a region no longer has a matching
file extent, it is deleted, and new regions are created for any
file extents without a matching region.

The FIEMAP call returns extents that are currently in-memory (or
journaled) and awaiting allocation in the file system. These have
the FIEMAP_EXTENT_UNKNOWN | FIEMAP_EXTENT_DELALLOC flag bits set
in the fe_flags field - these extents are skipped until they
have a known disk location.

Since it is possile for the 0th extent of the file to have been
deallocated this must also handle the possible deletion and
re-creation of the group leader: if no other region allocation
is taking place the group identifier will not change.
---
 libdm/.exported_symbols.DM_1_02_138 |    1 +
 libdm/libdevmapper.h                |   32 +++
 libdm/libdm-stats.c                 |  395 +++++++++++++++++++++++++++++++----
 3 files changed, 391 insertions(+), 37 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_138 b/libdm/.exported_symbols.DM_1_02_138
index 08f936f..3ebc59d 100644
--- a/libdm/.exported_symbols.DM_1_02_138
+++ b/libdm/.exported_symbols.DM_1_02_138
@@ -1,4 +1,5 @@
 dm_bit_get_last
 dm_bit_get_prev
+dm_stats_update_regions_from_fd
 dm_bitset_parse_list
 dm_stats_bind_from_fd
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3c96bd9..9a10252 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1335,6 +1335,38 @@ uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 					  int group, int precise,
 					  struct dm_histogram *bounds,
 					  const char *alias);
+/*
+ * Update a group of regions that correspond to the extents of a file
+ * in the filesystem, adding and removing regions to account for
+ * allocation changes in the underlying file.
+ *
+ * File descriptor fd must reference a regular file, open for reading,
+ * in a local file system that supports the FIEMAP ioctl, and that
+ * returns data describing the physical location of extents.
+ *
+ * The file descriptor can be closed by the caller following the call
+ * to dm_stats_update_regions_from_fd().
+ *
+ * On success the function returns a pointer to an array of uint64_t
+ * containing the IDs of the updated regions (including any existing
+ * regions that were not modified by the call).
+ *
+ * The region_id array is terminated by the special value
+ * DM_STATS_REGION_NOT_PRESENT and should be freed using dm_free()
+ * when no longer required.
+ *
+ * On error NULL is returned.
+ *
+ * Following a call to dm_stats_update_regions_from_fd() the handle
+ * is guaranteed to be in a listed state, and to contain any region
+ * and group identifiers created by the operation.
+ *
+ * This function cannot be used with file mapped regions that are
+ * not members of a group: either group the regions, or remove them
+ * and re-map them with dm_stats_create_regions_from_fd().
+ */
+uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
+					  uint64_t group_id);
 
 /*
  * Call this to actually run the ioctl.
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index f10c6d6..f0342a0 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3868,6 +3868,37 @@ static int _extent_start_compare(const void *p1, const void *p2)
 	return 1;
 }
 
+/*
+ * Resize the group bitmap corresponding to group_id so that it can
+ * contain at least num_regions members.
+ */
+static int _stats_resize_group(struct dm_stats_group *group, int num_regions)
+{
+	int last_bit = dm_bit_get_last(group->regions);
+	dm_bitset_t new, old;
+
+	if (last_bit >= num_regions) {
+		log_error("Cannot resize group bitmap to %d with bit %d set.",
+			  num_regions, last_bit);
+		return 0;
+	}
+
+	log_very_verbose("Resizing group bitmap from %d to %d (last_bit: %d).",
+			 group->regions[0], num_regions, last_bit);
+
+	new = dm_bitset_create(NULL, num_regions);
+	if (!new) {
+		log_error("Could not allocate memory for new group bitmap.");
+		return 0;
+	}
+
+	old = group->regions;
+	dm_bit_copy(new, old);
+	group->regions = new;
+	dm_bitset_destroy(old);
+	return 1;
+}
+
 static int _stats_create_group(struct dm_stats *dms, dm_bitset_t regions,
 			       const char *alias, uint64_t *group_id)
 {
@@ -4221,8 +4252,8 @@ bad:
 	return 0;
 }
 
-static int _stats_add_extent(struct dm_pool *mem, struct fiemap_extent *fm_ext,
-			     uint64_t id)
+static int _stats_add_file_extent(int fd, struct dm_pool *mem, uint64_t id,
+				  struct fiemap_extent *fm_ext)
 {
 	struct _extent extent;
 
@@ -4232,16 +4263,17 @@ static int _stats_add_extent(struct dm_pool *mem, struct fiemap_extent *fm_ext,
 	/* convert bytes to dm (512b) sectors */
 	extent.start = fm_ext->fe_physical >> SECTOR_SHIFT;
 	extent.len = fm_ext->fe_length >> SECTOR_SHIFT;
-
 	extent.id = id;
 
+	log_very_verbose("Extent " FMTu64 " on fd %d at " FMTu64 "+"
+			 FMTu64, extent.id, fd, extent.start, extent.len);
+
 	if (!dm_pool_grow_object(mem, &extent,
 				 sizeof(extent))) {
 		log_error("Cannot map file: failed to grow extent map.");
 		return 0;
 	}
 	return 1;
-
 }
 
 /* test for the boundary of an extent */
@@ -4258,7 +4290,7 @@ do {				\
 	*(to) = *(from);	\
 } while (0)
 
-static uint64_t _stats_map_extents(struct dm_pool *mem,
+static uint64_t _stats_map_extents(int fd, struct dm_pool *mem,
 				   struct fiemap *fiemap,
 				   struct fiemap_extent *fm_ext,
 				   struct fiemap_extent *fm_last,
@@ -4289,16 +4321,34 @@ static uint64_t _stats_map_extents(struct dm_pool *mem,
 		    & (FIEMAP_EXTENT_UNKNOWN | FIEMAP_EXTENT_DELALLOC))
 			continue;
 
-		if (ext_boundary(fm_ext[i], expected)) {
-			if (!_stats_add_extent(mem, fm_pending, nr_extents))
+		/*
+		 * Begin a new extent if the current physical address differs
+		 * from the expected address yielded by fm_last.fe_physical +
+		 * fm_last.fe_length.
+		 *
+		 * A logical discontinuity is seen at the start of the file if
+		 * unwritten space exists before the first extent: do not add
+		 * any extent record until we have accumulated a non-zero length
+		 * in fm_pending.
+		 */
+		if (fm_pending->fe_length &&
+		    ext_boundary(fm_ext[i], expected)) {
+			if (!_stats_add_file_extent(fd, mem, nr_extents,
+						    fm_pending))
 				goto_bad;
 			nr_extents++;
 			/* Begin a new pending extent. */
 			ext_copy(fm_pending, fm_ext + i);
 		} else {
 			expected = 0;
-			/* Begin a new pending extent for extent 0. */
-			if (fm_ext[i].fe_logical == 0)
+			/* Begin a new pending extent for extent 0. If there is
+			 * a hole at the start of the file, the first allocated
+			 * extent will have a non-zero fe_logical. Detect this
+			 * case by testing fm_pending->fe_length: if no length
+			 * has been accumulated we are handling the first
+			 * physical extent of the file.
+			 */
+			if (!fm_pending->fe_length || fm_ext[i].fe_logical == 0)
 				ext_copy(fm_pending, fm_ext + i);
 			else
 				/* accumulate this logical extent's length */
@@ -4311,8 +4361,8 @@ static uint64_t _stats_map_extents(struct dm_pool *mem,
 	 * If the file only has a single extent, no boundary is ever
 	 * detected to trigger addition of the first extent.
 	 */
-	if (fm_ext[i - 1].fe_logical == 0) {
-		_stats_add_extent(mem, fm_pending, nr_extents);
+	if (*eof || (fm_ext[i - 1].fe_logical == 0)) {
+		_stats_add_file_extent(fd, mem, nr_extents, fm_pending);
 		nr_extents++;
 	}
 
@@ -4344,7 +4394,6 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 	struct _extent *extents;
 	unsigned long flags = 0;
 	uint64_t *buf;
-	int rc;
 
 	buf = dm_zalloc(STATS_FIE_BUF_LEN);
 	if (!buf) {
@@ -4364,7 +4413,7 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 	if (!dm_pool_begin_object(mem, sizeof(*extents)))
 		return NULL;
 
-	flags |= FIEMAP_FLAG_SYNC;
+	flags = FIEMAP_FLAG_SYNC;
 
 	do {
 		/* start of ioctl loop - zero size and set count to bufsize */
@@ -4373,10 +4422,8 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 		fiemap->fm_extent_count = *count;
 
 		/* get count-sized chunk of extents */
-		rc = ioctl(fd, FS_IOC_FIEMAP, (unsigned long) fiemap);
-		if (rc < 0) {
-			rc = -errno;
-			if (rc == -EBADR)
+		if (ioctl(fd, FS_IOC_FIEMAP, (unsigned long) fiemap) < 0) {
+			if (errno == EBADR)
 				log_err_once("FIEMAP failed with unknown "
 					     "flags %x.", fiemap->fm_flags);
 			goto bad;
@@ -4386,8 +4433,9 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 		if (fiemap->fm_mapped_extents == 0)
 			break;
 
-		nr_extents += _stats_map_extents(mem, fiemap, fm_ext, &fm_last,
-						 &fm_pending, nr_extents, &eof);
+		nr_extents += _stats_map_extents(fd, mem, fiemap, fm_ext,
+						 &fm_last, &fm_pending,
+						 nr_extents, &eof);
 
 		/* check for extent mapping error */
 		if (eof < 0)
@@ -4415,23 +4463,140 @@ bad:
 	return NULL;
 }
 
+#define MATCH_EXTENT(e, s, l) \
+(((e).start == (s)) && ((e).len == (l)))
+
+static struct _extent *_find_extent(size_t nr_extents, struct _extent *extents,
+				    uint64_t start, uint64_t len)
+{
+	size_t i;
+	for (i = 0; i < nr_extents; i++)
+		if (MATCH_EXTENT(extents[i], start, len))
+			return extents + i;
+	return NULL;
+}
+
+/*
+ * Clean up a table of region_id values that were created during a
+ * failed dm_stats_create_regions_from_fd, or dm_stats_update_regions_from_fd
+ * operation.
+ */
+static void _stats_cleanup_region_ids(struct dm_stats *dms, uint64_t *regions,
+				      uint64_t nr_regions)
+{
+	uint64_t i;
+
+	for (i = 0; i < nr_regions; i++)
+		if (!_stats_delete_region(dms, regions[i]))
+			log_error("Could not delete region " FMTu64 ".", i);
+}
+
+/*
+ * First update pass: prune no-longer-allocated extents from the group
+ * and build a table of the remaining extents so that their creation
+ * can be skipped in the second pass.
+ */
+static int _stats_unmap_regions(struct dm_stats *dms, uint64_t group_id,
+				struct dm_pool *mem, struct _extent *extents,
+				struct _extent **old_extents, uint64_t *count,
+				int *regroup)
+{
+	struct dm_stats_region *region = NULL;
+	struct dm_stats_group *group = NULL;
+	int64_t nr_kept, nr_old, i;
+	struct _extent ext;
+
+	group = &dms->groups[group_id];
+
+	log_very_verbose("Checking for changed file extents in group ID "
+			 FMTu64, group_id);
+
+	if (!dm_pool_begin_object(mem, sizeof(**old_extents))) {
+		log_error("Could not allocate extent table.");
+		return 0;
+	}
+
+	nr_kept = nr_old = 0; /* counts of old and retained extents */
+
+	/*
+	 * First pass: delete de-allocated extents and set regroup=1 if
+	 * deleting the current group leader.
+	 */
+	i = dm_bit_get_last(group->regions);
+	for (; i >= 0; i = dm_bit_get_prev(group->regions, i)) {
+		region = &dms->regions[i];
+		nr_old++;
+
+		if (_find_extent(*count, extents,
+				  region->start, region->len)) {
+			ext.start = region->start;
+			ext.len = region->len;
+			ext.id = i;
+			nr_kept++;
+
+			dm_pool_grow_object(mem, &ext,
+					    sizeof(ext));
+			log_very_verbose("Kept region " FMTu64, i);
+		} else {
+
+			if (i == group_id)
+				*regroup = 1;
+
+			if (!_stats_delete_region(dms, i)) {
+				log_error("Could not remove region ID " FMTu64,
+					  i);
+				goto out;
+			}
+
+			log_very_verbose("Deleted region " FMTu64, i);
+		}
+	}
+
+	*old_extents = dm_pool_end_object(mem);
+	if (!*old_extents) {
+		log_error("Could not finalize region extent table.");
+		goto out;
+	}
+	log_very_verbose("Kept %ld of %ld old extents",
+			 nr_kept, nr_old);
+	log_very_verbose("Found " FMTu64 " new extents",
+			 *count - nr_kept);
+
+	return nr_kept;
+out:
+	dm_pool_abandon_object(mem);
+	return -1;
+}
+
 /*
- * Create a set of regions representing the extents of a file and
- * return a table of uint64_t region_id values. The number of regions
+ * Create or update a set of regions representing the extents of a file
+ * and return a table of uint64_t region_id values. The number of regions
  * created is returned in the memory pointed to by count (which must be
  * non-NULL).
+ *
+ * If group_id is not equal to DM_STATS_GROUP_NOT_PRESENT, it is assumed
+ * that group_id corresponds to a group containing existing regions that
+ * were mapped to this file at an earlier time: regions will be added or
+ * removed to reflect the current status of the file.
  */
-static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
-					    struct dm_histogram *bounds,
-					    int precise, uint64_t *count)
+static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
+					 struct dm_histogram *bounds,
+					 int precise, uint64_t group_id,
+					 uint64_t *count, int *regroup)
 {
-	uint64_t *regions = NULL, i, fail_region;
+	struct _extent *extents = NULL, *old_extents;
+	uint64_t *regions = NULL, fail_region;
+	struct dm_stats_group *group = NULL;
 	struct dm_pool *extent_mem = NULL;
-	struct _extent *extents = NULL;
+	struct _extent *old_ext;
 	char *hist_arg = NULL;
+	int update, num_bits;
 	struct statfs fsbuf;
+	int64_t nr_kept, i;
 	struct stat buf;
 
+	update = _stats_group_id_present(dms, group_id);
+
 #ifdef BTRFS_SUPER_MAGIC
 	if (fstatfs(fd, &fsbuf)) {
 		log_error("fstatfs failed for fd %d", fd);
@@ -4460,6 +4625,18 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 		return 0;
 	}
 
+	/*
+	 * If regroup is set here, we are creating a new filemap: otherwise
+	 * we are updating a group with a valid group identifier in group_id.
+	 */
+	if (update)
+		log_very_verbose("Updating extents from fd %d with group ID "
+				 FMTu64 " on (%d:%d)", fd, group_id,
+				 major(buf.st_dev), minor(buf.st_dev));
+	else
+		log_very_verbose("Mapping extents from fd %d on (%d:%d)",
+				 fd, major(buf.st_dev), minor(buf.st_dev));
+
 	/* Use a temporary, private pool for the extent table. This avoids
          * hijacking the dms->mem (region table) pool which would lead to
          * interleaving temporary allocations with dm_stats_list() data,
@@ -4473,19 +4650,41 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 		return_0;
 	}
 
-        if (bounds) {
-                /* _build_histogram_arg enables precise if vals < 1ms. */
+	if (update) {
+		group = &dms->groups[group_id];
+		if ((nr_kept = _stats_unmap_regions(dms, group_id, extent_mem,
+						     extents, &old_extents,
+						     count, regroup)) < 0)
+			goto_out;
+	}
+
+        if (bounds)
                 if (!(hist_arg = _build_histogram_arg(bounds, &precise)))
                         goto_out;
-        }
 
 	/* make space for end-of-table marker */
 	if (!(regions = dm_malloc((1 + *count) * sizeof(*regions)))) {
 		log_error("Could not allocate memory for region IDs.");
-		goto out;
+		goto_out;
 	}
 
+	/*
+	 * Second pass (first for non-update case): create regions for
+	 * all extents not retained from the prior mapping, and insert
+	 * retained regions into the table of region_id values.
+	 *
+	 * If a regroup is not scheduled, set group bits for newly
+	 * created regions in the group leader bitmap.
+	 */
 	for (i = 0; i < *count; i++) {
+		if (update) {
+			if ((old_ext = _find_extent(nr_kept, old_extents,
+						       extents[i].start,
+						       extents[i].len))) {
+				regions[i] = old_ext->id;
+				continue;
+			}
+		}
 		if (!_stats_create_region(dms, regions + i, extents[i].start,
 					  extents[i].len, -1, precise, hist_arg,
 					  dms->program_id, "")) {
@@ -4494,13 +4693,39 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 				  extents[i].start);
 			goto out_remove;
 		}
+
+		log_very_verbose("Created new region mapping " FMTu64 "+" FMTu64
+				 " with region ID " FMTu64, extents[i].start,
+				 extents[i].len, regions[i]);
+
+		if (!*regroup && update) {
+			/* expand group bitmap */
+			if (regions[i] > (group->regions[0] - 1)) {
+				num_bits = regions[i] + *count;
+				if (!_stats_resize_group(group, num_bits)) {
+					log_error("Failed to resize group "
+						  "bitmap.");
+					goto out_remove;
+				}
+			}
+			dm_bit_set(group->regions, regions[i]);
+		}
+
 	}
 	regions[*count] = DM_STATS_REGION_NOT_PRESENT;
 
+	/* Update group leader aux_data for new group members. */
+	if (!*regroup && update)
+		if (!_stats_set_aux(dms, group_id,
+				    dms->regions[group_id].aux_data))
+			log_error("Failed to update group aux_data.");
+
 	if (bounds)
 		dm_free(hist_arg);
+
 	dm_pool_free(extent_mem, extents);
 	dm_pool_destroy(extent_mem);
+	dm_free(hist_arg);
 	return regions;
 
 out_remove:
@@ -4514,13 +4739,15 @@ out_remove:
 	dm_stats_list(dms, NULL);
 
 	fail_region = i;
-	for (i = 0; i < fail_region; i++)
-		if (!_stats_delete_region(dms, regions[i]))
-			log_error("Could not delete region " FMTu64 ".", i);
-
+	_stats_cleanup_region_ids(dms, regions, fail_region);
 	*count = 0;
 
 out:
+	/*
+	 * The table of file extents in 'extents' is always built, so free
+	 * it explicitly: this will also free any 'old_extents' table that
+	 * was later allocated from the 'extent_mem' pool by this function.
+	 */
 	dm_pool_free(extent_mem, extents);
 	dm_pool_destroy(extent_mem);
 	dm_free(hist_arg);
@@ -4534,15 +4761,16 @@ uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 					  const char *alias)
 {
 	uint64_t *regions, count = 0;
+	int regroup = 1;
 
 	if (alias && !group) {
 		log_error("Cannot set alias without grouping regions.");
 		return NULL;
 	}
 
-	regions = _stats_create_file_regions(dms, fd, bounds, precise, &count);
-	if (!regions)
-		return_0;
+	if (!(regions = _stats_map_file_regions(dms, fd, bounds, precise,
+						-1, &count, &regroup)))
+		return NULL;
 
 	if (!group)
 		return regions;
@@ -4556,11 +4784,97 @@ uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 
 	return regions;
 out:
+	_stats_cleanup_region_ids(dms, regions, count);
 	dm_free(regions);
 	return NULL;
 }
 
+uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
+					  uint64_t group_id)
+{
+	struct dm_histogram *bounds = NULL;
+	int nr_bins, precise, regroup;
+	uint64_t *regions, count = 0;
+	const char *alias = NULL;
+
+	if (!dms->regions || !dm_stats_group_present(dms, group_id)) {
+		if (!dm_stats_list(dms, dms->program_id)) {
+			log_error("Could not obtain region list while "
+				  "updating group " FMTu64 ".", group_id);
+			return NULL;
+		}
+	}
+
+	if (!dm_stats_group_present(dms, group_id)) {
+		log_error("Group ID " FMTu64 " does not exist.", group_id);
+		return NULL;
+	}
+
+	/*
+	 * If the extent corresponding to the group leader's region has been
+	 * deallocated, _stats_map_file_regions() will remove the region and
+	 * the group. In this case, regroup will be set by the call and the
+	 * group will be re-created using saved values.
+	 */
+	regroup = 0;
+
+	/*
+	 * A copy of the alias is needed to re-create the group when regroup=1.
+	 */
+	if (dms->groups[group_id].alias) {
+		alias = dm_strdup(dms->groups[group_id].alias);
+		if (!alias) {
+			log_error("Failed to allocate group alias string.");
+			return NULL;
+		}
+	}
+
+	if (dms->regions[group_id].bounds) {
+		/*
+		 * A copy of the histogram bounds must be passed to
+		 * _stats_map_file_regions() to be used when creating new
+		 * regions: it is not safe to use the copy in the current group
+		 * leader since it may be destroyed during the first group
+		 * update pass.
+		 */
+		nr_bins = dms->regions[group_id].bounds->nr_bins;
+		bounds = _alloc_dm_histogram(nr_bins);
+		if (!bounds) {
+			log_error("Could not allocate memory for group "
+				  "histogram bounds.");
+			return NULL;
+		}
+		_stats_copy_histogram_bounds(bounds,
+					     dms->regions[group_id].bounds);
+	}
+
+	precise = (dms->regions[group_id].timescale == 1);
+
+	regions = _stats_map_file_regions(dms, fd, bounds, precise,
+					  group_id, &count, &regroup);
+
+	if (!regions)
+		goto bad;
+
+	if (!dm_stats_list(dms, NULL))
+		goto bad;
+
+	if (regroup)
+		if (!_stats_group_file_regions(dms, regions, count, alias))
+			goto bad;
+
+	dm_free(bounds);
+	dm_free((char *) alias);
+	return regions;
+bad:
+	_stats_cleanup_region_ids(dms, regions, count);
+	dm_free(bounds);
+	dm_free((char *) alias);
+	return NULL;
+}
+
 #else /* HAVE_LINUX_FIEMAP */
+
 uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 					  int group, int precise,
 					  struct dm_histogram *bounds,
@@ -4569,6 +4883,13 @@ uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 	log_error("File mapping requires FIEMAP ioctl support.");
 	return 0;
 }
+
+uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
+					  uint64_t group_id)
+{
+	log_error("File mapping requires FIEMAP ioctl support.");
+	return 0;
+}
 #endif /* HAVE_LINUX_FIEMAP */
 
 /*



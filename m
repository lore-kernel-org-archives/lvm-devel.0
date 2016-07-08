From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:26:42 +0000 (UTC)
Subject: master - libdm: add dm_stats_create_regions_from_fd()
Message-ID: <20160708182642.B513860E46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1048259165b09a35c45170cefbbccb4d43a9834
Commit:        e1048259165b09a35c45170cefbbccb4d43a9834
Parent:        12ecd95965321af194c3d446c0b5205d90994522
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jun 30 21:46:43 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 14:34:41 2016 +0100

libdm: add dm_stats_create_regions_from_fd()

Add a call to create dmstats regions that correspond to the extents
present in a file descriptor open on a file in a local file system.
The file must reside on a file system type that correctly supports
physical extent location data in the FIEMAP ioctl.

Regions are optionally placed into a group with a user-defined alias.

File systems that do not support physical offsets in FIEMAP (btrfs
currently) are detected via fstatfs() - although attempting to map
a --filemap group on btrfs will fail anyway with the generic error
"Not on a device-mapper device" this is confusing; the file system
mount is on a device-mapper device, but btrfs' volume layer masks
this in the returned st_dev field since the returned logical file
extents may span multiple physical devices.
---
 libdm/.exported_symbols.DM_1_02_131 |    1 +
 libdm/libdevmapper.h                |   29 ++++
 libdm/libdm-stats.c                 |  302 ++++++++++++++++++++++++++++++++++-
 3 files changed, 331 insertions(+), 1 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_131 b/libdm/.exported_symbols.DM_1_02_131
new file mode 100644
index 0000000..f766652
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_131
@@ -0,0 +1 @@
+dm_stats_create_regions_from_fd
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ec64426..0f61f9c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1286,6 +1286,35 @@ int dm_stats_get_group_descriptor(const struct dm_stats *dms,
 				  uint64_t group_id, char **buf);
 
 /*
+ * Create regions that correspond to the extents of a file in the
+ * filesystem and optionally place them into a group.
+ *
+ * File descriptor fd must reference a regular file, open for reading,
+ * in a local file system that supports the FIEMAP ioctl and that
+ * returns data describing the physical location of extents.
+ *
+ * The file descriptor can be closed by the caller following the call
+ * to dm_stats_create_regions_from_fd().
+ *
+ * The function returns a pointer to an array of uint64_t containing
+ * the IDs of the newly created regions. The array is terminated by the
+ * value DM_STATS_REGIONS_ALL and should be freed using dm_free() when
+ * no longer required.
+ *
+ * Unless nogroup is non-zero the regions will be placed into a group
+ * and the group alias is set to the value supplied.
+ *
+ * The group_id for the new group is equal to the region_id value in
+ * the first array element.
+ *
+ * File mapped histograms will be supported in a future version.
+ */
+uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
+					  int group, int precise,
+					  struct dm_histogram *bounds,
+					  const char *alias);
+
+/*
  * Call this to actually run the ioctl.
  */
 int dm_task_run(struct dm_task *dmt);
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 46495c3..2393edd 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1,5 +1,8 @@
 /*
- * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+ *
+ * _stats_get_extents_for_file() based in part on filefrag_fiemap() from
+ * e2fsprogs/misc/filefrag.c. Copyright 2003 by Theodore Ts'o.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -16,6 +19,12 @@
 
 #include "math.h" /* log10() */
 
+#include <sys/ioctl.h>
+#include <sys/vfs.h> /* fstatfs */
+#include <linux/fs.h> /* FS_IOC_FIEMAP */
+#include <linux/fiemap.h> /* fiemap */
+#include <linux/magic.h> /* BTRFS_SUPER_MAGIC */
+
 #define DM_STATS_REGION_NOT_PRESENT UINT64_MAX
 #define DM_STATS_GROUP_NOT_PRESENT DM_STATS_GROUP_NONE
 
@@ -3887,6 +3896,297 @@ int dm_stats_get_group_descriptor(const struct dm_stats *dms,
 }
 
 /*
+ * Group a table of region_ids corresponding to the extents of a file.
+ */
+static int _stats_group_file_regions(struct dm_stats *dms, uint64_t *region_ids,
+				     uint64_t count, const char *alias)
+{
+	dm_bitset_t regions = dm_bitset_create(NULL, dms->nr_regions);
+	uint64_t i, group_id = DM_STATS_GROUP_NOT_PRESENT;
+	char *members = NULL;
+	int buflen;
+
+	if (!regions) {
+		log_error("Cannot map file: failed to allocate group bitmap.");
+		return 0;
+	}
+
+	for (i = 0; i < count; i++)
+		dm_bit_set(regions, region_ids[i]);
+
+	buflen = _stats_group_tag_len(dms, regions);
+	members = dm_malloc(buflen);
+
+	if (!members) {
+		log_error("Cannot map file: failed to allocate group "
+			  "descriptor.");
+		dm_bitset_destroy(regions);
+		return 0;
+	}
+
+	if (!_stats_group_tag_fill(dms, regions, members, buflen))
+		goto bad;
+
+	/*
+	 * overlaps should not be possible: overlapping file extents
+	 * returned by FIEMAP imply a kernel bug or a corrupt fs.
+	 */
+	if (!_stats_group_check_overlap(dms, regions, count))
+		log_info("Creating group with overlapping regions.");
+
+	if (!_stats_create_group(dms, regions, alias, &group_id))
+		goto bad;
+
+	dm_free(members);
+	return 1;
+bad:
+	dm_bitset_destroy(regions);
+	dm_free(members);
+	return 0;
+}
+
+static int _stats_add_extent(struct dm_pool *mem, struct fiemap_extent *fm_ext,
+			     uint64_t id)
+{
+	struct _extent extent;
+
+	/* final address of list is unknown */
+	memset(&extent.list, 0, sizeof(extent.list));
+
+	/* convert bytes to dm (512b) sectors */
+	extent.start = fm_ext->fe_physical >> 9;
+	extent.len = fm_ext->fe_length >> 9;
+
+	extent.id = id;
+
+	if (!dm_pool_grow_object(mem, &extent,
+				 sizeof(extent))) {
+		log_error("Cannot map file: failed to grow extent map.");
+		return 0;
+	}
+	return 1;
+
+}
+
+/*
+ * Read the extents of an open file descriptor into a table of struct _extent.
+ *
+ * Based on e2fsprogs/misc/filefrag.c::filefrag_fiemap().
+ *
+ * Copyright 2003 by Theodore Ts'o.
+ *
+ */
+static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
+						   uint64_t *count)
+{
+	uint64_t buf[2048];
+	struct fiemap *fiemap = (struct fiemap *)buf;
+	struct fiemap_extent *fm_ext = &fiemap->fm_extents[0];
+	struct fiemap_extent fm_last = {0};
+	struct _extent *extents;
+	unsigned long long expected = 0;
+	unsigned long long expected_dense = 0;
+	unsigned long flags = 0;
+	unsigned int i, num = 0;
+	int tot_extents = 0, n = 0;
+	int last = 0;
+	int rc;
+
+	memset(buf, 0, sizeof(buf));
+
+	/* space available per ioctl */
+	*count = (sizeof(buf) - sizeof(*fiemap))
+		  / sizeof(struct fiemap_extent);
+
+	/* grow temporary extent table in the pool */
+	if (!dm_pool_begin_object(mem, sizeof(*extents)))
+		return NULL;
+
+	flags |= FIEMAP_FLAG_SYNC;
+
+	do {
+		/* start of ioctl loop - zero size and set count to bufsize */
+		fiemap->fm_length = ~0ULL;
+		fiemap->fm_flags = flags;
+		fiemap->fm_extent_count = *count;
+
+		/* get count-sized chunk of extents */
+		rc = ioctl(fd, FS_IOC_FIEMAP, (unsigned long) fiemap);
+		if (rc < 0) {
+			rc = -errno;
+			if (rc == -EBADR)
+				log_err_once("FIEMAP failed with unknown "
+					     "flags %x.", fiemap->fm_flags);
+			goto bad;
+		}
+
+		/* If 0 extents are returned, then more ioctls are not needed */
+		if (fiemap->fm_mapped_extents == 0)
+			break;
+
+		for (i = 0; i < fiemap->fm_mapped_extents; i++) {
+			expected_dense = fm_last.fe_physical +
+					 fm_last.fe_length;
+			expected = fm_last.fe_physical +
+				   fm_ext[i].fe_logical - fm_last.fe_logical;
+			if ((fm_ext[i].fe_logical != 0)
+			    && (fm_ext[i].fe_physical != expected)
+			    && (fm_ext[i].fe_physical != expected_dense)) {
+				tot_extents++;
+				if (!_stats_add_extent(mem, fm_ext + i,
+						       tot_extents - 1))
+					goto bad;
+			} else {
+				expected = 0;
+				if (!tot_extents)
+					tot_extents = 1;
+				if (fm_ext[i].fe_logical == 0)
+					if (!_stats_add_extent(mem, fm_ext + i,
+							       tot_extents - 1))
+						goto bad;
+			}
+			num += tot_extents;
+			if (fm_ext[i].fe_flags & FIEMAP_EXTENT_LAST)
+				last = 1;
+			fm_last = fm_ext[i];
+			n++;
+		}
+
+		fiemap->fm_start = (fm_ext[i - 1].fe_logical +
+				    fm_ext[i - 1].fe_length);
+	} while (last == 0);
+
+	if (!tot_extents) {
+		log_error("Cannot map file: no allocated extents.");
+		goto bad;
+	}
+
+	/* return total number of extents */
+	*count = tot_extents;
+	return dm_pool_end_object(mem);
+bad:
+	dm_pool_abandon_object(mem);
+	return NULL;
+}
+
+/*
+ * Create a set of regions representing the extents of a file and
+ * return a table of uint64_t region_id values. The number of regions
+ * created is returned in the memory pointed to by count (which must be
+ * non-NULL).
+ */
+static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
+					    struct dm_histogram *bounds,
+					    int precise, uint64_t *count)
+{
+	struct _extent *extents = NULL;
+	uint64_t *regions = NULL, i;
+	struct statfs fsbuf;
+	struct stat buf;
+
+	if (fstatfs(fd, &fsbuf)) {
+		log_error("fstatfs failed for fd %d", fd);
+		return 0;
+	}
+
+	if (fsbuf.f_type == BTRFS_SUPER_MAGIC) {
+		log_error("Cannot map file: btrfs does not provide "
+			  "physical FIEMAP extent data.");
+		return 0;
+	}
+
+	if (fstat(fd, &buf)) {
+		log_error("fstat failed for fd %d", fd);
+		return 0;
+	}
+
+	if (!(buf.st_mode & S_IFREG)) {
+		log_error("Not a regular file");
+		return 0;
+	}
+
+	if (!dm_is_dm_major(major(buf.st_dev))) {
+		log_error("Cannot map file: not a device-mapper device.");
+		return 0;
+	}
+
+	if (!(extents = _stats_get_extents_for_file(dms->mem, fd, count)))
+		return_0;
+
+	/* make space for end-of-table marker */
+	if (!(regions = dm_malloc((1 + *count) * sizeof(*regions)))) {
+		log_error("Could not allocate memory for region IDs.");
+		goto out;
+	}
+
+	for (i = 0; i < *count; i++) {
+		if (!_stats_create_region(dms, regions + i,
+					  extents[i].start, extents[i].len, -1,
+					  precise, NULL, dms->program_id, "")) {
+			log_error("Failed to create region " FMTu64 " of "
+				  FMTu64 " at " FMTu64 ".", i, *count,
+				  extents[i].start);
+			goto out_remove;
+		}
+	}
+	regions[*count] = DM_STATS_REGION_NOT_PRESENT;
+
+	dm_pool_free(dms->mem, extents);
+	return regions;
+
+out_remove:
+	/* clean up regions after create failure */
+	for (--i; i != DM_STATS_REGION_NOT_PRESENT; i--) {
+		if (!dm_stats_delete_region(dms, i))
+			log_error("Could not delete region " FMTu64 ".", i);
+	}
+
+out:
+	dm_pool_free(dms->mem, extents);
+	dm_free(regions);
+	return NULL;
+}
+
+
+uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
+					  int group, int precise,
+					  struct dm_histogram *bounds,
+					  const char *alias)
+{
+	uint64_t *regions, count = 0;
+
+	if (bounds) {
+		log_error("File mapped groups with histograms are not "
+			  "yet supported.");
+		return NULL;
+	}
+
+	if (alias && !group) {
+		log_error("Cannot set alias without grouping regions.");
+		return NULL;
+	}
+
+	regions = _stats_create_file_regions(dms, fd, bounds, precise, &count);
+	if (!regions)
+		return_0;
+
+	if (!group)
+		return regions;
+
+	/* refresh handle */
+	if (!dm_stats_list(dms, NULL))
+		goto_out;
+
+	if (!_stats_group_file_regions(dms, regions, count, alias))
+		goto_out;
+
+	return regions;
+out:
+	dm_free(regions);
+	return NULL;
+}
+
+/*
  * Backward compatible dm_stats_create_region() implementations.
  *
  * Keep these at the end of the file to avoid adding clutter around the



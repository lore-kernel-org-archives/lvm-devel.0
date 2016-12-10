From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat, 10 Dec 2016 12:22:13 +0000 (UTC)
Subject: master - libdm: fix performance of failed filemap cleanup
Message-ID: <20161210122213.9B7F560CE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d1dbb9eddd9dbc3aedf4572926178e532899995
Commit:        2d1dbb9eddd9dbc3aedf4572926178e532899995
Parent:        97c4490cc53157adde6da84933524f22149f449f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Dec 9 23:59:51 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Dec 10 11:59:16 2016 +0000

libdm: fix performance of failed filemap cleanup

While cleaning up the table of already created regions during a
failed dm_stats_create_regions_from_fd(), list the handle once,
and call _stats_delete_region() directly. This avoids sending a
@stats_list message for each region deleted, reducing runtime
from 6s to 0.7s when cleaning up ~250 out of ~10000 regions:

  # time dmstats create --filemap b.img
  device-mapper: message ioctl on (253:0) failed: Cannot allocate memory
  Failed to create region 246 of 309 at 9388032.
  Could not create regions from file /root/b.img
  << pauses here >>
  Command failed

  real	0m6.267s
  user	0m3.770s
  sys	0m2.487s

  # time dmstats create --filemap b.img
  device-mapper: message ioctl on (253:0) failed: Cannot allocate memory
  Failed to create region 246 of 309 at 9388032.
  Could not create regions from file /root/b.img
  Command failed

  real	0m0.716s
  user	0m0.034s
  sys	0m0.581s

Testing the error path requires region creation to start to
fail part way through the operation (in order to have regions
to clean up): the simplest way is to ensure the system is
close to the kernel limit of 1/4 RAM or 1/2 vmalloc space
consumed by dmstats data.
---
 libdm/libdevmapper.h |   21 +++++++++++++--------
 libdm/libdm-stats.c  |   20 +++++++++++++++-----
 2 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 09e3fcc..fe2e410 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1297,24 +1297,29 @@ int dm_stats_get_group_descriptor(const struct dm_stats *dms,
  * filesystem and optionally place them into a group.
  *
  * File descriptor fd must reference a regular file, open for reading,
- * in a local file system that supports the FIEMAP ioctl and that
+ * in a local file system that supports the FIEMAP ioctl, and that
  * returns data describing the physical location of extents.
  *
  * The file descriptor can be closed by the caller following the call
  * to dm_stats_create_regions_from_fd().
  *
- * The function returns a pointer to an array of uint64_t containing
- * the IDs of the newly created regions. The array is terminated by the
- * value DM_STATS_REGIONS_ALL and should be freed using dm_free() when
- * no longer required.
- *
  * Unless nogroup is non-zero the regions will be placed into a group
- * and the group alias is set to the value supplied.
+ * and the group alias set to the value supplied (if alias is NULL no
+ * group alias will be assigned).
+ *
+ * On success the function returns a pointer to an array of uint64_t
+ * containing the IDs of the newly created regions. The region_id
+ * array is terminated by the value DM_STATS_REGION_NOT_PRESENT and
+ * should be freed using dm_free() when no longer required. On error
+ * NULL is returned.
+ *
+ * Following a call to dm_stats_create_regions_from_fd() the handle
+ * is guaranteed to be in a listed state, and to contain any region
+ * and group identifiers created by the operation.
  *
  * The group_id for the new group is equal to the region_id value in
  * the first array element.
  *
- * File mapped histograms will be supported in a future version.
  */
 uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 					  int group, int precise,
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 1cabd9a..34870e3 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4323,8 +4323,8 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 					    struct dm_histogram *bounds,
 					    int precise, uint64_t *count)
 {
+	uint64_t *regions = NULL, i, max_region;
 	struct _extent *extents = NULL;
-	uint64_t *regions = NULL, i;
 	char *hist_arg = NULL;
 	struct statfs fsbuf;
 	struct stat buf;
@@ -4390,11 +4390,22 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 	return regions;
 
 out_remove:
-	/* clean up regions after create failure */
-	for (--i; i != DM_STATS_REGION_NOT_PRESENT; i--)
-		if (!dm_stats_delete_region(dms, regions[i]))
+	/* New region creation may begin to fail part-way through creating
+	 * a set of file mapped regions: in this case we need to roll back
+	 * the regions that were already created and return the handle to
+	 * a consistent state. A listed handle is required for this: use a
+	 * single list operation and call _stats_delete_region() directly
+	 * to avoid a @stats_list ioctl and list parsing for each region.
+	 */
+	dm_stats_list(dms, NULL);
+
+	max_region = i;
+	for (i = max_region - 1; i < max_region; i++)
+		if (!_stats_delete_region(dms, regions[i]))
 			log_error("Could not delete region " FMTu64 ".", i);
 
+	*count = 0;
+
 out:
 	dm_pool_free(dms->mem, extents);
 	dm_free(hist_arg);
@@ -4402,7 +4413,6 @@ out:
 	return NULL;
 }
 
-
 uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 					  int group, int precise,
 					  struct dm_histogram *bounds,



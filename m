From: Bryn Reeves <bmr@sourceware.org>
Date: Tue, 13 Jun 2017 14:47:47 -0400
Subject: master - libdm: allow truncated files in dm_stats_update_regions_from_fd()
Message-ID: <201706131847.v5DIllcB028898@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=744f2920dbb03c391a2d4981ed6c93af85121e7e
Commit:        744f2920dbb03c391a2d4981ed6c93af85121e7e
Parent:        37cd8f9678c92281e2f832dff01dc888e0ce608c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jun 7 19:21:10 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jun 13 19:45:50 2017 +0100

libdm: allow truncated files in dm_stats_update_regions_from_fd()

It's not an error to attempt to update regions from an fd that has
been truncated (or otherwise no longer has any allocated extents):
in this case, the call should remove all regions corresponding to
the group, and return an empty region table.
---
 WHATS_NEW_DM        |    1 +
 libdm/libdm-stats.c |   24 ++++++++++++------------
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2894d62..5718ab7 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.141 - 
 ===============================
+  Accept truncated files in calls to dm_stats_update_regions_from_fd().
   Restore Warning by 5% increment when thin-pool is over 80% (1.02.138).
 
 Version 1.02.140 - 3rd May 2017
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 6ce6c57..b0c9e4b 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4466,6 +4466,7 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 	return extents;
 
 bad:
+	*count = 0;
 	dm_pool_abandon_object(mem);
 	dm_free(buf);
 	return NULL;
@@ -4536,7 +4537,7 @@ static int _stats_unmap_regions(struct dm_stats *dms, uint64_t group_id,
 		region = &dms->regions[i];
 		nr_old++;
 
-		if (_find_extent(*count, extents,
+		if (extents && _find_extent(*count, extents,
 				  region->start, region->len)) {
 			ext.start = region->start;
 			ext.len = region->len;
@@ -4653,11 +4654,12 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
          * causing complications in the error path.
          */
 	if (!(extent_mem = dm_pool_create("extents", sizeof(*extents))))
-		return_0;
+		return_NULL;
 
 	if (!(extents = _stats_get_extents_for_file(extent_mem, fd, count))) {
-		dm_pool_destroy(extent_mem);
-		return_0;
+		log_very_verbose("No extents found in fd %d", fd);
+		if (!update)
+			goto out;
 	}
 
 	if (update) {
@@ -4734,7 +4736,10 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
 	if (bounds)
 		dm_free(hist_arg);
 
-	dm_pool_free(extent_mem, extents);
+	/* the extent table will be empty if the file has been truncated. */
+	if (extents)
+		dm_pool_free(extent_mem, extents);
+
 	dm_pool_destroy(extent_mem);
 
 	return regions;
@@ -4755,12 +4760,6 @@ out_remove:
 	*count = 0;
 
 out:
-	/*
-	 * The table of file extents in 'extents' is always built, so free
-	 * it explicitly: this will also free any 'old_extents' table that
-	 * was later allocated from the 'extent_mem' pool by this function.
-	 */
-	dm_pool_free(extent_mem, extents);
 	dm_pool_destroy(extent_mem);
 	dm_free(hist_arg);
 	dm_free(regions);
@@ -4872,7 +4871,8 @@ uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
 	if (!dm_stats_list(dms, NULL))
 		goto bad;
 
-	if (regroup)
+	/* regroup if there are regions to group */
+	if (regroup && (*regions != DM_STATS_REGION_NOT_PRESENT))
 		if (!_stats_group_file_regions(dms, regions, count, alias))
 			goto bad;
 



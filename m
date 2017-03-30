From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:04:37 -0400
Subject: master - libdm: use uint64_t where possible in filemap routines
Message-ID: <201703300904.v2U94bXS019995@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c7e4b97abc86da766d8465ff6c9bbc6b77766bba
Commit:        c7e4b97abc86da766d8465ff6c9bbc6b77766bba
Parent:        b823646aced03e49eb7f42aa9872d7e31f3fa1a4
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 20:49:03 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 10:02:54 2017 +0100

libdm: use uint64_t where possible in filemap routines

Use uint64_t where possible and explicit casts elsewhere to avoid
compiler warnings when converting between int, int64_t and
uint64_t.
---
 libdm/libdm-stats.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 2a6c343..b69302f 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4511,8 +4511,9 @@ static int _stats_unmap_regions(struct dm_stats *dms, uint64_t group_id,
 {
 	struct dm_stats_region *region = NULL;
 	struct dm_stats_group *group = NULL;
-	int64_t nr_kept, nr_old, i;
+	uint64_t nr_kept, nr_old;
 	struct _extent ext;
+	int64_t i;
 
 	group = &dms->groups[group_id];
 
@@ -4571,7 +4572,7 @@ static int _stats_unmap_regions(struct dm_stats *dms, uint64_t group_id,
 	log_very_verbose("Found " FMTu64 " new extents",
 			 *count - nr_kept);
 
-	return nr_kept;
+	return (int) nr_kept;
 out:
 	dm_pool_abandon_object(mem);
 	return -1;
@@ -4594,15 +4595,15 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
 					 uint64_t *count, int *regroup)
 {
 	struct _extent *extents = NULL, *old_extents = NULL;
-	uint64_t *regions = NULL, fail_region;
+	uint64_t *regions = NULL, fail_region, i, num_bits;
 	struct dm_stats_group *group = NULL;
 	struct dm_pool *extent_mem = NULL;
 	struct _extent *old_ext;
 	char *hist_arg = NULL;
-	int update, num_bits;
 	struct statfs fsbuf;
-	int64_t nr_kept = 0, i;
+	int64_t nr_kept = 0;
 	struct stat buf;
+	int update;
 
 	update = _stats_group_id_present(dms, group_id);
 



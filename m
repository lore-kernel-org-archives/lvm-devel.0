From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:26:55 +0000 (UTC)
Subject: master - libdm: enable creation of filemap regions with histograms
Message-ID: <20160708182655.5576A610E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4bb57341bd99a7d1af1a6a9ed84122369f362ba0
Commit:        4bb57341bd99a7d1af1a6a9ed84122369f362ba0
Parent:        c3caf4b80bbade402ba57c32090222214a9bc177
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 7 09:47:19 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

libdm: enable creation of filemap regions with histograms

---
 libdm/libdm-stats.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 55f1010..6504289 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4247,6 +4247,7 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 {
 	struct _extent *extents = NULL;
 	uint64_t *regions = NULL, i;
+	char *hist_arg = NULL;
 	struct statfs fsbuf;
 	struct stat buf;
 
@@ -4279,6 +4280,12 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 	if (!(extents = _stats_get_extents_for_file(dms->mem, fd, count)))
 		return_0;
 
+        if (bounds) {
+                /* _build_histogram_arg enables precise if vals < 1ms. */
+                if (!(hist_arg = _build_histogram_arg(bounds, &precise)))
+                        goto_out;
+        }
+
 	/* make space for end-of-table marker */
 	if (!(regions = dm_malloc((1 + *count) * sizeof(*regions)))) {
 		log_error("Could not allocate memory for region IDs.");
@@ -4286,9 +4293,9 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 	}
 
 	for (i = 0; i < *count; i++) {
-		if (!_stats_create_region(dms, regions + i,
-					  extents[i].start, extents[i].len, -1,
-					  precise, NULL, dms->program_id, "")) {
+		if (!_stats_create_region(dms, regions + i, extents[i].start,
+					  extents[i].len, -1, precise, hist_arg,
+					  dms->program_id, "")) {
 			log_error("Failed to create region " FMTu64 " of "
 				  FMTu64 " at " FMTu64 ".", i, *count,
 				  extents[i].start);
@@ -4321,12 +4328,6 @@ uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 {
 	uint64_t *regions, count = 0;
 
-	if (bounds) {
-		log_error("File mapped groups with histograms are not "
-			  "yet supported.");
-		return NULL;
-	}
-
 	if (alias && !group) {
 		log_error("Cannot set alias without grouping regions.");
 		return NULL;



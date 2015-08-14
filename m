From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 12:56:30 +0000 (UTC)
Subject: master - dmstats: cleanup _do_stats_create_regions()
Message-ID: <20150814125630.3453360AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f10ad95c3678f51c26ed55216f4337e78c992375
Commit:        f10ad95c3678f51c26ed55216f4337e78c992375
Parent:        9b3dc725060a243b7b6d849de9bafbdf3e9f5140
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Aug 13 20:54:21 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 13:36:52 2015 +0100

dmstats: cleanup _do_stats_create_regions()

Make the use of the this_start and this_len variables easier to
follow and clarify the use of zero start and len arguments to
request a whole-device region.
---
 tools/dmsetup.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 6e75e28..68ca7e0 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4381,7 +4381,9 @@ static uint64_t _nr_areas_from_step(uint64_t len, int64_t step)
 /*
  * Create a single region starting at start and spanning len sectors,
  * or, if the segments argument is no-zero create one region for each
- * segment present in the mapped device.
+ * segment present in the mapped device. Passing zero for segments,
+ * start, and length will create a single segment spanning the whole
+ * device.
  */
 static int _do_stats_create_regions(struct dm_stats *dms,
 				    const char *name, uint64_t start,
@@ -4390,7 +4392,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 				    const char *program_id,
 				    const char *aux_data)
 {
-	uint64_t this_start = start, this_len = len, region_id = UINT64_C(0);
+	uint64_t this_start, this_len, region_id = UINT64_C(0);
 	char *target_type, *params; /* unused */
 	struct dm_task *dmt;
 	struct dm_info info;
@@ -4439,8 +4441,8 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 			 * --start/--length arguments, or 0/0 for a default
 			 *  whole-device region).
 			 */
-			this_start = (segments) ? segment_start : this_start;
-			this_len = (segments) ? segment_len : this_len;
+			this_start = (segments) ? segment_start : start;
+			this_len = (segments) ? segment_len : len;
 			if (!dm_stats_create_region(dms, &region_id,
 						    this_start, this_len, step,
 						    program_id, aux_data)) {



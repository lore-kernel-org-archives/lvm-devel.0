From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 23:43:14 +0000 (UTC)
Subject: master - dmstats: fix new area count for 'create --areasize'
Message-ID: <20150814234314.CCAC960E61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d5cd4ca14a94d83bf7b3c0b73896abc4ff8926c
Commit:        9d5cd4ca14a94d83bf7b3c0b73896abc4ff8926c
Parent:        0b487802a041a0848e927e3dfc3d71618b66ca42
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Aug 15 00:32:59 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Aug 15 00:42:51 2015 +0100

dmstats: fix new area count for 'create --areasize'

Commit f10ad95 introduced a regression in the calculation of the
number of areas in a region created with the --areasize switch:

vg_hex-lv_home: Created new region with 0 area(s) as region ID 1
vg_hex-lv_swap: Created new region with 0 area(s) as region ID 1

Fis this by using the correct region size when calculating the
value.
---
 tools/dmsetup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 9e72226..ee1e1fe 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4456,7 +4456,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 				    const char *program_id,
 				    const char *aux_data)
 {
-	uint64_t this_start, this_len, region_id = UINT64_C(0);
+	uint64_t this_start = 0, this_len = 0, region_id = UINT64_C(0);
 	char *target_type, *params; /* unused */
 	struct dm_task *dmt;
 	struct dm_info info;
@@ -4506,7 +4506,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 			 *  whole-device region).
 			 */
 			this_start = (segments) ? segment_start : start;
-			this_len = (segments) ? segment_len : len;
+			this_len = (segments) ? segment_len : this_len;
 			if (!dm_stats_create_region(dms, &region_id,
 						    this_start, this_len, step,
 						    program_id, aux_data)) {



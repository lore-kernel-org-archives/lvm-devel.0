From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  6 Jul 2016 08:25:05 +0000 (UTC)
Subject: master - libdm: check non-zero io count in _average_{rd, wr}_wait_time (Coverity)
Message-ID: <20160706082505.18AFE60DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95ef0cdb461dfb7b7e6ac8e2484564fe0b5ec0ed
Commit:        95ef0cdb461dfb7b7e6ac8e2484564fe0b5ec0ed
Parent:        03e03e9c11f5731c225d6cb99a1f36d4d8b699f6
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jul 6 09:20:05 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jul 6 09:23:13 2016 +0100

libdm: check non-zero io count in _average_{rd,wr}_wait_time (Coverity)

Although a non-zero value for the number of ticks spent doing IO
should imply a non-zero number of IOs in the interval test for
this explicitly to avoid a divide-by-zero in the event of bad
counter data.
---
 libdm/libdm-stats.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index c0ef38f..c669b51 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2600,11 +2600,15 @@ static int _average_rd_wait_time(const struct dm_stats *dms, double *await,
 
 	rd_io_ticks = dm_stats_get_counter(dms, DM_STATS_READ_NSECS,
 					   region_id, area_id);
-
 	nr_rd_ios = dm_stats_get_counter(dms, DM_STATS_READS_COUNT,
 					 region_id, area_id);
 
-	if (rd_io_ticks > 0)
+	/*
+	 * If rd_io_ticks is > 0 this should imply that nr_rd_ios is
+	 * also > 0 (unless a kernel bug exists). Test for both here
+	 * before using the IO count as a divisor (Coverity).
+	 */
+	if (rd_io_ticks > 0 && nr_rd_ios > 0)
 		*await = (double) rd_io_ticks / (double) nr_rd_ios;
 	else
 		*await = 0.0;
@@ -2622,7 +2626,12 @@ static int _average_wr_wait_time(const struct dm_stats *dms, double *await,
 	nr_wr_ios = dm_stats_get_counter(dms, DM_STATS_WRITES_COUNT,
 					 region_id, area_id);
 
-	if (wr_io_ticks > 0)
+	/*
+	 * If wr_io_ticks is > 0 this should imply that nr_wr_ios is
+	 * also > 0 (unless a kernel bug exists). Test for both here
+	 * before using the IO count as a divisor (Coverity).
+	 */
+	if (wr_io_ticks > 0 && nr_wr_ios > 0)
 		*await = (double) wr_io_ticks / (double) nr_wr_ios;
 	else
 		*await = 0.0;



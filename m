From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 18 Aug 2015 09:31:57 +0000 (UTC)
Subject: master - dmstats: reduce minimum field widths
Message-ID: <20150818093157.CDCBA6055D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e229cb7ea37ccab0e235e53d27adca9b32ffae0
Commit:        8e229cb7ea37ccab0e235e53d27adca9b32ffae0
Parent:        13d3eeb2ee687455bd6e19ff6dae314b3a85776a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Aug 16 19:35:06 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Aug 18 10:30:53 2015 +0100

dmstats: reduce minimum field widths

---
 tools/dmsetup.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 10ec7a5..8074395 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3975,23 +3975,23 @@ FIELD_O(NAME, dm_split_name, STR, "LV", lv_name, 4, dm_lv_name, "lv_name", "LVM
 FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 7, dm_lv_layer_name, "lv_layer", "LVM device layer.")
 
 /* basic stats counters */
-FIELD_F(STATS, NUM, "Reads", 8, dm_stats_reads, "reads", "Number of reads completed.")
-FIELD_F(STATS, NUM, "RdMrges", 8, dm_stats_reads_merged, "reads_merged", "Number of reads merged.")
-FIELD_F(STATS, NUM, "RdSectors", 8, dm_stats_read_sectors, "read_sectors", "Number of sectors read.")
-FIELD_F(STATS, NUM, "RdNsec", 8, dm_stats_read_nsecs, "read_nsecs", "Time spent reading.")
-FIELD_F(STATS, NUM, "Writes", 8, dm_stats_writes, "writes", "Number of writes completed.")
-FIELD_F(STATS, NUM, "WrMerges", 8, dm_stats_writes_merged, "writes_merged", "Number of writes merged.")
-FIELD_F(STATS, NUM, "WrSectors", 8, dm_stats_write_sectors, "write_sectors", "Number of sectors written.")
-FIELD_F(STATS, NUM, "WrNsec", 8, dm_stats_write_nsecs, "write_nsecs", "Time spent writing.")
-FIELD_F(STATS, NUM, "InProgress", 8, dm_stats_io_in_progress, "in_progress", "Number of I/Os currently in progress.")
-FIELD_F(STATS, NUM, "IoNsec", 8, dm_stats_io_nsecs, "io_nsecs", "Time spent doing I/O.")
-FIELD_F(STATS, NUM, "WtIoNsec", 8, dm_stats_weighted_io_nsecs, "weighted_io_nsecs", "Weighted time spent doing I/O.")
-FIELD_F(STATS, NUM, "TotalRdNsec", 8, dm_stats_total_read_nsecs, "total_rd_nsecs", "Total time spent reading.")
-FIELD_F(STATS, NUM, "TotalWrNsec", 8, dm_stats_total_write_nsecs, "total_wr_nsecs", "Total time spent writing.")
+FIELD_F(STATS, NUM, "Reads", 5, dm_stats_reads, "reads", "Number of reads completed.")
+FIELD_F(STATS, NUM, "RdMrges", 5, dm_stats_reads_merged, "reads_merged", "Number of reads merged.")
+FIELD_F(STATS, NUM, "RdSectors", 5, dm_stats_read_sectors, "read_sectors", "Number of sectors read.")
+FIELD_F(STATS, NUM, "RdNsec", 5, dm_stats_read_nsecs, "read_nsecs", "Time spent reading.")
+FIELD_F(STATS, NUM, "Writes", 5, dm_stats_writes, "writes", "Number of writes completed.")
+FIELD_F(STATS, NUM, "WrMerges", 5, dm_stats_writes_merged, "writes_merged", "Number of writes merged.")
+FIELD_F(STATS, NUM, "WrSectors", 5, dm_stats_write_sectors, "write_sectors", "Number of sectors written.")
+FIELD_F(STATS, NUM, "WrNsec", 5, dm_stats_write_nsecs, "write_nsecs", "Time spent writing.")
+FIELD_F(STATS, NUM, "InProgress", 5, dm_stats_io_in_progress, "in_progress", "Number of I/Os currently in progress.")
+FIELD_F(STATS, NUM, "IoNsec", 5, dm_stats_io_nsecs, "io_nsecs", "Time spent doing I/O.")
+FIELD_F(STATS, NUM, "WtIoNsec", 5, dm_stats_weighted_io_nsecs, "weighted_io_nsecs", "Weighted time spent doing I/O.")
+FIELD_F(STATS, NUM, "TotalRdNsec", 5, dm_stats_total_read_nsecs, "total_rd_nsecs", "Total time spent reading.")
+FIELD_F(STATS, NUM, "TotalWrNsec", 5, dm_stats_total_write_nsecs, "total_wr_nsecs", "Total time spent writing.")
 
 /* Stats derived metrics */
-FIELD_F(STATS, NUM, "RRqM/s", 8, dm_stats_rrqm, "rrqm", "Read requests merged per second.")
-FIELD_F(STATS, NUM, "WRqM/s", 8, dm_stats_wrqm, "wrqm", "Write requests merged per second.")
+FIELD_F(STATS, NUM, "RRqM/s", 5, dm_stats_rrqm, "rrqm", "Read requests merged per second.")
+FIELD_F(STATS, NUM, "WRqM/s", 5, dm_stats_wrqm, "wrqm", "Write requests merged per second.")
 FIELD_F(STATS, NUM, "R/s", 5, dm_stats_rs, "rs", "Reads per second.")
 FIELD_F(STATS, NUM, "W/s", 5, dm_stats_ws, "ws", "Writes per second.")
 FIELD_F(STATS, NUM, "RSz/s", 5, dm_stats_read_secs, "rsize_sec", "Size of data read per second.")
@@ -4003,21 +4003,21 @@ FIELD_F(STATS, NUM, "RdAWait", 5, dm_stats_r_await, "r_await", "Averate read wai
 FIELD_F(STATS, NUM, "WrAWait", 5, dm_stats_w_await, "w_await", "Averate write wait time.")
 FIELD_F(STATS, NUM, "TPut", 5, dm_stats_tput, "tput", "Throughput.")
 FIELD_F(STATS, NUM, "SvcTm", 5, dm_stats_svctm, "svctm", "Service time.")
-FIELD_F(STATS, NUM, "Util%", 10, dm_stats_util, "util", "Utilization.")
+FIELD_F(STATS, NUM, "Util%", 5, dm_stats_util, "util", "Utilization.")
 
 /* Stats interval duration estimates */
 FIELD_F(STATS, NUM, "IntervalNSec", 10, dm_stats_sample_interval_ns, "interval_ns", "Sampling interval in nanoseconds.")
 FIELD_F(STATS, NUM, "Interval", 8, dm_stats_sample_interval, "interval", "Sampling interval.")
 
 /* Stats report meta-fields */
-FIELD_F(STATS_META, NUM, "RgID", 5, dm_stats_region_id, "region_id", "Region ID.")
+FIELD_F(STATS_META, NUM, "RgID", 4, dm_stats_region_id, "region_id", "Region ID.")
 FIELD_F(STATS_META, SIZ, "RStart", 5, dm_stats_region_start, "region_start", "Region start.")
 FIELD_F(STATS_META, SIZ, "RSize", 5, dm_stats_region_len, "region_len", "Region length.")
-FIELD_F(STATS_META, NUM, "ArID", 5, dm_stats_area_id, "area_id", "Area ID.")
+FIELD_F(STATS_META, NUM, "ArID", 4, dm_stats_area_id, "area_id", "Area ID.")
 FIELD_F(STATS_META, SIZ, "AStart", 5, dm_stats_area_start, "area_start", "Area offset from start of device.")
 FIELD_F(STATS_META, SIZ, "ASize", 5, dm_stats_area_len, "area_len", "Area length.")
 FIELD_F(STATS_META, SIZ, "AOff", 5, dm_stats_area_offset, "area_offset", "Area offset from start of region.")
-FIELD_F(STATS_META, NUM, "#Areas", 6, dm_stats_area_count, "area_count", "Area count.")
+FIELD_F(STATS_META, NUM, "#Areas", 3, dm_stats_area_count, "area_count", "Area count.")
 FIELD_F(STATS_META, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
 FIELD_F(STATS_META, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
 {0, 0, 0, 0, "", "", NULL, NULL},



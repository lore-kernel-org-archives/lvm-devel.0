From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  2 Sep 2015 20:03:28 +0000 (UTC)
Subject: master - dmstats: improve stats column names
Message-ID: <20150902200328.8DE236100C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=031cd2bb0dc436619b1e186512a024ea095c2324
Commit:        031cd2bb0dc436619b1e186512a024ea095c2324
Parent:        3c0fc6f0dad6489c7530d3b844e6db3c9ac620cf
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Aug 22 19:35:43 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Sep 2 21:03:03 2015 +0100

dmstats: improve stats column names

Improve the names and labels of stats reports columns, ensure that
the minimum field widths allow unambiguos labels to be shown and
update the man page descriptions of these fields.
---
 man/dmstats.8.in |  120 ++++++++++++++++++++++++++++-------------------------
 tools/dmsetup.c  |   77 ++++++++++++++++++----------------
 2 files changed, 104 insertions(+), 93 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index be7fb11..eb8f400 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -487,58 +487,58 @@ conventional Linux iostat program and are derived from the basic counter
 values provided by the kernel for each area.
 .br
 .HP
-.B rrqm
+.B reads_merged_per_sec
 .br
-Read requests merged per second.
+Reads merged per second.
 .HP
-.B wrqm
+.B writes_merged_per_sec
 .br
-Write requests merged per second.
+Writes merged per second.
 .HP
-.B rs
+.B reads_per_sec
 .br
-Read requests per second.
+Reads completed per second.
 .HP
-.B ws
+.B writes_per_sec
 .br
-Write requests per second.
+Writes completed per second.
 .HP
-.B rsec
+.B read_size_per_sec
 .br
-Sectors read per second.
+Size of data read per second.
 .HP
-.B wsec
+.B write_size_per_sec
 .br
-Sectors written per second.
+Size of data written per second.
 .HP
-.B arqsz
+.B avg_request_size
 .br
-The average size of requests submitted to the area.
+Average request size.
 .HP
-.B qusz
+.B queue_size
 .br
-The average queue length.
+Average queue size.
 .HP
 .B await
 .br
-The average wait time for read and write requests.
+The average wait time for read and write operations.
 .HP
 .B r_await
 .br
-The average wait time for read requests.
+The average wait time for read operations.
 .HP
 .B w_await
 .br
-The average wait time for write requests.
+The average wait time for write operations.
 .HP
-.B tput
+.B throughput
 .br
-The device throughput in requests per second.
+The device throughput in operations per second.
 .HP
-.B svctm
+.B service_time
 .br
-The  average  service  time  (in milliseconds) for I/O requests that
-were issued to the device.
+The  average  service  time  (in milliseconds) for operations issued
+to the device.
 .HP
 .B util
 .br
@@ -561,11 +561,13 @@ when a statistics region is created.
 .B region_start
 .br
 .br
-The region start sector in units of 512 byte sectors.
+The region start location. Display units are selected by the
+\fB--units\fP option.
 .HP
 .B region_len
 .br
-The length of the region in units of 512 byte sectors.
+The length of the region. Display units are selected by the
+\fB--units\fP option.
 .HP
 .B area_id
 .br
@@ -574,18 +576,18 @@ statistics library and uniquely identify each area within a region. Each
 ID corresponds to a distinct set of performance counters for that area
 of the statistics region. Area identifiers are always monotonically
 increasing within a region so that higher ID values correspond to
-greater sector addresses within the region and no gaps in the sequence
-of identifiers exist. Sorting a report by device, region start, and area
-ID (the default) will then produce rows in order of ascending region and
-area address.
+greater sector addresses within the area and no gaps in the sequence of
+identifiers exist.
 .HP
 .B area_start
 .br
-The area start sector in units of 512 byte sectors.
+The area start location. Display units are selected by the
+\fB--units\fP option.
 .HP
 .B area_len
 .br
-The length of the area in units of 512 byte sectors.
+The length of the area. Display units are selected by the
+\fB--units\fP option.
 .HP
 .B area_count
 .br
@@ -603,7 +605,7 @@ The auxiliary data value associated with this region.
 .B interval_ns
 .br
 The estimated interval over which the current counter values have
-accumulated. The vaulue is reported as an interger expressed in units
+accumulated. The value is reported as an interger expressed in units
 of nanoseconds.
 .br
 .HP
@@ -623,57 +625,61 @@ area. The first eleven of these match the counters provided in
 counters for read and write time.
 .P
 .HP
-.B reads
+.B read_count
 .br
-The number of reads successfully completed this interval.
+Count of reads completed this interval.
 .HP
-.B read_merges
+.B reads_merged_count
 .br
-The number of read requests merged this interval. This field is
-incremented every time a pair of requests are merged to create a single
-request to be issued to the device.
+Count of reads merged this interval.
 .HP
-.B read_sectors
+.B read_sector_count
 .br
-The number of 512 byte sectors read this interval.
+Count of 512 byte sectors read this interval.
 .HP
-.B read_nsecs
+.B read_time
 .br
-The number of nanoseconds spent reading during this interval.
+Accumulated duration of all read requests (ns).
 .HP
-.B writes
+.B write_count
 .br
-The number of writes successfully completed this interval.
+Count of writes completed this interval.
 .HP
-.B write_merges
+.B writes_merged_count
 .br
-The number of write requests merged this interval. This field is
-incremented every time a pair of requests are merged to create a single
-request to be issued to the device.
+Count of writes merged this interval.
 .HP
-.B write_sectors
+.B write_sector_count
 .br
-The number of 512 byte sectors written this interval.
+Count of 512 byte sectors written this interval.
 .HP
 .B write_nsecs
 .br
-The number of nanoseconds spent writing during this interval.
+Accumulated duration of all write requests (ns).
 .HP
-.B in_progress
+.B in_progress_count
 .br
-The number of reads and writes currently in progress.
+Count of requests currently in progress.
 .HP
-.B io_nsecs
+.B io_ticks
 .br
-The number of nanoseconds spent reading and writing.
+Nanoseconds spent servicing requests.
 .HP
-.B weighted_io_nsecs
+.B queue_ticks
 .br
 This field is incremented at each I/O start, I/O completion, I/O merge,
 or read of these stats by the number of I/Os in progress multiplied by
 the number of milliseconds spent doing I/O since the last update of this
 field.  This can provide an easy measure of both I/O completion time and
 the backlog that may be accumulating.
+.HP
+.B read_ticks
+.br
+Nanoseconds spent servicing reads.
+.HP
+.B write_ticks
+.br
+Nanoseconds spent servicing writes.
 .br
 .SS Histogram fields
 Histograms measure the frequency distribution of user specified I/O
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index bffeb7f..9c9711d 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4136,34 +4136,34 @@ FIELD_O(NAME, dm_split_name, STR, "LV", lv_name, 4, dm_lv_name, "lv_name", "LVM
 FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 7, dm_lv_layer_name, "lv_layer", "LVM device layer.")
 
 /* basic stats counters */
-FIELD_F(STATS, NUM, "Reads", 5, dm_stats_reads, "reads", "Number of reads completed.")
-FIELD_F(STATS, NUM, "RdMrges", 5, dm_stats_reads_merged, "reads_merged", "Number of reads merged.")
-FIELD_F(STATS, NUM, "RdSectors", 5, dm_stats_read_sectors, "read_sectors", "Number of sectors read.")
-FIELD_F(STATS, NUM, "RdNsec", 5, dm_stats_read_nsecs, "read_nsecs", "Time spent reading.")
-FIELD_F(STATS, NUM, "Writes", 5, dm_stats_writes, "writes", "Number of writes completed.")
-FIELD_F(STATS, NUM, "WrMerges", 5, dm_stats_writes_merged, "writes_merged", "Number of writes merged.")
-FIELD_F(STATS, NUM, "WrSectors", 5, dm_stats_write_sectors, "write_sectors", "Number of sectors written.")
-FIELD_F(STATS, NUM, "WrNsec", 5, dm_stats_write_nsecs, "write_nsecs", "Time spent writing.")
-FIELD_F(STATS, NUM, "InProgress", 5, dm_stats_io_in_progress, "in_progress", "Number of I/Os currently in progress.")
-FIELD_F(STATS, NUM, "IoNsec", 5, dm_stats_io_nsecs, "io_nsecs", "Time spent doing I/O.")
-FIELD_F(STATS, NUM, "WtIoNsec", 5, dm_stats_weighted_io_nsecs, "weighted_io_nsecs", "Weighted time spent doing I/O.")
-FIELD_F(STATS, NUM, "TotalRdNsec", 5, dm_stats_total_read_nsecs, "total_rd_nsecs", "Total time spent reading.")
-FIELD_F(STATS, NUM, "TotalWrNsec", 5, dm_stats_total_write_nsecs, "total_wr_nsecs", "Total time spent writing.")
+FIELD_F(STATS, NUM, "#Reads", 6, dm_stats_reads, "read_count", "Count of reads completed.")
+FIELD_F(STATS, NUM, "#RdMrgs", 7, dm_stats_reads_merged, "reads_merged_count", "Count of read requests merged.")
+FIELD_F(STATS, NUM, "#RdSectors", 10, dm_stats_read_sectors, "read_sector_count", "Count of sectors read.")
+FIELD_F(STATS, NUM, "AccRdTime", 11, dm_stats_read_nsecs, "read_time", "Accumulated duration of all read requests (ns).")
+FIELD_F(STATS, NUM, "#Writes", 7, dm_stats_writes, "write_count", "Count of writes completed.")
+FIELD_F(STATS, NUM, "#WrMrgs", 7, dm_stats_writes_merged, "writes_merged_count", "Count of write requests merged.")
+FIELD_F(STATS, NUM, "#WrSectors", 10, dm_stats_write_sectors, "write_sector_count", "Count of sectors written.")
+FIELD_F(STATS, NUM, "AccWrTime", 11, dm_stats_write_nsecs, "write_time", "Accumulated duration of all writes (ns).")
+FIELD_F(STATS, NUM, "#InProg", 7, dm_stats_io_in_progress, "in_progress_count", "Count of requests currently in progress.")
+FIELD_F(STATS, NUM, "IoTicks", 7, dm_stats_io_nsecs, "io_ticks", "Nanoseconds spent servicing requests.")
+FIELD_F(STATS, NUM, "QueueTicks", 10, dm_stats_weighted_io_nsecs, "queue_ticks", "Total nanoseconds spent in queue.")
+FIELD_F(STATS, NUM, "RdTicks", 7, dm_stats_total_read_nsecs, "read_ticks", "Nanoseconds spent servicing reads.")
+FIELD_F(STATS, NUM, "WrTicks", 7, dm_stats_total_write_nsecs, "write_ticks", "Nanoseconds spent servicing writes.")
 
 /* Stats derived metrics */
-FIELD_F(STATS, NUM, "RRqM/s", 5, dm_stats_rrqm, "rrqm", "Read requests merged per second.")
-FIELD_F(STATS, NUM, "WRqM/s", 5, dm_stats_wrqm, "wrqm", "Write requests merged per second.")
-FIELD_F(STATS, NUM, "R/s", 5, dm_stats_rs, "rs", "Reads per second.")
-FIELD_F(STATS, NUM, "W/s", 5, dm_stats_ws, "ws", "Writes per second.")
-FIELD_F(STATS, NUM, "RSz/s", 5, dm_stats_read_secs, "rsize_sec", "Size of data read per second.")
-FIELD_F(STATS, NUM, "WSz/s", 5, dm_stats_write_secs, "wsize_sec", "Size of data written per second.")
-FIELD_F(STATS, NUM, "AvRqSz", 5, dm_stats_arqsz, "arqsz", "Average request size.")
-FIELD_F(STATS, NUM, "QSize", 5, dm_stats_qusz, "qusz", "Average queue size.")
+FIELD_F(STATS, NUM, "RMrg/s", 6, dm_stats_rrqm, "reads_merged_per_sec", "Read requests merged per second.")
+FIELD_F(STATS, NUM, "WMrg/s", 6, dm_stats_wrqm, "writes_merged_per_sec", "Write requests merged per second.")
+FIELD_F(STATS, NUM, "R/s", 3, dm_stats_rs, "reads_per_sec", "Reads per second.")
+FIELD_F(STATS, NUM, "W/s", 3, dm_stats_ws, "writes_per_sec", "Writes per second.")
+FIELD_F(STATS, NUM, "RSz/s", 5, dm_stats_read_secs, "read_size_per_sec", "Size of data read per second.")
+FIELD_F(STATS, NUM, "WSz/s", 5, dm_stats_write_secs, "write_size_per_sec", "Size of data written per second.")
+FIELD_F(STATS, NUM, "AvgRqSz", 7, dm_stats_arqsz, "avg_request_size", "Average request size.")
+FIELD_F(STATS, NUM, "QSize", 5, dm_stats_qusz, "queue_size", "Average queue size.")
 FIELD_F(STATS, NUM, "AWait", 5, dm_stats_await, "await", "Averate wait time.")
-FIELD_F(STATS, NUM, "RdAWait", 5, dm_stats_r_await, "r_await", "Averate read wait time.")
-FIELD_F(STATS, NUM, "WrAWait", 5, dm_stats_w_await, "w_await", "Averate write wait time.")
-FIELD_F(STATS, NUM, "TPut", 5, dm_stats_tput, "tput", "Throughput.")
-FIELD_F(STATS, NUM, "SvcTm", 5, dm_stats_svctm, "svctm", "Service time.")
+FIELD_F(STATS, NUM, "RdAWait", 7, dm_stats_r_await, "read_await", "Averate read wait time.")
+FIELD_F(STATS, NUM, "WrAWait", 7, dm_stats_w_await, "write_await", "Averate write wait time.")
+FIELD_F(STATS, NUM, "Throughput", 10, dm_stats_tput, "throughput", "Throughput.")
+FIELD_F(STATS, NUM, "SvcTm", 5, dm_stats_svctm, "service_time", "Service time.")
 FIELD_F(STATS, NUM, "Util%", 5, dm_stats_util, "util", "Utilization.")
 
 /* Histogram fields */
@@ -4175,18 +4175,18 @@ FIELD_F(STATS, STR, "Histogram%", 10, dm_stats_hist_percent_bounds, "hist_percen
 FIELD_F(STATS, STR, "Histogram%", 10, dm_stats_hist_percent_ranges, "hist_percent_ranges", "Relative latency histogram with bin ranges.")
 
 /* Stats interval duration estimates */
-FIELD_F(STATS, NUM, "IntervalNSec", 10, dm_stats_sample_interval_ns, "interval_ns", "Sampling interval in nanoseconds.")
+FIELD_F(STATS, NUM, "IntervalNs", 10, dm_stats_sample_interval_ns, "interval_ns", "Sampling interval in nanoseconds.")
 FIELD_F(STATS, NUM, "Interval", 8, dm_stats_sample_interval, "interval", "Sampling interval.")
 
 /* Stats report meta-fields */
 FIELD_F(STATS_META, NUM, "RgID", 4, dm_stats_region_id, "region_id", "Region ID.")
-FIELD_F(STATS_META, SIZ, "RStart", 5, dm_stats_region_start, "region_start", "Region start.")
-FIELD_F(STATS_META, SIZ, "RSize", 5, dm_stats_region_len, "region_len", "Region length.")
+FIELD_F(STATS_META, SIZ, "RgStart", 5, dm_stats_region_start, "region_start", "Region start.")
+FIELD_F(STATS_META, SIZ, "RgSize", 5, dm_stats_region_len, "region_len", "Region length.")
 FIELD_F(STATS_META, NUM, "ArID", 4, dm_stats_area_id, "area_id", "Area ID.")
-FIELD_F(STATS_META, SIZ, "AStart", 5, dm_stats_area_start, "area_start", "Area offset from start of device.")
-FIELD_F(STATS_META, SIZ, "ASize", 5, dm_stats_area_len, "area_len", "Area length.")
-FIELD_F(STATS_META, SIZ, "AOff", 5, dm_stats_area_offset, "area_offset", "Area offset from start of region.")
-FIELD_F(STATS_META, NUM, "#Areas", 3, dm_stats_area_count, "area_count", "Area count.")
+FIELD_F(STATS_META, SIZ, "ArStart", 7, dm_stats_area_start, "area_start", "Area offset from start of device.")
+FIELD_F(STATS_META, SIZ, "ArSize", 6, dm_stats_area_len, "area_len", "Area length.")
+FIELD_F(STATS_META, SIZ, "ArOff", 5, dm_stats_area_offset, "area_offset", "Area offset from start of region.")
+FIELD_F(STATS_META, NUM, "#Areas", 6, dm_stats_area_count, "area_count", "Area count.")
 FIELD_F(STATS_META, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
 FIELD_F(STATS_META, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
 FIELD_F(STATS_META, STR, "Precise", 7, dm_stats_precise, "precise", "Set if nanosecond precision counters are enabled.")
@@ -4208,12 +4208,17 @@ static const char *default_report_options = "name,major,minor,attr,open,segments
 static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
 
 /* Stats counters & derived metrics. */
-#define RD_COUNTERS "reads,reads_merged,read_sectors,read_nsecs,total_rd_nsecs"
-#define WR_COUNTERS "writes,writes_merged,write_sectors,write_nsecs,total_wr_nsecs"
-#define IO_COUNTERS "in_progress,io_nsecs,weighted_io_nsecs"
-#define METRICS "rrqm,wrqm,rs,ws,rsize_sec,wsize_sec,arqsz,qusz,util,await,r_await,w_await"
+#define RD_COUNTERS "read_count,reads_merged_count,read_sector_count,read_time,read_ticks"
+#define WR_COUNTERS "write_count,writes_merged_count,write_sector_count,write_time,write_ticks"
+#define IO_COUNTERS "in_progress_count,io_ticks,queue_ticks"
 #define COUNTERS RD_COUNTERS "," WR_COUNTERS "," IO_COUNTERS
 
+#define METRICS "reads_merged_per_sec,writes_merged_per_sec,"	\
+		"reads_per_sec,writes_per_sec,"			\
+		"read_size_per_sec,write_size_per_sec,"		\
+		"avg_request_size,queue_size,util,"		\
+		"await,read_await,write_await"
+
 /* Device, region and area metadata. */
 #define STATS_DEV_INFO "name,region_id"
 #define STATS_AREA_INFO "area_id,area_start,area_len"



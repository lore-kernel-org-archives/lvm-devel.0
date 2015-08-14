From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 21:05:16 +0000 (UTC)
Subject: master - dmsetup: add support for 'stats report --raw'
Message-ID: <20150814210516.73C9B60B3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16ff2d927f6ce2f8c2ad8f7e6ec8fb52bd2a066c
Commit:        16ff2d927f6ce2f8c2ad8f7e6ec8fb52bd2a066c
Parent:        fc7a27bc3d8c14ba696cf6893708d2715918d564
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 14 17:42:03 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 22:03:37 2015 +0100

dmsetup: add support for 'stats report --raw'

Add a '--raw' switch to stats reports that causes us to report the
basic counter values rather than derived metrics for each visible
statistics region.
---
 tools/dmsetup.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 66364ac..74e7806 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -191,6 +191,7 @@ enum {
 	NOUDEVSYNC_ARG,
 	OPTIONS_ARG,
 	PROGRAM_ID_ARG,
+	RAW_ARG,
 	READAHEAD_ARG,
 	REGION_ID_ARG,
 	RETRY_ARG,
@@ -3996,11 +3997,13 @@ static const char *default_report_options = "name,major,minor,attr,open,segments
 static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
 
 #define DEV_INFO_STATS "name,region_id"
-#define RD_STATS "reads,reads_merged,read_sectors,read_nsecs,total_rd_nsecs"
-#define WR_STATS "writes,writes_merged,write_sectors,write_nsecs,total_wr_nsecs"
-#define IO_STATS "in_progress,io_nsecs,weighted_io_nsecs"
+#define RD_COUNTERS "reads,reads_merged,read_sectors,read_nsecs,total_rd_nsecs"
+#define WR_COUNTERS "writes,writes_merged,write_sectors,write_nsecs,total_wr_nsecs"
+#define IO_COUNTERS "in_progress,io_nsecs,weighted_io_nsecs"
 #define METRICS "rrqm,wrqm,rs,ws,rsize_sec,wsize_sec,arqsz,qusz,util,await,r_await,w_await"
+#define COUNTERS RD_COUNTERS "," WR_COUNTERS "," IO_COUNTERS
 static const char *_stats_default_report_options = DEV_INFO_STATS ",area_id,area_start,area_len," METRICS;
+static const char *_stats_raw_report_options = DEV_INFO_STATS ",area_id,area_start,area_len," COUNTERS;
 static const char *_stats_list_options = "name,region_id,region_start,region_len,area_len,area_count,program_id";
 
 static int _report_init(const struct command *cmd, const char *subcommand)
@@ -4026,7 +4029,9 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 		if (!strcmp(subcommand, "list"))
 			options = (char *) _stats_list_options;
 		else {
-			options = (char *) _stats_default_report_options;
+			options = (char *) (!_switches[RAW_ARG])
+					    ? _stats_default_report_options
+					    : _stats_raw_report_options;
 			_report_type |= DR_STATS;
 		}
 	}
@@ -5430,6 +5435,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
 		{"programid", 1, &ind, PROGRAM_ID_ARG},
+		{"raw", 0, &ind, RAW_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
 		{"regionid", 1, &ind, REGION_ID_ARG},
 		{"retry", 0, &ind, RETRY_ARG},
@@ -5579,6 +5585,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[PROGRAM_ID_ARG]++;
 			_string_args[PROGRAM_ID_ARG] = optarg;
 		}
+		if (ind == RAW_ARG)
+			_switches[RAW_ARG]++;
 		if (ind == REGION_ID_ARG) {
 			_switches[REGION_ID_ARG]++;
 			_int_args[REGION_ID_ARG] = atoi(optarg);



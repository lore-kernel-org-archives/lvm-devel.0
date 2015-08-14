From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 21:05:24 +0000 (UTC)
Subject: master - dmstats: make -v enable per area reports for 'stats list'
Message-ID: <20150814210524.C50D660358@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3891e90e32d0b76dc8c3ef2fb9bddbe09ffb846
Commit:        f3891e90e32d0b76dc8c3ef2fb9bddbe09ffb846
Parent:        0f3b81bb2e7de61457ec0f2a72f381b9992421c6
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 14 20:40:13 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 22:03:37 2015 +0100

dmstats: make -v enable per area reports for 'stats list'

When dmstats is run with -v or higher enable a per-area reporting
mode for statistics regions. This will output one row per area
(rather than one row per region) and adds additional fields of use
when viewing areas:

 area_id    - index within the region assigned by libdm-stats
 area_start - the start location of the area in the containing
              device.
---
 man/dmstats.8.in |    6 ++++++
 tools/dmsetup.c  |   43 +++++++++++++++++++++++++++++++++----------
 2 files changed, 39 insertions(+), 10 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index f8d2949..a6b2ff5 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -63,6 +63,8 @@ dmstats \(em device-mapper statistics management
 .RB [ \-\-units
 .IR units ]
 .RB [ \-\-nosuffix ]
+.RB [ \-\-nosuffix ]
+.RB [ \-v | \-\-verbose \ [ \-v | \-\-verbose ]
 .br
 .B dmstats print
 .RI [ device_name ]
@@ -302,11 +304,15 @@ the list of report fields.
 .RI [ device_name ]
 .RB [ \-\-allprograms ]
 .RB [ \-\-programid
+.RB [ \-v | \-\-verbose \ [ \-v | \-\-verbose ]]
 .IR id ]
 .br
 List the statistics regions registered on the device. If the
 \fB\-\-allprograms\fP switch is given all regions will be listed
 regardless of region program ID values.
+
+If \fB\-v\fP or \fB\-\-verbose\fP is given the report will include
+a row of information for each area contained in each region displayed.
 .br
 .TP
 .B print
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f69fbe4..f90ce3e 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -256,6 +256,7 @@ static struct dm_timestamp *_initial_timestamp = NULL;
 static uint64_t _disp_factor = 512; /* display sizes in sectors */
 static char _disp_units = 's';
 const char *_program_id = DM_STATS_PROGRAM_ID; /* program_id used for reports. */
+static int _stats_report_by_areas = 1; /* output per-area info for stats reports. */
 
 /* report timekeeping */
 static struct dm_timestamp *_cycle_timestamp = NULL;
@@ -859,8 +860,10 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 	dm_stats_walk_do(obj.stats) {
 		if (!dm_report_object(_report, &obj))
 			goto_out;
-		/* report walk is always by area */
-		dm_stats_walk_next(obj.stats);
+		if (_stats_report_by_areas)
+			dm_stats_walk_next(obj.stats);
+		else
+			dm_stats_walk_next_region(obj.stats);
 	} dm_stats_walk_while(obj.stats);
 	r = 1;
 
@@ -4024,15 +4027,23 @@ FIELD_F(STATS_META, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary
 static const char *default_report_options = "name,major,minor,attr,open,segments,events,uuid";
 static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
 
-#define DEV_INFO_STATS "name,region_id"
+/* Stats counters & derived metrics. */
 #define RD_COUNTERS "reads,reads_merged,read_sectors,read_nsecs,total_rd_nsecs"
 #define WR_COUNTERS "writes,writes_merged,write_sectors,write_nsecs,total_wr_nsecs"
 #define IO_COUNTERS "in_progress,io_nsecs,weighted_io_nsecs"
 #define METRICS "rrqm,wrqm,rs,ws,rsize_sec,wsize_sec,arqsz,qusz,util,await,r_await,w_await"
 #define COUNTERS RD_COUNTERS "," WR_COUNTERS "," IO_COUNTERS
-static const char *_stats_default_report_options = DEV_INFO_STATS ",area_id,area_start,area_len," METRICS;
-static const char *_stats_raw_report_options = DEV_INFO_STATS ",area_id,area_start,area_len," COUNTERS;
-static const char *_stats_list_options = "name,region_id,region_start,region_len,area_len,area_count,program_id";
+
+/* Device, region and area metadata. */
+#define STATS_DEV_INFO "name,region_id"
+#define STATS_AREA_INFO STATS_DEV_INFO ",region_start,region_len,area_count,area_id,area_start,area_len"
+#define STATS_REGION_INFO STATS_DEV_INFO ",region_start,region_len,area_count,area_len"
+
+/* Default stats report options. */
+static const char *_stats_default_report_options = STATS_DEV_INFO ",area_id,area_start,area_len," METRICS;
+static const char *_stats_raw_report_options = STATS_DEV_INFO ",area_id,area_start,area_len," COUNTERS;
+static const char *_stats_list_options = STATS_REGION_INFO ",program_id";
+static const char *_stats_area_list_options = STATS_AREA_INFO ",program_id";
 
 static int _report_init(const struct command *cmd, const char *subcommand)
 {
@@ -4055,11 +4066,14 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 	if (cmd && !strcmp(cmd->name, "stats")) {
 		_report_type |= DR_STATS_META;
 		if (!strcmp(subcommand, "list"))
-			options = (char *) _stats_list_options;
+			options = (char *) ((_switches[VERBOSE_ARG])
+					    ? _stats_area_list_options
+					    : _stats_list_options);
 		else {
-			options = (char *) (!_switches[RAW_ARG])
+			options = (char *) ((!_switches[RAW_ARG])
 					    ? _stats_default_report_options
-					    : _stats_raw_report_options;
+					    : _stats_raw_report_options);
+
 			_report_type |= DR_STATS;
 		}
 	}
@@ -4772,6 +4786,9 @@ static int _stats_report(CMD_ARGS)
 	if (_switches[ALL_PROGRAMS_ARG])
 		_program_id = "";
 
+	if (!_switches[VERBOSE_ARG] && !strcmp(subcommand, "list"))
+		_stats_report_by_areas = 0;
+
 	if (names)
 		name = names->name;
 	else {
@@ -5067,7 +5084,13 @@ static int _stats(CMD_ARGS)
 		return 0;
 	}
 
-	if (!stats_cmd->fn(stats_cmd, NULL, argc, argv, NULL, multiple_devices))
+	/*
+	 * Pass the sub-command through to allow a single function to be
+	 * used to implement several distinct sub-commands (e.g. 'report'
+	 * and 'list' share a single implementation.
+	 */
+	if (!stats_cmd->fn(stats_cmd, subcommand, argc, argv, NULL,
+			   multiple_devices))
 		return 0;
 
 	return 1;



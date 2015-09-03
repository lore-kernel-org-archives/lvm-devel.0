From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu,  3 Sep 2015 22:45:33 +0000 (UTC)
Subject: master - dmstats: replace histogram command with switch
Message-ID: <20150903224533.146ED60BAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cebbb0feafb97516377388eb1747e3207c4f0596
Commit:        cebbb0feafb97516377388eb1747e3207c4f0596
Parent:        6240a7639d1473f7e22c8a8099176bc1b444d4d3
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Sep 3 23:00:44 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Sep 3 23:39:11 2015 +0100

dmstats: replace histogram command with switch

Replace the histogram stats subcommand with a --histogram switch
to enable histogram related fields for both list and report output.

To avoid overloading the existing --histogram rename it to --bounds:
this is also a better description of the option.
---
 man/dmstats.8.in |   84 +++++++++++++++---------------------------------------
 tools/dmsetup.c  |   52 ++++++++++++++++++++-------------
 2 files changed, 54 insertions(+), 82 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 1e19524..326ab25 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -32,8 +32,8 @@ dmstats \(em device-mapper statistics management
 .IR nr_areas ]
 .RB |[ \-\-areasize
 .IR area_size ]]
-.RB [ \-\-histogram
-.IR boundaries ]
+.RB [ \-\-bounds
+.IR histogram_boundaries ]
 .RB [ \-\-precise ]
 .RB [[ \-\-start
 .IR start_sector ]
@@ -58,34 +58,12 @@ dmstats \(em device-mapper statistics management
 .B dmstats help
 .RB [ \-c | \-C | \-\-columns ]
 .br
-.B dmstats histogram
-.RI [ device_name ]
-.RB [ \-\-interval
-.IR seconds ]
-.RB [ \-\-count
-.IR count ]
-.RB [ \-\-units
-.IR units ]
-.RB [ \-\-allprograms ]
-.RB [ \-\-programid
-.IR id ]
-.RB [ \-\-relative ]
-.RB [ \-\-regionid
-.IR id ]
-.RB [ \-O | \-\-sort
-.IR sort_fields ]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-\-units
-.IR units ]
-.RB [ \-\-nosuffix ]
-.RB [ \-\-notimesuffix ]
-.br
 .B dmstats list
 .RI [ device_name ]
 .RB [ \-\-allprograms
 .RB | \-\-programid
 .IR id ]
+.RB [ \-\-histogram ]
 .RB [ \-\-units
 .IR units ]
 .RB [ \-\-nosuffix ]
@@ -110,6 +88,7 @@ dmstats \(em device-mapper statistics management
 .IR count ]
 .RB [ \-\-units
 .IR units ]
+.RB [ \-\-histogram ]
 .RB [ \-\-allprograms ]
 .RB [ \-\-programid
 .IR id ]
@@ -180,13 +159,17 @@ When printing statistics counters, also atomically reset them to zero.
 Specify the iteration count for repeating reports. If the count
 argument is zero reports will continue to repeat until interrupted.
 .TP
-.B \-\-histogram \fIboundaries
+.B \-\-bounds \fIhistogram_boundaries
 Specify the boundaries of a latency histogram to be tracked for the
 region as a comma separated list of latency values. Latency values are
 given in nanoseconds. An optional unit suffix of ns, us, ms, or s may be
 given after each value to specify units of nanoseconds, microseconds,
 miliseconds or seconds respectively.
 .TP
+.B \-\-histogram
+When used with the \fBreport\fP and \fBlist\fP commands select default
+fields that emphasize latency histogram data.
+.TP
 .B \-\-interval \fIseconds
 Specify the interval in seconds between successive iterations for
 repeating reports. If \-\-interval is specified but \-\-count is not,
@@ -289,8 +272,8 @@ regions (with the exception of in-flight IO counters).
 .IR nr_areas ]
 .RB [ \-\-areasize
 .IR area_size ]
-.RB [ \-\-histogram
-.IR boundaries ]
+.RB [ --bounds
+.IR histogram_boundaries ]
 .RB [ \-\-precise ]
 .RB [[ \-\-start
 .IR start_sector ]
@@ -314,7 +297,7 @@ device-mapper device's table.
 If the \fB\-\-precise\fP option is used the command will attempt to
 create a region using nanosecond precision counters.
 
-If \fB\-\-histogram\fP is given a latency histogram will be tracked for
+If \fB--bounds\fP is given a latency histogram will be tracked for
 the new region. The boundaries of the histogram bins are given as a
 comma separated list of latency values. There is an implicit lower bound
 of zero on the first bin and an implicit upper bound of infinity (or the
@@ -369,40 +352,9 @@ Outputs a summary of the commands available, optionally including
 the list of report fields.
 .br
 .TP
-.B histogram
-.RB [ \-\-allprograms ]
-.RB [ \-\-interval
-.IR seconds ]
-.RB [ \-\-count
-.IR count ]
-.RB [ \-\-units
-.IR unit ]
-.RB [ \-\-relative ]
-.RB [ \-\-regionid
-.IR id ]
-.RB [ \-\-programid
-.IR id ]
-.RB [ \-O | \-\-sort
-.IR sort_fields ]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-\-units
-.IR units ]
-.br
-Start a report for the specified region or for all present regions that
-emphasizes latency histograms in the default field options. If the count
-argument is specified, the report will repeat at a fixed interval set by
-the \fB\-\-interval\fP option. The default interval is one second.
-
-If the \fB\-\-allprograms\fP switch is given, all regions will be
-listed, regardless of region program ID values.
-
-If \fB\-\-relative\fP is given the default histogram field displays the
-relative histogram instead of absolute counts.
-.br
-.TP
 .B list
 .RI [ device_name ]
+.RB [ \-\-histogram ]
 .RB [ \-\-allprograms ]
 .RB [ \-\-programid
 .RB [ \-v | \-\-verbose \ [ \-v | \-\-verbose ]]
@@ -414,6 +366,9 @@ regardless of region program ID values.
 
 If \fB\-v\fP or \fB\-\-verbose\fP is given the report will include
 a row of information for each area contained in each region displayed.
+
+If \fB\-\-histogram\fP is given the report will include the bin count
+and latency boundary values for any configured histograms.
 .br
 .TP
 .B print
@@ -456,6 +411,13 @@ one second.
 
 If the \fB\-\-allprograms\fP switch is given, all regions will be
 listed, regardless of region program ID values.
+
+If \fB\-\-histogram\fP is given the report will include the histogram
+values and latency boundaries.
+
+If \fB\-\-relative\fP is used the default histogram field displays
+bin values as a percentage of the total number of I/Os.
+
 .br
 .SH REGIONS AND AREAS
 The device-mapper statistics facility allows separate performance
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 432677b..8983e18 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -162,6 +162,7 @@ enum {
 	AREAS_ARG,
 	AREA_SIZE_ARG,
 	AUX_DATA_ARG,
+	BOUNDS_ARG,
 	CHECKS_ARG,
 	CLEAR_ARG,
 	COLS_ARG,
@@ -4234,6 +4235,8 @@ static const char *_stats_default_report_options = STATS_DEV_INFO "," STATS_AREA
 static const char *_stats_raw_report_options = STATS_DEV_INFO "," STATS_AREA_INFO "," COUNTERS;
 static const char *_stats_list_options = STATS_REGION_INFO ",program_id";
 static const char *_stats_area_list_options = STATS_AREA_INFO_FULL ",program_id";
+static const char *_stats_hist_list_options = STATS_REGION_INFO ",hist_bins,hist_bounds";
+static const char *_stats_hist_area_list_options = STATS_AREA_INFO_FULL ",hist_bins,hist_bounds";
 static const char *_stats_hist_options = STATS_HIST ",hist_count_bounds";
 static const char *_stats_hist_relative_options = STATS_HIST ",hist_percent_bounds";
 
@@ -4257,19 +4260,24 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 
 	if (cmd && !strcmp(cmd->name, "stats")) {
 		_report_type |= DR_STATS_META;
-		if (!strcmp(subcommand, "list"))
-			options = (char *) ((_switches[VERBOSE_ARG])
-					    ? _stats_area_list_options
-					    : _stats_list_options);
-		else if (!strcmp(subcommand, "histogram"))
-			options = (char *) ((_switches[RELATIVE_ARG])
-					    ? _stats_hist_relative_options
-					    : _stats_hist_options);
-		else {
-			options = (char *) ((!_switches[RAW_ARG])
-					    ? _stats_default_report_options
-					    : _stats_raw_report_options);
-
+		if (!strcmp(subcommand, "list")) {
+			if (!_switches[HISTOGRAM_ARG])
+				options = (char *) ((_switches[VERBOSE_ARG])
+						    ? _stats_area_list_options
+						    : _stats_list_options);
+			else
+				options = (char *) ((_switches[VERBOSE_ARG])
+						    ? _stats_hist_area_list_options
+						    : _stats_hist_list_options);
+		} else {
+			if (_switches[HISTOGRAM_ARG])
+				options = (char *) ((_switches[RELATIVE_ARG])
+						    ? _stats_hist_relative_options
+						    : _stats_hist_options);
+			else
+				options = (char *) ((!_switches[RAW_ARG])
+						    ? _stats_default_report_options
+						    : _stats_raw_report_options);
 			_report_type |= DR_STATS;
 		}
 	}
@@ -4657,7 +4665,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 				    const char *aux_data)
 {
 	uint64_t this_start = 0, this_len = len, region_id = UINT64_C(0);
-	const char *devname = NULL, *histogram = _string_args[HISTOGRAM_ARG];
+	const char *devname = NULL, *histogram = _string_args[BOUNDS_ARG];
 	int r = 0, precise = _switches[PRECISE_ARG];
 	struct dm_histogram *bounds = NULL; /* histogram bounds */
 	char *target_type, *params; /* unused */
@@ -4833,9 +4841,9 @@ static int _stats_create(CMD_ARGS)
 		}
 	}
 
-	if (_switches[HISTOGRAM_ARG]) {
+	if (_switches[BOUNDS_ARG]) {
 		if (!dm_stats_driver_supports_histogram()) {
-			log_error("Using --histogram requires driver version "
+			log_error("Using --bounds requires driver version "
 				  "4.32.0 or later.");
 			goto out;
 		}
@@ -5075,7 +5083,6 @@ static struct command _stats_subcommands[] = {
 	{"clear", "--regionid <id> [<device>]", 0, -1, 1, 0, _stats_clear},
 	{"create", CREATE_OPTS "\n\t\t" ID_OPTS "[<device>]", 0, -1, 1, 0, _stats_create},
 	{"delete", "--regionid <id> <device>", 1, -1, 1, 0, _stats_delete},
-	{"histogram", REPORT_OPTS "[<device>]", 0, -1, 1, 0, _stats_report},
 	{"list", "[--programid <id>] [<device>]", 0, -1, 1, 0, _stats_report},
 	{"print", PRINT_OPTS "[<device>]", 0, -1, 1, 0, _stats_print},
 	{"report", REPORT_OPTS "[<device>]", 0, -1, 1, 0, _stats_report},
@@ -5680,6 +5687,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"areas", 1, &ind, AREAS_ARG},
 		{"areasize", 1, &ind, AREA_SIZE_ARG},
 		{"auxdata", 1, &ind, AUX_DATA_ARG},
+		{"bounds", 1, &ind, BOUNDS_ARG},
 		{"checks", 0, &ind, CHECKS_ARG},
 		{"clear", 0, &ind, CLEAR_ARG},
 		{"columns", 0, &ind, COLS_ARG},
@@ -5690,7 +5698,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
 		{"help", 0, &ind, HELP_ARG},
-		{"histogram", 1, &ind, HISTOGRAM_ARG},
+		{"histogram", 0, &ind, HISTOGRAM_ARG},
 		{"inactive", 0, &ind, INACTIVE_ARG},
 		{"interval", 1, &ind, INTERVAL_ARG},
 		{"length", 1, &ind, LENGTH_ARG},
@@ -5831,9 +5839,9 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			return 0;
 		if (c == 'h' || ind == HELP_ARG)
 			_switches[HELP_ARG]++;
-		if (ind == HISTOGRAM_ARG) {
-			_switches[HISTOGRAM_ARG]++;
-			_string_args[HISTOGRAM_ARG] = optarg;
+		if (ind == BOUNDS_ARG) {
+			_switches[BOUNDS_ARG]++;
+			_string_args[BOUNDS_ARG] = optarg;
 		}
 		if (ind == CLEAR_ARG)
 			_switches[CLEAR_ARG]++;
@@ -5843,6 +5851,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[FORCE_ARG]++;
 		if (c == 'r' || ind == READ_ONLY)
 			_switches[READ_ONLY]++;
+		if (ind == HISTOGRAM_ARG)
+			_switches[HISTOGRAM_ARG]++;
 		if (ind == LENGTH_ARG) {
 			_switches[LENGTH_ARG]++;
 			_string_args[LENGTH_ARG] = optarg;



From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  2 Sep 2015 20:03:26 +0000 (UTC)
Subject: master - dmstats: add histogram support
Message-ID: <20150902200326.623E46100C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c0fc6f0dad6489c7530d3b844e6db3c9ac620cf
Commit:        3c0fc6f0dad6489c7530d3b844e6db3c9ac620cf
Parent:        a0cf3d47f1747d64a0d54027903ddea1c858793c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Aug 18 12:40:03 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Sep 2 21:02:12 2015 +0100

dmstats: add histogram support

Add support to dmstats to create and report histograms.

Add a --histogram switch to 'create' that accepts a string
description of bin boundaries and DR_STATS and DR_STATS_META fields
to report bin configuration and absolute and relative histogram
values:

  hist_bins
  hist_bounds
  hist_ranges
  hist_count
  hist_count_bounds
  hist_count_ranges
  hist_percent
  hist_percent_bounds
  hist_percent_ranges

A new 'histogram' subcommand displays a report that emphasizes
histogram data as either counters or percentage values.
---
 WHATS_NEW_DM     |    2 +
 man/dmstats.8.in |  154 ++++++++++++++++++++++++++++++++++++++++
 tools/dmsetup.c  |  208 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 356 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b361b3e..6852e61 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -4,6 +4,8 @@ Version 1.02.107 -
 
 Version 1.02.106 - 26th August 2015
 ===================================
+  Add basic report fields for displaying latency histogram data.
+  Add dmstats --histogram to specify histogram boundaries for a region.
   Add public methods to libdm-stats to access numerical histogram data.
   Add the ability to parse histogram data into numeric form to libdm-stats.
   Add 'precise' column to statistics reports.
diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index ad5f952..be7fb11 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -32,6 +32,8 @@ dmstats \(em device-mapper statistics management
 .IR nr_areas ]
 .RB |[ \-\-areasize
 .IR area_size ]]
+.RB [ \-\-histogram
+.IR boundaries ]
 .RB [ \-\-precise ]
 .RB [[ \-\-start
 .IR start_sector ]
@@ -56,6 +58,28 @@ dmstats \(em device-mapper statistics management
 .B dmstats help
 .RB [ \-c | \-C | \-\-columns ]
 .br
+.B dmstats histogram
+.RI [ device_name ]
+.RB [ \-\-interval
+.IR seconds ]
+.RB [ \-\-count
+.IR count ]
+.RB [ \-\-units
+.IR units ]
+.RB [ \-\-allprograms ]
+.RB [ \-\-programid
+.IR id ]
+.RB [ \-\-relative ]
+.RB [ \-\-regionid
+.IR id ]
+.RB [ \-O | \-\-sort
+.IR sort_fields ]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB [ \-\-units
+.IR units ]
+.RB [ \-\-nosuffix ]
+.br
 .B dmstats list
 .RI [ device_name ]
 .RB [ \-\-allprograms
@@ -154,6 +178,13 @@ When printing statistics counters, also atomically reset them to zero.
 Specify the iteration count for repeating reports. If the count
 argument is zero reports will continue to repeat until interrupted.
 .TP
+.B \-\-histogram \fIboundaries
+Specify the boundaries of a latency histogram to be tracked for the
+region as a comma separated list of latency values. Latency values are
+given in nanoseconds. An optional unit suffix of ns, us, ms, or s may be
+given after each value to specify units of nanoseconds, microseconds,
+miliseconds or seconds respectively.
+.TP
 .B \-\-interval \fIseconds
 Specify the interval in seconds between successive iterations for
 repeating reports. If \-\-interval is specified but \-\-count is not,
@@ -192,6 +223,10 @@ string is stored with the region. Subsequent operations may supply a
 program ID in order to select only regions with a matching value. The
 default program ID for dmstats-managed regions is "dmstats".
 .TP
+.BR \-\-relative
+If displaying the histogram report show relative (percentage) values
+instead of absolute counts.
+.TP
 .BR \-S | \-\-select \ \fIselection
 Display only rows that match selection criteria. All rows with the
 additional "selected" column (-o selected) showing 1 if the row matches
@@ -245,6 +280,8 @@ regions (with the exception of in-flight IO counters).
 .IR nr_areas ]
 .RB [ \-\-areasize
 .IR area_size ]
+.RB [ \-\-histogram
+.IR boundaries ]
 .RB [ \-\-precise ]
 .RB [[ \-\-start
 .IR start_sector ]
@@ -268,6 +305,20 @@ device-mapper device's table.
 If the \fB\-\-precise\fP option is used the command will attempt to
 create a region using nanosecond precision counters.
 
+If \fB\-\-histogram\fP is given a latency histogram will be tracked for
+the new region. The boundaries of the histogram bins are given as a
+comma separated list of latency values. There is an implicit lower bound
+of zero on the first bin and an implicit upper bound of infinity (or the
+configured interval duration) on the final bin.
+
+Latencies are given in nanoseconds. An optional unit suffix of ns, us,
+ms, or s may be given after each value to specify units of nanoseconds,
+microseconds, miliseconds or seconds respectively, so for example, 10ms
+is equivalent to 10000000. Latency values with a precision of less than
+one milisecond can only be used when precise timestamps are enabled: if
+\fB\-\-precise\fP is not given and values less than one milisecond are
+used it will be enabled automatically.
+
 An optional \fBprogram_id\fP or \fBaux_data\fP string may be associated
 with the region. A \fBprogram_id\fP may then be used to select regions
 for subsequent list, print, and report operations. The \fBaux_data\fP
@@ -309,6 +360,38 @@ Outputs a summary of the commands available, optionally including
 the list of report fields.
 .br
 .TP
+.B histogram
+.RB [ \-\-allprograms ]
+.RB [ \-\-interval
+.IR seconds ]
+.RB [ \-\-count
+.IR count ]
+.RB [ \-\-units
+.IR unit ]
+.RB [ \-\-relative ]
+.RB [ \-\-regionid
+.IR id ]
+.RB [ \-\-programid
+.IR id ]
+.RB [ \-O | \-\-sort
+.IR sort_fields ]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB [ \-\-units
+.IR units ]
+.br
+Start a report for the specified region or for all present regions that
+emphasizes latency histograms in the default field options. If the count
+argument is specified, the report will repeat at a fixed interval set by
+the \fB\-\-interval\fP option. The default interval is one second.
+
+If the \fB\-\-allprograms\fP switch is given, all regions will be
+listed, regardless of region program ID values.
+
+If \fB\-\-relative\fP is given the default histogram field displays the
+relative histogram instead of absolute counts.
+.br
+.TP
 .B list
 .RI [ device_name ]
 .RB [ \-\-allprograms ]
@@ -592,6 +675,77 @@ the number of milliseconds spent doing I/O since the last update of this
 field.  This can provide an easy measure of both I/O completion time and
 the backlog that may be accumulating.
 .br
+.SS Histogram fields
+Histograms measure the frequency distribution of user specified I/O
+latency intervals. Histogram bin boundaries are specified when a region
+is created.
+
+A brief representation of the histogram values and latency intervals can
+be included in the report using these fields.
+.P
+.HP
+.B hist_count
+.br
+A list of the histogram counts for the current statistics area in order
+of ascending latency value. Each value represents the number of I/Os
+with latency times falling into that bin's time range during the sample
+period.
+.HP
+.B hist_count_bounds
+.br
+A list of the histogram counts for the current statistics area in order
+of ascending latency value including bin boundaries: each count is
+prefixed by the lower bound of the corresponding histogram bin.
+.HP
+.B hist_count_ranges
+.br
+A list of the histogram counts for the current statistics area in order
+of ascending latency value including bin boundaries: each count is
+prefixed by both the lower and upper bounds of the corresponding
+histogram bin.
+.HP
+.B hist_percent
+.br
+A list of the relative histogram values for the current statistics area
+in order of ascending latency value, expressed as a percentage. Each
+value represents the proportion of I/Os with latency times falling into
+that bin's time range during the sample period.
+.HP
+.B hist_percent_bounds
+.br
+A list of the relative histogram values for the current statistics area
+in order of ascending latency value, expressed as a percentage and
+including bin boundaries. Each value represents the proportion of I/Os
+with latency times falling into that bin's time range during the sample
+period and is prefixed with the corresponding bin's lower bound.
+.HP
+.B hist_percent_ranges
+.br
+A list of the relative histogram values for the current statistics area
+in order of ascending latency value, expressed as a percentage and
+including bin boundaries. Each value represents the proportion of I/Os
+with latency times falling into that bin's time range during the sample
+period and is prefixed with the corresponding bin's lower and upper
+bounds.
+.HP
+.B hist_bounds
+.br
+A list of the histogram boundary values for the current statistics area
+in order of ascending latency value.  The values are expressed in whole
+units of seconds, miliseconds, microseconds or nanoseconds with a suffix
+indicating the unit.
+.HP
+.B hist_ranges
+.br
+A list of the histogram bin ranges for the current statistics area in
+order of ascending latency value.  The values are expressed as
+"LOWER-UPPER" in whole units of seconds, miliseconds, microseconds or
+nanoseconds with a suffix indicating the unit.
+.HP
+.B hist_bins
+.br
+The number of latency histogram bins configured for the area.
+.br
 .br
 .P
 .SH EXAMPLES
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 976d9e3..bffeb7f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -172,6 +172,7 @@ enum {
 	FORCE_ARG,
 	GID_ARG,
 	HELP_ARG,
+	HISTOGRAM_ARG,
 	INACTIVE_ARG,
 	INTERVAL_ARG,
 	LENGTH_ARG,
@@ -195,6 +196,7 @@ enum {
 	RAW_ARG,
 	READAHEAD_ARG,
 	REGION_ID_ARG,
+	RELATIVE_ARG,
 	RETRY_ARG,
 	ROWS_ARG,
 	SEPARATOR_ARG,
@@ -3436,6 +3438,153 @@ static int _dm_stats_precise_disp(struct dm_report *rh,
 	return dm_report_field_int(rh, field, (const int *) &precise);
 }
 
+static const char *_get_histogram_string(const struct dm_stats *dms, int rel,
+					 int vals, int bounds)
+{
+	const struct dm_histogram *dmh;
+	int flags = 0;
+
+	if (!(dmh = dm_stats_get_histogram(dms, DM_STATS_REGION_CURRENT,
+					   DM_STATS_AREA_CURRENT)))
+		return ""; /* No histogram. */
+
+	flags |= (vals) ? DM_HISTOGRAM_VALUES
+			: 0;
+
+	flags |= bounds;
+
+	flags |= (rel) ? DM_HISTOGRAM_PERCENT
+			: 0;
+
+	flags |= DM_HISTOGRAM_SUFFIX;
+
+	/* FIXME: make unit conversion optional. */
+	return dm_histogram_to_string(dmh, -1, 0, flags);
+}
+
+static int _stats_hist_count_disp(struct dm_report *rh,
+				  struct dm_report_field *field, const void *data,
+				  int bounds)
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	const char *histogram;
+
+	histogram = _get_histogram_string(dms, 0, 1, bounds); /* counts */
+
+	if (!histogram)
+		return_0;
+
+	return dm_report_field_string(rh, field, (const char * const *) &histogram);
+}
+
+static int _dm_stats_hist_count_disp(struct dm_report *rh,
+				     struct dm_pool *mem __attribute__((unused)),
+				     struct dm_report_field *field, const void *data,
+				     void *private __attribute__((unused)))
+{
+	return _stats_hist_count_disp(rh, field, data, 0);
+}
+
+static int _dm_stats_hist_count_bounds_disp(struct dm_report *rh,
+					    struct dm_pool *mem __attribute__((unused)),
+					    struct dm_report_field *field, const void *data,
+					    void *private __attribute__((unused)))
+{
+	return _stats_hist_count_disp(rh, field, data, DM_HISTOGRAM_BOUNDS_LOWER);
+}
+
+static int _dm_stats_hist_count_ranges_disp(struct dm_report *rh,
+					    struct dm_pool *mem __attribute__((unused)),
+					    struct dm_report_field *field, const void *data,
+					    void *private __attribute__((unused)))
+{
+	return _stats_hist_count_disp(rh, field, data, DM_HISTOGRAM_BOUNDS_RANGE);
+}
+
+static int _stats_hist_percent_disp(struct dm_report *rh,
+				    struct dm_report_field *field, const void *data,
+				    int bounds)
+{
+
+	/* FIXME: configurable to-string options. */
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	const char *histogram;
+
+	histogram = _get_histogram_string(dms, 1, 1, bounds); /* relative values */
+
+	if (!histogram)
+		return_0;
+
+	return dm_report_field_string(rh, field, (const char * const *) &histogram);
+}
+
+static int _dm_stats_hist_percent_disp(struct dm_report *rh,
+				       struct dm_pool *mem __attribute__((unused)),
+				       struct dm_report_field *field, const void *data,
+				       void *private __attribute__((unused)))
+{
+	return _stats_hist_percent_disp(rh, field, data, 0);
+}
+
+static int _dm_stats_hist_percent_bounds_disp(struct dm_report *rh,
+					      struct dm_pool *mem __attribute__((unused)),
+					      struct dm_report_field *field, const void *data,
+					      void *private __attribute__((unused)))
+{
+	return _stats_hist_percent_disp(rh, field, data, DM_HISTOGRAM_BOUNDS_LOWER);
+}
+
+static int _dm_stats_hist_percent_ranges_disp(struct dm_report *rh,
+					      struct dm_pool *mem __attribute__((unused)),
+					      struct dm_report_field *field, const void *data,
+					      void *private __attribute__((unused)))
+{
+	return _stats_hist_percent_disp(rh, field, data, DM_HISTOGRAM_BOUNDS_RANGE);
+}
+
+static int _stats_hist_bounds_disp(struct dm_report *rh,
+				   struct dm_report_field *field, const void *data,
+				   int bounds)
+{
+	/* FIXME: configurable to-string options. */
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	const char *histogram;
+
+	histogram = _get_histogram_string(dms, 0, 0, bounds);
+
+	if (!histogram)
+		return_0;
+
+	return dm_report_field_string(rh, field, (const char * const *) &histogram);
+}
+
+static int _dm_stats_hist_bounds_disp(struct dm_report *rh,
+				      struct dm_pool *mem __attribute__((unused)),
+				      struct dm_report_field *field, const void *data,
+				      void *private __attribute__((unused)))
+{
+	return _stats_hist_bounds_disp(rh, field, data, DM_HISTOGRAM_BOUNDS_LOWER);
+}
+
+static int _dm_stats_hist_ranges_disp(struct dm_report *rh,
+				      struct dm_pool *mem __attribute__((unused)),
+				      struct dm_report_field *field, const void *data,
+				      void *private __attribute__((unused)))
+{
+	return _stats_hist_bounds_disp(rh, field, data, DM_HISTOGRAM_BOUNDS_RANGE);
+}
+
+static int _dm_stats_hist_bins_disp(struct dm_report *rh,
+				   struct dm_pool *mem __attribute__((unused)),
+				   struct dm_report_field *field, const void *data,
+				   void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	int bins;
+	bins = dm_stats_get_region_nr_histogram_bins(dms, DM_STATS_REGION_CURRENT);
+	return dm_report_field_int(rh, field, (const int *) &bins);
+}
+
 static int _dm_stats_rrqm_disp(struct dm_report *rh,
 			       struct dm_pool *mem __attribute__((unused)),
 			       struct dm_report_field *field, const void *data,
@@ -4017,6 +4166,14 @@ FIELD_F(STATS, NUM, "TPut", 5, dm_stats_tput, "tput", "Throughput.")
 FIELD_F(STATS, NUM, "SvcTm", 5, dm_stats_svctm, "svctm", "Service time.")
 FIELD_F(STATS, NUM, "Util%", 5, dm_stats_util, "util", "Utilization.")
 
+/* Histogram fields */
+FIELD_F(STATS, STR, "Histogram Counts", 16, dm_stats_hist_count, "hist_count", "Latency histogram counts.")
+FIELD_F(STATS, STR, "Histogram Counts", 16, dm_stats_hist_count_bounds, "hist_count_bounds", "Latency histogram counts with bin boundaries.")
+FIELD_F(STATS, STR, "Histogram Counts", 16, dm_stats_hist_count_ranges, "hist_count_ranges", "Latency histogram counts with bin ranges.")
+FIELD_F(STATS, STR, "Histogram%", 10, dm_stats_hist_percent, "hist_percent", "Relative latency histogram.")
+FIELD_F(STATS, STR, "Histogram%", 10, dm_stats_hist_percent_bounds, "hist_percent_bounds", "Relative latency histogram with bin boundaries.")
+FIELD_F(STATS, STR, "Histogram%", 10, dm_stats_hist_percent_ranges, "hist_percent_ranges", "Relative latency histogram with bin ranges.")
+
 /* Stats interval duration estimates */
 FIELD_F(STATS, NUM, "IntervalNSec", 10, dm_stats_sample_interval_ns, "interval_ns", "Sampling interval in nanoseconds.")
 FIELD_F(STATS, NUM, "Interval", 8, dm_stats_sample_interval, "interval", "Sampling interval.")
@@ -4032,7 +4189,10 @@ FIELD_F(STATS_META, SIZ, "AOff", 5, dm_stats_area_offset, "area_offset", "Area o
 FIELD_F(STATS_META, NUM, "#Areas", 3, dm_stats_area_count, "area_count", "Area count.")
 FIELD_F(STATS_META, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
 FIELD_F(STATS_META, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
-FIELD_F(STATS_META, STR, "Precise", 5, dm_stats_precise, "precise", "Set if the nanosecond precision timers are enabled.")
+FIELD_F(STATS_META, STR, "Precise", 7, dm_stats_precise, "precise", "Set if nanosecond precision counters are enabled.")
+FIELD_F(STATS_META, STR, "#Bins", 9, dm_stats_hist_bins, "hist_bins", "The number of histogram bins configured.")
+FIELD_F(STATS_META, STR, "Histogram Bounds", 16, dm_stats_hist_bounds, "hist_bounds", "Latency histogram bin boundaries.")
+FIELD_F(STATS_META, STR, "Histogram Ranges", 16, dm_stats_hist_ranges, "hist_ranges", "Latency histogram bin ranges.")
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };
@@ -4056,14 +4216,20 @@ static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
 
 /* Device, region and area metadata. */
 #define STATS_DEV_INFO "name,region_id"
-#define STATS_AREA_INFO STATS_DEV_INFO ",region_start,region_len,area_count,area_id,area_start,area_len"
+#define STATS_AREA_INFO "area_id,area_start,area_len"
+#define STATS_AREA_INFO_FULL STATS_DEV_INFO ",region_start,region_len,area_count,area_id,area_start,area_len"
 #define STATS_REGION_INFO STATS_DEV_INFO ",region_start,region_len,area_count,area_len"
 
+/* Minimal set of fields for histogram report. */
+#define STATS_HIST STATS_REGION_INFO ",util,await"
+
 /* Default stats report options. */
-static const char *_stats_default_report_options = STATS_DEV_INFO ",area_id,area_start,area_len," METRICS;
-static const char *_stats_raw_report_options = STATS_DEV_INFO ",area_id,area_start,area_len," COUNTERS;
+static const char *_stats_default_report_options = STATS_DEV_INFO "," STATS_AREA_INFO "," METRICS;
+static const char *_stats_raw_report_options = STATS_DEV_INFO "," STATS_AREA_INFO "," COUNTERS;
 static const char *_stats_list_options = STATS_REGION_INFO ",program_id";
-static const char *_stats_area_list_options = STATS_AREA_INFO ",program_id";
+static const char *_stats_area_list_options = STATS_AREA_INFO_FULL ",program_id";
+static const char *_stats_hist_options = STATS_HIST ",hist_count_bounds";
+static const char *_stats_hist_relative_options = STATS_HIST ",hist_percent_bounds";
 
 static int _report_init(const struct command *cmd, const char *subcommand)
 {
@@ -4089,6 +4255,10 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 			options = (char *) ((_switches[VERBOSE_ARG])
 					    ? _stats_area_list_options
 					    : _stats_list_options);
+		else if (!strcmp(subcommand, "histogram"))
+			options = (char *) ((_switches[RELATIVE_ARG])
+					    ? _stats_hist_relative_options
+					    : _stats_hist_options);
 		else {
 			options = (char *) ((!_switches[RAW_ARG])
 					    ? _stats_default_report_options
@@ -4481,12 +4651,16 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 				    const char *aux_data)
 {
 	uint64_t this_start = 0, this_len = len, region_id = UINT64_C(0);
+	const char *devname = NULL, *histogram = _string_args[HISTOGRAM_ARG];
+	int r = 0, precise = _switches[PRECISE_ARG];
+	struct dm_histogram *bounds = NULL; /* histogram bounds */
 	char *target_type, *params; /* unused */
 	struct dm_task *dmt;
 	struct dm_info info;
 	void *next = NULL;
-	const char *devname = NULL;
-	int r = 0, precise = _switches[PRECISE_ARG];
+
+	if (histogram && !(bounds = dm_histogram_bounds_from_string(histogram)))
+		return 0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TABLE))) {
 		dm_stats_destroy(dms);
@@ -4533,7 +4707,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 			this_len = (segments) ? segment_len : this_len;
 			if (!dm_stats_create_region(dms, &region_id,
 						    this_start, this_len, step,
-						    precise, NULL,
+						    precise, bounds,
 						    program_id, aux_data)) {
 				log_error("%s: Could not create statistics region.",
 					  devname);
@@ -4550,6 +4724,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 out:
 	dm_task_destroy(dmt);
 	dm_stats_destroy(dms);
+	dm_histogram_bounds_destroy(bounds);
 	return r;
 }
 
@@ -4652,6 +4827,14 @@ static int _stats_create(CMD_ARGS)
 		}
 	}
 
+	if (_switches[HISTOGRAM_ARG]) {
+		if (!dm_stats_driver_supports_histogram()) {
+			log_error("Using --histogram requires driver version "
+				  "4.32.0 or later.");
+			goto out;
+		}
+	}
+
 	if (!strlen(program_id))
 		/* force creation of a region with no id */
 		dm_stats_set_program_id(dms, 1, NULL);
@@ -4886,6 +5069,7 @@ static struct command _stats_subcommands[] = {
 	{"clear", "--regionid <id> [<device>]", 0, -1, 1, 0, _stats_clear},
 	{"create", CREATE_OPTS "\n\t\t" ID_OPTS "[<device>]", 0, -1, 1, 0, _stats_create},
 	{"delete", "--regionid <id> <device>", 1, -1, 1, 0, _stats_delete},
+	{"histogram", REPORT_OPTS "[<device>]", 0, -1, 1, 0, _stats_report},
 	{"list", "[--programid <id>] [<device>]", 0, -1, 1, 0, _stats_report},
 	{"print", PRINT_OPTS "[<device>]", 0, -1, 1, 0, _stats_print},
 	{"report", REPORT_OPTS "[<device>]", 0, -1, 1, 0, _stats_report},
@@ -5500,6 +5684,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
 		{"help", 0, &ind, HELP_ARG},
+		{"histogram", 1, &ind, HISTOGRAM_ARG},
 		{"inactive", 0, &ind, INACTIVE_ARG},
 		{"interval", 1, &ind, INTERVAL_ARG},
 		{"length", 1, &ind, LENGTH_ARG},
@@ -5523,6 +5708,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"raw", 0, &ind, RAW_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
 		{"regionid", 1, &ind, REGION_ID_ARG},
+		{"relative", 0, &ind, RELATIVE_ARG},
 		{"retry", 0, &ind, RETRY_ARG},
 		{"rows", 0, &ind, ROWS_ARG},
 		{"segments", 0, &ind, SEGMENTS_ARG},
@@ -5638,6 +5824,10 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			return 0;
 		if (c == 'h' || ind == HELP_ARG)
 			_switches[HELP_ARG]++;
+		if (ind == HISTOGRAM_ARG) {
+			_switches[HISTOGRAM_ARG]++;
+			_string_args[HISTOGRAM_ARG] = optarg;
+		}
 		if (ind == CLEAR_ARG)
 			_switches[CLEAR_ARG]++;
 		if (c == 'c' || c == 'C' || ind == COLS_ARG)
@@ -5678,6 +5868,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[REGION_ID_ARG]++;
 			_int_args[REGION_ID_ARG] = atoi(optarg);
 		}
+		if (ind == RELATIVE_ARG)
+			_switches[RELATIVE_ARG]++;
 		if (ind == SEPARATOR_ARG) {
 			_switches[SEPARATOR_ARG]++;
 			_string_args[SEPARATOR_ARG] = optarg;



From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  2 Sep 2015 19:49:51 +0000 (UTC)
Subject: master - libdm: add latency histogram support
Message-ID: <20150902194951.8EF0D60E15@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0cf3d47f1747d64a0d54027903ddea1c858793c
Commit:        a0cf3d47f1747d64a0d54027903ddea1c858793c
Parent:        c4f3732c918c9d26fdaca42acdc92a02898dbe35
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Aug 19 20:39:10 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Sep 2 20:48:59 2015 +0100

libdm: add latency histogram support

Add support for creating, parsing, and reporting dm-stats latency
histograms on kernels that support precise_timestamps.

Histograms are specified as a series of time values that give the
boundaries of the bins into which I/O counts accumulate (with
implicit lower and upper bounds on the first and last bins).

A new type, struct dm_histogram, is introduced to represent
histogram values and bin boundaries.

The boundary values may be given as either a string of values (with
optional unit suffixes) or as a zero terminated array of uint64_t
values expressing boundary times in nanoseconds.

A new bounds argument is added to dm_stats_create_region() which
accepts a pointer to a struct dm_histogram initialised with bounds
values.

Histogram data associated with a region is parsed during a call to
dm_stats_populate() and used to build a table of histogram values
that are pointed to from the containing area's counter set. The
histogram for a specified area may then be obtained and interogated
for values and properties.

This relies on kernel support to provide the boundary values in
a @stats_list response: this will be present in 4.3 and 4.2-stable. A
check for a minimum driver version of 4.33.0 is implemented to ensure
that this is present (4.32.0 has the necessary precise_timestamps and
histogram features but is unable to report these via @stats_list).

Access methods are provided to retrieve histogram values and bounds
as well as simple string representations of the counts and bin
boundaries.  Methods are also available to return the total count
for a histogram and the relative value (as a dm_percent_t) of a
specified bin.
---
 WHATS_NEW_DM                        |    2 +
 libdm/.exported_symbols.DM_1_02_107 |   15 +
 libdm/libdevmapper.h                |  225 +++++++++-
 libdm/libdm-stats.c                 |  877 +++++++++++++++++++++++++++++++++--
 tools/dmsetup.c                     |    2 +-
 5 files changed, 1064 insertions(+), 57 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ba89a9d..b361b3e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -4,6 +4,8 @@ Version 1.02.107 -
 
 Version 1.02.106 - 26th August 2015
 ===================================
+  Add public methods to libdm-stats to access numerical histogram data.
+  Add the ability to parse histogram data into numeric form to libdm-stats.
   Add 'precise' column to statistics reports.
   Add --precise switch to 'dmstats create' to request nanosecond counters.
   Add precise argument to dm_stats_create_region().
diff --git a/libdm/.exported_symbols.DM_1_02_107 b/libdm/.exported_symbols.DM_1_02_107
new file mode 100644
index 0000000..89d3464
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_107
@@ -0,0 +1,15 @@
+dm_histogram_bounds_destroy
+dm_histogram_bounds_from_string
+dm_histogram_bounds_from_uint64
+dm_histogram_get_bin_count
+dm_histogram_get_bin_lower
+dm_histogram_get_bin_percent
+dm_histogram_get_bin_upper
+dm_histogram_get_bin_width
+dm_histogram_get_nr_bins
+dm_histogram_get_sum
+dm_histogram_to_string
+dm_stats_create_region
+dm_stats_driver_supports_histogram
+dm_stats_get_histogram
+dm_stats_get_region_nr_histogram_bins
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 59eb5e9..c81a9e5 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -434,6 +434,19 @@ int dm_get_status_thin(struct dm_pool *mem, const char *params,
 struct dm_stats;
 
 /*
+ * Histogram handle.
+ *
+ * A histogram object represents the latency histogram values and bin
+ * boundaries of the histogram associated with a particular area.
+ *
+ * Operations on the handle allow the number of bins, bin boundaries,
+ * counts and relative proportions to be obtained as well as the
+ * conversion of a histogram or its bounds to a compact string
+ * representation.
+ */
+struct dm_histogram;
+
+/*
  * Allocate a dm_stats handle to use for subsequent device-mapper
  * statistics operations. A program_id may be specified and will be
  * used by default for subsequent operations on this handle.
@@ -474,11 +487,12 @@ int dm_stats_bind_uuid(struct dm_stats *dms, const char *uuid);
 int dm_message_supports_precise_timestamps(void);
 
 /*
- * Precise timetamps support.
+ * Precise timetamps and histogram support.
  * 
- * Test for the presence of precise_timestamps support.
+ * Test for the presence of precise_timestamps and histogram support.
  */
 int dm_stats_driver_supports_precise(void);
+int dm_stats_driver_supports_histogram(void);
 
 /*
  * Returns 1 if the specified region has the precise_timestamps feature
@@ -561,6 +575,28 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
  * If precise is non-zero attempt to create a region with nanosecond
  * precision counters using the kernel precise_timestamps feature.
  *
+ * precise - A flag to request nanosecond precision counters
+ * to be used for this region.
+ *
+ * histogram_bounds - specify the boundaries of a latency histogram to
+ * be tracked for the region. The values are expressed as an array of
+ * uint64_t terminated with a zero. Values must be in order of ascending
+ * magnitude and specify the upper bounds of successive histogram bins
+ * in nanoseconds (with an implicit lower bound of zero on the first bin
+ * and an implicit upper bound of infinity on the final bin). For
+ * example:
+ *
+ *   uint64_t bounds_ary[] = { 1000, 2000, 3000, 0 };
+ *
+ * Specifies a histogram with four bins: 0-1000ns, 1000-2000ns,
+ * 2000-3000ns and >3000ns.
+ *
+ * The smallest latency value that can be tracked for a region not using
+ * precise_timestamps is 1ms: attempting to create a region with
+ * histogram boundaries < 1ms will cause the precise_timestamps feature
+ * to be enabled for that region automatically if it was not requested
+ * explicitly.
+ *
  * program_id is an optional string argument that identifies the
  * program creating the region. If program_id is NULL or the empty
  * string the default program_id stored in the handle will be used.
@@ -574,7 +610,7 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
  */
 int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 			   uint64_t start, uint64_t len, int64_t step,
-			   int precise,
+			   int precise, struct dm_histogram *bounds,
 			   const char *program_id, const char *aux_data);
 
 /*
@@ -660,8 +696,74 @@ uint64_t dm_stats_get_region_nr_areas(const struct dm_stats *dms,
 uint64_t dm_stats_get_nr_areas(const struct dm_stats *dms);
 
 /*
- * Destroy a dm_stats object and all associated regions and counter
- * sets.
+ * Return the number of bins in the histogram configuration for the
+ * specified region or zero if no histogram specification is configured.
+ * Valid following a dm_stats_list() or dm_stats_populate() operation.
+ */
+int dm_stats_get_region_nr_histogram_bins(const struct dm_stats *dms,
+					  uint64_t region_id);
+
+/*
+ * Parse a histogram string with optional unit suffixes into a
+ * dm_histogram bounds description.
+ *
+ * A histogram string is a string of numbers "n1,n2,n3,..." that
+ * represent the boundaries of a histogram. The first and final bins
+ * have implicit lower and upper bounds of zero and infinity
+ * respectively and boundary values must occur in order of ascending
+ * magnitude.  Unless a unit suffix is given all values are specified in
+ * nanoseconds.
+ *
+ * For example, if bounds_str="300,600,900", the region will be created
+ * with a histogram containing four bins. Each report will include four
+ * numbers a:b:c:d. a is the number of requests that took between 0 and
+ * 300ns to complete, b is the number of requests that took 300-600ns to
+ * complete, c is the number of requests that took 600-900ns to complete
+ * and d is the number of requests that took more than 900ns to
+ * complete.
+ *
+ * An optional unit suffix of 's', 'ms', 'us', or 'ns' may be used to
+ * specify units of seconds, miliseconds, microseconds, or nanoseconds:
+ *
+ *   bounds_str="1ns,1us,1ms,1s"
+ *   bounds_str="500us,1ms,1500us,2ms"
+ *   bounds_str="200ms,400ms,600ms,800ms,1s"
+ *
+ * The smallest valid unit of time for a histogram specification depends
+ * on whether the region uses precise timestamps: for a region with the
+ * default milisecond precision the smallest possible histogram boundary
+ * magnitude is one milisecond: attempting to use a histogram with a
+ * boundary less than one milisecond when creating a region will cause
+ * the region to be created with the precise_timestamps feature enabled.
+ */
+struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str);
+
+/*
+ * Parse a zero terminated array of uint64_t into a dm_histogram bounds
+ * description.
+ *
+ * Each value in the array specifies the upper bound of a bin in the
+ * latency histogram in nanoseconds. Values must appear in ascending
+ * order of magnitude.
+ *
+ * The smallest valid unit of time for a histogram specification depends
+ * on whether the region uses precise timestamps: for a region with the
+ * default milisecond precision the smallest possible histogram boundary
+ * magnitude is one milisecond: attempting to use a histogram with a
+ * boundary less than one milisecond when creating a region will cause
+ * the region to be created with the precise_timestamps feature enabled.
+ */
+struct dm_histogram *dm_histogram_bounds_from_uint64(const uint64_t *bounds);
+
+/*
+ * Destroy the histogram bounds array obtained from a call to
+ * dm_histogram_bounds_from_string().
+ */
+void dm_histogram_bounds_destroy(struct dm_histogram *bounds);
+
+/*
+ * Destroy a dm_stats object and all associated regions, counter
+ * sets and histograms.
  */
 void dm_stats_destroy(struct dm_stats *dms);
 
@@ -2643,6 +2745,119 @@ int dm_stats_get_throughput(const struct dm_stats *dms, double *tput,
 int dm_stats_get_utilization(const struct dm_stats *dms, dm_percent_t *util,
 			     uint64_t region_id, uint64_t area_id);
 
+/*
+ * Statistics histogram access methods.
+ *
+ * Methods to access latency histograms for regions that have them
+ * enabled. Each histogram contains a configurable number of bins
+ * spanning a user defined latency interval.
+ *
+ * The bin count, upper and lower bin bounds, and bin values are
+ * made available via the following area methods.
+ *
+ * Methods to obtain a simple string representation of the histogram
+ * and its bounds are also provided.
+ */
+
+/*
+ * Retrieve a pointer to the histogram associated with the specified
+ * area. If the area does not have a histogram configured this function
+ * returns NULL.
+ *
+ * The pointer does not need to be freed explicitly by the caller: it
+ * will become invalid following a subsequent dm_stats_list(),
+ * dm_stats_populate() or dm_stats_destroy() of the corresponding
+ * dm_stats handle.
+ *
+ * If region_id or area_id is one of the special values
+ * DM_STATS_REGION_CURRENT or DM_STATS_AREA_CURRENT the current cursor
+ * value is used to select the region or area.
+ */
+struct dm_histogram *dm_stats_get_histogram(const struct dm_stats *dms,
+					    uint64_t region_id,
+					    uint64_t area_id);
+
+/*
+ * Return the number of bins in the specified histogram handle.
+ */
+int dm_histogram_get_nr_bins(const struct dm_histogram *dmh);
+
+/*
+ * Get the lower bound of the specified bin of the histogram for the
+ * area specified by region_id and area_id. The value is returned in
+ * nanoseconds.
+ */
+uint64_t dm_histogram_get_bin_lower(const struct dm_histogram *dmh, int bin);
+
+/*
+ * Get the upper bound of the specified bin of the histogram for the
+ * area specified by region_id and area_id. The value is returned in
+ * nanoseconds.
+ */
+uint64_t dm_histogram_get_bin_upper(const struct dm_histogram *dmh, int bin);
+
+/*
+ * Get the width of the specified bin of the histogram for the area
+ * specified by region_id and area_id. The width is equal to the bin
+ * upper bound minus the lower bound and yields the range of latency
+ * values covered by this bin. The value is returned in nanoseconds.
+ */
+uint64_t dm_histogram_get_bin_width(const struct dm_histogram *dmh, int bin);
+
+/*
+ * Get the value of the specified bin of the histogram for the area
+ * specified by region_id and area_id.
+ */
+uint64_t dm_histogram_get_bin_count(const struct dm_histogram *dmh, int bin);
+
+/*
+ * Get the percentage (relative frequency) of the specified bin of the
+ * histogram for the area specified by region_id and area_id.
+ */
+dm_percent_t dm_histogram_get_bin_percent(const struct dm_histogram *dmh,
+					  int bin);
+
+/*
+ * Return the total observations (sum of bin counts) for the histogram
+ * of the area specified by region_id and area_id.
+ */
+uint64_t dm_histogram_get_sum(const struct dm_histogram *dmh);
+
+/*
+ * Histogram formatting flags.
+ */
+#define DM_HISTOGRAM_VALUES  0x1
+#define DM_HISTOGRAM_SUFFIX  0x2
+#define DM_HISTOGRAM_PERCENT 0X4
+#define DM_HISTOGRAM_BOUNDS_LOWER 0x10
+#define DM_HISTOGRAM_BOUNDS_UPPER 0x20
+#define DM_HISTOGRAM_BOUNDS_RANGE 0x30
+
+/*
+ * Return a string representation of the supplied histogram's values and
+ * bin boundaries.
+ *
+ * The bin argument selects the bin to format. If this argument is less
+ * than zero all bins will be included in the resulting string.
+ *
+ * flags is a collection of flag arguments that control the string format:
+ *
+ * DM_HISTOGRAM_VALUES  - Include bin values in the string.
+ * DM_HISTOGRAM_SUFFIX  - Include time unit suffixes when printing bounds.
+ * DM_HISTOGRAM_PERCENT - Format bin values as a percentage.
+ *
+ * DM_HISTOGRAM_BOUNDS_LOWER - Include the lower bound of each bin.
+ * DM_HISTOGRAM_BOUNDS_UPPER - Include the upper bound of each bin.
+ * DM_HISTOGRAM_BOUNDS_RANGE - Show the span of each bin as "lo-up".
+ *
+ * The returned pointer does not need to be freed explicitly by the
+ * caller: it will become invalid following a subsequent
+ * dm_stats_list(), dm_stats_populate() or dm_stats_destroy() of the
+ * corresponding dm_stats handle.
+ */
+const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
+				   int width, int flags);
+
 /*************************
  * config file parse/print
  *************************/
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 800bde6..d611635 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -14,12 +14,32 @@
 
 #include "dmlib.h"
 
+#include "math.h" /* log10() */
+
 #define DM_STATS_REGION_NOT_PRESENT UINT64_MAX
 
+#define NSEC_PER_USEC   1000L
 #define NSEC_PER_MSEC   1000000L
 #define NSEC_PER_SEC    1000000000L
 
 #define PRECISE_ARG "precise_timestamps"
+#define HISTOGRAM_ARG "histogram:"
+
+/* Histogram bin */
+struct dm_histogram_bin {
+	uint64_t upper; /* Upper bound on this bin. */
+	uint64_t count; /* Count value for this bin. */
+};
+
+struct dm_histogram {
+	/* The stats handle this histogram belongs to. */
+	const struct dm_stats *dms;
+	/* The region this histogram belongs to. */
+	const struct dm_stats_region *region;
+	uint64_t sum; /* Sum of histogram bin counts. */
+	int nr_bins; /* Number of histogram bins assigned. */
+	struct dm_histogram_bin bins[0];
+};
 
 /*
  * See Documentation/device-mapper/statistics.txt for full descriptions
@@ -39,6 +59,7 @@ struct dm_stats_counters {
 	uint64_t weighted_io_nsecs; /* Weighted num milliseconds doing I/Os */
 	uint64_t total_read_nsecs;  /* Total time spent reading in milliseconds */
 	uint64_t total_write_nsecs; /* Total time spent writing in milliseconds */
+	struct dm_histogram *histogram; /* Histogram. */
 };
 
 struct dm_stats_region {
@@ -49,6 +70,7 @@ struct dm_stats_region {
 	char *program_id;
 	char *aux_data;
 	uint64_t timescale; /* precise_timestamps is per-region */
+	struct dm_histogram *bounds; /* histogram configuration */
 	struct dm_stats_counters *counters;
 };
 
@@ -60,6 +82,7 @@ struct dm_stats {
 	char *uuid; /* device-mapper UUID */
 	char *program_id; /* default program_id for this handle */
 	struct dm_pool *mem; /* memory pool for region and counter tables */
+	struct dm_pool *hist_mem; /* separate pool for histogram tables */
 	uint64_t nr_regions; /* total number of present regions */
 	uint64_t max_region; /* size of the regions table */
 	uint64_t interval_ns;  /* sampling interval in nanoseconds */
@@ -93,15 +116,40 @@ static char *_program_id_from_proc(void)
 	return dm_strdup(buf);
 }
 
+static uint64_t _nr_areas(uint64_t len, uint64_t step)
+{
+	/* Default is one area. */
+	if (!len || !step)
+		return 1;
+	/*
+	 * drivers/md/dm-stats.c::message_stats_create()
+	 * A region may be sub-divided into areas with their own counters.
+	 * Any partial area@the end of the region is treated as an
+	 * additional complete area.
+	 */
+	return (len + step - 1) / step;
+}
+
+static uint64_t _nr_areas_region(struct dm_stats_region *region)
+{
+	return _nr_areas(region->len, region->step);
+}
+
 struct dm_stats *dm_stats_create(const char *program_id)
 {
+	size_t hist_hint = sizeof(struct dm_histogram_bin);
 	struct dm_stats *dms = NULL;
 
 	if (!(dms = dm_zalloc(sizeof(*dms))))
 		return_NULL;
+
+	/* FIXME: better hint. */
 	if (!(dms->mem = dm_pool_create("stats_pool", 4096)))
 		goto_out;
 
+	if (!(dms->hist_mem = dm_pool_create("histogram_pool", hist_hint)))
+		return_0;
+
 	if (!program_id || !strlen(program_id))
 		dms->program_id = _program_id_from_proc();
 	else
@@ -134,6 +182,20 @@ static int _stats_region_present(const struct dm_stats_region *region)
 	return !(region->region_id == DM_STATS_REGION_NOT_PRESENT);
 }
 
+static void _stats_histograms_destroy(struct dm_pool *mem,
+				      struct dm_stats_region *region)
+{
+	uint64_t n;
+
+	/* Unpopulated handle. */
+	if (!region->counters)
+		return;
+
+	for (n = _nr_areas_region(region) - 1; n; n--)
+		if (region->counters[n].histogram)
+			dm_pool_free(mem, region->counters[n].histogram);
+}
+
 static void _stats_region_destroy(struct dm_stats_region *region)
 {
 	if (!_stats_region_present(region))
@@ -142,6 +204,8 @@ static void _stats_region_destroy(struct dm_stats_region *region)
 	/**
 	 * Don't free counters here explicitly; it will be dropped
 	 * from the pool along with the corresponding regions table.
+	 *
+	 * The following objects are all allocated with dm_malloc.
 	 */
 
 	if (region->program_id)
@@ -159,8 +223,11 @@ static void _stats_regions_destroy(struct dm_stats *dms)
 		return;
 
 	/* walk backwards to obey pool order */
-	for (i = dms->max_region; (i != DM_STATS_REGION_NOT_PRESENT); i--)
+	for (i = dms->max_region; (i != DM_STATS_REGION_NOT_PRESENT); i--) {
+		_stats_histograms_destroy(dms->hist_mem, &dms->regions[i]);
 		_stats_region_destroy(&dms->regions[i]);
+	}
+
 	dm_pool_free(mem, dms->regions);
 }
 
@@ -234,6 +301,7 @@ static int _stats_check_precise_timestamps(const struct dm_stats *dms)
 	/* Already checked? */
 	if (dms && dms->precise)
 		return 1;
+
 	return dm_message_supports_precise_timestamps();
 }
 
@@ -242,6 +310,80 @@ int dm_stats_driver_supports_precise(void)
 	return _stats_check_precise_timestamps(NULL);
 }
 
+int dm_stats_driver_supports_histogram(void)
+{
+	return _stats_check_precise_timestamps(NULL);
+}
+
+static char *_build_histogram_arg(struct dm_histogram *bounds, int *precise)
+{
+	struct dm_histogram_bin *entry, *bins;
+	size_t hist_len = 1, len = 0;
+	char *hist_arg, *arg = NULL;
+	uint64_t scale;
+
+	entry = bins = bounds->bins;
+
+	/* Empty histogram is invalid. */
+	if (!bounds->nr_bins) {
+		log_error("Cannot format empty histogram description.");
+		return NULL;
+	}
+
+	entry += bounds->nr_bins - 1;
+	while(entry >= bins) {
+		double value;
+		if (entry != bins) {
+			if (entry->upper < (entry - 1)->upper) {
+				log_error("Histogram boundaries must be in "
+					  "order of increasing magnitude.");
+				return 0;
+			}
+			hist_len++; /* ',' */
+		}
+
+		/*
+		 * Only enable precise_timestamps automatically if any
+		 * value in the histogram bounds uses precision < 1ms.
+		 */
+		if (!*precise && (entry->upper % NSEC_PER_MSEC))
+			*precise = 1;
+
+		value = (double) (entry--)->upper;
+		/* Use lround to avoid size_t -> double cast warning. */
+		hist_len += 1 + (size_t) lround(log10(value));
+	}
+
+	if(!(hist_arg = dm_zalloc(hist_len))) {
+		log_error("Could not allocate memory for histogram argument.");
+		return 0;
+	}
+
+	arg = hist_arg;
+
+	if (*precise)
+		scale = 1;
+	else
+		scale = (*precise) ? 1 : NSEC_PER_MSEC;
+
+	for (entry = bins; entry < (bins + bounds->nr_bins); entry++) {
+		uint64_t value;
+		ssize_t l = 0;
+		int last = !(entry < (bins + bounds->nr_bins - 1));
+		value = entry->upper / scale;
+		if ((l = dm_snprintf(arg, hist_len - len, FMTu64"%s", value,
+				     (last) ? "" : ",")) < 0)
+			goto out;
+		len += (size_t) l;
+		arg += (size_t) l;
+	}
+	return hist_arg;
+out:
+	log_error("Could not build histogram arguments.");
+	dm_free(hist_arg);
+	return NULL;
+}
+
 static struct dm_task *_stats_send_message(struct dm_stats *dms, char *msg)
 {
 	struct dm_task *dmt;
@@ -264,7 +406,114 @@ out:
 	return NULL;
 }
 
-static int _stats_parse_list_region(struct dm_stats_region *region, char *line)
+/*
+ * Parse a histogram specification returned by the kernel in a
+ * @stats_list response.
+ */
+static int _stats_parse_histogram_spec(struct dm_stats *dms,
+				       struct dm_stats_region *region,
+				       const char *histogram)
+{
+	static const char *_valid_chars = "0123456789,";
+	uint64_t scale = region->timescale;
+	struct dm_pool *mem = dms->hist_mem;
+	struct dm_histogram_bin cur;
+	struct dm_histogram hist;
+	unsigned nr_bins = 1;
+	const char *c, *v;
+	char *p;
+
+	/* Advance past "histogram:". */
+	histogram = strchr(histogram, ':');
+	if(!histogram) {
+		log_error("Could not parse histogram description.");
+		return 0;
+	}
+	histogram++;
+
+	/* @stats_list rows are newline terminated. */
+	if ((p = strchr(histogram, '\n')))
+		*p = '\0';
+
+	if (!dm_pool_begin_object(mem, sizeof(cur)))
+		return_0;
+
+	memset(&hist, 0, sizeof(hist));
+
+	hist.nr_bins = 0; /* fix later */
+	hist.region = region;
+	hist.dms = dms;
+
+	if(!dm_pool_grow_object(mem, &hist, sizeof(hist)))
+		goto_out;
+
+	c = histogram;
+	do {
+		for(v = _valid_chars; *v; v++)
+			if (*c == *v)
+				break;
+		if(!*v)
+			goto badchar;
+
+		if (*c == ',') {
+			log_error("Invalid histogram description: %s",
+				  histogram);
+			goto out;
+		} else {
+			const char *val_start = c;
+			char *endptr = NULL;
+			uint64_t this_val = 0;
+
+			this_val = strtoull(val_start, &endptr, 10);
+			if (!endptr) {
+				log_error("Could not parse histogram boundary.");
+				goto out;
+			}
+
+			c = endptr; /* Advance to units, comma, or end. */
+
+			if (*c == ',')
+				c++;
+			else if (*c || (*c == ' ')) /* Expected ',' or NULL. */
+				goto badchar;
+
+			if (*c == ',')
+				c++;
+
+			cur.upper = scale * this_val;
+			cur.count = 0;
+
+			if (!dm_pool_grow_object(mem, &cur, sizeof(cur)))
+				goto_out;
+
+			nr_bins++;
+		}
+	} while (*c && (*c != ' '));
+
+	/* final upper bound. */
+	cur.upper = UINT64_MAX;
+	if (!dm_pool_grow_object(mem, &cur, sizeof(cur)))
+		goto_out;
+
+	region->bounds = dm_pool_end_object(mem);
+
+	if (!region->bounds)
+		return_0;
+
+	region->bounds->nr_bins = nr_bins;
+
+	log_debug("Added region histogram spec with %d entries.", nr_bins);
+	return 1;
+
+badchar:
+	log_error("Invalid character in histogram: '%c' (0x%x)", *c, *c);
+out:
+	dm_pool_abandon_object(mem);
+	return 0;
+}
+
+static int _stats_parse_list_region(struct dm_stats *dms,
+				    struct dm_stats_region *region, char *line)
 {
 	char *p = NULL, string_data[4096]; /* FIXME: add dm_sscanf with %ms? */
 	const char *program_id, *aux_data, *stats_args;
@@ -316,6 +565,12 @@ static int _stats_parse_list_region(struct dm_stats_region *region, char *line)
 	else
 		region->timescale = NSEC_PER_MSEC;
 
+	if ((p = strstr(stats_args, HISTOGRAM_ARG))) {
+		if (!_stats_parse_histogram_spec(dms, region, p))
+			return_0;
+	} else
+		region->bounds = NULL;
+
 	if (!(region->program_id = dm_strdup(program_id)))
 		return_0;
 	if (!(region->aux_data = dm_strdup(aux_data))) {
@@ -363,7 +618,7 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 
 	while(fgets(line, sizeof(line), list_rows)) {
 
-		if (!_stats_parse_list_region(&cur, line))
+		if (!_stats_parse_list_region(dms, &cur, line))
 			goto_out;
 
 		/* handle holes in the list of region_ids */
@@ -435,11 +690,91 @@ out:
 	return 0;
 }
 
-static int _stats_parse_region(struct dm_pool *mem, const char *resp,
+/*
+ * Parse histogram data returned from a @stats_print operation.
+ */
+static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
+				  struct dm_histogram **histogram,
+				  struct dm_stats_region *region)
+{
+	static const char *_valid_chars = "0123456789:";
+	int nr_bins = region->bounds->nr_bins;
+	struct dm_histogram hist, *bounds = region->bounds;
+	struct dm_histogram_bin cur;
+	uint64_t sum = 0;
+	const char *c, *v;
+	int bin = 0;
+
+	c = hist_str;
+
+	dm_pool_begin_object(mem, sizeof(cur));
+
+	hist.nr_bins = nr_bins;
+
+	dm_pool_grow_object(mem, &hist, sizeof(hist));
+
+	do {
+		memset(&cur, 0, sizeof(cur));
+		for(v = _valid_chars; *v; v++)
+			if (*c == *v)
+				break;
+		if(!*v)
+			goto badchar;
+
+		if (*c == ',') {
+			log_error("Invalid histogram: %s", hist_str);
+			goto out;
+		} else {
+			const char *val_start = c;
+			char *endptr = NULL;
+			uint64_t this_val = 0;
+
+			this_val = strtoull(val_start, &endptr, 10);
+			if (!endptr) {
+				log_error("Could not parse histogram value.");
+				goto out;
+			}
+			c = endptr; /* Advance to colon, or end. */
+
+			if (*c == ':')
+				c++;
+			else if (*c & (*c != '\n'))
+				/* Expected ':', '\n', or NULL. */
+				goto badchar;
+
+			if (*c == ':')
+				c++;
+
+			cur.upper = bounds->bins[bin].upper;
+			cur.count = this_val;
+			sum += this_val;
+
+			dm_pool_grow_object(mem, &cur, sizeof(cur));
+
+			bin++;
+		}
+	} while (*c && (*c != '\n'));
+
+	log_debug("Added region histogram data with %d entries.", nr_bins);
+
+	*histogram = dm_pool_end_object(mem);
+	(*histogram)->sum = sum;
+
+	return 1;
+
+badchar:
+	log_error("Invalid character in histogram data: '%c' (0x%x)", *c, *c);
+out:
+	return 0;
+}
+
+static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 			       struct dm_stats_region *region,
 			       uint64_t timescale)
 {
+	struct dm_histogram *hist = NULL;
 	struct dm_stats_counters cur;
+	struct dm_pool *mem = dms->mem;
 	FILE *stats_rows = NULL;
 	uint64_t start, len;
 	char row[256];
@@ -522,8 +857,33 @@ static int _stats_parse_region(struct dm_pool *mem, const char *resp,
 			cur.total_write_nsecs *= timescale;
 		}
 
+		if (region->bounds) {
+			/* Find first histogram separator. */
+			char *hist_str = strchr(row, ':');
+			if (!hist_str) {
+				log_error("Could not parse histogram value.");
+				goto out;
+			}
+			/* Find space preceding histogram. */
+			while (hist_str && *(hist_str - 1) != ' ')
+				hist_str--;
+
+			/* Use a separate pool for histogram objects since we
+			 * are growing the area table and each area's histogram
+			 * table simultaneously.
+			 */
+			if (!_stats_parse_histogram(dms->hist_mem, hist_str,
+						    &hist, region))
+				goto out;
+			hist->dms = dms;
+			hist->region = region;
+		}
+
+		cur.histogram = hist;
+
 		if(!dm_pool_grow_object(mem, &cur, sizeof(cur)))
 			goto_out;
+
 		if (region->start == UINT64_MAX) {
 			region->start = start;
 			region->step = len; /* area size is always uniform. */
@@ -548,25 +908,6 @@ out:
 	return 0;
 }
 
-static uint64_t _nr_areas(uint64_t len, uint64_t step)
-{
-	/* Default is one area. */
-	if (!len || !step)
-		return 1;
-	/*
-	 * drivers/md/dm-stats.c::message_stats_create()
-	 * A region may be sub-divided into areas with their own counters.
-	 * Any partial area at the end of the region is treated as an
-	 * additional complete area.
-	 */
-	return (len + step - 1) / step;
-}
-
-static uint64_t _nr_areas_region(struct dm_stats_region *region)
-{
-	return _nr_areas(region->len, region->step);
-}
-
 static void _stats_walk_next(const struct dm_stats *dms, int region,
 			     uint64_t *cur_r, uint64_t *cur_a)
 {
@@ -669,9 +1010,21 @@ uint64_t dm_stats_get_nr_areas(const struct dm_stats *dms)
 	return nr_areas;
 }
 
+int dm_stats_get_region_nr_histogram_bins(const struct dm_stats *dms,
+					  uint64_t region_id)
+{
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+
+	if (!dms->regions[region_id].bounds)
+		return 0;
+
+	return dms->regions[region_id].bounds->nr_bins;
+}
+
 static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 				uint64_t start, uint64_t len, int64_t step,
-				int precise,
+				int precise, const char *hist_arg,
 				const char *program_id,	const char *aux_data)
 {
 	struct dm_task *dmt = NULL;
@@ -679,7 +1032,7 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	const char *err_fmt = "Could not prepare @stats_create %s.";
 	const char *precise_str = PRECISE_ARG;
 	const char *resp, *opt_args = NULL;
-	int nr_opt = 0, r = 0; /* number of optional args. */
+	int r = 0, nr_opt = 0; /* number of optional args. */
 
 	if (!_stats_bound(dms))
 		return_0;
@@ -703,9 +1056,16 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	else
 		precise_str = "";
 
+	if (hist_arg)
+		nr_opt++;
+	else
+		hist_arg = "";
+
 	if (nr_opt) {
-		if ((dm_asprintf((char **)&opt_args, "%d %s", nr_opt,
-				 precise_str)) < 0) {
+		if ((dm_asprintf((char **)&opt_args, "%d %s %s%s", nr_opt,
+				 precise_str,
+				 (strlen(hist_arg)) ? HISTOGRAM_ARG : "",
+				 hist_arg)) < 0) {
 			log_error(err_fmt, PRECISE_ARG " option.");
 			return 0;
 		}
@@ -749,34 +1109,29 @@ out:
 
 int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 			   uint64_t start, uint64_t len, int64_t step,
-			   int precise,
-			   const char *program_id,
-			   const char *aux_data)
+			   int precise, struct dm_histogram *bounds,
+			   const char *program_id, const char *aux_data)
 {
-	/* Nanosecond counters need precise_timestamps. */
-	if (precise && !_stats_check_precise_timestamps(dms))
+	char *hist_arg = NULL;
+	int r = 0;
+
+	/* Nanosecond counters and histograms both need precise_timestamps. */
+	if ((precise || bounds)
+	    && !_stats_check_precise_timestamps(dms))
 		return 0;
 
-	return _stats_create_region(dms, region_id, start, len, step,
-				    precise,
-				    program_id, aux_data);
-}
+	if (bounds) {
+		/* _build_histogram_arg enables precise if vals < 1ms. */
+		if (!(hist_arg = _build_histogram_arg(bounds, &precise)))
+			goto_out;
+	}
 
-/* Backward compatible dm_stats_create_region() */
-#if defined(__GNUC__)
-int dm_stats_create_region_v1_02_104(struct dm_stats *dms, uint64_t *region_id,
-				     uint64_t start, uint64_t len, int64_t step,
-				     const char *program_id, const char *aux_data);
-int dm_stats_create_region_v1_02_104(struct dm_stats *dms, uint64_t *region_id,
-				     uint64_t start, uint64_t len, int64_t step,
-				     const char *program_id, const char *aux_data)
-{
-	return _stats_create_region(dms, region_id, start, len, step,
-				    dms->precise,
-				    program_id, aux_data);
+	r = _stats_create_region(dms, region_id, start, len, step,
+				 precise, hist_arg, program_id, aux_data);
+	dm_free(hist_arg);
+out:
+	return r;
 }
-DM_EXPORT_SYMBOL(dm_stats_create_region, 1_02_104);
-#endif
 
 int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 {
@@ -916,7 +1271,7 @@ static int _dm_stats_populate_region(struct dm_stats *dms, uint64_t region_id,
 	if (!_stats_bound(dms))
 		return_0;
 
-	if (!_stats_parse_region(dms->mem, resp, region, region->timescale)) {
+	if (!_stats_parse_region(dms, resp, region, region->timescale)) {
 		log_error("Could not parse @stats_print message response.");
 		return 0;
 	}
@@ -984,6 +1339,7 @@ void dm_stats_destroy(struct dm_stats *dms)
 	_stats_regions_destroy(dms);
 	_stats_clear_binding(dms);
 	dm_pool_destroy(dms->mem);
+	dm_pool_destroy(dms->hist_mem);
 	dm_free(dms->program_id);
 	dm_free(dms);
 }
@@ -1501,3 +1857,422 @@ int dm_stats_get_current_region_precise_timestamps(const struct dm_stats *dms)
 {
 	return dm_stats_get_region_precise_timestamps(dms, dms->cur_region);
 }
+
+/*
+ * Histogram access methods.
+ */
+
+struct dm_histogram *dm_stats_get_histogram(const struct dm_stats *dms,
+					    uint64_t region_id,
+					    uint64_t area_id)
+{
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_AREA_CURRENT)
+		     ? dms->cur_area : area_id ;
+
+	if (!dms->regions[region_id].counters)
+		return dms->regions[region_id].bounds;
+
+	return dms->regions[region_id].counters[area_id].histogram;
+}
+
+int dm_histogram_get_nr_bins(const struct dm_histogram *dmh)
+{
+	return dmh->nr_bins;
+}
+
+uint64_t dm_histogram_get_bin_lower(const struct dm_histogram *dmh, int bin)
+{
+	return (!bin) ? 0 : dmh->bins[bin - 1].upper;
+}
+
+uint64_t dm_histogram_get_bin_upper(const struct dm_histogram *dmh, int bin)
+{
+	return dmh->bins[bin].upper;
+}
+
+uint64_t dm_histogram_get_bin_width(const struct dm_histogram *dmh, int bin)
+{
+	uint64_t upper, lower;
+	upper = dm_histogram_get_bin_upper(dmh, bin);
+	lower = dm_histogram_get_bin_lower(dmh, bin);
+	return (upper - lower);
+}
+
+uint64_t dm_histogram_get_bin_count(const struct dm_histogram *dmh, int bin)
+{
+	return dmh->bins[bin].count;
+}
+
+uint64_t dm_histogram_get_sum(const struct dm_histogram *dmh)
+{
+	return dmh->sum;
+}
+
+dm_percent_t dm_histogram_get_bin_percent(const struct dm_histogram *dmh,
+					  int bin)
+{
+	uint64_t value = dm_histogram_get_bin_count(dmh, bin);
+	uint64_t width = dm_histogram_get_bin_width(dmh, bin);
+	uint64_t total = dm_histogram_get_sum(dmh);
+
+	double val = (double) value;
+
+	if (!total || !value || !width)
+		return DM_PERCENT_0;
+
+	return dm_make_percent((uint64_t) val, total);
+}
+
+/*
+ * Histogram string helper functions: used to construct histogram and
+ * bin boundary strings from numeric data.
+ */
+
+/*
+ * Allocate an unbound histogram object with nr_bins bins. Only used
+ * for histograms used to hold bounds values as arguments for calls to
+ * dm_stats_create_region().
+ */
+static struct dm_histogram *_alloc_dm_histogram(int nr_bins)
+{
+	struct dm_histogram *dmh = NULL;
+	struct dm_histogram_bin *cur = NULL;
+	/* Allocate space for dm_histogram + nr_entries. */
+	size_t size = sizeof(*dmh) + (unsigned) nr_bins * sizeof(*cur);
+	return dm_zalloc(size);
+}
+
+/*
+ * Parse a histogram bounds string supplied by the user. The string
+ * consists of a list of numbers, "n1,n2,n3,..." with optional 'ns',
+ * 'us', 'ms', or 's' unit suffixes.
+ *
+ * The scale parameter indicates the timescale used for this region: one
+ * for nanoscale resolution and NSEC_PER_MSEC for miliseconds.
+ *
+ * On return bounds contains a pointer to an array of uint64_t
+ * histogram bounds values expressed in units of nanoseconds.
+ */
+struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str)
+{
+	static const char *_valid_chars = "0123456789,muns";
+	struct dm_histogram *dmh;
+	struct dm_histogram_bin *cur;
+	const char *c, *v;
+	int nr_entries = 1;
+
+	c = bounds_str;
+
+	/* Count number of bounds entries. */
+	while(*c)
+		if (*(c++) == ',')
+			nr_entries++;
+
+	c = bounds_str;
+
+	if (!(dmh = _alloc_dm_histogram(nr_entries)))
+		return 0;
+
+	dmh->nr_bins = nr_entries;
+
+	cur = dmh->bins;
+
+	do {
+		for(v = _valid_chars; *v; v++)
+			if (*c == *v)
+				break;
+		if(!*v)
+			goto badchar;
+
+		if (*c == ',') {
+			log_error("Empty histogram bin not allowed: %s",
+				  bounds_str);
+			goto out;
+		} else {
+			const char *val_start = c;
+			char *endptr = NULL;
+			uint64_t this_val = 0, mult = 1;
+
+			this_val = strtoull(val_start, &endptr, 10);
+			if (!endptr) {
+				log_error("Could not parse histogram bound.");
+				goto out;
+			}
+			c = endptr; /* Advance to units, comma, or end. */
+
+			if (*c == 's') {
+				mult = NSEC_PER_SEC;
+				c++; /* Advance over 's'. */
+			} else if (*(c + 1) == 's') {
+				if (*c == 'm')
+					mult = NSEC_PER_MSEC;
+				else if (*c == 'u')
+					mult = NSEC_PER_USEC;
+				else if (*c == 'n')
+					mult = 1;
+				else
+					goto badchar;
+				c += 2; /* Advance over 'ms', 'us', or 'ns'. */
+			} else if (*c == ',')
+				c++;
+			else if (*c) /* Expected ',' or NULL. */
+				goto badchar;
+
+			if (*c == ',')
+				c++;
+			this_val *= mult;
+			(cur++)->upper = this_val;
+		}
+	} while (*c);
+
+	/* Bounds histograms have no owner. */
+	dmh->dms = NULL;
+	dmh->region = NULL;
+
+	return dmh;
+
+badchar:
+	log_error("Invalid character in histogram: %c", *c);
+out:
+	dm_free(dmh);
+	return NULL;
+}
+
+struct dm_histogram *dm_histogram_bounds_from_uint64(const uint64_t *bounds)
+{
+	struct dm_histogram *dmh;
+	struct dm_histogram_bin *cur;
+	int nr_entries = 1;
+	const uint64_t *entry = bounds;
+
+	if (!bounds || !bounds[0]) {
+		log_error("Could not parse empty histogram bounds array");
+		return 0;
+	}
+
+	/* Count number of bounds entries. */
+	while(*entry)
+		if (*(++entry))
+			nr_entries++;
+
+	entry = bounds;
+
+	if (!(dmh = _alloc_dm_histogram(nr_entries)))
+		return_0;
+
+	dmh->nr_bins = nr_entries;
+
+	cur = dmh->bins;
+
+	while (*entry)
+		(cur++)->upper = *(entry++);
+
+	/* Bounds histograms have no owner. */
+	dmh->dms = NULL;
+	dmh->region = NULL;
+
+	return dmh;
+}
+
+void dm_histogram_bounds_destroy(struct dm_histogram *bounds)
+{
+	if (!bounds)
+		return;
+
+	/* Bounds histograms are not bound to any handle or region. */
+	if (bounds->dms || bounds->region) {
+		log_error("Freeing invalid histogram bounds pointer %p.",
+			  (void *) bounds);
+		stack;
+	}
+	/* dm_free() expects a (void *). */
+	dm_free((void *) bounds);
+}
+
+/*
+ * Scale a bounds value down from nanoseconds to the largest possible
+ * whole unit suffix.
+ */
+static void _scale_bound_value_to_suffix(uint64_t *bound, const char **suffix)
+{
+	if (!(*bound % NSEC_PER_SEC)) {
+		*bound /= NSEC_PER_SEC;
+		*suffix = "s";
+	} else if (!(*bound % NSEC_PER_MSEC)) {
+		*bound /= NSEC_PER_MSEC;
+		*suffix = "ms";
+	} else if (!(*bound % NSEC_PER_USEC)) {
+		*bound /= NSEC_PER_USEC;
+		*suffix = "us";
+	}
+}
+
+#define DM_HISTOGRAM_BOUNDS_MASK 0x30
+
+static int _make_bounds_string(char *buf, size_t size, uint64_t lower,
+			       uint64_t upper, int flags, int width)
+{
+	const char *l_suff = NULL;
+	const char *u_suff = NULL;
+	const char *sep = (flags & DM_HISTOGRAM_VALUES) ? ": " : "";
+	char bound_buf[32];
+	int bounds = flags & DM_HISTOGRAM_BOUNDS_MASK;
+
+	if (!bounds)
+		return 0;
+
+	*buf = '\0';
+
+	if (flags & DM_HISTOGRAM_SUFFIX) {
+		_scale_bound_value_to_suffix(&lower, &l_suff);
+		_scale_bound_value_to_suffix(&upper, &u_suff);
+	} else
+		l_suff = u_suff = "";
+
+	if (bounds > DM_HISTOGRAM_BOUNDS_LOWER) {
+		/* Handle infinite uppermost bound. */
+		if (upper == UINT64_MAX) {
+			if (dm_snprintf(bound_buf, sizeof(bound_buf),
+					 ">" FMTu64 "%s", lower, l_suff) < 0)
+				goto_out;
+			/* Only display an 'upper' string for final bin. */
+			bounds = DM_HISTOGRAM_BOUNDS_UPPER;
+		} else {
+			if (dm_snprintf(bound_buf, sizeof(bound_buf),
+					 FMTu64 "%s", upper, u_suff) < 0)
+				goto_out;
+		}
+	} else if (bounds == DM_HISTOGRAM_BOUNDS_LOWER) {
+		if ((dm_snprintf(bound_buf, sizeof(bound_buf), FMTu64 "%s",
+				 lower, l_suff)) < 0)
+			goto_out;
+	}
+
+	switch (bounds) {
+	case DM_HISTOGRAM_BOUNDS_LOWER:
+	case DM_HISTOGRAM_BOUNDS_UPPER:
+		return dm_snprintf(buf, size, "%*s%s", width, bound_buf, sep);
+	case DM_HISTOGRAM_BOUNDS_RANGE:
+		return dm_snprintf(buf, size,  FMTu64 "%s-%s%s",
+				   lower, l_suff, bound_buf, sep);
+	}
+out:
+	return 0;
+}
+
+#define BOUND_WIDTH 6 /* bounds string up to 9999xs */
+#define COUNT_WIDTH 6 /* count string: up to 9999 */
+#define PERCENT_WIDTH 8 /* percent string : 0.00-100.00% */
+
+const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
+				   int width, int flags)
+{
+	int minwidth, bounds, values, start, last;
+	uint64_t lower, upper; /* bounds of the current bin. */
+	/* Use the histogram pool for string building. */
+	struct dm_pool *mem = dmh->dms->hist_mem;
+	char buf[64], bounds_buf[64];
+	const char *sep = "";
+	ssize_t len;
+
+	bounds = flags & DM_HISTOGRAM_BOUNDS_MASK;
+	values = flags & DM_HISTOGRAM_VALUES;
+
+	if (bin < 0) {
+		start = 0;
+		last = dmh->nr_bins - 1;
+	} else
+		start = last = bin;
+
+	if (flags & DM_HISTOGRAM_PERCENT)
+		width = minwidth = (width) ? : PERCENT_WIDTH;
+	else if (flags & DM_HISTOGRAM_VALUES)
+		width = minwidth = (width) ? : COUNT_WIDTH;
+	else
+		width = 0; /* bounds only */
+
+	/* Set bounds string to the empty string. */
+	bounds_buf[0] = '\0';
+
+	dm_pool_begin_object(mem, 64);
+
+	for (bin = start; bin <= last; bin++) {
+		if (bounds) {
+			lower = dm_histogram_get_bin_lower(dmh, bin);
+			upper = dm_histogram_get_bin_upper(dmh, bin);
+			_make_bounds_string(bounds_buf, sizeof(bounds_buf),
+					    lower, upper, flags,
+					    (width) ? BOUND_WIDTH : 0);
+			sep = ", "; /* Comma separates "bounds: value" pairs */
+			width -= (int) (strlen(bounds_buf) - BOUND_WIDTH);
+			width = (width > 0) ? width : 0;
+		}
+
+		if (bin == last)
+			sep = "";
+		if (flags & DM_HISTOGRAM_PERCENT) {
+			dm_percent_t pr;
+			float value;
+			pr = dm_histogram_get_bin_percent(dmh, bin);
+			value = dm_percent_to_float(pr);
+			len = dm_snprintf(buf, sizeof(buf), "%s%*.2f%%%s",
+					  bounds_buf, width, value, sep);
+		} else if (values) {
+			uint64_t value = dmh->bins[bin].count;
+			len = dm_snprintf(buf, sizeof(buf), "%s%*"PRIu64"%s",
+					  bounds_buf, width, value, sep);
+		} else if (bounds)
+			len = dm_snprintf(buf, sizeof(buf), "%s%s", bounds_buf,
+					  sep);
+
+		if (len < 0)
+			goto_out;
+
+		width = minwidth; /* re-set histogram column width. */
+		dm_pool_grow_object(mem, buf, (size_t) len);
+	}
+	dm_pool_grow_object(mem, "\0", 1);
+	return (const char *) dm_pool_end_object(mem);
+out:
+	dm_pool_abandon_object(mem);
+	return NULL;
+}
+
+/*
+ * Backward compatible dm_stats_create_region() implementations.
+ *
+ * Keep these@the end of the file to avoid adding clutter around the
+ * current dm_stats_create_region() version.
+ */
+
+#if defined(__GNUC__)
+int dm_stats_create_region_v1_02_106(struct dm_stats *dms, uint64_t *region_id,
+				     uint64_t start, uint64_t len, int64_t step,
+				     int precise, const char *program_id,
+				     const char *aux_data);
+int dm_stats_create_region_v1_02_106(struct dm_stats *dms, uint64_t *region_id,
+				     uint64_t start, uint64_t len, int64_t step,
+				     int precise, const char *program_id,
+				     const char *aux_data)
+{
+	/* 1.02.106 lacks histogram argument. */
+	return _stats_create_region(dms, region_id, start, len, step, precise,
+				    NULL, program_id, aux_data);
+}
+DM_EXPORT_SYMBOL(dm_stats_create_region, 1_02_106);
+
+int dm_stats_create_region_v1_02_104(struct dm_stats *dms, uint64_t *region_id,
+				     uint64_t start, uint64_t len, int64_t step,
+				     const char *program_id, const char *aux_data);
+int dm_stats_create_region_v1_02_104(struct dm_stats *dms, uint64_t *region_id,
+				     uint64_t start, uint64_t len, int64_t step,
+				     const char *program_id, const char *aux_data)
+{
+	/* 1.02.104 lacks histogram and precise arguments. */
+	return _stats_create_region(dms, region_id, start, len, step, 0, NULL,
+				    program_id, aux_data);
+}
+DM_EXPORT_SYMBOL(dm_stats_create_region, 1_02_104);
+#endif
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index dcf44de..976d9e3 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4533,7 +4533,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 			this_len = (segments) ? segment_len : this_len;
 			if (!dm_stats_create_region(dms, &region_id,
 						    this_start, this_len, step,
-						    precise,
+						    precise, NULL,
 						    program_id, aux_data)) {
 				log_error("%s: Could not create statistics region.",
 					  devname);



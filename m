From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:29 +0000 (UTC)
Subject: master - libdm: add enum based counter and metric calls
Message-ID: <20160705185429.D5A5C60D29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=82e57660623c6b131632a5ec37deef3428de5399
Commit:        82e57660623c6b131632a5ec37deef3428de5399
Parent:        69f808ac8d25e3c7ef39bd2de66fed1efd290bbe
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Feb 29 17:33:16 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

libdm: add enum based counter and metric calls

Add a new enum based interface for accessing counter and metric
values that uses a single function for each:

uint64_t dm_stats_get_counter(const struct dm_stats *dms,
                              dm_stats_counter_t counter
                              uint64_t region_id, uint64_t area_id);

int dm_stats_get_metric(const struct dm_stats *dms, int metric,
                        uint64_t region_id, uint64_t area_id,
                        double *value);

This simplifies the implementation of value aggregation for
groups of regions. The named function interface now calls the
enum interface internally so that all new functionality is
available regardless of the method used to retrieve values.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_129 |    2 +
 libdm/libdevmapper.h                |   48 +++
 libdm/libdm-stats.c                 |  567 +++++++++++++++++++++--------------
 4 files changed, 396 insertions(+), 222 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 28999f1..59d0cdf 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.129 - 
 =================================
+  Add enum-driven dm_stats_get_{metric,counter}() interfaces.
   Add dm_bitset_parse_list() to parse a string representation of a bitset.
   Thin dmeventd plugin umounts lvm2 volume only when pool is 95% or more.
 
diff --git a/libdm/.exported_symbols.DM_1_02_129 b/libdm/.exported_symbols.DM_1_02_129
index fbd2a57..8385362 100644
--- a/libdm/.exported_symbols.DM_1_02_129
+++ b/libdm/.exported_symbols.DM_1_02_129
@@ -1 +1,3 @@
 dm_bitset_parse_list
+dm_stats_get_counter
+dm_stats_get_metric
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3668188..68f1192 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2742,6 +2742,12 @@ int dm_report_group_destroy(struct dm_report_group *group);
  * or area is selected according to the current state of the dm_stats
  * handle's embedded cursor.
  *
+ * Two methods are provided to access counter values: a named function
+ * for each available counter field and a single function that accepts
+ * an enum value specifying the required field. New code is encouraged
+ * to use the enum based interface as calls to the named functions are
+ * implemented using the enum method internally.
+ *
  * See the kernel documentation for complete descriptions of each
  * counter field:
  *
@@ -2766,6 +2772,27 @@ int dm_report_group_destroy(struct dm_report_group *group);
 #define DM_STATS_REGION_CURRENT UINT64_MAX
 #define DM_STATS_AREA_CURRENT UINT64_MAX
 
+typedef enum {
+	DM_STATS_READS_COUNT,
+	DM_STATS_READS_MERGED_COUNT,
+	DM_STATS_READ_SECTORS_COUNT,
+	DM_STATS_READ_NSECS,
+	DM_STATS_WRITES_COUNT,
+	DM_STATS_WRITES_MERGED_COUNT,
+	DM_STATS_WRITE_SECTORS_COUNT,
+	DM_STATS_WRITE_NSECS,
+	DM_STATS_IO_IN_PROGRESS_COUNT,
+	DM_STATS_IO_NSECS,
+	DM_STATS_WEIGHTED_IO_NSECS,
+	DM_STATS_TOTAL_READ_NSECS,
+	DM_STATS_TOTAL_WRITE_NSECS,
+	DM_STATS_NR_COUNTERS
+} dm_stats_counter_t;
+
+uint64_t dm_stats_get_counter(const struct dm_stats *dms,
+			      dm_stats_counter_t counter,
+			      uint64_t region_id, uint64_t area_id);
+
 uint64_t dm_stats_get_reads(const struct dm_stats *dms,
 			    uint64_t region_id, uint64_t area_id);
 
@@ -2832,6 +2859,27 @@ uint64_t dm_stats_get_total_write_nsecs(const struct dm_stats *dms,
  * average_wr_wait_time: the average write wait time
  */
 
+typedef enum {
+	DM_STATS_RD_MERGES_PER_SEC,
+	DM_STATS_WR_MERGES_PER_SEC,
+	DM_STATS_READS_PER_SEC,
+	DM_STATS_WRITES_PER_SEC,
+	DM_STATS_READ_SECTORS_PER_SEC,
+	DM_STATS_WRITE_SECTORS_PER_SEC,
+	DM_STATS_AVERAGE_REQUEST_SIZE,
+	DM_STATS_AVERAGE_QUEUE_SIZE,
+	DM_STATS_AVERAGE_WAIT_TIME,
+	DM_STATS_AVERAGE_RD_WAIT_TIME,
+	DM_STATS_AVERAGE_WR_WAIT_TIME,
+	DM_STATS_SERVICE_TIME,
+	DM_STATS_THROUGHPUT,
+	DM_STATS_UTILIZATION,
+	DM_STATS_NR_METRICS
+} dm_stats_metric_t;
+
+int dm_stats_get_metric(const struct dm_stats *dms, int metric,
+			uint64_t region_id, uint64_t area_id, double *value);
+
 int dm_stats_get_rd_merges_per_sec(const struct dm_stats *dms, double *rrqm,
 				   uint64_t region_id, uint64_t area_id);
 
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 99e4d72..e89f3d6 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1438,342 +1438,465 @@ void dm_stats_destroy(struct dm_stats *dms)
 	dm_free(dms);
 }
 
+static uint64_t _stats_get_counter(const struct dm_stats *dms,
+				   const struct dm_stats_counters *area,
+				   dm_stats_counter_t counter)
+{
+	switch(counter) {
+	case DM_STATS_READS_COUNT:
+		return area->reads;
+	case DM_STATS_READS_MERGED_COUNT:
+		return area->reads_merged;
+	case DM_STATS_READ_SECTORS_COUNT:
+		return area->read_sectors;
+	case DM_STATS_READ_NSECS:
+		return area->read_nsecs;
+	case DM_STATS_WRITES_COUNT:
+		return area->writes;
+	case DM_STATS_WRITES_MERGED_COUNT:
+		return area->writes_merged;
+	case DM_STATS_WRITE_SECTORS_COUNT:
+		return area->write_sectors;
+	case DM_STATS_WRITE_NSECS:
+		return area->write_nsecs;
+	case DM_STATS_IO_IN_PROGRESS_COUNT:
+		return area->io_in_progress;
+	case DM_STATS_IO_NSECS:
+		return area->io_nsecs;
+	case DM_STATS_WEIGHTED_IO_NSECS:
+		return area->weighted_io_nsecs;
+	case DM_STATS_TOTAL_READ_NSECS:
+		return area->total_read_nsecs;
+	case DM_STATS_TOTAL_WRITE_NSECS:
+		return area->total_write_nsecs;
+	case DM_STATS_NR_COUNTERS:
+	default:
+		log_error("Attempt to read invalid counter: %d", counter);
+	}
+	return 0;
+}
+
+uint64_t dm_stats_get_counter(const struct dm_stats *dms,
+			      dm_stats_counter_t counter,
+			      uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_region *region;
+	struct dm_stats_counters *area;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	region = &dms->regions[region_id];
+
+	area = &region->counters[area_id];
+
+	return _stats_get_counter(dms, area, counter);
+}
+
 /**
- * Methods for accessing counter fields. All methods share the
+ * Methods for accessing named counter fields. All methods share the
  * following naming scheme and prototype:
  *
- * uint64_t dm_stats_get_COUNTER(struct dm_stats *, uint64_t, uint64_t)
+ * uint64_t dm_stats_get_COUNTER(const struct dm_stats *, uint64_t, uint64_t)
  *
  * Where the two integer arguments are the region_id and area_id
  * respectively.
+ *
+ * name is the name of the counter (lower case)
+ * counter is the part of the enum name following DM_STATS_ (upper case)
  */
-#define MK_STATS_GET_COUNTER_FN(counter)				\
-uint64_t dm_stats_get_ ## counter(const struct dm_stats *dms,		\
-				uint64_t region_id, uint64_t area_id)	\
+#define MK_STATS_GET_COUNTER_FN(name, counter)				\
+uint64_t dm_stats_get_ ## name(const struct dm_stats *dms,		\
+			       uint64_t region_id, uint64_t area_id)	\
 {									\
-	region_id = (region_id == DM_STATS_REGION_CURRENT)		\
-		     ? dms->cur_region : region_id ;			\
-	area_id = (area_id == DM_STATS_REGION_CURRENT)			\
-		   ? dms->cur_area : area_id ;				\
-	return dms->regions[region_id].counters[area_id].counter;	\
-}
-
-MK_STATS_GET_COUNTER_FN(reads)
-MK_STATS_GET_COUNTER_FN(reads_merged)
-MK_STATS_GET_COUNTER_FN(read_sectors)
-MK_STATS_GET_COUNTER_FN(read_nsecs)
-MK_STATS_GET_COUNTER_FN(writes)
-MK_STATS_GET_COUNTER_FN(writes_merged)
-MK_STATS_GET_COUNTER_FN(write_sectors)
-MK_STATS_GET_COUNTER_FN(write_nsecs)
-MK_STATS_GET_COUNTER_FN(io_in_progress)
-MK_STATS_GET_COUNTER_FN(io_nsecs)
-MK_STATS_GET_COUNTER_FN(weighted_io_nsecs)
-MK_STATS_GET_COUNTER_FN(total_read_nsecs)
-MK_STATS_GET_COUNTER_FN(total_write_nsecs)
+	return dm_stats_get_counter(dms, DM_STATS_ ## counter,		\
+				    region_id, area_id);		\
+}
+
+MK_STATS_GET_COUNTER_FN(reads, READS_COUNT)
+MK_STATS_GET_COUNTER_FN(reads_merged, READS_MERGED_COUNT)
+MK_STATS_GET_COUNTER_FN(read_sectors, READ_SECTORS_COUNT)
+MK_STATS_GET_COUNTER_FN(read_nsecs, READ_NSECS)
+MK_STATS_GET_COUNTER_FN(writes, WRITES_COUNT)
+MK_STATS_GET_COUNTER_FN(writes_merged, WRITES_MERGED_COUNT)
+MK_STATS_GET_COUNTER_FN(write_sectors, WRITE_SECTORS_COUNT)
+MK_STATS_GET_COUNTER_FN(write_nsecs, WRITE_NSECS)
+MK_STATS_GET_COUNTER_FN(io_in_progress, IO_IN_PROGRESS_COUNT)
+MK_STATS_GET_COUNTER_FN(io_nsecs, IO_NSECS)
+MK_STATS_GET_COUNTER_FN(weighted_io_nsecs, WEIGHTED_IO_NSECS)
+MK_STATS_GET_COUNTER_FN(total_read_nsecs, TOTAL_READ_NSECS)
+MK_STATS_GET_COUNTER_FN(total_write_nsecs, TOTAL_WRITE_NSECS)
 #undef MK_STATS_GET_COUNTER_FN
 
-int dm_stats_get_rd_merges_per_sec(const struct dm_stats *dms, double *rrqm,
-				   uint64_t region_id, uint64_t area_id)
-{
-	struct dm_stats_counters *c;
+/*
+ * Floating point stats metric functions
+ *
+ * Called from dm_stats_get_metric() to calculate the value of
+ * the requested metric.
+ *
+ * int _metric_name(const struct dm_stats *dms,
+ * 		    struct dm_stats_counters *c,
+ * 		    double *value);
+ *
+ * Calculate a metric value from the counter data for the given
+ * identifiers and store it in the memory pointed to by value,
+ * applying group or region aggregation if enabled.
+ *
+ * Return one on success or zero on failure.
+ *
+ * To add a new metric:
+ *
+ * o Add a new name to the dm_stats_metric_t enum.
+ * o Create a _metric_fn() to calculate the new metric.
+ * o Add _metric_fn to the _metrics function table
+ *   (entries in enum order).
+ * o Do not add a new named public function for the metric -
+ *   users of new metrics are encouraged to convert to the enum
+ *   based metric interface.
+ *
+ */
 
-	if (!dms->interval_ns)
-		return_0;
+static int _rd_merges_per_sec(const struct dm_stats *dms, double *rrqm,
+			      uint64_t region_id, uint64_t area_id)
+{
+	double mrgs;
+	mrgs = (double) dm_stats_get_counter(dms, DM_STATS_READS_MERGED_COUNT,
+					     region_id, area_id);
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
+	*rrqm = mrgs / (double) dms->interval_ns;
 
-	c = &(dms->regions[region_id].counters[area_id]);
-	*rrqm = ((double) c->reads_merged) / (double) dms->interval_ns;
 	return 1;
 }
 
-int dm_stats_get_wr_merges_per_sec(const struct dm_stats *dms, double *wrqm,
-				   uint64_t region_id, uint64_t area_id)
+static int _wr_merges_per_sec(const struct dm_stats *dms, double *wrqm,
+			      uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
+	double mrgs;
+	mrgs = (double) dm_stats_get_counter(dms, DM_STATS_WRITES_MERGED_COUNT,
+					     region_id, area_id);
 
-	if (!dms->interval_ns)
-		return_0;
+	*wrqm = mrgs / (double) dms->interval_ns;
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
-
-	c = &(dms->regions[region_id].counters[area_id]);
-	*wrqm = ((double) c->writes_merged) / (double) dms->interval_ns;
 	return 1;
 }
 
-int dm_stats_get_reads_per_sec(const struct dm_stats *dms, double *rd_s,
-			       uint64_t region_id, uint64_t area_id)
+static int _reads_per_sec(const struct dm_stats *dms, double *rd_s,
+			  uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
-
-	if (!dms->interval_ns)
-		return_0;
+	double reads;
+	reads = (double) dm_stats_get_counter(dms, DM_STATS_READS_COUNT,
+					      region_id, area_id);
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
+	*rd_s = (reads * NSEC_PER_SEC) / (double) dms->interval_ns;
 
-	c = &(dms->regions[region_id].counters[area_id]);
-	*rd_s = ((double) c->reads * NSEC_PER_SEC) / (double) dms->interval_ns;
 	return 1;
 }
 
-int dm_stats_get_writes_per_sec(const struct dm_stats *dms, double *wr_s,
-				uint64_t region_id, uint64_t area_id)
+static int _writes_per_sec(const struct dm_stats *dms, double *wr_s,
+			   uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
+	double writes;
+	writes = (double) dm_stats_get_counter(dms, DM_STATS_WRITES_COUNT,
+					       region_id, area_id);
 
-	if (!dms->interval_ns)
-		return_0;
+	*wr_s = (writes * NSEC_PER_SEC) / (double) dms->interval_ns;
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
+	return 1;
+}
+
+static int _read_sectors_per_sec(const struct dm_stats *dms, double *rsec_s,
+				 uint64_t region_id, uint64_t area_id)
+{
+	double sect;
+	sect = (double) dm_stats_get_counter(dms, DM_STATS_READ_SECTORS_COUNT,
+					     region_id, area_id);
 
-	c = &(dms->regions[region_id].counters[area_id]);
-	*wr_s = ((double) c->writes * (double) NSEC_PER_SEC)
-		 / (double) dms->interval_ns;
+	*rsec_s = (sect * (double) NSEC_PER_SEC) / (double) dms->interval_ns;
 
 	return 1;
 }
 
-int dm_stats_get_read_sectors_per_sec(const struct dm_stats *dms, double *rsec_s,
-				      uint64_t region_id, uint64_t area_id)
+static int _write_sectors_per_sec(const struct dm_stats *dms, double *wsec_s,
+				  uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
+	double sect;
+	sect = (double) dm_stats_get_counter(dms, DM_STATS_WRITE_SECTORS_COUNT,
+					     region_id, area_id);
 
-	if (!dms->interval_ns)
-		return_0;
+	*wsec_s = (sect * (double) NSEC_PER_SEC) / (double) dms->interval_ns;
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
+	return 1;
+}
 
-	c = &(dms->regions[region_id].counters[area_id]);
-	*rsec_s = ((double) c->read_sectors * (double) NSEC_PER_SEC)
-		   / (double) dms->interval_ns;
+static int _average_request_size(const struct dm_stats *dms, double *arqsz,
+				 uint64_t region_id, uint64_t area_id)
+{
+	double ios, sectors;
+
+	ios = (double) (dm_stats_get_counter(dms, DM_STATS_READS_COUNT,
+					     region_id, area_id)
+			+ dm_stats_get_counter(dms, DM_STATS_WRITES_COUNT,
+					       region_id, area_id));
+	sectors = (double) (dm_stats_get_counter(dms, DM_STATS_READ_SECTORS_COUNT,
+						 region_id, area_id)
+			    + dm_stats_get_counter(dms, DM_STATS_WRITE_SECTORS_COUNT,
+						   region_id, area_id));
+
+	if (ios > 0.0)
+		*arqsz = sectors / ios;
+	else
+		*arqsz = 0.0;
 
 	return 1;
 }
 
-int dm_stats_get_write_sectors_per_sec(const struct dm_stats *dms, double *wsec_s,
-				       uint64_t region_id, uint64_t area_id)
+static int _average_queue_size(const struct dm_stats *dms, double *qusz,
+			       uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
-
-	if (!dms->interval_ns)
-		return_0;
+	double io_ticks;
+	io_ticks = (double) dm_stats_get_counter(dms, DM_STATS_WEIGHTED_IO_NSECS,
+						 region_id, area_id);
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
+	if (io_ticks > 0.0)
+		*qusz = io_ticks / (double) dms->interval_ns;
+	else
+		*qusz = 0.0;
 
-	c = &(dms->regions[region_id].counters[area_id]);
-	*wsec_s = ((double) c->write_sectors * (double) NSEC_PER_SEC)
-		   / (double) dms->interval_ns;
 	return 1;
 }
 
-int dm_stats_get_average_request_size(const struct dm_stats *dms, double *arqsz,
-				      uint64_t region_id, uint64_t area_id)
+static int _average_wait_time(const struct dm_stats *dms, double *await,
+			      uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
-	uint64_t nr_ios, nr_sectors;
+	uint64_t io_ticks, nr_ios;
 
-	if (!dms->interval_ns)
-		return_0;
+	io_ticks = dm_stats_get_counter(dms, DM_STATS_READ_NSECS,
+					region_id, area_id);
+	io_ticks += dm_stats_get_counter(dms, DM_STATS_WRITE_NSECS,
+					 region_id, area_id);
 
-	*arqsz = 0.0;
+	nr_ios = dm_stats_get_counter(dms, DM_STATS_READS_COUNT,
+				      region_id, area_id);
+	nr_ios += dm_stats_get_counter(dms, DM_STATS_WRITES_COUNT,
+				       region_id, area_id);
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
+	if (nr_ios > 0)
+		*await = (double) io_ticks / (double) nr_ios;
+	else
+		*await = 0.0;
 
-	c = &(dms->regions[region_id].counters[area_id]);
-	nr_ios = c->reads + c->writes;
-	nr_sectors = c->read_sectors + c->write_sectors;
-	if (nr_ios)
-		*arqsz = (double) nr_sectors / (double) nr_ios;
 	return 1;
 }
 
-int dm_stats_get_average_queue_size(const struct dm_stats *dms, double *qusz,
-				    uint64_t region_id, uint64_t area_id)
+static int _average_rd_wait_time(const struct dm_stats *dms, double *await,
+				 uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
-	uint64_t io_ticks;
+	uint64_t rd_io_ticks, nr_rd_ios;
 
-	if (!dms->interval_ns)
-		return_0;
+	rd_io_ticks = dm_stats_get_counter(dms, DM_STATS_READ_NSECS,
+					   region_id, area_id);
 
-	*qusz = 0.0;
+	nr_rd_ios = dm_stats_get_counter(dms, DM_STATS_READS_COUNT,
+					 region_id, area_id);
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
+	if (rd_io_ticks > 0)
+		*await = (double) rd_io_ticks / (double) nr_rd_ios;
+	else
+		*await = 0.0;
 
-	c = &(dms->regions[region_id].counters[area_id]);
-	io_ticks = c->weighted_io_nsecs;
-	if (io_ticks)
-		*qusz = (double) io_ticks / (double) dms->interval_ns;
 	return 1;
 }
 
-int dm_stats_get_average_wait_time(const struct dm_stats *dms, double *await,
-				   uint64_t region_id, uint64_t area_id)
+static int _average_wr_wait_time(const struct dm_stats *dms, double *await,
+				 uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
-	uint64_t io_ticks, nr_ios;
-
-	if (!dms->interval_ns)
-		return_0;
+	uint64_t wr_io_ticks, nr_wr_ios;
 
-	*await = 0.0;
+	wr_io_ticks = dm_stats_get_counter(dms, DM_STATS_WRITE_NSECS,
+					   region_id, area_id);
+	nr_wr_ios = dm_stats_get_counter(dms, DM_STATS_WRITES_COUNT,
+					 region_id, area_id);
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
+	if (wr_io_ticks > 0)
+		*await = (double) wr_io_ticks / (double) nr_wr_ios;
+	else
+		*await = 0.0;
 
-	c = &(dms->regions[region_id].counters[area_id]);
-	io_ticks = c->read_nsecs + c->write_nsecs;
-	nr_ios = c->reads + c->writes;
-	if (nr_ios)
-		*await = (double) io_ticks / (double) nr_ios;
 	return 1;
 }
 
-int dm_stats_get_average_rd_wait_time(const struct dm_stats *dms,
-				      double *await, uint64_t region_id,
-				      uint64_t area_id)
+static int _throughput(const struct dm_stats *dms, double *tput,
+		       uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
-	uint64_t rd_io_ticks, nr_rd_ios;
+	uint64_t nr_ios;
 
-	if (!dms->interval_ns)
-		return_0;
+	nr_ios = dm_stats_get_counter(dms, DM_STATS_READS_COUNT,
+				      region_id, area_id);
+	nr_ios += dm_stats_get_counter(dms, DM_STATS_WRITES_COUNT,
+				       region_id, area_id);
 
-	*await = 0.0;
+	*tput = ((double) NSEC_PER_SEC * (double) nr_ios)
+		/ (double) (dms->interval_ns);
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
-
-	c = &(dms->regions[region_id].counters[area_id]);
-	rd_io_ticks = c->read_nsecs;
-	nr_rd_ios = c->reads;
-	if (rd_io_ticks)
-		*await = (double) rd_io_ticks / (double) nr_rd_ios;
 	return 1;
 }
 
-int dm_stats_get_average_wr_wait_time(const struct dm_stats *dms,
-				      double *await, uint64_t region_id,
-				      uint64_t area_id)
+static int _utilization(const struct dm_stats *dms, double *util,
+			uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
-	uint64_t wr_io_ticks, nr_wr_ios;
+	uint64_t io_nsecs, interval_ns = dms->interval_ns;
 
-	if (!dms->interval_ns)
-		return_0;
+	/**
+	 * If io_nsec > interval_ns there is something wrong with the clock
+	 * for the last interval; do not allow a value > 100% utilization
+	 * to be passed to a dm_make_percent() call. We expect to see these
+	 * at startup if counters have not been cleared before the first read.
+	 */
+	io_nsecs = dm_stats_get_counter(dms, DM_STATS_IO_NSECS,
+					region_id, area_id);
 
-	*await = 0.0;
+	io_nsecs = ((io_nsecs < interval_ns) ? io_nsecs : interval_ns);
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
+	*util = (double) io_nsecs / (double) interval_ns;
 
-	c = &(dms->regions[region_id].counters[area_id]);
-	wr_io_ticks = c->write_nsecs;
-	nr_wr_ios = c->writes;
-	if (wr_io_ticks && nr_wr_ios)
-		*await = (double) wr_io_ticks / (double) nr_wr_ios;
 	return 1;
 }
 
-int dm_stats_get_service_time(const struct dm_stats *dms, double *svctm,
-			      uint64_t region_id, uint64_t area_id)
+static int _service_time(const struct dm_stats *dms, double *svctm,
+			 uint64_t region_id, uint64_t area_id)
 {
-	dm_percent_t util;
-	double tput;
+	double tput, util;
 
-	if (!dm_stats_get_throughput(dms, &tput, region_id, area_id))
-		return_0;
+	if (!_throughput(dms, &tput, region_id, area_id))
+		return 0;
 
-	if (!dm_stats_get_utilization(dms, &util, region_id, area_id))
-		return_0;
+	if (!_utilization(dms, &util, region_id, area_id))
+		return 0;
+
+	util *= 100;
 
 	/* avoid NAN with zero counter values */
 	if ( (uint64_t) tput == 0 || (uint64_t) util == 0) {
 		*svctm = 0.0;
 		return 1;
 	}
+
 	*svctm = ((double) NSEC_PER_SEC * dm_percent_to_float(util))
 		  / (100.0 * tput);
+
 	return 1;
 }
 
-int dm_stats_get_throughput(const struct dm_stats *dms, double *tput,
-			    uint64_t region_id, uint64_t area_id)
-{
-	struct dm_stats_counters *c;
+/*
+ * Table in enum order:
+ *      DM_STATS_RD_MERGES_PER_SEC,
+ *      DM_STATS_WR_MERGES_PER_SEC,
+ *      DM_STATS_READS_PER_SEC,
+ *      DM_STATS_WRITES_PER_SEC,
+ *      DM_STATS_READ_SECTORS_PER_SEC,
+ *      DM_STATS_WRITE_SECTORS_PER_SEC,
+ *      DM_STATS_AVERAGE_REQUEST_SIZE,
+ *      DM_STATS_AVERAGE_QUEUE_SIZE,
+ *      DM_STATS_AVERAGE_WAIT_TIME,
+ *      DM_STATS_AVERAGE_RD_WAIT_TIME,
+ *      DM_STATS_AVERAGE_WR_WAIT_TIME
+ *      DM_STATS_SERVICE_TIME,
+ *      DM_STATS_THROUGHPUT,
+ *      DM_STATS_UTILIZATION
+ *
+*/
+
+typedef int (*_metric_fn_t)(const struct dm_stats *, double *,
+			    uint64_t, uint64_t);
+
+_metric_fn_t _metrics[DM_STATS_NR_METRICS] = {
+	_rd_merges_per_sec,
+	_wr_merges_per_sec,
+	_reads_per_sec,
+	_writes_per_sec,
+	_read_sectors_per_sec,
+	_write_sectors_per_sec,
+	_average_request_size,
+	_average_queue_size,
+	_average_wait_time,
+	_average_rd_wait_time,
+	_average_wr_wait_time,
+	_service_time,
+	_throughput,
+	_utilization
+};
 
+int dm_stats_get_metric(const struct dm_stats *dms, int metric,
+			uint64_t region_id, uint64_t area_id, double *value)
+{
 	if (!dms->interval_ns)
 		return_0;
 
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
-
-	c = &(dms->regions[region_id].counters[area_id]);
+	if (metric < 0 || metric >= DM_STATS_NR_METRICS) {
+		log_error("Attempt to read invalid metric: %d", metric);
+		return 0;
+	}
 
-	*tput = (( NSEC_PER_SEC * ((double) c->reads + (double) c->writes))
-		 / (double) (dms->interval_ns));
-	return 1;
+	return _metrics[metric](dms, value, region_id, area_id);
 }
 
+/**
+ * Methods for accessing stats metrics. All methods share the
+ * following naming scheme and prototype:
+ *
+ * uint64_t dm_stats_get_metric(struct dm_stats *,
+ * 				int, int,
+ * 				uint64_t, uint64_t,
+ * 				double *v)
+ *
+ * Where the two integer arguments are the region_id and area_id
+ * respectively.
+ *
+ * name is the name of the metric (lower case)
+ * metric is the part of the enum name following DM_STATS_ (upper case)
+ */
+#define MK_STATS_GET_METRIC_FN(name, metric, meta)			\
+int dm_stats_get_ ## name(const struct dm_stats *dms, double *meta,	\
+			  uint64_t region_id, uint64_t area_id)		\
+{									\
+	return dm_stats_get_metric(dms, DM_STATS_ ## metric, 		\
+				   region_id, area_id, meta);		\
+}
+
+MK_STATS_GET_METRIC_FN(rd_merges_per_sec, RD_MERGES_PER_SEC, rrqm)
+MK_STATS_GET_METRIC_FN(wr_merges_per_sec, WR_MERGES_PER_SEC, wrqm)
+MK_STATS_GET_METRIC_FN(reads_per_sec, READS_PER_SEC, rd_s)
+MK_STATS_GET_METRIC_FN(writes_per_sec, WRITES_PER_SEC, wr_s)
+MK_STATS_GET_METRIC_FN(read_sectors_per_sec, READ_SECTORS_PER_SEC, rsec_s)
+MK_STATS_GET_METRIC_FN(write_sectors_per_sec, WRITE_SECTORS_PER_SEC, wsec_s)
+MK_STATS_GET_METRIC_FN(average_request_size, AVERAGE_REQUEST_SIZE, arqsz)
+MK_STATS_GET_METRIC_FN(average_queue_size, AVERAGE_QUEUE_SIZE, qusz)
+MK_STATS_GET_METRIC_FN(average_wait_time, AVERAGE_WAIT_TIME, await)
+MK_STATS_GET_METRIC_FN(average_rd_wait_time, AVERAGE_RD_WAIT_TIME, await)
+MK_STATS_GET_METRIC_FN(average_wr_wait_time, AVERAGE_WR_WAIT_TIME, await)
+MK_STATS_GET_METRIC_FN(service_time, SERVICE_TIME, svctm)
+MK_STATS_GET_METRIC_FN(throughput, THROUGHPUT, tput)
+
+/*
+ * Utilization is an exception since it used the dm_percent_t type in the
+ * original named function based interface: preserve this behaviour for
+ * backwards compatibility with existing users.
+ *
+ * The same metric may be accessed as a double via the enum based metric
+ * interface.
+ */
 int dm_stats_get_utilization(const struct dm_stats *dms, dm_percent_t *util,
 			     uint64_t region_id, uint64_t area_id)
 {
-	struct dm_stats_counters *c;
-	uint64_t io_nsecs;
+	double _util;
 
-	if (!dms->interval_ns)
+	if (!dm_stats_get_metric(dms, DM_STATS_UTILIZATION,
+				 region_id, area_id, &_util))
 		return_0;
-
-	region_id = (region_id == DM_STATS_REGION_CURRENT)
-		     ? dms->cur_region : region_id ;
-	area_id = (area_id == DM_STATS_REGION_CURRENT)
-		   ? dms->cur_area : area_id ;
-
-	c = &(dms->regions[region_id].counters[area_id]);
-
-	/**
-	 * If io_nsec > interval_ns there is something wrong with the clock
-	 * for the last interval; do not allow a value > 100% utilization
-	 * to be passed to a dm_make_percent() call. We expect to see these
-	 * at startup if counters have not been cleared before the first read.
-	 */
-	io_nsecs = (c->io_nsecs <= dms->interval_ns) ? c->io_nsecs : dms->interval_ns;
-	*util = dm_make_percent(io_nsecs, dms->interval_ns);
-
+	/* scale up utilization value in the range [0.00..1.00] */
+	*util = dm_make_percent(DM_PERCENT_1 * _util, DM_PERCENT_1);
 	return 1;
 }
 



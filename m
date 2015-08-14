From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 12:56:32 +0000 (UTC)
Subject: master - dmstats: separate stats meta fields into their own report type
Message-ID: <20150814125632.5F15960EDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37dd26e322bc2fc3fa0fd7dd85d1972b08fca36c
Commit:        37dd26e322bc2fc3fa0fd7dd85d1972b08fca36c
Parent:        f10ad95c3678f51c26ed55216f4337e78c992375
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Aug 13 21:14:57 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 13:43:03 2015 +0100

dmstats: separate stats meta fields into their own report type

Although statistics and meta fields (region and area properties) share
the same object type the state of the handle they expect differs: meta
only expects a dm_stats_list() operation to have been performed whereas
statistics require a fully populated handle.

Distinguish between these requirements by separating the fields into
two distinct report types:

  DR_STATS = 32,
  DR_STATS_META = 64

The new category is described as "Mapped Device Statistics Region
Information" in the help text.
---
 tools/dmsetup.c |  102 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 53 insertions(+), 49 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 68ca7e0..db2c3e4 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -222,7 +222,8 @@ typedef enum {
 	DR_DEPS = 4,
 	DR_TREE = 8,	/* Complete dependency tree required */
 	DR_NAME = 16,
-	DR_STATS = 32,
+	DR_STATS = 32,  /* Requires populated stats handle. */
+	DR_STATS_META = 64, /* Requires listed stats handle. */
 } report_type_t;
 
 typedef enum {
@@ -3376,39 +3377,6 @@ static int _dm_stats_aux_data_disp(struct dm_report *rh,
 	return dm_report_field_string(rh, field, (const char * const*) &aux_data);
 }
 
-static int _dm_stats_sample_interval_ns_disp(struct dm_report *rh,
-					     struct dm_pool *mem __attribute__((unused)),
-					     struct dm_report_field *field, const void *data,
-					     void *private __attribute__((unused)))
-{
-	/* FIXME: use internal interval estimate when supported by libdm */
-	return dm_report_field_uint64(rh, field, &_last_interval);
-}
-
-static int _dm_stats_sample_interval_disp(struct dm_report *rh,
-					  struct dm_pool *mem __attribute__((unused)),
-					  struct dm_report_field *field, const void *data,
-					  void *private __attribute__((unused)))
-{
-	char buf[64];
-	char *repstr;
-	double *sortval;
-
-	if (!(sortval = dm_pool_alloc(mem, sizeof(*sortval))))
-		return_0;
-
-	*sortval = (double)_last_interval / (double) NSEC_PER_SEC;
-
-	if (!dm_snprintf(buf, sizeof(buf), "%2.6f", *sortval))
-		return_0;
-
-	if (!(repstr = dm_pool_strdup(mem, buf)))
-		return_0;
-
-	dm_report_field_set_value(field, repstr, sortval);
-	return 1;
-}
-
 static int _dm_stats_rrqm_disp(struct dm_report *rh,
 			       struct dm_pool *mem __attribute__((unused)),
 			       struct dm_report_field *field, const void *data,
@@ -3837,6 +3805,39 @@ static int _dm_stats_util_disp(struct dm_report *rh,
 	return 1;
 }
 
+static int _dm_stats_sample_interval_ns_disp(struct dm_report *rh,
+					     struct dm_pool *mem __attribute__((unused)),
+					     struct dm_report_field *field, const void *data,
+					     void *private __attribute__((unused)))
+{
+	/* FIXME: use internal interval estimate when supported by libdm */
+	return dm_report_field_uint64(rh, field, &_last_interval);
+}
+
+static int _dm_stats_sample_interval_disp(struct dm_report *rh,
+					  struct dm_pool *mem __attribute__((unused)),
+					  struct dm_report_field *field, const void *data,
+					  void *private __attribute__((unused)))
+{
+	char buf[64];
+	char *repstr;
+	double *sortval;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(*sortval))))
+		return_0;
+
+	*sortval = (double)_last_interval / (double) NSEC_PER_SEC;
+
+	if (!dm_snprintf(buf, sizeof(buf), "%2.6f", *sortval))
+		return_0;
+
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
 static void *_task_get_obj(void *obj)
 {
 	return ((struct dmsetup_report_obj *)obj)->task;
@@ -3874,6 +3875,7 @@ static const struct dm_report_object_type _report_types[] = {
 	{ DR_TREE, "Mapped Device Relationship Information", "", _tree_get_obj },
 	{ DR_NAME, "Mapped Device Name Components", "", _split_name_get_obj },
 	{ DR_STATS, "Mapped Device Statistics","", _stats_get_obj },
+	{ DR_STATS_META, "Mapped Device Statistics Region Information","", _stats_get_obj },
 	{ 0, "", "", NULL }
 };
 
@@ -3940,19 +3942,6 @@ FIELD_F(STATS, NUM, "WtIoNsec", 8, dm_stats_weighted_io_nsecs, "weighted_io_nsec
 FIELD_F(STATS, NUM, "TotalRdNsec", 8, dm_stats_total_read_nsecs, "total_rd_nsecs", "Total time spent reading.")
 FIELD_F(STATS, NUM, "TotalWrNsec", 8, dm_stats_total_write_nsecs, "total_wr_nsecs", "Total time spent writing.")
 
-/* Stats report meta-fields */
-FIELD_F(STATS, NUM, "RgID", 5, dm_stats_region_id, "region_id", "Region ID.")
-FIELD_F(STATS, SIZ, "RStart", 5, dm_stats_region_start, "region_start", "Region start.")
-FIELD_F(STATS, SIZ, "RSize", 5, dm_stats_region_len, "region_len", "Region length.")
-FIELD_F(STATS, NUM, "ArID", 5, dm_stats_area_id, "area_id", "Area ID.")
-FIELD_F(STATS, SIZ, "AStrt", 5, dm_stats_area_start, "area_start", "Area start.")
-FIELD_F(STATS, SIZ, "ASize", 5, dm_stats_area_len, "area_len", "Area length.")
-FIELD_F(STATS, NUM, "#Areas", 6, dm_stats_area_count, "area_count", "Area count.")
-FIELD_F(STATS, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
-FIELD_F(STATS, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
-FIELD_F(STATS, NUM, "IntervalNSec", 10, dm_stats_sample_interval_ns, "interval_ns", "Sampling interval in nanoseconds.")
-FIELD_F(STATS, NUM, "Interval", 8, dm_stats_sample_interval, "interval", "Sampling interval.")
-
 /* Stats derived metrics */
 FIELD_F(STATS, NUM, "RRqM/s", 8, dm_stats_rrqm, "rrqm", "Read requests merged per second.")
 FIELD_F(STATS, NUM, "WRqM/s", 8, dm_stats_wrqm, "wrqm", "Write requests merged per second.")
@@ -3969,6 +3958,21 @@ FIELD_F(STATS, NUM, "TPut", 5, dm_stats_tput, "tput", "Throughput.")
 FIELD_F(STATS, NUM, "SvcTm", 5, dm_stats_svctm, "svctm", "Service time.")
 FIELD_F(STATS, NUM, "Util%", 10, dm_stats_util, "util", "Utilization.")
 
+/* Stats interval duration estimates */
+FIELD_F(STATS, NUM, "IntervalNSec", 10, dm_stats_sample_interval_ns, "interval_ns", "Sampling interval in nanoseconds.")
+FIELD_F(STATS, NUM, "Interval", 8, dm_stats_sample_interval, "interval", "Sampling interval.")
+
+/* Stats report meta-fields */
+FIELD_F(STATS_META, NUM, "RgID", 5, dm_stats_region_id, "region_id", "Region ID.")
+FIELD_F(STATS_META, SIZ, "RStart", 5, dm_stats_region_start, "region_start", "Region start.")
+FIELD_F(STATS_META, SIZ, "RSize", 5, dm_stats_region_len, "region_len", "Region length.")
+FIELD_F(STATS_META, NUM, "ArID", 5, dm_stats_area_id, "area_id", "Area ID.")
+FIELD_F(STATS_META, SIZ, "AStrt", 5, dm_stats_area_start, "area_start", "Area start.")
+FIELD_F(STATS_META, SIZ, "ASize", 5, dm_stats_area_len, "area_len", "Area length.")
+FIELD_F(STATS_META, NUM, "#Areas", 6, dm_stats_area_count, "area_count", "Area count.")
+FIELD_F(STATS_META, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
+FIELD_F(STATS_META, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
+
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };
@@ -4011,12 +4015,12 @@ static int _report_init(const struct command *cmd)
 
 	if (cmd && !strcmp(cmd->name, "stats")) {
 		options = (char *) _stats_default_report_options;
-		_report_type |= DR_STATS;
+		_report_type |= (DR_STATS | DR_STATS_META);
 	}
 
 	if (cmd && !strcmp(cmd->name, "list")) {
 		options = (char *) _stats_list_options;
-		_report_type |= DR_STATS;
+		_report_type |= DR_STATS_META;
 	}
 
 	/* emulate old dmsetup behaviour */



From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:36 +0000 (UTC)
Subject: master - libdm: use defined constants for buffer sizes
Message-ID: <20160705185436.408CE60DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62050760aa15e7059ea768b81abcd4d773ed6cab
Commit:        62050760aa15e7059ea768b81abcd4d773ed6cab
Parent:        2cb9794da2bea5b47b8f3812e445c1ba7868d1c8
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jun 16 19:40:43 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

libdm: use defined constants for buffer sizes

Introduce constants for the buffer sizes that libdm-stats uses:
one for messages sent to the kernel, one for rows of response data
returned, and a pair for the "start+len" range and histogram bounds
strings.
---
 libdm/libdm-stats.c |   34 +++++++++++++++++++++-------------
 1 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 537caab..dcde991 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -26,6 +26,9 @@
 #define PRECISE_ARG "precise_timestamps"
 #define HISTOGRAM_ARG "histogram:"
 
+#define STATS_ROW_BUF_LEN 4096
+#define STATS_MSG_BUF_LEN 1024
+
 /* Histogram bin */
 struct dm_histogram_bin {
 	uint64_t upper; /* Upper bound on this bin. */
@@ -109,7 +112,7 @@ struct dm_stats {
 static char *_program_id_from_proc(void)
 {
 	FILE *comm = NULL;
-	char buf[256];
+	char buf[STATS_ROW_BUF_LEN];
 
 	if (!(comm = fopen(PROC_SELF_COMM, "r")))
 		return_NULL;
@@ -820,7 +823,7 @@ bad:
 static int _stats_parse_list_region(struct dm_stats *dms,
 				    struct dm_stats_region *region, char *line)
 {
-	char *p = NULL, string_data[4096]; /* FIXME: add dm_sscanf with %ms? */
+	char *p = NULL, string_data[STATS_ROW_BUF_LEN];
 	char *program_id, *aux_data, *stats_args;
 	char *empty_string = (char *) "";
 	int r;
@@ -900,9 +903,8 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 	struct dm_stats_region cur, fill;
 	struct dm_stats_group cur_group;
 	struct dm_pool *mem = dms->mem, *group_mem = dms->group_mem;
+	char line[STATS_ROW_BUF_LEN];
 	FILE *list_rows;
-	/* FIXME: use correct maximum line length for kernel format */
-	char line[256];
 
 	if (!resp) {
 		log_error("Could not parse NULL @stats_list response.");
@@ -1003,8 +1005,8 @@ bad:
 
 int dm_stats_list(struct dm_stats *dms, const char *program_id)
 {
+	char msg[STATS_MSG_BUF_LEN];
 	struct dm_task *dmt;
-	char msg[256];
 	int r;
 
 	if (!_stats_bound(dms))
@@ -1130,7 +1132,7 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 	struct dm_stats_counters cur;
 	FILE *stats_rows = NULL;
 	uint64_t start = 0, len = 0;
-	char row[256];
+	char row[STATS_ROW_BUF_LEN];
 	int r;
 
 	if (!resp) {
@@ -1541,7 +1543,7 @@ static int _stats_set_aux(struct dm_stats *dms,
 {
 	const char *group_tag = NULL;
 	struct dm_task *dmt = NULL;
-	char msg[1024];
+	char msg[STATS_MSG_BUF_LEN];
 
 	/* group data required? */
 	if (_stats_group_id_present(dms, region_id)) {
@@ -1575,15 +1577,20 @@ bad:
 	return 0;
 }
 
+/*
+ * Maximum length of a "start+end" range string:
+ * Two 20 digit uint64_t, '+', and NULL.
+ */
+#define RANGE_LEN 42
 static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 				uint64_t start, uint64_t len, int64_t step,
 				int precise, const char *hist_arg,
 				const char *program_id,	const char *aux_data)
 {
+	char msg[STATS_MSG_BUF_LEN], range[RANGE_LEN], *endptr = NULL;
 	const char *err_fmt = "Could not prepare @stats_create %s.";
 	const char *precise_str = PRECISE_ARG;
 	const char *resp, *opt_args = NULL;
-	char msg[1024], range[64], *endptr = NULL;
 	struct dm_task *dmt = NULL;
 	int r = 0, nr_opt = 0;
 
@@ -1722,8 +1729,8 @@ static int _stats_remove_region_id_from_group(struct dm_stats *dms,
 
 int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 {
+	char msg[STATS_MSG_BUF_LEN];
 	struct dm_task *dmt;
-	char msg[1024];
 
 	if (!_stats_bound(dms))
 		return_0;
@@ -1772,8 +1779,8 @@ int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 
 int dm_stats_clear_region(struct dm_stats *dms, uint64_t region_id)
 {
+	char msg[STATS_MSG_BUF_LEN];
 	struct dm_task *dmt;
-	char msg[1024];
 
 	if (!_stats_bound(dms))
 		return_0;
@@ -1799,8 +1806,8 @@ static struct dm_task *_stats_print_region(struct dm_stats *dms,
 {
 	/* @stats_print[_clear] <region_id> [<start_line> <num_lines>] */
 	const char *err_fmt = "Could not prepare @stats_print %s.";
+	char msg[STATS_MSG_BUF_LEN], lines[RANGE_LEN];
 	struct dm_task *dmt = NULL;
-	char msg[1024], lines[64];
 
 	if (start_line || num_lines)
 		if (!dm_snprintf(lines, sizeof(lines),
@@ -2951,14 +2958,15 @@ static void _scale_bound_value_to_suffix(uint64_t *bound, const char **suffix)
 }
 
 #define DM_HISTOGRAM_BOUNDS_MASK 0x30
+#define BOUNDS_LEN 64
 
 static int _make_bounds_string(char *buf, size_t size, uint64_t lower,
 			       uint64_t upper, int flags, int width)
 {
+	char bound_buf[BOUNDS_LEN];
 	const char *l_suff = NULL;
 	const char *u_suff = NULL;
 	const char *sep = "";
-	char bound_buf[32];
 	int bounds = flags & DM_HISTOGRAM_BOUNDS_MASK;
 
 	if (!bounds)
@@ -3015,11 +3023,11 @@ out:
 const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 				   int width, int flags)
 {
+	char buf[BOUNDS_LEN], bounds_buf[BOUNDS_LEN];
 	int minwidth, bounds, values, start, last;
 	uint64_t lower, upper, val_u64; /* bounds of the current bin. */
 	/* Use the histogram pool for string building. */
 	struct dm_pool *mem = dmh->dms->hist_mem;
-	char buf[64], bounds_buf[64];
 	const char *sep = "";
 	int bounds_width;
 	ssize_t len = 0;



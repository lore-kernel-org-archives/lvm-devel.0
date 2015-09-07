From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  7 Sep 2015 19:15:05 +0000 (UTC)
Subject: master - libdm: clean up stats local variable use
Message-ID: <20150907191505.4145D61655@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7f45ebca52ecb7e15dee42f81718266b127bb5c
Commit:        d7f45ebca52ecb7e15dee42f81718266b127bb5c
Parent:        daa94eb792ee76a507dcafe74c5ceda9707a370f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 7 20:08:10 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 7 20:14:53 2015 +0100

libdm: clean up stats local variable use

---
 libdm/libdm-stats.c |   76 ++++++++++++++++++++++++---------------------------
 1 files changed, 36 insertions(+), 40 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index f239f01..ee62fe6 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -454,13 +454,13 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 				       const char *histogram)
 {
 	static const char *_valid_chars = "0123456789,";
-	uint64_t scale = region->timescale;
+	uint64_t scale = region->timescale, this_val = 0;
 	struct dm_pool *mem = dms->hist_mem;
 	struct dm_histogram_bin cur;
 	struct dm_histogram hist;
 	int nr_bins = 1;
-	const char *c, *v;
-	char *p;
+	const char *c, *v, *val_start;
+	char *p, *endptr = NULL;
 
 	/* Advance past "histogram:". */
 	histogram = strchr(histogram, ':');
@@ -501,9 +501,8 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 				  histogram);
 			goto bad;
 		} else {
-			const char *val_start = c;
-			char *endptr = NULL;
-			uint64_t this_val = 0;
+			val_start = c;
+			endptr = NULL;
 
 			this_val = strtoull(val_start, &endptr, 10);
 			if (!endptr) {
@@ -627,11 +626,11 @@ static int _stats_parse_list_region(struct dm_stats *dms,
 
 static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 {
-	struct dm_pool *mem = dms->mem;
-	struct dm_stats_region cur;
 	uint64_t max_region = 0, nr_regions = 0;
+	struct dm_stats_region cur, fill;
+	struct dm_pool *mem = dms->mem;
 	FILE *list_rows;
-	/* FIXME: determine correct maximum line length based on kernel format */
+	/* FIXME: use correct maximum line length for kernel format */
 	char line[256];
 
 	if (!resp) {
@@ -666,7 +665,6 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 
 		/* handle holes in the list of region_ids */
 		if (cur.region_id > max_region) {
-			struct dm_stats_region fill;
 			memset(&fill, 0, sizeof(fill));
 			fill.region_id = DM_STATS_REGION_NOT_PRESENT;
 			do {
@@ -742,12 +740,13 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 				  struct dm_histogram **histogram,
 				  struct dm_stats_region *region)
 {
+	struct dm_histogram hist, *bounds = region->bounds;
 	static const char *_valid_chars = "0123456789:";
 	int nr_bins = region->bounds->nr_bins;
-	struct dm_histogram hist, *bounds = region->bounds;
+	const char *c, *v, *val_start;
 	struct dm_histogram_bin cur;
-	uint64_t sum = 0;
-	const char *c, *v;
+	uint64_t sum = 0, this_val;
+	char *endptr = NULL;
 	int bin = 0;
 
 	c = hist_str;
@@ -771,9 +770,8 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 		if (*c == ',')
 			goto badchar;
 		else {
-			const char *val_start = c;
-			char *endptr = NULL;
-			uint64_t this_val = 0;
+			val_start = c;
+			endptr = NULL;
 
 			this_val = strtoull(val_start, &endptr, 10);
 			if (!endptr) {
@@ -821,8 +819,8 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 			       uint64_t timescale)
 {
 	struct dm_histogram *hist = NULL;
-	struct dm_stats_counters cur;
 	struct dm_pool *mem = dms->mem;
+	struct dm_stats_counters cur;
 	FILE *stats_rows = NULL;
 	uint64_t start, len;
 	char row[256];
@@ -1075,12 +1073,12 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 				int precise, const char *hist_arg,
 				const char *program_id,	const char *aux_data)
 {
-	struct dm_task *dmt = NULL;
-	char msg[1024], range[64];
 	const char *err_fmt = "Could not prepare @stats_create %s.";
 	const char *precise_str = PRECISE_ARG;
 	const char *resp, *opt_args = NULL;
-	int r = 0, nr_opt = 0; /* number of optional args. */
+	char msg[1024], range[64], *endptr = NULL;
+	struct dm_task *dmt = NULL;
+	int r = 0, nr_opt = 0;
 
 	if (!_stats_bound(dms))
 		return_0;
@@ -1140,7 +1138,6 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	}
 
 	if (region_id) {
-		char *endptr = NULL;
 		*region_id = strtoull(resp, &endptr, 10);
 		if (resp == endptr)
 			goto_out;
@@ -1230,11 +1227,11 @@ static struct dm_task *_stats_print_region(struct dm_stats *dms,
 				    uint64_t region_id, unsigned start_line,
 				    unsigned num_lines, unsigned clear)
 {
-	struct dm_task *dmt = NULL;
 	/* @stats_print[_clear] <region_id> [<start_line> <num_lines>] */
 	const char *clear_str = "_clear", *lines_fmt = "%u %u";
 	const char *msg_fmt = "@stats_print%s " FMTu64 " %s";
 	const char *err_fmt = "Could not prepare @stats_print %s.";
+	struct dm_task *dmt = NULL;
 	char msg[1024], lines[64];
 
 	if (start_line || num_lines)
@@ -1327,6 +1324,8 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 		      uint64_t region_id)
 {
 	int all_regions = (region_id == DM_STATS_REGIONS_ALL);
+	struct dm_task *dmt = NULL; /* @stats_print task */
+	const char *resp;
 
 	if (!_stats_bound(dms))
 		return_0;
@@ -1346,9 +1345,6 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 
 	dm_stats_walk_start(dms);
 	do {
-		struct dm_task *dmt = NULL; /* @stats_print task */
-		const char *resp;
-
 		region_id = (all_regions)
 			     ? dm_stats_get_current_region(dms) : region_id;
 
@@ -2002,10 +1998,12 @@ static struct dm_histogram *_alloc_dm_histogram(int nr_bins)
 struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str)
 {
 	static const char *_valid_chars = "0123456789,muns";
-	struct dm_histogram *dmh;
+	uint64_t this_val = 0, mult = 1;
+	const char *c, *v, *val_start;
 	struct dm_histogram_bin *cur;
-	const char *c, *v;
+	struct dm_histogram *dmh;
 	int nr_entries = 1;
+	char *endptr;
 
 	c = bounds_str;
 
@@ -2038,9 +2036,8 @@ struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str)
 				  bounds_str);
 			goto bad;
 		} else {
-			const char *val_start = c;
-			char *endptr = NULL;
-			uint64_t this_val = 0, mult = 1;
+			val_start = c;
+			endptr = NULL;
 
 			this_val = strtoull(val_start, &endptr, 10);
 			if (!endptr) {
@@ -2093,10 +2090,10 @@ bad:
 
 struct dm_histogram *dm_histogram_bounds_from_uint64(const uint64_t *bounds)
 {
-	struct dm_histogram *dmh;
+	const uint64_t *entry = bounds;
 	struct dm_histogram_bin *cur;
+	struct dm_histogram *dmh;
 	int nr_entries = 1;
-	const uint64_t *entry = bounds;
 
 	if (!bounds || !bounds[0]) {
 		log_error("Could not parse empty histogram bounds array");
@@ -2227,12 +2224,14 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 				   int width, int flags)
 {
 	int minwidth, bounds, values, start, last;
-	uint64_t lower, upper; /* bounds of the current bin. */
+	uint64_t lower, upper, val_u64; /* bounds of the current bin. */
 	/* Use the histogram pool for string building. */
 	struct dm_pool *mem = dmh->dms->hist_mem;
 	char buf[64], bounds_buf[64];
 	const char *sep = "";
+	int bounds_width;
 	ssize_t len = 0;
+	float val_flt;
 
 	bounds = flags & DM_HISTOGRAM_BOUNDS_MASK;
 	values = flags & DM_HISTOGRAM_VALUES;
@@ -2263,8 +2262,6 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 
 	for (bin = start; bin <= last; bin++) {
 		if (bounds) {
-			int bounds_width;
-
 			/* Default bounds width depends on time suffixes. */
 			bounds_width = (!(flags & DM_HISTOGRAM_SUFFIX))
 					? BOUND_WIDTH_NOSUFFIX
@@ -2297,15 +2294,14 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 
 		if (flags & DM_HISTOGRAM_PERCENT) {
 			dm_percent_t pr;
-			float value;
 			pr = dm_histogram_get_bin_percent(dmh, bin);
-			value = dm_percent_to_float(pr);
+			val_flt = dm_percent_to_float(pr);
 			len = dm_snprintf(buf, sizeof(buf), "%s%*.2f%%%s",
-					  bounds_buf, width, value, sep);
+					  bounds_buf, width, val_flt, sep);
 		} else if (values) {
-			uint64_t value = dmh->bins[bin].count;
+			val_u64 = dmh->bins[bin].count;
 			len = dm_snprintf(buf, sizeof(buf), "%s%*"PRIu64"%s",
-					  bounds_buf, width, value, sep);
+					  bounds_buf, width, val_u64, sep);
 		} else if (bounds)
 			len = dm_snprintf(buf, sizeof(buf), "%s%s", bounds_buf,
 					  sep);



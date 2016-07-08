From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:27:01 +0000 (UTC)
Subject: master - dmstats: group regions by default with --segments
Message-ID: <20160708182701.A9D8C610EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd1f4987eb954705e6ba8997ac37de025074e539
Commit:        bd1f4987eb954705e6ba8997ac37de025074e539
Parent:        db63587ce2473f3ceaea1c8ccc911eb3f1cacd0f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 7 13:53:06 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

dmstats: group regions by default with --segments

Grouping is also useful in combination with --segments: creating a
group allows both individual segment data and data for the device
as a whole to be presented in the same report.

Support grouping for 'create --segments' in the same manner as for
'create --filemap'; group regions by default, applying an optional
alias specified with --alias, unless the user specifies --nogroup.
---
 tools/dmsetup.c |   83 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 76 insertions(+), 7 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b31788c..eb7c83a 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4768,6 +4768,56 @@ static uint64_t _nr_areas_from_step(uint64_t len, int64_t step)
 	return (len / step) + !!(len % (uint64_t) step);
 }
 
+/* maximum length of a string representation of an integer */
+#define max_int_strlen(i) (strlen(#i))
+#define MAX_UINT64_STRLEN max_int_strlen(UINT64_MAX)
+static int _stats_group_segments(struct dm_stats *dms, uint64_t *region_ids,
+				 int count, const char *alias)
+{
+	/* NULL, commas, and count * region_id */
+	size_t bufsize = 1 + count + count * MAX_UINT64_STRLEN;
+	char *this_region, *regions = NULL;
+	uint64_t group_id;
+	int r, i;
+
+	this_region = regions = dm_malloc(bufsize);
+
+	if (!regions) {
+		log_error("Could not allocate memory for region_id table.");
+		return 0;
+	}
+
+	for (i = 0; i < count; i++) {
+		/*
+		 * We don't expect large numbers of segments (compared to e.g.
+		 * --filemap): use a fixed-size buffer based on the number of
+		 *  region identifiers and do not collapse continuous ranges
+		 *  of identifiers in the group descriptor argument.
+		 */
+		r = dm_snprintf(this_region, bufsize, FMTu64 "%s", region_ids[i],
+				(i < (count - 1)) ? "," : "");
+		if (r < 0)
+			goto_bad;
+		this_region += r;
+		bufsize -= r;
+	}
+
+	/* refresh handle */
+	if (!(r = dm_stats_list(dms, NULL)))
+		goto bad;
+
+	if ((r = dm_stats_create_group(dms, regions, alias, &group_id)))
+		printf("Grouped regions %s as group ID " FMTu64 "%s%s\n",
+		       regions, group_id, (alias) ? " with alias " : "",
+		       (alias) ? : "");
+	else
+		log_error("Failed to create group for regions %s", regions);
+
+bad:
+	dm_free(regions);
+	return r;
+}
+
 /*
  * Create a single region starting@start and spanning len sectors,
  * or, if the segments argument is no-zero create one region for each
@@ -4784,8 +4834,9 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 {
 	uint64_t this_start = 0, this_len = len, region_id = UINT64_C(0);
 	const char *devname = NULL, *histogram = _string_args[BOUNDS_ARG];
-	int r = 0, precise = _switches[PRECISE_ARG];
+	int r = 0, count = 0, precise = _switches[PRECISE_ARG];
 	struct dm_histogram *bounds = NULL; /* histogram bounds */
+	uint64_t *region_ids = NULL; /* segments */
 	char *target_type, *params; /* unused */
 	struct dm_task *dmt;
 	struct dm_info info;
@@ -4794,6 +4845,12 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 	if (histogram && !(bounds = dm_histogram_bounds_from_string(histogram)))
 		return_0;
 
+	if (_switches[ALIAS_ARG] && _switches[NOGROUP_ARG]) {
+		log_error("Cannot set alias with --nogroup.");
+		dm_stats_destroy(dms);
+		return 0;
+	}
+
 	if (!(dmt = dm_task_create(DM_DEVICE_TABLE))) {
 		dm_histogram_bounds_destroy(bounds);
 		dm_stats_destroy(dms);
@@ -4818,6 +4875,11 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 	if (!(devname = dm_task_get_name(dmt)))
 		goto_out;
 
+	if (!segments || (info.target_count == 1))
+		region_ids = &region_id;
+	else
+		region_ids = dm_malloc(info.target_count * sizeof(*region_ids));
+
 	do {
 		uint64_t segment_start, segment_len;
 		next = dm_get_next_target(dmt, next, &segment_start, &segment_len,
@@ -4838,10 +4900,10 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 			 */
 			this_start = (segments) ? segment_start : start;
 			this_len = (segments) ? segment_len : this_len;
-			if (!dm_stats_create_region(dms, &region_id,
-						    this_start, this_len, step,
-						    precise, bounds,
-						    program_id, user_data)) {
+			if (!(r = dm_stats_create_region(dms, &region_ids[count],
+							 this_start, this_len, step,
+							 precise, bounds,
+							 program_id, user_data))) {
 				log_error("%s: Could not create statistics region.",
 					  devname);
 				goto out;
@@ -4849,12 +4911,19 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 
 			printf("%s: Created new region with "FMTu64" area(s) as "
 			       "region ID "FMTu64"\n", devname,
-			       _nr_areas_from_step(this_len, step), region_id);
+			       _nr_areas_from_step(this_len, step),
+			       region_ids[count++]);
 		}
 	} while (next);
-	r = 1;
+
+	if (!_switches[NOGROUP_ARG] && segments)
+		r = _stats_group_segments(dms, region_ids, count,
+					  _string_args[ALIAS_ARG]);
 
 out:
+	if (region_ids != &region_id)
+		dm_free(region_ids);
+
 	dm_task_destroy(dmt);
 	dm_stats_destroy(dms);
 	dm_histogram_bounds_destroy(bounds);



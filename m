From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 13 Aug 2015 18:06:27 +0000 (UTC)
Subject: master - dmstats: improve region creation messages
Message-ID: <20150813180627.523AA607A2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=988ca743519839b283ebdbaaf06243cb0541b935
Commit:        988ca743519839b283ebdbaaf06243cb0541b935
Parent:        86adb6ca63358ca09d3a886915f30fcec997787f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Aug 13 12:42:35 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Aug 13 19:05:45 2015 +0100

dmstats: improve region creation messages

The region creation message just outputs the new region_id, e.g.:

Created region: 0

This is fine when the device is unambigous (as above) but produces
unhelpful output when creating multiple regions, or regions on
multiple devices:

Created region: 0
Created region: 0
Created region: 1
Created region: 2
Created region: 0

To address this refactor _stats_create_segments() (previously only
used when creating one-region-per-target for --segments) into a
more general _do_stats_create_regions() that can create regions
for each segment, or a single region spanning either the entire
device or a specied start/len range.

This allows us to output all region creation messages from a
single point where both the device name and all information needed
to derive the number of areas is available.

This allows us to log all these facts in the resulting messages:

vg_hex-lv_home: Created new region with 13 area(s) as region ID 0
vg_hex-lv_home: Created new region with 4 area(s) as region ID 1
vg_hex-lv_home: Created new region with 1 area(s) as region ID 2
vg_hex-lv_swap: Created new region with 1 area(s) as region ID 0
vg_hex-lv_root: Created new region with 10 area(s) as region ID 0
luks-79733921-3f68-4c92-9eb7-d0aca4c6ba3e: Created new region with 17 area(s) as region ID 0
vg_hex-lv_images: Created new region with 20 area(s) as region ID 0
vg_hex-lv_images: Created new region with 4 area(s) as region ID 1
---
 tools/dmsetup.c |   97 +++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 65 insertions(+), 32 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 3473244..420e263 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4282,19 +4282,43 @@ static int _size_from_string(char *argptr, uint64_t *size, const char *name)
 	return 1;
 }
 
-static int _stats_create_segments(struct dm_stats *dms,
-				  const char *name, int64_t step,
-				  const char *program_id, const char *aux_data)
+/*
+ * FIXME: expose this from libdm-stats
+ */
+static uint64_t _nr_areas_from_step(uint64_t len, int64_t step)
 {
-	uint64_t start, length, region_id = UINT64_C(0);
+	/* --areas */
+	if (step < 0)
+		return (uint64_t)(-step);
+
+	/* --areasize - cast step to unsigned as it cannot be -ve here. */
+	return (len / (step ? : len)) + !!(len % (uint64_t) step);
+}
+
+/*
+ * Create a single region starting@start and spanning len sectors,
+ * or, if the segments argument is no-zero create one region for each
+ * segment present in the mapped device.
+ */
+static int _do_stats_create_regions(struct dm_stats *dms,
+				    const char *name, uint64_t start,
+				    uint64_t len, int64_t step,
+				    int segments,
+				    const char *program_id,
+				    const char *aux_data)
+{
+	uint64_t this_start = start, this_len = len, region_id = UINT64_C(0);
 	char *target_type, *params; /* unused */
 	struct dm_task *dmt;
 	struct dm_info info;
 	void *next = NULL;
 	const char *devname = NULL;
+	int r = 0;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_TABLE)))
+	if (!(dmt = dm_task_create(DM_DEVICE_TABLE))) {
+		dm_stats_destroy(dms);
 		return 0;
+	}
 
 	if (!_set_task_device(dmt, name, 0))
 		goto out;
@@ -4315,30 +4339,50 @@ static int _stats_create_segments(struct dm_stats *dms,
 		goto out;
 
 	do {
-		next = dm_get_next_target(dmt, next, &start, &length,
+		uint64_t segment_start, segment_len;
+		next = dm_get_next_target(dmt, next, &segment_start, &segment_len,
 					  &target_type, &params);
-		if (!dm_stats_create_region(dms, &region_id, start, length,
-					    step, program_id, aux_data)) {
-			log_error("Could not create statistics region.");
+
+		/* Accumulate whole-device size for nr_areas calculation. */
+		if (!segments && !len)
+			this_len += segment_len;
+
+		/* Segments or whole-device. */
+		if (segments || !next) {
+			/*
+			 * this_start and this_len hold the start and length in
+			 * sectors of the to-be-created region: this is either the
+			 * segment start/len (for --segments), the value of the
+			 * --start/--length arguments, or 0/0 for a default
+			 *  whole-device region).
+			 */
+			this_start = (segments) ? segment_start : this_start;
+			this_len = (segments) ? segment_len : this_len;
+			if (!dm_stats_create_region(dms, &region_id,
+						    this_start, this_len, step,
+						    program_id, aux_data)) {
+				log_error("%s: Could not create statistics region.",
+					  devname);
+				goto out;
+			}
+
+			printf("%s: Created new region with "FMTu64" area(s) as "
+			       "region ID "FMTu64"\n", devname,
+			       _nr_areas_from_step(this_len, step), region_id);
 		}
-		printf("Created region %"PRIu64" on %s\n",
-		       region_id, devname);
 	} while (next);
-
-	dm_stats_destroy(dms);
-	dm_task_destroy(dmt);
-	return 1;
+	r = 1;
 
 out:
 	dm_task_destroy(dmt);
-	return 0;
+	dm_stats_destroy(dms);
+	return r;
 }
 
 static int _stats_create(CMD_ARGS)
 {
 	struct dm_stats *dms;
 	const char *name, *aux_data = "", *program_id = DM_STATS_PROGRAM_ID;
-	uint64_t region_id;
 	uint64_t start = 0, len = 0, areas = 0, area_size = 0;
 	int64_t step = 0;
 
@@ -4393,7 +4437,7 @@ static int _stats_create(CMD_ARGS)
 			return 0;
 
 	areas = (areas) ? areas : 1;
-	/* bytes to sectors or area count - promote to int before conversion */
+	/* bytes to sectors or -(areas): promote to signed before conversion */
 	step = (area_size) ? ((int64_t) area_size / 512) : -((int64_t) areas);
 
 	if (_switches[START_ARG]) {
@@ -4430,20 +4474,9 @@ static int _stats_create(CMD_ARGS)
 		/* force creation of a region with no id */
 		dm_stats_set_program_id(dms, 1, NULL);
 
-	if (_switches[SEGMENTS_ARG])
-		return _stats_create_segments(dms, name, step,
-					      program_id, aux_data);
-
-	if (!dm_stats_create_region(dms, &region_id, start, len,
-				    step, program_id, aux_data)) {
-		log_error("Could not create statistics region.");
-		goto out;
-	}
-
-	/* FIXME: support --quiet and --export output modes */
-	printf("Created region: %"PRIu64"\n", region_id);
-	dm_stats_destroy(dms);
-	return 1;
+	return _do_stats_create_regions(dms, name, start, len, step,
+					_switches[SEGMENTS_ARG],
+					program_id, aux_data);
 
 out:
 	dm_stats_destroy(dms);



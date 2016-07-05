From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:09 +0000 (UTC)
Subject: master - dmstats: report groups and region summaries
Message-ID: <20160705183509.60D0860FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8dffd6d217b53a94489ff1d411797d622e60c8b3
Commit:        8dffd6d217b53a94489ff1d411797d622e60c8b3
Parent:        d94c9569032d654a58cc6693c8a2a28e6e3b33f1
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Jun 19 13:38:41 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:50 2016 +0100

dmstats: report groups and region summaries

Walk avaiable groups and regions (in addition to areas) and report
aggregate statistics and properties.

A new switch is added to filter the type of obects inclued in the
report:

  --statstype={all,area,region,group}

The type of the current row is also available in a new
DR_STATS_META field 'type'.
---
 tools/dmsetup.c |  118 ++++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 95 insertions(+), 23 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index dfb362b..d1f93fd 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -209,6 +209,7 @@ enum {
 	SHOWKEYS_ARG,
 	SORT_ARG,
 	START_ARG,
+	STATSTYPE_ARG,
 	TABLE_ARG,
 	TARGET_ARG,
 	SEGMENTS_ARG,
@@ -264,7 +265,16 @@ static struct dm_timestamp *_initial_timestamp = NULL;
 static uint64_t _disp_factor = 512; /* display sizes in sectors */
 static char _disp_units = 's';
 const char *_program_id = DM_STATS_PROGRAM_ID; /* program_id used for reports. */
-static int _stats_report_by_areas = 1; /* output per-area info for stats reports. */
+static uint64_t _statstype = 0; /* stats objects to report */
+
+/* string names for stats object types */
+const char *_stats_types[] = {
+	"all",
+	"area",
+	"region",
+	"group",
+	NULL
+};
 
 /* report timekeeping */
 static struct dm_timestamp *_cycle_timestamp = NULL;
@@ -804,7 +814,7 @@ out:
 static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 {
 	struct dmsetup_report_obj obj;
-
+	uint64_t walk_flags = _statstype;
 	int r = 0;
 
 	if (!info->exists) {
@@ -835,6 +845,13 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 						       dm_task_get_name(dmt), '-')))
 			goto_out;
 
+	if (!(_report_type & (DR_STATS | DR_STATS_META))) {
+		if (!dm_report_object(_report, &obj))
+			goto_out;
+		r = 1;
+		goto out;
+	}
+
 	/*
 	 * Obtain statistics for the current reporting object and set
 	 * the interval estimate used for stats rate conversion.
@@ -854,10 +871,9 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		log_debug("Adjusted sample interval duration: %12"PRIu64"ns", _last_interval);
 		/* use measured approximation for calculations */
 		dm_stats_set_sampling_interval_ns(obj.stats, _last_interval);
-	}
-
-	/* Only a dm_stats_list is needed for DR_STATS_META reports. */
-	if (!obj.stats && (_report_type & DR_STATS_META)) {
+	} else if (!obj.stats && (_report_type & DR_STATS_META)
+		/* Only a dm_stats_list is needed for DR_STATS_META reports. */
+		    && !(_report_type & DR_STATS)) {
 		if (!(obj.stats = dm_stats_create(DM_STATS_PROGRAM_ID)))
 			goto_out;
 
@@ -871,20 +887,18 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 			goto_out;
 	}
 
-	/*
-	 * Walk any statistics regions contained in the current
-	 * reporting object: for objects with a NULL stats handle,
-	 * or a handle containing no registered regions, this loop
-	 * always executes exactly once.
-	 */
+	/* group report with no groups? */
+	if ((walk_flags == DM_STATS_WALK_GROUP)
+	    && !dm_stats_get_nr_groups(obj.stats))
+		goto out;
+
+	dm_stats_walk_init(obj.stats, walk_flags);
 	dm_stats_walk_do(obj.stats) {
 		if (!dm_report_object(_report, &obj))
 			goto_out;
-		if (_stats_report_by_areas)
-			dm_stats_walk_next(obj.stats);
-		else
-			dm_stats_walk_next_region(obj.stats);
+		dm_stats_walk_next(obj.stats);
 	} dm_stats_walk_while(obj.stats);
+
 	r = 1;
 
 out:
@@ -3251,6 +3265,13 @@ static int _dm_stats_region_id_disp(struct dm_report *rh,
 {
 	const struct dm_stats *dms = (const struct dm_stats *) data;
 	uint64_t region_id = dm_stats_get_current_region(dms);
+
+	if (dm_stats_current_object_type(dms) == DM_STATS_OBJECT_TYPE_GROUP) {
+		/* FIXME: output group region list and use group_id as sortval. */
+		dm_report_field_set_value(field, "-", &region_id);
+		return 1;
+	}
+
 	return dm_report_field_uint64(rh, field, &region_id);
 }
 
@@ -3317,6 +3338,10 @@ static int _dm_stats_area_id_disp(struct dm_report *rh,
 {
 	const struct dm_stats *dms = (const struct dm_stats *) data;
 	uint64_t area_id = dm_stats_get_current_area(dms);
+
+	if (dm_stats_current_object_type(dms) == DM_STATS_OBJECT_TYPE_GROUP)
+		area_id = 0;
+
 	return dm_report_field_uint64(rh, field, &area_id);
 }
 
@@ -3430,7 +3455,7 @@ static int _dm_stats_group_id_disp(struct dm_report *rh,
 	group_id = dm_stats_get_group_id(dms,
 					 dm_stats_get_current_region(dms));
 
-	if (group_id == UINT64_MAX) {
+	if (!dm_stats_group_present(dms, group_id)) {
 		dm_report_field_set_value(field, "-", &group_id);
 		return 1;
 	}
@@ -3475,6 +3500,17 @@ static int _dm_stats_name_disp(struct dm_report *rh,
 	return dm_report_field_string(rh, field, (const char * const *) &stats_name);
 }
 
+static int _dm_stats_object_type_disp(struct dm_report *rh,
+				     struct dm_pool *mem __attribute__((unused)),
+				     struct dm_report_field *field, const void *data,
+				     void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	int type = dm_stats_current_object_type(dms);
+
+	return dm_report_field_string(rh, field, (const char * const *) &_stats_types[type]);
+}
+
 static int _dm_stats_precise_disp(struct dm_report *rh,
 				  struct dm_pool *mem __attribute__((unused)),
 				  struct dm_report_field *field, const void *data,
@@ -4242,7 +4278,8 @@ FIELD_F(STATS_META, STR, "Precise", 7, dm_stats_precise, "precise", "Set if nano
 FIELD_F(STATS_META, STR, "#Bins", 9, dm_stats_hist_bins, "hist_bins", "The number of histogram bins configured.")
 FIELD_F(STATS_META, STR, "Histogram Bounds", 16, dm_stats_hist_bounds, "hist_bounds", "Latency histogram bin boundaries.")
 FIELD_F(STATS_META, STR, "Histogram Ranges", 16, dm_stats_hist_ranges, "hist_ranges", "Latency histogram bin ranges.")
-FIELD_F(STATS, STR, "Name", 16, dm_stats_name, "stats_name", "Stats name of current row.")
+FIELD_F(STATS_META, STR, "Name", 16, dm_stats_name, "stats_name", "Stats name of current object.")
+FIELD_F(STATS_META, STR, "Object Type", 11, dm_stats_object_type, "type", "Type of stats object being reported.")
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };
@@ -4577,6 +4614,7 @@ static int _stats_clear_regions(struct dm_stats *dms, uint64_t region_id)
 	if (!dm_stats_get_nr_regions(dms))
 		return 1;
 
+	dm_stats_walk_init(dms, DM_STATS_WALK_REGION);
 	dm_stats_walk_do(dms) {
 		if (allregions)
 			region_id = dm_stats_get_current_region(dms);
@@ -4591,7 +4629,7 @@ static int _stats_clear_regions(struct dm_stats *dms, uint64_t region_id)
 			return 0;
 		}
 		log_info("Cleared statistics region %"PRIu64".", region_id);
-		dm_stats_walk_next_region(dms);
+		dm_stats_walk_next(dms);
 	} dm_stats_walk_while(dms);
 
 	return 1;
@@ -4966,6 +5004,7 @@ static int _stats_delete(CMD_ARGS)
 	}
 
 	if (_switches[ALL_REGIONS_ARG]) {
+		dm_stats_walk_init(dms, DM_STATS_WALK_REGION);
 		dm_stats_walk_do(dms) {
 			region_id = dm_stats_get_current_region(dms);
 			if (!dm_stats_delete_region(dms, region_id)) {
@@ -4973,7 +5012,7 @@ static int _stats_delete(CMD_ARGS)
 				goto out;
 			}
 			log_info("Deleted statistics region %" PRIu64, region_id);
-			dm_stats_walk_next_region(dms);
+			dm_stats_walk_next(dms);
 		} dm_stats_walk_while(dms);
 	} else {
 		dm_stats_delete_region(dms, region_id);
@@ -5031,6 +5070,7 @@ static int _stats_print(CMD_ARGS)
 		goto out;
 	}
 
+	dm_stats_walk_init(dms, DM_STATS_WALK_REGION);
 	dm_stats_walk_do(dms) {
 		if (_switches[ALL_REGIONS_ARG])
 			region_id = dm_stats_get_current_region(dms);
@@ -5049,7 +5089,7 @@ static int _stats_print(CMD_ARGS)
 		printf("%s", stbuff);
 
 		dm_stats_buffer_destroy(dms, stbuff);
-		dm_stats_walk_next_region(dms);
+		dm_stats_walk_next(dms);
 
 	} dm_stats_walk_while(dms);
 
@@ -5073,8 +5113,14 @@ static int _stats_report(CMD_ARGS)
 	if (_switches[ALL_PROGRAMS_ARG])
 		_program_id = "";
 
-	if (!_switches[VERBOSE_ARG] && !strcmp(subcommand, "list"))
-		_stats_report_by_areas = 0;
+	if (_switches[VERBOSE_ARG] && !strcmp(subcommand, "list"))
+		_statstype |= (DM_STATS_WALK_ALL
+			       | DM_STATS_WALK_SKIP_SINGLE_AREA);
+
+	if (!strcmp(subcommand, "report"))
+		/* suppress duplicate rows of output */
+		_statstype |= (DM_STATS_WALK_ALL
+			       | DM_STATS_WALK_SKIP_SINGLE_AREA);
 
 	if (names)
 		name = names->name;
@@ -5478,7 +5524,15 @@ static const struct command *_find_stats_subcommand(const char *name)
 
 static int _stats(CMD_ARGS)
 {
+	const char *type_arg = _string_args[STATSTYPE_ARG];
+	const char **type = _stats_types;
 	const struct command *stats_cmd;
+	uint64_t type_flags[] = {
+		DM_STATS_WALK_ALL,
+		DM_STATS_WALK_AREA,
+		DM_STATS_WALK_REGION,
+		DM_STATS_WALK_GROUP
+	};
 
 	if (!(stats_cmd = _find_stats_subcommand(subcommand))) {
 		log_error("Unknown stats command.");
@@ -5496,6 +5550,19 @@ static int _stats(CMD_ARGS)
 		return 0;
 	}
 
+	if (_switches[STATSTYPE_ARG]) {
+		for (type = _stats_types; *type; type++) {
+			if (strstr(type_arg, *type))
+				_statstype |= type_flags[type - _stats_types];
+		}
+		if (!_statstype) {
+			log_error("Invalid argument to --statstype, expected: "
+				  "\"all\", \"area\", \"region\" or \"group\"");
+			return 0;
+		}
+	} else
+		_statstype = DM_STATS_WALK_REGION | DM_STATS_WALK_GROUP;
+
 	/*
 	 * Pass the sub-command through to allow a single function to be
 	 * used to implement several distinct sub-commands (e.g. 'report'
@@ -5917,6 +5984,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"showkeys", 0, &ind, SHOWKEYS_ARG},
 		{"sort", 1, &ind, SORT_ARG},
 		{"start", 1, &ind, START_ARG},
+		{"statstype", 1, &ind, STATSTYPE_ARG},
 		{"table", 1, &ind, TABLE_ARG},
 		{"target", 1, &ind, TARGET_ARG},
 		{"tree", 0, &ind, TREE_ARG},
@@ -6225,6 +6293,10 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[SETUUID_ARG]++;
 		if (ind == SHOWKEYS_ARG)
 			_switches[SHOWKEYS_ARG]++;
+		if (ind == STATSTYPE_ARG) {
+			_switches[STATSTYPE_ARG]++;
+			_string_args[STATSTYPE_ARG] = optarg;
+		}
 		if (ind == TABLE_ARG) {
 			_switches[TABLE_ARG]++;
 			if (!(_table = dm_strdup(optarg))) {



From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 12:56:34 +0000 (UTC)
Subject: master - dmstats: make 'dmstats list' use common report infrastructure
Message-ID: <20150814125634.70FB060EDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6724f0303b8dee0806ac799f0035d9f928441fc
Commit:        e6724f0303b8dee0806ac799f0035d9f928441fc
Parent:        37dd26e322bc2fc3fa0fd7dd85d1972b08fca36c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Aug 13 23:03:46 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 13:43:12 2015 +0100

dmstats: make 'dmstats list' use common report infrastructure

Unlike 'info -c' and 'stats report' the 'dmstats list' subcommand
does its own report processing. This complicates the handling of
the DR_STATS and DR_STATS_META fields and leads to inconsistent
behaviour between the different commands. In particular it causes
'stats list' to segfault when using 'all' field options:

Segmentation fault (core dumped)

Delete _stats_list() entirely and adapt _stats_report so that it
can correctly format a DR_STATS_META-only report request.

This requires passing the subcommand into _report_init() where it
is used in addition to the command name to select the default set
of report fields for the 'list' and 'report' stats subcommands.

With this change both 'list' and 'report' dmstats report will use
the correct report object type and ensure that it is initialised
appropriately for the field selection in use.
---
 tools/dmsetup.c |  147 ++++++++++++++++--------------------------------------
 1 files changed, 44 insertions(+), 103 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index db2c3e4..5472985 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -252,9 +252,9 @@ static report_type_t _report_type;
 static dev_name_t _dev_name_type;
 static uint32_t _count = 1; /* count of repeating reports */
 static struct dm_timestamp *_initial_timestamp = NULL;
-static int _stats_report_init = 0;
 static uint64_t _disp_factor = 512; /* display sizes in sectors */
 static char _disp_units = 's';
+const char *_program_id = DM_STATS_PROGRAM_ID; /* program_id used for reports. */
 
 /* report timekeeping */
 static struct dm_timestamp *_cycle_timestamp = NULL;
@@ -830,7 +830,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 
 		dm_stats_bind_devno(obj.stats, info->major, info->minor);
 
-		if (!(dm_stats_populate(obj.stats, DM_STATS_PROGRAM_ID, DM_STATS_REGIONS_ALL)))
+		if (!dm_stats_populate(obj.stats, _program_id, DM_STATS_REGIONS_ALL))
 			goto out;
 
 		/* Update timestamps and handle end-of-interval accounting. */
@@ -841,6 +841,21 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		dm_stats_set_sampling_interval_ns(obj.stats, _last_interval);
 	}
 
+	/* Only a dm_stats_list is needed for DR_STATS_META reports. */
+	if (!obj.stats && (_report_type & DR_STATS_META)) {
+		if (!(obj.stats = dm_stats_create(DM_STATS_PROGRAM_ID)))
+			goto_out;
+
+		dm_stats_bind_devno(obj.stats, info->major, info->minor);
+
+		if (!dm_stats_list(obj.stats, _program_id))
+			goto out;
+
+		/* No regions to report */
+		if (!dm_stats_get_nr_regions(obj.stats))
+			goto out;
+	}
+
 	/*
 	 * Walk any statistics regions contained in the current
 	 * reporting object: for objects with a NULL stats handle,
@@ -3995,7 +4010,7 @@ static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
 static const char *_stats_default_report_options = DEV_INFO_STATS ",area_id," METRICS;
 static const char *_stats_list_options = "name,region_id,region_start,region_len,area_len,area_count,program_id";
 
-static int _report_init(const struct command *cmd)
+static int _report_init(const struct command *cmd, const char *subcommand)
 {
 	char *options = (char *) default_report_options;
 	char *opt_fields = NULL; /* optional fields from command line */
@@ -4014,8 +4029,13 @@ static int _report_init(const struct command *cmd)
 	}
 
 	if (cmd && !strcmp(cmd->name, "stats")) {
-		options = (char *) _stats_default_report_options;
-		_report_type |= (DR_STATS | DR_STATS_META);
+		_report_type |= DR_STATS_META;
+		if (!strcmp(subcommand, "list"))
+			options = (char *) _stats_list_options;
+		else {
+			options = (char *) _stats_default_report_options;
+			_report_type |= DR_STATS;
+		}
 	}
 
 	if (cmd && !strcmp(cmd->name, "list")) {
@@ -4642,91 +4662,6 @@ out:
 	return 0;
 }
 
-static int _stats_list(CMD_ARGS)
-{
-	struct dm_stats *dms;
-	const char *name, *program_id = DM_STATS_PROGRAM_ID;
-	struct dm_task *dmt = NULL;
-	struct dm_info info;
-	struct dmsetup_report_obj obj;
-
-	if (names)
-		name = names->name;
-	else {
-		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
-			return _process_all(cmd, subcommand, argc, argv, 0, _stats_list);
-		name = argv[0];
-	}
-
-	if (_switches[PROGRAM_ID_ARG])
-		program_id = _string_args[PROGRAM_ID_ARG];
-
-	if (_switches[ALL_PROGRAMS_ARG])
-		program_id = "";
-
-	if (_switches[OPTIONS_ARG] && !strcmp(_string_args[OPTIONS_ARG], "help"))
-		/* field help already output from _report_init(). */
-		return 1;
-
-	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
-		return_0;
-
-	if (!_bind_stats_device(dms, name))
-		goto_out;
-
-	if (!dm_stats_list(dms, program_id)) {
-		log_error("Could not list statistics regions.");
-		goto out;
-	}
-
-	if (_report && !_stats_report_init) {
-		dm_report_free(_report);
-		_report_init(cmd);
-		_stats_report_init = 1;
-	}
-
-	if (!dm_stats_get_nr_regions(dms)) {
-		log_info("No statistics regions present.");
-		goto none;
-	}
-
-	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
-		return 0;
-
-	if (!_set_task_device(dmt, name, 0))
-		goto out;
-
-	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
-
-	if (!_task_run(dmt))
-		goto out;
-
-	if (!dm_task_get_info(dmt, &info))
-		goto out;
-
-	obj.task = dmt;
-	obj.stats = dms;
-	obj.info = &info;
-
-	dm_stats_walk_do(obj.stats) {
-		dm_report_object(_report, &obj);
-		dm_stats_walk_next_region(obj.stats);
-	} dm_stats_walk_while(obj.stats);
-
-	dm_task_destroy(dmt);
-
-none:
-	dm_stats_destroy(dms);
-	return 1;
-
-out:
-	if (dmt)
-		dm_task_destroy(dmt);
-	dm_stats_destroy(dms);
-	return 0;
-}
-
 static int _stats_print(CMD_ARGS)
 {
 	struct dm_stats *dms;
@@ -4805,6 +4740,12 @@ static int _stats_report(CMD_ARGS)
 	struct dm_task *dmt;
 	char *name = NULL;
 
+	if (_switches[PROGRAM_ID_ARG])
+		_program_id = _string_args[PROGRAM_ID_ARG];
+
+	if (_switches[ALL_PROGRAMS_ARG])
+		_program_id = "";
+
 	if (names)
 		name = names->name;
 	else {
@@ -4869,7 +4810,7 @@ static struct command _stats_subcommands[] = {
 	{"clear", "--regionid <id> [<device>]", 0, -1, 1, 0, _stats_clear},
 	{"create", CREATE_OPTS "\n\t\t" ID_OPTS "[<device>]", 0, -1, 1, 0, _stats_create},
 	{"delete", "--regionid <id> <device>", 1, -1, 1, 0, _stats_delete},
-	{"list", "[--programid <id>] [<device>]", 0, -1, 1, 0, _stats_list},
+	{"list", "[--programid <id>] [<device>]", 0, -1, 1, 0, _stats_report},
 	{"print", PRINT_OPTS "[<device>]", 0, -1, 1, 0, _stats_print},
 	{"report", REPORT_OPTS "[<device>]", 0, -1, 1, 0, _stats_report},
 	{"version", "", 0, -1, 1, 0, _version},
@@ -5025,7 +4966,7 @@ static int _stats_help(CMD_ARGS)
 			_report = NULL;
 		}
 
-		(void) _report_init(cmd);
+		(void) _report_init(cmd, "help");
 		if (_report) {
 			dm_report_free(_report);
 			_report = NULL;
@@ -5048,7 +4989,7 @@ static int _dmsetup_help(CMD_ARGS)
 			dm_report_free(_report);
 			_report = NULL;
 		}
-		(void) _report_init(cmd);
+		(void) _report_init(cmd, "");
 		if (_report) {
 			dm_report_free(_report);
 			_report = NULL;
@@ -5964,7 +5905,16 @@ unknown:
 		goto out;
 #endif
 
-	if (_switches[COLS_ARG] && !_report_init(cmd))
+	/*
+	 * Extract subcommand?
+	 * dmsetup <command> <subcommand> [args...]
+	 */
+	if (cmd->has_subcommands) {
+		subcommand = argv[0];
+		argc--, argv++;
+	}
+
+	if (_switches[COLS_ARG] && !_report_init(cmd, subcommand))
 		goto out;
 
 	if (_switches[COUNT_ARG])
@@ -5981,15 +5931,6 @@ unknown:
 		}
 	}
 
-	/*
-	 * Extract subcommand?
-	 * dmsetup <command> <subcommand> [args...]
-	 */
-	if (cmd->has_subcommands) {
-		subcommand = argv[0];
-		argc--, argv++;
-	}
-
 	/* Start interval timer. */
 	if (_count > 1)
 		if (!_start_timer())



From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:34 +0000 (UTC)
Subject: master - dmstats: replace --statstype with separate object switches
Message-ID: <20160705183534.4E44161253@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d374475ce6b9b8485b33c7ca7d4ae18e97a8c11
Commit:        6d374475ce6b9b8485b33c7ca7d4ae18e97a8c11
Parent:        cc6177284a4c08e115368c938f03899b443b5edf
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 14:08:28 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:51 2016 +0100

dmstats: replace --statstype with separate object switches

Replace --statstype=area,region,group with a separate switch for
each object type: --area, --region, --group. Omitting any object
type switch will use the defaults for the current command (regions
and groups for list, and regions, groups and areas for verbose list).
---
 tools/dmsetup.c |   62 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 32 insertions(+), 30 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index e0cade0..d48e423 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -160,6 +160,7 @@ enum {
 	ALL_DEVICES_ARG,
 	ALL_PROGRAMS_ARG,
 	ALL_REGIONS_ARG,
+	AREA_ARG,
 	AREAS_ARG,
 	AREA_SIZE_ARG,
 	AUX_DATA_ARG,
@@ -173,6 +174,7 @@ enum {
 	EXEC_ARG,
 	FORCE_ARG,
 	GID_ARG,
+	GROUP_ARG,
 	GROUP_ID_ARG,
 	HELP_ARG,
 	HISTOGRAM_ARG,
@@ -200,6 +202,7 @@ enum {
 	PROGRAM_ID_ARG,
 	RAW_ARG,
 	READAHEAD_ARG,
+	REGION_ARG,
 	REGION_ID_ARG,
 	RELATIVE_ARG,
 	RETRY_ARG,
@@ -209,7 +212,6 @@ enum {
 	SHOWKEYS_ARG,
 	SORT_ARG,
 	START_ARG,
-	STATSTYPE_ARG,
 	TABLE_ARG,
 	TARGET_ARG,
 	SEGMENTS_ARG,
@@ -5140,11 +5142,15 @@ out:
 
 static int _stats_report(CMD_ARGS)
 {
-	int r = 0;
+	int r = 0, objtype_args;
 
 	struct dm_task *dmt;
 	char *name = NULL;
 
+	objtype_args = (_switches[AREA_ARG]
+			|| _switches[REGION_ARG]
+			|| _switches[GROUP_ARG]);
+
 	if (_switches[PROGRAM_ID_ARG])
 		_program_id = _string_args[PROGRAM_ID_ARG];
 
@@ -5155,7 +5161,8 @@ static int _stats_report(CMD_ARGS)
 		_statstype |= (DM_STATS_WALK_ALL
 			       | DM_STATS_WALK_SKIP_SINGLE_AREA);
 
-	if (!strcmp(subcommand, "report") && !_switches[STATSTYPE_ARG])
+	/* suppress duplicates unless the user has requested all regions */
+	if (!strcmp(subcommand, "report") && !objtype_args)
 		/* suppress duplicate rows of output */
 		_statstype |= (DM_STATS_WALK_ALL
 			       | DM_STATS_WALK_SKIP_SINGLE_AREA);
@@ -5562,15 +5569,19 @@ static const struct command *_find_stats_subcommand(const char *name)
 
 static int _stats(CMD_ARGS)
 {
-	const char *type_arg = _string_args[STATSTYPE_ARG];
-	const char **type = _stats_types;
 	const struct command *stats_cmd;
-	uint64_t type_flags[] = {
-		DM_STATS_WALK_ALL,
-		DM_STATS_WALK_AREA,
-		DM_STATS_WALK_REGION,
-		DM_STATS_WALK_GROUP
-	};
+
+	if (_switches[AREA_ARG] || _switches[REGION_ARG] || _switches[GROUP_ARG])
+		_statstype = 0; /* switches will OR flags in */
+	else
+		_statstype = DM_STATS_WALK_REGION | DM_STATS_WALK_GROUP;
+
+	if (_switches[AREA_ARG])
+		_statstype |= DM_STATS_WALK_AREA;
+	if (_switches[REGION_ARG])
+		_statstype |= DM_STATS_WALK_REGION;
+	if (_switches[GROUP_ARG])
+		_statstype |= DM_STATS_WALK_GROUP;
 
 	if (!(stats_cmd = _find_stats_subcommand(subcommand))) {
 		log_error("Unknown stats command.");
@@ -5588,19 +5599,6 @@ static int _stats(CMD_ARGS)
 		return 0;
 	}
 
-	if (_switches[STATSTYPE_ARG]) {
-		for (type = _stats_types; *type; type++) {
-			if (strstr(type_arg, *type))
-				_statstype |= type_flags[type - _stats_types];
-		}
-		if (!_statstype) {
-			log_error("Invalid argument to --statstype, expected: "
-				  "\"all\", \"area\", \"region\" or \"group\"");
-			return 0;
-		}
-	} else
-		_statstype = DM_STATS_WALK_REGION | DM_STATS_WALK_GROUP;
-
 	/*
 	 * Pass the sub-command through to allow a single function to be
 	 * used to implement several distinct sub-commands (e.g. 'report'
@@ -5972,6 +5970,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"alldevices", 0, &ind, ALL_DEVICES_ARG},
 		{"allprograms", 0, &ind, ALL_PROGRAMS_ARG},
 		{"allregions", 0, &ind, ALL_REGIONS_ARG},
+		{"area", 0, &ind, AREA_ARG},
 		{"areas", 1, &ind, AREAS_ARG},
 		{"areasize", 1, &ind, AREA_SIZE_ARG},
 		{"auxdata", 1, &ind, AUX_DATA_ARG},
@@ -5985,6 +5984,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"exec", 1, &ind, EXEC_ARG},
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
+		{"group", 0, &ind, GROUP_ARG},
 		{"groupid", 1, &ind, GROUP_ID_ARG},
 		{"help", 0, &ind, HELP_ARG},
 		{"histogram", 0, &ind, HISTOGRAM_ARG},
@@ -5993,7 +5993,6 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"length", 1, &ind, LENGTH_ARG},
 		{"manglename", 1, &ind, MANGLENAME_ARG},
 		{"major", 1, &ind, MAJOR_ARG},
-		{"regions", 1, &ind, REGIONS_ARG},
 		{"minor", 1, &ind, MINOR_ARG},
 		{"mode", 1, &ind, MODE_ARG},
 		{"nameprefixes", 0, &ind, NAMEPREFIXES_ARG},
@@ -6012,6 +6011,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"programid", 1, &ind, PROGRAM_ID_ARG},
 		{"raw", 0, &ind, RAW_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
+		{"region", 0, &ind, REGION_ARG},
+		{"regions", 1, &ind, REGIONS_ARG},
 		{"regionid", 1, &ind, REGION_ID_ARG},
 		{"relative", 0, &ind, RELATIVE_ARG},
 		{"retry", 0, &ind, RETRY_ARG},
@@ -6022,7 +6023,6 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"showkeys", 0, &ind, SHOWKEYS_ARG},
 		{"sort", 1, &ind, SORT_ARG},
 		{"start", 1, &ind, START_ARG},
-		{"statstype", 1, &ind, STATSTYPE_ARG},
 		{"table", 1, &ind, TABLE_ARG},
 		{"target", 1, &ind, TARGET_ARG},
 		{"tree", 0, &ind, TREE_ARG},
@@ -6118,6 +6118,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[ALL_PROGRAMS_ARG]++;
 		if (ind == ALL_REGIONS_ARG)
 			_switches[ALL_REGIONS_ARG]++;
+		if (ind == AREA_ARG)
+			_switches[AREA_ARG]++;
 		if (ind == AREAS_ARG) {
 			_switches[AREAS_ARG]++;
 			_int_args[AREAS_ARG] = atoi(optarg);
@@ -6182,6 +6184,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[PRECISE_ARG]++;
 		if (ind == RAW_ARG)
 			_switches[RAW_ARG]++;
+		if (ind == REGION_ARG)
+			_switches[REGION_ARG]++;
 		if (ind == REGION_ID_ARG) {
 			_switches[REGION_ID_ARG]++;
 			_int_args[REGION_ID_ARG] = atoi(optarg);
@@ -6244,6 +6248,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[GID_ARG]++;
 			_int_args[GID_ARG] = atoi(optarg);
 		}
+		if (ind == GROUP_ARG)
+			_switches[GROUP_ARG]++;
 		if (ind == GROUP_ID_ARG) {
 			_switches[GROUP_ID_ARG]++;
 			_int_args[GROUP_ID_ARG] = atoi(optarg);
@@ -6331,10 +6337,6 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[SETUUID_ARG]++;
 		if (ind == SHOWKEYS_ARG)
 			_switches[SHOWKEYS_ARG]++;
-		if (ind == STATSTYPE_ARG) {
-			_switches[STATSTYPE_ARG]++;
-			_string_args[STATSTYPE_ARG] = optarg;
-		}
 		if (ind == TABLE_ARG) {
 			_switches[TABLE_ARG]++;
 			if (!(_table = dm_strdup(optarg))) {



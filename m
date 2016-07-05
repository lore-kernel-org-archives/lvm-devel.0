From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:44 +0000 (UTC)
Subject: master - dmstats: add 'group' and 'ungroup' commands
Message-ID: <20160705185444.92A9C608F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0761863e28ec3184c0884b8f11f42f10a1374b9e
Commit:        0761863e28ec3184c0884b8f11f42f10a1374b9e
Parent:        b4cbc8f2838ce52233151700a59e09b17a3d9a0d
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Mar 7 18:07:57 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

dmstats: add 'group' and 'ungroup' commands

Add a pair of commands to create and delete stats groups:

  dmstats group --regions REGIONS

  dmstats ungroup --groupid ID

REGIONS specifies a list of regions to be included in the group.
Regions are specified as a comma separated list in order of
increasing region ID. Ranges may be specified as a hypen separated
pair of values giving the first and last member of the range.
---
 tools/dmsetup.c |  129 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 129 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5cd0ef4..36058c8 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -172,6 +172,7 @@ enum {
 	EXEC_ARG,
 	FORCE_ARG,
 	GID_ARG,
+	GROUP_ID_ARG,
 	HELP_ARG,
 	HISTOGRAM_ARG,
 	INACTIVE_ARG,
@@ -179,6 +180,7 @@ enum {
 	LENGTH_ARG,
 	MANGLENAME_ARG,
 	MAJOR_ARG,
+	REGIONS_ARG,
 	MINOR_ARG,
 	MODE_ARG,
 	NAMEPREFIXES_ARG,
@@ -5088,6 +5090,118 @@ out:
 	return r;
 }
 
+static int _stats_group(CMD_ARGS)
+{
+	char *name, *regions = NULL;
+	struct dm_stats *dms;
+	uint64_t group_id;
+	int r = 0;
+
+	/* group does not use a report */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
+	if (!_switches[REGIONS_ARG]) {
+		err("Group requires --regions.");
+		return 0;
+	}
+
+	regions = _string_args[REGIONS_ARG];
+
+	if (names)
+		name = names->name;
+	else {
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
+			if (!_switches[ALL_DEVICES_ARG]) {
+				log_error("Please specify device(s) or use "
+					  "--alldevices.");
+				return 0;
+			}
+			return _process_all(cmd, subcommand, argc, argv, 0, _stats_group);
+		}
+		name = argv[0];
+	}
+
+	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
+		return_0;
+
+	if (!_bind_stats_device(dms, name))
+		goto_out;
+
+	if (!dm_stats_list(dms, NULL))
+		goto_out;
+
+	if(!dm_stats_create_group(dms, regions, NULL, &group_id)) {
+		log_error("Could not create group on %s: %s", name, regions);
+		goto out;
+	}
+
+	printf("Grouped regions %s as group ID " FMTu64 " on %s\n",
+	       regions, group_id, name);
+
+	r = 1;
+
+out:
+	dm_stats_destroy(dms);
+	return r;
+}
+
+static int _stats_ungroup(CMD_ARGS)
+{
+	struct dm_stats *dms;
+	uint64_t group_id;
+	char *name;
+	int r = 0;
+
+	/* ungroup does not use a report */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
+	if (!_switches[GROUP_ID_ARG]) {
+		err("Please specify group id.");
+		return 0;
+	}
+
+	group_id = (uint64_t) _int_args[GROUP_ID_ARG];
+
+	if (names)
+		name = names->name;
+	else {
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
+			if (!_switches[ALL_DEVICES_ARG]) {
+				log_error("Please specify device(s) or use "
+					  "--alldevices.");
+				return 0;
+			}
+			return _process_all(cmd, subcommand, argc, argv, 0, _stats_ungroup);
+		}
+		name = argv[0];
+	}
+
+	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
+		return_0;
+
+	if (!_bind_stats_device(dms, name))
+		goto_out;
+
+	if (!dm_stats_list(dms, NULL))
+		goto_out;
+
+	if (!(r = dm_stats_delete_group(dms, group_id, 0)))
+		log_error("Could not delete group " FMTu64 " on %s.",
+			  group_id, name);
+
+	printf("Removed group ID "FMTu64" on %s\n", group_id, name);
+
+out:
+	dm_stats_destroy(dms);
+	return r;
+}
+
 /*
  * Command dispatch tables and usage.
  */
@@ -5103,10 +5217,12 @@ static int _stats_help(CMD_ARGS);
  *           [--auxdata data] [--programid id] [<device_name>]
  *    delete [--regionid] <device_name>
  *    delete_all [--programid id]
+ *    group [--alias name] [--alldevices] [--regions <regions>] [<device_name>]
  *    list [--programid id] [<device_name>]
  *    print [--clear] [--programid id] [--regionid id] [<device_name>]
  *    report [--interval seconds] [--count count] [--units units] [--regionid id]
  *           [--programid id] [<device>]
+ *    ungroup [--alldevices] [--groupid id] [<device_name>]
  */
 
 #define AREA_OPTS "[--areas <nr_areas>] [--areasize <size>] "
@@ -5115,15 +5231,18 @@ static int _stats_help(CMD_ARGS);
 #define SELECT_OPTS "[--programid <id>] [--regionid <id>] "
 #define PRINT_OPTS "[--clear] " SELECT_OPTS
 #define REPORT_OPTS "[--interval <seconds>] [--count <cnt>]\n\t\t[--units <u>]" SELECT_OPTS
+#define GROUP_OPTS "[--alias NAME] --regions <regions>"
 
 static struct command _stats_subcommands[] = {
 	{"help", "", 0, 0, 0, 0, _stats_help},
 	{"clear", "--regionid <id> [<device>]", 0, -1, 1, 0, _stats_clear},
 	{"create", CREATE_OPTS "\n\t\t" ID_OPTS "[<device>]", 0, -1, 1, 0, _stats_create},
 	{"delete", "--regionid <id> <device>", 1, -1, 1, 0, _stats_delete},
+	{"group", GROUP_OPTS, 1, -1, 1, 0, _stats_group},
 	{"list", "[--programid <id>] [<device>]", 0, -1, 1, 0, _stats_report},
 	{"print", PRINT_OPTS "[<device>]", 0, -1, 1, 0, _stats_print},
 	{"report", REPORT_OPTS "[<device>]", 0, -1, 1, 0, _stats_report},
+	{"ungroup", "--groupid <id> [device]", 1, -1, 1, 0, _stats_ungroup},
 	{"version", "", 0, -1, 1, 0, _version},
 	{NULL, NULL, 0, 0, 0, 0, NULL}
 };
@@ -5738,6 +5857,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"exec", 1, &ind, EXEC_ARG},
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
+		{"groupid", 1, &ind, GROUP_ID_ARG},
 		{"help", 0, &ind, HELP_ARG},
 		{"histogram", 0, &ind, HISTOGRAM_ARG},
 		{"inactive", 0, &ind, INACTIVE_ARG},
@@ -5745,6 +5865,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"length", 1, &ind, LENGTH_ARG},
 		{"manglename", 1, &ind, MANGLENAME_ARG},
 		{"major", 1, &ind, MAJOR_ARG},
+		{"regions", 1, &ind, REGIONS_ARG},
 		{"minor", 1, &ind, MINOR_ARG},
 		{"mode", 1, &ind, MODE_ARG},
 		{"nameprefixes", 0, &ind, NAMEPREFIXES_ARG},
@@ -5902,6 +6023,10 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[MAJOR_ARG]++;
 			_int_args[MAJOR_ARG] = atoi(optarg);
 		}
+		if (ind == REGIONS_ARG) {
+			_switches[REGIONS_ARG]++;
+			_string_args[REGIONS_ARG] = optarg;
+		}
 		if (c == 'm' || ind == MINOR_ARG) {
 			_switches[MINOR_ARG]++;
 			_int_args[MINOR_ARG] = atoi(optarg);
@@ -5986,6 +6111,10 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[GID_ARG]++;
 			_int_args[GID_ARG] = atoi(optarg);
 		}
+		if (ind == GROUP_ID_ARG) {
+			_switches[GROUP_ID_ARG]++;
+			_int_args[GROUP_ID_ARG] = atoi(optarg);
+		}
 		if (c == 'U' || ind == UID_ARG) {
 			_switches[UID_ARG]++;
 			_int_args[UID_ARG] = atoi(optarg);



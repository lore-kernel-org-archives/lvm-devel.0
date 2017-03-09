From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 9 Mar 2017 13:54:08 -0500
Subject: master - dmstats: start dmfilemapd when creating or updating file maps
Message-ID: <201703091854.v29Is8iY011384@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=baa8a9be4adb3e1d57b4b135178e7f77d8580902
Commit:        baa8a9be4adb3e1d57b4b135178e7f77d8580902
Parent:        044f92e466176e1ea29d1159361de5f5f3fc263a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Dec 16 13:42:08 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 9 18:50:15 2017 +0000

dmstats: start dmfilemapd when creating or updating file maps

Launch an instance of the filemap monitoring daemon when creating,
or updating, a file mapped group, unless the --nomonitor switch is
given.

Unless --foreground is given the daemon will detach from the
terminal and run in the background until it is signaled or the
daemon termination conditions are met.

The --follow={inode|path} switch is added to control the daemon
behaviour when files are moved, unlinked, or renamed while they
are being monitored.

The daemon runs with the same verbosity as the dmstats command
that starts it.
---
 tools/dmsetup.c |   86 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 78 insertions(+), 8 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 549a8c5..eaeb1ce 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -172,7 +172,9 @@ enum {
 	SELECT_ARG,
 	EXEC_ARG,
 	FILEMAP_ARG,
+	FOLLOW_ARG,
 	FORCE_ARG,
+	FOREGROUND_ARG,
 	GID_ARG,
 	GROUP_ARG,
 	GROUP_ID_ARG,
@@ -196,6 +198,7 @@ enum {
 	NOTABLE_ARG,
 	NOTIMESUFFIX_ARG,
 	UDEVCOOKIE_ARG,
+	NOMONITOR_ARG,
 	NOUDEVRULES_ARG,
 	NOUDEVSYNC_ARG,
 	OPTIONS_ARG,
@@ -4999,15 +5002,25 @@ static int _stats_check_filemap_switches(void)
 	return 1;
 }
 
+static dm_filemapd_mode_t _stats_get_filemapd_mode(void)
+{
+	if (!_switches[FOLLOW_ARG])
+		return DM_FILEMAPD_FOLLOW_INODE;
+	return dm_filemapd_mode_from_string(_string_args[FOLLOW_ARG]);
+}
+
 static int _stats_create_file(CMD_ARGS)
 {
 	const char *alias, *program_id = DM_STATS_PROGRAM_ID;
 	const char *bounds_str = _string_args[BOUNDS_ARG];
+	int foreground = _switches[FOREGROUND_ARG];
+	int verbose = _switches[VERBOSE_ARG];
 	uint64_t *regions, *region, count = 0;
 	struct dm_histogram *bounds = NULL;
 	char *path, *abspath = NULL;
 	struct dm_stats *dms = NULL;
 	int group, fd = -1, precise;
+	dm_filemapd_mode_t mode;
 
 	if (names) {
 		err("Device names are not compatibile with --filemap.");
@@ -5060,6 +5073,10 @@ static int _stats_create_file(CMD_ARGS)
 	precise = _int_args[PRECISE_ARG];
 	group = !_switches[NOGROUP_ARG];
 
+	if (!_switches[NOMONITOR_ARG] && group)
+		if ((mode = _stats_get_filemapd_mode()) == -1)
+			goto bad;
+
 	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
 		goto_bad;
 
@@ -5091,6 +5108,12 @@ static int _stats_create_file(CMD_ARGS)
 	regions = dm_stats_create_regions_from_fd(dms, fd, group, precise,
 						  bounds, alias);
 
+	if (!_switches[NOMONITOR_ARG] && group) {
+		if (!dm_stats_start_filemapd(fd, regions[0], abspath, mode,
+					     foreground, verbose))
+			log_warn("Failed to start filemap monitoring daemon.");
+	}
+
 	if (close(fd))
 		log_error("Error closing %s", abspath);
 
@@ -5620,12 +5643,16 @@ out:
 
 static int _stats_update_file(CMD_ARGS)
 {
-	uint64_t group_id, *region, *regions, count = 0;
+	uint64_t group_id, *region, *regions = NULL, count = 0;
 	const char *program_id = DM_STATS_PROGRAM_ID;
+	int foreground = _switches[FOREGROUND_ARG];
+	int verbose = _switches[VERBOSE_ARG];
+	char *path, *abspath = NULL;
+	dm_filemapd_mode_t mode;
 	struct dm_stats *dms;
-	char *path, *abspath;
 	int fd = -1;
 
+
 	if (names) {
 		err("Device names are not compatibile with update_filemap.");
 		return 0;
@@ -5654,6 +5681,10 @@ static int _stats_update_file(CMD_ARGS)
 
 	group_id = (uint64_t) _int_args[GROUP_ID_ARG];
 
+	if (!_switches[NOMONITOR_ARG])
+		if ((mode = _stats_get_filemapd_mode()) < 0)
+			goto bad;
+
 	if (_switches[PROGRAM_ID_ARG])
 		program_id = _string_args[PROGRAM_ID_ARG];
 	if (!strlen(program_id) && !_switches[FORCE_ARG])
@@ -5676,6 +5707,25 @@ static int _stats_update_file(CMD_ARGS)
 		/* force creation of a region with no id */
 		dm_stats_set_program_id(dms, 1, NULL);
 
+	/*
+	 * Start dmfilemapd - it will test the file descriptor to determine
+	 * whether it is necessary to call dm_stats_update_regions_from_fd().
+	 *
+	 * If starting the daemon fails, fall back to a direct update.
+	 */
+	if (!_switches[NOMONITOR_ARG]) {
+		if (!dm_stats_start_filemapd(fd, group_id, abspath, mode,
+					     foreground, verbose)) {
+			log_warn("Failed to start filemap monitoring daemon.");
+			goto fallback;
+		}
+		goto out;
+	}
+
+fallback:
+	/*
+	 * --nomonitor case - perform a one-shot update directly from dmstats.
+	 */
 	regions = dm_stats_update_regions_from_fd(dms, fd, group_id);
 
 	if (close(fd))
@@ -5700,6 +5750,7 @@ static int _stats_update_file(CMD_ARGS)
 	printf("%s: Updated group ID " FMTu64 " with "FMTu64" region(s).\n",
 	       path, group_id, count);
 
+out:
 	dm_free(regions);
 	dm_free(abspath);
 	dm_stats_destroy(dms);
@@ -5732,7 +5783,7 @@ static int _stats_help(CMD_ARGS);
  *       [--programid <id>] [--userdata <data> ]
  *       [--bounds histogram_boundaries] [--precise]
  *       [--alldevices|<device>...]
- *   create --filemap [--nogroup]
+ *   create --filemap [--nogroup] [--nomonitor] [--follow=mode]
  *       [--programid <id>] [--userdata <data> ]
  *       [--bounds histogram_boundaries] [--precise] [<file_path>]
  *   delete [--allprograms|--programid id]
@@ -5764,6 +5815,8 @@ static int _stats_help(CMD_ARGS);
 #define PRECISE_OPTS "[--precise] "
 #define SEGMENTS_OPT "[--segments] "
 #define EXTRA_OPTS HIST_OPTS PRECISE_OPTS
+#define FILE_MONITOR_OPTS "[--nomonitor] [--follow mode]"
+#define GROUP_ID_OPT "--groupid <id> "
 #define ALL_PROGS_OPT "[--allprograms|--programid id] "
 #define ALL_REGIONS_OPT "[--allregions|--regionid id] "
 #define ALL_DEVICES_OPT "[--alldevices|<device>...] "
@@ -5774,12 +5827,13 @@ static int _stats_help(CMD_ARGS);
 
 /* command options */
 #define CREATE_OPTS REGION_OPTS INDENT ID_OPTS INDENT EXTRA_OPTS INDENT SEGMENTS_OPT
-#define FILEMAP_OPTS "--filemap [--nogroup]" INDENT ID_OPTS INDENT EXTRA_OPTS
+#define FILEMAP_OPTS "--filemap [--nogroup] " FILE_MONITOR_OPTS INDENT ID_OPTS INDENT EXTRA_OPTS
 #define PRINT_OPTS "[--clear] " ALL_PROGS_REGIONS_DEVICES
 #define REPORT_OPTS "[--interval <seconds>] [--count <cnt>]" INDENT \
 "[--units <u>] " SELECT_OPTS INDENT DM_REPORT_OPTS INDENT ALL_PROGS_OPT
 #define GROUP_OPTS "[--alias NAME] --regions <regions>" INDENT ALL_PROGS_OPT ALL_DEVICES_OPT
-#define UNGROUP_OPTS ALL_PROGS_OPT INDENT ALL_DEVICES_OPT
+#define UNGROUP_OPTS GROUP_ID_OPT ALL_PROGS_OPT INDENT ALL_DEVICES_OPT
+#define UPDATE_OPTS GROUP_ID_OPT INDENT FILE_MONITOR_OPTS " <file_path>"
 
 /*
  * The 'create' command has two entries in the table, to allow for the
@@ -5790,14 +5844,14 @@ static struct command _stats_subcommands[] = {
 	{"help", "", 0, 0, 0, 0, _stats_help},
 	{"clear", ALL_REGIONS_OPT ALL_DEVICES_OPT, 0, -1, 1, 0, _stats_clear},
 	{"create", CREATE_OPTS ALL_DEVICES_OPT, 0, -1, 1, 0, _stats_create},
-	{"create", FILEMAP_OPTS "[<file_path>]", 0, -1, 1, 0, _stats_create},
+	{"create", FILEMAP_OPTS "<file_path>", 0, -1, 1, 0, _stats_create},
 	{"delete", ALL_PROGS_REGIONS_DEVICES, 1, -1, 1, 0, _stats_delete},
 	{"group", GROUP_OPTS, 1, -1, 1, 0, _stats_group},
 	{"list", ALL_PROGS_OPT ALL_REGIONS_OPT, 0, -1, 1, 0, _stats_report},
 	{"print", PRINT_OPTS, 0, -1, 1, 0, _stats_print},
 	{"report", REPORT_OPTS "[<device>...]", 0, -1, 1, 0, _stats_report},
-	{"ungroup", "--groupid <id> " UNGROUP_OPTS, 1, -1, 1, 0, _stats_ungroup},
-	{"update_filemap", "--groupid <id> <file_path>", 1, 1, 0, 0, _stats_update_file},
+	{"ungroup", UNGROUP_OPTS, 1, -1, 1, 0, _stats_ungroup},
+	{"update_filemap", UPDATE_OPTS, 1, 1, 0, 0, _stats_update_file},
 	{"version", "", 0, -1, 1, 0, _version},
 	{NULL, NULL, 0, 0, 0, 0, NULL}
 };
@@ -6053,6 +6107,11 @@ static int _stats(CMD_ARGS)
 		return 0;
 	}
 
+	if (_switches[FOLLOW_ARG] && _switches[NOMONITOR_ARG]) {
+		log_error("Use of --follow is incompatible with --nomonitor.");
+		return 0;
+	}
+
 	/*
 	 * Pass the sub-command through to allow a single function to be
 	 * used to implement several distinct sub-commands (e.g. 'report'
@@ -6418,7 +6477,9 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"select", 1, &ind, SELECT_ARG},
 		{"exec", 1, &ind, EXEC_ARG},
 		{"filemap", 0, &ind, FILEMAP_ARG},
+		{"follow", 1, &ind, FOLLOW_ARG},
 		{"force", 0, &ind, FORCE_ARG},
+		{"foreground", 0, &ind, FOREGROUND_ARG},
 		{"gid", 1, &ind, GID_ARG},
 		{"group", 0, &ind, GROUP_ARG},
 		{"groupid", 1, &ind, GROUP_ID_ARG},
@@ -6441,6 +6502,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"notable", 0, &ind, NOTABLE_ARG},
 		{"notimesuffix", 0, &ind, NOTIMESUFFIX_ARG},
 		{"udevcookie", 1, &ind, UDEVCOOKIE_ARG},
+		{"nomonitor", 0, &ind, NOMONITOR_ARG},
 		{"noudevrules", 0, &ind, NOUDEVRULES_ARG},
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
@@ -6584,8 +6646,14 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[COLS_ARG]++;
 		if (ind == FILEMAP_ARG)
 			_switches[FILEMAP_ARG]++;
+		if (ind == FOLLOW_ARG) {
+			_switches[FOLLOW_ARG]++;
+			_string_args[FOLLOW_ARG] = optarg;
+		}
 		if (c == 'f' || ind == FORCE_ARG)
 			_switches[FORCE_ARG]++;
+		if (ind == FOREGROUND_ARG)
+			_switches[FOREGROUND_ARG]++;
 		if (c == 'r' || ind == READ_ONLY)
 			_switches[READ_ONLY]++;
 		if (ind == HISTOGRAM_ARG)
@@ -6678,6 +6746,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[UDEVCOOKIE_ARG]++;
 			_udev_cookie = _get_cookie_value(optarg);
 		}
+		if (ind == NOMONITOR_ARG)
+			_switches[NOMONITOR_ARG]++;
 		if (ind == NOUDEVRULES_ARG)
 			_switches[NOUDEVRULES_ARG]++;
 		if (ind == NOUDEVSYNC_ARG)



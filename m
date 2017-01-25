From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 25 Jan 2017 16:22:32 +0000 (UTC)
Subject: master - dmstats: allow --filemap groups to be updated
Message-ID: <20170125162232.2FF3F60E07@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b999d5f501bc959cad138e4a3a2459af90d0a3ca
Commit:        b999d5f501bc959cad138e4a3a2459af90d0a3ca
Parent:        e0d19feb85ce8e143c7f107d7bf1c668d667a57c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 11 13:26:34 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jan 25 16:15:21 2017 +0000

dmstats: allow --filemap groups to be updated

Add a new update_filemap command to dmstats that allows a filemap
group to be updated:

  # dmstats update_filemap --groupid 0 vm.img
  /var/lib/libvirt/images/vm.img: Updated group ID 0 with 137 region(s).

This will update the set of regions mapped to the file to reflect
the current file system allocation.

Currently this needs to be run manually - a future update will add
support for monitoring file maps via a daemon, allowing them to be
automatically updated when the underlying file is modified.
---
 tools/dmsetup.c |  131 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 122 insertions(+), 9 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index fabb183..c9549c6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4957,16 +4957,8 @@ static char *_get_abspath(const char *path)
 	return _path;
 }
 
-static int _stats_create_file(CMD_ARGS)
+static int _stats_check_filemap_switches(void)
 {
-	const char *alias, *program_id = DM_STATS_PROGRAM_ID;
-	const char *bounds_str = _string_args[BOUNDS_ARG];
-	uint64_t *regions, *region, count = 0;
-	struct dm_histogram *bounds = NULL;
-	char *path, *abspath = NULL;
-	struct dm_stats *dms = NULL;
-	int group, fd = -1, precise;
-
 	if (_switches[AREAS_ARG] || _switches[AREA_SIZE_ARG]) {
 		log_error("--filemap is incompatible with --areas and --area-size.");
 		return 0;
@@ -4997,6 +4989,27 @@ static int _stats_create_file(CMD_ARGS)
 		return 0;
 	}
 
+	return 1;
+}
+
+static int _stats_create_file(CMD_ARGS)
+{
+	const char *alias, *program_id = DM_STATS_PROGRAM_ID;
+	const char *bounds_str = _string_args[BOUNDS_ARG];
+	uint64_t *regions, *region, count = 0;
+	struct dm_histogram *bounds = NULL;
+	char *path, *abspath = NULL;
+	struct dm_stats *dms = NULL;
+	int group, fd = -1, precise;
+
+	if (names) {
+		err("Device names are not compatibile with --filemap.");
+		return 0;
+	}
+
+	if (!_stats_check_filemap_switches())
+		return 0;
+
 	/* _stats_create_file does not use _process_all() */
 	if (!argc) {
 		log_error("--filemap requires a file path argument");
@@ -5598,6 +5611,105 @@ out:
 	return r;
 }
 
+static int _stats_update_file(CMD_ARGS)
+{
+	uint64_t group_id, *region, *regions, count = 0;
+	const char *program_id = DM_STATS_PROGRAM_ID;
+	struct dm_stats *dms;
+	char *path, *abspath;
+	int fd = -1;
+
+	if (names) {
+		err("Device names are not compatibile with update_filemap.");
+		return 0;
+	}
+
+	if (!_stats_check_filemap_switches())
+		return 0;
+
+	/* _stats_update_file does not use _process_all() */
+	if (!argc) {
+		log_error("update_filemap requires a file path argument");
+		return 0;
+	}
+
+	if (!_switches[GROUP_ID_ARG]) {
+		err("--groupid is required to update a filemap group.");
+		return 0;
+	}
+
+	path = argv[0];
+
+	if (!(abspath = _get_abspath(path))) {
+		log_error("Could not canonicalize file name: %s", path);
+		return 0;
+	}
+
+	group_id = (uint64_t) _int_args[GROUP_ID_ARG];
+
+	if (_switches[PROGRAM_ID_ARG])
+		program_id = _string_args[PROGRAM_ID_ARG];
+	if (!strlen(program_id) && !_switches[FORCE_ARG])
+		program_id = DM_STATS_PROGRAM_ID;
+
+	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
+		goto_bad;
+
+	fd = open(abspath, O_RDONLY);
+
+	if (fd < 0) {
+		log_error("Could not open %s for reading", abspath);
+		goto bad;
+	}
+
+	if (!dm_stats_bind_from_fd(dms, fd))
+		goto_bad;
+
+	if (!strlen(program_id))
+		/* force creation of a region with no id */
+		dm_stats_set_program_id(dms, 1, NULL);
+
+	regions = dm_stats_update_regions_from_fd(dms, fd, group_id);
+
+	if (close(fd))
+		log_error("Error closing %s", abspath);
+
+	fd = -1;
+
+	if (!regions) {
+		log_error("Could not update regions from file %s", abspath);
+		goto bad;
+	}
+
+	for (region = regions; *region != DM_STATS_REGIONS_ALL; region++)
+		count++;
+
+	if (group_id != regions[0]) {
+		printf("Group ID changed from " FMTu64 " to " FMTu64,
+		       group_id, regions[0]);
+		group_id = regions[0];
+	}
+
+	printf("%s: Updated group ID " FMTu64 " with "FMTu64" region(s).\n",
+	       path, group_id, count);
+
+	dm_free(regions);
+	dm_free(abspath);
+	dm_stats_destroy(dms);
+	return 1;
+
+bad:
+	dm_free(abspath);
+
+	if ((fd > -1) && close(fd))
+		log_error("Error closing %s", path);
+
+	if (dms)
+		dm_stats_destroy(dms);
+
+	return 0;
+}
+
 /*
  * Command dispatch tables and usage.
  */
@@ -5678,6 +5790,7 @@ static struct command _stats_subcommands[] = {
 	{"print", PRINT_OPTS, 0, -1, 1, 0, _stats_print},
 	{"report", REPORT_OPTS "[<device...>]", 0, -1, 1, 0, _stats_report},
 	{"ungroup", "--groupid <id> " UNGROUP_OPTS, 1, -1, 1, 0, _stats_ungroup},
+	{"update_filemap", "--groupid <id> <file_path>", 1, 1, 0, 0, _stats_update_file},
 	{"version", "", 0, -1, 1, 0, _version},
 	{NULL, NULL, 0, 0, 0, 0, NULL}
 };



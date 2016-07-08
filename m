From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:26:44 +0000 (UTC)
Subject: master - dmstats: add create --filemap
Message-ID: <20160708182644.CA8C860FCF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ebe630b696e3bdbd66760ba140e05d11a999df5
Commit:        7ebe630b696e3bdbd66760ba140e05d11a999df5
Parent:        e1048259165b09a35c45170cefbbccb4d43a9834
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jun 30 21:48:10 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 14:34:41 2016 +0100

dmstats: add create --filemap

Add a new option to the create command to create regions that map the
extents of a file:

  # dmstats create --filemap /path/to/file
  /path/to/file: Created new group with 10 region(s) as group ID 0.

When performing a --filemap no device argument is required (and
supplying one results in error) since the device to bind to is implied
by the file path and is obtained directly from an fstat().

Grouping may be optionally disabled by the --nogroup switch: in this
case the command will report each region individually:

  # dmstats create --nogroup --filemap /path/to/file
  /path/to/file: Created new region with 1 area as region ID 0.
  /path/to/file: Created new region with 1 area as region ID 1.
  /path/to/file: Created new region with 1 area as region ID 2.

When grouping regions the group alias is automatically set to the
basename (as returned by dm_basename()) of the provided file.

This can be overridden to a user-defined value at the command line by
use of the --alias option.

If grouping is disabled no alias can be set.

Use of offset and subdivision options (--start, --length, --segments,
--areas, --areasize).

Setting aux_data and histograms for groups is possible but is not
currently implemented.
---
 tools/dmsetup.c |  221 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 203 insertions(+), 18 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 83d45da..637a82a 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -171,6 +171,7 @@ enum {
 	DEFERRED_ARG,
 	SELECT_ARG,
 	EXEC_ARG,
+	FILEMAP_ARG,
 	FORCE_ARG,
 	GID_ARG,
 	GROUP_ARG,
@@ -187,6 +188,7 @@ enum {
 	MODE_ARG,
 	NAMEPREFIXES_ARG,
 	NOFLUSH_ARG,
+	NOGROUP_ARG,
 	NOHEADINGS_ARG,
 	NOLOCKFS_ARG,
 	NOOPENCOUNT_ARG,
@@ -4611,6 +4613,24 @@ static int _bind_stats_device(struct dm_stats *dms, const char *name)
 	return 1;
 }
 
+static int _bind_stats_from_fd(struct dm_stats *dms, int fd)
+{
+	int major, minor;
+	struct stat buf;
+
+	if (fstat(fd, &buf)) {
+		log_error("fstat failed for fd %d.", fd);
+		return 0;
+	}
+
+	major = (int) MAJOR(buf.st_dev);
+	minor = (int) MINOR(buf.st_dev);
+
+	if (!dm_stats_bind_devno(dms, major, minor))
+		return_0;
+	return 1;
+}
+
 static int _stats_clear_one_region(struct dm_stats *dms, uint64_t region_id)
 {
 
@@ -4841,6 +4861,176 @@ out:
 	return r;
 }
 
+/*
+ * Returns the full absolute path, or NULL if the path could
+ * not be resolved.
+ */
+static char *_get_abspath(const char *path)
+{
+	char *_path;
+
+#ifdef HAVE_CANONICALIZE_FILE_NAME
+	_path = canonicalize_file_name(path);
+#else
+	/* FIXME Provide alternative */
+	log_error(INTERNAL_ERROR "Unimplemented _get_abspath.");
+	_path = NULL;
+#endif
+	return _path;
+}
+
+static int _stats_create_file(CMD_ARGS)
+{
+	const char *alias, *program_id = DM_STATS_PROGRAM_ID;
+	uint64_t *regions, *region, count = 0;
+	char *path, *abspath = NULL;
+	int group, fd, precise;
+	struct dm_stats *dms;
+
+	if (_switches[AREAS_ARG] || _switches[AREA_SIZE_ARG]) {
+		log_error("--filemap is incompatible with --areas and --area-size.");
+		return 0;
+	}
+
+	if (_switches[START_ARG] || _switches[LENGTH_ARG]) {
+		log_error("--filemap is incompatible with --start and --length.");
+		return 0;
+	}
+
+	if (_switches[SEGMENTS_ARG]) {
+		log_error("--filemap and --segments are incompatible.");
+		return 0;
+	}
+
+	if (_switches[USER_DATA_ARG]) {
+		log_error("--userdata is not yet supported with --filemap.");
+		return 0;
+	}
+
+	if (_switches[BOUNDS_ARG]) {
+		log_error("--bounds is not yet supported with --filemap.");
+		return 0;
+	}
+
+	/* _stats_create_file does not use _process_all() */
+	if (names) {
+		log_error("Device argument not compatible with --filemap.");
+		return 0;
+	} else {
+		if (argc || _switches[UUID_ARG] || _switches[MAJOR_ARG]) {
+			log_error("--uuid, --major, and device argument are "
+				  "incompatible with --filemap.");
+			return 0;
+		}
+		if (_switches[ALL_DEVICES_ARG]) {
+			log_error("--alldevices is incompatible with "
+				  "--filemap.");
+			return 0;
+		}
+	}
+
+	if (_switches[PRECISE_ARG]) {
+		if (!dm_stats_driver_supports_precise()) {
+			log_error("Using --precise requires driver version "
+				  "4.32.0 or later.");
+			return 0;
+		}
+	}
+
+	if (_switches[BOUNDS_ARG]) {
+		if (!dm_stats_driver_supports_histogram()) {
+			log_error("Using --bounds requires driver version "
+				  "4.32.0 or later.");
+			return 0;
+		}
+	}
+
+	if (_switches[PROGRAM_ID_ARG])
+		program_id = _string_args[PROGRAM_ID_ARG];
+	if (!strlen(program_id) && !_switches[FORCE_ARG])
+		program_id = DM_STATS_PROGRAM_ID;
+
+	path = _string_args[FILEMAP_ARG];
+	precise = _int_args[PRECISE_ARG];
+	group = !_switches[NOGROUP_ARG];
+
+	if (!(abspath = _get_abspath(path))) {
+		log_error("Could not canonicalize file name: %s", path);
+		return 0;
+	}
+
+	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
+		return_0;
+
+	fd = open(abspath, O_RDONLY);
+
+	if (fd < 0) {
+		log_error("Could not open %s for reading", path);
+		goto bad;
+	}
+
+	if (!_bind_stats_from_fd(dms, fd))
+		goto_bad;
+
+	if (!strlen(program_id))
+		/* force creation of a region with no id */
+		dm_stats_set_program_id(dms, 1, NULL);
+
+	if (group && !_switches[ALIAS_ARG])
+		alias = dm_basename(abspath);
+	else if (group)
+		alias = _string_args[ALIAS_ARG];
+	else if (!_switches[ALIAS_ARG])
+		alias = NULL;
+	else {
+		log_error("Cannot set alias with --nogroup.");
+		goto bad;
+	}
+
+	regions = dm_stats_create_regions_from_fd(dms, fd, group, precise,
+						  NULL, alias);
+
+	if (close(fd))
+		log_error("Error closing %s", path);
+
+	fd = -1;
+
+	if (!regions) {
+		log_error("Could not create regions from file %s", path);
+		goto bad;
+	}
+
+	for (region = regions; *region != DM_STATS_REGIONS_ALL; region++) {
+		count++;
+	}
+
+	if (group) {
+		printf("%s: Created new group with "FMTu64" region(s) as "
+		       "group ID "FMTu64".\n", path, count, regions[0]);
+	} else {
+		region = regions;
+		do
+			printf("%s: Created new region with 1 area as "
+			       "region ID "FMTu64".\n", path, *region);
+		while (*(++region) != DM_STATS_REGIONS_ALL);
+	}
+
+	dm_free(regions);
+	dm_free(abspath);
+	dm_stats_destroy(dms);
+	return 1;
+
+bad:
+	if (abspath)
+		dm_free(abspath);
+
+	if ((fd > -1) && close(fd))
+		log_error("Error closing %s", path);
+
+	dm_stats_destroy(dms);
+	return 0;
+}
+
 static int _stats_create(CMD_ARGS)
 {
 	struct dm_stats *dms;
@@ -4876,6 +5066,10 @@ static int _stats_create(CMD_ARGS)
 			return 0;
 	}
 
+	if (_switches[FILEMAP_ARG])
+		return _stats_create_file(cmd, subcommand, argc, argv,
+					  names, multiple_devices);
+
 	if (names)
 		name = names->name;
 	else {
@@ -5030,6 +5224,7 @@ static int _stats_delete(CMD_ARGS)
 			log_error("Could not delete statistics group.");
 			goto out;
 		}
+		printf("Deleted statistics group " FMTu64 ".\n", group_id);
 	} else if (_switches[ALL_REGIONS_ARG]) {
 		dm_stats_foreach_region(dms) {
 			region_id = dm_stats_get_current_region(dms);
@@ -5682,24 +5877,6 @@ static int _process_tree_options(const char *options)
 	return 1;
 }
 
-/*
- * Returns the full absolute path, or NULL if the path could
- * not be resolved.
- */
-static char *_get_abspath(const char *path)
-{
-	char *_path;
-
-#ifdef HAVE_CANONICALIZE_FILE_NAME
-	_path = canonicalize_file_name(path);
-#else
-	/* FIXME Provide alternative */
-	log_error(INTERNAL_ERROR "Unimplemented _get_abspath.");
-	_path = NULL;
-#endif
-	return _path;
-}
-
 static char *parse_loop_device_name(const char *dev, const char *dev_dir)
 {
 	char *buf;
@@ -5984,6 +6161,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"deferred", 0, &ind, DEFERRED_ARG},
 		{"select", 1, &ind, SELECT_ARG},
 		{"exec", 1, &ind, EXEC_ARG},
+		{"filemap", 1, &ind, FILEMAP_ARG},
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
 		{"group", 0, &ind, GROUP_ARG},
@@ -5998,6 +6176,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"minor", 1, &ind, MINOR_ARG},
 		{"mode", 1, &ind, MODE_ARG},
 		{"nameprefixes", 0, &ind, NAMEPREFIXES_ARG},
+		{"nogroup", 0, &ind, NOGROUP_ARG},
 		{"noflush", 0, &ind, NOFLUSH_ARG},
 		{"noheadings", 0, &ind, NOHEADINGS_ARG},
 		{"nolockfs", 0, &ind, NOLOCKFS_ARG},
@@ -6147,6 +6326,10 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[CLEAR_ARG]++;
 		if (c == 'c' || c == 'C' || ind == COLS_ARG)
 			_switches[COLS_ARG]++;
+		if (ind == FILEMAP_ARG) {
+			_switches[FILEMAP_ARG]++;
+			_string_args[FILEMAP_ARG] = optarg;
+		}
 		if (c == 'f' || ind == FORCE_ARG)
 			_switches[FORCE_ARG]++;
 		if (c == 'r' || ind == READ_ONLY)
@@ -6306,6 +6489,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[NAMEPREFIXES_ARG]++;
 		if (ind == NOFLUSH_ARG)
 			_switches[NOFLUSH_ARG]++;
+		if (ind == NOGROUP_ARG)
+			_switches[NOGROUP_ARG]++;
 		if (ind == NOHEADINGS_ARG)
 			_switches[NOHEADINGS_ARG]++;
 		if (ind == NOLOCKFS_ARG)



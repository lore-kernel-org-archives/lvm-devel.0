From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 21:05:56 +0000 (UTC)
Subject: master - dmstats: accept multiple arguments to --filemap
Message-ID: <20160708210556.7BCBE608F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a77a40501b6cc71d8e5af30393a1305fcd923ab
Commit:        6a77a40501b6cc71d8e5af30393a1305fcd923ab
Parent:        2d1f03b6164bce6f871918f563de9d8233e76f93
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 22:02:47 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 22:05:36 2016 +0100

dmstats: accept multiple arguments to --filemap

Make the --filemap switch take no arguments and instead accept one
or more files on the command line to be mapped and placed into
groups.

This allows --filemap to be used with a glob:

  # dmstats create --filemap *
  rhel5.10-1.qcow2: Created new group with 87 region(s) as group ID 1564.
  rhel5.10.qcow2: Created new group with 8 region(s) as group ID 1651.
  rhel7.0-1.qcow2: Created new group with 11 region(s) as group ID 1659.
  rhel7.0.qcow2: Created new group with 1454 region(s) as group ID 1670.
  vm.img: Created new group with 2 region(s) as group ID 3124.
---
 tools/dmsetup.c |   31 ++++++++++++++-----------------
 1 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 34e33d3..e21d195 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4979,18 +4979,19 @@ static int _stats_create_file(CMD_ARGS)
 	}
 
 	/* _stats_create_file does not use _process_all() */
-	if (names) {
-		log_error("Device argument not compatible with --filemap.");
+	if (names || !argc) {
+		log_error("--filemap requires a file path argument");
 		return 0;
 	} else {
-		if (argc || _switches[UUID_ARG] || _switches[MAJOR_ARG]) {
-			log_error("--uuid, --major, and device argument are "
-				  "incompatible with --filemap.");
-			return 0;
-		}
-		if (_switches[ALL_DEVICES_ARG]) {
-			log_error("--alldevices is incompatible with "
-				  "--filemap.");
+		if (argc)
+			path = argv[0];
+		else {
+			if (_switches[UUID_ARG] || _switches[MAJOR_ARG])
+				log_error("--uuid and --major are incompatible "
+					  "with --filemap.");
+			if (_switches[ALL_DEVICES_ARG])
+				log_error("--alldevices is incompatible with "
+					  "--filemap.");
 			return 0;
 		}
 	}
@@ -5019,7 +5020,6 @@ static int _stats_create_file(CMD_ARGS)
 	if (!strlen(program_id) && !_switches[FORCE_ARG])
 		program_id = DM_STATS_PROGRAM_ID;
 
-	path = _string_args[FILEMAP_ARG];
 	precise = _int_args[PRECISE_ARG];
 	group = !_switches[NOGROUP_ARG];
 
@@ -5069,9 +5069,8 @@ static int _stats_create_file(CMD_ARGS)
 		goto bad;
 	}
 
-	for (region = regions; *region != DM_STATS_REGIONS_ALL; region++) {
+	for (region = regions; *region != DM_STATS_REGIONS_ALL; region++)
 		count++;
-	}
 
 	if (group) {
 		printf("%s: Created new group with "FMTu64" region(s) as "
@@ -6230,7 +6229,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"deferred", 0, &ind, DEFERRED_ARG},
 		{"select", 1, &ind, SELECT_ARG},
 		{"exec", 1, &ind, EXEC_ARG},
-		{"filemap", 1, &ind, FILEMAP_ARG},
+		{"filemap", 0, &ind, FILEMAP_ARG},
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
 		{"group", 0, &ind, GROUP_ARG},
@@ -6395,10 +6394,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[CLEAR_ARG]++;
 		if (c == 'c' || c == 'C' || ind == COLS_ARG)
 			_switches[COLS_ARG]++;
-		if (ind == FILEMAP_ARG) {
+		if (ind == FILEMAP_ARG)
 			_switches[FILEMAP_ARG]++;
-			_string_args[FILEMAP_ARG] = optarg;
-		}
 		if (c == 'f' || ind == FORCE_ARG)
 			_switches[FORCE_ARG]++;
 		if (c == 'r' || ind == READ_ONLY)



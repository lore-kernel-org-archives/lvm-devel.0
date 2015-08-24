From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 24 Aug 2015 19:04:20 +0000 (UTC)
Subject: master - dmstats: add --precise switch to enable nanosecond counters.
Message-ID: <20150824190420.D984260993@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4145ebc47a833d443a7c8bcec26d9d2ec9e5518
Commit:        e4145ebc47a833d443a7c8bcec26d9d2ec9e5518
Parent:        567189cc7617a4d239d0f2ea052801fe2573d011
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Aug 18 12:39:34 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 24 20:03:21 2015 +0100

dmstats: add --precise switch to enable nanosecond counters.

---
 WHATS_NEW_DM     |    1 +
 man/dmstats.8.in |    9 +++++++++
 tools/dmsetup.c  |   16 ++++++++++++++--
 3 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e083231..01ceefb 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.106 -
 ===================================
+  Add --precise switch to 'dmstats create' to request nanosecond counters.
   Add precise argument to dm_stats_create_region().
   Add support to libdm-stats for precise_timestamps
 
diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index bdcf742..ad5f952 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -32,6 +32,7 @@ dmstats \(em device-mapper statistics management
 .IR nr_areas ]
 .RB |[ \-\-areasize
 .IR area_size ]]
+.RB [ \-\-precise ]
 .RB [[ \-\-start
 .IR start_sector ]
 .RB [ \-\-length
@@ -181,6 +182,10 @@ Specify which report fields to display.
 Sort output according to the list of fields given. Precede any
 sort_field with - for a reverse sort on that column.
 .TP
+.BR \-\-precise
+Attempt to use nanosecond precision counters when creating new
+statistics regions.
+.TP
 .B \-\-programid \fIid
 Specify a program ID string. When creating new statistics regions this
 string is stored with the region. Subsequent operations may supply a
@@ -240,6 +245,7 @@ regions (with the exception of in-flight IO counters).
 .IR nr_areas ]
 .RB [ \-\-areasize
 .IR area_size ]
+.RB [ \-\-precise ]
 .RB [[ \-\-start
 .IR start_sector ]
 .RB [ \-\-length
@@ -259,6 +265,9 @@ at an arbitrary offset into the device. The \fB\-\-segments\fP option
 causes a new region to be created for each target in the corresponding
 device-mapper device's table.
 
+If the \fB\-\-precise\fP option is used the command will attempt to
+create a region using nanosecond precision counters.
+
 An optional \fBprogram_id\fP or \fBaux_data\fP string may be associated
 with the region. A \fBprogram_id\fP may then be used to select regions
 for subsequent list, print, and report operations. The \fBaux_data\fP
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b8376dd..e98bdcd 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -190,6 +190,7 @@ enum {
 	NOUDEVRULES_ARG,
 	NOUDEVSYNC_ARG,
 	OPTIONS_ARG,
+	PRECISE_ARG,
 	PROGRAM_ID_ARG,
 	RAW_ARG,
 	READAHEAD_ARG,
@@ -4473,7 +4474,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 	struct dm_info info;
 	void *next = NULL;
 	const char *devname = NULL;
-	int r = 0;
+	int r = 0, precise = _switches[PRECISE_ARG];
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TABLE))) {
 		dm_stats_destroy(dms);
@@ -4520,7 +4521,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 			this_len = (segments) ? segment_len : this_len;
 			if (!dm_stats_create_region(dms, &region_id,
 						    this_start, this_len, step,
-						    -1,
+						    precise,
 						    program_id, aux_data)) {
 				log_error("%s: Could not create statistics region.",
 					  devname);
@@ -4631,6 +4632,14 @@ static int _stats_create(CMD_ARGS)
 	if (!_bind_stats_device(dms, name))
 		goto_out;
 
+	if (_switches[PRECISE_ARG]) {
+		if (!dm_stats_driver_supports_precise()) {
+			log_error("Using --precise requires driver version "
+				  "4.32.0 or later.");
+			goto out;
+		}
+	}
+
 	if (!strlen(program_id))
 		/* force creation of a region with no id */
 		dm_stats_set_program_id(dms, 1, NULL);
@@ -5497,6 +5506,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"noudevrules", 0, &ind, NOUDEVRULES_ARG},
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
+		{"precise", 0, &ind, PRECISE_ARG},
 		{"programid", 1, &ind, PROGRAM_ID_ARG},
 		{"raw", 0, &ind, RAW_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
@@ -5648,6 +5658,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[PROGRAM_ID_ARG]++;
 			_string_args[PROGRAM_ID_ARG] = optarg;
 		}
+		if (ind == PRECISE_ARG)
+			_switches[PRECISE_ARG]++;
 		if (ind == RAW_ARG)
 			_switches[RAW_ARG]++;
 		if (ind == REGION_ID_ARG) {



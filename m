From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 12 Aug 2015 20:41:16 +0000 (UTC)
Subject: master - dmstats: don't output column headings when args checks fail
Message-ID: <20150812204116.7A11F60315@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=098528513f8c00d12f4ca5b5e87e4a932a6ef4f6
Commit:        098528513f8c00d12f4ca5b5e87e4a932a6ef4f6
Parent:        829384f46dedee8646cc6b098ef98463658c51d6
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Aug 12 21:14:00 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Aug 12 21:40:43 2015 +0100

dmstats: don't output column headings when args checks fail

The clear, create, delete, and print commands do not use _report:
make sure it is freed and set to NULL before checking arguments.
---
 tools/dmsetup.c |   48 ++++++++++++++++++++++++------------------------
 1 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 459639b..e913a7e 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4193,6 +4193,12 @@ static int _stats_clear(CMD_ARGS)
 	char *name = NULL;
 	int allregions = _switches[ALL_REGIONS_ARG];
 
+	/* clear does not use a report */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
 	if (!_switches[REGION_ID_ARG] && !_switches[ALL_REGIONS_ARG]) {
 		err("Please specify a region_id.");
 		return 0;
@@ -4206,12 +4212,6 @@ static int _stats_clear(CMD_ARGS)
 		name = argv[1];
 	}
 
-	/* create does not use a report */
-	if (_report) {
-		dm_report_free(_report);
-		_report = NULL;
-	}
-
 	region_id = (allregions) ? DM_STATS_REGIONS_ALL
 		     : (uint64_t) _int_args[REGION_ID_ARG];
 
@@ -4327,6 +4327,12 @@ static int _stats_create(CMD_ARGS)
 	uint64_t start = 0, len = 0, areas = 0, area_size = 0;
 	int64_t step = 0;
 
+	/* create does not use a report */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
 	if (_switches[ALL_REGIONS_ARG]) {
 		log_error("Cannot use --allregions with create.");
 		return 0;
@@ -4363,12 +4369,6 @@ static int _stats_create(CMD_ARGS)
 		name = argv[1];
 	}
 
-	/* create does not use a report */
-	if (_report) {
-		dm_report_free(_report);
-		_report = NULL;
-	}
-
 	if (_switches[AREAS_ARG])
 		areas = (uint64_t) _int_args[AREAS_ARG];
 
@@ -4443,6 +4443,12 @@ static int _stats_delete(CMD_ARGS)
 	const char *program_id = DM_STATS_PROGRAM_ID;
 	int allregions = _switches[ALL_REGIONS_ARG];
 
+	/* delete does not use a report */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
 	if (!_switches[REGION_ID_ARG] && !allregions) {
 		err("Please specify a region_id.");
 		return 0;
@@ -4462,12 +4468,6 @@ static int _stats_delete(CMD_ARGS)
 		name = argv[1];
 	}
 
-	/* delete does not use a report */
-	if (_report) {
-		dm_report_free(_report);
-		_report = NULL;
-	}
-
 	if (_switches[ALL_PROGRAMS_ARG])
 		program_id = DM_STATS_ALL_PROGRAMS;
 
@@ -4598,6 +4598,12 @@ static int _stats_print(CMD_ARGS)
 	unsigned clear = (unsigned) _switches[CLEAR_ARG];
 	int allregions = _switches[ALL_REGIONS_ARG];
 
+	/* print does not use a report */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
 	if (!_switches[REGION_ID_ARG] && !allregions) {
 		err("Please specify a region_id.");
 		return 0;
@@ -4611,12 +4617,6 @@ static int _stats_print(CMD_ARGS)
 		name = argv[1];
 	}
 
-	/* print does not use a report */
-	if (_report) {
-		dm_report_free(_report);
-		_report = NULL;
-	}
-
 	region_id = (uint64_t) _int_args[REGION_ID_ARG];
 
 	dms = dm_stats_create(DM_STATS_PROGRAM_ID);



From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat,  8 Aug 2015 10:49:44 +0000 (UTC)
Subject: master - libdm: add dm_report_column_headings
Message-ID: <20150808104944.D0E0B60E02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=666c77c0f27f1ea3d0df411b5ad64719f750c177
Commit:        666c77c0f27f1ea3d0df411b5ad64719f750c177
Parent:        cafe145ba2c77138b5b2c8832b4c784e4c9b5e76
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 7 18:11:23 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Aug 8 11:43:52 2015 +0100

libdm: add dm_report_column_headings

Add a function to print column headings regardless of whether they
have already been output. This will be used by dmstats to issue
periodic reminders of the column headings.

This patch removes a check for RH_HEADINGS_PRINTED from
_report_headings that prevents headings being displayed if the flag
is already set; this check is redundant since the only existing
caller (_output_as_columns()) already tests the flag before
calling the function.
---
 libdm/.exported_symbols.DM_1_02_104 |    1 +
 libdm/libdevmapper.h                |    8 ++++++++
 libdm/libdm-report.c                |    8 +++++---
 tools/dmsetup.c                     |    2 ++
 4 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index ec5c50b..2ec5689 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -1,3 +1,4 @@
+dm_report_column_headings
 dm_report_get_interval_ms
 dm_report_get_interval_ns
 dm_report_set_interval_ms
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ed9a79e..2289d12 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1896,6 +1896,14 @@ int dm_report_object_is_selected(struct dm_report *rh, void *object, int do_outp
 int dm_report_compact_fields(struct dm_report *rh);
 
 int dm_report_output(struct dm_report *rh);
+
+/*
+ * Output the report headings for a columns-based report, even if they
+ * have already been shown. Useful for repeating reports that wish to
+ * issue a periodic reminder of the column headings.
+ */
+int dm_report_column_headings(struct dm_report *rh);
+
 void dm_report_free(struct dm_report *rh);
 
 /*
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index edb3fe2..4b09854 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -3922,9 +3922,6 @@ static int _report_headings(struct dm_report *rh)
 	char *buf = NULL;
 	size_t buf_size = 0;
 
-	if (rh->flags & RH_HEADINGS_PRINTED)
-		return 1;
-
 	rh->flags |= RH_HEADINGS_PRINTED;
 
 	if (!(rh->flags & DM_REPORT_OUTPUT_HEADINGS))
@@ -3997,6 +3994,11 @@ static int _report_headings(struct dm_report *rh)
 	return 0;
 }
 
+int dm_report_column_headings(struct dm_report *rh)
+{
+	return _report_headings(rh);
+}
+
 /*
  * Sort rows of data
  */
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 485301a..3d675fd 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3970,6 +3970,8 @@ doit:
 		r = _perform_command_for_all_repeatable_args(cmd, subcommand, argc, argv, NULL, multiple_devices);
 
 		if (_report) {
+			if (_count > 1)
+				dm_report_column_headings(_report);
 			dm_report_output(_report);
 
 			if (_count > 1) {



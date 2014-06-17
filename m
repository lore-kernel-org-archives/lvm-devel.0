From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:13 +0000 (UTC)
Subject: master - report: select: add --select arg to pvs, vgs and lvs
Message-ID: <20140617143413.A18EC60C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b734a0ea1ab5ef3c757ec51dcadb4837fe7f936
Commit:        5b734a0ea1ab5ef3c757ec51dcadb4837fe7f936
Parent:        3a1c7e5d785a75016f5326ed6464da3b5e2d6a8a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:38:59 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:20 2014 +0200

report: select: add --select arg to pvs, vgs and lvs

---
 lib/report/report.c |    9 +++++----
 lib/report/report.h |    2 +-
 tools/args.h        |    1 +
 tools/commands.h    |   24 ++++++++++++------------
 tools/reporter.c    |    7 +++++--
 5 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 2f340ed..8a87bd2 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1234,7 +1234,7 @@ static const struct dm_report_field_type _devtypes_fields[] = {
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
 		  int aligned, int buffered, int headings, int field_prefixes,
-		  int quoted, int columns_as_rows)
+		  int quoted, int columns_as_rows, const char *selection)
 {
 	uint32_t report_flags = 0;
 	int devtypes_report = *report_type & DEVTYPES ? 1 : 0;
@@ -1258,9 +1258,10 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 	if (columns_as_rows)
 		report_flags |= DM_REPORT_OUTPUT_COLUMNS_AS_ROWS;
 
-	rh = dm_report_init(report_type, devtypes_report ? _devtypes_report_types : _report_types,
-			    devtypes_report ? _devtypes_fields : _fields, format,
-			    separator, report_flags, keys, cmd);
+	rh = dm_report_init_with_selection(report_type,
+		devtypes_report ? _devtypes_report_types : _report_types,
+		devtypes_report ? _devtypes_fields : _fields, format,
+		separator, report_flags, keys, selection, cmd);
 
 	if (rh && field_prefixes)
 		dm_report_set_output_field_name_prefix(rh, "lvm2_");
diff --git a/lib/report/report.h b/lib/report/report.h
index 2c093b0..a89a637 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -38,7 +38,7 @@ typedef int (*field_report_fn) (struct report_handle * dh, struct field * field,
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
 		  int aligned, int buffered, int headings, int field_prefixes,
-		  int quoted, int columns_as_rows);
+		  int quoted, int columns_as_rows, const char *selection);
 void report_free(void *handle);
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
diff --git a/tools/args.h b/tools/args.h
index 6a594c3..0ee380a 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -174,6 +174,7 @@ arg(physicalextentsize_ARG, 's', "physicalextentsize", size_mb_arg, 0)
 arg(stdin_ARG, 's', "stdin", NULL, 0)
 arg(snapshot_ARG, 's', "snapshot", NULL, 0)
 arg(short_ARG, 's', "short", NULL, 0)
+arg(select_ARG, 'S', "select", string_arg, 0)
 arg(thin_ARG, 'T', "thin", NULL, 0)
 arg(test_ARG, 't', "test", NULL, 0)
 arg(uuid_ARG, 'u', "uuid", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 0fa028d..f8eece9 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -574,6 +574,7 @@ xx(lvs,
    "\t[--readonly]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -584,11 +585,10 @@ xx(lvs,
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
-   nameprefixes_ARG,
-   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   readonly_ARG,
-   rows_ARG, segments_ARG, separator_ARG, sort_ARG, trustcache_ARG,
-   unbuffered_ARG, units_ARG, unquoted_ARG)
+   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG,
+   partial_ARG, readonly_ARG, rows_ARG, segments_ARG, select_ARG,
+   separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
+   unquoted_ARG)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
@@ -816,6 +816,7 @@ xx(pvs,
    "\t[--readonly]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -827,8 +828,8 @@ xx(pvs,
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
    nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG,
-   partial_ARG, readonly_ARG, rows_ARG, segments_ARG, separator_ARG, sort_ARG,
-   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   partial_ARG, readonly_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG,
+   sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -1202,6 +1203,7 @@ xx(vgs,
    "\t[-P|--partial] " "\n"
    "\t[--readonly]\n"
    "\t[--rows]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -1212,11 +1214,9 @@ xx(vgs,
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
-   nameprefixes_ARG,
-   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   readonly_ARG,
-   rows_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
-   unquoted_ARG)
+   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG,
+   partial_ARG, readonly_ARG, rows_ARG, select_ARG, separator_ARG, sort_ARG,
+   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(vgscan,
    "Search for all volume groups",
diff --git a/tools/reporter.c b/tools/reporter.c
index b20b8ed..56980cf 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -235,7 +235,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	void *report_handle;
 	const char *opts;
 	char *str;
-	const char *keys = NULL, *options = NULL, *separator;
+	const char *keys = NULL, *options = NULL, *selection = NULL, *separator;
 	int r = ECMD_PROCESSED;
 	int aligned, buffered, headings, field_prefixes, quoted;
 	int columns_as_rows;
@@ -348,10 +348,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	if (arg_count(cmd, rows_ARG))
 		columns_as_rows = 1;
 
+	if (arg_count(cmd, select_ARG))
+		selection = arg_str_value(cmd, select_ARG, NULL);
+
 	if (!(report_handle = report_init(cmd, options, keys, &report_type,
 					  separator, aligned, buffered,
 					  headings, field_prefixes, quoted,
-					  columns_as_rows))) {
+					  columns_as_rows, selection))) {
 		if ( (!strcasecmp(options, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
 		      !strcmp(options, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) ||
 		     (!strcasecmp(keys, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||



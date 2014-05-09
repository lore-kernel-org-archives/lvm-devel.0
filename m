From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:57:02 +0000 (UTC)
Subject: dev-prajnoha-selout - selout: add --select arg to pvs, vgs and lvs
Message-ID: <20140509065702.A17DD60DED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74fd20e12dde65ef9c0c5c4b7bee883fc376e481
Commit:        74fd20e12dde65ef9c0c5c4b7bee883fc376e481
Parent:        5e444773af0eed95026fd0b5f5f5850c9ee3e5a9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 28 11:58:57 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri May 9 08:51:00 2014 +0200

selout: add --select arg to pvs, vgs and lvs

---
 lib/report/report.c |   13 ++++++++++---
 lib/report/report.h |    2 +-
 tools/args.h        |    1 +
 tools/commands.h    |   24 ++++++++++++------------
 tools/reporter.c    |    7 +++++--
 5 files changed, 29 insertions(+), 18 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 7a51c81..b922cae 100644
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
@@ -1262,8 +1262,15 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 			    devtypes_report ? _devtypes_fields : _fields, format,
 			    separator, report_flags, keys, cmd);
 
-	if (rh && field_prefixes)
-		dm_report_set_output_field_name_prefix(rh, "lvm2_");
+	if (rh) {
+		if (field_prefixes)
+			dm_report_set_output_field_name_prefix(rh, "lvm2_");
+
+		if (selection && !dm_report_set_output_selection(rh, report_type, selection)) {
+			dm_report_free(rh);
+			rh = NULL;
+		}
+	}
 
 	return rh;
 }
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
index 2e63adb..5e7ab3d 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -172,6 +172,7 @@ arg(physicalextentsize_ARG, 's', "physicalextentsize", size_mb_arg, 0)
 arg(stdin_ARG, 's', "stdin", NULL, 0)
 arg(snapshot_ARG, 's', "snapshot", NULL, 0)
 arg(short_ARG, 's', "short", NULL, 0)
+arg(select_ARG, 'S', "select", string_arg, 0)
 arg(thin_ARG, 'T', "thin", NULL, 0)
 arg(test_ARG, 't', "test", NULL, 0)
 arg(uuid_ARG, 'u', "uuid", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 21a2075..9bbc124 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -545,6 +545,7 @@ xx(lvs,
    "\t[--readonly]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -555,11 +556,10 @@ xx(lvs,
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
@@ -776,6 +776,7 @@ xx(pvs,
    "\t[--readonly]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -787,8 +788,8 @@ xx(pvs,
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
    nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG,
-   partial_ARG, readonly_ARG, rows_ARG, segments_ARG, separator_ARG, sort_ARG,
-   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   partial_ARG, readonly_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG,
+   sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -1144,6 +1145,7 @@ xx(vgs,
    "\t[-P|--partial] " "\n"
    "\t[--readonly]\n"
    "\t[--rows]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -1154,11 +1156,9 @@ xx(vgs,
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
index 2591fd5..889dafa 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -253,7 +253,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	void *report_handle;
 	const char *opts;
 	char *str;
-	const char *keys = NULL, *options = NULL, *separator;
+	const char *keys = NULL, *options = NULL, *selection = NULL, *separator;
 	int r = ECMD_PROCESSED;
 	int aligned, buffered, headings, field_prefixes, quoted;
 	int columns_as_rows;
@@ -366,10 +366,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
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
 		if (!strcasecmp(options, "help") || !strcmp(options, "?"))
 			return r;
 		return_ECMD_FAILED;



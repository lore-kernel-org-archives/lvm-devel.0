From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:17 +0000 (UTC)
Subject: master - report: add 'multiple_output' arg to report_init
Message-ID: <20160620094117.B1965605A9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b107adc1da26efe6e328e969c69d619436b0366
Commit:        1b107adc1da26efe6e328e969c69d619436b0366
Parent:        2078b842fb50d73f886fb93ff9e06c08977bf8a3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 12 14:37:38 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

report: add 'multiple_output' arg to report_init

Some reports may be reported several times with possible different
selection criteria, just like command log report.
---
 lib/report/report.c |    6 +++++-
 lib/report/report.h |    3 ++-
 tools/reporter.c    |    4 ++--
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 1436cfe..3b9693d 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3703,7 +3703,8 @@ static const struct dm_report_field_type _log_fields[] = {
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
 		  int aligned, int buffered, int headings, int field_prefixes,
-		  int quoted, int columns_as_rows, const char *selection)
+		  int quoted, int columns_as_rows, const char *selection,
+		  int multiple_output)
 {
 	uint32_t report_flags = 0;
 	const struct dm_report_object_type *types;
@@ -3729,6 +3730,9 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 	if (columns_as_rows)
 		report_flags |= DM_REPORT_OUTPUT_COLUMNS_AS_ROWS;
 
+	if (multiple_output)
+		report_flags |= DM_REPORT_OUTPUT_MULTIPLE_TIMES;
+
 	if (*report_type & CMDLOG) {
 		types = _log_report_types;
 		fields = _log_fields;
diff --git a/lib/report/report.h b/lib/report/report.h
index a6f17cd..f2880ec 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -88,7 +88,8 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
 		  int aligned, int buffered, int headings, int field_prefixes,
-		  int quoted, int columns_as_rows, const char *selection);
+		  int quoted, int columns_as_rows, const char *selection,
+		  int multiple_output);
 int report_get_single_selection(struct cmd_context *cmd, const char **selection);
 void *report_init_for_selection(struct cmd_context *cmd, report_type_t *report_type,
 				const char *selection);
diff --git a/tools/reporter.c b/tools/reporter.c
index d376947..3df4bac 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1032,7 +1032,7 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 	if (!(report_handle = report_init(cmd, single_args->options, single_args->keys, &report_type,
 					  args->separator, args->aligned, args->buffered,
 					  args->headings, args->field_prefixes, args->quoted,
-					  args->columns_as_rows, single_args->selection)))
+					  args->columns_as_rows, single_args->selection, 0)))
 		goto_out;
 
 	handle->custom_handle = report_handle;
@@ -1462,7 +1462,7 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 			if (!(tmp_log_rh = report_init(NULL, single_args->options, single_args->keys, &single_args->report_type,
 							  args.separator, args.aligned, args.buffered, args.headings,
 							  args.field_prefixes, args.quoted, args.columns_as_rows,
-							  single_args->selection))) {
+							  single_args->selection, 1))) {
 				log_error("Failed to create log report.");
 				goto bad;
 			}



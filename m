From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Tue, 16 Aug 2022 11:43:16 +0000 (GMT)
Subject: main - report: report numeric values (not string synonyms) for NUM and BIN fields with json_std format
Message-ID: <20220816114316.5BFE9385843E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81839cc4ebf566ea9f3e6d819c7338b98cdec374
Commit:        81839cc4ebf566ea9f3e6d819c7338b98cdec374
Parent:        ce58e9d5b37c3e408f2b41c8095980490a87f2a4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 15 11:40:52 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 16 13:42:50 2022 +0200

report: report numeric values (not string synonyms) for NUM and BIN fields with json_std format

Internally, NUM and BIN fields are marked as DM_REPORT_FIELD_TYPE_NUM_NUMBER
through libdevmapper API. The new 'json_std' format mandates that the report
string representing such a value must be a number, not an arbitrary string.
This is because numeric values in 'json_std' format do not have double quotes
around them. This practically means, we can't use string synonyms
("named reserved values") for such values and the report string must always
represent a proper number.

With 'json' and 'basic' formats, this is not an issue because 'basic' format
doesn't have any structure or typing at all and 'json' format puts all values
in quotes, including numeric ones.
---
 lib/commands/toolcontext.h |  1 +
 lib/report/report.c        |  7 ++++---
 man/lvmreport.7_main       |  4 ++++
 tools/reporter.c           | 10 ++++++++++
 4 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index f16322d4e..7a4979b33 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -144,6 +144,7 @@ struct cmd_context {
 	unsigned degraded_activation:1;
 	unsigned auto_set_activation_skip:1;
 	unsigned si_unit_consistency:1;
+	unsigned report_strict_type_mode:1;
 	unsigned report_binary_values_as_numeric:1;
 	unsigned report_mark_hidden_devices:1;
 	unsigned metadata_read_only:1;
diff --git a/lib/report/report.c b/lib/report/report.c
index c06b22674..8a5122ff9 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1256,7 +1256,7 @@ static int _binary_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 {
 	const struct cmd_context *cmd = (const struct cmd_context *) private;
 
-	if (cmd->report_binary_values_as_numeric)
+	if (cmd->report_strict_type_mode || cmd->report_binary_values_as_numeric)
 		/* "0"/"1" */
 		return _field_set_value(field, bin_value ? _str_one : _str_zero, bin_value ? &_one64 : &_zero64);
 
@@ -1269,7 +1269,7 @@ static int _binary_undef_disp(struct dm_report *rh, struct dm_pool *mem __attrib
 {
 	const struct cmd_context *cmd = (const struct cmd_context *) private;
 
-	if (cmd->report_binary_values_as_numeric)
+	if (cmd->report_strict_type_mode || cmd->report_binary_values_as_numeric)
 		return _field_set_value(field, GET_FIRST_RESERVED_NAME(num_undef_64), &GET_TYPE_RESERVED_VALUE(num_undef_64));
 
 	return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(num_undef_64));
@@ -3041,10 +3041,11 @@ static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
 				   struct dm_report_field *field,
 				   const void *data, void *private)
 {
+	struct cmd_context *cmd = (struct cmd_context *) private;
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint32_t count = vg_mda_copies(vg);
 
-	if (count == VGMETADATACOPIES_UNMANAGED)
+	if (count == VGMETADATACOPIES_UNMANAGED && !cmd->report_strict_type_mode)
 		return _field_set_value(field, GET_FIRST_RESERVED_NAME(vg_mda_copies_unmanaged),
 					GET_FIELD_RESERVED_VALUE(vg_mda_copies_unmanaged));
 
diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index 1ef5d25db..0015cdce7 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -1335,6 +1335,10 @@ compared to the original \fBjson\fP format:
 .RS
 - it does not use double quotes around numeric values,
 .br
+- numeric values are always expressed as numbers, not reserved strings
+  representing them (this also means that report/binary_values_as_numeric=1
+  setting is forced)
+.br
 - it uses 'null' for undefined numeric values,
 .br
 - it prints string list as proper JSON array of strings instead of a single string.
diff --git a/tools/reporter.c b/tools/reporter.c
index b31f1891e..e62858f42 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1495,6 +1495,16 @@ int report_format_init(struct cmd_context *cmd)
 		return 0;
 	}
 
+	/*
+	 * JSON_STD requires strict type mode. That means all NUM and BIN
+	 * fields are always reported as numeric values and not strings which
+	 * are synonyms to these numeric values.
+	 */
+	if (args.report_group_type == DM_REPORT_GROUP_JSON_STD)
+		cmd->report_strict_type_mode = 1;
+	else
+		cmd->report_strict_type_mode = 0;
+
 	if (report_command_log) {
 		single_args = &args.single_args[REPORT_IDX_LOG];
 		single_args->report_type = CMDLOG;


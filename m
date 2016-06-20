From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:23 +0000 (UTC)
Subject: master - toollib: add report_format_init fn to create report group and to create/add log report handle
Message-ID: <20160620094023.552F06031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79a74e9aaecee0b02cfd83f544a99870f29e0016
Commit:        79a74e9aaecee0b02cfd83f544a99870f29e0016
Parent:        c36d4632a697f6e8f68a214a7c7db9f6fb25c09c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 2 14:22:02 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:41 2016 +0200

toollib: add report_format_init fn to create report group and to create/add log report handle

Add new --reportformat option and new report_format_init function that
checks this option and creates new report group accordingly, also
preparing log report handle and adding it to the report group just
created.
---
 WHATS_NEW           |    1 +
 lib/report/report.h |    3 ++
 tools/args.h        |    1 +
 tools/reporter.c    |   66 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1e80d82..90ae561 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Recognize --reportformat {basic|json} option to select report output format.
   Add log/command_log_{sort,cols} to lvm.conf to configure command log report.
   Add log_object_{type,name,id,group,group_id} fields to cmd log.
   Add log_{seq_num,type,context,message,errno,ret_code} fields to cmd log.
diff --git a/lib/report/report.h b/lib/report/report.h
index 06ffe70..62c52dc 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -80,6 +80,9 @@ struct processing_handle;
 typedef int (*field_report_fn) (struct report_handle * dh, struct field * field,
 				const void *data);
 
+int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_group_type,
+		       struct dm_report_group **report_group, struct dm_report **log_rh);
+
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
 		  int aligned, int buffered, int headings, int field_prefixes,
diff --git a/tools/args.h b/tools/args.h
index ef9dbc9..049ea5a 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -96,6 +96,7 @@ arg(refresh_ARG, '\0', "refresh", NULL, 0)
 arg(removemissing_ARG, '\0', "removemissing", NULL, 0)
 arg(repair_ARG, '\0', "repair", NULL, 0)
 arg(replace_ARG, '\0', "replace", string_arg, ARG_GROUPABLE)
+arg(reportformat_ARG, '\0', "reportformat", string_arg, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
 arg(restoremissing_ARG, '\0', "restoremissing", NULL, 0)
 arg(resync_ARG, '\0', "resync", NULL, 0)
diff --git a/tools/reporter.c b/tools/reporter.c
index 4714ae1..fa66064 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -20,6 +20,7 @@
 struct report_args {
 	int argc;
 	char **argv;
+	dm_report_group_type_t report_group_type;
 	report_type_t report_type;
 	int args_are_pvs;
 	int aligned;
@@ -1061,3 +1062,68 @@ int devtypes(struct cmd_context *cmd, int argc, char **argv)
 {
 	return _report(cmd, argc, argv, DEVTYPES);
 }
+
+#define REPORT_FORMAT_NAME_BASIC "basic"
+#define REPORT_FORMAT_NAME_JSON "json"
+
+int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_group_type,
+		       struct dm_report_group **report_group, struct dm_report **log_rh)
+{
+	static char log_report_name[] = "log";
+	const char *format_str = arg_str_value(cmd, reportformat_ARG, NULL);
+	struct report_args args = {0};
+	struct dm_report_group *new_report_group;
+	struct dm_report *tmp_log_rh = NULL;
+
+	if (!format_str) {
+		args.report_group_type = DM_REPORT_GROUP_SINGLE;
+	} else if (!strcmp(format_str, REPORT_FORMAT_NAME_BASIC)) {
+		args.report_group_type = DM_REPORT_GROUP_BASIC;
+	} else if (!strcmp(format_str, REPORT_FORMAT_NAME_JSON)) {
+		args.report_group_type = DM_REPORT_GROUP_JSON;
+	} else {
+		log_error("%s: unknown report format.", format_str);
+		log_error("Supported report formats: %s, %s.",
+			  REPORT_FORMAT_NAME_BASIC,
+			  REPORT_FORMAT_NAME_JSON);
+		return 0;
+	}
+
+	if (report_group_type)
+		*report_group_type = args.report_group_type;
+
+	if (!(new_report_group = dm_report_group_create(args.report_group_type, NULL))) {
+		log_error("Failed to create report group.");
+		return 0;
+	}
+
+	if (!*log_rh) {
+		args.report_type = CMDLOG;
+		if (!_config_report(cmd, &args))
+			goto_bad;
+
+		if (!(tmp_log_rh = report_init(NULL, args.options, args.keys, &args.report_type,
+						  args.separator, args.aligned, args.buffered, args.headings,
+						  args.field_prefixes, args.quoted, args.columns_as_rows,
+						  args.selection))) {
+			log_error("Failed to create log report.");
+			goto bad;
+		}
+	}
+
+	if (!(dm_report_group_push(new_report_group, tmp_log_rh ? : *log_rh, log_report_name))) {
+		log_error("Failed to add log report to report group.");
+		goto bad;
+	}
+
+	*report_group = new_report_group;
+	if (tmp_log_rh)
+		*log_rh = tmp_log_rh;
+	return 1;
+bad:
+	if (!dm_report_group_destroy(new_report_group))
+		stack;
+	if (tmp_log_rh)
+		dm_report_free(tmp_log_rh);
+	return 0;
+}



From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:35 +0000 (UTC)
Subject: master - report: add current report to existing group
Message-ID: <20160620094035.D0E5D6031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10a1b9e18248f08f11af2bb0214fa857d0c9d6fc
Commit:        10a1b9e18248f08f11af2bb0214fa857d0c9d6fc
Parent:        f752a953022387cc7e5c4da11d118c12e3716ce4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 2 14:37:16 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:41 2016 +0200

report: add current report to existing group

Add any report (pvs/vgs/lvs) currently processed to current report group
which is part of processing handle and which already contains log
report. This way both log report and pvs/vgs/lvs report will be
reported as a whole within a group, thus having same output format as
selected by --reportformat option.
---
 tools/reporter.c |   54 +++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 45 insertions(+), 9 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 7bd5d36..9f4f95a 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -26,6 +26,8 @@ typedef enum {
 
 struct single_report_args {
 	report_type_t report_type;
+	char report_prefix[32];
+	const char *report_name;
 	int args_are_pvs;
 	const char *keys;
 	const char *options;
@@ -822,6 +824,32 @@ static int _get_report_selection(struct cmd_context *cmd,
 	return r;
 }
 
+static int _set_report_prefix_and_name(struct single_report_args *single_args)
+{
+	const char *report_prefix;
+	size_t len;
+
+	report_prefix = report_get_field_prefix(single_args->report_type);
+	len = strlen(report_prefix);
+	if (report_prefix[len - 1] == '_')
+		len--;
+
+	if (!len) {
+		log_error(INTERNAL_ERROR "_set_report_prefix_and_name: no prefix "
+			  "found for report type 0x%x", single_args->report_type);
+		return 0;
+	}
+
+	if (!dm_strncpy(single_args->report_prefix, report_prefix, sizeof(single_args->report_prefix))) {
+		log_error("_set_report_prefix_and_name: dm_strncpy failed");
+		return 0;
+	}
+	single_args->report_prefix[len] = '\0';
+	single_args->report_name = single_args->report_prefix;
+
+	return 1;
+}
+
 static int _do_report(struct cmd_context *cmd, struct report_args *args, struct single_report_args *single_args)
 {
 	struct processing_handle *handle = NULL;
@@ -851,6 +879,9 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args, struct
 				    &report_type))
 		goto_out;
 
+	if (!dm_report_group_push(handle->report_group, report_handle, (void *) single_args->report_name))
+		goto_out;
+
 	/*
 	 * We lock VG_GLOBAL to enable use of metadata cache.
 	 * This can pause alongide pvscan or vgscan process for a while.
@@ -959,6 +990,9 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 	/* Check PV specifics and do extra changes/actions if needed. */
 	_check_pv_list(cmd, args, single_args);
 
+	if (!_set_report_prefix_and_name(single_args))
+		return_0;
+
 	switch (single_args->report_type) {
 		case DEVTYPES:
 			single_args->keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
@@ -1141,10 +1175,10 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 	}
 
 	if (report_command_log) {
-		if (!*log_rh) {
-			single_args = &args.single_args[REPORT_IDX_LOG];
-			single_args->report_type = CMDLOG;
+		single_args = &args.single_args[REPORT_IDX_LOG];
+		single_args->report_type = CMDLOG;
 
+		if (!*log_rh) {
 			if (!_config_report(cmd, &args, single_args))
 				goto_bad;
 
@@ -1155,19 +1189,21 @@ int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_g
 				log_error("Failed to create log report.");
 				goto bad;
 			}
+		} else {
+			/*
+			 * We reusing existing log report handle.
+			 * Just get report's name and prefix now.
+			 */
+			if (!_set_report_prefix_and_name(single_args))
+				goto_bad;
 		}
 
-		if (!(dm_report_group_push(new_report_group, *log_rh ? : tmp_log_rh, log_report_name))) {
+		if (!(dm_report_group_push(new_report_group, tmp_log_rh ? : *log_rh, (void *) single_args->report_name))) {
 			log_error("Failed to add log report to report group.");
 			goto bad;
 		}
 	}
 
-	if (!(dm_report_group_push(new_report_group, tmp_log_rh ? : *log_rh, log_report_name))) {
-		log_error("Failed to add log report to report group.");
-		goto bad;
-	}
-
 	*report_group = new_report_group;
 	if (tmp_log_rh)
 		*log_rh = tmp_log_rh;



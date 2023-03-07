From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Tue,  7 Mar 2023 14:30:36 +0000 (GMT)
Subject: main - toollib: fix segfault if using -S|--select with log/report_command_log=1 setting
Message-ID: <20230307143036.A8D95385559E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cd14d3fcc0e03136d0cea1ab1a9edff3b8b9dbeb
Commit:        cd14d3fcc0e03136d0cea1ab1a9edff3b8b9dbeb
Parent:        c8f2125b85afe043af1b2e887a80f882b8d8d7c7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 7 14:45:06 2023 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 7 15:29:54 2023 +0100

toollib: fix segfault if using -S|--select with log/report_command_log=1 setting

When we are using -S|--select for non-reporting tools while using command log
reporting (log/report_command_log=1 setting), we need to create an internal
processing handle to handle the selection itself. In this case, the internal
processing handle to execute the selection (to process the -S|--select) has
a parent handle (that is processing the actual non-reporting command).

When this parent handle exists, we can't destroy the command log report
in destroy_processing_handle as there's still the parent processing to
finish. The parent processing may still generate logs which need to be
reported in the command log report. If the command log report was
destroyed prematurely together with destroying the internal processing
handle for -S|--select, then any subsequent log request from processing
the actual command (and hence an attermpt to access the command log report)
ended up with a segfault.

See also: https://bugzilla.redhat.com/show_bug.cgi?id=2175220
---
 WHATS_NEW       |  1 +
 tools/toollib.c | 15 ++++++++++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8523b5eb7..7c979d69c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 version 2.03.20 - 
 ====================================
+  Fix segfault if using -S|--select with log/report_command_log=1 setting.
   Configure now fails when requested lvmlockd dependencies are missing.
   Add some configure Gentoo enhancements for static builds.
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 194088ea6..43e628abf 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2050,7 +2050,20 @@ void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle
 
 		log_restore_report_state(cmd->cmd_report.saved_log_report_state);
 
-		if (!cmd->is_interactive) {
+		/*
+		 * Do not destroy current cmd->report_group and cmd->log_rh
+		 * (the log report) yet if we're running interactively
+		 * (== running in lvm shell) or if there's a parent handle
+		 * (== we're executing nested processing, like it is when
+		 * doing selection for parent's process_each_* processing).
+		 *
+		 * In both cases, there's still possible further processing
+		 * to do outside the processing covered by the handle we are
+		 * destroying here and for which we may still need to access
+		 * the log report to cover the rest of the processing.
+		 *
+		 */
+		if (!cmd->is_interactive && !handle->parent) {
 			if (!dm_report_group_destroy(cmd->cmd_report.report_group))
 				stack;
 			cmd->cmd_report.report_group = NULL;


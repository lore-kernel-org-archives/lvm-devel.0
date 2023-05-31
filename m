From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Wed, 31 May 2023 07:30:05 +0000 (GMT)
Subject: main - reporter: restore report type to initial value after processing report_for_selection
Message-ID: <20230531073005.1D89B3858C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=031f7a4639eb808e2a86e57a215dd9def7519ac4
Commit:        031f7a4639eb808e2a86e57a215dd9def7519ac4
Parent:        0591131a539fb668412fc38807686d2a89decd27
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 30 21:14:37 2023 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed May 31 09:28:11 2023 +0200

reporter: restore report type to initial value after processing report_for_selection

If we are executing 'report_for_selection' to do an internal report
just for the selection itself (not for display), we call
'report_for_selection'. We can call this  more than once, in which case
we are reusing the same selection handle (e.g. inside 'process_each_lv_in_vg').

The selection handle has 'report_type' field which is a union of all
report types needed for the report based on selection fields we actually
use.

The 'report_type' is further clarified based on checks and rules inside
'_get_final_report_type' which 'report_for_selection' calls. Then, this
final report type unambiguously identifies proper branch to take in
'report_all_in_{pv,vg,lv}' that is called next.

If the 'report_for_selection' is called more than once with the same
selection handle, we need to make sure that we always restore the report
type to its initial value, so all the rules inside 'report_for_selection'
are applied correctly next time.

This patch fixes the missing restoration of the 'report_type' value in
'selection_handle' that is reused for recurring 'report_for_selection'
calls.

An example scenario where this failed was with selecting an LV for
removal with "lvremove --select" while using a field in the selection
that required extra DM info or DM status call for the LV (that is,
"Logical Volume Device Info Fields" and "Logical Volume Device Status Fields"
as visible in 'lvs -S help').
---
 WHATS_NEW        | 1 +
 tools/reporter.c | 7 ++++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ad870317d..493567c5d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 version 2.03.22 - 
 =================================
+  Fix failing -S|--select for non-reporting cmds if using LV info/status fields.
 
 version 2.03.21 - 21st April 2023
 =================================
diff --git a/tools/reporter.c b/tools/reporter.c
index e62858f42..45273c0a4 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -633,6 +633,7 @@ int report_for_selection(struct cmd_context *cmd,
 			 struct logical_volume *lv)
 {
 	struct selection_handle *sh = parent_handle->selection_handle;
+	report_type_t initial_report_type = sh->report_type;
 	struct report_args args = {0};
 	struct single_report_args *single_args = &args.single_args[REPORT_IDX_SINGLE];
 	int do_lv_info, do_lv_seg_status;
@@ -648,8 +649,10 @@ int report_for_selection(struct cmd_context *cmd,
 				    &sh->report_type))
 		return_0;
 
-	if (!(handle = init_processing_handle(cmd, parent_handle)))
+	if (!(handle = init_processing_handle(cmd, parent_handle))) {
+		sh->report_type = initial_report_type;
 		return_0;
+	}
 
 	/*
 	 * We're already reporting for select so override
@@ -695,6 +698,8 @@ int report_for_selection(struct cmd_context *cmd,
 			break;
 	}
 
+	sh->report_type = initial_report_type;
+
 	/*
 	 * Keep the selection handle provided from the caller -
 	 * do not destroy it - the caller will still use it to


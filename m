From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:31 +0000 (UTC)
Subject: master - toollib: add report_group and log_rh to processing_handle and initialize cmd processing log report
Message-ID: <20160620094031.A8AAE6031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c099f531fbb1702ea0aed16e5deec0368e7e7250
Commit:        c099f531fbb1702ea0aed16e5deec0368e7e7250
Parent:        213434d426622b34f2fd7bc2e74f6e5ca0c6c125
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 23 10:16:29 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:41 2016 +0200

toollib: add report_group and log_rh to processing_handle and initialize cmd processing log report

Wire up report group creation with log report in struct
processing_handle and call report_format_init during processing handle
initialization (init_processing_handle fn) and destroy it while
destroing processing handle (destroy_processing_handle fn).

This way, all the LVM command processing using processing handle
has access to log report via which the current command log
can be reported as items are processed.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |   10 ++++++++++
 tools/toollib.h |    3 +++
 3 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ebddfd0..349bd30 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Integrate report group handling and cmd log report into cmd processing code.
   Add log/report_command_log to lvm.conf to enable or disable cmd log report.
   Add log/report_output_format to lvm.conf for default report output format.
   Recognize --reportformat {basic|json} option to select report output format.
diff --git a/tools/toollib.c b/tools/toollib.c
index 9353814..e091467 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1725,6 +1725,12 @@ struct processing_handle *init_processing_handle(struct cmd_context *cmd)
 	handle->internal_report_for_select = arg_is_set(cmd, select_ARG);
 	handle->include_historical_lvs = cmd->include_historical_lvs;
 
+	if (!report_format_init(cmd, &handle->report_group_type, &handle->report_group,
+				&handle->log_rh)) {
+		dm_pool_free(cmd->mem, handle);
+		return NULL;
+	}
+
 	return handle;
 }
 
@@ -1754,6 +1760,10 @@ void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle
 	if (handle) {
 		if (handle->selection_handle && handle->selection_handle->selection_rh)
 			dm_report_free(handle->selection_handle->selection_rh);
+		if (!dm_report_group_destroy(handle->report_group))
+			stack;
+		if (handle->log_rh)
+			dm_report_free(handle->log_rh);
 		/*
 		 * TODO: think about better alternatives:
 		 * handle mempool, dm_alloc for handle memory...
diff --git a/tools/toollib.h b/tools/toollib.h
index 06d0ef9..622badc 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -72,6 +72,9 @@ struct processing_handle {
 	int internal_report_for_select;
 	int include_historical_lvs;
 	struct selection_handle *selection_handle;
+	dm_report_group_type_t report_group_type;
+	struct dm_report_group *report_group;
+	struct dm_report *log_rh;
 	void *custom_handle;
 };
 



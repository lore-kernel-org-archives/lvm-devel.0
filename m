From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:52 +0000 (UTC)
Subject: master - cmd: add '-H|--history' switch and wire it up in cmd_context and processing_handle
Message-ID: <20160303131952.DF90C6024B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f7e0a4cc1809c371a4aee2a3da8a3545379fcfbf
Commit:        f7e0a4cc1809c371a4aee2a3da8a3545379fcfbf
Parent:        baee45a103846a995b847e04c1c2985bfd1743e0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:22:48 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:14 2016 +0100

cmd: add '-H|--history' switch and wire it up in cmd_context and processing_handle

This patch adds "include_historical_lvs" field to struct cmd_context to
make it possible for the command to switch between original funcionality
where no historical LVs are processed and functionality where historical
LVs are taken into account (and reported or processed further). The switch
between these modes is done using the '-H|--history' switch on command
line.

The include_historical_lvs state is then passed to process_each_* fns
using the "include_historical_lvs" field within struct processing_handle.
---
 lib/commands/toolcontext.h |    1 +
 tools/args.h               |    1 +
 tools/lvmcmdline.c         |    1 +
 tools/reporter.c           |    5 +++++
 tools/toollib.c            |    1 +
 tools/toollib.h            |    1 +
 6 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 5fda9a9..b5328e8 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -128,6 +128,7 @@ struct cmd_context {
 	unsigned threaded:1;			/* set if running within a thread e.g. clvmd */
 	unsigned independent_metadata_areas:1;	/* active formats have MDAs outside PVs */
 	unsigned unknown_system_id:1;
+	unsigned include_historical_lvs:1;	/* also process/report/display historical LVs */
 	unsigned include_foreign_vgs:1;		/* report/display cmds can reveal foreign VGs */
 	unsigned include_shared_vgs:1;		/* report/display cmds can reveal lockd VGs */
 	unsigned include_active_foreign_vgs:1;	/* cmd should process foreign VGs with active LVs */
diff --git a/tools/args.h b/tools/args.h
index 68de524..8dfe744 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -163,6 +163,7 @@ arg(force_ARG, 'f', "force", NULL, ARG_COUNTABLE)
 arg(full_ARG, 'f', "full", NULL, 0)
 arg(help_ARG, 'h', "help", NULL, 0)
 arg(cache_ARG, 'H', "cache", NULL, 0)
+arg(history_ARG, 'H', "history", NULL, 0)
 arg(help2_ARG, '?', "", NULL, 0)
 arg(interval_ARG, 'i', "interval", int_arg, 0)
 arg(iop_version_ARG, 'i', "iop_version", NULL, 0)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 29c1c7e..4a5cd23 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1101,6 +1101,7 @@ static int _get_settings(struct cmd_context *cmd)
 	cmd->ignore_clustered_vgs = arg_is_set(cmd, ignoreskippedcluster_ARG);
 	cmd->include_foreign_vgs = arg_is_set(cmd, foreign_ARG) ? 1 : 0;
 	cmd->include_shared_vgs = arg_is_set(cmd, shared_ARG) ? 1 : 0;
+	cmd->include_historical_lvs = arg_is_set(cmd, history_ARG) ? 1 : 0;
 
 	/*
 	 * This is set to zero by process_each which wants to print errors
diff --git a/tools/reporter.c b/tools/reporter.c
index 0c73a09..1a708c4 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -65,6 +65,10 @@ static int _do_info_and_status(struct cmd_context *cmd,
 	unsigned use_layer = lv_is_thin_pool(lv) ? 1 : 0;
 
 	status->lv = lv;
+
+	if (lv_is_historical(lv))
+		return 1;
+
 	if (do_status) {
 		if (!(status->seg_status.mem = dm_pool_create("reporter_pool", 1024)))
 			return_0;
@@ -866,6 +870,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	handle.internal_report_for_select = 0;
+	handle.include_historical_lvs = cmd->include_historical_lvs;
 	handle.custom_handle = report_handle;
 
 	switch (report_type) {
diff --git a/tools/toollib.c b/tools/toollib.c
index dba5023..3833581 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1692,6 +1692,7 @@ struct processing_handle *init_processing_handle(struct cmd_context *cmd)
 	 * *The internal report for select is only needed for non-reporting tools!*
 	 */
 	handle->internal_report_for_select = arg_is_set(cmd, select_ARG);
+	handle->include_historical_lvs = cmd->include_historical_lvs;
 
 	return handle;
 }
diff --git a/tools/toollib.h b/tools/toollib.h
index a67b3e6..19f4dd0 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -70,6 +70,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm);
  */
 struct processing_handle {
 	int internal_report_for_select;
+	int include_historical_lvs;
 	struct selection_handle *selection_handle;
 	void *custom_handle;
 };



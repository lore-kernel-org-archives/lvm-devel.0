From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:26 +0000 (UTC)
Subject: master - tools: add 'lvm lastlog' command for interactive query and display of last command's log
Message-ID: <20160620094126.094E4606C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89e2aef63a9a2b29b1f83a589d108c25236b4ae1
Commit:        89e2aef63a9a2b29b1f83a589d108c25236b4ae1
Parent:        c33c0545aff1d531972682c8777e5db5e8da5676
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri May 20 15:30:58 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

tools: add 'lvm lastlog' command for interactive query and display of last command's log

If we're running in lvm shell, we can keep last command's log report
for further query with possible different selection criteria for easy
log lookup.
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |    3 +++
 lib/commands/toolcontext.h |    5 +++++
 tools/Makefile.in          |    2 +-
 tools/commands.h           |    9 +++++++++
 tools/lvm.c                |    6 ++++++
 tools/reporter.c           |   35 +++++++++++++++++++++++++++++++++++
 tools/toollib.c            |   12 ++++++++++--
 8 files changed, 70 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f800eca..6f6e9e8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Add lvm lastlog command for query and display of last cmd's log in lvm shell.
   Report per-object return codes via cmd log while processing multiple objects.
   Annotate processing code with log report hooks for per-object command log.
   Also pass common printed messages (besides warnings and errors) to log report.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 076f48d..75f19c9 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -2247,6 +2247,9 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	if (cmd->cft_def_hash)
 		dm_hash_destroy(cmd->cft_def_hash);
 
+	if (cmd->log_rh)
+		dm_report_free(cmd->log_rh);
+
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index c04455c..ee849b5 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -186,6 +186,11 @@ struct cmd_context {
 	char proc_dir[PATH_MAX];
 
 	/*
+	 * Command log reporting.
+	 */
+	struct dm_report *log_rh;		/* keep log report of last cmd for further queries if cmd line is interactive (e.g. lvm shell) */
+
+	/*
 	 * Buffers.
 	 */
 	char display_buffer[NAME_LEN * 10];	/* ring buffer for upto 10 longest vg/lv names */
diff --git a/tools/Makefile.in b/tools/Makefile.in
index bb29176..8dfac7f 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -168,7 +168,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
-		egrep -v '^ *(|#.*|config|devtypes|dumpconfig|formats|fullreport|help|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
+		egrep -v '^ *(|#.*|config|devtypes|dumpconfig|formats|fullreport|help|lastlog|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
diff --git a/tools/commands.h b/tools/commands.h
index 3f0fff5..d54a50c 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -174,6 +174,15 @@ xx(fullreport,
    rows_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
    unbuffered_ARG, units_ARG, unquoted_ARG)
 
+xx(lastlog,
+   "Display last command's log report",
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
+   "log\n"
+   "\t[--reportformat {json}]\n"
+   "\t[-S|--select Selection]\n",
+
+   reportformat_ARG, select_ARG)
+
 xx(lvchange,
    "Change the attributes of logical volume(s)",
    CACHE_VGMETADATA | PERMITTED_READ_ONLY,
diff --git a/tools/lvm.c b/tools/lvm.c
index 18e3490..62cc141 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -235,6 +235,12 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 			break;
 		}
 
+		if (cmd->log_rh && strcmp(argv[0], "lastlog")) {
+			/* drop old log report */
+			dm_report_free(cmd->log_rh);
+			cmd->log_rh = NULL;
+		}
+
 		ret = lvm_run_command(cmd, argc, argv);
 		if (ret == ENO_SUCH_CMD)
 			log_error("No such command '%s'.  Try 'help'.",
diff --git a/tools/reporter.c b/tools/reporter.c
index 3df4bac..c732d0e 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1497,3 +1497,38 @@ bad:
 		dm_report_free(tmp_log_rh);
 	return 0;
 }
+
+int lastlog(struct cmd_context *cmd, int argc, char **argv)
+{
+	static report_idx_t expected_idxs[] = {REPORT_IDX_SINGLE, REPORT_IDX_LOG, REPORT_IDX_NULL};
+	struct dm_report_group *report_group = NULL;
+	const char *selection = NULL;
+	int r = ECMD_FAILED;
+
+	if (!cmd->log_rh) {
+		log_error("No log report stored.");
+		goto out;
+	}
+
+	if (!report_format_init(cmd, NULL, &report_group, &cmd->log_rh, NULL))
+		goto_out;
+
+	if (arg_count(cmd, select_ARG) &&
+	    !_do_report_get_selection(cmd, NULL, NULL, expected_idxs, &selection))
+		goto_out;
+
+	if (!dm_report_set_selection(cmd->log_rh, selection)) {
+		log_error("Failed to set selection for log report.");
+		goto out;
+	}
+
+	if (!dm_report_output(cmd->log_rh) ||
+	    !dm_report_group_pop(report_group))
+		goto_out;
+
+	r = ECMD_PROCESSED;
+out:
+	if (!dm_report_group_destroy(report_group))
+		stack;
+	return r;
+}
diff --git a/tools/toollib.c b/tools/toollib.c
index e044cb4..41ef549 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1778,8 +1778,16 @@ void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle
 
 		if (!dm_report_group_destroy(handle->report_group))
 			stack;
-		if (handle->log_rh)
-			dm_report_free(handle->log_rh);
+		if (handle->log_rh) {
+			if (cmd->is_interactive) {
+				/*
+				 * Keep log report if we're interactive so
+				 * we can do further queries on this report.
+				 */
+				cmd->log_rh = handle->log_rh;
+			} else
+				dm_report_free(handle->log_rh);
+		}
 		/*
 		 * TODO: think about better alternatives:
 		 * handle mempool, dm_alloc for handle memory...



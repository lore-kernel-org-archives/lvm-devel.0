From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 18 Oct 2016 17:07:51 +0000 (UTC)
Subject: master - dmsetup: Produce partial output if dev disappears.
Message-ID: <20161018170751.B44E460F13@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34da83d729436d245e91e24e30b6996862fe7725
Commit:        34da83d729436d245e91e24e30b6996862fe7725
Parent:        5c55c4ac18f60822da6bf61dde9dec3467a9e79a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Oct 18 18:01:52 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 18 18:01:52 2016 +0100

dmsetup: Produce partial output if dev disappears.

If a device disappears after obtaining the list of devices but before
processing it as a member of that list, dmsetup exits with a failure code.

Most commands still produce what output they can in these circumstances,
but 'ls --tree' and 'info -c' with fields depending on device dependencies
didn't.  Change this.
---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |   53 ++++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 37 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c69eb27..58a302e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Still produce output when dmsetup dependency tree building finds dev missing.
   Check and report pthread_sigmask() failure in dmeventd.
   Check mem alloc fail in _canonicalize_field_ids().
   Use unsigned math when checking more then 31 legs of raid.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5b817bb..9d357ec 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2707,6 +2707,9 @@ static int _add_dep(CMD_ARGS)
 
 /*
  * Create and walk dependency tree
+ *
+ * An incomplete _dtree may still be used by the caller,
+ * but the error must be reported.
  */
 static int _build_whole_deptree(const struct command *cmd)
 {
@@ -2724,12 +2727,14 @@ static int _build_whole_deptree(const struct command *cmd)
 
 static int _display_tree(CMD_ARGS)
 {
-	if (!_build_whole_deptree(cmd))
-		return_0;
+	int r;
 
-	_display_tree_walk_children(dm_tree_find_node(_dtree, 0, 0), 0);
+	r = _build_whole_deptree(cmd);
 
-	return 1;
+	if (_dtree)
+		_display_tree_walk_children(dm_tree_find_node(_dtree, 0, 0), 0);
+
+	return r;
 }
 
 /*
@@ -4471,9 +4476,14 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 				selection, NULL, NULL)))
 		goto_out;
 
-	if ((_report_type & DR_TREE) && cmd && !_build_whole_deptree(cmd)) {
-		err("Internal device dependency tree creation failed.");
-		goto out;
+	r = 1;
+
+	if ((_report_type & DR_TREE) && cmd) {
+		r = _build_whole_deptree(cmd);
+		if  (!_dtree) {
+			err("Internal device dependency tree creation failed.");
+			goto out;
+		}
 	}
 
 	if (!_switches[INTERVAL_ARG])
@@ -4484,8 +4494,6 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 	if (field_prefixes)
 		dm_report_set_output_field_name_prefix(_report, "dm_");
 
-	r = 1;
-
 out:
 	if (len)
 		dm_free(options);
@@ -6782,8 +6790,15 @@ unknown:
 		argc--, argv++;
 	}
 
-	if (_switches[COLS_ARG] && !_report_init(cmd, subcommand))
-		goto_out;
+	/* Default to success */
+	ret = 0;
+
+	if (_switches[COLS_ARG]) {
+		if (!_report_init(cmd, subcommand))
+			ret = 1;
+ 		if (!_report)
+			goto_out;
+	}
 
 	if (_switches[COUNT_ARG])
 		_count = ((uint32_t)_int_args[COUNT_ARG]) ? : UINT32_MAX;
@@ -6795,14 +6810,17 @@ unknown:
 						  &_disp_units);
 		if (!_disp_factor) {
 			log_error("Invalid --units argument.");
+			ret = 1;
 			goto out;
 		}
 	}
 
 	/* Start interval timer. */
 	if (_count > 1)
-		if (!_start_timer())
+		if (!_start_timer()) {
+			ret = 1;
 			goto_out;
+		}
 
 doit:
 	multiple_devices = (cmd->repeatable_cmd && argc != 1 &&
@@ -6819,18 +6837,19 @@ doit:
 			if (_count > 1 && r) {
 				printf("\n");
 				/* wait for --interval and update timestamps */
-				if (!_do_report_wait())
+				if (!_do_report_wait()) {
+					ret = 1;
 					goto_out;
+				}
 			}
 		}
 
-		if (!r)
+		if (!r) {
+			ret = 1;
 			goto_out;
+		}
 	} while (--_count);
 
-	/* Success */
-	ret = 0;
-
 out:
 	if (_report)
 		dm_report_free(_report);



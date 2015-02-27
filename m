From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 27 Feb 2015 12:38:23 +0000 (UTC)
Subject: master - report: fix handling of reports with pure label fields
Message-ID: <20150227123823.9B6B26105B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ea77b788b0822fe06e8efb92d13f80dbc62e351
Commit:        9ea77b788b0822fe06e8efb92d13f80dbc62e351
Parent:        8bceb1e0bb460a728638aea179b000f07b4cbd0b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 27 13:32:52 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 27 13:39:25 2015 +0100

report: fix handling of reports with pure label fields

Two problems fixed by this patch:
  - PV tags were not recognized at all when using them with pvs
    report that has only label fields (regression since 2.02.105)
  - incorrect persistent .cache file to be generated after pvs
    report that has only label fields (regression since 2.02.106)

These bugs come from the transition from process_each_pv to
process_each_label introduced by commit
67a7b7a87da65b2350f975272e581be5f41976e0 and commit
490226fc475232e0b158cf9fdc8670a663da4efe and related.
---
 WHATS_NEW        |    2 ++
 tools/reporter.c |   44 +++++++++++++++++++++++++++++++++++---------
 2 files changed, 37 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f4c4cde..cc974a6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.117 - 
 ====================================
+  Fix incorrect persistent .cache after report with label fields only (2.02.106).
+  Reinstate PV tag recognition for pvs if reporting label fields only (2.02.105).
   Rescan devices before vgimport with lvmetad so exported VG is seen.
   Fix hang by adjusting cluster mirror regionsize, avoiding CPG msg limit.
   Do not crash when --cachepolicy is given without --cachesettings.
diff --git a/tools/reporter.c b/tools/reporter.c
index 779e0bd..df5a58b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -566,6 +566,39 @@ int report_for_selection(struct cmd_context *cmd,
 	return r;
 }
 
+static void _check_pv_list(struct cmd_context *cmd, int argc, char **argv,
+			   report_type_t *report_type, unsigned *args_are_pvs)
+{
+	unsigned i;
+	int rescan_done = 0;
+
+	*args_are_pvs = (*report_type == PVS ||
+			 *report_type == LABEL ||
+			 *report_type == PVSEGS) ? 1 : 0;
+
+	if (args_are_pvs && argc) {
+		for (i = 0; i < argc; i++) {
+			if (!dev_cache_get(argv[i], cmd->full_filter) && !rescan_done) {
+				cmd->filter->wipe(cmd->filter);
+				/* FIXME scan only one device */
+				lvmcache_label_scan(cmd, 0);
+				rescan_done = 1;
+			}
+			if (*argv[i] == '@') {
+				if (*report_type == LABEL)
+					*report_type = PVS;
+				/*
+				 * If we changed the report_type and we did rescan,
+				 * no need to iterate over dev list further - nothing
+				 * else would change.
+				 */
+				if (rescan_done)
+					break;
+			}
+		}
+	}
+}
+
 static int _report(struct cmd_context *cmd, int argc, char **argv,
 		   report_type_t report_type)
 {
@@ -589,15 +622,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	quoted = find_config_tree_bool(cmd, report_quoted_CFG, NULL);
 	columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG, NULL);
 
-	args_are_pvs = (report_type == PVS ||
-			report_type == LABEL ||
-			report_type == PVSEGS) ? 1 : 0;
-
-	/*
-	 * FIXME Trigger scans based on unrecognised listed devices instead.
-	 */
-	if (args_are_pvs && argc)
-		cmd->filter->wipe(cmd->filter);
+	/* Check PV specifics and do extra changes/actions if needed. */
+	_check_pv_list(cmd, argc, argv, &report_type, &args_are_pvs);
 
 	switch (report_type) {
 	case DEVTYPES:



From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:40:16 +0000 (UTC)
Subject: dev-dct-process-latest - reporter: global lock needed before process_each_pv
Message-ID: <20140922154016.0630E60DDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1dd6983fb9c00514359b644fd3b297e3922a814
Commit:        f1dd6983fb9c00514359b644fd3b297e3922a814
Parent:        6be399b5ebb0f9a0e0d345747d1c164cc3911e2e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 4 16:30:02 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:24 2014 -0500

reporter: global lock needed before process_each_pv

The block of code that acquires the global lock for
process_each_pv() was in the wrong location given
the way report_type is munged, and does not equal
PVS until later in the function.
---
 tools/reporter.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 32a0b05..919a9ae 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -283,19 +283,6 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	if (args_are_pvs && argc)
 		cmd->filter->wipe(cmd->filter);
 
-	/*
-	 * This moved here as part of factoring it out of process_each_pv.
-	 * We lock VG_GLOBAL to enable use of metadata cache.
-	 * This can pause alongide pvscan or vgscan process for a while.
-	 */
-	if ((report_type == PVS || report_type == PVSEGS) && !lvmetad_active()) {
-		lock_global = 1;
-		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
-			log_error("Unable to obtain global lock.");
-			return ECMD_FAILED;
-		}
-	}
-
 	switch (report_type) {
 	case DEVTYPES:
 		keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
@@ -423,6 +410,19 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	else if (report_type & LVS)
 		report_type = LVS;
 
+	/*
+	 * This moved here as part of factoring it out of process_each_pv.
+	 * We lock VG_GLOBAL to enable use of metadata cache.
+	 * This can pause alongide pvscan or vgscan process for a while.
+	 */
+	if ((report_type == PVS || report_type == PVSEGS) && !lvmetad_active()) {
+		lock_global = 1;
+		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
+			log_error("Unable to obtain global lock.");
+			return ECMD_FAILED;
+		}
+	}
+
 	switch (report_type) {
 	case DEVTYPES:
 		r = _process_each_devtype(cmd, argc, report_handle);



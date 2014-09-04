From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  4 Sep 2014 21:33:00 +0000 (UTC)
Subject: dev-dct-process-v22 - reporter: global lock needed before process_each_pv
Message-ID: <20140904213300.ADBF6610A9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=463f6bed44e09a02e962113871480e1841bdb463
Commit:        463f6bed44e09a02e962113871480e1841bdb463
Parent:        c3d7a14ad4b1d0dfa5944224390d55b9effd00ed
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 4 16:30:02 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 4 16:30:02 2014 -0500

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



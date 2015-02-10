From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:13:11 +0000 (UTC)
Subject: master - tools: allow -S|--select for vgremove and lvremove
Message-ID: <20150210151311.EEF5960F9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00744b053f395be79ab1cb80fdf7342548aa79e2
Commit:        00744b053f395be79ab1cb80fdf7342548aa79e2
Parent:        f784c60cd65d14d107e957338af041c3a507ef8d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 12 09:34:50 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:08:42 2015 +0100

tools: allow -S|--select for vgremove and lvremove

---
 WHATS_NEW        |    1 +
 tools/commands.h |   10 ++++++----
 tools/lvremove.c |    5 +++--
 tools/reporter.c |    2 +-
 tools/vgremove.c |    5 +++--
 5 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f02ac8b..7fa7d3c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Add support for -S/--select to vgremove and lvremove.
   Add support for -S/--select to vgchange,lvchange and pvchange.
   Add infrastructure to support selection for non-reporting tools.
   Add LVM_COMMAND_PROFILE env var to set default command profile name to use.
diff --git a/tools/commands.h b/tools/commands.h
index 6df7f7d..63dbb2a 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -512,7 +512,7 @@ xx(lvreduce,
 
 xx(lvremove,
    "Remove logical volume(s) from the system",
-   0,
+   ALL_VGS_IS_DEFAULT, /* all VGs only with --select */
    "lvremove\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -520,12 +520,13 @@ xx(lvremove,
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[--noudevsync]\n"
+   "\t[-S|--select Selection]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
-   autobackup_ARG, force_ARG, noudevsync_ARG, test_ARG)
+   autobackup_ARG, force_ARG, noudevsync_ARG, select_ARG, test_ARG)
 
 xx(lvrename,
    "Rename a logical volume",
@@ -1186,19 +1187,20 @@ xx(vgreduce,
 
 xx(vgremove,
    "Remove volume group(s)",
-   0,
+   ALL_VGS_IS_DEFAULT, /* all VGs only with select */
    "vgremove\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[--noudevsync]\n"
+   "\t[-S|--select Selection]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
-   force_ARG, noudevsync_ARG, test_ARG)
+   force_ARG, noudevsync_ARG, select_ARG, test_ARG)
 
 xx(vgrename,
    "Rename a volume group",
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 1005218..df920fb 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -17,8 +17,9 @@
 
 int lvremove(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (!argc) {
-		log_error("Please enter one or more logical volume paths");
+	if (!argc && !arg_is_set(cmd, select_ARG)) {
+		log_error("Please enter one or more logical volume paths "
+			  "or use -S for selection.");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/reporter.c b/tools/reporter.c
index dba97be..0bfed51 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -455,7 +455,7 @@ int report_for_selection(struct selection_handle *sh,
 	static const char *incorrect_report_type_msg = "report_for_selection: incorrect report type";
 	int args_are_pvs = sh->orig_report_type == PVS;
 	int do_lv_info, do_lv_seg_status;
-	struct processing_handle handle = { .internal_report = 0,
+	struct processing_handle handle = { .internal_report_for_select = 0,
 					    .selection_handle = sh,
 					    .custom_handle = NULL };
 	int r = 0;
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 315e1dc..3ce0763 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -69,8 +69,9 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 {
 	int ret;
 
-	if (!argc) {
-		log_error("Please enter one or more volume group paths");
+	if (!argc && !arg_is_set(cmd, select_ARG)) {
+		log_error("Please enter one or more volume group paths "
+			  "or use -S for selection.");
 		return EINVALID_CMD_LINE;
 	}
 



From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 13 Nov 2017 16:24:59 -0500
Subject: master - persistent filter: Skip import before rescan
Message-ID: <201711132124.vADLOxcY031651@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=598fcccf458010dac5d9e319db943629e15d5b16
Commit:        598fcccf458010dac5d9e319db943629e15d5b16
Parent:        fe69a8d21573f37cb3fd503ee40ceb00b555a7e2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Nov 13 19:45:16 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Nov 13 19:45:16 2017 +0000

persistent filter: Skip import before rescan

The persistent filter should not be imported by any command that doesn't
use it so take addtional note of REQUIRES_FULL_LABEL_SCAN (for vgrename)
and introduce IGNORE_PERSISTENT_FILTER for vgscan and pvscan.
---
 WHATS_NEW          |    1 +
 tools/command.c    |    1 +
 tools/commands.h   |    4 ++--
 tools/lvmcmdline.c |   21 +++++++++++++++++++--
 tools/tools.h      |    2 ++
 5 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0775d7b..1c8838c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Avoid importing persistent filter in vgscan/pvscan/vgrename.
   Fix memleak of string buffer when vgcfgbackup runs in secure mode.
   Do not print error when clvmd cannot find running clvmd.
   Prevent start of new merge of snapshot if origin is already being merged.
diff --git a/tools/command.c b/tools/command.c
index 17b5eb4..1a712cc 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -140,6 +140,7 @@ static inline int configtype_arg(struct cmd_context *cmd __attribute__((unused))
 #define ENABLE_DUPLICATE_DEVS    0x00000400
 #define DISALLOW_TAG_ARGS        0x00000800
 #define GET_VGNAME_FROM_OPTIONS  0x00001000
+#define IGNORE_PERSISTENT_FILTER 0x00002000
 
 /* create foo_CMD enums for command def ID's in command-lines.in */
 
diff --git a/tools/commands.h b/tools/commands.h
index 4739479..d65330a 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -149,7 +149,7 @@ xx(pvs,
 
 xx(pvscan,
    "List all physical volumes",
-   PERMITTED_READ_ONLY | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN)
+   PERMITTED_READ_ONLY | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN | IGNORE_PERSISTENT_FILTER)
 
 xx(segtypes,
    "List available segment types",
@@ -233,7 +233,7 @@ xx(vgs,
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN | IGNORE_PERSISTENT_FILTER)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f2e208c..ed73b8d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2706,6 +2706,21 @@ static int _cmd_no_meta_proc(struct cmd_context *cmd)
 	return cmd->cname->flags & NO_METADATA_PROCESSING;
 }
 
+static int _cmd_no_lvmetad_autoscan(struct cmd_context *cmd)
+{
+	return cmd->cname->flags & NO_LVMETAD_AUTOSCAN;
+}
+
+static int _cmd_requires_full_label_scan(struct cmd_context *cmd)
+{
+	return cmd->cname->flags & REQUIRES_FULL_LABEL_SCAN;
+}
+
+static int _cmd_ignores_persistent_filter(struct cmd_context *cmd)
+{
+	return cmd->cname->flags & IGNORE_PERSISTENT_FILTER;
+}
+
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct dm_config_tree *config_string_cft, *config_profile_command_cft, *config_profile_metadata_cft;
@@ -2831,8 +2846,10 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	/* Note: Load persistent cache only if we haven't refreshed toolcontext!
 	 *       If toolcontext has been refreshed, it means config has changed
 	 *       and we can't rely on persistent cache anymore.
+	 * Similarly ignore the persistent cache if the command is going to discard it regardless.
 	 */
-	if (!cmd->initialized.filters && !_cmd_no_meta_proc(cmd) && !init_filters(cmd, !refresh_done))
+	if (!cmd->initialized.filters && !_cmd_no_meta_proc(cmd) &&
+	    !init_filters(cmd, !(refresh_done || _cmd_requires_full_label_scan(cmd) || _cmd_ignores_persistent_filter(cmd))))
 		return_ECMD_FAILED;
 
 	if (arg_is_set(cmd, readonly_ARG))
@@ -2945,7 +2962,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	 * In this case, disable the *use* of lvmetad by this command, reverting to
 	 * disk scanning.
 	 */
-	if (lvmetad_used() && !(cmd->cname->flags & NO_LVMETAD_AUTOSCAN)) {
+	if (lvmetad_used() && !_cmd_no_lvmetad_autoscan(cmd)) {
 		if (cmd->include_foreign_vgs || !lvmetad_token_matches(cmd)) {
 			if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, cmd->include_foreign_vgs ? 1 : 0)) {
 				log_warn("WARNING: Not using lvmetad because cache update failed.");
diff --git a/tools/tools.h b/tools/tools.h
index 53f8ddc..dc29e4b 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -137,6 +137,8 @@ struct arg_value_group_list {
 #define DISALLOW_TAG_ARGS        0x00000800
 /* Command may need to find VG name in an option value. */
 #define GET_VGNAME_FROM_OPTIONS  0x00001000
+/* Command must not load the contents saved by the persistent filter */
+#define IGNORE_PERSISTENT_FILTER 0x00002000
 
 void usage(const char *name);
 



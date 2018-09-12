From: David Teigland <teigland@sourceware.org>
Date: Wed, 12 Sep 2018 17:31:17 -0400
Subject: master - remove unneded check to skip filter init
Message-ID: <201809122131.w8CLVHO9016817@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1365f0d4c8f977cd3e426708891ee8d39ffe6527
Commit:        1365f0d4c8f977cd3e426708891ee8d39ffe6527
Parent:        0aeca60aaa65bde99115ec7ca92a93a885d3afb1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 12 16:13:46 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 12 16:30:50 2018 -0500

remove unneded check to skip filter init

There's no more persistent filter so we don't need
to check for it.
---
 tools/command.c    |    1 -
 tools/commands.h   |    4 ++--
 tools/lvmcmdline.c |   12 +-----------
 tools/tools.h      |    2 --
 4 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 42f9aa3..c994c39 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -131,7 +131,6 @@ static inline int configtype_arg(struct cmd_context *cmd __attribute__((unused))
 #define ALLOW_UUID_AS_NAME      0x00000010
 #define LOCKD_VG_SH             0x00000020
 #define NO_METADATA_PROCESSING  0x00000040
-#define IGNORE_PERSISTENT_FILTER 0x00000080
 #define MUST_USE_ALL_ARGS        0x00000100
 #define ENABLE_DUPLICATE_DEVS    0x00000400
 #define DISALLOW_TAG_ARGS        0x00000800
diff --git a/tools/commands.h b/tools/commands.h
index ef5763b..8c653e6 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -149,7 +149,7 @@ xx(pvs,
 
 xx(pvscan,
    "List all physical volumes",
-   PERMITTED_READ_ONLY | LOCKD_VG_SH | IGNORE_PERSISTENT_FILTER)
+   PERMITTED_READ_ONLY | LOCKD_VG_SH)
 
 xx(segtypes,
    "List available segment types",
@@ -232,7 +232,7 @@ xx(vgs,
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | IGNORE_PERSISTENT_FILTER)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index a1097fb..b1d0723 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2731,11 +2731,6 @@ static int _cmd_no_meta_proc(struct cmd_context *cmd)
 	return cmd->cname->flags & NO_METADATA_PROCESSING;
 }
 
-static int _cmd_ignores_persistent_filter(struct cmd_context *cmd)
-{
-	return cmd->cname->flags & IGNORE_PERSISTENT_FILTER;
-}
-
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct dm_config_tree *config_string_cft, *config_profile_command_cft, *config_profile_metadata_cft;
@@ -2860,13 +2855,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (!cmd->initialized.connections && !_cmd_no_meta_proc(cmd) && !init_connections(cmd))
 		return_ECMD_FAILED;
 
-	/* Note: Load persistent cache only if we haven't refreshed toolcontext!
-	 *       If toolcontext has been refreshed, it means config has changed
-	 *       and we can't rely on persistent cache anymore.
-	 * Similarly ignore the persistent cache if the command is going to discard it regardless.
-	 */
 	if (!cmd->initialized.filters && !_cmd_no_meta_proc(cmd) &&
-	    !init_filters(cmd, !(refresh_done || _cmd_ignores_persistent_filter(cmd))))
+	    !init_filters(cmd, !refresh_done))
 		return_ECMD_FAILED;
 
 	if (arg_is_set(cmd, readonly_ARG))
diff --git a/tools/tools.h b/tools/tools.h
index 405910f..55d486b 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -123,8 +123,6 @@ struct arg_value_group_list {
 #define LOCKD_VG_SH		0x00000020
 /* Command does not process any metadata. */
 #define NO_METADATA_PROCESSING	0x00000040
-/* Command must not load the contents saved by the persistent filter */
-#define IGNORE_PERSISTENT_FILTER 0x00000080
 /* Command must use all specified arg names and fail if all cannot be used. */
 #define MUST_USE_ALL_ARGS        0x00000100
 /* Command should process unused duplicate devices. */



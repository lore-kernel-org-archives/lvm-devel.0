From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:56:09 -0400
Subject: master - remove unnecessary REQUIRES_FULL_LABEL_SCAN
Message-ID: <201804231356.w3NDu9rZ001947@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89c65d4f71e51c2db4fcba176546d2474e3451bd
Commit:        89c65d4f71e51c2db4fcba176546d2474e3451bd
Parent:        45e5e702c1d488df4898a41db0c00ead63c5f6ee
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 6 13:18:03 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

remove unnecessary REQUIRES_FULL_LABEL_SCAN

we always scan all devices
---
 tools/command.c    |    3 +--
 tools/commands.h   |    2 +-
 tools/lvmcmdline.c |    7 +------
 tools/tools.h      |    7 ++-----
 tools/vgrename.c   |    5 -----
 5 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 8944399..f3b5d82 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -134,13 +134,12 @@ static inline int configtype_arg(struct cmd_context *cmd __attribute__((unused))
 #define ALLOW_UUID_AS_NAME      0x00000010
 #define LOCKD_VG_SH             0x00000020
 #define NO_METADATA_PROCESSING  0x00000040
-#define REQUIRES_FULL_LABEL_SCAN 0x00000080
+#define IGNORE_PERSISTENT_FILTER 0x00000080
 #define MUST_USE_ALL_ARGS        0x00000100
 #define NO_LVMETAD_AUTOSCAN      0x00000200
 #define ENABLE_DUPLICATE_DEVS    0x00000400
 #define DISALLOW_TAG_ARGS        0x00000800
 #define GET_VGNAME_FROM_OPTIONS  0x00001000
-#define IGNORE_PERSISTENT_FILTER 0x00002000
 
 /* create foo_CMD enums for command def ID's in command-lines.in */
 
diff --git a/tools/commands.h b/tools/commands.h
index cbd527b..3d142c3 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -225,7 +225,7 @@ xx(vgremove,
 
 xx(vgrename,
    "Rename a volume group",
-   ALLOW_UUID_AS_NAME | REQUIRES_FULL_LABEL_SCAN)
+   ALLOW_UUID_AS_NAME)
 
 xx(vgs,
    "Display information about volume groups",
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3774014..bcb2c53 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2727,11 +2727,6 @@ static int _cmd_no_lvmetad_autoscan(struct cmd_context *cmd)
 	return cmd->cname->flags & NO_LVMETAD_AUTOSCAN;
 }
 
-static int _cmd_requires_full_label_scan(struct cmd_context *cmd)
-{
-	return cmd->cname->flags & REQUIRES_FULL_LABEL_SCAN;
-}
-
 static int _cmd_ignores_persistent_filter(struct cmd_context *cmd)
 {
 	return cmd->cname->flags & IGNORE_PERSISTENT_FILTER;
@@ -2865,7 +2860,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	 * Similarly ignore the persistent cache if the command is going to discard it regardless.
 	 */
 	if (!cmd->initialized.filters && !_cmd_no_meta_proc(cmd) &&
-	    !init_filters(cmd, !(refresh_done || _cmd_requires_full_label_scan(cmd) || _cmd_ignores_persistent_filter(cmd))))
+	    !init_filters(cmd, !(refresh_done || _cmd_ignores_persistent_filter(cmd))))
 		return_ECMD_FAILED;
 
 	if (arg_is_set(cmd, readonly_ARG))
diff --git a/tools/tools.h b/tools/tools.h
index 0886551..d4d2fb2 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -124,8 +124,8 @@ struct arg_value_group_list {
 #define LOCKD_VG_SH		0x00000020
 /* Command does not process any metadata. */
 #define NO_METADATA_PROCESSING	0x00000040
-/* Command wants to scan for new devices and force labels to be read from them all. */
-#define REQUIRES_FULL_LABEL_SCAN 0x00000080
+/* Command must not load the contents saved by the persistent filter */
+#define IGNORE_PERSISTENT_FILTER 0x00000080
 /* Command must use all specified arg names and fail if all cannot be used. */
 #define MUST_USE_ALL_ARGS        0x00000100
 /* Command wants to control the device scan for lvmetad itself. */
@@ -136,9 +136,6 @@ struct arg_value_group_list {
 #define DISALLOW_TAG_ARGS        0x00000800
 /* Command may need to find VG name in an option value. */
 #define GET_VGNAME_FROM_OPTIONS  0x00001000
-/* Command must not load the contents saved by the persistent filter */
-#define IGNORE_PERSISTENT_FILTER 0x00002000
-
 void usage(const char *name);
 
 /* the argument verify/normalise functions */
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 5c69faf..4f2a08b 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -59,11 +59,6 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 	/*
 	 * Check if a VG already exists with the new VG name.
 	 *
-	 * When not using lvmetad, it's essential that a full scan has
-	 * been done to ensure we see all existing VG names, so we
-	 * do not use an existing name.  This has been done by
-	 * process_each_vg REQUIRES_FULL_LABEL_SCAN.
-	 *
 	 * (FIXME: We could look for the new name in the list of all
 	 * VGs that process_each_vg created, but we don't have access
 	 * to that list here, so we have to look in lvmcache.



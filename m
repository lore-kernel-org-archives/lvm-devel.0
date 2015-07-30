From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Jul 2015 11:58:01 +0000 (UTC)
Subject: master - commands: add new NO_METADATA_PROCESSING flag to selected commands
Message-ID: <20150730115801.C916260FB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0629c13fe2dfa8d6aaace242209f4bf7675345f
Commit:        c0629c13fe2dfa8d6aaace242209f4bf7675345f
Parent:        f6473baffc2d0b486b2aa941cf2681683026b3a5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 30 10:48:28 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 30 13:56:13 2015 +0200

commands: add new NO_METADATA_PROCESSING flag to selected commands

When a command is flagged with NO_METADATA_PROCESSING flag, it means
such command does not process any metadata and hence it doens't require
lvmetad, lvmpolld and it can get away with no locking too. These are
mostly simple commands (like lvmconfig/dumpconfig, version, types,
segtypes and other builtin commands that do not process metadata
in any way).

At first, when lvm command is executed, create toolcontext without
initializing connections (lvmetad,lvmpolld) and without initializing
filters (which depend on connections init). Instead, delay this
initialization until we know we need this. That is, until the
lvm_run_command fn is called in which we know what the actual
command to run is and hence we can avoid any connection, filter
or locking initiliazation for commands that would not make use
of it anyway.

For all the other create_toolcontext calls, we keep the original
behaviour - the filters and connections are initialized together
with the toolcontext.
---
 WHATS_NEW             |    1 +
 lib/locking/locking.c |    5 +++--
 tools/commands.h      |   20 ++++++++++----------
 tools/lvmcmdline.c    |   21 +++++++++++++++++----
 tools/tools.h         |    2 ++
 5 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1d8f472..1e04acb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.127 - 
 =================================
+  Do not init filters, locking, lvmetad, lvmpolld if command doesn't use it.
   Recognise vg/lv name format in dmsetup.
   Fix regression in cache causing some PVs to bypass filters (2.02.105).
 
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index c88a85b..22e83d2 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -119,8 +119,9 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 	switch (type) {
 	case 0:
 		init_no_locking(&_locking, cmd, suppress_messages);
-		log_warn("WARNING: Locking disabled. Be careful! "
-			  "This could corrupt your metadata.");
+		log_warn_suppress(suppress_messages,
+			"WARNING: Locking disabled. Be careful! "
+			"This could corrupt your metadata.");
 		return 1;
 
 	case 1:
diff --git a/tools/commands.h b/tools/commands.h
index 7f4b4e2..0ab578d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -30,7 +30,7 @@ xx(e2fsadm,
 
 xx(config,
    "Display and manipulate configuration information",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "config\n"
    "\t[-f|--file filename]\n"
    "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
@@ -60,7 +60,7 @@ xx(config,
 
 xx(devtypes,
    "Display recognised built-in block device types",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "devtypes\n"
    "\t[--aligned]\n"
    "\t[--binary]\n"
@@ -86,7 +86,7 @@ xx(devtypes,
 
 xx(dumpconfig,
    "Display and manipulate configuration information",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "dumpconfig\n"
    "\t[-f|--file filename]\n"
    "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
@@ -116,12 +116,12 @@ xx(dumpconfig,
 
 xx(formats,
    "List available metadata formats",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "formats\n")
 
 xx(help,
    "Display help for commands",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "help <command>\n")
 
 /*********
@@ -491,7 +491,7 @@ xx(lvmchange,
 
 xx(lvmconfig,
    "Display and manipulate configuration information",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "lvmconfig\n"
    "\t[-f|--file filename]\n"
    "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
@@ -979,17 +979,17 @@ xx(pvscan,
 
 xx(segtypes,
    "List available segment types",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "segtypes\n")
 
 xx(systemid,
    "Display the system ID, if any, currently set on this host",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "systemid\n")
 
 xx(tags,
    "List tags defined on this host",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "tags\n")
 
 xx(vgcfgbackup,
@@ -1409,5 +1409,5 @@ xx(vgsplit,
 
 xx(version,
    "Display software and driver version information",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "version\n")
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0c88164..b7809c7 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1463,6 +1463,11 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 	return 1;
 }
 
+static int _cmd_no_meta_proc(struct cmd_context *cmd)
+{
+	return cmd->command->flags & NO_METADATA_PROCESSING;
+}
+
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct dm_config_tree *config_string_cft;
@@ -1554,6 +1559,12 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (!_prepare_profiles(cmd))
 		return_ECMD_FAILED;
 
+	if (!cmd->initialized.connections && !_cmd_no_meta_proc(cmd) && !init_connections(cmd))
+		return_ECMD_FAILED;
+
+	if (!cmd->initialized.filters && !_cmd_no_meta_proc(cmd) && !init_filters(cmd, 1))
+		return_ECMD_FAILED;
+
 	if (arg_count(cmd, readonly_ARG))
 		cmd->metadata_read_only = 1;
 
@@ -1587,7 +1598,9 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (arg_count(cmd, readonly_ARG)) {
+	if (_cmd_no_meta_proc(cmd))
+		locking_type = 0;
+	else if (arg_count(cmd, readonly_ARG)) {
 		if (find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL)) {
 			/*
 			 * FIXME: we could use locking_type 5 here if that didn't
@@ -1610,12 +1623,12 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	else
 		locking_type = -1;
 
-	if (!init_locking(locking_type, cmd, arg_count(cmd, sysinit_ARG))) {
+	if (!init_locking(locking_type, cmd, _cmd_no_meta_proc(cmd) || arg_count(cmd, sysinit_ARG))) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}
 
-	if (!_init_lvmlockd(cmd)) {
+	if (!_cmd_no_meta_proc(cmd) && !_init_lvmlockd(cmd)) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}
@@ -2056,7 +2069,7 @@ int lvm2_main(int argc, char **argv)
 	if (!alias && argc > 1 && !strcmp(argv[1], "version"))
 		return lvm_return_code(version(NULL, argc, argv));
 
-	if (!(cmd = init_lvm(1, 1)))
+	if (!(cmd = init_lvm(0, 0)))
 		return -1;
 
 	cmd->argv = argv;
diff --git a/tools/tools.h b/tools/tools.h
index 5ee5786..4ed893f 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -103,6 +103,8 @@ struct arg_value_group_list {
 #define ONE_VGNAME_ARG		0x00000010
 /* Command needs a shared lock on a VG; it only reads the VG. */
 #define LOCKD_VG_SH		0x00000020
+/* Command does not process any metadata. */
+#define NO_METADATA_PROCESSING	0x00000040
  
 /* a register of the lvm commands */
 struct command {



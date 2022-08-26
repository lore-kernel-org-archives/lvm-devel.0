From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Fri, 26 Aug 2022 10:36:31 +0000 (GMT)
Subject: main - args: add ARG_NONINTERACTIVE for cmds not supported in lvm shell
Message-ID: <20220826103631.E166A38CB7D8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6b6a09f90f53a5cea3a712b2b84af57f4514a02
Commit:        e6b6a09f90f53a5cea3a712b2b84af57f4514a02
Parent:        800436d2affd4142b9d4b405112c4c30f1d31b5b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 26 12:17:45 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 26 12:17:50 2022 +0200

args: add ARG_NONINTERACTIVE for cmds not supported in lvm shell

Certain args can't be used in lvm shell ("interactive mode") because
they are not supported there. Add ARG_NONINTERACTIVE flag to mark
such args and error out if we're in interactive mode and at the same
time we detect use of such argument.

Currently, this is the case for --reportformat arg - we don't support
changing the format per command in lvm shell. The whole shell is running
under a reportformat chosen at shell's start.
---
 WHATS_NEW          | 1 +
 tools/args.h       | 2 +-
 tools/command.c    | 1 +
 tools/lvmcmdline.c | 9 +++++++++
 tools/tools.h      | 1 +
 5 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 90dd417b1..9e7cd1f0c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.17 - 
 ===============================
+  Error out in lvm shell if using a cmd argument not supported in the shell.
   Fix lvm shell's lastlog command to report previous pre-command failures.
   Extend VDO and VDOPOOL without flushing and locking fs.
   Add --valuesonly option to lvmconfig to print only values without keys.
diff --git a/tools/args.h b/tools/args.h
index bdeefca7d..85dd11aeb 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -671,7 +671,7 @@ arg(replace_ARG, '\0', "replace", pv_VAL, ARG_GROUPABLE, 0,
     "Multiple PVs can be replaced by repeating this option.\n"
     "See \\fBlvmraid\\fP(7) for more information.\n")
 
-arg(reportformat_ARG, '\0', "reportformat", reportformat_VAL, 0, 0,
+arg(reportformat_ARG, '\0', "reportformat", reportformat_VAL, ARG_NONINTERACTIVE, 0,
     "Overrides current output format for reports which is defined globally by\n"
     "the report/output_format setting in \\fBlvm.conf\\fP(5).\n"
     "\\fBbasic\\fP is the original format with columns and rows.\n"
diff --git a/tools/command.c b/tools/command.c
index 8de8825e4..5da511530 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -78,6 +78,7 @@ static void *dm_pool_alloc(void *p, size_t size)
 /* needed to include args.h */
 #define ARG_COUNTABLE 0x00000001
 #define ARG_GROUPABLE 0x00000002
+#define ARG_NONINTERACTIVE 0x00000004
 struct cmd_context;
 struct arg_values;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4fb21074f..ba3ca220b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2261,6 +2261,15 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 
 		av = &cmd->opt_arg_values[arg_enum];
 
+		if (a->flags & ARG_NONINTERACTIVE && cmd->is_interactive) {
+			log_error("Argument%s%c%s%s cannot be used in interactive mode.",
+				  a->short_opt ? " -" : "",
+				  a->short_opt ? : ' ',
+				  (a->short_opt && a->long_opt) ?
+				  "/" : "", a->long_opt ? : "");
+			return 0;
+		}
+
 		if (a->flags & ARG_GROUPABLE) {
 			/*
 			 * Start a new group of arguments:
diff --git a/tools/tools.h b/tools/tools.h
index cd89e1692..2636c22da 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -96,6 +96,7 @@ enum {
 
 #define ARG_COUNTABLE 0x00000001	/* E.g. -vvvv */
 #define ARG_GROUPABLE 0x00000002	/* E.g. --addtag */
+#define ARG_NONINTERACTIVE 0x00000004	/* only for use in noninteractive mode  */
 
 struct arg_values {
 	unsigned count;


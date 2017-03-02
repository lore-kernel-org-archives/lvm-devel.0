From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 17:58:59 -0500
Subject: master - man lvcreate: show extents option
Message-ID: <201703022258.v22MwxOd027351@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1a0d57f89503e9f25860ca85acb7d2a3e80cad9c
Commit:        1a0d57f89503e9f25860ca85acb7d2a3e80cad9c
Parent:        9a62767f2d44c9d9a9004ffe08a6f21a153c2a8f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 16:56:32 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 16:58:19 2017 -0600

man lvcreate: show extents option

Display --extents as an option in each cmd def,
in addition to the special notes about how
--size and --extents are alternatives.
---
 man/lvcreate.8.des |    6 +++---
 tools/command.c    |   12 ++++++++++++
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/man/lvcreate.8.des b/man/lvcreate.8.des
index 488dab4..b77006b 100644
--- a/man/lvcreate.8.des
+++ b/man/lvcreate.8.des
@@ -28,9 +28,9 @@ to improve performance.
 
 .SS Usage notes
 
-In the usage section below, \fB--size\fP \fINumber\fP can be replaced
-in each case with \fB--extents\fP \fINumberExtents\fP.  Also see both
-descriptions the options section.
+In the usage section below, \fB--size\fP \fISize\fP can be replaced
+in each case with \fB--extents\fP \fINumber\fP.  See both descriptions
+the options section.
 
 In the usage section below, \fB--name\fP is omitted from the required
 options, even though it is typically used.  When the name is not
diff --git a/tools/command.c b/tools/command.c
index d2d7a26..25be87f 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2110,6 +2110,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
 	int sep, ro, rp, oo, op, opt_enum;
 	int need_ro_indent_end = 0;
+	int include_extents = 0;
 
 	if (!(cname = find_command_name(cmd->name)))
 		return;
@@ -2239,6 +2240,10 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			opt_enum = cmd->required_opt_args[ro].opt;
 
+			/* special case */
+			if (!strcmp(cmd->name, "lvcreate") && (opt_enum == size_ARG))
+				include_extents = 1;
+
 			if (opt_names[opt_enum].short_opt) {
 				printf(" \\fB-%c\\fP|\\fB%s\\fP",
 				       opt_names[opt_enum].short_opt,
@@ -2284,6 +2289,13 @@ void print_man_usage(char *lvmname, struct command *cmd)
 	if (cmd->oo_count) {
 		printf(".RS 4\n");
 
+		if (include_extents) {
+			printf(".ad l\n");
+			printf("[ \\fB-l\\fP|\\fB--extents\\fP \\fINumber\\fP[PERCENT] ]\n");
+			printf(".ad b\n");
+			sep = 1;
+		}
+
 		/* print optional options with short opts */
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {



From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 15:00:34 -0500
Subject: master - commands: handle including an optional opt multiple times
Message-ID: <201703022000.v22K0Ytl012653@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6360ba3d2d7b1ab9e32ad5c660473d2a290ef3fd
Commit:        6360ba3d2d7b1ab9e32ad5c660473d2a290ef3fd
Parent:        b7831fc14ae9a7b35c1d814486f45f4b3cbadc8b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 13:52:06 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 13:52:06 2017 -0600

commands: handle including an optional opt multiple times

When a cmd def includes multiple sets of options (OO_FOO),
allow multiple OO_FOO sets to contain the same option and
avoid repeating it in the cmd def.
---
 tools/command.c |   30 +++++++++++++++++++++++++-----
 1 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index a532a10..0187972 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -845,10 +845,12 @@ static void include_optional_opt_args(struct command *cmd, const char *str)
  * This function sets the opt_args.opt value for it.
  */
 
-static void add_opt_arg(struct command *cmd, char *str, int *takes_arg, int required)
+static void add_opt_arg(struct command *cmd, char *str,
+			int *takes_arg, int *already, int required)
 {
 	char *comma;
 	int opt;
+	int i;
 
 	/* opt_arg.opt set here */
 	/* opt_arg.def will be set in update_prev_opt_arg() if needed */
@@ -872,6 +874,17 @@ static void add_opt_arg(struct command *cmd, char *str, int *takes_arg, int requ
 	if (opt == uuidstr_ARG)
 		opt = uuid_ARG;
 
+	/* Skip adding an optional opt if it is already included. */
+	if (already && !required) {
+		for (i = 0; i < cmd->oo_count; i++) {
+			if (cmd->optional_opt_args[i].opt == opt) {
+				*already = 1;
+				*takes_arg = opt_names[opt].val_enum ? 1 : 0;
+				return;
+			}
+		}
+	}
+
 skip:
 	if (required > 0)
 		cmd->required_opt_args[cmd->ro_count++].opt = opt;
@@ -966,13 +979,17 @@ static void update_prev_pos_arg(struct command *cmd, char *str, int required)
 static void add_optional_opt_line(struct command *cmd, int argc, char *argv[])
 {
 	int takes_arg = 0;
+	int already;
 	int i;
 
 	for (i = 0; i < argc; i++) {
 		if (!i && !strncmp(argv[i], "OO:", 3))
 			continue;
+
+		already = 0;
+
 		if (is_opt_name(argv[i]))
-			add_opt_arg(cmd, argv[i], &takes_arg, OPTIONAL);
+			add_opt_arg(cmd, argv[i], &takes_arg, &already, OPTIONAL);
 		else if (!strncmp(argv[i], "OO_", 3))
 			include_optional_opt_args(cmd, argv[i]);
 		else if (takes_arg)
@@ -983,6 +1000,9 @@ static void add_optional_opt_line(struct command *cmd, int argc, char *argv[])
 			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 			return;
 		}
+
+		if (already && takes_arg)
+			i++;
 	}
 }
 
@@ -997,7 +1017,7 @@ static void add_ignore_opt_line(struct command *cmd, int argc, char *argv[])
 		if (!i && !strncmp(argv[i], "IO:", 3))
 			continue;
 		if (is_opt_name(argv[i]))
-			add_opt_arg(cmd, argv[i], &takes_arg, IGNORE);
+			add_opt_arg(cmd, argv[i], &takes_arg, NULL, IGNORE);
 		else if (takes_arg)
 			update_prev_opt_arg(cmd, argv[i], IGNORE);
 		else {
@@ -1032,7 +1052,7 @@ static void add_required_opt_line(struct command *cmd, int argc, char *argv[])
 
 	for (i = 0; i < argc; i++) {
 		if (is_opt_name(argv[i]))
-			add_opt_arg(cmd, argv[i], &takes_arg, REQUIRED);
+			add_opt_arg(cmd, argv[i], &takes_arg, NULL, REQUIRED);
 		else if (takes_arg)
 			update_prev_opt_arg(cmd, argv[i], REQUIRED);
 		else {
@@ -1090,7 +1110,7 @@ static void add_required_line(struct command *cmd, int argc, char *argv[])
 
 		if (is_opt_name(argv[i])) {
 			/* add new required_opt_arg */
-			add_opt_arg(cmd, argv[i], &takes_arg, REQUIRED);
+			add_opt_arg(cmd, argv[i], &takes_arg, NULL, REQUIRED);
 			prev_was_opt = 1;
 			prev_was_pos = 0;
 



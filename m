From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 14 Feb 2017 16:17:02 +0000 (UTC)
Subject: master - commands: skip parsing command defs for other command names
Message-ID: <20170214161702.584F960B42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0f2a59993e373781c6dd5568cd559547cfe49a1
Commit:        c0f2a59993e373781c6dd5568cd559547cfe49a1
Parent:        f46b28bdb6f8c0f7bae7a8b4fb4b886332831318
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 14 10:16:13 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 14 10:16:13 2017 -0600

commands: skip parsing command defs for other command names

The base command name can be used to skip parsing
command defs that will not be needed.
---
 tools/command.c     |   30 ++++++++++++++++++++++--------
 tools/command.h     |    2 +-
 tools/lvm2cmdline.h |    2 +-
 tools/lvmcmdlib.c   |    2 +-
 tools/lvmcmdline.c  |   14 +++++++++++---
 5 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index a968bed..b655abe 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1292,7 +1292,7 @@ static int copy_line(char *line, int max_line, int *position)
 	return 1;
 }
 
-int define_commands(void)
+int define_commands(char *run_name)
 {
 	struct command *cmd;
 	char line[MAX_LINE];
@@ -1306,6 +1306,10 @@ int define_commands(void)
 	int prev_was_oo = 0;
 	int prev_was_op = 0;
 	int copy_pos = 0;
+	int skip = 0;
+
+	if (run_name && !strcmp(run_name, "help"))
+		run_name = NULL;
 
 	create_opt_names_alpha();
 
@@ -1340,6 +1344,16 @@ int define_commands(void)
 			cmd->command_index = cmd_count;
 			cmd_count++;
 			cmd->name = strdup(name);
+
+			if (run_name && strcmp(run_name, name)) {
+				skip = 1;
+				prev_was_oo_def = 0;
+				prev_was_oo = 0;
+				prev_was_op = 0;
+				continue;
+			}
+			skip = 0;
+
 			cmd->pos_count = 1;
 			add_required_line(cmd, line_argc, line_argv);
 
@@ -1353,7 +1367,7 @@ int define_commands(void)
 		 * context of the existing command[].
 		 */
 
-		if (is_desc_line(line_argv[0])) {
+		if (is_desc_line(line_argv[0]) && !skip) {
 			char *desc = strdup(line_orig);
 			if (cmd->desc) {
 				int newlen = strlen(cmd->desc) + strlen(desc) + 2;
@@ -1369,12 +1383,12 @@ int define_commands(void)
 			continue;
 		}
 
-		if (is_flags_line(line_argv[0])) {
+		if (is_flags_line(line_argv[0]) && !skip) {
 			add_flags(cmd, line_orig);
 			continue;
 		}
 
-		if (is_rule_line(line_argv[0])) {
+		if (is_rule_line(line_argv[0]) && !skip) {
 			add_rule(cmd, line_orig);
 			continue;
 		}
@@ -1394,7 +1408,7 @@ int define_commands(void)
 		}
 
 		/* OO: ... */
-		if (is_oo_line(line_argv[0])) {
+		if (is_oo_line(line_argv[0]) && !skip) {
 			add_optional_opt_line(cmd, line_argc, line_argv);
 			prev_was_oo_def = 0;
 			prev_was_oo = 1;
@@ -1403,7 +1417,7 @@ int define_commands(void)
 		}
 
 		/* OP: ... */
-		if (is_op_line(line_argv[0])) {
+		if (is_op_line(line_argv[0]) && !skip) {
 			add_optional_pos_line(cmd, line_argc, line_argv);
 			prev_was_oo_def = 0;
 			prev_was_oo = 0;
@@ -1412,7 +1426,7 @@ int define_commands(void)
 		}
 
 		/* IO: ... */
-		if (is_io_line(line_argv[0])) {
+		if (is_io_line(line_argv[0]) && !skip) {
 			add_ignore_opt_line(cmd, line_argc, line_argv);
 			prev_was_oo = 0;
 			prev_was_op = 0;
@@ -2703,7 +2717,7 @@ int main(int argc, char *argv[])
 		exit(EXIT_FAILURE);
 	}
 
-	define_commands();
+	define_commands(NULL);
 
 	print_man(argv[1], (argc > 2) ? argv[2] : NULL, 1, 1);
 
diff --git a/tools/command.h b/tools/command.h
index b3fae03..3d708f0 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -209,7 +209,7 @@ struct command {
 	int pos_count; /* temp counter used by create-command */
 };
 
-int define_commands(void);
+int define_commands(char *run_name);
 int command_id_to_enum(const char *str);
 void print_usage(struct command *cmd);
 void print_usage_common(struct command_name *cname, struct command *cmd);
diff --git a/tools/lvm2cmdline.h b/tools/lvm2cmdline.h
index 9b75c36..00162a4 100644
--- a/tools/lvm2cmdline.h
+++ b/tools/lvm2cmdline.h
@@ -32,7 +32,7 @@ void *cmdlib_lvm2_init(unsigned static_compile);
 void lvm_fin(struct cmd_context *cmd);
 
 struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters);
-void lvm_register_commands(void);
+void lvm_register_commands(char *name);
 int lvm_split(char *str, int *argc, char **argv, int max);
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv);
 int lvm_return_code(int ret);
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index a1e938b..9e50343 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -34,7 +34,7 @@ void *cmdlib_lvm2_init(unsigned static_compile)
 	if (!(cmd = init_lvm(1, 1)))
 		return NULL;
 
-	lvm_register_commands();
+	lvm_register_commands(NULL);
 
 	return (void *) cmd;
 }
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 494f01f..65f80c8 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1128,7 +1128,7 @@ static struct command_function *_find_command_id_function(int command_enum)
 	return NULL;
 }
 
-void lvm_register_commands(void)
+void lvm_register_commands(char *name)
 {
 	int i;
 
@@ -1138,7 +1138,7 @@ void lvm_register_commands(void)
 	 * populate commands[] array with command definitions
 	 * by parsing command-lines.in/command-lines-input.h
 	 */
-	if (!define_commands()) {
+	if (!define_commands(name)) {
 		log_error("Failed to parse command definitions.");
 		return;
 	}
@@ -3158,6 +3158,7 @@ int lvm2_main(int argc, char **argv)
 	int ret, alias = 0;
 	struct custom_fds custom_fds;
 	struct cmd_context *cmd;
+	char *name;
 
 	if (!argv)
 		return -1;
@@ -3199,7 +3200,14 @@ int lvm2_main(int argc, char **argv)
 
 	cmd->argv = argv;
 
-	lvm_register_commands();
+	if (!alias && argc == 1)
+		name = NULL;
+	else if (alias)
+		name = argv[0];
+	else
+		name = argv[1];
+
+	lvm_register_commands(name);
 
 	if (_lvm1_fallback(cmd)) {
 		/* Attempt to run equivalent LVM1 tool instead */



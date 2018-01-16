From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 15 Jan 2018 22:17:03 -0500
Subject: master - command: Skip some memory zeroing.
Message-ID: <201801160317.w0G3H3Mq025327@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=da37cbd24fc0073f3f00a3b7aac7807d2185b829
Commit:        da37cbd24fc0073f3f00a3b7aac7807d2185b829
Parent:        e4e2abc8bc2f257c2d0f9458bab7c87d34626be3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jan 13 03:36:53 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jan 13 03:44:15 2018 +0000

command: Skip some memory zeroing.

commands[] is in bss, its content wouldn't change if reinitialised
and unregister has no memory to free so don't bother.
---
 tools/command.c    |   11 ++++++-----
 tools/lvmcmdline.c |   12 ------------
 2 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 1a712cc..5a5f351 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1356,13 +1356,11 @@ static void _create_opt_names_alpha(void)
 	qsort(opt_names_alpha, ARG_COUNT, sizeof(long), _long_name_compare);
 }
 
-static int _copy_line(char *line, int max_line, int *position)
+static int _copy_line(char *line, int max_line, int *position, int *len)
 {
 	int p = *position;
 	int i = 0;
 
-	memset(line, 0, max_line);
-
 	while (1) {
 		line[i] = _command_input[p];
 		i++;
@@ -1376,7 +1374,9 @@ static int _copy_line(char *line, int max_line, int *position)
 		if (i == (max_line - 1))
 			break;
 	}
+	line[i] = '\0';
 	*position = p;
+	*len = i + 1;
 	return 1;
 }
 
@@ -1394,6 +1394,7 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 	int prev_was_oo = 0;
 	int prev_was_op = 0;
 	int copy_pos = 0;
+	int copy_len = 0;
 	int skip = 0;
 	int i;
 
@@ -1404,14 +1405,14 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 
 	/* Process each line of command-lines-input.h (from command-lines.in) */
 
-	while (_copy_line(line, MAX_LINE, &copy_pos)) {
+	while (_copy_line(line, MAX_LINE, &copy_pos, &copy_len)) {
 		if (line[0] == '\n')
 			break;
 
 		if ((n = strchr(line, '\n')))
 			*n = '\0';
 
-		memcpy(line_orig, line, sizeof(line));
+		memcpy(line_orig, line, copy_len);
 		_split_line(line, &line_argc, line_argv, ' ');
 
 		if (!line_argc)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6be4bcd..246d332 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1262,15 +1262,6 @@ static const struct command_function *_find_command_id_function(int command_enum
 	return NULL;
 }
 
-static void _unregister_commands(void)
-{
-	_cmdline.commands = NULL;
-	_cmdline.num_commands = 0;
-	_cmdline.command_names = NULL;
-	_cmdline.num_command_names = 0;
-	memset(&commands, 0, sizeof(commands));
-}
-
 int lvm_register_commands(struct cmd_context *cmd, const char *run_name)
 {
 	int i;
@@ -1279,8 +1270,6 @@ int lvm_register_commands(struct cmd_context *cmd, const char *run_name)
 	if (_cmdline.commands)
 		return 1;
 
-	memset(&commands, 0, sizeof(commands));
-
 	/*
 	 * populate commands[] array with command definitions
 	 * by parsing command-lines.in/command-lines-input.h
@@ -3335,7 +3324,6 @@ struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters)
 
 void lvm_fin(struct cmd_context *cmd)
 {
-	_unregister_commands();
 	destroy_toolcontext(cmd);
 	udev_fin_library_context();
 }



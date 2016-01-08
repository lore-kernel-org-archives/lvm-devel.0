From: Tony Asleson <tasleson@redhat.com>
Date: Fri,  8 Jan 2016 15:37:16 -0600
Subject: [PATCH 1/2] lvm.c: Don't use GNU readline when no tty
In-Reply-To: <1452289037-30597-1-git-send-email-tasleson@redhat.com>
References: <1452289037-30597-1-git-send-email-tasleson@redhat.com>
Message-ID: <1452289037-30597-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If you use lvm shell and write requests to STDIN and read from STDOUT over a
pipe you will find that the GNU readline library echos STDIN to STDOUT.
This wouldn't be so much of an issue if that's all it did, but it also
injects ' \r' (seemingly random) into STDOUT when echoing longer requests.

strace snippet from lvm shell:
...
read(0, "/", 1)                         = 1
write(1, "/", 1)                        = 1
read(0, "s", 1)                         = 1
write(1, "s \r", 3)                     = 3
read(0, "d", 1)                         = 1
write(1, "d", 1)                        = 1
...

This patch removes the calls to GNU readline when STDIN is not a tty as
readline functionality is not needed or wanted in this use case.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 tools/lvm.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 47 insertions(+), 9 deletions(-)

diff --git a/tools/lvm.c b/tools/lvm.c
index 63cc0b4..2f3b911 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -181,22 +181,56 @@ static void _write_history(void)
 		log_very_verbose("Couldn't write history to %s.", hist_file);
 }
 
+static char *_fetchline(const char *prompt)
+{
+	char *line = NULL;
+	size_t allocated_size = 0;
+
+	fprintf(stdout, "%s", prompt);
+	fflush(stdout);
+
+	if (getline(&line, &allocated_size, stdin) == -1) {
+		free(line);
+		line = NULL;
+	}
+
+	if (line) {
+		size_t l = strlen(line);
+
+		/* Mimic same behavior as readline, remove trailing \n if present */
+		if (l) {
+			l--;
+			if (line[l] == '\n')
+				line[l] = '\0';
+		}
+	}
+	return line;
+}
+
+typedef char *(*fetch_line_fp)(const char *);
+
 int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 {
-	int argc, ret;
+	int argc, ret = 0;
 	char *input = NULL, *args[MAX_ARGS], **argv;
+	int tty = 0;
+	fetch_line_fp get_next_line = _fetchline;
 
-	rl_readline_name = "lvm";
-	rl_attempted_completion_function = (rl_completion_func_t *) _completion;
+	tty = isatty(STDIN_FILENO);
 
-	_read_history(cmd);
+	if (tty) {
+		rl_readline_name = "lvm";
+		rl_attempted_completion_function = (rl_completion_func_t *) _completion;
+		_read_history(cmd);
+		get_next_line = readline;
+	}
 
 	_cmdline = cmdline;
 
 	_cmdline->interactive = 1;
 	while (1) {
 		free(input);
-		input = readline("lvm> ");
+		input = get_next_line("lvm> ");
 
 		/* EOF */
 		if (!input) {
@@ -209,7 +243,8 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 		if (!*input)
 			continue;
 
-		add_history(input);
+		if (tty)
+			add_history(input);
 
 		argv = args;
 
@@ -230,7 +265,8 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 			continue;
 
 		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit")) {
-			remove_history(history_length - 1);
+			if (tty)
+				remove_history(history_length - 1);
 			log_error("Exiting.");
 			break;
 		}
@@ -240,11 +276,13 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 			log_error("No such command '%s'.  Try 'help'.",
 				  argv[0]);
 
-                if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
+		if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
 			log_debug(INTERNAL_ERROR "Failed command did not use log_error");
 			log_error("Command failed with status code %d.", ret);
 		}
-		_write_history();
+
+		if (tty)
+			_write_history();
 	}
 
 	free(input);
-- 
1.7.1



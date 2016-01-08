From: Tony Asleson <tasleson@redhat.com>
Date: Fri,  8 Jan 2016 15:37:17 -0600
Subject: [PATCH 2/2] lvm.c: Add return value lvm shell prompt
In-Reply-To: <1452289037-30597-1-git-send-email-tasleson@redhat.com>
References: <1452289037-30597-1-git-send-email-tasleson@redhat.com>
Message-ID: <1452289037-30597-3-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm shell will print messages to stderr when the command completes
successfully.  Thus there is no simple way to know if things executed
OK as you cannot use the absence of stderr as success.  This patch
adds a return code to the prompt when STDIN is *not* a tty so you
cal tell if the previous command completed successfully.

An example:

[0] lvm> pvs
  PV         VG   Fmt  Attr PSize  PFree
  /dev/sdb        lvm2 ---  36.00g 36.00g
  /dev/sdc        lvm2 ---  36.00g 36.00g
  /dev/sdd        lvm2 ---  36.00g 36.00g
  /dev/sde        lvm2 ---  36.00g 36.00g
[0] lvm> vgs doesnotexist
  Volume group "doesnotexist" not found
  Cannot process volume group doesnotexist
[5] lvm>

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 tools/lvm.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/tools/lvm.c b/tools/lvm.c
index 2f3b911..89ef8d3 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -215,6 +215,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	char *input = NULL, *args[MAX_ARGS], **argv;
 	int tty = 0;
 	fetch_line_fp get_next_line = _fetchline;
+	char prompt[32];
 
 	tty = isatty(STDIN_FILENO);
 
@@ -223,6 +224,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 		rl_attempted_completion_function = (rl_completion_func_t *) _completion;
 		_read_history(cmd);
 		get_next_line = readline;
+		snprintf(prompt, sizeof(prompt), "lvm> ");
 	}
 
 	_cmdline = cmdline;
@@ -230,7 +232,12 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	_cmdline->interactive = 1;
 	while (1) {
 		free(input);
-		input = get_next_line("lvm> ");
+
+		if (!tty) {
+			snprintf(prompt, sizeof(prompt), "[%d] lvm> ", ret);
+		}
+
+		input = get_next_line(prompt);
 
 		/* EOF */
 		if (!input) {
@@ -283,6 +290,10 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 
 		if (tty)
 			_write_history();
+
+		/* Zero ret if all was good */
+		if (ret == ECMD_PROCESSED)
+			ret = 0;
 	}
 
 	free(input);
-- 
1.7.1



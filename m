From: Gustavo Zacarias <gustavo@zacarias.com.ar>
Date: Mon,  3 Mar 2014 10:46:35 -0300
Subject: [PATCH] tools: switch to new-style readline typedef
Message-ID: <1393854395-29418-1-git-send-email-gustavo@zacarias.com.ar>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The CPPFunction typedef (among others) have been deprecated in favour of
specific prototyped typedefs since readline 4.2 (circa 2001).
It's been working since because compatibility typedefs have been in
place until they where removed in the recent readline 6.3 release.
Switch to the new style to avoid build breakage.

Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
---
 tools/lvm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvm.c b/tools/lvm.c
index 51e9293..a8d5008 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -185,7 +185,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	char *input = NULL, *args[MAX_ARGS], **argv;
 
 	rl_readline_name = "lvm";
-	rl_attempted_completion_function = (CPPFunction *) _completion;
+	rl_attempted_completion_function = (rl_completion_func_t *) _completion;
 
 	_read_history(cmd);
 
-- 
1.8.3.2



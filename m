From: Milan Broz <mbroz@redhat.com>
Date: Thu, 02 Apr 2009 16:19:47 +0200
Subject: [PATCH] fix cmd->cmd_line memory pool use
Message-ID: <49D4C983.1070002@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not use pointer from released memory pool (cmd->cmd_line).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/lvmcmdline.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index a96ef3c..bedf9e2 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1026,16 +1026,16 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	cmd->current_settings = cmd->default_settings;
 	_apply_settings(cmd);
 
-	/*
-	 * free off any memory the command used.
-	 */
-	dm_pool_empty(cmd->mem);
-
 	if (ret == EINVALID_CMD_LINE && !_cmdline.interactive)
 		_short_usage(cmd->command->name);
 
 	log_debug("Completed: %s", cmd->cmd_line);
 
+	/*
+	 * free off any memory the command used.
+	 */
+	dm_pool_empty(cmd->mem);
+
 	return ret;
 }
 




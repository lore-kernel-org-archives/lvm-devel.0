From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 27 Jul 2009 16:01:45 -0400
Subject: [PATCH] Refactor _override_settings to take the new config string as input.
In-Reply-To: <1248724909-20369-2-git-send-email-dwysocha@redhat.com>
References: <1248724909-20369-1-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1248724909-20369-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We will re-use this function from liblvm.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvmcmdline.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 81adfce..3ca75a7 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -887,9 +887,9 @@ int help(struct cmd_context *cmd __attribute((unused)), int argc, char **argv)
 	return ret;
 }
 
-static int _override_settings(struct cmd_context *cmd)
+static int _override_settings(struct cmd_context *cmd, const char *config_settings)
 {
-	if (!(cmd->cft_override = create_config_tree_from_string(cmd, arg_str_value(cmd, config_ARG, "")))) {
+	if (!(cmd->cft_override = create_config_tree_from_string(cmd, config_settings))) {
 		log_error("Failed to set overridden configuration entries.");
 		return EINVALID_CMD_LINE;
 	}
@@ -986,7 +986,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	set_cmd_name(cmd->command->name);
 
 	if (arg_count(cmd, config_ARG))
-		if ((ret = _override_settings(cmd)))
+		if ((ret = _override_settings(cmd,
+				arg_str_value(cmd, config_ARG, ""))))
 			goto_out;
 
 	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
-- 
1.6.0.6



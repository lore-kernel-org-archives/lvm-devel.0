From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 27 Jul 2009 16:01:46 -0400
Subject: [PATCH] Rename _override_settings into override_config_tree_from_string and move.
In-Reply-To: <1248724909-20369-3-git-send-email-dwysocha@redhat.com>
References: <1248724909-20369-1-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-2-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1248724909-20369-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move _override_settings from tools/lvmcmdline.c into lib/config/config.c
and export so we can re-use in liblvm.
---
 lib/config/config.c |   11 +++++++++++
 lib/config/config.h |    2 ++
 tools/lvmcmdline.c  |   16 ++++------------
 3 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index a32fd9f..7ed7b82 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -186,6 +186,17 @@ struct config_tree *create_config_tree_from_string(struct cmd_context *cmd __att
 	return cft;
 }
 
+int override_config_tree_from_string(struct cmd_context *cmd,
+				     const char *config_settings)
+{
+	if (!(cmd->cft_override = create_config_tree_from_string(cmd,config_settings))) {
+		log_error("Failed to set overridden configuration entries.");
+		return 1;
+	}
+
+	return 0;
+}
+
 int read_config_fd(struct config_tree *cft, struct device *dev,
 		   off_t offset, size_t size, off_t offset2, size_t size2,
 		   checksum_fn_t checksum_fn, uint32_t checksum)
diff --git a/lib/config/config.h b/lib/config/config.h
index 1e4bc29..f5a8f3b 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -56,6 +56,8 @@ struct config_tree_list {
 struct config_tree *create_config_tree(const char *filename, int keep_open);
 struct config_tree *create_config_tree_from_string(struct cmd_context *cmd,
 						   const char *config_settings);
+int override_config_tree_from_string(struct cmd_context *cmd,
+				     const char *config_settings);
 void destroy_config_tree(struct config_tree *cft);
 
 typedef uint32_t (*checksum_fn_t) (uint32_t initial, const void *buf, uint32_t size);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3ca75a7..0966d0b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -887,16 +887,6 @@ int help(struct cmd_context *cmd __attribute((unused)), int argc, char **argv)
 	return ret;
 }
 
-static int _override_settings(struct cmd_context *cmd, const char *config_settings)
-{
-	if (!(cmd->cft_override = create_config_tree_from_string(cmd, config_settings))) {
-		log_error("Failed to set overridden configuration entries.");
-		return EINVALID_CMD_LINE;
-	}
-
-	return 0;
-}
-
 static void _apply_settings(struct cmd_context *cmd)
 {
 	init_debug(cmd->current_settings.debug);
@@ -986,9 +976,11 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	set_cmd_name(cmd->command->name);
 
 	if (arg_count(cmd, config_ARG))
-		if ((ret = _override_settings(cmd,
-				arg_str_value(cmd, config_ARG, ""))))
+		if ((ret = override_config_tree_from_string(cmd,
+			     arg_str_value(cmd, config_ARG, "")))) {
+			ret = EINVALID_CMD_LINE;
 			goto_out;
+		}
 
 	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
-- 
1.6.0.6



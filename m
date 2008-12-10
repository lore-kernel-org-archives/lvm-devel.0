From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:10:56 -0500
Subject: [PATCH 06/11] Remove archive_enable() calls after create_toolcontext() calls.
In-Reply-To: <1228932661-15662-5-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1228932661-15662-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

_init_backup() calls archive_init(), which originally set 'enabled' to
a hardcoded '1' value.  This seems incorrect based on my read of other
areas of the code so here we add a 'enabled' paramter to archive_init().
We pass in cmd->default_settings.archive, which is obtained from the
config tree.  Later in create_toolcontext, cmd->current_settings is
set to cmd->default_settings.  The archive_enable() call we remove
here was using cmd->current_settings to set the 'archive' enable
value.  The final value of cmd->archive_params->enabled should thus
be equivalent to the original code.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    1 -
 lib/commands/toolcontext.c    |    5 +++--
 lib/format_text/archiver.c    |    5 +++--
 lib/format_text/archiver.h    |    3 ++-
 tools/lvmcmdline.c            |    1 -
 5 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 9da99dd..ef4953b 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -733,7 +733,6 @@ int init_lvm(int using_gulm)
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
 	set_activation(cmd->current_settings.activation);
-	archive_enable(cmd, cmd->current_settings.archive);
 	backup_enable(cmd, cmd->current_settings.backup);
 	cmd->cmd_line = (char *)"clvmd";
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index b240dc2..0fd0963 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -926,7 +926,7 @@ static int _init_backup(struct cmd_context *cmd)
 	if (!cmd->sys_dir) {
 		log_warn("WARNING: Metadata changes will NOT be backed up");
 		backup_init(cmd, "");
-		archive_init(cmd, "", 0, 0);
+		archive_init(cmd, "", 0, 0, 0);
 		return 1;
 	}
 
@@ -952,7 +952,8 @@ static int _init_backup(struct cmd_context *cmd)
 	dir = find_config_tree_str(cmd, "backup/archive_dir",
 			      default_dir);
 
-	if (!archive_init(cmd, dir, days, min)) {
+	if (!archive_init(cmd, dir, days, min,
+			  cmd->default_settings.archive)) {
 		log_debug("backup_init failed.");
 		return 0;
 	}
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index ba9a5ab..fc87371 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -36,7 +36,8 @@ struct backup_params {
 };
 
 int archive_init(struct cmd_context *cmd, const char *dir,
-		 unsigned int keep_days, unsigned int keep_min)
+		 unsigned int keep_days, unsigned int keep_min,
+		 int enabled)
 {
 	if (!(cmd->archive_params = dm_pool_zalloc(cmd->libmem,
 						sizeof(*cmd->archive_params)))) {
@@ -56,7 +57,7 @@ int archive_init(struct cmd_context *cmd, const char *dir,
 
 	cmd->archive_params->keep_days = keep_days;
 	cmd->archive_params->keep_number = keep_min;
-	cmd->archive_params->enabled = 1;
+	cmd->archive_params->enabled = enabled;
 
 	return 1;
 }
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index 931aaa4..835d677 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -32,7 +32,8 @@
  */
 
 int archive_init(struct cmd_context *cmd, const char *dir,
-		 unsigned int keep_days, unsigned int keep_min);
+		 unsigned int keep_days, unsigned int keep_min,
+		 int enabled);
 void archive_exit(struct cmd_context *cmd);
 
 void archive_enable(struct cmd_context *cmd, int flag);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index a55c508..0bd875e 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1097,7 +1097,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 	init_cmd_name(cmd->default_settings.cmd_name);
 
-	archive_enable(cmd, cmd->current_settings.archive);
 	backup_enable(cmd, cmd->current_settings.backup);
 
 	set_activation(cmd->current_settings.activation);
-- 
1.5.5.1



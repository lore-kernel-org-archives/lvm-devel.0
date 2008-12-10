From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:10:57 -0500
Subject: [PATCH 07/11] Remove backup_enable() calls after create_toolcontext() calls.
In-Reply-To: <1228932661-15662-6-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1228932661-15662-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Identical argument to previous patch which removed archive_enable() calls.
We add a new parameter to backup_init() which sets the enable value based
on the cmd->default_settings.backup value.  This value was used to set
cmd->current_settings.backup, used in the removed backup_enable() call.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    1 -
 lib/commands/toolcontext.c    |    4 ++--
 lib/format_text/archiver.c    |    4 +++-
 lib/format_text/archiver.h    |    2 +-
 tools/lvmcmdline.c            |    2 --
 5 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index ef4953b..3673803 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -733,7 +733,6 @@ int init_lvm(int using_gulm)
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
 	set_activation(cmd->current_settings.activation);
-	backup_enable(cmd, cmd->current_settings.backup);
 	cmd->cmd_line = (char *)"clvmd";
 
 	/* Check lvm.conf is setup for cluster-LVM */
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0fd0963..186a816 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -925,7 +925,7 @@ static int _init_backup(struct cmd_context *cmd)
 
 	if (!cmd->sys_dir) {
 		log_warn("WARNING: Metadata changes will NOT be backed up");
-		backup_init(cmd, "");
+		backup_init(cmd, "", 0);
 		archive_init(cmd, "", 0, 0, 0);
 		return 1;
 	}
@@ -973,7 +973,7 @@ static int _init_backup(struct cmd_context *cmd)
 
 	dir = find_config_tree_str(cmd, "backup/backup_dir", default_dir);
 
-	if (!backup_init(cmd, dir)) {
+	if (!backup_init(cmd, dir, cmd->default_settings.backup)) {
 		log_debug("backup_init failed.");
 		return 0;
 	}
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index fc87371..829b00c 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -150,7 +150,8 @@ int archive_display_file(struct cmd_context *cmd, const char *file)
 	return r;
 }
 
-int backup_init(struct cmd_context *cmd, const char *dir)
+int backup_init(struct cmd_context *cmd, const char *dir,
+		int enabled)
 {
 	if (!(cmd->backup_params = dm_pool_zalloc(cmd->libmem,
 					       sizeof(*cmd->archive_params)))) {
@@ -166,6 +167,7 @@ int backup_init(struct cmd_context *cmd, const char *dir)
 		log_error("Couldn't copy backup directory name.");
 		return 0;
 	}
+	cmd->backup_params->enabled = enabled;
 
 	return 1;
 }
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index 835d677..eb58ae9 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -41,7 +41,7 @@ int archive(struct volume_group *vg);
 int archive_display(struct cmd_context *cmd, const char *vg_name);
 int archive_display_file(struct cmd_context *cmd, const char *file);
 
-int backup_init(struct cmd_context *cmd, const char *dir);
+int backup_init(struct cmd_context *cmd, const char *dir, int enabled);
 void backup_exit(struct cmd_context *cmd);
 
 void backup_enable(struct cmd_context *cmd, int flag);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0bd875e..2c6c60d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1097,8 +1097,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 	init_cmd_name(cmd->default_settings.cmd_name);
 
-	backup_enable(cmd, cmd->current_settings.backup);
-
 	set_activation(cmd->current_settings.activation);
 
 	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
-- 
1.5.5.1



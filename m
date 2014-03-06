From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 11:21:01 +0000 (UTC)
Subject: master - config: runtime default for backup/backup_dir, backup/archive_dir
Message-ID: <20140306112101.B9D8F6114B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0da1e5d9f8bdb2e4d385faf7c0f4604e63100acc
Commit:        0da1e5d9f8bdb2e4d385faf7c0f4604e63100acc
Parent:        f6adef9825710ad93f96474a9719ef9fcf655721
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 3 13:24:30 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 11:15:21 2014 +0100

config: runtime default for backup/backup_dir, backup/archive_dir

The backup/backup_dir and backup/archive_dir default value is evaluated
in runtime and takes LVM_SYSTEM_DIR into consideration...
---
 lib/commands/toolcontext.c   |   21 ++-------------------
 lib/config/config.c          |   26 ++++++++++++++++++++++++++
 lib/config/config.h          |    6 ++++--
 lib/config/config_settings.h |    4 ++--
 4 files changed, 34 insertions(+), 23 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4b3d265..ce4349d 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1238,7 +1238,6 @@ static int _init_hostname(struct cmd_context *cmd)
 
 static int _init_backup(struct cmd_context *cmd)
 {
-	static char default_dir[PATH_MAX];
 	uint32_t days, min;
 	const char *dir;
 
@@ -1257,16 +1256,8 @@ static int _init_backup(struct cmd_context *cmd)
 
 	min = (uint32_t) find_config_tree_int(cmd, backup_retain_min_CFG, NULL);
 
-	if (dm_snprintf
-	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
-	     DEFAULT_ARCHIVE_SUBDIR) == -1) {
-		log_error("Couldn't create default archive path '%s/%s'.",
-			  cmd->system_dir, DEFAULT_ARCHIVE_SUBDIR);
-		return 0;
-	}
-
 	if (!(dir = find_config_tree_str(cmd, backup_archive_dir_CFG, NULL)))
-		dir = default_dir;
+		return_0;
 
 	if (!archive_init(cmd, dir, days, min,
 			  cmd->default_settings.archive)) {
@@ -1277,16 +1268,8 @@ static int _init_backup(struct cmd_context *cmd)
 	/* set up the backup */
 	cmd->default_settings.backup = find_config_tree_bool(cmd, backup_backup_CFG, NULL);
 
-	if (dm_snprintf
-	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
-	     DEFAULT_BACKUP_SUBDIR) == -1) {
-		log_error("Couldn't create default backup path '%s/%s'.",
-			  cmd->system_dir, DEFAULT_BACKUP_SUBDIR);
-		return 0;
-	}
-
 	if (!(dir = find_config_tree_str(cmd, backup_backup_dir_CFG, NULL)))
-		dir = default_dir;
+		return_0;
 
 	if (!backup_init(cmd, dir, cmd->default_settings.backup)) {
 		log_debug("backup_init failed.");
diff --git a/lib/config/config.c b/lib/config/config.c
index 65a2ba8..75b90fb 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1648,3 +1648,29 @@ const char *get_default_devices_cache_CFG(struct cmd_context *cmd, struct profil
 	}
 	return dm_pool_strdup(cmd->mem, buf);
 }
+
+const char *get_default_backup_backup_dir_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	static char buf[PATH_MAX];
+
+	if (dm_snprintf(buf, sizeof(buf), "%s/%s", cmd->system_dir, DEFAULT_BACKUP_SUBDIR) == -1) {
+		log_error("Couldn't create default backup path '%s/%s'.",
+			  cmd->system_dir, DEFAULT_BACKUP_SUBDIR);
+		return NULL;
+	}
+
+	return dm_pool_strdup(cmd->mem, buf);
+}
+
+const char *get_default_backup_archive_dir_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	static char buf[PATH_MAX];
+
+	if (dm_snprintf (buf, sizeof(buf), "%s/%s", cmd->system_dir, DEFAULT_ARCHIVE_SUBDIR) == -1) {
+		log_error("Couldn't create default archive path '%s/%s'.",
+			  cmd->system_dir, DEFAULT_ARCHIVE_SUBDIR);
+		return NULL;
+	}
+
+	return dm_pool_strdup(cmd->mem, buf);
+}
diff --git a/lib/config/config.h b/lib/config/config.h
index b7e0a16..a042c60 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -227,10 +227,12 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profile);
 
 /*
- * Functions for individual configuration settings for
- * which the default value is evaluated at runtime.
+ * Functions for configuration settings for which the default
+ * value is evaluated at runtime based on command context.
  */
 const char *get_default_devices_cache_dir_CFG(struct cmd_context *cmd, struct profile *profile);
 const char *get_default_devices_cache_CFG(struct cmd_context *cmd, struct profile *profile);
+const char *get_default_backup_backup_dir_CFG(struct cmd_context *cmd, struct profile *profile);
+const char *get_default_backup_archive_dir_CFG(struct cmd_context *cmd, struct profile *profile);
 
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index fd59328..d6ccf0e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -142,9 +142,9 @@ cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFIN
 cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking", vsn(2, 2, 99), NULL)
 
 cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL)
-cfg(backup_backup_dir_CFG, "backup_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg_runtime(backup_backup_dir_CFG, "backup_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), NULL)
 cfg(backup_archive_CFG, "archive", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ARCHIVE_ENABLED, vsn(1, 0, 0), NULL)
-cfg(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), NULL)
 cfg(backup_retain_min_CFG, "retain_min", backup_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_ARCHIVE_NUMBER, vsn(1, 0, 0), NULL)
 cfg(backup_retain_days_CFG, "retain_days", backup_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_ARCHIVE_DAYS, vsn(1, 0, 0), NULL)
 



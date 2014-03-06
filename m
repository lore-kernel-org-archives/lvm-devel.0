From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 11:21:03 +0000 (UTC)
Subject: master - config: runtime default for config/profile_dir
Message-ID: <20140306112103.ED7D66114B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11039589d36b54f8ddb7fe2b0d59dd2610a7e2f4
Commit:        11039589d36b54f8ddb7fe2b0d59dd2610a7e2f4
Parent:        0da1e5d9f8bdb2e4d385faf7c0f4604e63100acc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 3 13:30:13 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 11:16:04 2014 +0100

config: runtime default for config/profile_dir

The config/profile_dir default value takes LVM_SYSTEM_DIR into consideraton.
---
 lib/commands/toolcontext.c   |   12 ++----------
 lib/config/config.c          |   13 +++++++++++++
 lib/config/config.h          |    1 +
 lib/config/config_settings.h |    2 +-
 4 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index ce4349d..7282592 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -613,7 +613,6 @@ static int _init_tag_configs(struct cmd_context *cmd)
 
 static int _init_profiles(struct cmd_context *cmd)
 {
-	static char default_dir[PATH_MAX];
 	const char *dir;
 	struct profile_params *pp;
 
@@ -622,15 +621,8 @@ static int _init_profiles(struct cmd_context *cmd)
 		return 0;
 	}
 
-	if (!(dir = find_config_tree_str(cmd, config_profile_dir_CFG, NULL))) {
-		if (dm_snprintf(default_dir, sizeof(default_dir), "%s/%s",
-				cmd->system_dir, DEFAULT_PROFILE_SUBDIR) == -1) {
-			log_error("Couldn't create default profile path '%s/%s'.",
-				  cmd->system_dir, DEFAULT_PROFILE_SUBDIR);
-			return 0;
-		}
-		dir = default_dir;
-	}
+	if (!(dir = find_config_tree_str(cmd, config_profile_dir_CFG, NULL)))
+		return_0;
 
 	pp->dir = dm_pool_strdup(cmd->libmem, dir);
 	dm_list_init(&pp->profiles_to_load);
diff --git a/lib/config/config.c b/lib/config/config.c
index 75b90fb..f3e105d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1674,3 +1674,16 @@ const char *get_default_backup_archive_dir_CFG(struct cmd_context *cmd, struct p
 
 	return dm_pool_strdup(cmd->mem, buf);
 }
+
+const char *get_default_config_profile_dir_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	static char buf[PATH_MAX];
+
+	if (dm_snprintf(buf, sizeof(buf), "%s/%s", cmd->system_dir, DEFAULT_PROFILE_SUBDIR) == -1) {
+		log_error("Couldn't create default profile path '%s/%s'.",
+			  cmd->system_dir, DEFAULT_PROFILE_SUBDIR);
+		return NULL;
+	}
+
+	return dm_pool_strdup(cmd->mem, buf);
+}
diff --git a/lib/config/config.h b/lib/config/config.h
index a042c60..f380e26 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -234,5 +234,6 @@ const char *get_default_devices_cache_dir_CFG(struct cmd_context *cmd, struct pr
 const char *get_default_devices_cache_CFG(struct cmd_context *cmd, struct profile *profile);
 const char *get_default_backup_backup_dir_CFG(struct cmd_context *cmd, struct profile *profile);
 const char *get_default_backup_archive_dir_CFG(struct cmd_context *cmd, struct profile *profile);
+const char *get_default_config_profile_dir_CFG(struct cmd_context *cmd, struct profile *profile);
 
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d6ccf0e..081d612 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -83,7 +83,7 @@ cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18), NULL)
 
 cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), "Configuration tree check on each LVM command execution.")
 cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99), "Abort LVM command execution if configuration is invalid.")
-cfg(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRING, 0, vsn(2, 2, 99), "Directory with configuration profiles.")
+cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 99), "Directory with configuration profiles.")
 
 cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL)
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, 0, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL)



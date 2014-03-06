From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 11:21:06 +0000 (UTC)
Subject: master - config: runtime default for activation/mirror_image_fault_policy
Message-ID: <20140306112106.10F2E6114B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eecf191d3e95526c6638c668a20472c9c3620967
Commit:        eecf191d3e95526c6638c668a20472c9c3620967
Parent:        11039589d36b54f8ddb7fe2b0d59dd2610a7e2f4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 3 13:37:35 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 11:16:23 2014 +0100

config: runtime default for activation/mirror_image_fault_policy

The activation/mirror_image_fault_policy default value copies the
value (or default one) used for activation/mirror_device_fault_policy.
---
 lib/config/config.c          |    5 +++++
 lib/config/config.h          |    1 +
 lib/config/config_settings.h |    2 +-
 tools/lvconvert.c            |    2 --
 4 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index f3e105d..a7cb5b2 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1687,3 +1687,8 @@ const char *get_default_config_profile_dir_CFG(struct cmd_context *cmd, struct p
 
 	return dm_pool_strdup(cmd->mem, buf);
 }
+
+const char *get_default_activation_mirror_image_fault_policy_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	return find_config_tree_str(cmd, activation_mirror_device_fault_policy_CFG, profile);
+}
diff --git a/lib/config/config.h b/lib/config/config.h
index f380e26..4d762fe 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -235,5 +235,6 @@ const char *get_default_devices_cache_CFG(struct cmd_context *cmd, struct profil
 const char *get_default_backup_backup_dir_CFG(struct cmd_context *cmd, struct profile *profile);
 const char *get_default_backup_archive_dir_CFG(struct cmd_context *cmd, struct profile *profile);
 const char *get_default_config_profile_dir_CFG(struct cmd_context *cmd, struct profile *profile);
+const char *get_default_activation_mirror_image_fault_policy_CFG(struct cmd_context *cmd, struct profile *profile);
 
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 081d612..04f2498 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -202,7 +202,7 @@ cfg(activation_readahead_CFG, "readahead", activation_CFG_SECTION, 0, CFG_TYPE_S
 cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID_FAULT_POLICY, vsn(2, 2, 89), NULL)
 cfg(activation_mirror_device_fault_policy_CFG, "mirror_device_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_DEVICE_FAULT_POLICY, vsn(1, 2, 10), NULL)
 cfg(activation_mirror_log_fault_policy_CFG, "mirror_log_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_LOG_FAULT_POLICY, vsn(1, 2, 18), NULL)
-cfg(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(2, 2, 57), NULL)
+cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 57), NULL)
 cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD, vsn(2, 2, 75), NULL)
 cfg(activation_snapshot_autoextend_percent_CFG, "snapshot_autoextend_percent", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT, vsn(2, 2, 75), NULL)
 cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 09a64c7..c8cc506 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1063,8 +1063,6 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 
 	if (arg_count(cmd, use_policies_ARG)) {
 		leg_policy = find_config_tree_str(cmd, activation_mirror_image_fault_policy_CFG, NULL);
-		if (!leg_policy)
-			leg_policy = find_config_tree_str(cmd, activation_mirror_device_fault_policy_CFG, NULL);
 		log_policy = find_config_tree_str(cmd, activation_mirror_log_fault_policy_CFG, NULL);
 		*replace_mirrors = strcmp(leg_policy, "remove");
 		*replace_log = strcmp(log_policy, "remove");



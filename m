From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 21:28:00 +0000 (UTC)
Subject: master - config: Adjust system_id defaults.
Message-ID: <20150223212800.3FF7E61136@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d406e5a8dfe254f45585759aafa0720a251f0ad
Commit:        3d406e5a8dfe254f45585759aafa0720a251f0ad
Parent:        e15b439bf346f8dc618bef9380b12eb595519a2c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 21:20:51 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 21:20:51 2015 +0000

config: Adjust system_id defaults.

Allow cmd->unknown_system_id to be cleared during toolcontext
refresh.
Set a default value of "none" for global/system_id_source.
Allow local/system_id to be empty so it's not impossible for
a later config file to remove it.
---
 lib/commands/toolcontext.c   |    9 ++++++---
 lib/config/config_settings.h |    4 ++--
 lib/config/defaults.h        |    1 +
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 58f3b5e..d81de97 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -424,12 +424,15 @@ int process_profilable_config(struct cmd_context *cmd)
 
 static int _init_system_id(struct cmd_context *cmd)
 {
-	const char *source;
-	int local_set;
+	const char *source, *system_id;
+	int local_set = 0;
 
 	cmd->system_id = NULL;
+	cmd->unknown_system_id = 0;
 
-	local_set = !!find_config_tree_str(cmd, local_system_id_CFG, NULL);
+	system_id = find_config_tree_str_allow_empty(cmd, local_system_id_CFG, NULL);
+	if (system_id && *system_id)
+		local_set = 1;
 
 	source = find_config_tree_str(cmd, global_system_id_source_CFG, NULL);
 	if (!source)
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7360420..fe4218e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -193,7 +193,7 @@ cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECT
 cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), NULL)
 cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_REPAIR_CMD, vsn(2, 2, 108), NULL)
 cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL)
-cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL)
 cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
 
 cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL)
@@ -281,7 +281,7 @@ cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_H
 cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18), NULL)
 cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
 
-cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
 cfg_array(local_allow_system_id_CFG, "allow_system_id", local_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
 
 cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 9d2cff9..8339c1a 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -29,6 +29,7 @@
 
 #define DEFAULT_DEV_DIR "/dev"
 #define DEFAULT_PROC_DIR "/proc"
+#define DEFAULT_SYSTEM_ID_SOURCE "none"
 #define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 1
 #define DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE "none"
 #define DEFAULT_SYSFS_SCAN 1



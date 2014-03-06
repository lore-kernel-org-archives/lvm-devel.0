From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 08:50:31 +0000 (UTC)
Subject: master - config: fixup default values for selected config settings
Message-ID: <20140306085031.B078D611AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5a4e60c112893b5624cede0dac89bd5de7e14a4
Commit:        c5a4e60c112893b5624cede0dac89bd5de7e14a4
Parent:        52aa3dbcabe85b38b51c68c27fb2397eb0fb1efd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 6 09:41:11 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 09:49:57 2014 +0100

config: fixup default values for selected config settings

These settings don't have any default value predefined:
  log/file
  log/activate_file
  global/library_dir

This settings has default value but not yet declared in config_settings.h:
  global/locking_library (default is DEFAULT_LOCKING_LIB)
---
 lib/config/config_settings.h   |    8 ++++----
 lib/locking/external_locking.c |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 32ca0cf..eb89e87 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -122,14 +122,14 @@ cfg(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL)
 cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT, vsn(2, 2, 98), NULL)
 cfg(log_syslog_CFG, "syslog", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSLOG, vsn(1, 0, 0), NULL)
-cfg(log_file_CFG, "file", log_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg(log_file_CFG, "file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 cfg(log_overwrite_CFG, "overwrite", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OVERWRITE, vsn(1, 0, 0), NULL)
 cfg(log_level_CFG, "level", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_LOGLEVEL, vsn(1, 0, 0), NULL)
 cfg(log_indent_CFG, "indent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_INDENT, vsn(1, 0, 0), NULL)
 cfg(log_command_names_CFG, "command_names", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CMD_NAME, vsn(1, 0, 0), NULL)
 cfg(log_prefix_CFG, "prefix", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_MSG_PREFIX, vsn(1, 0, 0), NULL)
 cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(1, 0, 0), NULL)
-cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking", vsn(2, 2, 99), NULL)
 
 cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL)
@@ -158,8 +158,8 @@ cfg(global_fallback_to_clustered_locking_CFG, "fallback_to_clustered_locking", g
 cfg(global_fallback_to_local_locking_CFG, "fallback_to_local_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LOCAL_LOCKING, vsn(2, 2, 42), NULL)
 cfg(global_locking_dir_CFG, "locking_dir", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LOCK_DIR, vsn(1, 0, 0), NULL)
 cfg(global_prioritise_write_locks_CFG, "prioritise_write_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_PRIORITISE_WRITE_LOCKS, vsn(2, 2, 52), NULL)
-cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
-cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_LOCKING_LIB, vsn(1, 0, 0), NULL)
 cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ABORT_ON_INTERNAL_ERRORS, vsn(2, 2, 57), NULL)
 cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_corruption", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION, vsn(2, 2, 96), NULL)
 cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_METADATA_READ_ONLY, vsn(2, 2, 75), NULL)
diff --git a/lib/locking/external_locking.c b/lib/locking/external_locking.c
index 8b63a29..1e669bb 100644
--- a/lib/locking/external_locking.c
+++ b/lib/locking/external_locking.c
@@ -81,7 +81,7 @@ int init_external_locking(struct locking_type *locking, struct cmd_context *cmd,
 	locking->flags = 0;
 
 	if (!(libname = find_config_tree_str(cmd, global_locking_library_CFG, NULL)))
-		libname = DEFAULT_LOCKING_LIB;
+		return_0;
 
 	if (!(_locking_lib = load_shared_library(cmd, libname, "locking", 1)))
 		return_0;



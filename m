From: David Teigland <teigland@sourceware.org>
Date: Tue,  2 Mar 2021 20:15:47 +0000 (GMT)
Subject: main - config: remove redundant comment for deprecated settings
Message-ID: <20210302201547.DD2ED3950416@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3bab1a10264bf0d546cb5f0948ca382c9c882910
Commit:        3bab1a10264bf0d546cb5f0948ca382c9c882910
Parent:        db4af67b37b224171d9b2fed21f144a5e8a82496
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 2 14:11:38 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 2 14:15:17 2021 -0600

config: remove redundant comment for deprecated settings

Drop the comment "This setting is no longer used." which
was printed just before the standard deprecation comment:
"This configuration option is deprecated."
---
 lib/config/config_settings.h | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index ee5d97721..f04b435fb 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -352,16 +352,16 @@ cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_D
 	"global_filter are not opened by LVM.\n")
 
 cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), vsn(1, 2, 19), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19), vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_CACHE_FILE_PREFIX, vsn(1, 2, 19), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of additional acceptable block device types.\n"
@@ -493,7 +493,7 @@ cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, 0
 	"different way, making them a better choice for VG stacking.\n")
 
 cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 75), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID, vsn(2, 2, 73), NULL, 0, NULL,
 	"Allow use of pvcreate --uuid without requiring --restorefile.\n")
@@ -974,13 +974,13 @@ cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 	"the error messages.\n")
 
 cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(1, 0, 18), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg(global_format_CFG, "format", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.")
+	  NULL)
 
 cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, vsn(2, 3, 3), NULL, NULL)
 
@@ -991,16 +991,16 @@ cfg(global_etc_CFG, "etc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ETC_D
 	"Location of /etc system configuration directory.\n")
 
 cfg(global_locking_type_CFG, "locking_type", global_CFG_SECTION, 0, CFG_TYPE_INT, 1, vsn(1, 0, 0), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.")
+    NULL)
 
 cfg(global_wait_for_locks_CFG, "wait_for_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_WAIT_FOR_LOCKS, vsn(2, 2, 50), NULL, 0, NULL,
 	"When disabled, fail if a lock request would block.\n")
 
 cfg(global_fallback_to_clustered_locking_CFG, "fallback_to_clustered_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING, vsn(2, 2, 42), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg(global_fallback_to_local_locking_CFG, "fallback_to_local_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LOCAL_LOCKING, vsn(2, 2, 42), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg(global_locking_dir_CFG, "locking_dir", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LOCK_DIR, vsn(1, 0, 0), "@DEFAULT_LOCK_DIR@", 0, NULL,
 	"Directory to use for LVM command file locks.\n"
@@ -1019,7 +1019,7 @@ cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_UNDEF
 	"Search this directory first for shared libraries.\n")
 
 cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LOCKING_LIB, vsn(1, 0, 0), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ABORT_ON_INTERNAL_ERRORS, vsn(2, 2, 57), NULL, 0, NULL,
 	"Abort a command that encounters an internal error.\n"
@@ -1027,7 +1027,7 @@ cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_
 	"encountered the internal error. Please only enable for debugging.\n")
 
 cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_corruption", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 96), NULL, vsn(2, 2, 174), NULL,
-	"No longer used.\n")
+	NULL)
 
 cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_METADATA_READ_ONLY, vsn(2, 2, 75), NULL, 0, NULL,
 	"No operations that change on-disk metadata are permitted.\n"
@@ -1125,10 +1125,10 @@ cfg(global_event_activation_CFG, "event_activation", global_CFG_SECTION, CFG_DEF
 	"a direct activation command to activate LVs in complete VGs.\n")
 
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), 0, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg(global_lvmetad_update_wait_time_CFG, "lvmetad_update_wait_time", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(2, 2, 151), NULL, vsn(2, 3, 0), NULL,
-	"This setting is no longer used.\n")
+	NULL)
 
 cfg(global_use_aio_CFG, "use_aio", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_AIO, vsn(2, 2, 183), NULL, 0, NULL,
 	"Use async I/O when reading and writing devices.\n")
@@ -1764,7 +1764,7 @@ cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG
 cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
 cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, vsn(2, 3, 0), NULL,
-	  "This setting is no longer used.\n")
+	  NULL)
 
 cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), vsn(2, 3, 0), NULL, NULL)
 cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), vsn(2, 3, 0), NULL, NULL)



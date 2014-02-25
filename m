From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 25 Feb 2014 10:33:19 +0000 (UTC)
Subject: master - dumpconfig: comment out config lines without default values defined
Message-ID: <20140225103319.616036126A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=558c932444fb4058e1db99147b286bfed72e94d0
Commit:        558c932444fb4058e1db99147b286bfed72e94d0
Parent:        d0b5e51d29d5d1c03b3fd561ced3755383d5f4c3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 25 11:05:23 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 25 11:32:54 2014 +0100

dumpconfig: comment out config lines without default values defined

To make "lvm dumpconfig --type default" output to be usable like any
other config, we need to comment out lines that have no default value
defined. Otherwise, we'd have the output with config options
with blank or zero values which is not the same as when the value
is not defined! And such configuration can't be feed into lvm again
without further edits. So let's fix this.

Currently this covers these configuration options exactly:

  devices/loopfiles
  devices/preferred_names
  devices/filter
  devices/global_filter
  devices/types
  allocation/cling_tag_list
  global/format_libraries
  global/segment_libraries
  activation/volume_list
  activation/auto_activation_volume_list
  activation/read_only_volume_list
  activation/mlock_filter
  metadata/dirs
  metadata/disk_areas
  metadata/disk_areas/<disk_area>
  metadata/disk_areas/<disk_area>/start_sector
  metadata/disk_areas/<disk_area>/size
  metadata/disk_areas/<disk_area>/id
  tags/<tag>
  tags/<tag>/host_list
---
 WHATS_NEW                    |    1 +
 lib/config/config.c          |   20 ++++++++++++--------
 lib/config/config.h          |   11 +++++++----
 lib/config/config_settings.h |   41 +++++++++++++++++++++--------------------
 tools/dumpconfig.c           |   10 +++++++---
 5 files changed, 48 insertions(+), 35 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 005a321..dd0821e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Comment out config lines in dumpconfig output without default values defined.
   Improve detection of clustered mirror support.
   Enhance raid code with feature flags, for now checks for raid10.
   Move parsing of VG metadata from vg_commit() back to vg_write() (2.02.99)
diff --git a/lib/config/config.c b/lib/config/config.c
index 6e93c40..69e357b 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1086,8 +1086,7 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 
 struct out_baton {
 	FILE *fp;
-	int withcomment;
-	int withversion;
+	struct config_def_tree_spec *tree_spec;
 };
 
 static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, void *baton)
@@ -1108,7 +1107,7 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 
 	cfg_def = cfg_def_get_item_p(cn->id);
 
-	if (out->withcomment) {
+	if (out->tree_spec->withcomments) {
 		path = cfg_def_get_path(cfg_def);
 		fprintf(out->fp, "%s# Configuration %s %s.\n", line, node_type_name, path);
 
@@ -1120,9 +1119,12 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 
 		if (cfg_def->flags & CFG_UNSUPPORTED)
 			fprintf(out->fp, "%s# This configuration %s is not officially supported.\n", line, node_type_name);
+
+		if (cfg_def->flags & CFG_DEFAULT_UNDEFINED)
+			fprintf(out->fp, "%s# This configuration %s does not have a default value defined.\n", line, node_type_name);
 	}
 
-	if (out->withversion) {
+	if (out->tree_spec->withversions) {
 		if (dm_snprintf(version, 9, "%u.%u.%u",
 				(cfg_def->since_version & 0xE000) >> 13,
 				(cfg_def->since_version & 0x1E00) >> 9,
@@ -1139,7 +1141,10 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 static int _out_line_fn(const struct dm_config_node *cn, const char *line, void *baton)
 {
 	struct out_baton *out = baton;
-	fprintf(out->fp, "%s\n", line);
+	struct cfg_def_item *cfg_def = cfg_def_get_item_p(cn->id);
+
+	fprintf(out->fp, "%s%s\n", (out->tree_spec->type != CFG_DEF_TREE_CURRENT) &&
+				   (cfg_def->flags & CFG_DEFAULT_UNDEFINED) ? "#" : "", line);
 	return 1;
 }
 
@@ -1149,7 +1154,7 @@ static int _out_suffix_fn(const struct dm_config_node *cn, const char *line, voi
 }
 
 int config_write(struct dm_config_tree *cft,
-		 int withcomment, int withversion,
+		 struct config_def_tree_spec *tree_spec,
 		 const char *file, int argc, char **argv)
 {
 	static const struct dm_config_node_out_spec _out_spec = {
@@ -1159,8 +1164,7 @@ int config_write(struct dm_config_tree *cft,
 	};
 	const struct dm_config_node *cn;
 	struct out_baton baton = {
-		.withcomment = withcomment,
-		.withversion = withversion
+		.tree_spec = tree_spec
 	};
 	int r = 1;
 
diff --git a/lib/config/config.h b/lib/config/config.h
index 0769c40..f716efb 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -82,6 +82,8 @@ typedef union {
 #define CFG_UNSUPPORTED		0x08
 /* whether the configuration item is customizable by a profile */
 #define CFG_PROFILABLE		0x10
+/* whether the default value is undefned */
+#define CFG_DEFAULT_UNDEFINED	0x20
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
@@ -109,8 +111,10 @@ typedef enum {
 struct config_def_tree_spec {
 	cfg_def_tree_t type;		/* tree type */
 	uint16_t version;		/* tree at this LVM2 version */
-	int ignoreadvanced;		/* do not include advanced configs */
-	int ignoreunsupported;		/* do not include unsupported configs */
+	int ignoreadvanced:1;		/* do not include advanced configs */
+	int ignoreunsupported:1;	/* do not include unsupported configs */
+	int withcomments:1;		/* include comments */
+	int withversions:1;		/* include versions */
 	uint8_t *check_status;		/* status of last tree check (currently needed for CFG_DEF_TREE_MISSING only) */
 };
 
@@ -163,8 +167,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			checksum_fn_t checksum_fn, uint32_t checksum);
 int config_file_read(struct dm_config_tree *cft);
 struct dm_config_tree *config_file_open_and_read(const char *config_file, config_source_t source);
-int config_write(struct dm_config_tree *cft,
-		 int withcomment, int withversion,
+int config_write(struct dm_config_tree *cft, struct config_def_tree_spec *tree_spec,
 		 const char *file, int argc, char **argv);
 struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec);
 void config_destroy(struct dm_config_tree *cft);
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f1900b8..32ca0cf 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -32,6 +32,7 @@
  * 				CFG_ADVANCED - this node belongs to advanced config set
  * 				CFG_UNSUPPORTED - this node belongs to unsupported config set
  * 				CFG_PROFILABLE - this node is customizable by a profile
+ * 				CFG_DEFAULT_UNDEFINED - node's default value is undefined
  * type:		allowed type for the value of simple configuation setting, one of:
  * 				CFG_TYPE_BOOL
  * 				CFG_TYPE_INT
@@ -77,16 +78,16 @@ cfg(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRIN
 
 cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL)
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, 0, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL)
-cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL)
+cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL)
 cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL)
-cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL)
-cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
-cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL)
+cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL)
+cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL)
 cfg(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 cfg(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL)
 cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL)
 cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0), NULL)
-cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, 0, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSFS_SCAN, vsn(1, 0, 8), NULL)
 cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL)
 cfg(devices_md_component_detection_CFG, "md_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_COMPONENT_DETECTION, vsn(1, 0, 18), NULL)
@@ -102,7 +103,7 @@ cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid",
 cfg(devices_pv_min_size_CFG, "pv_min_size", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PV_MIN_SIZE_KB, vsn(2, 2, 85), NULL)
 cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ISSUE_DISCARDS, vsn(2, 2, 85), NULL)
 
-cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL)
+cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL)
 cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MAXIMISE_CLING, vsn(2, 2, 85), NULL)
 cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
@@ -148,8 +149,8 @@ cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0), NULL)
 cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), NULL)
 cfg(global_format_CFG, "format", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0), NULL)
-cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
-cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
+cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
 cfg(global_proc_CFG, "proc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL)
 cfg(global_locking_type_CFG, "locking_type", global_CFG_SECTION, 0, CFG_TYPE_INT, 1, vsn(1, 0, 0), NULL)
 cfg(global_wait_for_locks_CFG, "wait_for_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_WAIT_FOR_LOCKS, vsn(2, 2, 50), NULL)
@@ -183,9 +184,9 @@ cfg(activation_use_linear_target_CFG, "use_linear_target", activation_CFG_SECTIO
 cfg(activation_reserved_stack_CFG, "reserved_stack", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_STACK, vsn(1, 0, 0), NULL)
 cfg(activation_reserved_memory_CFG, "reserved_memory", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_MEMORY, vsn(1, 0, 0), NULL)
 cfg(activation_process_priority_CFG, "process_priority", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PROCESS_PRIORITY, vsn(1, 0, 0), NULL)
-cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
-cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 97), NULL)
-cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 89), NULL)
+cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY|CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
+cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 97), NULL)
+cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 89), NULL)
 cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL)
 cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(2, 2, 99), NULL)
 cfg(activation_readahead_CFG, "readahead", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_READ_AHEAD, vsn(1, 0, 23), NULL)
@@ -197,7 +198,7 @@ cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold
 cfg(activation_snapshot_autoextend_percent_CFG, "snapshot_autoextend_percent", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT, vsn(2, 2, 75), NULL)
 cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL)
 cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent", activation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT, vsn(2, 2, 89), NULL)
-cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL)
+cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL)
 cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL)
 cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL)
 cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL)
@@ -208,13 +209,13 @@ cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG
 cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATASIZE, vsn(1, 0, 0), NULL)
 cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_BOOL, DEFAULT_PVMETADATAIGNORE, vsn(2, 2, 69), NULL)
 cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL)
-cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 
-cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_ADVANCED | CFG_UNSUPPORTED, vsn(1, 0, 0), NULL)
-cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_ADVANCED | CFG_UNSUPPORTED, vsn(1, 0, 0), NULL)
-cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL)
-cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL)
-cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL)
+cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL)
+cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL)
+cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL)
+cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 
 cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL)
 cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0), NULL)
@@ -250,7 +251,7 @@ cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, 0, CFG_TYPE_STR
 
 cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_HOSTTAGS, vsn(1, 0, 18), NULL)
 
-cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE, vsn(1, 0, 18), NULL)
-cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
+cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18), NULL)
+cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
 
 cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL)
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 18fba34..cb88bc6 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -193,6 +193,12 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
+	if (arg_count(cmd, withcomments_ARG))
+		tree_spec.withcomments = 1;
+
+	if (arg_count(cmd, withversions_ARG))
+		tree_spec.withversions = 1;
+
 	if (cft_check_handle)
 		tree_spec.check_status = cft_check_handle->status;
 
@@ -202,9 +208,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 	}
 
-	if (!config_write(cft, arg_count(cmd, withcomments_ARG),
-			  arg_count(cmd, withversions_ARG),
-			  file, argc, argv)) {
+	if (!config_write(cft, &tree_spec, file, argc, argv)) {
 		stack;
 		r = ECMD_FAILED;
 	}



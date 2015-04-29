From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 29 Apr 2015 14:32:50 +0000 (UTC)
Subject: master - config: consolidate CFG_UNSUPPORTED and CFG_ADVANCED settings
Message-ID: <20150429143250.85A57606F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b6b90b0730658c12169a0a8fffcf043be6c7eb6
Commit:        8b6b90b0730658c12169a0a8fffcf043be6c7eb6
Parent:        244ca7ee775b554eb12d1897a8f90bf2d9640138
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 29 16:07:52 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 29 16:31:47 2015 +0200

config: consolidate CFG_UNSUPPORTED and CFG_ADVANCED settings

These settings are in the "unsupported" group:

devices/loopfiles
log/activate_file
metadata/disk_areas (section)
metadata/disk_areas/<disk_area> (section)
metadata/disk_areas/<disk_area>/size
metadata/disk_areas/<disk_area>/id

These settings are in the "advanced" group:

devices/dir
devices/scan
devices/types
global/proc
activation/missing_stripe_filler
activation/mlock_filter
metadata/pvmetadatacopies
metadata/pvmetadataignore
metadata/stripesize
metadata/dirs

Also, this patch causes the --ignoreunsupported and --ignoreadvanced
switches to be honoured for all config types (lvmconfig --type).

By default, the --type current and --type diff display unsupported
settings, the other types ignore them - this patch also introduces
--showunsupported switch for all these other types to display even
unsupported settings in their output if needed.
---
 WHATS_NEW                    |    3 +++
 lib/config/config.c          |   10 +++++++++-
 lib/config/config.h          |    2 ++
 lib/config/config_settings.h |   36 ++++++++++++++++++------------------
 man/lvmconfig.8.in           |   15 +++++++++++++--
 tools/args.h                 |    1 +
 tools/commands.h             |   12 +++++++++---
 tools/dumpconfig.c           |   23 +++++++++++++++++++++--
 8 files changed, 76 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1437825..6949497 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.119 - 
 ==================================
+  Add --showunsupported to lvmconfig to also display unsupported settings.
+  Display unsupported settings for lvmconfig --type current,diff only by default.
+  Honour lvmconfig --ignoreunsupported and --ignoreadvanced for all --type.
   Make python bindings usable with python3 (and compatible with 2.6 & 2.7).
   Add lvmconfig -l|--list as shortcut for lvmconfig --type list --withsummary.
   Add lvmconfig --type list to display plain list of configuration settings.
diff --git a/lib/config/config.c b/lib/config/config.c
index 45a1d36..167cfff 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -826,6 +826,12 @@ static int _check_value_differs_from_default(struct cft_check_handle *handle,
 	float f;
 	const char *str;
 
+	if ((handle->ignoreunsupported && (def->flags & CFG_UNSUPPORTED)) ||
+	    (handle->ignoreadvanced && (def->flags & CFG_ADVANCED))) {
+		diff = 0;
+		goto out;
+	}
+
 	/* if default value is undefined, the value used differs from default */
 	if (def->flags & CFG_DEFAULT_UNDEFINED) {
 		diff = 1;
@@ -1598,7 +1604,7 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 static int _out_line_fn(const struct dm_config_node *cn, const char *line, void *baton)
 {
 	struct out_baton *out = baton;
-	struct cfg_def_item *cfg_def = cfg_def_get_item_p(cn->id);
+	struct cfg_def_item *cfg_def;
 	char config_path[CFG_PATH_MAX_LEN];
 	char summary[MAX_COMMENT_LINE+1];
 	char version[9];
@@ -1608,6 +1614,8 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	    (!(out->tree_spec->check_status[cn->id] & CFG_DIFF)))
 		return 1;
 
+	cfg_def = cfg_def_get_item_p(cn->id);
+
 	if (out->tree_spec->type == CFG_DEF_TREE_LIST) {
 		/* List view with node paths and summary. */
 		if (cfg_def->type & CFG_TYPE_SECTION)
diff --git a/lib/config/config.h b/lib/config/config.h
index 1e9f0f8..892529d 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -198,6 +198,8 @@ struct cft_check_handle {
 	unsigned skip_if_checked:1;	/* skip the check if already done before - return last state */
 	unsigned suppress_messages:1;	/* suppress messages during the check if config item is found invalid */
 	unsigned check_diff:1;		/* check if the value used differs from default one */
+	unsigned ignoreadvanced:1;	/* do not include advnced configs */
+	unsigned ignoreunsupported:1;	/* do not include unsupported configs */
 	uint8_t status[CFG_COUNT];	/* flags for each configuration item - the result of the check */
 };
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e97ada5..aaaa3a3 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -39,7 +39,7 @@
  * 				CFG_NAME_VARIABLE - configuration node name is variable
  * 				CFG_ALLOW_EMPTY - node value can be emtpy
  * 				CFG_ADVANCED - this node belongs to advanced config set
- * 				CFG_UNSUPPORTED - this node belongs to unsupported config set
+ * 				CFG_UNSUPPORTED - this node is not officially supported and it's used primarily by developers
  * 				CFG_PROFILABLE - this node is customizable by a profile
  * 				CFG_PROFILABLE_METADATA - profilable and attachable to VG/LV metadata
  * 				CFG_DEFAULT_UNDEFINED - node's default value is undefined
@@ -99,9 +99,9 @@ cfg_section(global_CFG_SECTION, "global", root_CFG_SECTION, CFG_PROFILABLE, vsn(
 	"Miscellaneous global LVM settings.\n")
 
 cfg_section(activation_CFG_SECTION, "activation", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), NULL)
-cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, CFG_ADVANCED, vsn(1, 0, 0), NULL)
+cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
 
-cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_ADVANCED | CFG_PROFILABLE, vsn(1, 0, 0),
+cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0),
 	"LVM report command output formatting.\n")
 
 cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3),
@@ -127,14 +127,14 @@ cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TY
 cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 99),
 	"Directory where LVM looks for configuration profiles.\n")
 
-cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL,
+cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL,
 	"Directory in which to create volume group device nodes.\n"
 	"Commands also accept this as a prefix on volume group names.\n")
 
-cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, 0, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL,
+cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL,
 	"Directories containing device nodes to use with LVM.\n")
 
-cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, NULL)
+cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, NULL)
 
 cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL,
 	"Obtain the list of available devices from udev.\n"
@@ -239,7 +239,7 @@ cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG
 cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0), NULL,
 	"Enable/disable writing the cache file. See devices/cache_dir.\n")
 
-cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL,
+cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL,
 	"List of additional acceptable block device types.\n"
 	"These are of device type names from /proc/devices,\n"
 	"followed by the maximum number of partitions.\n"
@@ -518,7 +518,7 @@ cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(
 	"Log messages during activation.\n"
 	"Don't use this in low memory situations (can deadlock).\n")
 
-cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, NULL)
+cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, NULL)
 
 cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking", vsn(2, 2, 99), NULL,
 	"Select log messages by class.\n"
@@ -605,7 +605,7 @@ cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, C
 
 cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, NULL)
 
-cfg(global_proc_CFG, "proc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL,
+cfg(global_proc_CFG, "proc", global_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL,
 	"Location of proc filesystem.\n")
 
 cfg(global_etc_CFG, "etc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ETC_DIR, vsn(2, 2, 117), "@CONFDIR@",
@@ -926,7 +926,7 @@ cfg(activation_retry_deactivation_CFG, "retry_deactivation", activation_CFG_SECT
 	"process run from a quick udev rule temporarily opened\n"
 	"the device.\n")
 
-cfg(activation_missing_stripe_filler_CFG, "missing_stripe_filler", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_STRIPE_FILLER, vsn(1, 0, 0), NULL,
+cfg(activation_missing_stripe_filler_CFG, "missing_stripe_filler", activation_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_STRIPE_FILLER, vsn(1, 0, 0), NULL,
 	"Method to fill missing stripes when activating an incomplete LV.\n"
 	"Using 'error' will make inaccessible parts of the device return\n"
 	"I/O errors on access.  You can instead use a device path, in which\n"
@@ -1135,7 +1135,7 @@ cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent",
 	"The amount of additional space added to a thin pool is this\n"
 	"percent of its current size.\n")
 
-cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL,
+cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL,
 	"Do not mlock these memory areas.\n"
 	"While activating devices, I/O to devices being\n"
 	"(re)configured is suspended. As a precaution against\n"
@@ -1209,7 +1209,7 @@ cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG
 	"be useful with VGs containing large numbers of PVs.\n"
 	"The '--pvmetadatacopies' option overrides this setting.\n")
 
-cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL,
+cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL,
 	"Number of copies of metadata to maintain for each VG.\n"
 	"If set to a non-zero value, LVM automatically chooses which of\n"
 	"the available metadata areas to use to achieve the requested\n"
@@ -1221,7 +1221,7 @@ cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG
 	"the individual PV level using 'pvchange --metadataignore y|n'.\n"
 	"The '--vgmetadatacopies' option overrides this setting.\n")
 
-cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATASIZE, vsn(1, 0, 0), NULL,
+cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PVMETADATASIZE, vsn(1, 0, 0), NULL,
 	"Approximate number of sectors to use for each metadata copy.\n"
 	"VGs with large numbers of PVs or LVs, or VGs containing\n"
 	"complex LV structures, may need additional space for VG\n"
@@ -1252,11 +1252,11 @@ cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DE
 	"Example:\n"
 	"dirs = [ \"/etc/lvm/metadata\", \"/mnt/disk2/lvm/metadata2\" ]\n")
 
-cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL)
-cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL)
-cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, NULL)
-cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, NULL)
-cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, NULL)
+cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL)
+cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL)
+cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, NULL)
+cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, NULL)
+cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, NULL)
 
 cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL,
 	"Do not print empty report fields.\n"
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index 798e2bb..b855a6e 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -22,6 +22,7 @@ lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration
 .RB [ \-\-metadataprofile
 .IR ProfileName ]
 .RB [ \-\-mergedconfig ]
+.RB [ \-\-showunsupported ]
 .RB [ \-\-validate ]
 .RB [ \-\-withsummary ]
 .RB [ \-\-withcomments ]
@@ -103,8 +104,10 @@ Exclude advanced configuration settings from the output.
 .TP
 .B \-\-ignoreunsupported
 Exclude unsupported configuration settings from the output. These settings are
-either used for debugging purposes only or their support is not yet
-complete and they are not meant to be used in production.
+either used for debugging and development purposes only or their support is not
+yet complete and they are not meant to be used in production. The \fBcurrent\fP
+and \fBdiff\fP types include unsupported settings in their output by default,
+all the other types ignore unsupported settings.
 
 .TP
 .B \-\-ignorelocal
@@ -147,6 +150,14 @@ the front of the cascade is displayed. See also \fBlvm.conf\fP(5) for more
 info about \fBconfig cascade\fP.
 
 .TP
+.B \-\-showunsupported
+Include unsupported configuration settings to the output. These settings
+are either used for debugging or development purposes only or their support
+is not yet complete and they are not meant to be used in production. The
+\fBcurrent\fP and \fBdiff\fP types include unsupported settings in their
+output by default, all the other types ignore unsupported settings.
+
+.TP
 .B \-\-validate
 Validate current configuration used and exit with appropriate
 return code. The validation is done only for the configuration
diff --git a/tools/args.h b/tools/args.h
index 465100d..2745699 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -98,6 +98,7 @@ arg(split_ARG, '\0', "split", NULL, 0)
 arg(splitcache_ARG, '\0', "splitcache", NULL, 0)
 arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0)
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0)
+arg(showunsupported_ARG, '\0', "showunsupported", NULL, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)	/* FIXME Use custom validation fn */
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index f7b6e98..b7f9844 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -44,6 +44,7 @@ xx(config,
    "\t[--profile ProfileName]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
+   "\t[--showunsupported]\n"
    "\t[--validate]\n"
    "\t[--withsummary]\n"
    "\t[--withcomments]\n"
@@ -52,7 +53,8 @@ xx(config,
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG, withversions_ARG)
+   showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG,
+   withversions_ARG)
 
 xx(devtypes,
    "Display recognised built-in block device types",
@@ -96,6 +98,7 @@ xx(dumpconfig,
    "\t[--profile ProfileName]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
+   "\t[--showunsupported]\n"
    "\t[--validate]\n"
    "\t[--withsummary]\n"
    "\t[--withcomments]\n"
@@ -104,7 +107,8 @@ xx(dumpconfig,
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG, withversions_ARG)
+   showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG,
+   withversions_ARG)
 
 xx(formats,
    "List available metadata formats",
@@ -497,6 +501,7 @@ xx(lvmconfig,
    "\t[--profile ProfileName]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
+   "\t[--showunsupported]\n"
    "\t[--validate]\n"
    "\t[--withsummary]\n"
    "\t[--withcomments]\n"
@@ -505,7 +510,8 @@ xx(lvmconfig,
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG, withversions_ARG)
+   showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG,
+   withversions_ARG)
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 50057a1..6b8f7b0 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -50,6 +50,9 @@ static int _do_def_check(struct config_def_tree_spec *spec,
 		handle->check_diff = 0;
 	}
 
+	handle->ignoreunsupported = spec->ignoreunsupported;
+	handle->ignoreadvanced = spec->ignoreadvanced;
+
 	config_def_check(handle);
 	*cft_check_handle = handle;
 
@@ -116,8 +119,22 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, ignoreadvanced_ARG))
 		tree_spec.ignoreadvanced = 1;
 
-	if (arg_count(cmd, ignoreunsupported_ARG))
+	if (arg_count(cmd, ignoreunsupported_ARG)) {
+		if (arg_count(cmd, showunsupported_ARG)) {
+			log_error("Only one of --ignoreunsupported and --showunsupported permitted.");
+			return EINVALID_CMD_LINE;
+		}
 		tree_spec.ignoreunsupported = 1;
+	} else if (arg_count(cmd, showunsupported_ARG)) {
+		tree_spec.ignoreunsupported = 0;
+	} else if (strcmp(type, "current") && strcmp(type, "diff")) {
+		/*
+		 * By default hide unsupported settings
+		 * for all display types except "current"
+		 * and "diff".
+		 */
+		tree_spec.ignoreunsupported = 1;
+	}
 
 	if (arg_count(cmd, ignorelocal_ARG))
 		tree_spec.ignorelocal = 1;
@@ -128,7 +145,9 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 			return EINVALID_CMD_LINE;
 		}
 
-		if ((tree_spec.ignoreadvanced || tree_spec.ignoreunsupported)) {
+		if (arg_count(cmd, ignoreunsupported_ARG) ||
+		    arg_count(cmd, ignoreadvanced_ARG)) {
+			/* FIXME: allow these even for --type current */
 			log_error("--ignoreadvanced and --ignoreunsupported has "
 				  "no effect with --type current");
 			return EINVALID_CMD_LINE;



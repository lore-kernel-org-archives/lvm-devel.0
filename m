From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 09:27:39 +0000 (UTC)
Subject: master - config: cleanup default values for some configuration settings with array values
Message-ID: <20150624092739.5348E60FB4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1545ebf938d3eab5df5ab48b8258afc4f62b896b
Commit:        1545ebf938d3eab5df5ab48b8258afc4f62b896b
Parent:        9465963faf485dc5ae58b1c5aafa02a615411572
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 23 13:18:53 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 11:13:38 2015 +0200

config: cleanup default values for some configuration settings with array values

Do not use "#S" (blank string) as default value as that ends up with
'key = [ "" ]' to be generated which is not what we want in most cases.

Also, fix default values for global/{thin,cache}_{check,repair}_options
and avoid assigning blank values. For example, the thin_check_options
had this set as default value previously:

  "#S" DEFAULT_THIN_CHECK_OPTION1 "#S" DEFAULT_THIN_CHECK_OPTION2

If any (or both) of DEFAULT_THIN_CHECK_OPTION* variables was set
to "", we ended up with clumsy default value generated like:

  thin_check_options = [ "-q", "" ]

With this patch, we end up with correct:

  thin_check_options = [ "-q" ]

or, if all options are undefined:

  thin_check_options = [ ]

Which is the correct way to express this.
---
 lib/config/config_settings.h |   20 ++++++++++----------
 lib/config/defaults.h        |    5 +++++
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f8ea579..9335a7a 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -203,7 +203,7 @@ cfg(devices_external_device_info_source_CFG, "external_device_info_source", devi
 	"udev - Reuse existing udev database records. Applicable\n"
 	"only if LVM is compiled with udev support.\n")
 
-cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED , CFG_TYPE_STRING, "#S", vsn(1, 2, 19), NULL, 0, NULL,
+cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED , CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL, 0, NULL,
 	"Select which path name to display for a block device.\n"
 	"If multiple path names exist for a block device,\n"
 	"and LVM needs to display a name for the device,\n"
@@ -250,7 +250,7 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFIN
 	"filter = [ \"a|loop|\", \"r|.*|\" ]\n"
 	"Example:\n"
 	"Accept all loop devices and ide drives except hdc.\n"
-	"filter =[ \"a|loop|\", \"r|/dev/hdc|\", \"a|/dev/ide|\", \"r|.*|\" ]\n"
+	"filter = [ \"a|loop|\", \"r|/dev/hdc|\", \"a|/dev/ide|\", \"r|.*|\" ]\n"
 	"Example:\n"
 	"Use anchors to be very specific.\n"
 	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|\" ]\n")
@@ -618,7 +618,7 @@ cfg(global_si_unit_consistency_CFG, "si_unit_consistency", global_CFG_SECTION, C
 cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0), NULL, 0, NULL,
 	"Display unit suffix for sizes.\n"
 	"This setting has no effect if the units are in human-readable\n"
-	"form (global/units=\"h\") in which case the suffix is always\n"
+	"form (global/units = \"h\") in which case the suffix is always\n"
 	"displayed.\n")
 
 cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION, vsn(1, 0, 0), NULL, 0, NULL,
@@ -855,7 +855,7 @@ cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECT
 	"Also see thin_repair_options.\n"
 	"(For thin tools, see thin_check_executable.)\n")
 
-cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTION1 "#S" DEFAULT_THIN_CHECK_OPTION2, vsn(2, 2, 96), NULL, 0, NULL,
+cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, DEFAULT_THIN_CHECK_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_THIN_CHECK_OPTIONS_CONFIG, vsn(2, 2, 96), NULL, 0, NULL,
 	"List of options passed to the thin_check command.\n"
 	"With thin_check version 2.1 or newer you can add\n"
 	"--ignore-non-fatal-errors to let it pass through\n"
@@ -863,10 +863,10 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 	"With thin_check version 3.2 or newer you should add\n"
 	"--clear-needs-check-flag.\n")
 
-cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL, 0, NULL,
+cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, DEFAULT_THIN_REPAIR_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_THIN_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 100), NULL, 0, NULL,
 	"List of options passed to the thin_repair command.\n")
 
-cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S", vsn(2, 2, 99), NULL, 0, NULL,
+cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL, 0, NULL,
 	"Features to not use in the thin driver.\n"
 	"This can be helpful for testing, or to avoid\n"
 	"using a feature that is causing problems.\n"
@@ -900,10 +900,10 @@ cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SE
 	"Also see cache_repair_options.\n"
 	"(For cache tools, see cache_check_executable.)\n")
 
-cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_CHECK_OPTION1, vsn(2, 2, 108), NULL, 0, NULL,
+cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, DEFAULT_CACHE_CHECK_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_CACHE_CHECK_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_check command.\n")
 
-cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL, 0, NULL,
+cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG ? CFG_DEFAULT_COMMENTED : CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_repair command.\n")
 
 cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL, 0, NULL,
@@ -1206,7 +1206,7 @@ cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, C
 	"locale-archive was found to make up over 80% of the memory\n"
 	"used by the process.\n"
 	"Example:\n"
-	"mlock_filter=[ \"locale/locale-archive\", \"gconv/gconv-modules.cache\" ]\n")
+	"mlock_filter = [ \"locale/locale-archive\", \"gconv/gconv-modules.cache\" ]\n")
 
 cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Use the old behavior of mlockall to pin all memory.\n"
@@ -1497,7 +1497,7 @@ cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_D
 	"Set the system_id to the string 'host1'.\n"
 	"system_id = \"host1\"\n")
 
-cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S", vsn(2, 2, 117), NULL, 0, NULL,
+cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"A list of extra VG system IDs the local host can access.\n"
 	"VGs with the system IDs listed here (in addition\n"
 	"to the host's own system ID) can be fully accessed\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 6793d01..d764ec9 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -78,12 +78,15 @@
 #ifdef THIN_CHECK_NEEDS_CHECK
 #  define DEFAULT_THIN_CHECK_OPTION1 "-q"
 #  define DEFAULT_THIN_CHECK_OPTION2 "--clear-needs-check-flag"
+#  define DEFAULT_THIN_CHECK_OPTIONS_CONFIG "#S" DEFAULT_THIN_CHECK_OPTION1 "#S" DEFAULT_THIN_CHECK_OPTION2
 #else
 #  define DEFAULT_THIN_CHECK_OPTION1 "-q"
 #  define DEFAULT_THIN_CHECK_OPTION2 ""
+#  define DEFAULT_THIN_CHECK_OPTIONS_CONFIG "#S" DEFAULT_THIN_CHECK_OPTION1
 #endif
 
 #define DEFAULT_THIN_REPAIR_OPTIONS ""
+#define DEFAULT_THIN_REPAIR_OPTIONS_CONFIG NULL
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
@@ -96,7 +99,9 @@
 #define DEFAULT_POOL_METADATA_SPARE 1 /* thin + cache */
 
 #define DEFAULT_CACHE_CHECK_OPTION1 "-q"
+#define DEFAULT_CACHE_CHECK_OPTIONS_CONFIG "#S" DEFAULT_CACHE_CHECK_OPTION1
 #define DEFAULT_CACHE_REPAIR_OPTIONS ""
+#define DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG NULL
 #define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_CACHE_POOL_CHUNK_SIZE 64 /* KB */
 #define DEFAULT_CACHE_POOL_MIN_METADATA_SIZE 2048  /* KB */



From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 17 Aug 2015 19:54:28 +0000 (UTC)
Subject: master - config: add empty lines around examples
Message-ID: <20150817195428.6C3BD60B28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b091c37595b28702e8bd3570416fea2718836d56
Commit:        b091c37595b28702e8bd3570416fea2718836d56
Parent:        ca70770cfd281a353143057d3164e3f9bc661081
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 13 09:16:21 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 17 13:52:34 2015 -0500

config: add empty lines around examples

When --withspaces is used, a blank line is
added before and after an Example section,
making the text less dense.
---
 lib/config/config_settings.h |  137 +++++++++++++++++++++++++----------------
 1 files changed, 83 insertions(+), 54 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 789e2e2..d4f51eb 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -218,8 +218,10 @@ cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, C
 	"Rule 2 prefers the path with the least slashes.\n"
 	"Rule 3 prefers a symlink.\n"
 	"Rule 4 prefers the path with least value in lexicographical order.\n"
-	"Example:\n"
-	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n")
+	"#\n"
+	"Example\n"
+	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n"
+	"#\n")
 
 cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*/|", vsn(1, 0, 0), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM commands.\n"
@@ -240,21 +242,19 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENT
 	"might produce unexpected results (test any changes.)\n"
 	"Run vgscan after changing the filter to regenerate the cache.\n"
 	"See the use_lvmetad comment for a special case regarding filters.\n"
-	"Example:\n"
-	"Accept every block device.\n"
+	"#\n"
+	"Example\n"
+	"Accept every block device:\n"
 	"filter = [ \"a|.*/|\" ]\n"
-	"Example:\n"
-	"Reject the cdrom drive.\n"
+	"Reject the cdrom drive:\n"
 	"filter = [ \"r|/dev/cdrom|\" ]\n"
-	"Example:\n"
-	"Work with just loopback devices, e.g. for testing.\n"
+	"Work with just loopback devices, e.g. for testing:\n"
 	"filter = [ \"a|loop|\", \"r|.*|\" ]\n"
-	"Example:\n"
-	"Accept all loop devices and ide drives except hdc.\n"
+	"Accept all loop devices and ide drives except hdc:\n"
 	"filter = [ \"a|loop|\", \"r|/dev/hdc|\", \"a|/dev/ide|\", \"r|.*|\" ]\n"
-	"Example:\n"
-	"Use anchors to be very specific.\n"
-	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|\" ]\n")
+	"Use anchors to be very specific:\n"
+	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|\" ]\n"
+	"#\n")
 
 cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*/|", vsn(2, 2, 98), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM system components.\n"
@@ -287,8 +287,10 @@ cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED
 	"List of additional acceptable block device types.\n"
 	"These are of device type names from /proc/devices,\n"
 	"followed by the maximum number of partitions.\n"
-	"Example:\n"
-	"types = [ \"fd\", 16 ]\n")
+	"#\n"
+	"Example\n"
+	"types = [ \"fd\", 16 ]\n"
+	"#\n")
 
 cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSFS_SCAN, vsn(1, 0, 8), NULL, 0, NULL,
 	"Restrict device scanning to block devices appearing in sysfs.\n"
@@ -408,14 +410,15 @@ cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTIO
 	"list of tags is defined here, it will check whether any of them are\n"
 	"attached to the PVs concerned and then seek to match those PV tags\n"
 	"between existing extents and new extents.\n"
-	"Example:\n"
-	"Use the special tag \"@*\" as a wildcard to match any PV tag.\n"
+	"#\n"
+	"Example\n"
+	"Use the special tag \"@*\" as a wildcard to match any PV tag:\n"
 	"cling_tag_list = [ \"@*\" ]\n"
-	"Example:\n"
-	"LVs are mirrored between two sites within a single VG.\n"
+	"LVs are mirrored between two sites within a single VG, and\n"
 	"PVs are tagged with either @site1 or @site2 to indicate where\n"
-	"they are situated.\n"
-	"cling_tag_list = [ \"@site1\", \"@site2\" ]\n")
+	"they are situated:\n"
+	"cling_tag_list = [ \"@site1\", \"@site2\" ]\n"
+	"#\n")
 
 cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MAXIMISE_CLING, vsn(2, 2, 85), NULL, 0, NULL,
 	"Use a previous allocation algorithm.\n"
@@ -907,16 +910,20 @@ cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CF
 	"Features: block_size, discards, discards_non_power_2,\n"
 	"external_origin, metadata_resize, external_origin_extend,\n"
 	"error_if_no_space.\n"
-	"Example:\n"
-	"thin_disabled_features = [ \"discards\", \"block_size\" ]\n")
+	"#\n"
+	"Example\n"
+	"thin_disabled_features = [ \"discards\", \"block_size\" ]\n"
+	"#\n")
 
 cfg_array(global_cache_disabled_features_CFG, "cache_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 128), NULL, 0, NULL,
 	"Features to not use in the cache driver.\n"
 	"This can be helpful for testing, or to avoid\n"
 	"using a feature that is causing problems.\n"
 	"Features: policy_mq, policy_smq.\n"
-	"Example:\n"
-	"cache_disabled_features = [ \"policy_smq\" ]\n")
+	"#\n"
+	"Example\n"
+	"cache_disabled_features = [ \"policy_smq\" ]\n"
+	"#\n")
 
 cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, CACHE_CHECK_CMD, vsn(2, 2, 108), "@CACHE_CHECK_CMD@", 0, NULL,
 	"The full path to the cache_check command.\n"
@@ -1066,8 +1073,10 @@ cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG
 	"the LV or VG.  See tags/hosttags.\n"
 	"If any host tags exist but volume_list is not defined,\n"
 	"a default single-entry list containing '@*' is assumed.\n"
-	"Example:\n"
-	"volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n")
+	"#\n"
+	"Example\n"
+	"volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n"
+	"#\n")
 
 cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 97), NULL, 0, NULL,
 	"Only LVs selected by this list are auto-activated.\n"
@@ -1203,19 +1212,25 @@ cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold
 	"The minimum value is 50 (a smaller value is treated as 50.)\n"
 	"Also see snapshot_autoextend_percent.\n"
 	"Automatic extension requires dmeventd to be monitoring the LV.\n"
-	"Example:\n"
-	"With snapshot_autoextend_threshold 70 and\n"
-	"snapshot_autoextend_percent 20, whenever a snapshot\n"
-	"exceeds 70% usage, it will be extended by another 20%.\n"
-	"For a 1G snapshot, using 700M will trigger a resize to 1.2G.\n"
-	"When the usage exceeds 840M, the snapshot will be extended\n"
-	"to 1.44G, and so on.\n")
+	"#\n"
+	"Example\n"
+	"Using 70% autoextend threshold and 20% autoextend size, when a 1G\n"
+	"snapshot exceeds 700M, it is extended to 1.2G, and when it exceeds\n"
+	"840M, it is extended to 1.44G:\n"
+	"snapshot_autoextend_threshold = 70\n"
+	"#\n")
 
 cfg(activation_snapshot_autoextend_percent_CFG, "snapshot_autoextend_percent", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT, vsn(2, 2, 75), NULL, 0, NULL,
 	"Auto-extending a snapshot adds this percent extra space.\n"
 	"The amount of additional space added to a snapshot is this\n"
 	"percent of its current size.\n"
-	"Also see snapshot_autoextend_threshold.\n")
+	"#\n"
+	"Example\n"
+	"Using 70% autoextend threshold and 20% autoextend size, when a 1G\n"
+	"snapshot exceeds 700M, it is extended to 1.2G, and when it exceeds\n"
+	"840M, it is extended to 1.44G:\n"
+	"snapshot_autoextend_percent = 20\n"
+	"#\n")
 
 cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL, 0, NULL,
 	"Auto-extend a thin pool when its usage exceeds this percent.\n"
@@ -1223,18 +1238,25 @@ cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_thresho
 	"The minimum value is 50 (a smaller value is treated as 50.)\n"
 	"Also see thin_pool_autoextend_percent.\n"
 	"Automatic extension requires dmeventd to be monitoring the LV.\n"
-	"Example:\n"
-	"With thin_pool_autoextend_threshold 70 and\n"
-	"thin_pool_autoextend_percent 20, whenever a thin pool\n"
-	"exceeds 70% usage, it will be extended by another 20%.\n"
-	"For a 1G thin pool, using up 700M will trigger a resize to 1.2G.\n"
-	"When the usage exceeds 840M, the thin pool will be extended\n"
-	"to 1.44G, and so on.\n")
+	"#\n"
+	"Example\n"
+	"Using 70% autoextend threshold and 20% autoextend size, when a 1G\n"
+	"thin pool exceeds 700M, it is extended to 1.2G, and when it exceeds\n"
+	"840M, it is extended to 1.44G:\n"
+	"thin_pool_autoextend_threshold = 70\n"
+	"#\n")
 
 cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT, vsn(2, 2, 89), NULL, 0, NULL,
 	"Auto-extending a thin pool adds this percent extra space.\n"
 	"The amount of additional space added to a thin pool is this\n"
-	"percent of its current size.\n")
+	"percent of its current size.\n"
+	"#\n"
+	"Example\n"
+	"Using 70% autoextend threshold and 20% autoextend size, when a 1G\n"
+	"thin pool exceeds 700M, it is extended to 1.2G, and when it exceeds\n"
+	"840M, it is extended to 1.44G:\n"
+	"thin_pool_autoextend_percent = 20\n"
+	"#\n")
 
 cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Do not mlock these memory areas.\n"
@@ -1249,8 +1271,10 @@ cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, C
 	"to lines that match are not pinned.  On some systems,\n"
 	"locale-archive was found to make up over 80% of the memory\n"
 	"used by the process.\n"
-	"Example:\n"
-	"mlock_filter = [ \"locale/locale-archive\", \"gconv/gconv-modules.cache\" ]\n")
+	"#\n"
+	"Example\n"
+	"mlock_filter = [ \"locale/locale-archive\", \"gconv/gconv-modules.cache\" ]\n"
+	"#\n")
 
 cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Use the old behavior of mlockall to pin all memory.\n"
@@ -1358,8 +1382,10 @@ cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DE
 	"Never edit any files in these directories by hand unless you\n"
 	"you are absolutely sure you know what you are doing! Use\n"
 	"the supplied toolset to make changes (e.g. vgcfgrestore).\n"
-	"Example:\n"
-	"dirs = [ \"/etc/lvm/metadata\", \"/mnt/disk2/lvm/metadata2\" ]\n")
+	"#\n"
+	"Example\n"
+	"dirs = [ \"/etc/lvm/metadata\", \"/mnt/disk2/lvm/metadata2\" ]\n"
+	"#\n")
 
 cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), 0, NULL, NULL)
 cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), 0, NULL, NULL)
@@ -1595,10 +1621,12 @@ cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG
 	"to the local machine as a 'host tag'.\n"
 	"If this subsection is empty (has no host_list), then\n"
 	"the subsection name is always applied as a 'host tag'.\n"
-	"Example:\n"
+	"#\n"
+	"Example\n"
 	"The host tag foo is given to all hosts, and the host tag\n"
 	"bar is given to the hosts named machine1 and machine2.\n"
-	"tags { foo { } bar { host_list = [ \"machine1\", \"machine2\" ] } }\n")
+	"tags { foo { } bar { host_list = [ \"machine1\", \"machine2\" ] } }\n"
+	"#\n")
 
 cfg_array(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
 	"A list of machine names.\n"
@@ -1615,12 +1643,13 @@ cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_D
 	"When used, it must be set to a unique value\n"
 	"among all hosts sharing access to the storage,\n"
 	"e.g. a host name.\n"
-	"Example:\n"
-	"Set no system ID.\n"
+	"#\n"
+	"Example\n"
+	"Set no system ID:\n"
 	"system_id = \"\"\n"
-	"Example:\n"
-	"Set the system_id to the string 'host1'.\n"
-	"system_id = \"host1\"\n")
+	"Set the system_id to a specific name:\n"
+	"system_id = \"host1\"\n"
+	"#\n")
 
 cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"A list of extra VG system IDs the local host can access.\n"



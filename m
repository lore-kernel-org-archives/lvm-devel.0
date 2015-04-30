From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Apr 2015 15:55:58 +0000 (UTC)
Subject: master - config_settings: devices/cache, activation/mirror_region_size and activation/mirror_device_fault_policy are deprecated
Message-ID: <20150430155558.8B27061047@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a0197121b07b8a2318000872d4b6916c2176ef9
Commit:        5a0197121b07b8a2318000872d4b6916c2176ef9
Parent:        b769183a98ca942c8252c8571241ac62d7476a26
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 30 17:39:59 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 30 17:39:59 2015 +0200

config_settings: devices/cache, activation/mirror_region_size and activation/mirror_device_fault_policy are deprecated

---
 lib/config/config_settings.h |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index bece635..9fd9be6 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -245,8 +245,9 @@ cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_D
 	"system components. The syntax is the same as devices/filter.\n"
 	"Devices rejected by global_filter are not opened by LVM.\n")
 
-cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), 0, NULL,
-	"The path can be set using the devices/cache_dir setting.\n")
+cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), vsn(1, 2, 19),
+	"This has been replaced by the devices/cache_dir setting.\n",
+	"Cache file path.\n")
 
 cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19), 0, NULL,
 	"Directory in which to store the device cache file.\n"
@@ -1034,8 +1035,9 @@ cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activat
 	"Possible options are: vgname, vgname/lvname, @tag, @*\n"
 	"See volume_list for how these options are matched to LVs.\n")
 
-cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL, 0, NULL,
-	"This has been replaced by the activation/raid_region_size setting.\n")
+cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL, vsn(2, 2, 99),
+	"This has been replaced by the activation/raid_region_size setting.\n",
+        "Size (in KB) of each copy operation when mirroring.\n")
 
 cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(2, 2, 99), NULL, 0, NULL,
 	"Size in KiB of each raid or mirror synchronization region.\n"
@@ -1117,8 +1119,9 @@ cfg(activation_mirror_log_fault_policy_CFG, "mirror_log_fault_policy", activatio
 	"The mirror_image_fault_policy description for mirrored LVs\n"
 	"also applies to mirrored log LVs.\n")
 
-cfg(activation_mirror_device_fault_policy_CFG, "mirror_device_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_DEVICE_FAULT_POLICY, vsn(1, 2, 10), NULL, 0, NULL,
-	"This has been replaced by the mirror_image_fault_policy setting.\n")
+cfg(activation_mirror_device_fault_policy_CFG, "mirror_device_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_DEVICE_FAULT_POLICY, vsn(1, 2, 10), NULL, vsn(2, 2, 57),
+	"This has been replaced by the activation/mirror_image_fault_policy setting.\n",
+        "Define how a device failure affecting a mirror is handled.\n")
 
 cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD, vsn(2, 2, 75), NULL, 0, NULL,
 	"Auto-extend a snapshot when its usage exceeds this percent.\n"



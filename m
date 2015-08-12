From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:16 +0000 (UTC)
Subject: master - cleanup: use IEC KiB units
Message-ID: <20150812124116.F398D60072@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ece758457de0c5a40b5b33b90cab2238de34d55e
Commit:        ece758457de0c5a40b5b33b90cab2238de34d55e
Parent:        79e9bde0ea37abe04afa970972c6bf0504706766
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 16 14:03:48 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:33:15 2015 +0200

cleanup: use IEC KiB units

Reduce mixing of KB, kiB and use just KiB.
---
 lib/config/config_settings.h |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index c2bef27..54a50ab 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -314,7 +314,7 @@ cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, 0
 
 cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_DATA_ALIGNMENT, vsn(2, 2, 75), NULL, 0, NULL,
 	"Default alignment of the start of a PV data area in MB.\n"
-	"If set to 0, a value of 64KB will be used.\n"
+	"If set to 0, a value of 64KiB will be used.\n"
 	"Set to 1 for 1MiB, 2 for 2MiB, etc.\n")
 
 cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_DETECTION, vsn(2, 2, 51), NULL, 0, NULL,
@@ -330,7 +330,7 @@ cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CF
 	"This setting takes precedence over md_chunk_alignment.\n")
 
 cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 45), NULL, 0, NULL,
-	"Alignment of the start of a PV data area in KB.\n"
+	"Alignment of the start of a PV data area in KiB.\n"
 	"If a PV is placed directly on an md device and\n"
 	"md_chunk_alignment or data_alignment_detection are enabled,\n"
 	"then this setting is ignored.  Otherwise, md_chunk_alignment\n"
@@ -341,10 +341,10 @@ cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detectio
 	"Detect PV data alignment offset based on sysfs device information.\n"
 	"The start of a PV aligned data area will be shifted by the\n"
 	"alignment_offset exposed in sysfs.  This offset is often 0, but\n"
-	"may be non-zero.  Certain 4KB sector drives that compensate for\n"
+	"may be non-zero.  Certain 4KiB sector drives that compensate for\n"
 	"windows partitioning will have an alignment_offset of 3584 bytes\n"
-	"(sector 7 is the lowest aligned logical block, the 4KB sectors start\n"
-	"at LBA -1, and consequently sector 63 is aligned on a 4KB boundary).\n"
+	"(sector 7 is the lowest aligned logical block, the 4KiB sectors start\n"
+	"at LBA -1, and consequently sector 63 is aligned on a 4KiB boundary).\n"
 	"pvcreate --dataalignmentoffset will skip this detection.\n")
 
 cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_SUSPENDED_DEVICES, vsn(1, 2, 19), NULL, 0, NULL,
@@ -384,9 +384,9 @@ cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid",
 	"Allow use of pvcreate --uuid without requiring --restorefile.\n")
 
 cfg(devices_pv_min_size_CFG, "pv_min_size", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PV_MIN_SIZE_KB, vsn(2, 2, 85), NULL, 0, NULL,
-	"Minimum size (in KB) of block devices which can be used as PVs.\n"
+	"Minimum size in KiB of block devices which can be used as PVs.\n"
 	"In a clustered environment all nodes must use the same value.\n"
-	"Any value smaller than 512KB is ignored.  The previous built-in\n"
+	"Any value smaller than 512KiB is ignored.  The previous built-in\n"
 	"value was 512.\n")
 
 cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ISSUE_DISCARDS, vsn(2, 2, 85), NULL, 0, NULL,
@@ -440,7 +440,7 @@ cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_z
 	"Look for and erase any signatures while zeroing a new LV.\n"
 	"Zeroing is controlled by the -Z/--zero option, and if not\n"
 	"specified, zeroing is used by default if possible.\n"
-	"Zeroing simply overwrites the first 4 KiB of a new LV\n"
+	"Zeroing simply overwrites the first 4KiB of a new LV\n"
 	"with zeroes and does no signature detection or wiping.\n"
 	"Signature wiping goes beyond zeroing and detects exact\n"
 	"types and positions of signatures within the whole LV.\n"
@@ -490,7 +490,7 @@ cfg_section(policy_settings_CFG_SUBSECTION, "policy_settings", allocation_cache_
 	"Multiple subsections for different policies can be created.\n")
 
 cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), 0, NULL,
-	"The minimal chunk size (in kiB) for cache pool volumes.\n"
+	"The minimal chunk size in KiB for cache pool volumes.\n"
 	"Using a chunk_size that is too large can result in wasteful\n"
 	"use of the cache, where small reads and writes can cause\n"
 	"large sections of an LV to be mapped into the cache.  However,\n"
@@ -498,8 +498,8 @@ cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", alloc
 	"overhead trying to manage the numerous chunks that become mapped\n"
 	"into the cache.  The former is more of a problem than the latter\n"
 	"in most cases, so we default to a value that is on the smaller\n"
-	"end of the spectrum.  Supported values range from 32(kiB) to\n"
-	"1048576 in multiples of 32.\n")
+	"end of the spectrum.  Supported values range from 32KiB to\n"
+	"1GiB in multiples of 32.\n")
 
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
 	"Thin pool metdata and data will always use different PVs.\n")
@@ -525,16 +525,16 @@ cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", a
 	"The chunk size is always at least 512KiB.\n")
 
 cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99), 0, NULL,
-	"The minimal chunk size (in KB) for thin pool volumes.\n"
+	"The minimal chunk size in KiB for thin pool volumes.\n"
 	"Larger chunk sizes may improve performance for plain\n"
 	"thin volumes, however using them for snapshot volumes\n"
 	"is less efficient, as it consumes more space and takes\n"
 	"extra time for copying.  When unset, lvm tries to estimate\n"
-	"chunk size starting from 64KB.  Supported values are in\n"
-	"the range 64 to 1048576.\n")
+	"chunk size starting from 64KiB.  Supported values are in\n"
+	"the range 64KiB to 1GiB.\n")
 
 cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
-	"Default physical extent size to use for new VGs (in KB).\n")
+	"Default physical extent size in KiB to use for new VGs.\n")
 
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Controls the messages sent to stdout or stderr.\n")
@@ -1040,11 +1040,11 @@ cfg(activation_use_linear_target_CFG, "use_linear_target", activation_CFG_SECTIO
 	"that only handles a single stripe.\n")
 
 cfg(activation_reserved_stack_CFG, "reserved_stack", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_STACK, vsn(1, 0, 0), NULL, 0, NULL,
-	"Stack size in KB to reserve for use while devices are suspended.\n"
+	"Stack size in KiB to reserve for use while devices are suspended.\n"
 	"Insufficent reserve risks I/O deadlock during device suspension.\n")
 
 cfg(activation_reserved_memory_CFG, "reserved_memory", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_MEMORY, vsn(1, 0, 0), NULL, 0, NULL,
-	"Memory size in KB to reserve for use while devices are suspended.\n"
+	"Memory size in KiB to reserve for use while devices are suspended.\n"
 	"Insufficent reserve risks I/O deadlock during device suspension.\n")
 
 cfg(activation_process_priority_CFG, "process_priority", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PROCESS_PRIORITY, vsn(1, 0, 0), NULL, 0, NULL,
@@ -1111,7 +1111,7 @@ cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activat
 
 cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL, vsn(2, 2, 99),
 	"This has been replaced by the activation/raid_region_size setting.\n",
-        "Size (in KB) of each copy operation when mirroring.\n")
+        "Size in KiB of each copy operation when mirroring.\n")
 
 cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(2, 2, 99), NULL, 0, NULL,
 	"Size in KiB of each raid or mirror synchronization region.\n"



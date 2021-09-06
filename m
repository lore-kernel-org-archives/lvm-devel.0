From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  6 Sep 2021 13:25:08 +0000 (GMT)
Subject: main - vdo: add support for auto-unsafe writePolicy
Message-ID: <20210906132508.25AC23858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=79427151dc5ffb5faff133c57e058acbad00dd10
Commit:        79427151dc5ffb5faff133c57e058acbad00dd10
Parent:        337053c56a2d288337449067510301d5a2e4eec5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 6 13:56:40 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 6 15:19:51 2021 +0200

vdo: add support for auto-unsafe writePolicy

This vdoWritePolicy policy missed matching support in lvm2.
---
 WHATS_NEW                      | 1 +
 conf/example.conf.in           | 2 ++
 device_mapper/libdm-deptree.c  | 3 ++-
 device_mapper/vdo/target.h     | 3 ++-
 device_mapper/vdo/vdo_target.c | 1 +
 lib/config/config_settings.h   | 4 +++-
 lib/metadata/vdo_manip.c       | 4 ++++
 7 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 90fe1b676..feed7f53d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.14 - 
 ==================================
+  Add support for VDO async-unsage write policy.
   Improve lvm_import_vdo script.
   Support VDO LV with lvcreate -ky.
   Fix lvconvert for VDO LV bigger then 2T.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 2dc6dd9e6..5bcbc65e7 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -713,6 +713,8 @@ allocation {
 	#         This policy is not supported if the underlying storage is not also synchronous.
 	# async - Writes are acknowledged after data has been cached for writing to stable storage.
 	#         Data which has not been flushed is not guaranteed to persist in this mode.
+	# async-unsafe - Writes are handled like 'async' but there is no guarantee of the atomicity async provides.
+	#         This mode should only be used for better performance when atomicity is not required.
 	# This configuration option has an automatic default value.
 	# vdo_write_policy = "auto"
 
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 70acfb093..c759c4e46 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2885,7 +2885,8 @@ static int _vdo_emit_segment_line(struct dm_task *dmt,
 		    seg->vdo_params.block_map_era_length,
 		    seg->vdo_params.use_metadata_hints ? "on" : "off" ,
 		    (seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_SYNC) ? "sync" :
-			(seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_ASYNC) ? "async" : "auto", // policy
+			(seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_ASYNC) ? "async" :
+			(seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_ASYNC_UNSAFE) ? "async-unsafe" : "auto", // policy
 		    seg->vdo_name,
 		    seg->vdo_params.max_discard,
 		    seg->vdo_params.ack_threads,
diff --git a/device_mapper/vdo/target.h b/device_mapper/vdo/target.h
index 776798389..51dde3f4d 100644
--- a/device_mapper/vdo/target.h
+++ b/device_mapper/vdo/target.h
@@ -69,7 +69,8 @@ bool dm_vdo_status_parse(struct dm_pool *mem, const char *input,
 enum dm_vdo_write_policy {
 	DM_VDO_WRITE_POLICY_AUTO = 0,
 	DM_VDO_WRITE_POLICY_SYNC,
-	DM_VDO_WRITE_POLICY_ASYNC
+	DM_VDO_WRITE_POLICY_ASYNC,
+	DM_VDO_WRITE_POLICY_ASYNC_UNSAFE
 };
 
 // FIXME: review whether we should use the createParams from the userlib
diff --git a/device_mapper/vdo/vdo_target.c b/device_mapper/vdo/vdo_target.c
index 946be5aa7..2ffd29145 100644
--- a/device_mapper/vdo/vdo_target.c
+++ b/device_mapper/vdo/vdo_target.c
@@ -100,6 +100,7 @@ bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 	switch (vtp->write_policy) {
 	case DM_VDO_WRITE_POLICY_SYNC:
 	case DM_VDO_WRITE_POLICY_ASYNC:
+	case DM_VDO_WRITE_POLICY_ASYNC_UNSAFE:
 	case DM_VDO_WRITE_POLICY_AUTO:
 		break;
 	default:
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index fa87bea23..c0e491cad 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -796,7 +796,9 @@ cfg(allocation_vdo_write_policy_CFG, "vdo_write_policy", allocation_CFG_SECTION,
 	"sync  - Writes are acknowledged only after data is stably written.\n"
 	"        This policy is not supported if the underlying storage is not also synchronous.\n"
 	"async - Writes are acknowledged after data has been cached for writing to stable storage.\n"
-	"        Data which has not been flushed is not guaranteed to persist in this mode.\n")
+	"        Data which has not been flushed is not guaranteed to persist in this mode.\n"
+	"async-unsafe - Writes are handled like 'async' but there is no guarantee of the atomicity async provides.\n"
+	"        This mode should only be used for better performance when atomicity is not required.\n")
 
 cfg(allocation_vdo_max_discard_CFG, "vdo_max_discard", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_MAX_DISCARD, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specified the maximum size of discard bio accepted, in 4096 byte blocks.\n"
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 3f2de1a01..673db98e2 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -81,6 +81,8 @@ const char *get_vdo_write_policy_name(enum dm_vdo_write_policy policy)
 		return "sync";
 	case DM_VDO_WRITE_POLICY_ASYNC:
 		return "async";
+	case DM_VDO_WRITE_POLICY_ASYNC_UNSAFE:
+		return "async-unsafe";
 	default:
 		log_debug(INTERNAL_ERROR "Unrecognized VDO write policy: %u.", policy);
 		/* Fall through */
@@ -441,6 +443,8 @@ int set_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy)
 		*vwp = DM_VDO_WRITE_POLICY_SYNC;
 	else if (strcasecmp(policy, "async") == 0)
 		*vwp = DM_VDO_WRITE_POLICY_ASYNC;
+	else if (strcasecmp(policy, "async-unsafe") == 0)
+		*vwp = DM_VDO_WRITE_POLICY_ASYNC_UNSAFE;
 	else if (strcasecmp(policy, "auto") == 0)
 		*vwp = DM_VDO_WRITE_POLICY_AUTO;
 	else {



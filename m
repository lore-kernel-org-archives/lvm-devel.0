From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2023 18:24:59 +0000 (GMT)
Subject: main - vdo: check_point_frequence is unused option
Message-ID: <20230629182459.38ECA3858421@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6ff65e675582265a673136f1edd5358b26c9e481
Commit:        6ff65e675582265a673136f1edd5358b26c9e481
Parent:        fa434a18373e42108aed319d3257c935f510f2c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 11:55:20 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 13:10:42 2023 +0200

vdo: check_point_frequence is unused option

This vdo parameter existed in the early stage of integration of vdo into lvm2,
but later it's been removed from vdoformat tool - so actually if
there would be any non-zero value it would cause error on lvcreate.
Option was not stored on disk in lvm2 metadata.

Remove this vdo parameter from lvm2 sources.

(Although this vdo parameter will be still accepted on cmdline through
 --vdosettings option, but it will be ignored.)
---
 conf/example.conf.in         |  5 -----
 conf/vdo-small.profile       |  1 -
 device_mapper/vdo/target.h   |  1 -
 lib/config/config_settings.h |  4 ++--
 lib/metadata/merge.c         |  1 -
 lib/metadata/vdo_manip.c     | 10 ----------
 man/lvmvdo.7_main            |  1 -
 scripts/lvm_import_vdo.sh    |  1 -
 tools/toollib.c              |  6 +++++-
 9 files changed, 7 insertions(+), 23 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 35837c013..1ed1f854b 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -650,11 +650,6 @@ allocation {
 	# This configuration option has an automatic default value.
 	# vdo_block_map_period = 16380
 
-	# Configuration option allocation/vdo_check_point_frequency.
-	# The default check point frequency for VDO volume.
-	# This configuration option has an automatic default value.
-	# vdo_check_point_frequency = 0
-
 	# Configuration option allocation/vdo_use_sparse_index.
 	# Enables sparse indexing for VDO volume.
 	# This configuration option has an automatic default value.
diff --git a/conf/vdo-small.profile b/conf/vdo-small.profile
index 2044fc27f..97b5b37dd 100644
--- a/conf/vdo-small.profile
+++ b/conf/vdo-small.profile
@@ -8,7 +8,6 @@ allocation {
 	vdo_minimum_io_size=4096
 	vdo_block_map_cache_size_mb=128
 	vdo_block_map_period=16380
-	vdo_check_point_frequency=0
 	vdo_use_sparse_index=0
 	vdo_index_memory_size_mb=256
 	vdo_slab_size_mb=2048
diff --git a/device_mapper/vdo/target.h b/device_mapper/vdo/target.h
index bd21bb5d7..353320f9e 100644
--- a/device_mapper/vdo/target.h
+++ b/device_mapper/vdo/target.h
@@ -81,7 +81,6 @@ struct dm_vdo_target_params {
 		uint32_t block_map_era_length;	// format period
 		uint32_t block_map_period;      // supported alias
 	};
-	uint32_t check_point_frequency;
 	uint32_t index_memory_size_mb;  // format
 
 	uint32_t slab_size_mb;          // format
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 51e11857e..fd56993ba 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -732,8 +732,8 @@ cfg(allocation_vdo_block_map_era_length_CFG, "vdo_block_map_period", allocation_
 	"The maximum and recommended value is " DM_TO_STRING(DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM)
 	"; the minimum value is " DM_TO_STRING(DM_VDO_BLOCK_MAP_ERA_LENGTH_MINIMUM) ".\n")
 
-cfg(allocation_vdo_check_point_frequency_CFG, "vdo_check_point_frequency", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_CHECK_POINT_FREQUENCY, VDO_1ST_VSN, NULL, 0, NULL,
-	"The default check point frequency for VDO volume.\n")
+cfg(allocation_vdo_check_point_frequency_CFG, "vdo_check_point_frequency", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_CHECK_POINT_FREQUENCY, VDO_1ST_VSN, NULL, vsn(2, 3, 22), NULL,
+	"Deprecated option to set default check point frequency for VDO volume.\n")
 
 // vdo format
 cfg(allocation_vdo_use_sparse_index_CFG, "vdo_use_sparse_index", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_SPARSE_INDEX, VDO_1ST_VSN, NULL, 0, NULL,
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 5209f51b5..25b2bc33a 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -555,7 +555,6 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 		if (seg->vdo_params.minimum_io_size |
 		    seg->vdo_params.block_map_cache_size_mb |
 		    seg->vdo_params.block_map_era_length |
-		    seg->vdo_params.check_point_frequency |
 		    seg->vdo_params.index_memory_size_mb |
 		    seg->vdo_params.slab_size_mb |
 		    seg->vdo_params.max_discard |
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 19291c9d6..f24182cca 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -283,14 +283,6 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 	argv[args] = buf_args[args];
 	args++;
 
-	if (vtp->check_point_frequency) {
-		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--uds-checkpoint-frequency=%u",
-				vtp->check_point_frequency) < 0)
-			return_0;
-		argv[args] = buf_args[args];
-		args++;
-	}
-
 	/* Convert size to GiB units or one of these strings: 0.25, 0.50, 0.75 */
 	if (vtp->index_memory_size_mb >= 1024) {
 		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--uds-memory-size=%u",
@@ -516,8 +508,6 @@ int fill_vdo_target_params(struct cmd_context *cmd,
 		find_config_tree_int64(cmd, allocation_vdo_block_map_cache_size_mb_CFG, profile);
 	vtp->block_map_era_length =
 		find_config_tree_int(cmd, allocation_vdo_block_map_era_length_CFG, profile);
-	vtp->check_point_frequency =
-		find_config_tree_int(cmd, allocation_vdo_check_point_frequency_CFG, profile);
 	vtp->use_sparse_index =
 		find_config_tree_int(cmd, allocation_vdo_use_sparse_index_CFG, profile);
 	vtp->index_memory_size_mb =
diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 8c3e3eeaa..a31e5dd4d 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -165,7 +165,6 @@ vdo_use_metadata_hints=1
 vdo_minimum_io_size=4096
 vdo_block_map_cache_size_mb=128
 vdo_block_map_period=16380
-vdo_check_point_frequency=0
 vdo_use_sparse_index=0
 vdo_index_memory_size_mb=256
 vdo_slab_size_mb=2048
diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 13197c6fb..307233429 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -560,7 +560,6 @@ allocation {
 	vdo_minimum_io_size = $vdo_logicalBlockSize
 	vdo_block_map_cache_size_mb = $(( $(get_kb_size_with_unit_ "$vdo_blockMapCacheSize") / 1024 ))
 	vdo_block_map_period = $vdo_blockMapPeriod
-	vdo_check_point_frequency = $vdo_indexCfreq
 	vdo_use_sparse_index = $(get_enabled_value_ "$vdo_indexSparse")
 	vdo_index_memory_size_mb = $(awk "BEGIN {print $vdo_indexMemory * 1024}")
 	vdo_slab_size_mb = $(( $(get_kb_size_with_unit_ "$vdo_slabSize") / 1024 ))
diff --git a/tools/toollib.c b/tools/toollib.c
index 2f4756b6b..696f541c4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1319,7 +1319,6 @@ int get_vdo_settings(struct cmd_context *cmd,
 			// Settings bellow cannot be changed with lvchange command
 			is_lvchange = checked_lvchange;
 
-			DO_OFFLINE(check_point_frequency);
 			DO_OFFLINE(index_memory_size_mb);
 			DO_OFFLINE(minimum_io_size);
 			DO_OFFLINE(slab_size_mb);
@@ -1336,6 +1335,11 @@ int get_vdo_settings(struct cmd_context *cmd,
 				continue;
 			}
 
+			if (_compare_vdo_option(cn->key, "check_point_frequency")) {
+				log_verbose("Ignoring deprecated --vdosettings option \"%s\" and its value.", cn->key);
+				continue; /* Accept & ignore deprecated option */
+			}
+
 			log_error("Unknown VDO setting \"%s\".", cn->key);
 			goto out;
 		}


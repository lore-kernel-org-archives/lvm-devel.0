From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 29 Jan 2014 18:13:03 +0000 (UTC)
Subject: master - cache: Allocation code changes necessary to support cache_pool
Message-ID: <20140129181303.0B76460FC1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70fd2139e17568e757fd66f5ebfcea2b1bb9d3f1
Commit:        70fd2139e17568e757fd66f5ebfcea2b1bb9d3f1
Parent:        75b8ea195cb3783ebe6ed7f95907e8a647a85a74
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jan 28 12:25:02 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jan 28 12:25:02 2014 -0600

cache:  Allocation code changes necessary to support cache_pool

Cache pools require a data and metadata area (like thin pools).  Unlike
thin pool, if 'cache_pool_metadata_require_separate_pvs' is not set to
'1', the metadata and data area will be allocated from the same device.
It is also done in a manner similar to RAID, where a single chunk of
space is allocated and then split to form the metadata and data device -
ensuring that they are together.
---
 conf/example.conf.in         |    4 ++++
 lib/config/config_settings.h |    1 +
 lib/config/defaults.h        |    2 ++
 lib/metadata/lv_manip.c      |   39 ++++++++++++++++++++++++++++++++-------
 4 files changed, 39 insertions(+), 7 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 0f73cf3..7b98b4b 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -301,6 +301,10 @@ allocation {
     # until version 2.02.85.
     mirror_logs_require_separate_pvs = 0
 
+    # Set to 1 to guarantee that cache_pool metadata will always be
+    # placed on  different PVs from the cache_pool data.
+    cache_pool_metadata_require_separate_pvs = 0
+
     # Set to 1 to guarantee that thin pool metadata will always
     # be placed on different PVs from the pool data.
     thin_pool_metadata_require_separate_pvs = 0
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 1546b3f..2c6953b 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -107,6 +107,7 @@ cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0,
 cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL)
+cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 141b7ae..a388e13 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -79,6 +79,8 @@
 #define DEFAULT_THIN_POOL_ZERO 1
 #define DEFAULT_POOL_METADATA_SPARE 1
 
+#define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
+
 #define DEFAULT_UMASK 0077
 
 #ifdef LVM1_FALLBACK
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a2831cf..bd1e57c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -924,6 +924,9 @@ struct alloc_handle {
 	 * that is new_extents + log_len and then split that between two
 	 * allocated areas when found.  'alloc_and_split_meta' indicates
 	 * that this is the desired dynamic.
+	 *
+	 * This same idea is used by cache LVs to get the metadata device
+	 * and data device allocated together.
 	 */
 	unsigned alloc_and_split_meta;
 
@@ -1115,6 +1118,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	 * a correct area_multiple.
 	 */
 	ah->area_multiple = _calc_area_multiple(segtype, area_count + parity_count, stripes);
+	//FIXME: s/mirror_logs_separate/metadata_separate/ so it can be used by otehrs?
 	ah->mirror_logs_separate = find_config_tree_bool(cmd, allocation_mirror_logs_require_separate_pvs_CFG, NULL);
 
 	if (segtype_is_raid(segtype)) {
@@ -1137,12 +1141,30 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 			ah->log_len = 0;
 		}
 	} else if (segtype_is_thin_pool(segtype)) {
-		ah->log_area_count = metadata_area_count;
-		/* thin_pool uses region_size to pass metadata size in extents */
+		/*
+		 * thin_pool uses ah->region_size to
+		 * pass metadata size in extents
+		 */
 		ah->log_len = ah->region_size;
+		ah->log_area_count = metadata_area_count;
 		ah->region_size = 0;
 		ah->mirror_logs_separate =
 			find_config_tree_bool(cmd, allocation_thin_pool_metadata_require_separate_pvs_CFG, NULL);
+	} else if (segtype_is_cache_pool(segtype)) {
+		/*
+		 * Like thin_pool, cache_pool uses ah->region_size to
+		 * pass metadata size in extents
+		 */
+		ah->log_len = ah->region_size;
+		/* use metadata_area_count, not log_area_count */
+		ah->metadata_area_count = metadata_area_count;
+		ah->region_size = 0;
+		ah->mirror_logs_separate =
+			find_config_tree_bool(cmd, allocation_cache_pool_metadata_require_separate_pvs_CFG, NULL);
+		if (!ah->mirror_logs_separate) {
+			ah->alloc_and_split_meta = 1;
+			ah->new_extents += ah->log_len;
+		}
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
@@ -1956,14 +1978,15 @@ static void _report_needed_allocation_space(struct alloc_handle *ah,
 	uint32_t parallel_areas_count, parallel_area_size;
 	uint32_t metadata_count, metadata_size;
 
-	parallel_area_size = (ah->new_extents - alloc_state->allocated) / ah->area_multiple -
-		      ((ah->alloc_and_split_meta) ? ah->log_len : 0);
+	parallel_area_size = ah->new_extents - alloc_state->allocated;
+	parallel_area_size /= ah->area_multiple;
+	parallel_area_size -= (ah->alloc_and_split_meta) ? ah->log_len : 0;
 
 	parallel_areas_count = ah->area_count + ah->parity_count;
 
 	metadata_size = ah->log_len;
 	if (ah->alloc_and_split_meta) {
-		metadata_type = "RAID metadata area";
+		metadata_type = "metadata area";
 		metadata_count = parallel_areas_count;
 	} else {
 		metadata_type = "mirror log";
@@ -1975,8 +1998,10 @@ static void _report_needed_allocation_space(struct alloc_handle *ah,
 	log_debug_alloc("  %" PRIu32 " (%" PRIu32 " data/%" PRIu32
 			" parity) parallel areas of %" PRIu32 " extents each",
 			parallel_areas_count, ah->area_count, ah->parity_count, parallel_area_size);
-	log_debug_alloc("  %" PRIu32 " %ss of %" PRIu32 " extents each",
-			metadata_count, metadata_type, metadata_size);
+	log_debug_alloc("  %" PRIu32 " %s%s of %" PRIu32 " extents each",
+			metadata_count, metadata_type,
+			(metadata_count == 1) ? "" : "s",
+			metadata_size);
 }
 /*
  * Returns 1 regardless of whether any space was found, except on error.



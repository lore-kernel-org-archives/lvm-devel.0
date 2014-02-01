From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 31 Jan 2014 18:03:07 -0600
Subject: [LVM PATCH 1/6] pool: Make another thin pool fn generic for cache usage also
In-Reply-To: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
References: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1391212992-3439-2-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Make '_recalculate_thin_pool_chunk_size_with_dev_hints' so it can
be used for cache and thin pools.
---
 conf/example.conf.in         |   11 +++++++++
 lib/config/config_settings.h |    3 ++
 lib/metadata/lv_manip.c      |   52 +++++++++++++++++++++++++++++-------------
 3 files changed, 50 insertions(+), 16 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 7b98b4b..08ce877 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -305,6 +305,17 @@ allocation {
     # placed on  different PVs from the cache_pool data.
     cache_pool_metadata_require_separate_pvs = 0
 
+    # Specify the minimal chunk size (in kiB) for cache pool volumes.
+    # Using a chunk_size that is too large can result in wasteful use of
+    # the cache, where small reads and writes can cause large sections of
+    # an LV to be mapped into the cache.  However, choosing a chunk_size
+    # that is too small can result in more overhead trying to manage the
+    # numerous chunks that become mapped into the cache.  The former is
+    # more of a problem than the latter in most cases, so we default to
+    # a value that is on the smaller end of the spectrum.  Supported values
+    # range from 32(kiB) to 1048576 in multiples of 32.
+    # cache_pool_chunk_size = 64
+
     # Set to 1 to guarantee that thin pool metadata will always
     # be placed on different PVs from the pool data.
     thin_pool_metadata_require_separate_pvs = 0
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e9ae494..ae91e2d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -107,7 +107,10 @@ cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0,
 cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL)
+
 cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL)
+cfg(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 106), NULL)
+
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index bd1e57c..e95b7e5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5628,8 +5628,8 @@ static unsigned long _lcm(unsigned long n1, unsigned long n2)
 	return (n1 * n2) / _gcd(n1, n2);
 }
 
-static int _recalculate_thin_pool_chunk_size_with_dev_hints(struct lvcreate_params *lp,
-							    struct logical_volume *pool_lv)
+static int _recalculate_pool_chunk_size_with_dev_hints(struct lvcreate_params *lp,
+						       struct logical_volume *pool_lv)
 {
 	struct logical_volume *pool_data_lv;
 	struct lv_segment *seg;
@@ -5637,13 +5637,34 @@ static int _recalculate_thin_pool_chunk_size_with_dev_hints(struct lvcreate_para
 	struct cmd_context *cmd = pool_lv->vg->cmd;
 	unsigned long previous_hint = 0, hint = 0;
 	uint32_t chunk_size = lp->chunk_size;
-	uint32_t default_chunk_size = lp->thin_chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE ?
-					DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE*2 : DEFAULT_THIN_POOL_CHUNK_SIZE*2;
+	uint32_t default_chunk_size;
+	uint32_t min_chunk, max_chunk;
 
-	if (lp->passed_args & PASS_ARG_CHUNK_SIZE ||
-	    find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, NULL))
+	if (lp->passed_args & PASS_ARG_CHUNK_SIZE)
 		goto out;
 
+	if (seg_is_thin_pool(lp)) {
+		if (find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, NULL))
+			goto out;
+
+		min_chunk = DM_THIN_MIN_DATA_BLOCK_SIZE;
+		max_chunk = DM_THIN_MAX_DATA_BLOCK_SIZE;
+		if (lp->thin_chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)
+			default_chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE*2;
+		else
+			default_chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE*2;
+	} else if (seg_is_cache_pool(lp)) {
+		if (find_config_tree_int(cmd, allocation_cache_pool_chunk_size_CFG, NULL))
+			goto out;
+		min_chunk = DM_CACHE_MIN_DATA_BLOCK_SIZE;
+		max_chunk = DM_CACHE_MAX_DATA_BLOCK_SIZE;
+		default_chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE*2;
+	} else {
+		log_error(INTERNAL_ERROR "%s is not a thin pool or cache pool",
+			  pool_lv->name);
+		return 0;
+	}
+
 	pool_data_lv = seg_lv(first_seg(pool_lv), 0);
 
 	dm_list_iterate_items(seg, &pool_data_lv->segments) {
@@ -5661,19 +5682,18 @@ static int _recalculate_thin_pool_chunk_size_with_dev_hints(struct lvcreate_para
 	}
 
 	if (!hint) {
-		log_debug_alloc("No usable device hint found while recalculating "
-				"thin pool chunk size for %s.", pool_lv->name);
+		log_debug_alloc("No usable device hint found while recalculating"
+				" thin pool chunk size for %s.", pool_lv->name);
 		goto out;
 	}
 
-	if (hint < DM_THIN_MIN_DATA_BLOCK_SIZE ||
-	    hint > DM_THIN_MAX_DATA_BLOCK_SIZE) {
-		log_debug_alloc("Calculated chunk size value of %ld sectors "
-				"for thin pool %s is out of allowed range (%d-%d).",
-				hint, pool_lv->name, DM_THIN_MIN_DATA_BLOCK_SIZE,
-				DM_THIN_MAX_DATA_BLOCK_SIZE);
+	if ((hint < min_chunk) || (hint > max_chunk)) {
+		log_debug_alloc("Calculated chunk size value of %ld sectors for"
+				" thin pool %s is out of allowed range (%d-%d).",
+				hint, pool_lv->name, min_chunk, max_chunk);
 	} else
-		chunk_size = hint >= default_chunk_size ? hint : default_chunk_size;
+		chunk_size = (hint >= default_chunk_size) ?
+			hint : default_chunk_size;
 out:
 	first_seg(pool_lv)->chunk_size = chunk_size;
 	return 1;
@@ -5989,7 +6009,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return_NULL;
 
 	if (seg_is_thin_pool(lp)) {
-		if (!_recalculate_thin_pool_chunk_size_with_dev_hints(lp, lv))
+		if (!_recalculate_pool_chunk_size_with_dev_hints(lp, lv))
 			return_NULL;
 		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
 		first_seg(lv)->discards = lp->discards;
-- 
1.7.7.6



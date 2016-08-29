From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 29 Aug 2016 19:08:55 +0000 (UTC)
Subject: master - cache: introduce cache_pool_max_chunks
Message-ID: <20160829190855.51C77618AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b493811968b34876ef558ad04d18c1b76bd28113
Commit:        b493811968b34876ef558ad04d18c1b76bd28113
Parent:        2fde4399a01a002437d6d882c7faa59221aca93e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 24 10:16:01 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 29 20:47:31 2016 +0200

cache: introduce cache_pool_max_chunks

Introduce 'hard limit' for max number of cache chunks.
When cache target operates with too many chunks (>10e6).

When user is aware of related possible troubles he
may increase the limit in lvm.conf.

Also verbosely inform user about possible solution.

Code works for both lvcreate and lvconvert.

Lvconvert fully supports change of chunk_size when caching LV
(and validates for compatible settings).
---
 WHATS_NEW                            |    1 +
 lib/config/config.c                  |   22 +++++++++++
 lib/config/config.h                  |    1 +
 lib/config/config_settings.h         |    5 ++
 lib/config/defaults.h                |    1 +
 lib/metadata/cache_manip.c           |   68 ++++++++++++++++++++++++++++++----
 test/shell/lvconvert-cache-chunks.sh |   53 ++++++++++++++++++++++++++
 tools/lvconvert.c                    |   10 ++++-
 8 files changed, 151 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1c0bcf4..76e203d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Add allocation/cache_pool_max_chunks to prevent misuse of cache target.
   Give error not segfault in lvconvert --splitmirrors when PV lies outside LV.
   Fix typo in report/columns_as_rows config option name recognition (2.02.99).
   Avoid PV tags when checking allocation against parallel PVs.
diff --git a/lib/config/config.c b/lib/config/config.c
index 46ef8e7..820a744 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -2461,3 +2461,25 @@ int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, st
 {
 	return DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
 }
+
+uint64_t get_default_allocation_cache_pool_max_chunks_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	static int _warn_max_chunks = 0;
+	/*
+	 * TODO: In future may depend on the cache target version,
+	 *       newer targets may scale better.
+	 */
+	uint64_t default_max_chunks = DEFAULT_CACHE_POOL_MAX_CHUNKS;
+	uint64_t max_chunks = find_config_tree_int(cmd, allocation_cache_pool_max_chunks_CFG, profile);
+
+	if (!max_chunks)
+		max_chunks = default_max_chunks;
+	else if (max_chunks > default_max_chunks)
+		/* Still warn the user when the value is tweaked above recommended level */
+		/* Maybe drop to log_verbose... */
+		log_warn_suppress(_warn_max_chunks++, "WARNING: Configured cache_pool_max_chunks value "
+				  FMTu64 " is higher then recommended " FMTu64 ".",
+				  max_chunks, default_max_chunks);
+
+	return max_chunks;
+}
diff --git a/lib/config/config.h b/lib/config/config.h
index aa95202..f0202b6 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -307,5 +307,6 @@ int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, st
 #define get_default_unconfigured_allocation_cache_pool_chunk_size_CFG NULL
 const char *get_default_allocation_cache_policy_CFG(struct cmd_context *cmd, struct profile *profile);
 #define get_default_unconfigured_allocation_cache_policy_CFG NULL
+uint64_t get_default_allocation_cache_pool_max_chunks_CFG(struct cmd_context *cmd, struct profile *profile);
 
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7401725..9eed969 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -516,6 +516,11 @@ cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", alloc
 	"on the smaller end of the spectrum. Supported values range from\n"
 	"32KiB to 1GiB in multiples of 32.\n")
 
+cfg(allocation_cache_pool_max_chunks_CFG, "cache_pool_max_chunks", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(2, 2, 165), NULL, 0, NULL,
+	"The maximum number of chunks in a cache pool.\n"
+	"For cache target v1.9 the recommended maximumm is 1000000 chunks.\n"
+	"Using cache pool with more chunks may degrade cache performance.\n")
+
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
 	"Thin pool metdata and data will always use different PVs.\n")
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index c6efcdc..d988779 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -127,6 +127,7 @@
 #define DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG "#S" DEFAULT_CACHE_REPAIR_OPTION1
 #define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_CACHE_POOL_CHUNK_SIZE 64 /* KB */
+#define DEFAULT_CACHE_POOL_MAX_CHUNKS 1000000
 #define DEFAULT_CACHE_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_CACHE_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_CACHE_POLICY "mq"
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 275696e..d73142d 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -161,9 +161,40 @@ int update_cache_pool_params(const struct segment_type *segtype,
 	uint64_t min_meta_size;
 	uint32_t extent_size = vg->extent_size;
 	uint64_t pool_metadata_size = (uint64_t) *pool_metadata_extents * extent_size;
-
-	if (!(passed_args & PASS_ARG_CHUNK_SIZE))
+	uint64_t pool_data_size = (uint64_t) pool_data_extents * extent_size;
+	uint64_t max_chunks =
+		get_default_allocation_cache_pool_max_chunks_CFG(vg->cmd, vg->profile);
+	/* min chunk size in a multiple of DM_CACHE_MIN_DATA_BLOCK_SIZE */
+	uint64_t min_chunk_size = (((pool_data_size + max_chunks - 1) / max_chunks +
+				    DM_CACHE_MIN_DATA_BLOCK_SIZE - 1) /
+				   DM_CACHE_MIN_DATA_BLOCK_SIZE) * DM_CACHE_MIN_DATA_BLOCK_SIZE;
+
+	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
 		*chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
+		if (*chunk_size < min_chunk_size) {
+			/*
+			 * When using more then 'standard' default,
+			 * keep user informed he might be using things in untintended direction
+			 */
+			log_print_unless_silent("Using %s chunk size instead of default %s, "
+						"so cache pool has less then " FMTu64 " chunks.",
+						display_size(vg->cmd, min_chunk_size),
+						display_size(vg->cmd, *chunk_size),
+						max_chunks);
+			*chunk_size = min_chunk_size;
+		} else
+			log_verbose("Setting chunk size to %s.",
+				    display_size(vg->cmd, *chunk_size));
+	} else if (*chunk_size < min_chunk_size) {
+		log_error("Chunk size %s is less then required minimal chunk size %s "
+			  "for a cache pool of %s size and limit " FMTu64 " chunks.",
+			  display_size(vg->cmd, *chunk_size),
+			  display_size(vg->cmd, min_chunk_size),
+			  display_size(vg->cmd, pool_data_size),
+			  max_chunks);
+		log_error("To allow use of more chunks, see setting allocation/cache_pool_max_chunks.");
+		return 0;
+	}
 
 	if (!validate_pool_chunk_size(vg->cmd, segtype, *chunk_size))
 		return_0;
@@ -204,18 +235,39 @@ int update_cache_pool_params(const struct segment_type *segtype,
  */
 int validate_lv_cache_chunk_size(struct logical_volume *pool_lv, uint32_t chunk_size)
 {
+	struct volume_group *vg = pool_lv->vg;
+	uint64_t max_chunks = get_default_allocation_cache_pool_max_chunks_CFG(vg->cmd, vg->profile);
 	uint64_t min_size = _cache_min_metadata_size(pool_lv->size, chunk_size);
+	uint64_t chunks = pool_lv->size / chunk_size;
+	int r = 1;
 
 	if (min_size > first_seg(pool_lv)->metadata_lv->size) {
-		log_error("Cannot use chunk size %s with cache pool %s. "
-			  "Minimal required size for metadata is %s.",
-			  display_size(pool_lv->vg->cmd, chunk_size),
+		log_error("Cannot use chunk size %s with cache pool %s metadata size %s.",
+			  display_size(vg->cmd, chunk_size),
 			  display_lvname(pool_lv),
-			  display_size(pool_lv->vg->cmd, min_size));
-		return 0;
+			  display_size(vg->cmd, first_seg(pool_lv)->metadata_lv->size));
+		log_error("Minimal size for cache pool %s metadata with chunk size %s would be %s.",
+			  display_lvname(pool_lv),
+			  display_size(vg->cmd, chunk_size),
+			  display_size(vg->cmd, min_size));
+		r = 0;
 	}
 
-	return 1;
+	if (chunks > max_chunks) {
+		log_error("Cannot use too small chunk size %s with cache pool %s data volume size %s.",
+			  display_size(vg->cmd, chunk_size),
+			  display_lvname(pool_lv),
+			  display_size(pool_lv->vg->cmd, pool_lv->size));
+		log_error("Maximum configured chunks for a cache pool is " FMTu64 ".",
+			  max_chunks);
+		log_error("Use smaller cache pool (<%s) or bigger cache chunk size (>=%s) or enable higher "
+			  "values in 'allocation/cache_pool_max_chunks'.",
+			  display_size(vg->cmd, chunk_size * max_chunks),
+			  display_size(vg->cmd, pool_lv->size / max_chunks));
+		r = 0;
+	}
+
+	return r;
 }
 /*
  * Validate arguments for converting origin into cached volume with given cache pool.
diff --git a/test/shell/lvconvert-cache-chunks.sh b/test/shell/lvconvert-cache-chunks.sh
new file mode 100644
index 0000000..806db0f
--- /dev/null
+++ b/test/shell/lvconvert-cache-chunks.sh
@@ -0,0 +1,53 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise number of cache chunks in cache pool
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 2 1000000
+
+# Really large cache pool data LV
+lvcreate -L1T -n cpool $vg
+
+# Works and pick higher chunks size then default
+lvconvert -y --type cache-pool $vg/cpool
+
+# Check chunk size in sectors is more then 512K
+test $(get lv_field $vg/cpool chunk_size --units s --nosuffix) -gt 1000
+
+lvcreate -L1M -n $lv1 $vg
+
+# Not let pass small chunks when caching origin
+fail lvconvert -H --chunksize 128K --cachepool $vg/cpool $vg/$lv1
+
+# Though 2M is valid
+lvconvert -y -H  --chunksize 2M --cachepool $vg/cpool $vg/$lv1
+
+lvremove -f $vg
+
+###
+
+# Really large cache pool data LV
+lvcreate -L1T -n cpool $vg
+# Not allowed to create more then 10e6 chunks
+fail lvconvert -y --type cache-pool --chunksize 128K $vg/cpool
+
+# Let operation pass when max_chunk limit is raised
+lvconvert -y --type cache-pool --chunksize 128K $vg/cpool \
+	--config 'allocation/cache_pool_max_chunks=10000000'
+
+vgremove -f $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 457724c..d1d21b6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3037,16 +3037,22 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 
 		if (!metadata_lv) {
 			if (arg_from_list_is_set(cmd, "is invalid with existing pool",
-						 chunksize_ARG, discards_ARG,
+						 discards_ARG,
 						 poolmetadatasize_ARG, -1))
 				return_0;
 
 			if (lp->thin &&
 			    arg_from_list_is_set(cmd, "is invalid with existing thin pool",
-						 zero_ARG, -1))
+						 chunksize_ARG, zero_ARG, -1))
 				return_0;
 
 			if (lp->cache) {
+				if (!lp->chunk_size)
+					lp->chunk_size = first_seg(pool_lv)->chunk_size;
+
+				if (!validate_lv_cache_chunk_size(pool_lv, lp->chunk_size))
+					return_0;
+
 				/* Check is user requested zeroing logic via [-Z y|n] */
 				if (!arg_is_set(cmd, zero_ARG)) {
 					/* Note: requires rather deep know-how to skip zeroing */



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:44 -0500
Subject: master - cache: improve support for profile for cache settings
Message-ID: <201703101835.v2AIZiRT019042@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dcf038c7a616cb415ea55e3d19a1c1ee0d0086b9
Commit:        dcf038c7a616cb415ea55e3d19a1c1ee0d0086b9
Parent:        c598e65de988663d2174f9d9b00408a1d50a075e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 5 17:42:15 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

cache: improve support for profile for cache settings

User can specify metadata profile which stores important cache
geometry data for easy configuration.

Fix missing support for getting chunk_size, cache_mode, cache_policy
for a cache/cache pools volumes from configuration or metadata profile.
---
 WHATS_NEW                    |    2 ++
 lib/config/config_settings.h |   16 ++++++++--------
 lib/metadata/cache_manip.c   |   22 ++++++++++++++++------
 3 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 63cc2d2..da541d2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.169 - 
 =====================================
+  Fix metadata profile allocation/cache_[mode|policy] setting.
+  Fix missing support for using allocation/cache_pool_chunk_size setting.
   Upstream git moved to https://sourceware.org/git/?p=lvm2
   Support conversion of raid type, stripesize and number of disks
   Reject writemostly/writebehind in lvchange during resynchronization.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 2b76526..6a01a97 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -473,14 +473,14 @@ cfg(allocation_raid_stripe_all_devices_CFG, "raid_stripe_all_devices", allocatio
 	"when the command does not specify the number of stripes to use.\n"
 	"This was the default behaviour until release 2.02.162.\n")
 
-cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
+cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
 	"Cache pool metadata and data will always use different PVs.\n")
 
-cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_MODE, vsn(2, 2, 113), NULL, vsn(2, 2, 128),
+cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_MODE, vsn(2, 2, 113), NULL, vsn(2, 2, 128),
 	"This has been replaced by the allocation/cache_mode setting.\n",
 	"Cache mode.\n")
 
-cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_MODE, vsn(2, 2, 128), NULL, 0, NULL,
+cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_MODE, vsn(2, 2, 128), NULL, 0, NULL,
 	"The default cache mode used for new cache.\n"
 	"#\n"
 	"Accepted values:\n"
@@ -492,20 +492,20 @@ cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_PROFILA
 	"#\n"
 	"This setting replaces allocation/cache_pool_cachemode.\n")
 
-cfg(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, 0, vsn(2, 2, 128), NULL, 0, NULL,
+cfg(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, 0, vsn(2, 2, 128), NULL, 0, NULL,
 	"The default cache policy used for new cache volume.\n"
 	"Since kernel 4.2 the default policy is smq (Stochastic multique),\n"
 	"otherwise the older mq (Multiqueue) policy is selected.\n")
 
-cfg_section(allocation_cache_settings_CFG_SECTION, "cache_settings", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 128), 0, NULL,
+cfg_section(allocation_cache_settings_CFG_SECTION, "cache_settings", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, vsn(2, 2, 128), 0, NULL,
 	"Settings for the cache policy.\n"
 	"See documentation for individual cache policies for more info.\n")
 
-cfg_section(policy_settings_CFG_SUBSECTION, "policy_settings", allocation_cache_settings_CFG_SECTION, CFG_NAME_VARIABLE | CFG_SECTION_NO_CHECK | CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 128), 0, NULL,
+cfg_section(policy_settings_CFG_SUBSECTION, "policy_settings", allocation_cache_settings_CFG_SECTION, CFG_NAME_VARIABLE | CFG_SECTION_NO_CHECK | CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, vsn(2, 2, 128), 0, NULL,
 	"Replace this subsection name with a policy name.\n"
 	"Multiple subsections for different policies can be created.\n")
 
-cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), 0, NULL,
+cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), 0, NULL,
 	"The minimal chunk size in KiB for cache pool volumes.\n"
 	"Using a chunk_size that is too large can result in wasteful use of\n"
 	"the cache, where small reads and writes can cause large sections of\n"
@@ -516,7 +516,7 @@ cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", alloc
 	"on the smaller end of the spectrum. Supported values range from\n"
 	"32KiB to 1GiB in multiples of 32.\n")
 
-cfg(allocation_cache_pool_max_chunks_CFG, "cache_pool_max_chunks", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(2, 2, 165), NULL, 0, NULL,
+cfg(allocation_cache_pool_max_chunks_CFG, "cache_pool_max_chunks", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(2, 2, 165), NULL, 0, NULL,
 	"The maximum number of chunks in a cache pool.\n"
 	"For cache target v1.9 the recommended maximumm is 1000000 chunks.\n"
 	"Using cache pool with more chunks may degrade cache performance.\n")
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index eb4ebfe..92f368e 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -77,6 +77,7 @@ int set_cache_mode(cache_mode_t *mode, const char *cache_mode)
 int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode)
 {
 	struct cmd_context *cmd = seg->lv->vg->cmd;
+	struct profile *profile = seg->lv->profile;
 	const char *str;
 	int id;
 
@@ -107,7 +108,7 @@ int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode)
 	    find_config_node(cmd, cmd->cft, allocation_cache_pool_cachemode_CFG))
 		id = allocation_cache_pool_cachemode_CFG;
 
-	if (!(str = find_config_tree_str(cmd, id, NULL))) {
+	if (!(str = find_config_tree_str(cmd, id, profile))) {
 		log_error(INTERNAL_ERROR "Cache mode is not determined.");
 		return 0;
 	}
@@ -162,7 +163,7 @@ int update_cache_pool_params(const struct segment_type *segtype,
 	uint32_t extent_size = vg->extent_size;
 	uint64_t pool_metadata_size = (uint64_t) *pool_metadata_extents * extent_size;
 	uint64_t pool_data_size = (uint64_t) pool_data_extents * extent_size;
-	uint64_t max_chunks =
+	const uint64_t max_chunks =
 		get_default_allocation_cache_pool_max_chunks_CFG(vg->cmd, vg->profile);
 	/* min chunk size in a multiple of DM_CACHE_MIN_DATA_BLOCK_SIZE */
 	uint64_t min_chunk_size = (((pool_data_size + max_chunks - 1) / max_chunks +
@@ -170,7 +171,10 @@ int update_cache_pool_params(const struct segment_type *segtype,
 				   DM_CACHE_MIN_DATA_BLOCK_SIZE) * DM_CACHE_MIN_DATA_BLOCK_SIZE;
 
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
-		*chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE * 2;
+		if (!(*chunk_size = find_config_tree_int(vg->cmd, allocation_cache_pool_chunk_size_CFG,
+							 vg->profile) * 2))
+			*chunk_size = get_default_allocation_cache_pool_chunk_size_CFG(vg->cmd,
+										       vg->profile);
 		if (*chunk_size < min_chunk_size) {
 			/*
 			 * When using more then 'standard' default,
@@ -236,7 +240,7 @@ int update_cache_pool_params(const struct segment_type *segtype,
 int validate_lv_cache_chunk_size(struct logical_volume *pool_lv, uint32_t chunk_size)
 {
 	struct volume_group *vg = pool_lv->vg;
-	uint64_t max_chunks = get_default_allocation_cache_pool_max_chunks_CFG(vg->cmd, vg->profile);
+	const uint64_t max_chunks = get_default_allocation_cache_pool_max_chunks_CFG(vg->cmd, pool_lv->profile);
 	uint64_t min_size = _cache_min_metadata_size(pool_lv->size, chunk_size);
 	uint64_t chunks = pool_lv->size / chunk_size;
 	int r = 1;
@@ -394,6 +398,9 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 	if (!attach_pool_lv(seg, pool_lv, NULL, NULL, NULL))
 		return_NULL;
 
+	if (!seg->lv->profile) /* Inherit profile from cache-pool */
+		seg->lv->profile = seg->pool_lv->profile;
+
 	return cache_lv;
 }
 
@@ -665,6 +672,7 @@ int cache_set_policy(struct lv_segment *seg, const char *name,
 	struct dm_config_tree *old = NULL, *new = NULL, *tmp = NULL;
 	int r = 0;
 	const int passed_seg_is_cache = seg_is_cache(seg);
+	struct profile *profile = seg->lv->profile;
 
 	if (passed_seg_is_cache)
 		seg = first_seg(seg->pool_lv);
@@ -675,7 +683,8 @@ int cache_set_policy(struct lv_segment *seg, const char *name,
 			return 0;
 		}
 	} else if (!seg->policy_name && passed_seg_is_cache) {
-		if (!(seg->policy_name = find_config_tree_str(seg->lv->vg->cmd, allocation_cache_policy_CFG, NULL)) &&
+		if (!(seg->policy_name = find_config_tree_str(seg->lv->vg->cmd, allocation_cache_policy_CFG,
+							      profile)) &&
 		    !(seg->policy_name = _get_default_cache_policy(seg->lv->vg->cmd)))
 			return_0;
 	}
@@ -702,7 +711,8 @@ int cache_set_policy(struct lv_segment *seg, const char *name,
 		    !(seg->policy_settings = dm_config_clone_node_with_mem(seg->lv->vg->vgmem, cn, 0)))
 			goto_out;
 	} else if (passed_seg_is_cache && /* Look for command's profile cache_policies */
-		   (cns = find_config_tree_node(seg->lv->vg->cmd, allocation_cache_settings_CFG_SECTION, NULL))) {
+		   (cns = find_config_tree_node(seg->lv->vg->cmd, allocation_cache_settings_CFG_SECTION,
+						seg->lv->profile))) {
 		/* Try to find our section for given policy */
 		for (cn = cns->child; cn; cn = cn->sib) {
 			/* Only matching section names */



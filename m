From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 1 Mar 2017 12:59:27 -0500
Subject: master - lvconvert: libdm RAID API compatibility versioning; remove new function
Message-ID: <201703011759.v21HxRTO000782@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb42874a4f4b5e69a930be7b39c4ca9ad9e7e47f
Commit:        fb42874a4f4b5e69a930be7b39c4ca9ad9e7e47f
Parent:        48778bc5038f0384bf0e6ad43bac048f6700637b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Mar 1 18:58:48 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Mar 1 18:58:48 2017 +0100

lvconvert: libdm RAID API compatibility versioning; remove new function

Commit 80a6de616a19 versioned the dm_tree_node_add_raid_target_with_params()
and dm_tree_node_add_raid_target() APIs for compatibility reasons.

There's no user of the latter function, remove it.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 libdm/.exported_symbols.DM_1_02_138 |    1 -
 libdm/libdevmapper.h                |    9 ---------
 libdm/libdm-deptree.c               |   20 --------------------
 3 files changed, 0 insertions(+), 30 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_138 b/libdm/.exported_symbols.DM_1_02_138
index 43e4111..6d658b9 100644
--- a/libdm/.exported_symbols.DM_1_02_138
+++ b/libdm/.exported_symbols.DM_1_02_138
@@ -3,5 +3,4 @@ dm_bit_get_prev
 dm_stats_update_regions_from_fd
 dm_bitset_parse_list
 dm_stats_bind_from_fd
-dm_tree_node_add_raid_target_v2
 dm_tree_node_add_raid_target_with_params_v2
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index b515f6d..e1dc5a4 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1723,15 +1723,6 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 				 uint64_t rebuilds,
 				 uint64_t flags);
 
-/* Version 2 coping with 253 (MD kernel limitation) devices */
-int dm_tree_node_add_raid_target_v2(struct dm_tree_node *node,
-				    uint64_t size,
-				    const char *raid_type,
-				    uint32_t region_size,
-				    uint32_t stripe_size,
-				    uint64_t *rebuilds,
-				    uint64_t flags);
-
 /*
  * Defines below are based on kernel's dm-cache.c defines
  * DM_CACHE_MIN_DATA_BLOCK_SIZE (32 * 1024 >> SECTOR_SHIFT)
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 79117d2..a78fbcc 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3386,26 +3386,6 @@ int dm_tree_node_add_raid_target_with_params_v2(struct dm_tree_node *node,
 	return 1;
 }
 
-int dm_tree_node_add_raid_target_v2(struct dm_tree_node *node,
-				    uint64_t size,
-				    const char *raid_type,
-				    uint32_t region_size,
-				    uint32_t stripe_size,
-				    uint64_t *rebuilds,
-				    uint64_t flags)
-{
-	struct dm_tree_node_raid_params_v2 params = {
-		.raid_type = raid_type,
-		.region_size = region_size,
-		.stripe_size = stripe_size,
-		.flags = flags
-	};
-
-	memcpy(params.rebuilds, rebuilds, sizeof(params.rebuilds));
-
-	return dm_tree_node_add_raid_target_with_params_v2(node, size, &params);
-}
-
 int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint64_t size,
 				  uint64_t feature_flags, /* DM_CACHE_FEATURE_* */



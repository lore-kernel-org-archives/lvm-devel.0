From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 29 Jan 2014 08:01:07 +0000 (UTC)
Subject: master - cleanup: fix cut&paste and move initialization
Message-ID: <20140129080107.64C02616A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a1e1d0d398ad5ca32092047738ce6f7624837e9
Commit:        5a1e1d0d398ad5ca32092047738ce6f7624837e9
Parent:        e9d9852c55cbc2c509c293691287fa5443868926
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 29 08:58:50 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 29 09:00:16 2014 +0100

cleanup: fix cut&paste and move initialization

Use C initializers and fix cut&paste core_arg error.

(in release fix)
---
 lib/cache_segtype/cache.c |   27 ++++++++++++---------------
 1 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index c12ac2f..bfc84c3 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -343,19 +343,24 @@ static int _cache_add_target_line(struct dev_manager *dm,
 				 struct dm_tree_node *node, uint64_t len,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
-	struct lv_segment *cache_pool_seg;
 	struct logical_volume *data, *metadata, *origin;
-	struct dm_tree_node_cache_params params;
+	struct lv_segment *cache_pool_seg = first_seg(seg->pool_lv);
+	struct dm_tree_node_cache_params params = {
+		.chunk_size = cache_pool_seg->chunk_size,
+
+		/* Cache features, core args, and policy are stored in the cache_pool */
+		.feature_flags = cache_pool_seg->feature_flags,
+		.core_argc = cache_pool_seg->core_argc,
+		.core_argv = cache_pool_seg->core_argv,
+		.policy_name = cache_pool_seg->policy_name,
+		.policy_argc = cache_pool_seg->policy_argc,
+		.policy_argv = cache_pool_seg->policy_argv
+	};
 
-	cache_pool_seg = first_seg(seg->pool_lv);
 	data = seg_lv(cache_pool_seg, 0);
 	metadata = cache_pool_seg->metadata_lv;
 	origin = seg_lv(seg, 0);
 
-	memset(&params, 0, sizeof(params));
-
-	params.chunk_size = cache_pool_seg->chunk_size;
-
 	if (!(params.data_uuid = build_dm_uuid(mem, data->lvid.s, NULL)))
 		return_0;
 
@@ -365,14 +370,6 @@ static int _cache_add_target_line(struct dev_manager *dm,
 	if (!(params.origin_uuid = build_dm_uuid(mem, origin->lvid.s, NULL)))
 		return_0;
 
-	/* Cache features, core args, and policy are stored in the cache_pool */
-	params.feature_flags = cache_pool_seg->feature_flags;
-	params.policy_argc = cache_pool_seg->core_argc;
-	params.policy_argv = cache_pool_seg->core_argv;
-	params.policy_name = cache_pool_seg->policy_name;
-	params.policy_argc = cache_pool_seg->policy_argc;
-	params.policy_argv = cache_pool_seg->policy_argv;
-
 	if (!dm_tree_node_add_cache_target(node, len, &params))
 		return_0;
 



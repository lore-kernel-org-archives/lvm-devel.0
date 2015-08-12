From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:14 +0000 (UTC)
Subject: master - libdm: rename to data_block_size
Message-ID: <20150812124114.CCB8B60072@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79e9bde0ea37abe04afa970972c6bf0504706766
Commit:        79e9bde0ea37abe04afa970972c6bf0504706766
Parent:        08f047eb51375f6b96b0612e766cc9e0edae6ca0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 11 13:30:02 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:33:15 2015 +0200

libdm: rename to data_block_size

Use common name for pool device - as we use data_block_size
for thin pool metadata, use same name for cache_pool.

This change does not affect API.
---
 libdm/libdevmapper.h  |    2 +-
 libdm/libdm-deptree.c |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 1be8e4f..18df90a 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1308,7 +1308,7 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  const char *origin_uuid,
 				  const char *policy_name,
 				  const struct dm_config_node *policy_settings,
-				  uint32_t chunk_size);
+				  uint32_t data_block_size);
 
 /*
  * FIXME Add individual cache policy pairs  <key> = value, like:
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index bbbd2d8..040a826 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -159,7 +159,7 @@ struct load_segment {
 	uint32_t stripe_size;		/* Striped + raid */
 
 	int persistent;			/* Snapshot */
-	uint32_t chunk_size;		/* Snapshot + cache */
+	uint32_t chunk_size;		/* Snapshot */
 	struct dm_tree_node *cow;	/* Snapshot */
 	struct dm_tree_node *origin;	/* Snapshot + Snapshot origin + Cache */
 	struct dm_tree_node *merge;	/* Snapshot */
@@ -200,7 +200,7 @@ struct load_segment {
 	struct dm_list thin_messages;	/* Thin_pool */
 	uint64_t transaction_id;	/* Thin_pool */
 	uint64_t low_water_mark;	/* Thin_pool */
-	uint32_t data_block_size;       /* Thin_pool */
+	uint32_t data_block_size;       /* Thin_pool + cache */
 	unsigned skip_block_zeroing;	/* Thin_pool */
 	unsigned ignore_discard;	/* Thin_pool target vsn 1.1 */
 	unsigned no_discard_passdown;	/* Thin_pool target vsn 1.1 */
@@ -2429,8 +2429,8 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 
 	EMIT_PARAMS(pos, " %s %s %s", metadata, data, origin);
 
-	/* Chunk size */
-	EMIT_PARAMS(pos, " %u", seg->chunk_size);
+	/* Data block size */
+	EMIT_PARAMS(pos, " %u", seg->data_block_size);
 
 	/* Features */
 	/* feature_count = hweight32(seg->flags); */
@@ -3353,7 +3353,7 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  const char *origin_uuid,
 				  const char *policy_name,
 				  const struct dm_config_node *policy_settings,
-				  uint32_t chunk_size)
+				  uint32_t data_block_size)
 {
 	struct dm_config_node *cn;
 	struct load_segment *seg;
@@ -3415,7 +3415,7 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	if (!_link_tree_nodes(node, seg->origin))
 		return_0;
 
-	seg->chunk_size = chunk_size;
+	seg->data_block_size = data_block_size;
 	seg->flags = feature_flags;
 	seg->policy_name = policy_name;
 



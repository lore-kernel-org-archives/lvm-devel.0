From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Feb 2014 10:39:03 +0000 (UTC)
Subject: master - cleanup: indent spaces
Message-ID: <20140215103903.61CAC60E70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a508786664f225d22c3549739abe7a749fc10960
Commit:        a508786664f225d22c3549739abe7a749fc10960
Parent:        c651c614ec758702cc63a8ac96aac1ddfd45a067
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 14 20:46:55 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 15 11:36:53 2014 +0100

cleanup: indent spaces

---
 libdm/libdevmapper.h  |   66 ++++++++++++++++++++++++------------------------
 libdm/libdm-deptree.c |   52 +++++++++++++++++++-------------------
 2 files changed, 59 insertions(+), 59 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index cbd86d4..dd57457 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -557,10 +557,10 @@ struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *tree,
  * Set major and minor to 0 or uuid to NULL to get the root node.
  */
 struct dm_tree_node *dm_tree_find_node(struct dm_tree *tree,
-					  uint32_t major,
-					  uint32_t minor);
+				       uint32_t major,
+				       uint32_t minor);
 struct dm_tree_node *dm_tree_find_node_by_uuid(struct dm_tree *tree,
-						  const char *uuid);
+					       const char *uuid);
 
 /*
  * Use this to walk through all children of a given node.
@@ -592,8 +592,8 @@ int dm_tree_node_num_children(const struct dm_tree_node *node, uint32_t inverted
  * Ignores devices that don't have a uuid starting with uuid_prefix.
  */
 int dm_tree_deactivate_children(struct dm_tree_node *dnode,
-				   const char *uuid_prefix,
-				   size_t uuid_prefix_len);
+				const char *uuid_prefix,
+				size_t uuid_prefix_len);
 /*
  * Preload/create a device plus all dependencies.
  * Ignores devices that don't have a uuid starting with uuid_prefix.
@@ -615,8 +615,8 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
  * Ignores devices that don't have a uuid starting with uuid_prefix.
  */
 int dm_tree_suspend_children(struct dm_tree_node *dnode,
-				   const char *uuid_prefix,
-				   size_t uuid_prefix_len);
+			     const char *uuid_prefix,
+			     size_t uuid_prefix_len);
 
 /*
  * Skip the filesystem sync when suspending.
@@ -646,36 +646,36 @@ void dm_tree_retry_remove(struct dm_tree_node *dnode);
  * Returns 1 if the tree walk has to be aborted.
  */
 int dm_tree_children_use_uuid(struct dm_tree_node *dnode,
-				 const char *uuid_prefix,
-				 size_t uuid_prefix_len);
+			      const char *uuid_prefix,
+			      size_t uuid_prefix_len);
 
 /*
  * Construct tables for new nodes before activating them.
  */
 int dm_tree_node_add_snapshot_origin_target(struct dm_tree_node *dnode,
-					       uint64_t size,
-					       const char *origin_uuid);
+					    uint64_t size,
+					    const char *origin_uuid);
 int dm_tree_node_add_snapshot_target(struct dm_tree_node *node,
-					uint64_t size,
-					const char *origin_uuid,
-					const char *cow_uuid,
-					int persistent,
-					uint32_t chunk_size);
+				     uint64_t size,
+				     const char *origin_uuid,
+				     const char *cow_uuid,
+				     int persistent,
+				     uint32_t chunk_size);
 int dm_tree_node_add_snapshot_merge_target(struct dm_tree_node *node,
-					     uint64_t size,
-					     const char *origin_uuid,
-					     const char *cow_uuid,
-					     const char *merge_uuid,
-					     uint32_t chunk_size);
+					   uint64_t size,
+					   const char *origin_uuid,
+					   const char *cow_uuid,
+					   const char *merge_uuid,
+					   uint32_t chunk_size);
 int dm_tree_node_add_error_target(struct dm_tree_node *node,
-				     uint64_t size);
+				  uint64_t size);
 int dm_tree_node_add_zero_target(struct dm_tree_node *node,
-				    uint64_t size);
+				 uint64_t size);
 int dm_tree_node_add_linear_target(struct dm_tree_node *node,
-				      uint64_t size);
+				   uint64_t size);
 int dm_tree_node_add_striped_target(struct dm_tree_node *node,
-				       uint64_t size,
-				       uint32_t stripe_size);
+				    uint64_t size,
+				    uint32_t stripe_size);
 
 #define DM_CRYPT_IV_DEFAULT	UINT64_C(-1)	/* iv_offset == seg offset */
 /*
@@ -692,7 +692,7 @@ int dm_tree_node_add_crypt_target(struct dm_tree_node *node,
 				  uint64_t iv_offset,
 				  const char *key);
 int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
-				      uint64_t size);
+				   uint64_t size);
  
 /* Mirror log flags */
 #define DM_NOSYNC		0x00000001	/* Known already in sync */
@@ -701,11 +701,11 @@ int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 #define DM_CORELOG		0x00000008	/* In-memory log */
 
 int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
-					  uint32_t region_size,
-					  unsigned clustered,
-					  const char *log_uuid,
-					  unsigned area_count,
-					  uint32_t flags);
+				       uint32_t region_size,
+				       unsigned clustered,
+				       const char *log_uuid,
+				       unsigned area_count,
+				       uint32_t flags);
 
 int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 				 uint64_t size,
@@ -1149,7 +1149,7 @@ void dm_hash_remove(struct dm_hash_table *t, const char *key);
 
 void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key, uint32_t len);
 int dm_hash_insert_binary(struct dm_hash_table *t, const void *key, uint32_t len,
-		       void *data);
+			  void *data);
 void dm_hash_remove_binary(struct dm_hash_table *t, const void *key, uint32_t len);
 
 unsigned dm_hash_get_num_entries(struct dm_hash_table *t);
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 0834f38..6d45e08 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -538,7 +538,7 @@ static struct dm_tree_node *_find_dm_tree_node(struct dm_tree *dtree,
 	dev_t dev = MKDEV((dev_t)major, minor);
 
 	return dm_hash_lookup_binary(dtree->devs, (const char *) &dev,
-				  sizeof(dev));
+				     sizeof(dev));
 }
 
 static struct dm_tree_node *_find_dm_tree_node_by_uuid(struct dm_tree *dtree,
@@ -707,8 +707,8 @@ static int _children_suspended(struct dm_tree_node *node,
  * Set major and minor to zero for root of tree.
  */
 struct dm_tree_node *dm_tree_find_node(struct dm_tree *dtree,
-					  uint32_t major,
-					  uint32_t minor)
+				       uint32_t major,
+				       uint32_t minor)
 {
 	if (!major && !minor)
 		return &dtree->root;
@@ -720,7 +720,7 @@ struct dm_tree_node *dm_tree_find_node(struct dm_tree *dtree,
  * Set uuid to NULL for root of tree.
  */
 struct dm_tree_node *dm_tree_find_node_by_uuid(struct dm_tree *dtree,
-						  const char *uuid)
+					       const char *uuid)
 {
 	if (!uuid || !*uuid)
 		return &dtree->root;
@@ -2801,8 +2801,8 @@ static struct load_segment *_add_segment(struct dm_tree_node *dnode, unsigned ty
 }
 
 int dm_tree_node_add_snapshot_origin_target(struct dm_tree_node *dnode,
-					       uint64_t size,
-					       const char *origin_uuid)
+					    uint64_t size,
+					    const char *origin_uuid)
 {
 	struct load_segment *seg;
 	struct dm_tree_node *origin_node;
@@ -2832,12 +2832,12 @@ int dm_tree_node_add_snapshot_origin_target(struct dm_tree_node *dnode,
 }
 
 static int _add_snapshot_target(struct dm_tree_node *node,
-				   uint64_t size,
-				   const char *origin_uuid,
-				   const char *cow_uuid,
-				   const char *merge_uuid,
-				   int persistent,
-				   uint32_t chunk_size)
+				uint64_t size,
+				const char *origin_uuid,
+				const char *cow_uuid,
+				const char *merge_uuid,
+				int persistent,
+				uint32_t chunk_size)
 {
 	struct load_segment *seg;
 	struct dm_tree_node *origin_node, *cow_node, *merge_node;
@@ -2950,7 +2950,7 @@ int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
 }
 
 int dm_tree_node_add_error_target(struct dm_tree_node *node,
-				     uint64_t size)
+				  uint64_t size)
 {
 	if (!_add_segment(node, SEG_ERROR, size))
 		return_0;
@@ -2959,7 +2959,7 @@ int dm_tree_node_add_error_target(struct dm_tree_node *node,
 }
 
 int dm_tree_node_add_zero_target(struct dm_tree_node *node,
-				    uint64_t size)
+				 uint64_t size)
 {
 	if (!_add_segment(node, SEG_ZERO, size))
 		return_0;
@@ -2968,7 +2968,7 @@ int dm_tree_node_add_zero_target(struct dm_tree_node *node,
 }
 
 int dm_tree_node_add_linear_target(struct dm_tree_node *node,
-				      uint64_t size)
+				   uint64_t size)
 {
 	if (!_add_segment(node, SEG_LINEAR, size))
 		return_0;
@@ -2977,8 +2977,8 @@ int dm_tree_node_add_linear_target(struct dm_tree_node *node,
 }
 
 int dm_tree_node_add_striped_target(struct dm_tree_node *node,
-				       uint64_t size,
-				       uint32_t stripe_size)
+				    uint64_t size,
+				    uint32_t stripe_size)
 {
 	struct load_segment *seg;
 
@@ -3013,11 +3013,11 @@ int dm_tree_node_add_crypt_target(struct dm_tree_node *node,
 }
 
 int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
-					  uint32_t region_size,
-					  unsigned clustered,
-					  const char *log_uuid,
-					  unsigned area_count,
-					  uint32_t flags)
+				       uint32_t region_size,
+				       unsigned clustered,
+				       const char *log_uuid,
+				       unsigned area_count,
+				       uint32_t flags)
 {
 	struct dm_tree_node *log_node = NULL;
 	struct load_segment *seg;
@@ -3065,7 +3065,7 @@ int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 }
 
 int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
-				      uint64_t size)
+				   uint64_t size)
 {
 	if (!_add_segment(node, SEG_MIRRORED, size))
 		return_0;
@@ -3887,9 +3887,9 @@ static int _add_area(struct dm_tree_node *node, struct load_segment *seg, struct
 }
 
 int dm_tree_node_add_target_area(struct dm_tree_node *node,
-				    const char *dev_name,
-				    const char *uuid,
-				    uint64_t offset)
+				 const char *dev_name,
+				 const char *uuid,
+				 uint64_t offset)
 {
 	struct load_segment *seg;
 	struct stat info;



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 13:38:19 +0000 (GMT)
Subject: stable-2.02 - libdm: add dm_tree_node_add_thin_pool_target_v1
Message-ID: <20210201133819.5CCDA3836C59@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5196392bcd1522580f19992397b603cbac077ffb
Commit:        5196392bcd1522580f19992397b603cbac077ffb
Parent:        5e97bc5e6786b2187f5326f35bcb82f47fd999a4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 14:06:31 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 14:32:07 2021 +0100

libdm: add dm_tree_node_add_thin_pool_target_v1

Supports thin-pool without crop.
---
 WHATS_NEW_DM                        |  1 +
 libdm/.exported_symbols.DM_1_02_172 |  1 +
 libdm/libdevmapper.h                | 16 ++++++++++++---
 libdm/libdm-deptree.c               | 39 +++++++++++++++++++++++++++----------
 4 files changed, 44 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 06e65b7d3..188ac8900 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.172 - 
 ==================================
+  Add dm_tree_node_add_thin_pool_target_v1 with crop_metadata support.
   Add support for VDO in blkdeactivate script.
   Try to remove all created devices on dm preload tree error path.
   Fix dm_list interators with gcc 10 optimization (-ftree-pta).
diff --git a/libdm/.exported_symbols.DM_1_02_172 b/libdm/.exported_symbols.DM_1_02_172
new file mode 100644
index 000000000..ed4cce7d6
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_172
@@ -0,0 +1 @@
+dm_tree_node_add_thin_pool_target_v1
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index a61ffe17e..26d64bf4e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1968,10 +1968,10 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 #define DM_THIN_MIN_DATA_BLOCK_SIZE (UINT32_C(128))
 #define DM_THIN_MAX_DATA_BLOCK_SIZE (UINT32_C(2097152))
 /*
- * Max supported size for thin pool  metadata device (17112760320 bytes)
- * Limitation is hardcoded into the kernel and bigger device size
- * is not accepted.
+ * Max supported size for thin pool metadata device (17045913600 bytes)
  * drivers/md/dm-thin-metadata.h THIN_METADATA_MAX_SECTORS
+ * But here DM_THIN_MAX_METADATA_SIZE got defined incorrectly
+ * Correct size is (UINT64_C(255) * ((1 << 14) - 64) * (4096 / (1 << 9)))
  */
 #define DM_THIN_MAX_METADATA_SIZE   (UINT64_C(255) * (1 << 14) * (4096 / (1 << 9)) - 256 * 1024)
 
@@ -1984,6 +1984,16 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t low_water_mark,
 				      unsigned skip_block_zeroing);
 
+int dm_tree_node_add_thin_pool_target_v1(struct dm_tree_node *node,
+					 uint64_t size,
+					 uint64_t transaction_id,
+					 const char *metadata_uuid,
+					 const char *pool_uuid,
+					 uint32_t data_block_size,
+					 uint64_t low_water_mark,
+					 unsigned skip_block_zeroing,
+					 unsigned crop_metadata);
+
 /* Supported messages for thin provision target */
 typedef enum {
 	DM_THIN_MESSAGE_CREATE_SNAP,		/* device_id, origin_id */
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 92f262073..4f71a7008 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3502,6 +3502,24 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint32_t data_block_size,
 				      uint64_t low_water_mark,
 				      unsigned skip_block_zeroing)
+{
+	return dm_tree_node_add_thin_pool_target_v1(node, size, transaction_id,
+						    metadata_uuid, pool_uuid,
+						    data_block_size,
+						    low_water_mark,
+						    skip_block_zeroing,
+						    1);
+}
+
+int dm_tree_node_add_thin_pool_target_v1(struct dm_tree_node *node,
+					 uint64_t size,
+					 uint64_t transaction_id,
+					 const char *metadata_uuid,
+					 const char *pool_uuid,
+					 uint32_t data_block_size,
+					 uint64_t low_water_mark,
+					 unsigned skip_block_zeroing,
+					 unsigned crop_metadata)
 {
 	struct load_segment *seg, *mseg;
 	uint64_t devsize = 0;
@@ -3529,17 +3547,18 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 	if (!_link_tree_nodes(node, seg->metadata))
 		return_0;
 
-	/* FIXME: more complex target may need more tweaks */
-	dm_list_iterate_items(mseg, &seg->metadata->props.segs) {
-		devsize += mseg->size;
-		if (devsize > DM_THIN_MAX_METADATA_SIZE) {
-			log_debug_activation("Ignoring %" PRIu64 " of device.",
-					     devsize - DM_THIN_MAX_METADATA_SIZE);
-			mseg->size -= (devsize - DM_THIN_MAX_METADATA_SIZE);
-			devsize = DM_THIN_MAX_METADATA_SIZE;
-			/* FIXME: drop remaining segs */
+	if (crop_metadata)
+		/* FIXME: more complex target may need more tweaks */
+		dm_list_iterate_items(mseg, &seg->metadata->props.segs) {
+			devsize += mseg->size;
+			if (devsize > DM_THIN_MAX_METADATA_SIZE) {
+				log_debug_activation("Ignoring %" PRIu64 " of device.",
+						     devsize - DM_THIN_MAX_METADATA_SIZE);
+				mseg->size -= (devsize - DM_THIN_MAX_METADATA_SIZE);
+				devsize = DM_THIN_MAX_METADATA_SIZE;
+				/* FIXME: drop remaining segs */
+			}
 		}
-	}
 
 	if (!(seg->pool = dm_tree_find_node_by_uuid(node->dtree, pool_uuid))) {
 		log_error("Missing pool uuid %s.", pool_uuid);



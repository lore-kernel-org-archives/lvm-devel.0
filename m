From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:21:20 +0000 (UTC)
Subject: master - libdm: move thin max size to header
Message-ID: <20130611122120.9EFCF614A2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=861fd1108f4873f549c1e1b852243edcf03493d9
Commit:        861fd1108f4873f549c1e1b852243edcf03493d9
Parent:        9ac0f58ea13dc068806ff1085e0ea06a7840d5fd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 22 15:02:55 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 14:21:00 2013 +0200

libdm: move thin max size to header

Move max size of thin metadata into define.
Increase a bit the size to match the kernel size.
(16978542592->17112760320)
---
 libdm/libdevmapper.h  |    7 +++++++
 libdm/libdm-deptree.c |   15 ++++-----------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index dba8548..bada775 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -749,6 +749,13 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
  */
 #define DM_THIN_MIN_DATA_BLOCK_SIZE (UINT32_C(128))
 #define DM_THIN_MAX_DATA_BLOCK_SIZE (UINT32_C(2097152))
+/*
+ * Max supported size for thin pool  metadata device (17112760320 bytes)
+ * Limitation is hardcoded into the kernel and bigger device size
+ * is not accepted.
+ * drivers/md/dm-thin-metadata.h THIN_METADATA_MAX_SECTORS
+ */
+#define DM_THIN_MAX_METADATA_SIZE   (UINT64_C(255) * (1 << 14) * (4096 / (1 << 9)) - 256 * 1024)
 
 int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t size,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index f8c0d7a..50ed908 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3232,13 +3232,6 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 {
 	struct load_segment *seg, *mseg;
 	uint64_t devsize = 0;
-	/*
-	 * Max supported size for thin pool  metadata device
-	 * Limitation is hardcoded into kernel and bigger
-	 * device size is not accepted. (16978542592)
-	 */
-	const uint64_t max_metadata_size =
-		255ULL * (1 << 14) * (4096 / (1 << 9)) - 256 * 1024;
 
 	if (data_block_size < DM_THIN_MIN_DATA_BLOCK_SIZE) {
 		log_error("Data block size %u is lower then %u sectors.",
@@ -3266,11 +3259,11 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 	/* FIXME: more complex target may need more tweaks */
 	dm_list_iterate_items(mseg, &seg->metadata->props.segs) {
 		devsize += mseg->size;
-		if (devsize > max_metadata_size) {
+		if (devsize > DM_THIN_MAX_METADATA_SIZE) {
 			log_debug_activation("Ignoring %" PRIu64 " of device.",
-					     devsize - max_metadata_size);
-			mseg->size -= (devsize - max_metadata_size);
-			devsize = max_metadata_size;
+					     devsize - DM_THIN_MAX_METADATA_SIZE);
+			mseg->size -= (devsize - DM_THIN_MAX_METADATA_SIZE);
+			devsize = DM_THIN_MAX_METADATA_SIZE;
 			/* FIXME: drop remaining segs */
 		}
 	}



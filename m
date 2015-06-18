From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jun 2015 16:52:35 +0000 (UTC)
Subject: master - libdm: add dm_tree_node_set_thin_pool_read_only
Message-ID: <20150618165235.706FD60F08@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69132f55eafb6a797e86b449783f9cd2f518c3dd
Commit:        69132f55eafb6a797e86b449783f9cd2f518c3dd
Parent:        fd1376ebefa3dd66baff5da161de02b869a734a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 18 15:15:39 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 18 15:15:39 2015 +0200

libdm: add dm_tree_node_set_thin_pool_read_only

Support thin-pool tree node with activation in read-only mode.
(Native kernel API).
---
 WHATS_NEW_DM                       |    1 +
 libdm/.exported_symbols.DM_1_02_99 |    1 +
 libdm/libdevmapper.h               |    3 +++
 libdm/libdm-deptree.c              |   18 +++++++++++++++++-
 4 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dda2777..d87e2bd 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.99 - 
 ================================
+  New dm_tree_node_set_thin_pool_read_only(DM_1_02_99) for read-only thin pool.
   Enhance error message when thin-pool message fails.
 
 Version 1.02.98 - 12th June 2015
diff --git a/libdm/.exported_symbols.DM_1_02_99 b/libdm/.exported_symbols.DM_1_02_99
new file mode 100644
index 0000000..e586a5c
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_99
@@ -0,0 +1 @@
+dm_tree_node_set_thin_pool_read_only
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index c811641..cbd4f3d 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -899,6 +899,9 @@ int dm_tree_node_set_thin_pool_discard(struct dm_tree_node *node,
  */
 int dm_tree_node_set_thin_pool_error_if_no_space(struct dm_tree_node *node,
 						 unsigned error_if_no_space);
+/* Start thin pool with metadata in read-only mode */
+int dm_tree_node_set_thin_pool_read_only(struct dm_tree_node *node,
+					 unsigned read_only);
 /*
  * FIXME: Defines bellow are based on kernel's dm-thin.c defines
  * MAX_DEV_ID ((1 << 24) - 1)
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 1602c62..8428376 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -205,6 +205,7 @@ struct load_segment {
 	unsigned ignore_discard;	/* Thin_pool target vsn 1.1 */
 	unsigned no_discard_passdown;	/* Thin_pool target vsn 1.1 */
 	unsigned error_if_no_space;	/* Thin pool target vsn 1.10 */
+	unsigned read_only;		/* Thin pool target vsn 1.3 */
 	uint32_t device_id;		/* Thin */
 
 };
@@ -2421,6 +2422,7 @@ static int _thin_pool_emit_segment_line(struct dm_task *dmt,
 	int pos = 0;
 	char pool[DM_FORMAT_DEV_BUFSIZE], metadata[DM_FORMAT_DEV_BUFSIZE];
 	int features = (seg->error_if_no_space ? 1 : 0) +
+		 (seg->read_only ? 1 : 0) +
 		 (seg->ignore_discard ? 1 : 0) +
 		 (seg->no_discard_passdown ? 1 : 0) +
 		 (seg->skip_block_zeroing ? 1 : 0);
@@ -2431,9 +2433,10 @@ static int _thin_pool_emit_segment_line(struct dm_task *dmt,
 	if (!_build_dev_string(pool, sizeof(pool), seg->pool))
 		return_0;
 
-	EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %d%s%s%s%s", metadata, pool,
+	EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %d%s%s%s%s%s", metadata, pool,
 		    seg->data_block_size, seg->low_water_mark, features,
 		    seg->error_if_no_space ? " error_if_no_space" : "",
+		    seg->read_only ? " read_only" : "",
 		    seg->skip_block_zeroing ? " skip_block_zeroing" : "",
 		    seg->ignore_discard ? " ignore_discard" : "",
 		    seg->no_discard_passdown ? " no_discard_passdown" : ""
@@ -3866,6 +3869,19 @@ int dm_tree_node_set_thin_pool_error_if_no_space(struct dm_tree_node *node,
 	return 1;
 }
 
+int dm_tree_node_set_thin_pool_read_only(struct dm_tree_node *node,
+					 unsigned read_only)
+{
+	struct load_segment *seg;
+
+	if (!(seg = _get_single_load_segment(node, SEG_THIN_POOL)))
+		return_0;
+
+	seg->read_only = read_only;
+
+	return 1;
+}
+
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
 				 const char *pool_uuid,



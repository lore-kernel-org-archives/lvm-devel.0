From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 7 Dec 2017 15:03:42 -0500
Subject: master - libdm: add help func _get_last_load_segment
Message-ID: <201712072003.vB7K3gJE005630@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a4ea47f709287444f3b0d8e0581ce17e730ef4c
Commit:        4a4ea47f709287444f3b0d8e0581ce17e730ef4c
Parent:        c3e224ad0ebd473268b171204c8985c9c642f590
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 6 13:23:37 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 7 20:59:37 2017 +0100

libdm: add help func _get_last_load_segment

Share code for same functionality.
---
 libdm/libdm-deptree.c |   40 ++++++++++++++++++++++++----------------
 1 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 1ef1700..ef5da59 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1485,6 +1485,16 @@ out:
 	return r;
 }
 
+static struct load_segment *_get_last_load_segment(struct dm_tree_node *node)
+{
+	if (dm_list_empty(&node->props.segs)) {
+		log_error("Node %s is missing a segment.", _node_name(node));
+		return NULL;
+	}
+
+	return dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+}
+
 /* For preload pass only validate pool's transaction_id */
 static int _node_send_messages(struct dm_tree_node *dnode,
 			       const char *uuid_prefix,
@@ -1497,10 +1507,12 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 	const char *uuid;
 	int have_messages;
 
-	if (!dnode->info.exists || (dm_list_size(&dnode->props.segs) != 1))
+	if (!dnode->info.exists)
 		return 1;
 
-	seg = dm_list_item(dm_list_last(&dnode->props.segs), struct load_segment);
+	if (!(seg = _get_last_load_segment(dnode)))
+		return_0;
+
 	if (seg->type != SEG_THIN_POOL)
 		return 1;
 
@@ -3146,12 +3158,8 @@ int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 	struct dm_tree_node *log_node = NULL;
 	struct load_segment *seg;
 
-	if (!node->props.segment_count) {
-		log_error(INTERNAL_ERROR "Attempt to add target area to missing segment.");
-		return 0;
-	}
-
-	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+	if (!(seg = _get_last_load_segment(node)))
+		return_0;
 
 	if (log_uuid) {
 		if (!(seg->uuid = dm_pool_strdup(node->dtree->mem, log_uuid))) {
@@ -3429,13 +3437,16 @@ static struct load_segment *_get_single_load_segment(struct dm_tree_node *node,
 {
 	struct load_segment *seg;
 
+	if (!(seg = _get_last_load_segment(node)))
+		return_NULL;
+
+	/* Never used past _load_node(), so can test segment_count */
 	if (node->props.segment_count != 1) {
 		log_error("Node %s must have only one segment.",
 			  _dm_segtypes[type].target);
 		return NULL;
 	}
 
-	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
 	if (seg->type != type) {
 		log_error("Node %s has segment type %s.",
 			  _dm_segtypes[type].target,
@@ -3741,12 +3752,8 @@ int dm_tree_node_add_target_area(struct dm_tree_node *node,
 			return_0;
 	}
 
-	if (!node->props.segment_count) {
-		log_error(INTERNAL_ERROR "Attempt to add target area to missing segment.");
-		return 0;
-	}
-
-	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+	if (!(seg = _get_last_load_segment(node)))
+		return_0;
 
 	if (!_add_area(node, seg, dev_node, offset))
 		return_0;
@@ -3758,7 +3765,8 @@ int dm_tree_node_add_null_area(struct dm_tree_node *node, uint64_t offset)
 {
 	struct load_segment *seg;
 
-	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+	if (!(seg = _get_last_load_segment(node)))
+		return_0;
 
 	switch (seg->type) {
 	case SEG_RAID0:



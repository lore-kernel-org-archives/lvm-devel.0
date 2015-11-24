From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 24 Nov 2015 10:33:13 +0000 (UTC)
Subject: master - libdm: enhance thin-pool preload
Message-ID: <20151124103313.051E5610DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ca5447e0c65ba6126a005aafeff3dc5c340bb75
Commit:        6ca5447e0c65ba6126a005aafeff3dc5c340bb75
Parent:        ddbf0075b1abb5ea0cb0ff56cc128fd18523ed36
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 23 23:15:04 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 23 23:34:46 2015 +0100

libdm: enhance thin-pool preload

When preloading thin-pool device node for already
existing/running thin-pool do not resume such thin-pool.

This allows to properly schedule commit point for metadata,
when thin-pool data or metadata volume is resized.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 49aa50f..600c5b7 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.112 - 
 =====================================
+  Improve preloading sequence of an active thin-pool target.
   Drop extra space from cache target line to fix unneded table reloads.
 
 Version 1.02.111 - 23rd November 2015
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 830a6a8..0b33ad3 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2788,6 +2788,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 	struct dm_tree_node *child;
 	struct dm_info newinfo;
 	int update_devs_flag = 0;
+	struct load_segment *seg;
 
 	/* Preload children first */
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
@@ -2835,6 +2836,22 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		if (!dm_tree_node_num_children(child, 1) || !child->props.size_changed)
 			continue;
 
+		if (!node_created && (dm_list_size(&child->props.segs) == 1)) {
+			/* If thin-pool child nodes were preloaded WITH changed size
+			 * skip device resume, as this is likely resize of data or
+			 * metadata device and so thin pool needs suspend before
+			 * resume operation.
+			 * Note: child->props.segment_count is already 0 here
+			 */
+			seg = dm_list_item(dm_list_last(&child->props.segs),
+					   struct load_segment);
+			if (seg->type == SEG_THIN_POOL) {
+				log_debug_activation("Skipping resume of thin-pool %s.",
+						     child->name);
+				continue;
+			}
+		}
+
 		if (!child->info.inactive_table && !child->info.suspended)
 			continue;
 



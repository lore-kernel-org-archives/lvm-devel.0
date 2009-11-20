From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 16:29:08 -0500
Subject: [PATCH 1/5] libdm-deptree-return-failure-activate-and-preload-children
Message-ID: <1258752552-1589-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Return error immediately to dm_tree_preload_children() and
dm_tree_activate_children() callers.

Otherwise resume_lv and its variants can fail silently.

Catching these failures is especially important now that dm targets like
crypt and snapshot-merge can fail in .preresume

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 libdm/libdm-deptree.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 1465fd3..bb10fe5 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1158,7 +1158,8 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 			continue;
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_activate_children(child, uuid_prefix, uuid_prefix_len);
+			if (!dm_tree_activate_children(child, uuid_prefix, uuid_prefix_len))
+				return_0;
 	}
 
 	handle = NULL;
@@ -1204,7 +1205,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 				log_error("Unable to resume %s (%" PRIu32
 					  ":%" PRIu32 ")", child->name, child->info.major,
 					  child->info.minor);
-				continue;
+				return 0;
 			}
 
 			/* Update cached info */
@@ -1621,7 +1622,8 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			continue;
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_preload_children(child, uuid_prefix, uuid_prefix_len);
+			if (!dm_tree_preload_children(child, uuid_prefix, uuid_prefix_len))
+				return_0;
 
 		/* FIXME Cope if name exists with no uuid? */
 		if (!child->info.exists) {
@@ -1655,7 +1657,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			log_error("Unable to resume %s (%" PRIu32
 				  ":%" PRIu32 ")", child->name, child->info.major,
 				  child->info.minor);
-			continue;
+			return 0;
 		}
 
 		/* Update cached info */
-- 
1.6.5.2



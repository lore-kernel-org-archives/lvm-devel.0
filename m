From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Feb 2020 11:24:40 -0500
Subject: master - cachevol: stop dm errors with uncaching cache with cachevol
Message-ID: <81083.120021111243402225@us-mta-21.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=892a182975049ebe732860c30c866fe2de5b7717
Commit:        892a182975049ebe732860c30c866fe2de5b7717
Parent:        25b97e522d8f0d8226aa3a50c69f0ec9de17b88c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 11 17:11:39 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 17:19:57 2020 +0100

cachevol: stop dm errors with uncaching cache with cachevol

Fix the anoying kernel message reported:
device-mapper: cache: 253:2: metadata operation 'dm_cache_commit' failed: error = -5
which has been reported while cachevol has been removed.
Happened via confusing variable - so switch the variable to commonly user '_size'
which presents a value in sector units and avoid 'scaling' this as extent length
by vg extent size when placing 'error' target on removal path.

Patch shouldn't have impact on actual users data, since at this moment
of removal all date should have been already flushed to origin device.

m
---
 WHATS_NEW                  |  1 +
 lib/activate/dev_manager.c | 14 +++++++-------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d1c545b..30f1391 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.09 - 
 ====================================
+  Fix showing of a dm kernel error when uncaching a volume with cachevol.
 
 Version 2.03.08 - 11th February 2020
 ====================================
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8569e86..c8a22fb 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3161,8 +3161,8 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		char *dlid_meta;
 		char *dlid_data;
 		char *dlid_pool;
-		uint64_t meta_len = first_seg(lv)->metadata_len;
-		uint64_t data_len = first_seg(lv)->data_len;
+		uint64_t meta_size = first_seg(lv)->metadata_len;
+		uint64_t data_size = first_seg(lv)->data_len;
 		uint16_t udev_flags = _get_udev_flags(dm, lv, layer,
 					     laopts->noscan, laopts->temporary,
 					     0);
@@ -3210,12 +3210,12 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 		if (dm->track_pending_delete) {
 			log_debug_activation("Using error for pending meta delete %s.", display_lvname(lv));
-			if (!dm_tree_node_add_error_target(dnode_meta, (uint64_t)lv->vg->extent_size * meta_len))
+			if (!dm_tree_node_add_error_target(dnode_meta, meta_size))
 				return_0;
 		} else {
 			/* add load_segment to meta dnode: linear, size of meta area */
 			if (!add_linear_area_to_dtree(dnode_meta,
-						      meta_len,
+						      meta_size,
 						      lv->vg->extent_size,
 						      lv->vg->cmd->use_linear_target,
 						      lv->vg->name, lv->name))
@@ -3239,19 +3239,19 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 		if (dm->track_pending_delete) {
 			log_debug_activation("Using error for pending data delete %s.", display_lvname(lv));
-			if (!dm_tree_node_add_error_target(dnode_data, (uint64_t)lv->vg->extent_size * data_len))
+			if (!dm_tree_node_add_error_target(dnode_data, data_size))
 				return_0;
 		} else {
 			/* add load_segment to data dnode: linear, size of data area */
 			if (!add_linear_area_to_dtree(dnode_data,
-						      data_len,
+						      data_size,
 						      lv->vg->extent_size,
 						      lv->vg->cmd->use_linear_target,
 						      lv->vg->name, lv->name))
 				return_0;
 
 			/* add seg_area to prev load_seg: offset 0 maps to cachepool lv after meta */
-			if (!dm_tree_node_add_target_area(dnode_data, NULL, dlid_pool, meta_len))
+			if (!dm_tree_node_add_target_area(dnode_data, NULL, dlid_pool, meta_size))
 				return_0;
 		}
 	}




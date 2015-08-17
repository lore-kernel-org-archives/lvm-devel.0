From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Aug 2015 09:25:14 +0000 (UTC)
Subject: master - thin: restore transaction_id handling
Message-ID: <20150817092514.403A96104D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79ea81b8a849677489c35717fb571d3d6e67a0a0
Commit:        79ea81b8a849677489c35717fb571d3d6e67a0a0
Parent:        d4c024c836aa10be0fe4d55157bac15f5ede62a8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 14 17:41:27 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 17 11:25:03 2015 +0200

thin: restore transaction_id handling

Revert back to already existing behavior which has been slightly
modified by a900d150e4658a5d72c39acdd4fefd069b8f00b8.

At the end however it seem to be equal to change TID right with first
metadata write.

Existing code missed handling for 'unused' thin-pool which would
require to also check empty message list for TID==0.

So with the fix we now again preserve 'active' thin-pool volume
when first thin volume is created - this property was lost and caused
problems in cluster, where the lock was hold, but volume was no longer
active on the node.

Another missing part was the proper support for already increased,
but unfinished TID change.

So going back here with existing logic -

TID is increased with first MDA update.

Code allows start with either same TID or (TID-1).

If there are messages, TID must be lower by 1 for sending,
otherwise messages were already posted.
---
 lib/metadata/thin_manip.c |    7 ++++---
 lib/thin/thin.c           |   10 +++++-----
 libdm/libdm-deptree.c     |    2 +-
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index d0a5c55..24c68a8 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -63,6 +63,10 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 
 	tmsg->type = type;
 
+	/* If the 1st message is add in non-read-only mode, modify transaction_id */
+	if (!no_update && dm_list_empty(&pool_seg->thin_messages))
+		pool_seg->transaction_id++;
+
 	dm_list_add(&pool_seg->thin_messages, &tmsg->list);
 
 	log_debug_metadata("Added %s message.",
@@ -476,9 +480,6 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 
 	dm_list_init(&(first_seg(lv)->thin_messages));
 
-	/* thin-pool target transaction is finished, increase lvm2 TID */
-	first_seg(lv)->transaction_id++;
-
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 4c4636f..c5f04f3 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -295,7 +295,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	}
 
 	if (!dm_tree_node_add_thin_pool_target(node, len,
-					       seg->transaction_id + (laopts->send_messages ? 1 : 0),
+					       seg->transaction_id,
 					       metadata_dlid, pool_dlid,
 					       seg->chunk_size, seg->low_water_mark,
 					       seg->zero_new_blocks ? 0 : 1))
@@ -345,7 +345,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 				 */
 				if (!lv_thin_pool_transaction_id(seg->lv, &transaction_id))
 					return_0; /* Thin pool should exist and work */
-				if (transaction_id != seg->transaction_id) {
+				if ((transaction_id + 1) != seg->transaction_id) {
 					log_error("Can't create snapshot %s as origin %s is not suspended.",
 						  lmsg->u.lv->name, origin->name);
 					return 0;
@@ -373,11 +373,11 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 
 	if (!dm_list_empty(&seg->thin_messages)) {
 		/* Messages were passed, modify transaction_id as the last one */
-		log_debug_activation("Thin pool set transaction id %" PRIu64 ".", seg->transaction_id + 1);
+		log_debug_activation("Thin pool set transaction id %" PRIu64 ".", seg->transaction_id);
 		if (!dm_tree_node_add_thin_pool_message(node,
 							DM_THIN_MESSAGE_SET_TRANSACTION_ID,
-							seg->transaction_id,
-							seg->transaction_id + 1))
+							seg->transaction_id - 1,
+							seg->transaction_id))
 			return_0;
 	}
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d28f0de..84f1d28 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1586,7 +1586,7 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 	}
 
 	/* Error if there are no stacked messages or id mismatches */
-	if (trans_id != (seg->transaction_id - have_messages)) {
+	if ((trans_id + 1) != seg->transaction_id) {
 		log_error("Thin pool %s transaction_id is %" PRIu64 ", while expected %" PRIu64 ".",
 			  _node_name(dnode), trans_id, seg->transaction_id - have_messages);
 		return 0;



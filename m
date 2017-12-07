From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 7 Dec 2017 15:03:42 -0500
Subject: master - libdm: use delay_resume_if_extended
Message-ID: <201712072003.vB7K3grM005625@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82ae02bc6a6788aabb10ac8a95287feea37ab88c
Commit:        82ae02bc6a6788aabb10ac8a95287feea37ab88c
Parent:        297d5915c3c927cba3a63bc9d6d1747271d06641
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 7 20:28:03 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 7 21:00:39 2017 +0100

libdm: use delay_resume_if_extended

Update the logic towards more explicit logic.

Preload tree normally does not want to resume, only
in certain cases of extension or new loaded nodes can be
resumed. So introduce new internal variable delay_resume_if_extended
controlable by target.

Patch itself is not changing current existing behaviour,
and rather documents existing problem in more readable way.

lvm2 needs to introduce explicit mechanism how to support more
fain-grained (and safe) logic to i.e. resize thin-pool which
can be sitting on cached raid volume.
---
 libdm/libdm-deptree.c |   55 ++++++++++++++++++++++++++++--------------------
 1 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index f463eab..745fec3 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -233,6 +233,19 @@ struct load_properties {
 	unsigned delay_resume_if_new;
 
 	/*
+	 * Preload tree normally only loads and not resume, but there is
+	 * automatic resume when target is extended, as it's believed
+	 * there can be no i/o flying to this 'new' extedend space
+	 * from any device above. Reason is that preloaded target above
+	 * may actually need to see its bigger subdevice before it
+	 * gets suspended. As long as devices are simple linears
+	 * there is no problem to resume bigger device in preload (before commit).
+	 * However complex targets like thin-pool (raid,cache...)
+	 * they shall not be resumed before their commit.
+	 */
+	unsigned delay_resume_if_extended;
+
+	/*
 	 * Call node_send_messages(), set to 2 if there are messages
 	 * When != 0, it validates matching transaction id, thus thin-pools
 	 * where transation_id is passed as 0 are never validated, this
@@ -2745,6 +2758,18 @@ static int _load_node(struct dm_tree_node *dnode)
 					     PRIu64 " for %s.%s", existing_table_size,
 					     seg_start, _node_name(dnode),
 					     dnode->props.size_changed ? "" : " (Ignoring.)");
+
+			/*
+			 * FIXME: code here has known design problem.
+			 *  LVM2 does NOT resize thin-pool on top of other LV in 2 steps -
+			 *  where raid would be resized with 1st. transaction
+			 *  followed by 2nd. thin-pool resize - RHBZ #1285063
+			 */
+			if (existing_table_size && dnode->props.delay_resume_if_extended) {
+				log_debug_activation("Resume of table of extended device %s delayed.",
+						     _node_name(dnode));
+				dnode->props.size_changed = 0;
+			}
 		}
 	}
 
@@ -2791,7 +2816,6 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 	struct dm_tree_node *child;
 	struct dm_info newinfo;
 	int update_devs_flag = 0;
-	struct load_segment *seg;
 
 	/* Preload children first */
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
@@ -2816,6 +2840,10 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		if (!child->info.exists && !(node_created = _create_node(child)))
 			return_0;
 
+		/* Propagate delayed resume from exteded child node */
+		if (child->props.delay_resume_if_extended)
+			dnode->props.delay_resume_if_extended = 1;
+
 		if (!child->info.inactive_table &&
 		    child->props.segment_count &&
 		    !_load_node(child)) {
@@ -2833,32 +2861,10 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			return_0;
 		}
 
-		/* Propagate device size change change */
-		if (child->props.size_changed > 0 && !dnode->props.size_changed)
-			dnode->props.size_changed = 1;
-		else if (child->props.size_changed < 0)
-			dnode->props.size_changed = -1;
-
 		/* No resume for a device without parents or with unchanged or smaller size */
 		if (!dm_tree_node_num_children(child, 1) || (child->props.size_changed <= 0))
 			continue;
 
-		if (!node_created && (dm_list_size(&child->props.segs) == 1)) {
-			/* If thin-pool child nodes were preloaded WITH changed size
-			 * skip device resume, as this is likely resize of data or
-			 * metadata device and so thin pool needs suspend before
-			 * resume operation.
-			 * Note: child->props.segment_count is already 0 here
-			 */
-			seg = dm_list_item(dm_list_last(&child->props.segs),
-					   struct load_segment);
-			if (seg->type == SEG_THIN_POOL) {
-				log_debug_activation("Skipping resume of thin-pool %s.",
-						     child->name);
-				continue;
-			}
-		}
-
 		if (!child->info.inactive_table && !child->info.suspended)
 			continue;
 
@@ -3527,6 +3533,9 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 	seg->metadata->props.delay_resume_if_new = 0;
 	seg->pool->props.delay_resume_if_new = 0;
 
+	/* Preload must not resume extended running thin-pool before it's committed */
+	node->props.delay_resume_if_extended = 1;
+
 	/* Validate only transaction_id > 0 when activating thin-pool */
 	node->props.send_messages = transaction_id ? 1 : 0;
 	seg->transaction_id = transaction_id;



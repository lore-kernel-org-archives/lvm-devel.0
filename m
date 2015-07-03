From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Jul 2015 14:19:11 +0000 (UTC)
Subject: master - thin: move pool messaging from resume to suspend
Message-ID: <20150703141911.5BB1260FE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a900d150e4658a5d72c39acdd4fefd069b8f00b8
Commit:        a900d150e4658a5d72c39acdd4fefd069b8f00b8
Parent:        5bef18f2eb1071a29b682f6f456a13a73493868e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 1 13:31:37 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 3 16:13:14 2015 +0200

thin: move pool messaging from resume to suspend

Existing messaging intarface for thin-pool has a few 'weak' points:

* Message were posted with each 'resume' operation, thus not allowing
activation of thin-pool with the existing state.

* Acceleration skipped suspend step has not worked in cluster,
since clvmd resumes only nodes which are suspended (have proper lock
state).

* Resume may fail and code is not really designed to 'fail' in this
phase (generic rule here is resume DOES NOT fail unless something serious
is wrong and lvm2 tool usually doesn't handle recovery path in this case.)

* Full thin-pool suspend happened, when taken a thin-volume snapshot.

With this patch the new method relocates message passing into suspend
state.

This has a few drawbacks with current API, but overal it performs
better and gives are more posibilities to deal with errors.

Patch introduces a new logic for 'origin-only' suspend of thin-pool and
this also relates to thin-volume when taking snapshot.

When suspend_origin_only operation is invoked on a pool with
queued messages then only those messages are posted to thin-pool and
actual suspend of thin pool and data and metadata volume is skipped.

This makes taking a snapshot of thin-volume lighter operation and
avoids blocking of other unrelated active thin volumes.

Also fail now happens in 'suspend' state where the 'Fail' is more expected
and it is better handled through error paths.

Activation of thin-pool is now not sending any message and leaves upto a tool
to decided later how to finish unfinished double-commit transaction.

Problem which needs some API improvements relates to the lvm2 tree
construction. For the suspend tree we do not add target table line
into the tree, but only a device is inserted into a tree.
Current mechanism to attach messages for thin-pool requires the libdm
to know about thin-pool target, so lvm2 currently takes assumption, node
is really a thin-pool and fills in the table line for this node (which
should be ensured by the PRELOAD phase, but it's a misuse of internal API)
we would possibly need to be able to attach message to 'any' node.

Other thing to notice - current messaging interface in thin-pool
target requires to suspend thin volume origin first and then send
a create message, but this could not have any 'nice' solution on lvm2
side and IMHO we should introduce something like 'create_after_resume'
message.

Patch also changes the moment, where lvm2 transaction id is increased.
Now it happens only after successful finish of kernel transaction id
change. This change was needed to handle properly activation of pool,
which is in the middle of unfinished transaction, and also this corrects
usage of thin-pool by external apps like Docker.
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |   12 ++++-----
 lib/activate/dev_manager.c |   56 ++++++++++++++++++++++++++++++++++++--------
 lib/metadata/lv_manip.c    |   32 +++++++++++--------------
 lib/metadata/thin_manip.c  |   44 ++++++++++++++++++----------------
 lib/thin/thin.c            |    9 ++++---
 libdm/libdm-deptree.c      |   10 ++++++-
 7 files changed, 102 insertions(+), 62 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 22fc42a..382f290 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.124 -
 =================================
+  Move sending thin pool messages from resume to suspend phase.
   Report warning when pool is overprovisioned and not auto resized.
   Recognize free-form date/time values for lv_time field in selection criteria.
   Fix regression in select to match string fields if using synonyms (2.02.123).
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 5905b7b..2e58c3b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1813,7 +1813,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		goto_out;
 
 	/* Ignore origin_only unless LV is origin in both old and new metadata */
-	if (!lv_is_thin_volume(ondisk_lv) && !(lv_is_origin(ondisk_lv) && lv_is_origin(incore_lv)))
+	/* or LV is thin or thin pool volume */
+	if (!lv_is_thin_volume(ondisk_lv) && !lv_is_thin_pool(ondisk_lv) &&
+	    !(lv_is_origin(ondisk_lv) && lv_is_origin(incore_lv)))
 		laopts->origin_only = 0;
 
 	if (test_mode()) {
@@ -1987,7 +1989,6 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	const struct logical_volume *lv_to_free = NULL;
 	struct lvinfo info;
 	int r = 0;
-	int messages_only = 0;
 
 	if (!activation())
 		return 1;
@@ -1995,10 +1996,7 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto_out;
 
-	if (lv_is_thin_pool(lv) && laopts->origin_only)
-		messages_only = 1;
-
-	if (!lv_is_origin(lv) && !lv_is_thin_volume(lv))
+	if (!lv_is_origin(lv) && !lv_is_thin_volume(lv) && !lv_is_thin_pool(lv))
 		laopts->origin_only = 0;
 
 	if (test_mode()) {
@@ -2018,7 +2016,7 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
-	if (!info.exists || !(info.suspended || messages_only)) {
+	if (!info.exists || !info.suspended) {
 		if (error_if_not_active)
 			goto_out;
 		r = 1;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index f4b2a4a..e13b8e5 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -60,6 +60,7 @@ struct dev_manager {
 	uint32_t pvmove_mirror_count;
 	int flush_required;
 	int activation;                 /* building activation tree */
+	int suspend;			/* building suspend tree */
 	int skip_external_lv;
 	struct dm_list pending_delete;	/* str_list of dlid(s) with pending delete */
 	unsigned track_pending_delete;
@@ -2066,6 +2067,11 @@ static int _pool_register_callback(struct dev_manager *dm,
 	return 1;
 }
 
+/* Declaration to resolve suspend tree and message passing for thin-pool */
+static int _add_target_to_dtree(struct dev_manager *dm,
+				struct dm_tree_node *dnode,
+				struct lv_segment *seg,
+				struct lv_activate_opts *laopts);
 /*
  * Add LV and any known dependencies
  */
@@ -2134,15 +2140,43 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		 */
 		if (!_add_dev_to_dtree(dm, dtree, lv, lv_layer(lv)))
 			return_0;
+
+		/*
+		 * TODO: change API and move this code
+		 * Could be easier to handle this in _add_dev_to_dtree()
+		 * and base this according to info.exists ?
+		 */
 		if (!dm->activation) {
-			/* Setup callback for non-activation partial tree */
-			/* Activation gets own callback when needed */
-			/* TODO: extend _cached_dm_info() to return dnode */
 			if (!(uuid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 				return_0;
-			if ((node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
-			    !_pool_register_callback(dm, node, lv))
-				return_0;
+			if ((node = dm_tree_find_node_by_uuid(dtree, uuid))) {
+				if (origin_only) {
+					struct lv_activate_opts laopts = {
+						.origin_only = 1,
+						.send_messages = 1 /* Node with messages */
+					};
+					/*
+					 * Add some messsages if right node exist in the table only
+					 * when building SUSPEND tree for origin-only thin-pool.
+					 *
+					 * TODO: Fix call of '_add_target_to_dtree()' to add message
+					 * to thin-pool node as we already know the pool node exists
+					 * in the table. Any better/cleaner API way ?
+					 *
+					 * Probably some 'new' target method to add messages for any node?
+					 */
+					if (dm->suspend &&
+					    !dm_list_empty(&(first_seg(lv)->thin_messages)) &&
+					    !_add_target_to_dtree(dm, node, first_seg(lv), &laopts))
+						return_0;
+				} else {
+					/* Setup callback for non-activation partial tree */
+					/* Activation gets own callback when needed */
+					/* TODO: extend _cached_dm_info() to return dnode */
+					if (!_pool_register_callback(dm, node, lv))
+						return_0;
+				}
+			}
 		}
 	}
 
@@ -2240,7 +2274,7 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, const struc
 
 	dm_tree_set_optional_uuid_suffixes(dtree, &uuid_suffix_list[0]);
 
-	if (!_add_lv_to_dtree(dm, dtree, lv, (lv_is_origin(lv) || lv_is_thin_volume(lv)) ? origin_only : 0))
+	if (!_add_lv_to_dtree(dm, dtree, lv, (lv_is_origin(lv) || lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) ? origin_only : 0))
 		goto_bad;
 
 	return dtree;
@@ -2695,7 +2729,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		return_0;
 
 	/* Add pool layer */
-	if (seg->pool_lv &&
+	if (seg->pool_lv && !laopts->origin_only &&
 	    !_add_new_lv_to_dtree(dm, dtree, seg->pool_lv, laopts,
 				  lv_layer(seg->pool_lv)))
 		return_0;
@@ -3137,6 +3171,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 	}
 	/* Some targets may build bigger tree for activation */
 	dm->activation = ((action == PRELOAD) || (action == ACTIVATE));
+	dm->suspend = (action == SUSPEND_WITH_LOCKFS) || (action == SUSPEND);
 	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))
 		return_0;
 
@@ -3181,7 +3216,9 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 	case PRELOAD:
 	case ACTIVATE:
 		/* Add all required new devices to tree */
-		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, (lv_is_origin(lv) && laopts->origin_only) ? "real" : NULL))
+		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts,
+					  (lv_is_origin(lv) && laopts->origin_only) ? "real" :
+					  (lv_is_thin_pool(lv) && laopts->origin_only) ? "tpool" : NULL))
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
@@ -3219,7 +3256,6 @@ out_no_root:
 int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv,
 			 struct lv_activate_opts *laopts)
 {
-	laopts->send_messages = 1;
 	if (!_tree_action(dm, lv, laopts, ACTIVATE))
 		return_0;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d23dd62..1891491 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7372,11 +7372,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				stack;
 				goto revert_new_lv;
 			}
-			/* When change is activating, don't duplicate backup call */
-			if (!is_change_activating(lp->activate))
-				backup(vg);
 		}
-		if (is_change_activating(lp->activate)) {
+		if (!dm_list_empty(&first_seg(pool_lv)->thin_messages)) {
 			/* Send message so that table preload knows new thin */
 			if (!lv_is_active(pool_lv)) {
 				/* Avoid multiple thin-pool activations in this case */
@@ -7394,25 +7391,24 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				}
 			}
 			/* Keep thin pool active until thin volume is activated */
-			if (!update_pool_lv(pool_lv, (thin_pool_was_active < 0) ? 1 : 0)) {
+			if (!update_pool_lv(pool_lv, 1)) {
 				stack;
 				goto revert_new_lv;
 			}
+		}
+		backup(vg);
 
-			backup(vg);
-
-			if (!lv_active_change(cmd, lv, lp->activate, 0)) {
-				log_error("Failed to activate thin %s.", lv->name);
-				goto deactivate_and_revert_new_lv;
-			}
+		if (!lv_active_change(cmd, lv, lp->activate, 0)) {
+			log_error("Failed to activate thin %s.", lv->name);
+			goto deactivate_and_revert_new_lv;
+		}
 
-			/* Restore inactive state if needed */
-			if (!thin_pool_was_active &&
-			    !deactivate_lv(cmd, pool_lv)) {
-				log_error("Failed to deactivate thin pool %s.",
-					  display_lvname(pool_lv));
-				return NULL;
-			}
+		/* Restore inactive state if needed */
+		if (!thin_pool_was_active &&
+		    !deactivate_lv(cmd, pool_lv)) {
+			log_error("Failed to deactivate thin pool %s.",
+				  display_lvname(pool_lv));
+			return NULL;
 		}
 	} else if (lp->snapshot) {
 		lv->status |= LV_TEMPORARY;
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 1453f88..6ae0795 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -21,6 +21,7 @@
 #include "defaults.h"
 #include "display.h"
 
+/* TODO: drop unused no_update */
 int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 			struct logical_volume *lv, uint32_t delete_id,
 			int no_update)
@@ -62,10 +63,6 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 
 	tmsg->type = type;
 
-	/* If the 1st message is add in non-read-only mode, modify transaction_id */
-	if (!no_update && dm_list_empty(&pool_seg->thin_messages))
-		pool_seg->transaction_id++;
-
 	dm_list_add(&pool_seg->thin_messages, &tmsg->list);
 
 	log_debug_metadata("Added %s message.",
@@ -423,7 +420,7 @@ static int _check_pool_create(const struct logical_volume *lv)
 
 int update_pool_lv(struct logical_volume *lv, int activate)
 {
-	int monitored;
+	int monitored = DMEVENTD_MONITOR_IGNORE;
 	int ret = 1;
 
 	if (!lv_is_thin_pool(lv)) {
@@ -449,32 +446,37 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 					  display_lvname(lv));
 				return 0;
 			}
-
-			if (!(ret = _check_pool_create(lv)))
-				stack;
-
+		} else
+			activate = 0; /* Was already active */
+
+		if (!(ret = _check_pool_create(lv)))
+			stack; /* Safety guard, needs local presence of thin-pool target */
+		else if (!(ret = suspend_lv_origin(lv->vg->cmd, lv)))
+			/* Send messages */
+			log_error("Failed to suspend and send message %s.", display_lvname(lv));
+		else if (!(ret = resume_lv_origin(lv->vg->cmd, lv)))
+			log_error("Failed to resume %s.", display_lvname(lv));
+
+		if (activate) {
 			if (!deactivate_lv(lv->vg->cmd, lv)) {
 				init_dmeventd_monitor(monitored);
 				return_0;
 			}
 			init_dmeventd_monitor(monitored);
-
-			/* Unlock memory if possible */
-			memlock_unlock(lv->vg->cmd);
 		}
-		/*
-		 * Resume active pool to send thin messages.
-		 * origin_only is used to skip check for resumed state
-		 */
-		else if (!resume_lv_origin(lv->vg->cmd, lv)) {
-			log_error("Failed to resume %s.", lv->name);
-			return 0;
-		} else if (!(ret = _check_pool_create(lv)))
-			stack;
+
+		/* Unlock memory if possible */
+		memlock_unlock(lv->vg->cmd);
+
+		if (!ret)
+			return_0;
 	}
 
 	dm_list_init(&(first_seg(lv)->thin_messages));
 
+	/* thin-pool target transaction is finished, increase lvm2 TID */
+	first_seg(lv)->transaction_id++;
+
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index e098744..6993249 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -294,7 +294,8 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (!dm_tree_node_add_thin_pool_target(node, len, seg->transaction_id,
+	if (!dm_tree_node_add_thin_pool_target(node, len,
+					       seg->transaction_id + (laopts->send_messages ? 1 : 0),
 					       metadata_dlid, pool_dlid,
 					       seg->chunk_size, seg->low_water_mark,
 					       seg->zero_new_blocks ? 0 : 1))
@@ -372,11 +373,11 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 
 	if (!dm_list_empty(&seg->thin_messages)) {
 		/* Messages were passed, modify transaction_id as the last one */
-		log_debug_activation("Thin pool set transaction id %" PRIu64 ".", seg->transaction_id);
+		log_debug_activation("Thin pool set transaction id %" PRIu64 ".", seg->transaction_id + 1);
 		if (!dm_tree_node_add_thin_pool_message(node,
 							DM_THIN_MESSAGE_SET_TRANSACTION_ID,
-							seg->transaction_id - 1,
-							seg->transaction_id))
+							seg->transaction_id,
+							seg->transaction_id + 1))
 			return_0;
 	}
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index b9a8582..5baac6d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -241,7 +241,12 @@ struct load_properties {
 	 */
 	unsigned delay_resume_if_new;
 
-	/* Send messages for this node in preload */
+	/*
+	 * Call node_send_messages(), set to 2 if there are messages
+	 * When != 0, it validates matching transaction id, thus thin-pools
+	 * where transation_id is passed as 0 are never validated, this
+	 * allows external managment of thin-pool TID.
+	 */
 	unsigned send_messages;
 	/* Skip suspending node's children, used when sending messages to thin-pool */
 	int skip_suspend;
@@ -3871,7 +3876,8 @@ int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
 
 	tm->message.type = type;
 	dm_list_add(&seg->thin_messages, &tm->list);
-	node->props.send_messages = 1;
+	/* Higher value >1 identifies there are really some messages */
+	node->props.send_messages = 2;
 
 	return 1;
 }



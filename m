From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:57:59 -0500
Subject: master - cleanup: use _node_name
Message-ID: <201712041457.vB4EvxKd007169@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a01e3d4ca56b13c266629ebb343d1dfb5e9b583
Commit:        2a01e3d4ca56b13c266629ebb343d1dfb5e9b583
Parent:        925fec6ecb8f1915aee20e09a9703e1cb70cd0b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 13:33:05 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: use _node_name

Use existing internal method for create 'name (major:minor)' string
for debug messages and reduce some messages.
---
 libdm/libdm-deptree.c |   57 ++++++++++++++++++-------------------------------
 1 files changed, 21 insertions(+), 36 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index f662d26..6370e88 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -597,8 +597,9 @@ static struct dm_tree_node *_find_dm_tree_node_by_uuid(struct dm_tree *dtree,
 static const char *_node_name(struct dm_tree_node *dnode)
 {
 	if (dm_snprintf(dnode->dtree->buf, sizeof(dnode->dtree->buf),
-			"%s (%" PRIu32 ":%" PRIu32 ")",
-			dnode->name, dnode->info.major, dnode->info.minor) < 0) {
+			"%s (" FMTu32 ":" FMTu32 ")",
+			dnode->name ? dnode->name : "",
+			dnode->info.major, dnode->info.minor) < 0) {
 		stack;
 		return dnode->name;
 	}
@@ -609,12 +610,9 @@ static const char *_node_name(struct dm_tree_node *dnode)
 void dm_tree_node_set_udev_flags(struct dm_tree_node *dnode, uint16_t udev_flags)
 
 {
-	struct dm_info *dinfo = &dnode->info;
-
 	if (udev_flags != dnode->udev_flags)
-		log_debug_activation("Resetting %s (%" PRIu32 ":%" PRIu32
-				     ") udev_flags from 0x%x to 0x%x",
-				     dnode->name, dinfo->major, dinfo->minor,
+		log_debug_activation("Resetting %s udev_flags from 0x%x to 0x%x.",
+				     _node_name(dnode),
 				     dnode->udev_flags, udev_flags);
 	dnode->udev_flags = udev_flags;
 }
@@ -1398,8 +1396,8 @@ static int _thin_pool_get_status(struct dm_tree_node *dnode,
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
 	if (type && (strcmp(type, "thin-pool") != 0)) {
-		log_error("Expected thin-pool target for %d:%d and got %s.",
-			  dnode->info.major, dnode->info.minor, type);
+		log_error("Expected thin-pool target for %s and got %s.",
+			  _node_name(dnode), type);
 		goto out;
 	}
 
@@ -1895,9 +1893,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 			if (!_resume_node(child->name, child->info.major, child->info.minor,
 					  child->props.read_ahead, child->props.read_ahead_flags,
 					  &newinfo, &child->dtree->cookie, child->udev_flags, child->info.suspended)) {
-				log_error("Unable to resume %s (%" PRIu32
-					  ":%" PRIu32 ")", child->name, child->info.major,
-					  child->info.minor);
+				log_error("Unable to resume %s.", _node_name(child));
 				r = 0;
 				continue;
 			}
@@ -1997,9 +1993,8 @@ static int _remove_node(struct dm_tree_node *dnode)
 
 	if (!_deactivate_node(dnode->name, dnode->info.major, dnode->info.minor,
 			      &dnode->dtree->cookie, dnode->udev_flags, 0)) {
-		log_error("Failed to clean-up device with no table: %s %u:%u",
-			  dnode->name ? dnode->name : "",
-			  dnode->info.major, dnode->info.minor);
+		log_error("Failed to clean-up device with no table: %s.",
+			  _node_name(dnode));
 		return 0;
 	}
 	return 1;
@@ -2691,22 +2686,21 @@ static int _load_node(struct dm_tree_node *dnode)
 	struct load_segment *seg;
 	uint64_t seg_start = 0, existing_table_size;
 
-	log_verbose("Loading %s table (%" PRIu32 ":%" PRIu32 ")", dnode->name,
-		    dnode->info.major, dnode->info.minor);
+	log_verbose("Loading table for %s.", _node_name(dnode));
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RELOAD))) {
-		log_error("Reload dm_task creation failed for %s", dnode->name);
+		log_error("Reload dm_task creation failed for %s.", _node_name(dnode));
 		return 0;
 	}
 
 	if (!dm_task_set_major(dmt, dnode->info.major) ||
 	    !dm_task_set_minor(dmt, dnode->info.minor)) {
-		log_error("Failed to set device number for %s reload.", dnode->name);
+		log_error("Failed to set device number for %s reload.", _node_name(dnode));
 		goto out;
 	}
 
 	if (dnode->props.read_only && !dm_task_set_ro(dmt)) {
-		log_error("Failed to set read only flag for %s", dnode->name);
+		log_error("Failed to set read only flag for %s.", _node_name(dnode));
 		goto out;
 	}
 
@@ -2724,10 +2718,8 @@ static int _load_node(struct dm_tree_node *dnode)
 	if ((r = dm_task_run(dmt))) {
 		r = dm_task_get_info(dmt, &dnode->info);
 		if (r && !dnode->info.inactive_table)
-			log_verbose("Suppressed %s (%" PRIu32 ":%" PRIu32
-				    ") identical table reload.",
-				    dnode->name,
-				    dnode->info.major, dnode->info.minor);
+			log_verbose("Suppressed %s identical table reload.",
+				    _node_name(dnode));
 
 		existing_table_size = dm_task_get_existing_table_size(dmt);
 		if ((dnode->props.size_changed =
@@ -2742,9 +2734,8 @@ static int _load_node(struct dm_tree_node *dnode)
 				dnode->props.size_changed = 0;
 
 			log_debug_activation("Table size changed from %" PRIu64 " to %"
-					     PRIu64 " for %s (%" PRIu32 ":%" PRIu32 ").%s",
-					     existing_table_size, seg_start, dnode->name,
-					     dnode->info.major, dnode->info.minor,
+					     PRIu64 " for %s.%s", existing_table_size,
+					     seg_start, _node_name(dnode),
 					     dnode->props.size_changed ? "" : " (Ignoring.)");
 		}
 	}
@@ -2773,9 +2764,7 @@ static int _dm_tree_revert_activated(struct dm_tree_node *parent)
 		}
 		if (!_deactivate_node(child->name, child->info.major, child->info.minor,
 				      &child->dtree->cookie, child->udev_flags, 0)) {
-			log_error("Unable to deactivate %s (%" PRIu32
-				  ":%" PRIu32 ")", child->name, child->info.major,
-				  child->info.minor);
+			log_error("Unable to deactivate %s.", _node_name(child));
 			return 0;
 		}
 		if (!_dm_tree_revert_activated(child))
@@ -2869,16 +2858,12 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 				  child->props.read_ahead, child->props.read_ahead_flags,
 				  &newinfo, &child->dtree->cookie, child->udev_flags,
 				  child->info.suspended)) {
-			log_error("Unable to resume %s (%" PRIu32
-				  ":%" PRIu32 ")", child->name, child->info.major,
-				  child->info.minor);
+			log_error("Unable to resume %s.", _node_name(child));
 			/* If the device was not previously active, we might as well remove this node. */
 			if (!child->info.live_table &&
 			    !_deactivate_node(child->name, child->info.major, child->info.minor,
 					      &child->dtree->cookie, child->udev_flags, 0))
-				log_error("Unable to deactivate %s (%" PRIu32
-					  ":%" PRIu32 ")", child->name, child->info.major,
-					  child->info.minor);
+				log_error("Unable to deactivate %s.", _node_name(child));
 			r = 0;
 			/* Each child is handled independently */
 			continue;



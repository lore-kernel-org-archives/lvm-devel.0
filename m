From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  1 Feb 2023 10:53:12 +0000 (GMT)
Subject: main - device_mapper: reactivate siblings for snapshot
Message-ID: <20230201105312.6A6943858412@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c8a5948a71b041ae2cce03e1b3a9843f0fab023f
Commit:        c8a5948a71b041ae2cce03e1b3a9843f0fab023f
Parent:        85aa236946d3c290c7fab2c6229684ed268b1670
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 30 14:32:44 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 1 11:47:47 2023 +0100

device_mapper: reactivate siblings for snapshot

When activating origin and its thick snapshots, ensure the
origin's LV udev processing is finished first and after this
reactivate its snapshot so the udev can scan them afterwards.

This should fix the problems for users using UUID of such device
in their fstab and occasionaly mounted snapshot instead of origin LV.
---
 WHATS_NEW                     |  1 +
 device_mapper/libdm-deptree.c | 89 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 90 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 191338868..7dbb669a1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 version 2.03.19 - 
 ====================================
+  Ensure udev is processing origin LV before its thick snapshots LVs.
   Fix and improve runtime memory size detection for VDO volumes.
 
 version 2.03.18 - 22nd december 2022
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 6a7fd08ee..ebf1d0257 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -294,6 +294,10 @@ struct load_properties {
 	unsigned send_messages;
 	/* Skip suspending node's children, used when sending messages to thin-pool */
 	int skip_suspend;
+
+	/* Suspend and Resume siblings after node activation with udev flags*/
+	unsigned reactivate_siblings;
+	uint16_t reactivate_udev_flags;
 };
 
 /* Two of these used to join two nodes with uses and used_by. */
@@ -2030,6 +2034,68 @@ static int _rename_conflict_exists(struct dm_tree_node *parent,
 	return 0;
 }
 
+/*
+ * Reactivation of sibling nodes
+ *
+ * Function is used when activating origin and its thick snapshots
+ * to ensure udev is processing first the origin LV and all the
+ * snapshot LVs are processed afterwards.
+ */
+static int _reactivate_siblings(struct dm_tree_node *dnode,
+				const char *uuid_prefix,
+				size_t uuid_prefix_len)
+{
+	struct dm_tree_node *child;
+	const char *uuid;
+	void *handle = NULL;
+	int r = 1;
+
+	/* Wait for udev before reactivating siblings */
+	if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
+		stack;
+
+	dm_tree_set_cookie(dnode, 0);
+
+	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
+		if (child->props.reactivate_siblings) {
+			/* Skip 'leading' device in this group, marked with flag */
+			child->props.reactivate_siblings = 0;
+			continue;
+		}
+
+		if (!(uuid = dm_tree_node_get_uuid(child))) {
+			stack;
+			continue;
+		}
+
+		if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
+			continue;
+
+		if (!_suspend_node(child->name, child->info.major, child->info.minor,
+				   child->dtree->skip_lockfs,
+				   child->dtree->no_flush, &child->info)) {
+			log_error("Unable to suspend %s (" FMTu32
+				  ":" FMTu32 ")", child->name,
+				  child->info.major, child->info.minor);
+			r = 0;
+			continue;
+		}
+		if (!_resume_node(child->name, child->info.major, child->info.minor,
+				  child->props.read_ahead, child->props.read_ahead_flags,
+				  &child->info, &child->dtree->cookie,
+				  child->props.reactivate_udev_flags, // use these flags
+				  child->info.suspended)) {
+			log_error("Failed to suspend %s (" FMTu32
+				  ":" FMTu32 ")", child->name,
+				  child->info.major, child->info.minor);
+			r = 0;
+			continue;
+		}
+	}
+
+	return r;
+}
+
 int dm_tree_activate_children(struct dm_tree_node *dnode,
 				 const char *uuid_prefix,
 				 size_t uuid_prefix_len)
@@ -2122,6 +2188,11 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 			if (r && (child->props.send_messages > 1) &&
 			    !(r = _node_send_messages(child, uuid_prefix, uuid_prefix_len, 1)))
 				stack;
+
+			/* Reactivate only for fresh activated origin */
+			if (r && child->props.reactivate_siblings &&
+			    (!(r = _reactivate_siblings(dnode, uuid_prefix, uuid_prefix_len))))
+				stack;
 		}
 		if (awaiting_peer_rename)
 			priority--; /* redo priority level */
@@ -3455,6 +3526,10 @@ int dm_tree_node_add_snapshot_origin_target(struct dm_tree_node *dnode,
 	/* Resume snapshot origins after new snapshots */
 	dnode->activation_priority = 1;
 
+	if (!dnode->info.exists)
+		/* Reactivate siblings for this origin after being resumed */
+		dnode->props.reactivate_siblings = 1;
+
 	/*
 	 * Don't resume the origin immediately in case it is a non-trivial 
 	 * target that must not be active more than once concurrently!
@@ -3517,6 +3592,20 @@ static int _add_snapshot_target(struct dm_tree_node *node,
 			/* Resume merging snapshot after snapshot-merge */
 			seg->merge->activation_priority = 2;
 		}
+	} else if (!origin_node->info.exists) {
+		/* Keep original udev_flags for reactivation. */
+		node->props.reactivate_udev_flags = node->udev_flags;
+
+		/* Reactivation is needed if the origin's -real device is not in DM table.
+		 * For this case after the resume of its origin LV we resume its snapshots
+		 * with updated udev_flags to completely avoid udev scanning for the first resume.
+		 * Reactivation then resumes snapshots with original udev_flags.
+		 */
+		node->udev_flags |= DM_SUBSYSTEM_UDEV_FLAG0 |
+			DM_UDEV_DISABLE_DISK_RULES_FLAG |
+			DM_UDEV_DISABLE_OTHER_RULES_FLAG;
+		log_debug_activation("Using udev_flags 0x%x for activation of %s.",
+				     node->udev_flags, node->name);
 	}
 
 	return 1;


From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon,  9 Sep 2013 20:23:40 +0000 (UTC)
Subject: master - Misc/RAID: Enable resume_lv to handle some renaming conflicts.
Message-ID: <20130909202340.B1105602F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca514351536c2dd8929944bb6b01a64587cb0a46
Commit:        ca514351536c2dd8929944bb6b01a64587cb0a46
Parent:        9f2fc2471cd39effccd549d73c2fc9c0e6419f94
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Sep 9 15:07:28 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Sep 9 15:07:28 2013 -0500

Misc/RAID: Enable resume_lv to handle some renaming conflicts.

When images and their associated metadata are removed from a RAID1 LV,
the remaining sub-LVs are "shifted" down to fill the gaps.  For
example, if there is a 3-way mirror:
	[0][1][2]
and we remove device#0, the devices will be shifted down
	[1][2]
and renamed.
	[0][1]

This can create a problem for resume_lv (specifically,
dm_tree_activate_children) during the renaming process though.  This
is because it will attempt to rename the higher indexed sub-LVs first
and find that it cannot because there are currently other sub-LVs with
that name.  The solution is to check for a conflicting name before
attempting to rename.  If a conflict is found and that conflicting
sub-LV is also in the process of renaming, we can defer the current
rename until the conflicting sub-LV has renamed and cleared the
conflict.

Now that resume_lv can handle these types of rename conflicts, we can
remove the workaround in RAID that was attempting to resume a RAID1
LV from the bottom-up in order to force a proper rename in assending
order before attempting a resume on the top-level LV.  This "hack"
only worked for single machine use-cases of LVM.  Clearing this up
paves the way for exclusive activation of RAID LVs in a cluster.
---
 lib/metadata/raid_manip.c |   42 +--------------------------------
 libdm/libdm-deptree.c     |   55 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 40 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 47c2788..d13750d 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -59,24 +59,6 @@ uint32_t lv_raid_image_count(const struct logical_volume *lv)
 	return seg->area_count;
 }
 
-/*
- * Resume sub-LVs first, then top-level LV
- */
-static int _bottom_up_resume(struct logical_volume *lv)
-{
-	uint32_t s;
-	struct lv_segment *seg = first_seg(lv);
-
-	if (seg_is_raid(seg) && (seg->area_count > 1)) {
-		for (s = 0; s < seg->area_count; s++)
-			if (!resume_lv(lv->vg->cmd, seg_lv(seg, s)) ||
-			    !resume_lv(lv->vg->cmd, seg_metalv(seg, s)))
-				return_0;
-	}
-
-	return resume_lv(lv->vg->cmd, lv);
-}
-
 static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 					   struct logical_volume *sub_lv)
 {
@@ -991,17 +973,7 @@ static int _raid_remove_images(struct logical_volume *lv,
 		}
 	}
 
-	/*
-	 * Resume the remaining LVs
-	 * We must start by resuming the sub-LVs first (which would
-	 * otherwise be handled automatically) because the shifting
-	 * of positions could otherwise cause name collisions.  For
-	 * example, if position 0 of a 3-way array is removed, position
-	 * 1 and 2 must be shifted and renamed 0 and 1.  If position 2
-	 * tries to rename first, it will collide with the existing
-	 * position 1.
-	 */
-	if (!_bottom_up_resume(lv)) {
+	if (!resume_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -1164,17 +1136,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		if (!resume_lv(cmd, lvl->lv))
 			return_0;
 
-	/*
-	 * Resume the remaining LVs
-	 * We must start by resuming the sub-LVs first (which would
-	 * otherwise be handled automatically) because the shifting
-	 * of positions could otherwise cause name collisions.  For
-	 * example, if position 0 of a 3-way array is split, position
-	 * 1 and 2 must be shifted and renamed 0 and 1.  If position 2
-	 * tries to rename first, it will collide with the existing
-	 * position 1.
-	 */
-	if (!_bottom_up_resume(lv)) {
+	if (!resume_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);
 		return 0;
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 57f00f6..752a44b 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1702,11 +1702,58 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 	return r;
 }
 
+/*
+ * _rename_conflict_exists
+ * @dnode
+ * @node
+ * @resolvable
+ *
+ * Check if there is a rename conflict with existing peers in
+ * this tree.  'resolvable' is set if the conflicting node will
+ * also be undergoing a rename.  (Allowing that node to rename
+ * first would clear the conflict.)
+ *
+ * Returns: 1 if conflict, 0 otherwise
+ */
+static int _rename_conflict_exists(struct dm_tree_node *parent,
+				 struct dm_tree_node *node,
+				 int *resolvable)
+{
+	void *handle = NULL;
+	const char *name = dm_tree_node_get_name(node);
+	const char *sibling_name;
+	struct dm_tree_node *sibling;
+
+	*resolvable = 0;
+
+	if (!name)
+		return_0;
+
+	while ((sibling = dm_tree_next_child(&handle, parent, 0))) {
+		if (sibling == node)
+			continue;
+
+		if (!(sibling_name = dm_tree_node_get_name(sibling))) {
+			stack;
+			continue;
+		}
+
+		if (!strcmp(node->props.new_name, sibling_name)) {
+			if (sibling->props.new_name)
+				*resolvable = 1;
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 int dm_tree_activate_children(struct dm_tree_node *dnode,
 				 const char *uuid_prefix,
 				 size_t uuid_prefix_len)
 {
 	int r = 1;
+	int resolvable_name_conflict, awaiting_peer_rename = 0;
 	void *handle = NULL;
 	struct dm_tree_node *child = dnode;
 	struct dm_info newinfo;
@@ -1732,6 +1779,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	handle = NULL;
 
 	for (priority = 0; priority < 3; priority++) {
+		awaiting_peer_rename = 0;
 		while ((child = dm_tree_next_child(&handle, dnode, 0))) {
 			if (priority != child->activation_priority)
 				continue;
@@ -1751,6 +1799,11 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 
 			/* Rename? */
 			if (child->props.new_name) {
+				if (_rename_conflict_exists(dnode, child, &resolvable_name_conflict) &&
+				    resolvable_name_conflict) {
+					awaiting_peer_rename++;
+					continue;
+				}
 				if (!_rename_node(name, child->props.new_name, child->info.major,
 						  child->info.minor, &child->dtree->cookie,
 						  child->udev_flags)) {
@@ -1779,6 +1832,8 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 			/* Update cached info */
 			child->info = newinfo;
 		}
+		if (awaiting_peer_rename)
+			priority--; /* redo priority level */
 	}
 
 	/*



From: Milan Broz <mbroz@redhat.com>
Date: Tue, 19 May 2009 12:46:04 +0200
Subject: [PATCH] Use suspend with flush when device size was changed during table preload.
Message-ID: <4A128DEC.9080508@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use suspend with flush when device size was changed during table preload.

This allows online mirror resize, also removes condition to preventing
code to do this.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c    |   14 +++++++-------
 lib/activate/dev_manager.c |   20 ++++++++++++++++----
 lib/activate/dev_manager.h |    5 +++--
 libdm/.exported_symbols    |    1 +
 libdm/libdevmapper.h       |    1 +
 libdm/libdm-deptree.c      |    9 +++++++++
 tools/lvresize.c           |    6 ------
 7 files changed, 37 insertions(+), 19 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 34f979a..b600431 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -589,7 +589,7 @@ static int _lv_activate_lv(struct logical_volume *lv)
 	return r;
 }
 
-static int _lv_preload(struct logical_volume *lv)
+static int _lv_preload(struct logical_volume *lv, int *flush_required)
 {
 	int r;
 	struct dev_manager *dm;
@@ -597,7 +597,7 @@ static int _lv_preload(struct logical_volume *lv)
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_preload(dm, lv)))
+	if (!(r = dev_manager_preload(dm, lv, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -619,7 +619,7 @@ static int _lv_deactivate(struct logical_volume *lv)
 	return r;
 }
 
-static int _lv_suspend_lv(struct logical_volume *lv, int lockfs)
+static int _lv_suspend_lv(struct logical_volume *lv, int lockfs, int flush_required)
 {
 	int r;
 	struct dev_manager *dm;
@@ -627,7 +627,7 @@ static int _lv_suspend_lv(struct logical_volume *lv, int lockfs)
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_suspend(dm, lv, lockfs)))
+	if (!(r = dev_manager_suspend(dm, lv, lockfs, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -845,7 +845,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 {
 	struct logical_volume *lv = NULL, *lv_pre = NULL;
 	struct lvinfo info;
-	int r = 0, lockfs = 0;
+	int r = 0, lockfs = 0, flush_required = 0;
 
 	if (!activation())
 		return 1;
@@ -873,7 +873,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 
 	/* If VG was precommitted, preload devices for the LV */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
-		if (!_lv_preload(lv_pre)) {
+		if (!_lv_preload(lv_pre, &flush_required)) {
 			/* FIXME Revert preloading */
 			goto_out;
 		}
@@ -888,7 +888,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (lv_is_origin(lv_pre) || lv_is_cow(lv_pre))
 		lockfs = 1;
 
-	if (!_lv_suspend_lv(lv, lockfs)) {
+	if (!_lv_suspend_lv(lv, lockfs, flush_required)) {
 		memlock_dec();
 		fs_unlock();
 		goto out;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3157f5f..0b22730 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -49,6 +49,7 @@ struct dev_manager {
 
 	void *target_state;
 	uint32_t pvmove_mirror_count;
+	int flush_required;
 
 	char *vg_name;
 };
@@ -1164,7 +1165,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
-		if ((lv->status & MIRRORED) && !(lv->status & PVMOVE))
+		if (!dm->flush_required && (lv->status & MIRRORED) && !(lv->status & PVMOVE))
 			dm_tree_use_no_flush_suspend(root);
 	case SUSPEND_WITH_LOCKFS:
 		if (!dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
@@ -1180,6 +1181,9 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 		if (!dm_tree_preload_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;
 
+		if (dm_tree_node_size_changed(root))
+			dm->flush_required = 1;
+
 		if ((action == ACTIVATE) &&
 		    !dm_tree_activate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;
@@ -1210,13 +1214,19 @@ int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv)
 	return _tree_action(dm, lv, CLEAN);
 }
 
-int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv)
+int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
+			int *flush_required)
 {
 	/* FIXME Update the pvmove implementation! */
 	if ((lv->status & PVMOVE) || (lv->status & LOCKED))
 		return 1;
 
-	return _tree_action(dm, lv, PRELOAD);
+	if (!_tree_action(dm, lv, PRELOAD))
+		return 0;
+
+	*flush_required = dm->flush_required;
+
+	return 1;
 }
 
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv)
@@ -1231,8 +1241,10 @@ int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv)
 }
 
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
-			int lockfs)
+			int lockfs, int flush_required)
 {
+	dm->flush_required = flush_required;
+
 	return _tree_action(dm, lv, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND);
 }
 
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 7a76453..f064504 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -49,9 +49,10 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 			       struct logical_volume *lv, int wait,
 			       float *percent, uint32_t *event_nr);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
-			int lockfs);
+			int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv);
-int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv);
+int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
+			int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
 
 int dev_manager_lv_mknodes(const struct logical_volume *lv);
diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index a6e04f8..2c80b05 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -49,6 +49,7 @@ dm_tree_node_get_name
 dm_tree_node_get_uuid
 dm_tree_node_get_info
 dm_tree_node_get_context
+dm_tree_node_size_changed
 dm_tree_node_num_children
 dm_tree_node_num_parents
 dm_tree_find_node
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 93aecbb..a6e2530 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -288,6 +288,7 @@ const char *dm_tree_node_get_name(struct dm_tree_node *node);
 const char *dm_tree_node_get_uuid(struct dm_tree_node *node);
 const struct dm_info *dm_tree_node_get_info(struct dm_tree_node *node);
 void *dm_tree_node_get_context(struct dm_tree_node *node);
+int dm_tree_node_size_changed(struct dm_tree_node *dnode);
 
 /*
  * Returns the number of children of the given node (excluding the root node).
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 11428ca..179cf95 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -640,6 +640,11 @@ void *dm_tree_node_get_context(struct dm_tree_node *node)
 	return node->context;
 }
 
+int dm_tree_node_size_changed(struct dm_tree_node *dnode)
+{
+	return dnode->props.size_changed;
+}
+
 int dm_tree_node_num_children(struct dm_tree_node *node, uint32_t inverted)
 {
 	if (inverted) {
@@ -1481,6 +1486,10 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			}
 		}
 
+		/* Propagate device size change change */
+		if (child->props.size_changed)
+			dnode->props.size_changed = 1;
+
 		/* Resume device immediately if it has parents and its size changed */
 		if (!dm_tree_node_num_children(child, 1) || !child->props.size_changed)
 			continue;
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 5737558..966e33b 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -550,12 +550,6 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		lp->resize = LV_EXTEND;
 	}
 
-	if (lp->mirrors && activation() &&
-	    lv_info(cmd, lv, &info, 0, 0) && info.exists) {
-		log_error("Mirrors cannot be resized while active yet.");
-		return ECMD_FAILED;
-	}
-
 	if (lv_is_origin(lv)) {
 		if (lp->resize == LV_REDUCE) {
 			log_error("Snapshot origin volumes cannot be reduced "




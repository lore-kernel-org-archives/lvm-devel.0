From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 23 Feb 2013 09:41:48 +0000 (UTC)
Subject: master - thin: replace _thin_layer with lv_layer()
Message-ID: <20130223094148.A462F40A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=520cc9a7f86282a230d8e6eef0edcac9dd94a8cd
Commit:        520cc9a7f86282a230d8e6eef0edcac9dd94a8cd
Parent:        78b23f35950f9d5dd502495325aa019b793c8052
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 18 09:53:05 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 23 10:28:04 2013 +0100

thin: replace  _thin_layer with lv_layer()

Use consitently lv_layer function internally for thin pool layer name.
---
 lib/activate/dev_manager.c |   20 ++++++++++----------
 lib/thin/thin.c            |    2 +-
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index deaab9f..c0cee4c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -59,8 +59,6 @@ struct lv_layer {
 	const char *old_name;
 };
 
-static const char _thin_layer[] = "tpool";
-
 int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts)
 {
 	return (laopts->read_only || !(lv->vg->status & LVM_WRITE) || !(lv->status & LVM_WRITE));
@@ -1137,7 +1135,7 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 	int r = 0;
 
 	/* Build dlid for the thin pool layer */
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, _thin_layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
 		return_0;
 
 	log_debug_activation("Getting thin pool device status for %s.", lv->name);
@@ -1178,10 +1176,10 @@ int dev_manager_thin_pool_percent(struct dev_manager *dm,
 
 	/* Build a name for the top layer */
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name,
-				      _thin_layer)))
+				      lv_layer(lv))))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, _thin_layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
 		return_0;
 
 	log_debug_activation("Getting device status percentage for %s", name);
@@ -1618,10 +1616,10 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/* FIXME code from _create_partial_dtree() should be moved here */
 		if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, 0), 0))
 			return_0;
-		if (!_add_dev_to_dtree(dm, dtree, lv, _thin_layer))
+		if (!_add_dev_to_dtree(dm, dtree, lv, lv_layer(lv)))
 			return_0;
 		/* If the partial tree is used for deactivation, setup callback */
-		if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, _thin_layer)))
+		if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, lv_layer(lv))))
 			return_0;
 		if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
 		    !_thin_pool_register_callback(dm, thin_node, lv))
@@ -2046,11 +2044,13 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	} else if (lv_is_cow(seg->lv) && !layer) {
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
-	} else if ((layer != _thin_layer) && seg_is_thin(seg)) {
+	} else if ((layer != lv_layer(seg->lv)) && seg_is_thin(seg)) {
 		lva = *laopts;
 		lva.real_pool = 1;
 		if (!_add_new_lv_to_dtree(dm, dtree, seg_is_thin_pool(seg) ?
-					  seg->lv : seg->pool_lv, &lva, _thin_layer))
+					  seg->lv : seg->pool_lv, &lva,
+					  seg_is_thin_pool(seg) ?
+					  lv_layer(seg->lv) : lv_layer(seg->pool_lv)))
 			return_0;
 	} else {
 		if (seg_is_thin_pool(seg) &&
@@ -2405,7 +2405,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 	/* Restore fs cookie */
 	dm_tree_set_cookie(root, fs_get_cookie());
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, (lv_is_origin(lv) && laopts->origin_only) ? "real" : NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, laopts->origin_only ? lv_layer(lv) : NULL)))
 		goto_out;
 
 	/* Only process nodes with uuid of "LVM-" plus VG id. */
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 8c0ec82..06ab67b 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -496,7 +496,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 	char *pool_dlid;
 	uint32_t device_id = seg->device_id;
 
-	if (!(pool_dlid = build_dm_uuid(mem, seg->pool_lv->lvid.s, "tpool"))) {
+	if (!(pool_dlid = build_dm_uuid(mem, seg->pool_lv->lvid.s, lv_layer(seg->pool_lv)))) {
 		log_error("Failed to build uuid for pool LV %s.",
 			  seg->pool_lv->name);
 		return 0;



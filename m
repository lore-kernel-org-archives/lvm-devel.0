From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:52:13 -0000
Subject: LVM2/lib activate/activate.h activate/dev_mana ...
Message-ID: <20111103145213.28719.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:52:10

Modified files:
	lib/activate   : activate.h dev_manager.c 
	lib/thin       : thin.c 

Log message:
	Add -tpool layer in activation tree
	
	Let's put the overlay device over real thin pool device.
	So we can get the proper locking on cluster.
	Overwise the pool LV would be activate once implicitely
	and in other case explicitely, confusing locking mechanism.
	This patch make the activation of pool LV independent on
	activation of thin LV since they will both implicitely use
	real -thin pool device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.247&r2=1.248
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/lib/activate/activate.h	2011/10/17 14:18:07	1.84
+++ LVM2/lib/activate/activate.h	2011/11/03 14:52:09	1.85
@@ -34,6 +34,7 @@
 	int exclusive;
 	int origin_only;
 	int no_merging;
+	int real_pool;
 	unsigned revert;
 };
 
--- LVM2/lib/activate/dev_manager.c	2011/10/28 20:34:45	1.247
+++ LVM2/lib/activate/dev_manager.c	2011/11/03 14:52:09	1.248
@@ -1100,13 +1100,16 @@
 		return_0;
 
 	if (lv_is_thin_pool(lv)) {
-		    if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->pool_metadata_lv, origin_only))
-			    return_0;
-		    if (!_add_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), origin_only))
-			    return_0;
+		if (!_add_dev_to_dtree(dm, dtree, lv, "tpool"))
+			return_0;
+		if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->pool_metadata_lv, origin_only))
+			return_0;
+		/* FIXME code from _create_partial_dtree() should be moved here */
+		if (!_add_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), origin_only))
+			return_0;
 	} else if (lv_is_thin_volume(lv)) {
-		    if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->pool_lv, origin_only))
-			    return_0;
+		if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->pool_lv, origin_only))
+			return_0;
 	}
 
 	return 1;
@@ -1451,6 +1454,7 @@
 	struct dm_list *snh;
 	struct lv_segment *seg_present;
 	const char *target_name;
+	struct lv_activate_opts lva;
 
 	/* Ensure required device-mapper targets are loaded */
 	seg_present = find_cow(seg->lv) ? : seg;
@@ -1495,13 +1499,18 @@
 	} else if (lv_is_cow(seg->lv) && !layer) {
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
-	} else if (lv_is_thin_volume(seg->lv)) {
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->pool_lv, laopts, NULL))
+	} else if (!layer && (lv_is_thin_pool(seg->lv) ||
+			      lv_is_thin_volume(seg->lv))) {
+		lva = *laopts;
+		lva.real_pool = 1;
+		if (!_add_new_lv_to_dtree(dm, dtree, lv_is_thin_pool(seg->lv) ?
+					  seg->lv : seg->pool_lv, &lva, "tpool"))
 			return_0;
 	} else {
 		if (lv_is_thin_pool(seg->lv) &&
 		    !_add_new_lv_to_dtree(dm, dtree, seg->pool_metadata_lv, laopts, NULL))
 			return_0;
+
 		/* Add any LVs used by this segment */
 		for (s = 0; s < seg->area_count; s++) {
 			if ((seg_type(seg, s) == AREA_LV) &&
--- LVM2/lib/thin/thin.c	2011/11/03 14:45:01	1.29
+++ LVM2/lib/thin/thin.c	2011/11/03 14:52:10	1.30
@@ -223,6 +223,21 @@
 	char *metadata_dlid, *pool_dlid;
 	const struct lv_thin_message *lmsg;
 
+	if (!laopts->real_pool) {
+		if (!(pool_dlid = build_dm_uuid(mem, seg->lv->lvid.s, "tpool"))) {
+			log_error("Failed to build uuid for thin pool LV %s.", seg->pool_lv->name);
+			return 0;
+		}
+
+		//if (!dm_tree_node_add_thin_target(node, len, pool_dlid,
+		//				    DM_THIN_ERROR_DEVICE_ID))
+		if (!dm_tree_node_add_linear_target(node, len) ||
+		    !dm_tree_node_add_target_area(node, NULL, pool_dlid, 0))
+			return_0;
+
+		return 1;
+	}
+
 	if (!(metadata_dlid = build_dm_uuid(mem, seg->pool_metadata_lv->lvid.s, NULL))) {
 		log_error("Failed to build uuid for metadata LV %s.",
 			  seg->pool_metadata_lv->name);
@@ -356,14 +371,29 @@
 				 struct dm_tree_node *node, uint64_t len,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
-	char *thin_pool_dlid;
+	char *pool_dlid;
+	uint32_t device_id = seg->device_id;
 
-	if (!(thin_pool_dlid = build_dm_uuid(mem, seg->pool_lv->lvid.s, NULL))) {
-		log_error("Failed to build uuid for thin pool LV %s.", seg->pool_lv->name);
+	if (!(pool_dlid = build_dm_uuid(mem, seg->pool_lv->lvid.s, "tpool"))) {
+		log_error("Failed to build uuid for pool LV %s.",
+			  seg->pool_lv->name);
 		return 0;
 	}
 
-	if (!dm_tree_node_add_thin_target(node, len, thin_pool_dlid, seg->device_id))
+#if 0
+{
+	/* If we would need to activate 'to be deleted' thin LVs */
+	struct lv_thin_message *tmsg;
+	dm_list_iterate_items(tmsg, &first_seg(seg->pool_lv)->thin_messages)
+		/* If this node is going to be deleted - use the error target */
+		if ((tmsg->type == DM_THIN_MESSAGE_DELETE) &&
+		    (tmsg->u.delete_id == seg->device_id)) {
+			device_id = DM_THIN_ERROR_DEVICE_ID;
+			break;
+		}
+}
+#endif
+	if (!dm_tree_node_add_thin_target(node, len, pool_dlid, device_id))
 		return_0;
 
 	return 1;



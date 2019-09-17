From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 17 Sep 2019 07:19:02 -0400
Subject: master - vdo: enhance activation with layer -vpool
Message-ID: <201909171119.x8HBJ2fr025639@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6612d8dd5e77eab1b24cafccffa83e65a504c94f
Commit:        6612d8dd5e77eab1b24cafccffa83e65a504c94f
Parent:        66f69e766e576692ea32328c1921acbacb69ed14
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 14 01:13:33 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 17 13:17:19 2019 +0200

vdo: enhance activation with layer -vpool

Enhance 'activation' experience for VDO pool to more closely match
what happens for thin-pools where we do use a 'fake' LV to keep pool
running even when no thinLVs are active. This gives user a choice
whether he want to keep thin-pool running (wihout possibly lenghty
activation/deactivation process)

As we do plan to support multple VDO LVs to be mapped into a single VDO,
we want to give user same experience and 'use-patter' as with thin-pools.

This patch gives option to activate VDO pool only without activating
VDO LV.

Also due to 'fake' layering LV we can protect usage of VDO pool from
command like 'mkfs' which do require exlusive access to the volume,
which is no longer possible.

Note: VDO pool contains 1024 initial sectors as 'empty' header - such
header is also exposed in layered LV (as read-only LV).
For blkid we are indentified as LV with UUID suffix - thus private DM
device of lvm2 - so we do not need to store any extra info in this
header space (aka zero is good enough).
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |   14 +++++++++++++-
 lib/activate/dev_manager.c |   35 +++++++++++++++++++++++++++++------
 lib/metadata/vdo_manip.c   |    2 +-
 lib/misc/lvm-string.c      |    2 +-
 tools/lvchange.c           |    3 ---
 6 files changed, 45 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 81a73ef..a9bd750 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Allow standalone activation of VDO pool just like for thin-pools.
   Activate thin-pool layered volume as 'read-only' device.
   Ignore crypto devices with UUID signature CRYPT-SUBDEV.
   Enhance validation for thin and cache pool conversion and swapping.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 38e21be..29cd2d3 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -794,6 +794,18 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 		return 1;
 	}
 
+	if (lv_is_vdo_pool(lv)) {
+		/* Always collect status for '-vpool' */
+		if (_lv_info(cmd, lv, 1, &status->info, lv_seg, &status->seg_status, 0, 0) &&
+		    (status->seg_status.type == SEG_STATUS_VDO_POOL)) {
+			/* There is -tpool device, but query 'active' state of 'fake' vdo-pool */
+			if (!_lv_info(cmd, lv, 0, NULL, NULL, NULL, 0, 0))
+				status->info.exists = 0; /* So VDO pool LV is not active */
+		}
+
+		return 1;
+	}
+
 	return _lv_info(cmd, lv, 0, &status->info, lv_seg, &status->seg_status,
 			with_open_count, with_read_ahead);
 }
@@ -1342,7 +1354,7 @@ int lv_vdo_pool_status(const struct logical_volume *lv, int flush,
 	int r = 0;
 	struct dev_manager *dm;
 
-	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
+	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
 		return 0;
 
 	log_debug_activation("Checking VDO pool status for LV %s.",
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 32fdcb9..5ee5efe 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1991,7 +1991,7 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, const struct logical_vol
 		/* New thin-pool is regular LV with -tpool UUID suffix. */
 		udev_flags |= DM_UDEV_DISABLE_DISK_RULES_FLAG |
 		              DM_UDEV_DISABLE_OTHER_RULES_FLAG;
-	else if (layer || !lv_is_visible(lv) || lv_is_thin_pool(lv))
+	else if (layer || !lv_is_visible(lv) || lv_is_thin_pool(lv) || lv_is_vdo_pool(lv))
 		udev_flags |= DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG |
 			      DM_UDEV_DISABLE_DISK_RULES_FLAG |
 			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;
@@ -2611,6 +2611,15 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		}
 	}
 
+	if (lv_is_vdo_pool(lv)) {
+		/*
+		 * For both origin_only and !origin_only
+		 * skips test for -vpool-real and vpool-cow
+		 */
+		if (!_add_dev_to_dtree(dm, dtree, lv, lv_layer(lv)))
+			return_0;
+	}
+
 	if (lv_is_cache(lv)) {
 		if (!origin_only && !dm->activation && !dm->track_pending_delete) {
 			/* Setup callback for non-activation partial tree */
@@ -2682,7 +2691,8 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s) &&
 			    /* origin only for cache without pending delete */
 			    (!dm->track_pending_delete || !lv_is_cache(lv)) &&
-			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
+			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s),
+					      lv_is_vdo_pool(seg_lv(seg, s)) ? 1 : 0))
 				return_0;
 			if (seg_is_raid_with_meta(seg) && seg->meta_areas && seg_metalv(seg, s) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 0))
@@ -2908,8 +2918,11 @@ static int _add_layer_target_to_dtree(struct dev_manager *dm,
 	if (!(layer_dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
 		return_0;
 
+
 	/* Add linear mapping over layered LV */
-	if (!add_linear_area_to_dtree(dnode, lv->size, lv->vg->extent_size,
+	/* From VDO layer expose ONLY vdo pool header, we would need to use virtual size otherwise */
+	if (!add_linear_area_to_dtree(dnode, lv_is_vdo_pool(lv) ? first_seg(lv)->vdo_pool_header_size : lv->size,
+				      lv->vg->extent_size,
 				      lv->vg->cmd->use_linear_target,
 				      lv->vg->name, lv->name) ||
 	    !dm_tree_node_add_target_area(dnode, NULL, layer_dlid, 0))
@@ -3132,7 +3145,9 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		    /* origin only for cache without pending delete */
 		    (!dm->track_pending_delete || !seg_is_cache(seg)) &&
 		    !_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
-					  laopts, NULL))
+					  laopts,
+					  lv_is_vdo_pool(seg_lv(seg, s)) ?
+					  lv_layer(seg_lv(seg, s)) : NULL))
 			return_0;
 		if (seg_is_raid_with_meta(seg) && seg->meta_areas && seg_metalv(seg, s) &&
 		    !lv_is_raid_image_with_tracking(seg_lv(seg, s)) &&
@@ -3424,8 +3439,9 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		if (!_add_snapshot_target_to_dtree(dm, dnode, lv, laopts))
 			return_0;
 	} else if (!layer && ((lv_is_thin_pool(lv) && !lv_is_new_thin_pool(lv)) ||
+                              lv_is_vdo_pool(lv) ||
 			      lv_is_external_origin(lv))) {
-		/* External origin or 'used' Thin pool is using layer */
+		/* External origin or 'used' Thin pool or VDO pool is using layer */
 		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, lv_layer(lv)))
 			return_0;
 		if (!_add_layer_target_to_dtree(dm, dnode, lv))
@@ -3438,6 +3454,10 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			if (max_stripe_size < seg->stripe_size * seg->area_count)
 				max_stripe_size = seg->stripe_size * seg->area_count;
 		}
+
+		if (!layer && lv_is_vdo_pool(lv) &&
+		    !_add_layer_target_to_dtree(dm, dnode, lv))
+			return_0;
 	}
 
 	/* Setup thin pool callback */
@@ -3705,7 +3725,10 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		/* Add all required new devices to tree */
 		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts,
 					  (lv_is_origin(lv) && laopts->origin_only) ? "real" :
-					  (lv_is_thin_pool(lv) && laopts->origin_only) ? "tpool" : NULL))
+					  (laopts->origin_only &&
+					   (lv_is_thin_pool(lv) ||
+					    lv_is_vdo_pool(lv))) ?
+					  lv_layer(lv) : NULL))
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 4be9d2b..548b4ad 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -159,7 +159,7 @@ int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_
 	status->data_usage = DM_PERCENT_INVALID;
 
 	if (!(dm_name = dm_build_dm_name(mem, vdo_pool_lv->vg->name,
-					 vdo_pool_lv->name, NULL))) {
+					 vdo_pool_lv->name, lv_layer(vdo_pool_lv)))) {
 		log_error("Failed to build VDO DM name %s.",
 			  display_lvname(vdo_pool_lv));
 		return 0;
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 901243c..fe24f23 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -259,7 +259,7 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 			lv_is_thin_pool(lv) ? "pool" :
 			lv_is_thin_pool_data(lv) ? "tdata" :
 			lv_is_thin_pool_metadata(lv) ? "tmeta" :
-			lv_is_vdo_pool(lv) ? "vpool" :
+			lv_is_vdo_pool(lv) ? "pool" :
 			lv_is_vdo_pool_data(lv) ? "vdata" :
 			NULL;
 	}
diff --git a/tools/lvchange.c b/tools/lvchange.c
index c28a7bb..03a7793 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1400,9 +1400,6 @@ static int _lvchange_activate_check(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_is_vdo_pool(lv) && !lv_is_named_arg)
-		return 0;	/* Skip VDO pool processing unless explicitely named */
-
 	return 1;
 }
 



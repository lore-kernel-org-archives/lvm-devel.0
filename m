From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:32 -0400
Subject: master - cleanup: display_lvname update message
Message-ID: <201804201102.w3KB2Wci031356@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d437bd86ffcb8dc589ddf941ec7c12d493c89b33
Commit:        d437bd86ffcb8dc589ddf941ec7c12d493c89b33
Parent:        7323557379d9dc40e68203a467e8ec541e512789
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 27 21:08:20 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:17:01 2018 +0200

cleanup: display_lvname update message

Add more display_lvname usage.
Update some error messages.
Indent.
---
 lib/metadata/mirror.c |   39 ++++++++++++++++++++-------------------
 tools/pvmove.c        |    2 +-
 2 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 8fcf94e..13e1474 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -606,12 +606,12 @@ static int _mirrored_lv_in_sync(struct logical_volume *lv)
 			       NULL)) {
 		if (lv_is_active_but_not_locally(lv))
 			log_error("Unable to determine mirror sync status of"
-				  " remotely active LV, %s/%s",
-				  lv->vg->name, lv->name);
+				  " remotely active LV, %s",
+				  display_lvname(lv));
 		else
 			log_error("Unable to determine mirror "
-				  "sync status of %s/%s.",
-				  lv->vg->name, lv->name);
+				  "sync status of %s.",
+				  display_lvname(lv));
 		return 0;
 	}
 
@@ -700,7 +700,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 
 	new_lv->name = dm_pool_strdup(lv->vg->vgmem, split_name);
 	if (!new_lv->name) {
-		log_error("Unable to rename newly split LV");
+		log_error("Unable to rename newly split LV.");
 		return 0;
 	}
 
@@ -1141,14 +1141,14 @@ int collapse_mirrored_lv(struct logical_volume *lv)
 	while ((tmp_lv = find_temporary_mirror(lv))) {
 		mirror_seg = find_mirror_seg(first_seg(tmp_lv));
 		if (!mirror_seg) {
-			log_error("Failed to find mirrored LV for %s",
-				  tmp_lv->name);
+			log_error("Failed to find mirrored LV for %s.",
+				  display_lvname(tmp_lv));
 			return 0;
 		}
 
 		if (!_mirrored_lv_in_sync(mirror_seg->lv)) {
-			log_verbose("Not collapsing %s: out-of-sync",
-				    mirror_seg->lv->name);
+			log_verbose("Not collapsing %s: out-of-sync.",
+				    display_lvname(mirror_seg->lv));
 			return 1;
 		}
 
@@ -1339,8 +1339,8 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 
 	for (m = 0; m < num_mirrors; m++) {
 		if (!(img_lvs[m] = lv_create_empty(img_name,
-					     NULL, LVM_READ | LVM_WRITE,
-					     ALLOC_INHERIT, lv->vg))) {
+						   NULL, LVM_READ | LVM_WRITE,
+						   ALLOC_INHERIT, lv->vg))) {
 			log_error("Aborting. Failed to create mirror image LV. "
 				  "Remove new LV and retry.");
 			return 0;
@@ -1352,7 +1352,7 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 			if (!lv_add_log_segment(ah, first_area, img_lvs[m], 0)) {
 				log_error("Failed to add mirror image segment"
 					  " to %s. Remove new LV and retry.",
-					  img_lvs[m]->name);
+					  display_lvname(img_lvs[m]));
 				return 0;
 			}
 		} else {
@@ -1361,7 +1361,7 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 					    stripe_size, 0, 0)) {
 				log_error("Aborting. Failed to add mirror image segment "
 					  "to %s. Remove new LV and retry.",
-					  img_lvs[m]->name);
+					  display_lvname(img_lvs[m]));
 				return 0;
 			}
 		}
@@ -1385,13 +1385,14 @@ int remove_mirrors_from_segments(struct logical_volume *lv,
 	/* Check the segment params are compatible */
 	dm_list_iterate_items(seg, &lv->segments) {
 		if (!seg_is_mirrored(seg)) {
-			log_error("Segment is not mirrored: %s:%" PRIu32,
-				  lv->name, seg->le);
+			log_error("Segment is not mirrored: %s:" FMTu32,
+				  display_lvname(lv), seg->le);
 			return 0;
 		}
 		if ((seg->status & status_mask) != status_mask) {
-			log_error("Segment status does not match: %s:%" PRIu32
-				  " status:0x%" PRIx64 "/0x%" PRIx64, lv->name, seg->le,
+			log_error("Segment status does not match: %s:" FMTu32
+				  " status:0x" FMTx64 "/0x" FMTx64,
+				  display_lvname(lv), seg->le,
 				  seg->status, status_mask);
 			return 0;
 		}
@@ -1523,7 +1524,7 @@ struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 	uint32_t s;
 
 	if (!(lvs = dm_pool_alloc(cmd->mem, sizeof(*lvs)))) {
-		log_error("lvs list alloc failed");
+		log_error("lvs list alloc failed.");
 		return NULL;
 	}
 
@@ -1542,7 +1543,7 @@ struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 				    seg_lv(seg, s) != lv)
 					continue;
 				if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
-					log_error("lv_list alloc failed");
+					log_error("lv_list alloc failed.");
 					return NULL;
 				}
 				lvl->lv = lv1;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 9ad17f6..754bd58 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -465,7 +465,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			/* With exclusive pvmove skip LV when:
 			 *  - is active remotely
 			 *  - is not active locally and cannot be activated exclusively locally
-                         *
+			 *
 			 * Note: lvm2 can proceed with exclusive pvmove for 'just' locally active LVs
 			 * in the case it's NOT active anywhere else, since LOCKED LVs cannot be
 			 * later activated by user.



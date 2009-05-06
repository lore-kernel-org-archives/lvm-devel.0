From: Milan Broz <mbroz@redhat.com>
Date: Wed,  6 May 2009 16:42:59 +0200
Subject: [PATCH 2/7] Never set mirror log and images directly visible in metadata.
In-Reply-To: <cover.1241620083.git.mbroz@redhat.com>
References: <cover.1241620083.git.mbroz@redhat.com>
Message-ID: <a3d0392fa15ad5ecbc874cb5419a0177011655ed.1241620083.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Mirror creation and conversion force set mirror log and images
to be visible. This can violate VG max_lv restriction on LV.

There is no need to set these volumes visible, even during
mirror images conversion.

The log must be cleared, but the requested symlink is created
if the volume is manipulated directly.

[Is it true for udev?]

[Is there some side effect on cluster with this patch?]

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/mirror.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 5eb53f4..678e54f 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -259,9 +259,6 @@ static int _init_mirror_log(struct cmd_context *cmd,
 		was_active = 1;
 	}
 
-	/* Temporary make it visible for set_lv() */
-	log_lv->status |= VISIBLE_LV;
-
 	/* Temporary tag mirror log for activation */
 	dm_list_iterate_items(sl, tags)
 		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
@@ -275,6 +272,10 @@ static int _init_mirror_log(struct cmd_context *cmd,
 
 	backup(log_lv->vg);
 
+	/*
+	 * Directly activating log_lv will create symlink for set_lv,
+	 * even then log_lv is never directly visible
+	 */
 	if (!activate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to activate mirror log.");
 		goto revert_new_lv;
@@ -303,8 +304,6 @@ static int _init_mirror_log(struct cmd_context *cmd,
 		return 0;
 	}
 
-	log_lv->status &= ~VISIBLE_LV;
-
 	if (was_active && !activate_lv(cmd, log_lv))
 		return_0;
 
@@ -410,7 +409,6 @@ struct logical_volume *detach_mirror_log(struct lv_segment *mirrored_seg)
 
 	log_lv = mirrored_seg->log_lv;
 	mirrored_seg->log_lv = NULL;
-	log_lv->status |= VISIBLE_LV;
 	log_lv->status &= ~MIRROR_LOG;
 	remove_seg_from_segs_using_this_lv(log_lv, mirrored_seg);
 
@@ -536,7 +534,6 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	dm_list_init(&tmp_orphan_lvs);
 	for (m = new_area_count; m < mirrored_seg->area_count; m++) {
 		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
-		seg_lv(mirrored_seg, m)->status |= VISIBLE_LV;
 		if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl)))) {
 			log_error("lv_list alloc failed");
 			return 0;
@@ -554,7 +551,6 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	if (new_area_count == 1 && !is_temporary_mirror_layer(lv)) {
 		lv1 = seg_lv(mirrored_seg, 0);
 		lv1->status &= ~MIRROR_IMAGE;
-		lv1->status |= VISIBLE_LV;
 		detached_log_lv = detach_mirror_log(mirrored_seg);
 		if (!remove_layer_from_lv(lv, lv1))
 			return_0;
@@ -1265,7 +1261,7 @@ static struct logical_volume *_create_mirror_log(struct logical_volume *lv,
 	}
 
 	if (!(log_lv = lv_create_empty(log_name, NULL,
-				       VISIBLE_LV | LVM_READ | LVM_WRITE,
+				       LVM_READ | LVM_WRITE,
 				       alloc, 0, lv->vg)))
 		return_NULL;
 
-- 
1.6.2.4



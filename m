From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 17:24:29 +0200
Subject: [PATCH 6/9] Introduce lv_set_visible & lv_set_hidden and use lv_is_visible always.
In-Reply-To: <cover.1242227458.git.mbroz@redhat.com>
References: <cover.1242227458.git.mbroz@redhat.com>
Message-ID: <147fdad1e94de8a66aaa3b20ab99b66ff0eb3ce2.1242227458.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The vg->lv_count parameter now includes always number of visible
logical volumes.

Note that virtual snapshot volume (snapshotX) is never visible,
but it is stored in metadata with visible flag, so code
uses exception here.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c          |    4 ++--
 lib/metadata/lv_manip.c          |   22 +++++++++++++++++++++-
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/mirror.c            |   12 ++++++------
 lib/metadata/snapshot_manip.c    |    5 +++--
 5 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7011a09..e38c4d8 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -647,7 +647,7 @@ static int _lvs_in_vg_activated(struct volume_group *vg, unsigned by_uuid_only)
 		return 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lvl->lv->status & VISIBLE_LV)
+		if (lv_is_visible(lvl->lv))
 			count += (_lv_active(vg->cmd, lvl->lv, by_uuid_only) == 1);
 	}
 
@@ -996,7 +996,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 		goto out;
 	}
 
-	if (info.open_count && (lv->status & VISIBLE_LV)) {
+	if (info.open_count && lv_is_visible(lv)) {
 		log_error("LV %s/%s in use: not deactivating", lv->vg->name,
 			  lv->name);
 		goto out;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index da2f250..068d745 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1504,7 +1504,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 		if (!set_lv_segment_area_lv(seg, m, sub_lvs[m - old_area_count],
 					    0, status))
 			return_0;
-		sub_lvs[m - old_area_count]->status &= ~VISIBLE_LV;
+		lv_set_hidden(sub_lvs[m - old_area_count]);
 	}
 
 	lv->status |= MIRRORED;
@@ -1961,6 +1961,26 @@ int vg_unlink_lv(struct logical_volume *lv)
 	return 1;
 }
 
+void lv_set_visible(struct logical_volume *lv)
+{
+	if (lv_is_visible(lv))
+		return;
+
+	lv->status |= VISIBLE_LV;
+
+	log_debug("LV %s in VG %s is now visible.",  lv->name, lv->vg->name);
+}
+
+void lv_set_hidden(struct logical_volume *lv)
+{
+	if (!lv_is_visible(lv))
+		return;
+
+	lv->status &= ~VISIBLE_LV;
+
+	log_debug("LV %s in VG %s is now hidden.",  lv->name, lv->vg->name);
+}
+
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		     const force_t force)
 {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d534386..64b30f7 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -370,6 +370,8 @@ struct dm_list *get_pvs(struct cmd_context *cmd);
 
 int vg_link_lv(struct volume_group *vg, struct logical_volume *lv);
 int vg_unlink_lv(struct logical_volume *lv);
+void lv_set_visible(struct logical_volume *lv);
+void lv_set_hidden(struct logical_volume *lv);
 
 /* Set full_scan to 1 to re-read every (filtered) device label */
 struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan);
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 5eb53f4..087ce73 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -260,7 +260,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	}
 
 	/* Temporary make it visible for set_lv() */
-	log_lv->status |= VISIBLE_LV;
+	lv_set_visible(log_lv);
 
 	/* Temporary tag mirror log for activation */
 	dm_list_iterate_items(sl, tags)
@@ -303,7 +303,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 		return 0;
 	}
 
-	log_lv->status &= ~VISIBLE_LV;
+	lv_set_hidden(log_lv);
 
 	if (was_active && !activate_lv(cmd, log_lv))
 		return_0;
@@ -410,7 +410,7 @@ struct logical_volume *detach_mirror_log(struct lv_segment *mirrored_seg)
 
 	log_lv = mirrored_seg->log_lv;
 	mirrored_seg->log_lv = NULL;
-	log_lv->status |= VISIBLE_LV;
+	lv_set_visible(log_lv);
 	log_lv->status &= ~MIRROR_LOG;
 	remove_seg_from_segs_using_this_lv(log_lv, mirrored_seg);
 
@@ -536,7 +536,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	dm_list_init(&tmp_orphan_lvs);
 	for (m = new_area_count; m < mirrored_seg->area_count; m++) {
 		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
-		seg_lv(mirrored_seg, m)->status |= VISIBLE_LV;
+		lv_set_visible(seg_lv(mirrored_seg, m));
 		if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl)))) {
 			log_error("lv_list alloc failed");
 			return 0;
@@ -554,7 +554,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	if (new_area_count == 1 && !is_temporary_mirror_layer(lv)) {
 		lv1 = seg_lv(mirrored_seg, 0);
 		lv1->status &= ~MIRROR_IMAGE;
-		lv1->status |= VISIBLE_LV;
+		lv_set_visible(lv1);
 		detached_log_lv = detach_mirror_log(mirrored_seg);
 		if (!remove_layer_from_lv(lv, lv1))
 			return_0;
@@ -1340,7 +1340,7 @@ int attach_mirror_log(struct lv_segment *seg, struct logical_volume *log_lv)
 {
 	seg->log_lv = log_lv;
 	log_lv->status |= MIRROR_LOG;
-	log_lv->status &= ~VISIBLE_LV;
+	lv_set_hidden(log_lv);
 	return add_seg_to_segs_using_this_lv(log_lv, seg);
 }
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 0509fe0..ff608c3 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -76,7 +76,8 @@ void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 	seg->origin = origin;
 	seg->cow = cow;
 
-	cow->status &= ~VISIBLE_LV;
+	lv_set_hidden(cow);
+
 	cow->snapshot = seg;
 
 	origin->origin_count++;
@@ -137,7 +138,7 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	}
 
 	cow->snapshot = NULL;
-	cow->status |= VISIBLE_LV;
+	lv_set_visible(cow);
 
 	return 1;
 }
-- 
1.6.2.4



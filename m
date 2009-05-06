From: Milan Broz <mbroz@redhat.com>
Date: Wed,  6 May 2009 16:43:02 +0200
Subject: [PATCH 5/7] Introduce lv_set_visible & lv_set_hidden and use lv_is_visible always.
In-Reply-To: <cover.1241620083.git.mbroz@redhat.com>
References: <cover.1241620083.git.mbroz@redhat.com>
Message-ID: <a69d7e8ab6e48759349210e94d8f96495af3f660.1241620083.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The vg->lv_count parameter now includes always number of visible
logical volumes.

Note that virtual snapshot volume (snapshotX) is never visible,
but it is stored in metadata with visible flag, so code
use exception here.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c          |    4 +-
 lib/metadata/lv_manip.c          |   45 ++++++++++++++++++++++++++-----------
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/metadata.c          |   16 ++++++++-----
 lib/metadata/mirror.c            |    2 +-
 lib/metadata/snapshot_manip.c    |   28 +++++++++++++++--------
 lib/snapshot/snapshot.c          |    9 ++-----
 tools/vgsplit.c                  |    2 +-
 8 files changed, 68 insertions(+), 40 deletions(-)

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
index 1903320..705fa2b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -432,13 +432,9 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 		return 1;
 
 	/* Remove the LV if it is now empty */
-	if (!lv->le_count) {
-		if(!vg_remove_lv(lv))
-			return_0;
-		//FIXME: cow still in VG, fix count, remove this later
-		if (lv->status & SNAPSHOT)
-			lv->vg->lv_count++;
-	} else if (lv->vg->fid->fmt->ops->lv_setup &&
+	if (!lv->le_count && !vg_remove_lv(lv))
+		return_0;
+	else if (lv->vg->fid->fmt->ops->lv_setup &&
 		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
 		return_0;
 
@@ -1507,7 +1503,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 		if (!set_lv_segment_area_lv(seg, m, sub_lvs[m - old_area_count],
 					    0, status))
 			return_0;
-		sub_lvs[m - old_area_count]->status &= ~VISIBLE_LV;
+		lv_set_hidden(sub_lvs[m - old_area_count]);
 	}
 
 	lv->status |= MIRRORED;
@@ -1866,10 +1862,6 @@ struct logical_volume *lv_create_empty(const char *name,
 	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv))
 		goto_bad;
 
-	//FIXME: remove that
-	if (import)
-		vg->lv_count--;
-
 	return lv;
 bad:
 	dm_pool_free(vg->vgmem, lv);
@@ -1953,7 +1945,8 @@ int vg_add_lv(struct volume_group *vg, struct logical_volume *lv)
 	lv->vg = vg;
 	dm_list_add(&vg->lvs, &lvl->list);
 
-	vg->lv_count++;
+	if (lv_is_visible(lv))
+		vg->lv_count++;
 
 	return 1;
 }
@@ -1967,11 +1960,35 @@ int vg_remove_lv(struct logical_volume *lv)
 
 	dm_list_del(&lvl->list);
 
-	lvl->lv->vg->lv_count--;
+	if (lv_is_visible(lvl->lv))
+		lvl->lv->vg->lv_count--;
 
 	return 1;
 }
 
+void lv_set_visible(struct logical_volume *lv)
+{
+	if (lv_is_visible(lv))
+		return;
+
+	if (lv->status & SNAPSHOT)
+		return;
+
+	log_debug("LV %s in VG %s is now visible.",  lv->name, lv->vg->name);
+	lv->status |= VISIBLE_LV;
+	lv->vg->lv_count++;
+}
+
+void lv_set_hidden(struct logical_volume *lv)
+{
+	if (!lv_is_visible(lv))
+		return;
+
+	log_debug("LV %s in VG %s is now hidden.",  lv->name, lv->vg->name);
+	lv->status &= ~VISIBLE_LV;
+	lv->vg->lv_count--;
+}
+
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		     const force_t force)
 {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 92942e1..ac5de87 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -369,6 +369,8 @@ struct dm_list *get_pvs(struct cmd_context *cmd);
 
 int vg_add_lv(struct volume_group *vg, struct logical_volume *lv);
 int vg_remove_lv(struct logical_volume *lv);
+void lv_set_visible(struct logical_volume *lv);
+void lv_set_hidden(struct logical_volume *lv);
 
 /* Set full_scan to 1 to re-read every (filtered) device label */
 struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 50762f6..745083b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1454,12 +1454,16 @@ int vg_validate(struct volume_group *vg)
 		r = 0;
 	}
 
-	if ((lv_count = (uint32_t) dm_list_size(&vg->lvs)) !=
-	    vg->lv_count + 2 * snapshot_lvs_in_vg(vg)) {
-		log_error("Internal error: #internal LVs (%u) != #LVs (%"
-			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
-			  dm_list_size(&vg->lvs), vg->lv_count,
-			  snapshot_lvs_in_vg(vg), vg->name);
+	lv_count = 0;
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_visible(lvl->lv))
+			lv_count++;
+
+	if (lv_count != vg->lv_count) {
+		log_error("Internal error: #internal visible LVs (%u) != "
+			  "visible #LVs (%u of %" PRIu32 ") in VG %s",
+			  lv_count, vg->lv_count, dm_list_size(&vg->lvs),
+			  vg->name);
 		r = 0;
 	}
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 678e54f..f46381e 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1336,7 +1336,7 @@ int attach_mirror_log(struct lv_segment *seg, struct logical_volume *log_lv)
 {
 	seg->log_lv = log_lv;
 	log_lv->status |= MIRROR_LOG;
-	log_lv->status &= ~VISIBLE_LV;
+	lv_set_hidden(log_lv);
 	return add_seg_to_segs_using_this_lv(log_lv, seg);
 }
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index cc57aeb..852ad76 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -30,8 +30,11 @@ int lv_is_cow(const struct logical_volume *lv)
 
 int lv_is_visible(const struct logical_volume *lv)
 {
+	if (lv->status & SNAPSHOT)
+		return 0;
+
 	if (lv_is_cow(lv))
-		return lv_is_visible(find_cow(lv)->lv);
+		return lv_is_visible(origin_from_cow(lv));
 
 	return lv->status & VISIBLE_LV ? 1 : 0;
 }
@@ -83,15 +86,15 @@ int vg_add_snapshot(struct logical_volume *origin,
 	}
 
 	/*
-	 * Set origin lv count in advance to prevent fail because
+	 * Remove COW from visible volumes in advance to prevent fail because
 	 * of temporary violation of LV limits.
 	 */
-	origin->vg->lv_count--;
+	lv_set_hidden(cow);
 
 	if (!(snap = lv_create_empty("snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
 				     ALLOC_INHERIT, 1, origin->vg))) {
-		origin->vg->lv_count++;
+		lv_set_visible(cow);
 		return_0;
 	}
 
@@ -108,11 +111,11 @@ int vg_add_snapshot(struct logical_volume *origin,
 	origin->origin_count++;
 	cow->snapshot = seg;
 
-	cow->status &= ~VISIBLE_LV;
-
         /* FIXME Assumes an invisible origin belongs to a sparse device */
-        if (!lv_is_visible(origin))
+        if (!lv_is_visible(origin)) {
+		origin->vg->lv_count--;
                 origin->status |= VIRTUAL_ORIGIN;
+	}
 
 	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
 
@@ -130,10 +133,15 @@ int vg_remove_snapshot(struct logical_volume *cow)
 		return 0;
 	}
 
-	cow->snapshot = NULL;
+	/*
+	 * Virtual snapshot volume was removed
+	 * LV count must be fixed...
+	 */
+        if (!lv_is_virtual_origin(cow->snapshot->origin))
+		cow->vg->lv_count--;
 
-	cow->vg->lv_count++;
-	cow->status |= VISIBLE_LV;
+	lv_set_visible(cow);
+	cow->snapshot = NULL;
 
 	return 1;
 }
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index ad5d158..4dc7111 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -78,17 +78,14 @@ static int _snap_text_import(struct lv_segment *seg, const struct config_node *s
 	seg->origin = org;
 	seg->cow = cow;
 
-	// FIXME: direct count manipulation to be removed later
-	cow->status &= ~VISIBLE_LV;
-	cow->vg->lv_count--;
 	cow->snapshot = seg;
-
 	org->origin_count++;
-	org->vg->lv_count--;
 
         /* FIXME Assumes an invisible origin belongs to a sparse device */
-        if (!lv_is_visible(org))
+        if (!lv_is_visible(org)) {
+		org->vg->lv_count--;
                 org->status |= VIRTUAL_ORIGIN;
+	}
 
 	seg->lv->status |= VIRTUAL;
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index c4b583a..a960302 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -106,7 +106,7 @@ static int _move_one_lv(struct volume_group *vg_from,
 		return 0;
 	}
 
-	if (!(lv->status & SNAPSHOT) && !lv_is_cow(lv)) {
+	if (lv_is_visible(lv)) {
 		vg_from->lv_count--;
 		vg_to->lv_count++;
 	}
-- 
1.6.2.4



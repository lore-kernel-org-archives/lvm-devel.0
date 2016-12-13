From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:09:51 +0000 (UTC)
Subject: master - cleanup: more lv_is_ usage
Message-ID: <20161213210952.0017F60C42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8f5e1f2744a568779445aa5def423f7e1210ee7
Commit:        a8f5e1f2744a568779445aa5def423f7e1210ee7
Parent:        47b96c3537968caf0cfb8ffa3874d64944715bec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 13 00:09:15 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 13 22:07:52 2016 +0100

cleanup: more  lv_is_  usage

---
 lib/format1/import-export.c     |    2 +-
 lib/format1/import-extents.c    |    2 +-
 lib/format_pool/import_export.c |    2 +-
 lib/format_text/import_vsn1.c   |    2 +-
 lib/locking/lvmlockd.c          |    2 +-
 lib/metadata/lv.c               |    2 +-
 lib/metadata/lv_manip.c         |    7 +++----
 lib/metadata/raid_manip.c       |    2 +-
 lib/metadata/snapshot_manip.c   |    2 +-
 tools/toollib.c                 |    2 +-
 tools/vgchange.c                |    4 ++--
 tools/vgconvert.c               |    2 +-
 tools/vgsplit.c                 |    4 ++--
 13 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 9b7f5ef..146623e 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -510,7 +510,7 @@ int export_lvs(struct disk_list *dl, struct volume_group *vg,
 		goto_out;
 
 	dm_list_iterate_items(ll, &vg->lvs) {
-		if (ll->lv->status & SNAPSHOT)
+		if (lv_is_snapshot(ll->lv))
 			continue;
 
 		if (!(lvdl = dm_pool_alloc(dl->mem, sizeof(*lvdl))))
diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
index 5cad4f2..3ab3ac4 100644
--- a/lib/format1/import-extents.c
+++ b/lib/format1/import-extents.c
@@ -56,7 +56,7 @@ static struct dm_hash_table *_create_lv_maps(struct dm_pool *mem,
 	}
 
 	dm_list_iterate_items(ll, &vg->lvs) {
-		if (ll->lv->status & SNAPSHOT)
+		if (lv_is_snapshot(ll->lv))
 			continue;
 
 		if (!(lvm = dm_pool_alloc(mem, sizeof(*lvm))))
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 1529df5..2f0f2eb 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -267,7 +267,7 @@ int import_pool_segments(struct dm_list *lvs, struct dm_pool *mem,
 	dm_list_iterate_items(lvl, lvs) {
 		lv = lvl->lv;
 
-		if (lv->status & SNAPSHOT)
+		if (lv_is_snapshot(lv))
 			continue;
 
 		for (i = 0; i < subpools; i++) {
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index e11b16b..00caf21 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -512,7 +512,7 @@ static int _read_segments(struct logical_volume *lv, const struct dm_config_node
 			count++;
 		}
 		/* FIXME Remove this restriction */
-		if ((lv->status & SNAPSHOT) && count > 1) {
+		if (lv_is_snapshot(lv) && count > 1) {
 			log_error("Only one segment permitted for snapshot");
 			return 0;
 		}
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 8acf69c..92a970a 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2651,7 +2651,7 @@ int lockd_lv_uses_lock(struct logical_volume *lv)
 	if (lv_is_cow(lv))
 		return 0;
 
-	if (lv->status & SNAPSHOT)
+	if (lv_is_snapshot(lv))
 		return 0;
 
 	/* FIXME: lv_is_virtual_origin ? */
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 8f13f6b..1084149 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -971,7 +971,7 @@ int lv_mirror_image_in_sync(const struct logical_volume *lv)
 	struct lv_segment *seg = first_seg(lv);
 	struct lv_segment *mirror_seg;
 
-	if (!(lv->status & MIRROR_IMAGE) || !seg ||
+	if (!lv_is_mirror_image(lv) || !seg ||
 	    !(mirror_seg = find_mirror_seg(seg))) {
 		log_error(INTERNAL_ERROR "Cannot find mirror segment.");
 		return 0;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fdfee36..211b190 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1139,7 +1139,8 @@ int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
 			 display_lvname(seg->lv), seg->le, area_num,
 			 display_lvname(lv), le);
 
-	if (status & RAID_META) {
+	lv->status |= status;
+	if (lv_is_raid_metadata(lv)) {
 		seg->meta_areas[area_num].type = AREA_LV;
 		seg_metalv(seg, area_num) = lv;
 		if (le) {
@@ -1152,7 +1153,6 @@ int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
 		seg_lv(seg, area_num) = lv;
 		seg_le(seg, area_num) = le;
 	}
-	lv->status |= status;
 
 	if (!add_seg_to_segs_using_this_lv(lv, seg))
 		return_0;
@@ -4678,8 +4678,7 @@ static int _lvresize_check(struct logical_volume *lv,
 
 	if (lv_is_raid_image(lv) || lv_is_raid_metadata(lv)) {
 		log_error("Cannot resize a RAID %s directly",
-			  (lv->status & RAID_IMAGE) ? "image" :
-			  "metadata area");
+			  lv_is_raid_image(lv) ? "image" : "metadata area");
 		return 0;
 	}
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b8a47c0..81e2ac2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -135,7 +135,7 @@ static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 
 	*tracking = NULL;
 
-	if (!(lv->status & RAID))
+	if (!lv_is_raid(lv))
 		return 0;
 
 	for (s = 0; s < seg->area_count; s++)
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 2f13ac9..b5fb60c 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -121,7 +121,7 @@ int lv_is_visible(const struct logical_volume *lv)
 	if (lv_is_historical(lv))
 		return 1;
 
-	if (lv->status & SNAPSHOT)
+	if (lv_is_snapshot(lv))
 		return 0;
 
 	if (lv_is_cow(lv)) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 9f399b8..235e535 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2402,7 +2402,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			goto_out;
 		}
 
-		if (lvl->lv->status & SNAPSHOT)
+		if (lv_is_snapshot(lvl->lv))
 			continue;
 
 		/* Skip availability change for non-virt snaps when processing all LVs */
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 455f688..ca0f450 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -107,11 +107,11 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			lv = origin_from_cow(lv);
 
 		/* Only request activation of snapshot origin devices */
-		if ((lv->status & SNAPSHOT) || lv_is_cow(lv))
+		if (lv_is_snapshot(lv) || lv_is_cow(lv))
 			continue;
 
 		/* Only request activation of mirror LV */
-		if ((lv->status & MIRROR_IMAGE) || (lv->status & MIRROR_LOG))
+		if (lv_is_mirror_image(lv) || lv_is_mirror_log(lv))
 			continue;
 
 		/* Only request activation of the first replicator-dev LV */
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 4f28ba3..2c0ac08 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -97,7 +97,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	if (cmd->fmt->features & FMT_RESTRICTED_LVIDS) {
 		dm_list_iterate_items(lvl, &vg->lvs) {
 			lv = lvl->lv;
-			if (lv->status & SNAPSHOT)
+			if (lv_is_snapshot(lv))
 				continue;
 			if (lvnum_from_lvid(&lv->lvid) < MAX_RESTRICTED_LVS)
 				continue;
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 52f603f..e2ba6f7 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -112,7 +112,7 @@ static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
 		lv = dm_list_item(lvh, struct lv_list)->lv;
 
-		if ((lv->status & SNAPSHOT))
+		if (lv_is_snapshot(lv))
 			continue;
 
 		if (lv_is_raid(lv))
@@ -193,7 +193,7 @@ static int _move_snapshots(struct volume_group *vg_from,
 	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
 		lv = dm_list_item(lvh, struct lv_list)->lv;
 
-		if (!(lv->status & SNAPSHOT))
+		if (!lv_is_snapshot(lv))
 			continue;
 
 		dm_list_iterate_items(seg, &lv->segments) {



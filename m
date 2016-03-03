From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Mar 2016 09:20:12 +0000 (UTC)
Subject: master - cleanup: use lv_is_partial
Message-ID: <20160303092012.C0A02605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e04a0184cb046c28428c65e52afc28ec591c50cf
Commit:        e04a0184cb046c28428c65e52afc28ec591c50cf
Parent:        a975dc530e31fec883bbf6e2db7a6b48cb3b789d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 2 20:59:03 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 3 10:17:03 2016 +0100

cleanup: use lv_is_partial

Check for PARTIAL_LV flag in standard way.
---
 lib/activate/activate.c          |    2 +-
 lib/metadata/lv.c                |    2 +-
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |    3 ++-
 lib/metadata/mirror.c            |    4 ++--
 lib/metadata/raid_manip.c        |   29 ++++++++++++++---------------
 lib/report/report.c              |    2 +-
 tools/lvconvert.c                |    8 ++++----
 tools/vgreduce.c                 |    4 ++--
 10 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a7ac608..2eb24d4 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2243,7 +2243,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
-	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV)) {
+	if ((!lv->vg->cmd->partial_activation) && lv_is_partial(lv)) {
 		if (!lv_is_raid_type(lv) || !partial_raid_lv_supports_degraded_activation(lv)) {
 			log_error("Refusing activation of partial LV %s.  "
 				  "Use '--activationmode partial' to override.",
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 98b1ddb..459de6e 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1173,7 +1173,7 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 		repstr[7] = '-';
 
 	repstr[8] = '-';
-	if (lv->status & PARTIAL_LV)
+	if (lv_is_partial(lv))
 		repstr[8] = 'p';
 	else if (lv_is_raid_type(lv)) {
 		uint64_t n;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5e4a81f..1b431c1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1360,7 +1360,7 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 
 int lv_refresh_suspend_resume(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	if (!cmd->partial_activation && (lv->status & PARTIAL_LV)) {
+	if (!cmd->partial_activation && lv_is_partial(lv)) {
 		log_error("Refusing refresh of partial LV %s."
 			  " Use '--activationmode partial' to override.",
 			  display_lvname(lv));
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6b39de4..8376a54 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -193,6 +193,7 @@
 #define vg_is_archived(vg)	(((vg)->status & ARCHIVED_VG) ? 1 : 0)
 
 #define lv_is_locked(lv)	(((lv)->status & LOCKED) ? 1 : 0)
+#define lv_is_partial(lv)	(((lv)->status & PARTIAL_LV) ? 1 : 0)
 #define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
 #define lv_is_merging(lv)	(((lv)->status & MERGING) ? 1 : 0)
 #define lv_is_merging_origin(lv) (lv_is_merging(lv))
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6ec0a0e..5e84e96 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2471,7 +2471,8 @@ struct _lv_mark_if_partial_baton {
 static int _lv_mark_if_partial_collect(struct logical_volume *lv, void *data)
 {
 	struct _lv_mark_if_partial_baton *baton = data;
-	if (baton && lv->status & PARTIAL_LV)
+
+	if (baton && lv_is_partial(lv))
 		baton->partial = 1;
 
 	return 1;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index fa1cc35..2a72209 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -935,7 +935,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 			 * not in-sync.
 			 */
 			if ((s == 0) && !_mirrored_lv_in_sync(lv) &&
-			    !(lv->status & PARTIAL_LV)) {
+			    !(lv_is_partial(lv))) {
 				log_error("Unable to remove primary mirror image while mirror is not in-sync");
 				return 0;
 			}
@@ -1034,7 +1034,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	 * the only way to release the pending writes.
 	 */
 	if (detached_log_lv && lv_is_mirrored(detached_log_lv) &&
-	    (detached_log_lv->status & PARTIAL_LV)) {
+	    lv_is_partial(detached_log_lv)) {
 		struct lv_segment *seg = first_seg(detached_log_lv);
 
 		log_very_verbose("%s being removed due to failures",
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e6684fc..e66b533 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1500,18 +1500,18 @@ static int _remove_partial_multi_segment_image(struct logical_volume *lv,
 	struct logical_volume *rm_image = NULL;
 	struct physical_volume *pv;
 
-	if (!(lv->status & PARTIAL_LV))
+	if (!lv_is_partial(lv))
 		return_0;
 
 	for (s = 0; s < raid_seg->area_count; s++) {
 		extents_needed = 0;
-		if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) &&
+		if (lv_is_partial(seg_lv(raid_seg, s)) &&
 		    lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) &&
 		    (dm_list_size(&(seg_lv(raid_seg, s)->segments)) > 1)) {
 			rm_image = seg_lv(raid_seg, s);
 
 			/* First, how many damaged extents are there */
-			if (seg_metalv(raid_seg, s)->status & PARTIAL_LV)
+			if (lv_is_partial(seg_metalv(raid_seg, s)))
 				extents_needed += seg_metalv(raid_seg, s)->le_count;
 			dm_list_iterate_items(rm_seg, &rm_image->segments) {
 				/*
@@ -1576,8 +1576,7 @@ static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, allocate_pvs)
-		if (!(lv->status & PARTIAL_LV) &&
-		    lv_is_on_pv(lv, pvl->pv))
+		if (!lv_is_partial(lv) && lv_is_on_pv(lv, pvl->pv))
 			pvl->pv->status |= PV_ALLOCATION_PROHIBITED;
 
 	return 1;
@@ -1617,7 +1616,7 @@ int lv_raid_replace(struct logical_volume *lv,
 	dm_list_init(&new_meta_lvs);
 	dm_list_init(&new_data_lvs);
 
-	if (lv->status & PARTIAL_LV)
+	if (lv_is_partial(lv))
 		lv->vg->cmd->partial_activation = 1;
 
 	if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
@@ -1708,7 +1707,7 @@ int lv_raid_replace(struct logical_volume *lv,
 try_again:
 	if (!_alloc_image_components(lv, allocate_pvs, match_count,
 				     &new_meta_lvs, &new_data_lvs)) {
-		if (!(lv->status & PARTIAL_LV)) {
+		if (!lv_is_partial(lv)) {
 			log_error("LV %s in not partial.", display_lvname(lv));
 			return 0;
 		}
@@ -1853,7 +1852,7 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 	uint32_t s;
 	struct lv_segment *seg = first_seg(lv);
 
-	if (!(lv->status & PARTIAL_LV)) {
+	if (!lv_is_partial(lv)) {
 		log_error(INTERNAL_ERROR "%s/%s is not a partial LV",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -1870,8 +1869,8 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 	 */
 
 	for (s = 0; s < seg->area_count; s++) {
-		if (!(seg_lv(seg, s)->status & PARTIAL_LV) &&
-		    !(seg_metalv(seg, s)->status & PARTIAL_LV))
+		if (!lv_is_partial(seg_lv(seg, s)) &&
+		    !lv_is_partial(seg_metalv(seg, s)))
 			continue;
 
 		log_debug("Replacing %s and %s segments with error target",
@@ -1911,8 +1910,8 @@ static int _partial_raid_lv_is_redundant(const struct logical_volume *lv)
 			if (!(i % copies))
 				rebuilds_per_group = 0;
 
-			if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
-			    (seg_metalv(raid_seg, s)->status & PARTIAL_LV) ||
+			if (lv_is_partial(seg_lv(raid_seg, s)) ||
+			    lv_is_partial(seg_metalv(raid_seg, s)) ||
 			    lv_is_virtual(seg_lv(raid_seg, s)) ||
 			    lv_is_virtual(seg_metalv(raid_seg, s)))
 				rebuilds_per_group++;
@@ -1928,8 +1927,8 @@ static int _partial_raid_lv_is_redundant(const struct logical_volume *lv)
 	}
 
 	for (s = 0; s < raid_seg->area_count; s++) {
-		if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
-		    (seg_metalv(raid_seg, s)->status & PARTIAL_LV) ||
+		if (lv_is_partial(seg_lv(raid_seg, s)) ||
+		    lv_is_partial(seg_metalv(raid_seg, s)) ||
 		    lv_is_virtual(seg_lv(raid_seg, s)) ||
 		    lv_is_virtual(seg_metalv(raid_seg, s)))
 			failed_components++;
@@ -1961,7 +1960,7 @@ static int _lv_may_be_activated_in_degraded_mode(struct logical_volume *lv, void
 	if (*not_capable)
 		return 1;	/* No further checks needed */
 
-	if (!(lv->status & PARTIAL_LV))
+	if (!lv_is_partial(lv))
 		return 1;
 
 	if (lv_is_raid(lv)) {
diff --git a/lib/report/report.c b/lib/report/report.c
index 631a1bf..43987b1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3298,7 +3298,7 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 	const char *health = "";
 	uint64_t n;
 
-	if (lv->status & PARTIAL_LV)
+	if (lv_is_partial(lv))
 		health = "partial";
 	else if (lv_is_raid_type(lv)) {
 		if (!activation())
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f6ea614..db1c7f7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -854,7 +854,7 @@ static int _failed_mirrors_count(struct logical_volume *lv)
 			if (seg_type(lvseg, s) == AREA_LV) {
 				if (is_temporary_mirror_layer(seg_lv(lvseg, s)))
 					ret += _failed_mirrors_count(seg_lv(lvseg, s));
-				else if (seg_lv(lvseg, s)->status & PARTIAL_LV)
+				else if (lv_is_partial(seg_lv(lvseg, s)))
 					++ ret;
 			}
 			else if (seg_type(lvseg, s) == AREA_PV &&
@@ -871,7 +871,7 @@ static int _failed_logs_count(struct logical_volume *lv)
 	int ret = 0;
 	unsigned s;
 	struct logical_volume *log_lv = first_seg(lv)->log_lv;
-	if (log_lv && (log_lv->status & PARTIAL_LV)) {
+	if (log_lv && lv_is_partial(log_lv)) {
 		if (lv_is_mirrored(log_lv))
 			ret += _failed_mirrors_count(log_lv);
 		else
@@ -926,7 +926,7 @@ static struct dm_list *_failed_pv_list(struct volume_group *vg)
 static int _is_partial_lv(struct logical_volume *lv,
 			  void *baton __attribute__((unused)))
 {
-	return lv->status & PARTIAL_LV;
+	return lv_is_partial(lv);
 }
 
 /*
@@ -1499,7 +1499,7 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 
 	lv_check_transient(lv); /* TODO check this in lib for all commands? */
 
-	if (!(lv->status & PARTIAL_LV)) {
+	if (!lv_is_partial(lv)) {
 		log_print_unless_silent("Volume %s is consistent. Nothing to repair.",
 					display_lvname(lv));
 		return 1;
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 41b5b83..e7c66fe 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -51,7 +51,7 @@ static int _consolidate_vg(struct cmd_context *cmd, struct volume_group *vg)
 	int r = 1;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
-		if (lvl->lv->status & PARTIAL_LV) {
+		if (lv_is_partial(lvl->lv)) {
 			log_warn("WARNING: Partial LV %s needs to be repaired "
 				 "or removed. ", lvl->lv->name);
 			r = 0;
@@ -88,7 +88,7 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 		lv = lvl->lv;
 
 		/* Are any segments of this LV on missing PVs? */
-		if (lv->status & PARTIAL_LV) {
+		if (lv_is_partial(lv)) {
 			if (seg_is_raid(first_seg(lv))) {
 				if (!lv_raid_remove_missing(lv))
 					return_0;



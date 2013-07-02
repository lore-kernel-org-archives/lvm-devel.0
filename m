From: Mike Snitzer <msnitzer@fedoraproject.org>
Date: Tue,  2 Jul 2013 20:29:39 +0000 (UTC)
Subject: master - snapshot: Rename snapshot segment returning methods from find_*_cow to find_*_snapshot
Message-ID: <20130702202939.2358B60F0D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9e0adcce56055f625ab8c77c7d66e4db61fe23a
Commit:        f9e0adcce56055f625ab8c77c7d66e4db61fe23a
Parent:        79106f73940762ccde7fa536f37f922ba4773b70
Author:        Mike Snitzer <snitzer@redhat.com>
AuthorDate:    Tue Jul 2 16:26:03 2013 -0400
Committer:     Mike Snitzer <snitzer@redhat.com>
CommitterDate: Tue Jul 2 16:26:03 2013 -0400

snapshot: Rename snapshot segment returning methods from find_*_cow to find_*_snapshot

find_cow -> find_snapshot, find_merging_cow -> find_merging_snapshot.
Will thin snapshot code to reuse these methods without confusion.
---
 WHATS_NEW                        |    1 +
 lib/activate/activate.c          |    2 +-
 lib/activate/dev_manager.c       |   20 ++++++++++----------
 lib/display/display.c            |    2 +-
 lib/metadata/lv.c                |    4 ++--
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    6 +++---
 lib/metadata/snapshot_manip.c    |   35 +++++++++++++++++------------------
 tools/lvconvert.c                |    8 ++++----
 9 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5d9d27a..60b2fac 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Rename snapshot segment returning methods from find_*_cow to find_*_snapshot.
   liblvm/python API: Additions: PV create/removal/resize/listing
   liblvm/python API: Additions: LV attr/origin/Thin pool/Thin LV creation
   Add vgs/lvs -o vg_profile/lv_profile to report profiles attached to VG/LV.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2f1718b..204cceb 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -74,7 +74,7 @@ int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
 				return_0;
 
 	if (lv_is_cow(seg->lv)) {
-		snap_seg = find_cow(seg->lv);
+		snap_seg = find_snapshot(seg->lv);
 		if (snap_seg->segtype->ops->modules_needed &&
 		    !snap_seg->segtype->ops->modules_needed(mem, snap_seg,
 							    modules)) {
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 85bd724..74afaac 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1162,7 +1162,7 @@ static int _belong_to_vg(const char *vgname, const char *name)
 		return 0;
 }
 
-	if (!(snap_seg = find_cow(lv)))
+	if (!(snap_seg = find_snapshot(lv)))
 		return 1;
 
 	old_origin = snap_seg->origin;
@@ -1170,7 +1170,7 @@ static int _belong_to_vg(const char *vgname, const char *name)
 	/* Was this the last active snapshot with this origin? */
 	dm_list_iterate_items(lvl, active_head) {
 		active = lvl->lv;
-		if ((snap_seg = find_cow(active)) &&
+		if ((snap_seg = find_snapshot(active)) &&
 		    snap_seg->origin == old_origin) {
 			return 1;
 		}
@@ -1977,20 +1977,20 @@ static int _add_snapshot_merge_target_to_dtree(struct dev_manager *dm,
 					       struct logical_volume *lv)
 {
 	const char *origin_dlid, *cow_dlid, *merge_dlid;
-	struct lv_segment *merging_cow_seg = find_merging_cow(lv);
+	struct lv_segment *merging_snap_seg = find_merging_snapshot(lv);
 
 	if (!(origin_dlid = build_dm_uuid(dm->mem, lv->lvid.s, "real")))
 		return_0;
 
-	if (!(cow_dlid = build_dm_uuid(dm->mem, merging_cow_seg->cow->lvid.s, "cow")))
+	if (!(cow_dlid = build_dm_uuid(dm->mem, merging_snap_seg->cow->lvid.s, "cow")))
 		return_0;
 
-	if (!(merge_dlid = build_dm_uuid(dm->mem, merging_cow_seg->cow->lvid.s, NULL)))
+	if (!(merge_dlid = build_dm_uuid(dm->mem, merging_snap_seg->cow->lvid.s, NULL)))
 		return_0;
 
 	if (!dm_tree_node_add_snapshot_merge_target(dnode, lv->size, origin_dlid,
 						    cow_dlid, merge_dlid,
-						    merging_cow_seg->chunk_size))
+						    merging_snap_seg->chunk_size))
 		return_0;
 
 	return 1;
@@ -2006,7 +2006,7 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 	struct lv_segment *snap_seg;
 	uint64_t size;
 
-	if (!(snap_seg = find_cow(lv))) {
+	if (!(snap_seg = find_snapshot(lv))) {
 		log_error("Couldn't find snapshot for '%s'.", lv->name);
 		return 0;
 	}
@@ -2165,7 +2165,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	const char *target_name;
 
 	/* Ensure required device-mapper targets are loaded */
-	seg_present = find_cow(seg->lv) ? : seg;
+	seg_present = find_snapshot(seg->lv) ? : seg;
 	target_name = (seg_present->segtype->ops->target_name ?
 		       seg_present->segtype->ops->target_name(seg_present, laopts) :
 		       seg_present->segtype->name);
@@ -2310,7 +2310,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		if (((dinfo = _cached_info(dm->mem, dtree, lv, NULL)) &&
 		     dinfo->open_count) ||
 		    ((dinfo = _cached_info(dm->mem, dtree,
-					   find_merging_cow(lv)->cow, NULL)) &&
+					   find_merging_snapshot(lv)->cow, NULL)) &&
 		     dinfo->open_count)) {
 			/* FIXME Is there anything simpler to check for instead? */
 			if (!lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
@@ -2369,7 +2369,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			return_0;
 		if (!laopts->no_merging && lv_is_merging_origin(lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
-			     find_merging_cow(lv)->cow, laopts, "cow"))
+			     find_merging_snapshot(lv)->cow, laopts, "cow"))
 				return_0;
 			/*
 			 * Must also add "real" LV for use when
diff --git a/lib/display/display.c b/lib/display/display.c
index 121a85e..e2b0f76 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -569,7 +569,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 					  snap_active ? "active" : "INACTIVE");
 		}
 		snap_seg = NULL;
-	} else if ((snap_seg = find_cow(lv))) {
+	} else if ((snap_seg = find_snapshot(lv))) {
 		if (inkernel &&
 		    (snap_active = lv_snapshot_percent(snap_seg->cow,
 						       &snap_percent)))
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 475a514..0742562 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -169,7 +169,7 @@ uint64_t lvseg_chunksize(const struct lv_segment *seg)
 	uint64_t size;
 
 	if (lv_is_cow(seg->lv))
-		size = (uint64_t) find_cow(seg->lv)->chunk_size;
+		size = (uint64_t) find_snapshot(seg->lv)->chunk_size;
 	else if (seg_is_thin_pool(seg))
 		size = (uint64_t) seg->chunk_size;
 	else
@@ -324,7 +324,7 @@ uint64_t lv_origin_size(const struct logical_volume *lv)
 	struct lv_segment *seg;
 
 	if (lv_is_cow(lv))
-		return (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
+		return (uint64_t) find_snapshot(lv)->len * lv->vg->extent_size;
 
 	if (lv_is_thin_volume(lv) && (seg = first_seg(lv)) &&
 	    seg->external_lv)
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 38f5b45..4c3beb0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3634,7 +3634,7 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 		}
 		lp->extents += lv->le_count;
 		if (lv_is_cow(lv)) {
-			extents_used = cow_max_extents(origin_from_cow(lv), find_cow(lv)->chunk_size);
+			extents_used = cow_max_extents(origin_from_cow(lv), find_snapshot(lv)->chunk_size);
 			if (extents_used < lp->extents) {
 				log_print_unless_silent("Reached maximum COW size %s.",
 							display_size(vg->cmd, (uint64_t) vg->extent_size * extents_used));
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d6c6acb..7b7ac3c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -801,10 +801,10 @@ int lv_is_visible(const struct logical_volume *lv);
 
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
-struct lv_segment *find_merging_cow(const struct logical_volume *origin);
+struct lv_segment *find_merging_snapshot(const struct logical_volume *origin);
 
 /* Given a cow LV, return return the snapshot lv_segment that uses it */
-struct lv_segment *find_cow(const struct logical_volume *lv);
+struct lv_segment *find_snapshot(const struct logical_volume *lv);
 
 /* Given a cow LV, return its origin */
 struct logical_volume *origin_from_cow(const struct logical_volume *lv);
@@ -812,7 +812,7 @@ struct logical_volume *origin_from_cow(const struct logical_volume *lv);
 void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 		       struct logical_volume *cow, uint32_t chunk_size, int merge);
 
-int init_snapshot_merge(struct lv_segment *cow_seg, struct logical_volume *origin);
+int init_snapshot_merge(struct lv_segment *snap_seg, struct logical_volume *origin);
 
 void clear_snapshot_merge(struct logical_volume *origin);
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index e0d2f5b..f949b23 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -70,7 +70,7 @@ uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_siz
 int lv_is_cow_covering_origin(const struct logical_volume *lv)
 {
 	return lv_is_cow(lv) &&
-		(lv->size >= _cow_max_size(origin_from_cow(lv)->size, find_cow(lv)->chunk_size));
+		(lv->size >= _cow_max_size(origin_from_cow(lv)->size, find_snapshot(lv)->chunk_size));
 }
 
 int lv_is_visible(const struct logical_volume *lv)
@@ -101,22 +101,21 @@ int lv_is_merging_origin(const struct logical_volume *origin)
 	return (origin->status & MERGING) ? 1 : 0;
 }
 
-struct lv_segment *find_merging_cow(const struct logical_volume *origin)
+struct lv_segment *find_merging_snapshot(const struct logical_volume *origin)
 {
 	if (!lv_is_merging_origin(origin))
 		return NULL;
 
-	return find_cow(origin);
+	return find_snapshot(origin);
 }
 
 int lv_is_merging_cow(const struct logical_volume *snapshot)
 {
 	/* checks lv_segment's status to see if cow is merging */
-	return (find_cow(snapshot)->status & MERGING) ? 1 : 0;
+	return (find_snapshot(snapshot)->status & MERGING) ? 1 : 0;
 }
 
-/* Given a cow LV, return the snapshot lv_segment that uses it */
-struct lv_segment *find_cow(const struct logical_volume *lv)
+struct lv_segment *find_snapshot(const struct logical_volume *lv)
 {
 	return lv->snapshot;
 }
@@ -153,27 +152,27 @@ void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
 }
 
-int init_snapshot_merge(struct lv_segment *cow_seg,
+int init_snapshot_merge(struct lv_segment *snap_seg,
 			struct logical_volume *origin)
 {
 	/*
-	 * Even though lv_is_visible(cow_seg->lv) returns 0,
-	 * the cow_seg->lv (name: snapshotX) is _not_ hidden;
+	 * Even though lv_is_visible(snap_seg->lv) returns 0,
+	 * the snap_seg->lv (name: snapshotX) is _not_ hidden;
 	 * this is part of the lvm2 snapshot fiction.  Must
 	 * clear VISIBLE_LV directly (lv_set_visible can't)
-	 * - cow_seg->lv->status is used to control whether 'lv'
+	 * - snap_seg->lv->status is used to control whether 'lv'
 	 *   (with user provided snapshot LV name) is visible
 	 * - this also enables vg_validate() to succeed with
-	 *   merge metadata (cow_seg->lv is now "internal")
+	 *   merge metadata (snap_seg->lv is now "internal")
 	 */
-	cow_seg->lv->status &= ~VISIBLE_LV;
-	cow_seg->status |= MERGING;
-	origin->snapshot = cow_seg;
+	snap_seg->lv->status &= ~VISIBLE_LV;
+	snap_seg->status |= MERGING;
+	origin->snapshot = snap_seg;
 	origin->status |= MERGING;
 
-	if (cow_seg->segtype->ops->target_present &&
-	    !cow_seg->segtype->ops->target_present(cow_seg->lv->vg->cmd,
-				cow_seg, NULL))
+	if (snap_seg->segtype->ops->target_present &&
+	    !snap_seg->segtype->ops->target_present(snap_seg->lv->vg->cmd,
+						    snap_seg, NULL))
 		return 0;
 
 	return 1;
@@ -231,7 +230,7 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	dm_list_del(&cow->snapshot->origin_list);
 	origin->origin_count--;
 
-	if (find_merging_cow(origin) == find_cow(cow)) {
+	if (find_merging_snapshot(origin) == find_snapshot(cow)) {
 		clear_snapshot_merge(origin);
 		/*
 		 * preload origin IFF "snapshot-merge" target is active
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 542c71d..4ac7e54 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -603,7 +603,7 @@ static int _finish_lvconvert_merge(struct cmd_context *cmd,
 				   struct logical_volume *lv,
 				   struct dm_list *lvs_changed __attribute__((unused)))
 {
-	struct lv_segment *snap_seg = find_merging_cow(lv);
+	struct lv_segment *snap_seg = find_merging_snapshot(lv);
 	if (!snap_seg) {
 		log_error("Logical volume %s has no merging snapshot.", lv->name);
 		return 0;
@@ -1784,7 +1784,7 @@ static int lvconvert_merge(struct cmd_context *cmd,
 	int r = 0;
 	int merge_on_activate = 0;
 	struct logical_volume *origin = origin_from_cow(lv);
-	struct lv_segment *cow_seg = find_cow(lv);
+	struct lv_segment *snap_seg = find_snapshot(lv);
 	struct lvinfo info;
 
 	/* Check if merge is possible */
@@ -1794,7 +1794,7 @@ static int lvconvert_merge(struct cmd_context *cmd,
 	}
 	if (lv_is_merging_origin(origin)) {
 		log_error("Snapshot %s is already merging into the origin",
-			  find_merging_cow(origin)->cow->name);
+			  find_merging_snapshot(origin)->cow->name);
 		return 0;
 	}
 
@@ -1821,7 +1821,7 @@ static int lvconvert_merge(struct cmd_context *cmd,
 		}
 	}
 
-	if (!init_snapshot_merge(cow_seg, origin)) {
+	if (!init_snapshot_merge(snap_seg, origin)) {
 		log_error("Can't initialize snapshot merge. "
 			  "Missing support in kernel?");
 		return_0;



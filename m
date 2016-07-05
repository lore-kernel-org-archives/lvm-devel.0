From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  5 Jul 2016 13:45:18 +0000 (UTC)
Subject: master - vgsplit: fix moving RAID LVs to split off VG and check for LVs not to skip moving with other LV types
Message-ID: <20160705134518.769B760D5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3afd1bd133e896a8e23a3ecf35940983b0429bc
Commit:        f3afd1bd133e896a8e23a3ecf35940983b0429bc
Parent:        b1b32c900adb69a780bfaf673bc63189e7c86541
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jul 5 15:39:57 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jul 5 15:39:57 2016 +0200

vgsplit: fix moving RAID LVs to split off VG and check for LVs not to skip moving with other LV types

---
 tools/vgsplit.c |  132 +++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 99 insertions(+), 33 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 6114a72..afe87af 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009,2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -23,9 +23,46 @@ static int _lv_is_in_vg(struct volume_group *vg, struct logical_volume *lv)
 	return 1;
 }
 
+static struct dm_list *_lvh_in_vg(struct logical_volume *lv, struct volume_group *vg)
+{
+	struct dm_list *lvh;
+
+	dm_list_iterate(lvh, &vg->lvs)
+		if (lv == dm_list_item(lvh, struct lv_list)->lv)
+			return lvh;
+
+	return NULL;
+}
+
+static int _lv_tree_move(struct dm_list *lvh,
+			 struct volume_group *vg_from,
+			 struct volume_group *vg_to)
+{
+	uint32_t s;
+	struct logical_volume *lv = dm_list_item(lvh, struct lv_list)->lv;
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list *lvh1;
+
+	dm_list_move(&vg_to->lvs, lvh);
+	lv->vg = vg_to;
+	lv->lvid.id[0] = lv->vg->id;
+
+	if (seg)
+		for (s = 0; s < seg->area_count; s++)
+			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s)) {
+				if ((lvh1 = _lvh_in_vg(seg_lv(seg, s), vg_from))) {
+					if (!_lv_tree_move(lvh1, vg_from, vg_to))
+						return 0;
+				} else if (!_lvh_in_vg(seg_lv(seg, s), vg_to))
+					return 0;
+			}
+
+	return 1;
+}
+
 static int _move_one_lv(struct volume_group *vg_from,
-			 struct volume_group *vg_to,
-			 struct dm_list *lvh)
+			struct volume_group *vg_to,
+			struct dm_list *lvh)
 {
 	struct logical_volume *lv = dm_list_item(lvh, struct lv_list)->lv;
 	struct logical_volume *parent_lv;
@@ -38,10 +75,15 @@ static int _move_one_lv(struct volume_group *vg_from,
 		return 0;
 	}
 
-	dm_list_move(&vg_to->lvs, lvh);
-	lv->vg = vg_to;
+	/* Bail out, if any allocations of @lv are still on PVs of @vg_from */
+	if (lv_is_on_pvs(lv, &vg_from->pvs)) {
+		log_error("Can't split LV %s between "
+			  "two Volume Groups", lv->name);
+		return 0;
+	}
 
-	lv->lvid.id[0] = lv->vg->id;
+	if (!_lv_tree_move(lvh, vg_from, vg_to))
+		return 0;
 
 	/* Moved pool metadata spare LV */
 	if (vg_from->pool_metadata_spare_lv == lv) {
@@ -148,6 +190,10 @@ static int _move_snapshots(struct volume_group *vg_from,
 		if (!(lv->status & SNAPSHOT))
 			continue;
 
+		/* Ignore, if no allocations on PVs of @vg_to */
+		if (!lv_is_on_pvs(lv, &vg_to->pvs))
+			continue;
+
 		dm_list_iterate_items(seg, &lv->segments) {
 			cow_from = _lv_is_in_vg(vg_from, seg->cow);
 			origin_from = _lv_is_in_vg(vg_from, seg->origin);
@@ -194,6 +240,10 @@ static int _move_mirrors(struct volume_group *vg_from,
 		if (!lv_is_mirrored(lv))
 			continue;
 
+		/* Ignore, if no allocations on PVs of @vg_to */
+		if (!lv_is_on_pvs(lv, &vg_to->pvs))
+			continue;
+
 		seg = first_seg(lv);
 
 		seg_in = 0;
@@ -233,13 +283,18 @@ static int _move_mirrors(struct volume_group *vg_from,
 	return 1;
 }
 
-static int _move_raid(struct volume_group *vg_from,
-		      struct volume_group *vg_to)
+/*
+ * Check for any RAID LVs with allocations on PVs of @vg_to.
+ *
+ * If these don't have any allocations on PVs of @vg_from,
+ * move their whole lv stack across to @vg_to including the
+ * top-level RAID LV.
+ */
+static int _move_raids(struct volume_group *vg_from,
+		       struct volume_group *vg_to)
 {
 	struct dm_list *lvh, *lvht;
 	struct logical_volume *lv;
-	struct lv_segment *seg;
-	unsigned s, seg_in;
 
 	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
 		lv = dm_list_item(lvh, struct lv_list)->lv;
@@ -247,22 +302,11 @@ static int _move_raid(struct volume_group *vg_from,
 		if (!lv_is_raid(lv))
 			continue;
 
-		seg = first_seg(lv);
-
-		seg_in = 0;
-		for (s = 0; s < seg->area_count; s++) {
-			if (_lv_is_in_vg(vg_to, seg_lv(seg, s)))
-				seg_in++;
-			if (seg->meta_areas && seg_metalv(seg, s) && _lv_is_in_vg(vg_to, seg_metalv(seg, s)))
-				seg_in++;	/* FIXME Inadequate - must count separately */
-		}
-
-		if (seg_in && seg_in != (seg->area_count * (seg->meta_areas ? 2 : 1))) {
-			log_error("Can't split RAID %s between "
-				  "two Volume Groups", lv->name);
-			return 0;
-		}
-
+		/* Ignore, if no allocations on PVs of @vg_to */
+		if (!lv_is_on_pvs(lv, &vg_to->pvs))
+			continue;
+ 
+		/* If allocations are on PVs of @vg_to -> move RAID LV stack across */
 		if (!_move_one_lv(vg_from, vg_to, lvh))
 			return_0;
 	}
@@ -283,6 +327,11 @@ static int _move_thins(struct volume_group *vg_from,
 		if (lv_is_thin_volume(lv)) {
 			seg = first_seg(lv);
 			data_lv = seg_lv(first_seg(seg->pool_lv), 0);
+
+			/* Ignore, if no allocations on PVs of @vg_to */
+			if (!lv_is_on_pvs(data_lv, &vg_to->pvs))
+				continue;
+
 			if ((_lv_is_in_vg(vg_to, data_lv) ||
 			     _lv_is_in_vg(vg_to, seg->external_lv))) {
 				if (_lv_is_in_vg(vg_from, seg->external_lv) ||
@@ -299,6 +348,11 @@ static int _move_thins(struct volume_group *vg_from,
 		} else if (lv_is_thin_pool(lv)) {
 			seg = first_seg(lv);
 			data_lv = seg_lv(seg, 0);
+
+			/* Ignore, if no allocations on PVs of @vg_to */
+			if (!lv_is_on_pvs(data_lv, &vg_to->pvs))
+				continue;
+
 			if (_lv_is_in_vg(vg_to, data_lv) ||
 			    _lv_is_in_vg(vg_to, seg->metadata_lv)) {
 				if (_lv_is_in_vg(vg_from, seg->metadata_lv) ||
@@ -364,6 +418,12 @@ static int _move_cache(struct volume_group *vg_from,
 				is_moving = 1;
 		}
 
+		if (!lv_is_on_pvs(data, &vg_to->pvs))
+			continue;
+
+		if (!lv_is_on_pvs(meta, &vg_to->pvs))
+			continue;
+
 		if (orig && (_lv_is_in_vg(vg_to, orig) != is_moving)) {
 			log_error("Can't split %s and its origin (%s)"
 				  " into separate VGs", lv->name, orig->name);
@@ -601,13 +661,19 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (lv_name && !move_pvs_used_by_lv(vg_from, vg_to, lv_name))
 		goto_bad;
 
-	/* Move required LVs across, checking consistency */
-	if (!(_move_lvs(vg_from, vg_to)))
+	/*
+	 * First move any required RAID LVs across recursively.
+	 * Reject if they get split between VGs.
+	 *
+	 * This moves the whole LV stack across, thus _move_lvs() below
+	 * ain't hit any of their MetaLVs/DataLVs any more but'll still
+	 * work for all other type specific moves following it.
+	 */
+	if (!(_move_raids(vg_from, vg_to)))
 		goto_bad;
 
-	/* FIXME Separate the 'move' from the 'validation' to fix dev stacks */
-	/* Move required RAID across */
-	if (!(_move_raid(vg_from, vg_to)))
+	/* Move required sub LVs across, checking consistency */
+	if (!(_move_lvs(vg_from, vg_to)))
 		goto_bad;
 
 	/* Move required mirrors across */
@@ -641,8 +707,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	/*
 	 * First, write out the new VG as EXPORTED.  We do this first in case
 	 * there is a crash - we will still have the new VG information, in an
-	 * exported state.  Recovery after this point would be removal of the
-	 * new VG and redoing the vgsplit.
+	 * exported state.  Recovery after this point would importing and removal
+	 * of the new VG and redoing the vgsplit.
 	 * FIXME: recover automatically or instruct the user?
 	 */
 	vg_to->status |= EXPORTED_VG;



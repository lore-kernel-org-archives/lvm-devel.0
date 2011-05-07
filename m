From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 May 2011 15:52:17 -0000
Subject: LVM2 tools/vgreduce.c test/t-mirror-vgreduce-r ...
Message-ID: <20110507155217.28146.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-07 15:52:16

Modified files:
	tools          : vgreduce.c 
	test           : t-mirror-vgreduce-removemissing.sh 
Added files:
	test           : t-vgreduce-removemissing-snapshot.sh 

Log message:
	Rewrite vgreduce --removemissing --force, using existing primitives:
	lv_remove_with_dependencies and mirror_remove_missing (the latter coming from
	lvconvert). Remove substantial amount of legacy code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-removemissing-snapshot.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/tools/vgreduce.c	2011/03/29 20:19:04	1.110
+++ LVM2/tools/vgreduce.c	2011/05/07 15:52:16	1.111
@@ -15,6 +15,7 @@
 
 #include "tools.h"
 #include "lv_alloc.h"
+#include "lvconvert.h"
 
 static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 {
@@ -45,91 +46,6 @@
 	return 1;
 }
 
-static int _remove_lv(struct cmd_context *cmd, struct logical_volume *lv,
-		      int *list_unsafe, struct dm_list *lvs_changed)
-{
-	struct lv_segment *snap_seg;
-	struct dm_list *snh, *snht;
-	struct logical_volume *cow;
-	struct lv_list *lvl;
-	struct lvinfo info;
-	int first = 1;
-
-	log_verbose("%s/%s has missing extents: removing (including "
-		    "dependencies)", lv->vg->name, lv->name);
-
-	/* FIXME Cope properly with stacked devices & snapshots. */
-
-	/* If snapshot device is missing, deactivate origin. */
-	if (lv_is_cow(lv) && (snap_seg = find_cow(lv))) {
-		log_verbose("Deactivating (if active) logical volume %s "
-			    "(origin of %s)", snap_seg->origin->name, lv->name);
-
-		if (!test_mode() && !deactivate_lv(cmd, snap_seg->origin)) {
-			log_error("Failed to deactivate LV %s",
-				  snap_seg->origin->name);
-			return 0;
-		}
-
-		/* Use the origin LV */
-		lv = snap_seg->origin;
-	}
-
-	/* Remove snapshot dependencies */
-	dm_list_iterate_safe(snh, snht, &lv->snapshot_segs) {
-		snap_seg = dm_list_struct_base(snh, struct lv_segment,
-					    origin_list);
-		cow = snap_seg->cow;
-
-		if (first && !test_mode() &&
-		    !deactivate_lv(cmd, snap_seg->origin)) {
-			log_error("Failed to deactivate LV %s",
-				  snap_seg->origin->name);
-			return 0;
-		}
-
-		*list_unsafe = 1;	/* May remove caller's lvht! */
-		if (!vg_remove_snapshot(cow))
-			return_0;
-		log_verbose("Removing LV %s from VG %s", cow->name,
-			    lv->vg->name);
-		if (!lv_remove(cow))
-			return_0;
-
-		first = 0;
-	}
-
-	/*
-	 * If LV is active, replace it with error segment
-	 * and add to list of LVs to be removed later.
-	 * Doesn't apply to snapshots/origins yet - they're already deactivated.
-	 */
-	/*
-	 * If the LV is a part of mirror segment,
-	 * the mirrored LV also should be cleaned up.
-	 * Clean-up is currently done by caller (_make_vg_consistent()).
-	 */
-	if ((lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) ||
-	    find_mirror_seg(first_seg(lv))) {
-		if (!replace_lv_with_error_segment(lv))
-			return_0;
-
-		if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
-			log_error("lv_list alloc failed");
-			return 0;
-		}
-		lvl->lv = lv;
-		dm_list_add(lvs_changed, &lvl->list);
-	} else {
-		/* Remove LV immediately. */
-		log_verbose("Removing LV %s from VG %s", lv->name, lv->vg->name);
-		if (!lv_remove(lv))
-			return_0;
-	}
-
-	return 1;
-}
-
 static int _consolidate_vg(struct cmd_context *cmd, struct volume_group *vg)
 {
 	struct pv_list *pvl;
@@ -162,215 +78,41 @@
 
 static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 {
-	struct dm_list *pvh, *pvht;
-	struct dm_list *lvh, *lvht;
-	struct pv_list *pvl;
-	struct lv_list *lvl, *lvl2, *lvlt;
+	struct lv_list *lvl;
 	struct logical_volume *lv;
-	struct physical_volume *pv;
-	struct lv_segment *seg, *mirrored_seg;
-	unsigned s;
-	uint32_t mimages, remove_log;
-	int list_unsafe, only_mirror_images_found;
-	DM_LIST_INIT(lvs_changed);
-	only_mirror_images_found = 1;
-
-	/* Deactivate & remove necessary LVs */
-      restart_loop:
-	list_unsafe = 0;	/* Set if we delete a different list-member */
-
-	dm_list_iterate_safe(lvh, lvht, &vg->lvs) {
-		lv = dm_list_item(lvh, struct lv_list)->lv;
-
-		/* Are any segments of this LV on missing PVs? */
-		dm_list_iterate_items(seg, &lv->segments) {
-			for (s = 0; s < seg->area_count; s++) {
-				if (seg_type(seg, s) != AREA_PV)
-					continue;
-
-				/* FIXME Also check for segs on deleted LVs (incl pvmove) */
-
-				pv = seg_pv(seg, s);
-				if (!pv || !pv_dev(pv) ||
-				    is_missing_pv(pv)) {
-					if (arg_count(cmd, mirrorsonly_ARG) &&
-					    !(lv->status & MIRROR_IMAGE)) {
-						log_error("Non-mirror-image LV %s found: can't remove.", lv->name);
-						only_mirror_images_found = 0;
-						continue;
-					}
-					if (!_remove_lv(cmd, lv, &list_unsafe, &lvs_changed))
-						return_0;
-					if (list_unsafe)
-						goto restart_loop;
-				}
-			}
-		}
-	}
 
-	if (!only_mirror_images_found) {
-		log_error("Aborting because --mirrorsonly was specified.");
-		return 0;
-	}
+	cmd->partial_activation = 1;
 
-	/*
-	 * Remove missing PVs. FIXME: This duplicates _consolidate_vg above,
-	 * but we cannot use that right now, since the LV removal code in this
-	 * function leaves the VG in a "somewhat inconsistent" state and
-	 * _consolidate_vg doesn't like that -- specifically, mirrors are fixed
-	 * up *after* the PVs are removed. All this should be gradually
-	 * superseded by lvconvert --repair.
-	 */
-	dm_list_iterate_safe(pvh, pvht, &vg->pvs) {
-		pvl = dm_list_item(pvh, struct pv_list);
-		if (pvl->pv->dev && !is_missing_pv(pvl->pv))
-			continue;
-		if (!_remove_pv(vg, pvl, 0))
-			return_0;
-	}
+ restart:
+	vg_mark_partial_lvs(vg, 1);
 
-	/* FIXME Recovery.  For now people must clean up by hand. */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		lv = lvl->lv;
 
-	if (!dm_list_empty(&lvs_changed)) {
-		if (!vg_write(vg)) {
-			log_error("Failed to write out a consistent VG for %s",
-				  vg->name);
-			return 0;
-		}
-
-		if (!test_mode()) {
-			/* Suspend lvs_changed */
-			if (!suspend_lvs(cmd, &lvs_changed)) {
-				stack;
-				vg_revert(vg);
-				return 0;
-			}
-		}
-
-		if (!vg_commit(vg)) {
-			log_error("Failed to commit consistent VG for %s",
-				  vg->name);
-			vg_revert(vg);
-			return 0;
-		}
-
-		if (!test_mode()) {
-			if (!resume_lvs(cmd, &lvs_changed)) {
-				log_error("Failed to resume LVs using error segments.");
-				return 0;
-			}
-		}
-
-  lvs_changed_altered:
-		/* Remove lost mirror images from mirrors */
-		dm_list_iterate_items(lvl, &vg->lvs) {
-  mirrored_seg_altered:
-			mirrored_seg = first_seg(lvl->lv);
-			if (!seg_is_mirrored(mirrored_seg))
-				continue;
-
-			mimages = mirrored_seg->area_count;
-			remove_log = 0;
-
-			for (s = 0; s < mirrored_seg->area_count; s++) {
-				dm_list_iterate_items_safe(lvl2, lvlt, &lvs_changed) {
-					if (seg_type(mirrored_seg, s) != AREA_LV ||
-					    lvl2->lv != seg_lv(mirrored_seg, s))
-						continue;
-					dm_list_del(&lvl2->list);
-					if (!shift_mirror_images(mirrored_seg, s))
-						return_0;
-					mimages--;	/* FIXME Assumes uniqueness */
-				}
-			}
-
-			if (mirrored_seg->log_lv) {
-				dm_list_iterate_items(seg, &mirrored_seg->log_lv->segments) {
-					/* FIXME: The second test shouldn't be required */
-					if (seg->segtype ==
-					    get_segtype_from_string(vg->cmd, "error")) {
-						log_print("The log device for %s/%s has failed.",
-							  vg->name, mirrored_seg->lv->name);
-						remove_log = 1;
-						break;
-					}
-					if (!strcmp(seg->segtype->name, "error")) {
-						log_print("Log device for %s/%s has failed.",
-							  vg->name, mirrored_seg->lv->name);
-						remove_log = 1;
-						break;
-					}
-				}
-			}
-
-			if ((mimages != mirrored_seg->area_count) || remove_log){
-				if (!reconfigure_mirror_images(mirrored_seg, mimages,
-							       NULL, remove_log))
+		/* Are any segments of this LV on missing PVs? */
+		if (lv->status & PARTIAL_LV) {
+			if (lv->status & MIRRORED) {
+				if (!mirror_remove_missing(cmd, lv, 1))
 					return_0;
-
-				if (!vg_write(vg)) {
-					log_error("Failed to write out updated "
-						  "VG for %s", vg->name);
-					return 0;
-				}
-		
-				if (!vg_commit(vg)) {
-					log_error("Failed to commit updated VG "
-						  "for %s", vg->name);
-					vg_revert(vg);
-					return 0;
-				}
-
-				/* mirrored LV no longer has valid mimages.
-				 * So add it to lvs_changed for removal.
-				 * For this LV may be an area of other mirror,
-				 * restart the loop. */
-				if (!mimages) {
-					if (!_remove_lv(cmd, lvl->lv,
-						 &list_unsafe, &lvs_changed))
-						return_0;
-					goto lvs_changed_altered;
-				}
-
-				/* As a result of reconfigure_mirror_images(),
-				 * first_seg(lv) may now be different seg.
-				 * e.g. a temporary layer might be removed.
-				 * So check the mirrored_seg again. */
-				goto mirrored_seg_altered;
+				goto restart;
 			}
-		}
 
-		/* Deactivate error LVs */
-		if (!test_mode()) {
-			dm_list_iterate_items_safe(lvl, lvlt, &lvs_changed) {
-				log_verbose("Deactivating (if active) logical volume %s",
-					    lvl->lv->name);
-
-				if (!deactivate_lv(cmd, lvl->lv)) {
-					log_error("Failed to deactivate LV %s",
-						  lvl->lv->name);
-					/*
-					 * We failed to deactivate.
-					 * Probably because this was a mirror log.
-					 * Don't try to lv_remove it.
-					 * Continue work on others.
-					 */
-					dm_list_del(&lvl->list);
-				}
+			if (arg_count(cmd, mirrorsonly_ARG) &&!(lv->status & MIRRORED)) {
+				log_error("Non-mirror-image LV %s found: can't remove.", lv->name);
+				continue;
 			}
-		}
 
-		/* Remove remaining LVs */
-		dm_list_iterate_items(lvl, &lvs_changed) {
-			log_verbose("Removing LV %s from VG %s", lvl->lv->name,
-				    lvl->lv->vg->name);
-				/* Skip LVs already removed by mirror code */
-				if (find_lv_in_vg(vg, lvl->lv->name) &&
-				    !lv_remove(lvl->lv))
-					return_0;
+			if (!lv_is_visible(lv))
+				continue;
+			log_warn("Removing partial LV %s.", lv->name);
+			if (!lv_remove_with_dependencies(cmd, lv, 1, 0))
+				return_0;
+			goto restart;
 		}
 	}
 
+	_consolidate_vg(cmd, vg);
+
 	return 1;
 }
 
/cvs/lvm2/LVM2/test/t-vgreduce-removemissing-snapshot.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgreduce-removemissing-snapshot.sh
+++ -	2011-05-07 15:52:16.886692000 +0000
@@ -0,0 +1,26 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 5
+lvcreate -m 3 --ig -L 2M -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
+lvcreate -s $vg/4way -L 2M -n snap
+lvcreate -i 2 -L 2M $vg $dev1 $dev2 -n stripe
+
+aux disable_dev $dev2 $dev4
+echo n | lvconvert --repair $vg/4way
+aux enable_dev $dev2 $dev4
+#not vgreduce --removemissing $vg
+vgreduce -v --removemissing --force $vg # $dev2 $dev4
+lvs -a -o +devices | not grep unknown
+lvs -a -o +devices
+check mirror $vg 4way $dev5
+
--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2011/03/30 13:39:24	1.12
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2011/05/07 15:52:16	1.13
@@ -95,7 +95,7 @@
 prepare_lvs_()
 {
 	lvremove -ff $vg;
-	if dmsetup table|grep $vg; then
+	if dmsetup table|grep -v -- "-missing_"|grep $vg; then
 		echo "ERROR: lvremove did leave some some mappings in DM behind!"
 		return 1
 	fi
@@ -208,13 +208,14 @@
 	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0
 	lvchange -an $vg/$lv1 
 	lvconvert -m+1 $vg/$lv1 $dev4 
-	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
-	mirrorlog_is_on_ $lv1 $dev5 
-	eval aux disable_dev \$dev$n 
+	check mirror_images_on $vg $lv1 $dev1 $dev2 $dev3 $dev4 
+	check mirror_log_on $vg $lv1 $dev5 
+	eval aux disable_dev \$dev$index 
+        lvs -a -o +devices
 	vgreduce --removemissing --force $vg 
-	lvs -a -o+devices $vg 
-	mimages_are_on_ $lv1 $(rest_pvs_ $index 4) 
-	mirrorlog_is_on_ $lv1 $dev5
+	lvs -a -o+devices # $vg 
+	check mirror_images_on $vg $lv1 $dev5 # $(rest_pvs_ $index 4) 
+	check mirror_log_on $vg $lv1 $dev5
 }
 
 for n in $(seq 1 4); do
@@ -234,16 +235,17 @@
 	local index=$1
 
 	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0
-	lvchange -an $vg/$lv1 
-	lvconvert -m+1 $vg/$lv1 $dev4 
-	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
-	mirrorlog_is_on_ $lv1 $dev5 
-	aux disable_dev $(rest_pvs_ $index 4) 
-	vgreduce --removemissing --force $vg 
-	lvs -a -o+devices $vg 
+	lvchange -an $vg/$lv1
+	lvconvert -m+1 $vg/$lv1 $dev4
+	check mirror_images_on $vg $lv1 $dev1 $dev2 $dev3 $dev4
+	check mirror_log_on $vg $lv1 $dev5
+	lvs -a -o+devices $vg
+	aux disable_dev $(rest_pvs_ $index 4)
+	vgreduce --removemissing --force $vg
+	lvs -a -o+devices $vg
 	eval local dev=\$dev$n
-	mimages_are_on_ $lv1 $dev || lv_is_on_ $lv1 $dev
-	not mirrorlog_is_on_ $lv1 $dev5
+	check linear $vg $lv1
+        check lv_on $vg $lv1 $dev
 }
 
 for n in $(seq 1 4); do



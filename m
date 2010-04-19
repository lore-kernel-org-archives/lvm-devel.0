From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 19 Apr 2010 12:49:09 -0500
Subject: [PATCH] Prevent primary image from being pulled from a non-sync'ed mirror (bug 581611)
Message-ID: <1271699349.9666.2.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch fixes bug 581611.

This patch disallows removing the primary image of a mirror
when the mirror set is not in-sync.  Data loss is the likely
result if this action is not forbidden.

Testing also revealed an additional bug that is addressed in
this patch.  The functions that add mirrors differ from the
functions that remove mirrors in the way they take pv lists.
_remove_mirror_images, for example, will modify it's behavior
based on whether a list was supplied or not.  (Most likely this
difference arose because when you are removing devices from
a mirror, you already know the set of available devices to work
on if not specified - the devices in the mirror.  However, when
allocating, the user either specified or the list must be
obtained via lp->pvh - it cannot be inferred.)  Some unexpected
results occurred because the removal functions where not passed
NULL when lp->pv_count == 0.  Further complicating things is
that when mirrors are being repaired, lp->pv_count can be 0,
but still will pass in a list of failed pvs to be removed.  I
simplified things as much as I could, but getting this section
cleaner will need to be part of a rewrite.

Also, I didn't want to change the way the repair actions were
happening.  So, this patch dis-allows users from pulling the
primary device when a mirror is not in sync, but it does not
impose these restrictions on the repair operations.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -516,6 +516,21 @@ static int _move_removable_mimages_to_en
 	return !count;
 }
 
+static int _mirrored_lv_in_sync(struct logical_volume *lv)
+{
+	float sync_percent;
+	percent_range_t percent_range;
+
+	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
+			       &percent_range, NULL)) {
+		log_error("Unable to determine mirror sync status of %s/%s.",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	return (percent_range == PERCENT_100) ? 1 : 0;
+}
+
 /*
  * Split off 'split_count' legs from a mirror
  *
@@ -766,6 +781,21 @@ static int _remove_mirror_images(struct 
 
 	/* Move removable_pvs to end of array */
 	if (removable_pvs_specified) {
+		/*
+		 * A user may unintensionally specify the primary image
+		 * of a mirror for removal - even though the mirror is
+		 * not yet in-sync.  Disallow this.
+		 */
+		sub_lv = seg_lv(mirrored_seg, 0);
+		if (num_removed &&
+		    !(lv->status & PARTIAL_LV) &&
+		    !_mirrored_lv_in_sync(lv) &&
+		    !is_temporary_mirror_layer(sub_lv) &&
+		    _is_mirror_image_removable(sub_lv, removable_pvs)) {
+			log_error("Unable to remove primary mirror image while mirror is not in-sync");
+			return_0;
+		}
+
 		for (s = 0; s < mirrored_seg->area_count &&
 			    old_area_count - new_area_count < num_removed; s++) {
 			sub_lv = seg_lv(mirrored_seg, s);
@@ -960,21 +990,6 @@ int remove_mirror_images(struct logical_
 	return 1;
 }
 
-static int _mirrored_lv_in_sync(struct logical_volume *lv)
-{
-	float sync_percent;
-	percent_range_t percent_range;
-
-	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
-			       &percent_range, NULL)) {
-		log_error("Unable to determine mirror sync status of %s/%s.",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
-	return (percent_range == PERCENT_100) ? 1 : 0;
-}
-
 /*
  * Collapsing temporary mirror layers.
  *
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -929,6 +929,7 @@ static int _lvconvert_mirrors_aux(struct
 {
 	uint32_t region_size;
 	struct lv_segment *seg;
+	struct dm_list *removable_pvs = operable_pvs;
 	struct logical_volume *layer_lv;
 	uint32_t old_mimage_count = lv_mirror_count(lv);
 	uint32_t old_log_count = _get_log_count(lv);
@@ -960,8 +961,8 @@ static int _lvconvert_mirrors_aux(struct
 		 * user perspective.
 		 */
 		if (!lv_add_mirrors(cmd, lv, new_mimage_count - 1, lp->stripes,
-				    lp->stripe_size, region_size, new_log_count, operable_pvs,
-				    lp->alloc, MIRROR_BY_LV)) {
+				    lp->stripe_size, region_size, new_log_count,
+				    operable_pvs, lp->alloc, MIRROR_BY_LV)) {
 			stack;
 			return 0;
 		}
@@ -1046,15 +1047,15 @@ static int _lvconvert_mirrors_aux(struct
 		uint32_t nmc = old_mimage_count - new_mimage_count;
 		uint32_t nlc = (!new_log_count || lp->mirrors == 1) ? 1U : 0U;
 
-		/* FIXME: We did nlc used to be calculated that way? */
+		/* FIXME: Why did nlc used to be calculated that way? */
 
 		/* Reduce number of mirrors */
 		if (lp->keep_mimages) {
 			if (!lv_split_mirror_images(lv, lp->lv_split_name,
-						    nmc, operable_pvs))
+						    nmc, removable_pvs))
 				return 0;
 		} else if (!lv_remove_mirrors(cmd, lv, nmc, nlc,
-					      operable_pvs, 0))
+					      removable_pvs, 0))
 			return_0;
 
 		goto out; /* Just in case someone puts code between */
@@ -1192,7 +1193,6 @@ static int _lvconvert_mirrors_repair(str
 	/*
 	 * Second phase - replace faulty devices
 	 */
-
 	if (replace_mirrors)
 		lp->mirrors = old_mimage_count;
 
@@ -1259,7 +1259,7 @@ static int _lvconvert_mirrors(struct cmd
 						 old_mimage_count,
 						 old_log_count);
 
-	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
+	if (!_lvconvert_mirrors_aux(cmd, lv, lp, lp->pv_count ? lp->pvh : NULL,
 				    new_mimage_count, new_log_count))
 		return 0;
 
Index: LVM2/test/t-lvconvert-mirror.sh
===================================================================
--- LVM2.orig/test/t-lvconvert-mirror.sh
+++ LVM2/test/t-lvconvert-mirror.sh
@@ -61,10 +61,20 @@ lvcreate -l2 -n $lv1 $vg $dev1
 not lvconvert -m+1 --mirrorlog core $vg/$lv1 $dev1
 lvremove -ff $vg
 
-lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
+# Start w/ 3-way mirror
+# Test pulling primary image before mirror in-sync (should fail)
+# Test pulling primary image after mirror in-sync (should work)
+# Test that the correct devices remain in the mirror
+lvcreate -l8 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
+# FIXME:
+#  This is somewhat timing dependent - sync /could/ finish before
+#  we get a chance to have this command fail
+not lvconvert -m-1 $vg/$lv1 $dev1
+while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do
+	sleep 1
+done
 lvconvert -m-1 $vg/$lv1 $dev1
 check mirror_images_on $lv1 $dev2 $dev4
 lvconvert -m-1 $vg/$lv1 $dev2
 check linear $vg $lv1
 check lv_on $vg/$lv1 $dev4
-
Index: LVM2/test/t-mirror-lvconvert.sh
===================================================================
--- LVM2.orig/test/t-mirror-lvconvert.sh
+++ LVM2/test/t-mirror-lvconvert.sh
@@ -98,6 +98,12 @@ wait_conversion_()
   while (lvs --noheadings -oattr "$lv" | grep -q '^ *c'); do sleep 1; done
 }
 
+wait_sync_()
+{
+  local lv=$1
+  while [ `lvs --noheadings -o copy_percent $lv` != "100.00" ]; do sleep 1; done
+}
+
 check_no_tmplvs_()
 {
   local lv=$1
@@ -404,6 +410,7 @@ lvcreate -l`pvs --noheadings -ope_count 
 lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
+wait_sync_ $vg/$lv1 # cannot pull primary unless mirror in-sync
 lvconvert -m0 $vg/$lv1 $dev1 
 lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 




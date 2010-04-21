From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 20 Apr 2010 21:13:47 -0500
Subject: [PATCH] Prevent primary image removal from non-sync'ed mirror (bug 581611)
Message-ID: <1271816027.18449.24.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Taking mornfall's suggestion and working the loop backwards allows for a
much cleaner patch - removing the need to alter lvconvert.c.

 brassow

This patch fixes bug 581611.

This patch disallows removing the primary image of a mirror
when the mirror set is not in-sync.  Data loss is the likely
result if this action is not forbidden.

I didn't want to change the way the repair actions were
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
@@ -736,7 +751,7 @@ static int _remove_mirror_images(struct 
 				 uint32_t *removed)
 {
 	uint32_t m;
-	uint32_t s;
+	int32_t s;
 	int removable_pvs_specified;
 	struct logical_volume *sub_lv;
 	struct logical_volume *detached_log_lv = NULL;
@@ -766,15 +781,25 @@ static int _remove_mirror_images(struct 
 
 	/* Move removable_pvs to end of array */
 	if (removable_pvs_specified) {
-		for (s = 0; s < mirrored_seg->area_count &&
-			    old_area_count - new_area_count < num_removed; s++) {
+		for (s = mirrored_seg->area_count - 1;
+		     s >= 0 && old_area_count - new_area_count < num_removed;
+		     s--) {
 			sub_lv = seg_lv(mirrored_seg, s);
 
 			if (!is_temporary_mirror_layer(sub_lv) &&
 			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
+				/*
+				 * Check if the user is trying to pull the
+				 * primary mirror image when the mirror is
+				 * not in-sync.
+				 */
+				if ((s == 0) && !_mirrored_lv_in_sync(lv) &&
+				    !(lv->status & PARTIAL_LV)) {
+					log_error("Unable to remove primary mirror image while mirror is not in-sync");
+					return_0;
+				}
 				if (!shift_mirror_images(mirrored_seg, s))
 					return_0;
-				s--; /* adjust counter after shifting */
 				new_area_count--;
 			}
 		}
@@ -960,21 +985,6 @@ int remove_mirror_images(struct logical_
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




From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 17 Mar 2017 09:00:15 -0400
Subject: master - raid: conditionally reject convert to striped/raid0*
Message-ID: <201703171300.v2HD0FIa006709@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17bee733d16e88d260b7de826c747c6ade9f797c
Commit:        17bee733d16e88d260b7de826c747c6ade9f797c
Parent:        5e7bc8d854bb6752e6987692791750a48e871442
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 17 13:58:54 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 17 13:58:54 2017 +0100

raid: conditionally reject convert to striped/raid0*

If SubLVs to be removed still exist after an image removing
conversion (i.e. "lvconvert --yes --force --stripes N "
with N < total stripes) any request to convert to a different
striped/raid* level has to be rejected until after those freed
SubLVs got removed by running the aforementioned lvconvert again.

Add tests to check conversion to striped/raid* gets rejected.
Enhance a test comment.

Related: rhbz1191935
Related: rhbz1366296
---
 lib/metadata/raid_manip.c            |   54 +++++++++++++++++++++++++--------
 test/shell/lvconvert-raid-reshape.sh |   14 +++++++-
 2 files changed, 53 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index dbffc5a..df48897 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -171,6 +171,33 @@ char *top_level_lv_name(struct volume_group *vg, const char *lv_name)
 	return new_lv_name;
 }
 
+/* Get available and removed SubLVs for @lv */
+static int _get_available_removed_sublvs(const struct logical_volume *lv, uint32_t *available_slvs, uint32_t *removed_slvs)
+{
+	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+
+	*available_slvs = 0;
+	*removed_slvs = 0;
+
+	if (!lv_is_raid(lv))
+		return 1;
+
+	for (s = 0; s < seg->area_count; s++) {
+		struct logical_volume *slv;
+
+		if (seg_type(seg, s) != AREA_LV || !(slv = seg_lv(seg, s))) {
+			log_error(INTERNAL_ERROR "Missing image sub lv in area %" PRIu32 " of LV %s.",
+				  s, display_lvname(lv));
+			return_0;
+		}
+
+		(slv->status & LV_REMOVE_AFTER_RESHAPE) ? (*removed_slvs)++ : (*available_slvs)++;
+	}
+
+	return 1;
+}
+
 static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 				     struct logical_volume **tracking)
 {
@@ -1916,19 +1943,8 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 		 * -> remove the freed up images and reduce LV size
 		 *
 		 */
-		for (active_lvs = removed_lvs = s = 0; s < seg->area_count; s++) {
-			struct logical_volume *slv;
-
-			if (!seg_lv(seg, s) || !(slv = seg_lv(seg, s))) {
-				log_error("Missing image sub lv off LV %s.", display_lvname(lv));
-				return 0;
-			}
-
-			if (slv->status & LV_REMOVE_AFTER_RESHAPE)
-				removed_lvs++;
-			else
-				active_lvs++;
-		}
+		if (!_get_available_removed_sublvs(lv, &active_lvs,  &removed_lvs))
+			return_0;
 
 		if (devs_in_sync != new_image_count) {
 			log_error("No correct kernel/lvm active LV count on %s.", display_lvname(lv));
@@ -5965,6 +5981,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	uint32_t new_image_count = seg->area_count;
 	uint32_t region_size = new_region_size;
 	uint32_t data_copies = seg->data_copies;
+	uint32_t available_slvs, removed_slvs;
 	takeover_fn_t takeover_fn;
 
 	new_segtype = new_segtype ? : seg->segtype;
@@ -6016,6 +6033,17 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
+	/* Prohibit any takeover in case sub LVs to be removed still exist after a previous reshape */
+	if (_get_available_removed_sublvs(lv, &available_slvs, &removed_slvs))
+		return 0;
+	if (removed_slvs) {
+		log_error("Can't convert %s LV %s to %s containing sub LVs to remove after a reshape.",
+			  lvseg_name(seg), display_lvname(lv), new_segtype->name);
+		log_error("Run \"lvconvert --stripes %" PRIu32 " %s\" first.",
+			  seg->area_count - removed_slvs - 1, display_lvname(lv));
+		return 0;
+	}
+
 	/*
 	 * Check acceptible options mirrors, region_size,
 	 * stripes and/or stripe_size have been provided.
diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index 05c4784..f9ff744 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -110,7 +110,7 @@ aux wait_for_sync $vg $lv1
 _reshape_layout raid5_ls 3 4 $vg $lv1 --stripesize 256K
 check lv_first_seg_field $vg/$lv1 stripesize "256.00k"
 
-# Convert raid5(_n) -> striped
+# Convert raid5(_n) -> striped testing raid5_ls gets rejected
 not _lvconvert striped striped 3 3 $vg $lv1 512k
 _reshape_layout raid5_n 3 4 $vg $lv1
 _lvconvert striped striped 3 3 $vg $lv1
@@ -144,8 +144,18 @@ _reshape_layout raid5_ls 63 64 $vg $lv1 --stripes 63
 _reshape_layout raid5_ls 27 64 $vg $lv1 --stripes 27 --force
 _reshape_layout raid5_ls 27 28 $vg $lv1 --stripes 27
 
-# Convert raid5_ls back to 4 stripes
+# Convert raid5_ls back to 4 stripes checking
+# conversion to striped/raid* gets rejected
+# with existing LVs to be removed afer reshape
 _reshape_layout raid5_ls 4 28 $vg $lv1 --stripes 4 --force
+
+# No we got the data reshaped and the freed SubLVs still present
+# -> check takeover request gets rejected
+not lvconvert --yes --type striped $vg/$lv1
+not lvconvert --yes --type raid0 $vg/$lv1
+not lvconvert --yes --type raid0_meta $vg/$lv1
+not lvconvert --yes --type raid6 $vg/$lv1
+# Remove the freed SubLVs
 _reshape_layout raid5_ls 4 5 $vg $lv1 --stripes 4
 
 # Convert raid5_ls back to 3 stripes



From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:40 +0000 (UTC)
Subject: master - lvconvert: impose region size constraints
Message-ID: <20170224063240.C26EE60B26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=189fa647931834b0d9cb30c20d16785b8e8923c9
Commit:        189fa647931834b0d9cb30c20d16785b8e8923c9
Parent:        3bdc4045c2abbf9ea11000b76eeefab9fed16033
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 07:27:43 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 07:27:43 2017 +0100

lvconvert: impose region size constraints

When requesting a regionsize change during conversions, check
for constraints or the command may fail in the kernel n case
the region size is too smalle or too large thus leaving any
new SubLVs behind.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |   86 +++++++++++++++++++++++++++++++-------------
 tools/lvconvert.c         |    2 +
 2 files changed, 62 insertions(+), 26 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 34567bd..34e8856 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -94,6 +94,27 @@ uint32_t raid_ensure_min_region_size(const struct logical_volume *lv, uint64_t r
 	return region_size;
 }
 
+/* check constraints on region size vs. stripe and LV size on @lv */
+static int _check_region_size_constraints(struct logical_volume *lv,
+					  const struct segment_type *segtype,
+					  uint32_t region_size,
+					  uint32_t stripe_size)
+{
+	if (region_size < stripe_size) {
+		log_error("Regionsize may not be smaller than stripe size on %s LV %s.",
+			  segtype->name, display_lvname(lv));
+		return 0;
+	}
+
+	if (region_size * 8 > lv->size) {
+		log_error("Regionsize too large for %s LV %s.",
+			   segtype->name, display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Check for maximum number of raid devices.
  * Constrained by kernel MD maximum device limits _and_ dm-raid superblock
@@ -2142,6 +2163,9 @@ static int _raid_reshape(struct logical_volume *lv,
 	if (!_check_max_raid_devices(new_image_count))
 		return_0;
 
+	if (!_check_region_size_constraints(lv, new_segtype, new_region_size, new_stripe_size))
+		return 0;
+
 	if (!_raid_in_sync(lv)) {
 		log_error("Unable to convert %s while it is not in-sync.",
 			  display_lvname(lv));
@@ -4772,6 +4796,9 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 	}
 
+	if (!_check_region_size_constraints(lv, new_segtype, new_region_size, new_stripe_size))
+		return 0;
+
 	if (seg_is_any_raid10(seg) && (seg->area_count % seg->data_copies)) {
 		log_error("Can't convert %s LV %s to %s with odd number of stripes.",
 			  lvseg_name(seg), display_lvname(lv), new_segtype->name);
@@ -4853,7 +4880,8 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 		seg->region_size = 0;
 		if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0_META)))
 			return_0;
-	}
+	} else
+		seg->region_size = new_region_size;
 
 	if (segtype_is_striped_target(new_segtype)) {
 		if (!_convert_raid0_to_striped(lv, 0, &removal_lvs))
@@ -5035,6 +5063,11 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 			new_stripe_size = 128;
 	}
 
+	region_size = seg->region_size;
+
+	if (!_check_region_size_constraints(lv, new_segtype, new_region_size, new_stripe_size))
+		return 0;
+
 	/* Archive metadata */
 	if (!archive(lv->vg))
 		return_0;
@@ -5065,7 +5098,6 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 
 
 	extents_copied = seg->extents_copied;
-	region_size = seg->region_size;
 	seg_len = seg->len;
 	stripe_size = seg->stripe_size;
 
@@ -5221,21 +5253,24 @@ static int _takeover_from_raid0_to_raid10(TAKEOVER_FN_ARGS)
 {
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 					   first_seg(lv)->area_count * 2 /* new_image_count */,
-					   2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+					   2 /* data_copies */, 0, new_stripe_size,
+					   new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_to_raid45(TAKEOVER_FN_ARGS)
 {
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 					   first_seg(lv)->area_count + 1 /* new_image_count */,
-					   2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+					   2 /* data_copies */, 0, new_stripe_size,
+					   new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_to_raid6(TAKEOVER_FN_ARGS)
 {
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 					   first_seg(lv)->area_count + 2 /* new_image_count */,
-					   3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+					   3 /* data_copies */, 0, new_stripe_size,
+					   new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_to_striped(TAKEOVER_FN_ARGS)
@@ -5273,21 +5308,24 @@ static int _takeover_from_raid0_meta_to_raid10(TAKEOVER_FN_ARGS)
 {
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 						      first_seg(lv)->area_count * 2 /* new_image_count */,
-						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+						      2 /* data_copies */, 0, new_stripe_size,
+						      new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_meta_to_raid45(TAKEOVER_FN_ARGS)
 {
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 						      first_seg(lv)->area_count + 1 /* new_image_count */,
-						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+						      2 /* data_copies */, 0, new_stripe_size,
+						      new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_meta_to_raid6(TAKEOVER_FN_ARGS)
 {
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 						      first_seg(lv)->area_count + 2 /* new_image_count */,
-						      3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+						      3 /* data_copies */, 0, new_stripe_size,
+						      new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_meta_to_striped(TAKEOVER_FN_ARGS)
@@ -5332,7 +5370,8 @@ static int _takeover_from_raid1_to_raid5(TAKEOVER_FN_ARGS)
 {
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 					   first_seg(lv)->area_count /* unchanged new_image_count */,
-					   2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+					   2 /* data_copies */, 0, new_stripe_size,
+					   new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid1_to_striped(TAKEOVER_FN_ARGS)
@@ -5369,7 +5408,7 @@ static int _takeover_from_raid5_to_raid1(TAKEOVER_FN_ARGS)
 {
 	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
 					     first_seg(lv)->area_count,
-					     2 /* data_copies */, 0, 0, 0, allocate_pvs);
+					     2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_raid54(TAKEOVER_FN_ARGS)
@@ -5390,7 +5429,8 @@ static int _takeover_from_raid45_to_raid6(TAKEOVER_FN_ARGS)
 	}
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 					   first_seg(lv)->area_count + 1 /* new_image_count */,
-					   3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+					   3 /* data_copies */, 0, new_stripe_size,
+					   new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_striped(TAKEOVER_FN_ARGS)
@@ -5411,14 +5451,14 @@ static int _takeover_from_raid6_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
 	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
 					     first_seg(lv)->area_count - 2,
-					    1 /* data_copies */, 0, 0, 0, allocate_pvs);
+					     1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_raid45(TAKEOVER_FN_ARGS)
 {
 	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
 					     first_seg(lv)->area_count - 1,
-					    2 /* data_copies */, 0, 0, 0, allocate_pvs);
+					     2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_striped(TAKEOVER_FN_ARGS)
@@ -5453,20 +5493,23 @@ static int _takeover_from_striped_to_raid10(TAKEOVER_FN_ARGS)
 {
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 					   first_seg(lv)->area_count * 2 /* new_image_count */,
-					   2 /* FIXME: variable data_copies */, 0, 0, new_region_size, allocate_pvs);
+					   2 /* FIXME: variable data_copies */, 0, new_stripe_size,
+					   new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_striped_to_raid45(TAKEOVER_FN_ARGS)
 {
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count + 1,
-					   2 /* data_copies*/, 0, 0, new_region_size, allocate_pvs);
+					   2 /* data_copies*/, 0, new_stripe_size,
+					   new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_striped_to_raid6(TAKEOVER_FN_ARGS)
 {
 	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
 					   first_seg(lv)->area_count + 2 /* new_image_count */,
-					   3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
+					   3 /* data_copies */, 0, new_stripe_size,
+					   new_region_size, allocate_pvs);
 }
 
 /*
@@ -5725,17 +5768,8 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, con
 		return 1;
 	}
 
-	if (region_size * 8 > lv->size) {
-		log_error("Requested region size too large for LV %s size %s.",
-			  display_lvname(lv), display_size(lv->vg->cmd, lv->size));
+	if (!_check_region_size_constraints(lv, seg->segtype, region_size, seg->stripe_size))
 		return 0;
-	}
-
-	if (region_size < seg->stripe_size) {
-		log_error("Requested region size for LV %s is smaller than stripe size.",
-			  display_lvname(lv));
-		return 0;
-	}
 
 	if (!_raid_in_sync(lv)) {
 		log_error("Unable to change region size on %s LV %s while it is not in-sync.",
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0db10cb..183421a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1401,6 +1401,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			lp->stripes = 0;
 		if (!arg_is_set(cmd, type_ARG))
 		       lp->segtype = NULL;
+		if (!arg_is_set(cmd, regionsize_ARG))
+		       lp->region_size = 0;
 
 		if (!lv_raid_convert(lv, lp->segtype,
 				     lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,



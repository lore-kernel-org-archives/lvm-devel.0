From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 10 Feb 2017 18:13:24 +0000 (UTC)
Subject: master - lvconvert: add conversion from/to raid10
Message-ID: <20170210181324.7DB1E60EEA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=baba3f8e2a1c6f6fcfcefaa06e87872ff63cac6d
Commit:        baba3f8e2a1c6f6fcfcefaa06e87872ff63cac6d
Parent:        68ec6940e6897192aec6480a14492a5adc6937d8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 10 19:10:05 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 10 19:13:02 2017 +0100

lvconvert: add conversion from/to raid10

Add:
- conversion support from striped/raid0/raid0_meta to/from raid10;
  raid10 goes by the near format (same as used in creation of
  raid10 LVs), which groups data copies together with their original
  blocks (e.g. 3-way striped, 2 data copies resulting in 112233 in the
  first stripe followed by 445566 in the second etc.) and is limited
  to even numbers of legs for now
- related tests to lvconvert-raid-takeover.sh
- typo

Related: rhbz1366296
---
 WHATS_NEW                             |    1 +
 lib/metadata/lv_manip.c               |    2 +-
 lib/metadata/raid_manip.c             |  220 ++++++++++++++++++++++++++++++---
 lib/metadata/segtype.h                |    3 +-
 lib/metadata/takeover_matrix.h        |    2 +-
 test/shell/lvconvert-raid-takeover.sh |   23 ++++-
 test/shell/lvresize-raid.sh           |    2 +-
 7 files changed, 230 insertions(+), 23 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7a32777..e5f1ba1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Support striped/raid0* <-> raid10_near conversions
   Support shrinking of RaidLvs
   Support region size changes on existing RaidLVs
   Avoid parallel usage of cpg_mcast_joined() in clvmd with corosync.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2e96740..dfeb3ad 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5418,7 +5418,7 @@ int lv_resize(struct logical_volume *lv,
 		}
 	}
 
-	/* Ensure stipe boundary extents! */
+	/* Ensure stripe boundary extents! */
 	if (!lp->percent && lv_is_raid(lv))
 		lp->extents =_round_to_stripe_boundary(lv->vg, lp->extents,
 						       seg_is_raid1(seg) ? 0 : _raid_stripes_count(seg),
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 288802e..3ed8ee3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -481,6 +481,161 @@ out:
 	return r;
 }
 
+/* raid0* <-> raid10_near area reorder helper: swap 2 LV segment areas @a1 and @a2 */
+static void _swap_areas(struct lv_segment_area *a1, struct lv_segment_area *a2)
+{
+	struct lv_segment_area tmp;
+
+	tmp = *a1;
+	*a1 = *a2;
+	*a2 = tmp;
+}
+
+/*
+ * Reorder the areas in the first segment of @seg to suit raid10_{near,far}/raid0 layout.
+ *
+ * raid10_{near,far} can only be reordered to raid0 if !mod(#total_devs, #mirrors)
+ *
+ * Examples with 6 disks indexed 0..5 with 3 stripes:
+ * raid0             (012345) -> raid10_{near,far} (031425) order
+ * idx                024135
+ * raid10_{near,far} (012345) -> raid0  (024135/135024) order depending on mirror leg selection (TBD)
+ * idx                031425
+ * _or_ (variations possible)
+ * idx                304152
+ *
+ * Examples 3 stripes with 9 disks indexed 0..8 to create a 3 striped raid0 with 3 data_copies per leg:
+ *         vvv
+ * raid0  (012345678) -> raid10 (034156278) order
+ *         v  v  v
+ * raid10 (012345678) -> raid0  (036124578) order depending on mirror leg selection (TBD)
+ *
+ */
+enum raid0_raid10_conversion { reorder_to_raid10_near, reorder_from_raid10_near };
+static int _reorder_raid10_near_seg_areas(struct lv_segment *seg, enum raid0_raid10_conversion conv)
+{
+	unsigned dc, idx1, idx1_sav, idx2, s, ss, str, xchg;
+	uint32_t data_copies = 2; /* seg->data_copies */
+	uint32_t *idx, stripes = seg->area_count;
+	unsigned i = 0;
+
+	/* Internal sanity checks... */
+	if (!(conv == reorder_to_raid10_near || conv == reorder_from_raid10_near))
+		return_0;
+	if ((conv == reorder_to_raid10_near && !(seg_is_striped(seg) || seg_is_any_raid0(seg))) ||
+	    (conv == reorder_from_raid10_near && !seg_is_raid10_near(seg)))
+		return_0;
+
+	/* FIXME: once more data copies supported with raid10 */
+	if (seg_is_raid10_near(seg) && (stripes % data_copies)) {
+		log_error("Can't convert %s LV %s with number of stripes not divisable by number of data copies",
+			  lvseg_name(seg), display_lvname(seg->lv));
+		return 0;
+	}
+
+	/* FIXME: once more data copies supported with raid10 */
+	stripes /= data_copies;
+
+	if (!(idx = dm_pool_zalloc(seg_lv(seg, 0)->vg->vgmem, seg->area_count * sizeof(*idx))))
+		return 0;
+
+	/* Set up positional index array */
+	switch (conv) {
+	case reorder_to_raid10_near:
+		/*
+		 * raid0  (012 345) with 3 stripes/2 data copies     -> raid10 (031425)
+		 *
+		 * _reorder_raid10_near_seg_areas 2137 idx[0]=0
+		 * _reorder_raid10_near_seg_areas 2137 idx[1]=2
+		 * _reorder_raid10_near_seg_areas 2137 idx[2]=4
+		 * _reorder_raid10_near_seg_areas 2137 idx[3]=1
+		 * _reorder_raid10_near_seg_areas 2137 idx[4]=3
+		 * _reorder_raid10_near_seg_areas 2137 idx[5]=5
+		 *
+		 * raid0  (012 345 678) with 3 stripes/3 data copies -> raid10 (036147258)
+		 *
+		 * _reorder_raid10_near_seg_areas 2137 idx[0]=0
+		 * _reorder_raid10_near_seg_areas 2137 idx[1]=3
+		 * _reorder_raid10_near_seg_areas 2137 idx[2]=6
+		 *
+		 * _reorder_raid10_near_seg_areas 2137 idx[3]=1
+		 * _reorder_raid10_near_seg_areas 2137 idx[4]=4
+		 * _reorder_raid10_near_seg_areas 2137 idx[5]=7
+		 * _reorder_raid10_near_seg_areas 2137 idx[6]=2
+		 * _reorder_raid10_near_seg_areas 2137 idx[7]=5
+		 * _reorder_raid10_near_seg_areas 2137 idx[8]=8
+		 */
+		/* idx[from] = to */
+		for (s = ss = 0; s < seg->area_count; s++)
+			if (s < stripes)
+				idx[s] = s * data_copies;
+
+			else {
+				uint32_t factor = s % stripes;
+
+				if (!factor)
+					ss++;
+
+				idx[s] = ss + factor * data_copies;
+			}
+
+		break;
+
+	case reorder_from_raid10_near:
+		/*
+		 * Order depending on mirror leg selection (TBD)
+		 *
+		 * raid10 (012345) with 3 stripes/2 data copies    -> raid0  (024135/135024)
+		 * raid10 (012345678) with 3 stripes/3 data copies -> raid0  (036147258/147036258/...)
+		 */
+		/* idx[from] = to */
+		for (s = 0; s < seg->area_count; s++)
+			idx[s] = -1; /* = unused */
+
+		idx1 = 0;
+		idx2 = stripes;
+		for (str = 0; str < stripes; str++) {
+			idx1_sav = idx1;
+			for (dc = 0; dc < data_copies; dc++) {
+				struct logical_volume *slv;
+				s = str * data_copies + dc;
+				slv = seg_lv(seg, s);
+				idx[s] = ((slv->status & PARTIAL_LV) || idx1 != idx1_sav) ? idx2++ : idx1++;
+			}
+
+			if (idx1 == idx1_sav) {
+				log_error("Failed to find a valid mirror in stripe %u!", str);
+				return 0;
+			}
+		}
+
+		break;
+
+	default:
+		return 0;
+	}
+
+	/* Sort areas */
+	do {
+		xchg = seg->area_count;
+
+		for (s = 0; s < seg->area_count ; s++)
+			if (idx[s] == s)
+				xchg--;
+
+			else {
+				_swap_areas(seg->areas + s, seg->areas + idx[s]);
+				_swap_areas(seg->meta_areas + s, seg->meta_areas + idx[s]);
+				ss = idx[idx[s]];
+				idx[idx[s]] = idx[s];
+				idx[s] = ss;
+			}
+		i++;
+	} while (xchg);
+
+	return 1;
+}
+
 /*
  * _shift_and_rename_image_components
  * @seg: Top-level RAID segment
@@ -2646,6 +2801,12 @@ static struct possible_takeover_reshape_type _possible_takeover_reshape_types[]
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
 
+	/* striped,raid0* <-> raid10_near */
+	{ .current_types  = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID10_NEAR,
+	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID10_NEAR,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+
 	/* raid5_ls <-> raid6_ls_6 */
 	{ .current_types  = SEG_RAID5_LS|SEG_RAID6_LS_6,
 	  .possible_types = SEG_RAID5_LS|SEG_RAID6_LS_6,
@@ -3151,7 +3312,7 @@ static int _shift_parity_dev(struct lv_segment *seg)
 
 /* raid456 -> raid0* / striped */
 static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS);
-static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
+static int _raid45610_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 {
 	int rename_sublvs = 0;
 	struct lv_segment *seg = first_seg(lv);
@@ -3196,6 +3357,10 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 			log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
 			return 0;
 		}
+	} else if (seg_is_raid10_near(seg)) {
+		log_debug_metadata("Reordering areas for raid10 -> raid0 takeover");
+		if (!_reorder_raid10_near_seg_areas(seg, reorder_from_raid10_near))
+			return 0;
 	}
 
 	/* Remove meta and data LVs requested */
@@ -3348,9 +3513,6 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 
 	dm_list_init(&removal_lvs);
 
-	if (seg_is_raid10(seg))
-		return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
-
 	if (new_data_copies > new_image_count) {
 		log_error("N number of data_copies \"--mirrors N-1\" may not be larger than number of stripes.");
 		return 0;
@@ -3409,6 +3571,10 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 	     !_rename_area_lvs(lv, "_"))) {
 		log_error("Can't convert %s to %s.", display_lvname(lv), new_segtype->name);
 		return 0;
+	} else if (segtype_is_raid10_near(new_segtype)) {
+		log_debug_metadata("Reordering areas for raid0 -> raid10 takeover");
+		if (!_reorder_raid10_near_seg_areas(seg, reorder_to_raid10_near))
+			return 0;
 	}
 
 	seg->segtype = new_segtype;
@@ -3514,7 +3680,9 @@ static int _takeover_from_raid0_to_raid1(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+						      first_seg(lv)->area_count * 2 /* new_image_count */,
+						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_to_raid45(TAKEOVER_FN_ARGS)
@@ -3564,7 +3732,9 @@ static int _takeover_from_raid0_meta_to_raid1(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_meta_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+						      first_seg(lv)->area_count * 2 /* new_image_count */,
+						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_meta_to_raid45(TAKEOVER_FN_ARGS)
@@ -3641,12 +3811,12 @@ static int _takeover_from_raid45_to_mirrored(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid45_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_raid1(TAKEOVER_FN_ARGS)
@@ -3677,30 +3847,30 @@ static int _takeover_from_raid45_to_raid6(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid45_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1, 1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
+	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
 						    1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
+	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
 						    1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1,
+	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1,
 						    2 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
+	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
 						    2 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
@@ -3727,7 +3897,9 @@ static int _takeover_from_striped_to_raid0_meta(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_striped_to_raid10(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+						      first_seg(lv)->area_count * 2 /* new_image_count */,
+						      2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_striped_to_raid45(TAKEOVER_FN_ARGS)
@@ -3744,6 +3916,8 @@ static int _takeover_from_striped_to_raid6(TAKEOVER_FN_ARGS)
 }
 
 /*
+ * Only if we decide to support raid01 at all.
+ 
 static int _takeover_from_raid01_to_raid01(TAKEOVER_FN_ARGS)
 {
 	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
@@ -3758,6 +3932,7 @@ static int _takeover_from_raid01_to_striped(TAKEOVER_FN_ARGS)
 {
 	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
+*/
 
 static int _takeover_from_raid10_to_linear(TAKEOVER_FN_ARGS)
 {
@@ -3771,17 +3946,22 @@ static int _takeover_from_raid10_to_mirrored(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid10_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count / 2,
+						      1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
+/*
+ * Only if we decide to support raid01 at all.
 static int _takeover_from_raid10_to_raid01(TAKEOVER_FN_ARGS)
 {
 	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
+*/
 
 static int _takeover_from_raid10_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count / 2,
+						      1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid10_to_raid1(TAKEOVER_FN_ARGS)
@@ -3789,16 +3969,20 @@ static int _takeover_from_raid10_to_raid1(TAKEOVER_FN_ARGS)
 	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
+/*
+ * This'd be a reshape, not a takeover.
+ *
 static int _takeover_from_raid10_to_raid10(TAKEOVER_FN_ARGS)
 {
 	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
+*/
 
 static int _takeover_from_raid10_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid45610_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count / 2,
+						      1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
-*/
 
 /*
  * Import takeover matrix.
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index e8fd26f..9212824 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -50,7 +50,8 @@ struct dev_manager;
 #define SEG_RAID0		0x0000000000040000ULL
 #define SEG_RAID0_META		0x0000000000080000ULL
 #define SEG_RAID1		0x0000000000100000ULL
-#define SEG_RAID10		0x0000000000200000ULL
+#define SEG_RAID10_NEAR		0x0000000000200000ULL
+#define SEG_RAID10		SEG_RAID10_NEAR
 #define SEG_RAID4		0x0000000000400000ULL
 #define SEG_RAID5_N		0x0000000000800000ULL
 #define SEG_RAID5_LA		0x0000000001000000ULL
diff --git a/lib/metadata/takeover_matrix.h b/lib/metadata/takeover_matrix.h
index 0736643..bb3e6cb 100644
--- a/lib/metadata/takeover_matrix.h
+++ b/lib/metadata/takeover_matrix.h
@@ -112,7 +112,7 @@ static takeover_fn_t _takeover_fns[][11] = {
         /* raid1      */ { r1__lin,  r1__str,  r1__mir,  r1__r0,  r1__r0m,  r1__r1,  r1__r45,  X     ,  r1__r10,  X      , X },
         /* raid4/5    */ { r45_lin,  r45_str,  r45_mir,  r45_r0,  r45_r0m,  r45_r1,  r45_r54,  r45_r6,  X      ,  X      , X },
         /* raid6      */ { X      ,  r6__str,  X      ,  r6__r0,  r6__r0m,  X     ,  r6__r45,  X     ,  X      ,  X      , X },
-        /* raid10     */ // { r10_lin,  r10_str,  r10_mir,  r10_r0,  r10_r0m,  r10_r1,  X      ,  X     ,  r10_r10,  r10_r01, X },
+        /* raid10     */ { r10_lin,  r10_str,  r10_mir,  r10_r0,  r10_r0m,  r10_r1,  X      ,  X     ,  X      ,  X	 , X },
         /* raid01     */ // { X      ,  r01_str,  X      ,  X     ,  X      ,  X     ,  X      ,  X     ,  r01_r10,  r01_r01, X },
         /* other      */ { X      ,  X      ,  X      ,  X     ,  X      ,  X     ,  X      ,  X     ,  X      ,  X      , X },
 };
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index c7b569a..257d169 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -19,7 +19,7 @@ aux have_raid 1 9 0 || skip
 correct_raid4_layout=0
 aux have_raid 1 9 1 && correct_raid4_layout=1
 
-aux prepare_vg 6 80
+aux prepare_vg 8 80
 
 function _lvcreate
 {
@@ -242,6 +242,27 @@ _lvconvert raid0_meta raid0_meta 3 $vg $lv1
 # Convert raid0_meta -> raid6_n_6
 _lvconvert raid6 raid6_n_6 5 $vg $lv1
 
+# Convert raid6_n_6 -> striped
+_lvconvert striped striped 3 $vg $lv1
+
+# Convert striped -> raid10
+_lvconvert raid10 raid10 6 $vg $lv1
+
+# Convert raid10 -> raid0
+_lvconvert raid0 raid0 3 $vg $lv1
+
+# Convert raid0 -> raid10
+_lvconvert raid10 raid10 6 $vg $lv1
+
+# Convert raid10 -> raid0
+_lvconvert raid0_meta raid0_meta 3 $vg $lv1
+
+# Convert raid0_meta -> raid10
+_lvconvert raid10 raid10 6 $vg $lv1
+
+# Convert raid10 -> striped
+_lvconvert striped striped 3 $vg $lv1
+
 # Clean up
 lvremove -y $vg
 
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 4f22740..b4f6058 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -19,7 +19,7 @@ aux have_raid 1 3 0 || skip
 levels="5 6 10"
 aux have_raid4 && levels="0 0_meta 4 $levels"
 
-aux prepare_pvs 6 80
+aux prepare_pvs 6
 
 vgcreate -s 256K $vg $(cat DEVICES)
 



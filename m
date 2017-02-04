From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat,  4 Feb 2017 00:42:38 +0000 (UTC)
Subject: master - lvconvert: add segtype raid6_n_6 and conversions to/from it
Message-ID: <20170204004238.D06536003D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3673ce48e0d6147fe7a24fcce97130fab8914e51
Commit:        3673ce48e0d6147fe7a24fcce97130fab8914e51
Parent:        96f331fe05297259274c04ac7fbd7d99eb911c77
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Feb 4 01:40:58 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Feb 4 01:42:21 2017 +0100

lvconvert: add segtype raid6_n_6 and conversions to/from it

Add:
- support for segment type raid6_n_6 (striped raid with dedicated last parity/Q-Syndrome SubLVs)
- conversion support from striped/raid0/raid0_meta/raid4 to/from raid6_n_6
- related tests to lvconvert-raid-takeover.sh

Related: rhbz1366296
---
 lib/metadata/raid_manip.c             |   70 +++++++++++++++++++--------
 lib/raid/raid.c                       |    1 +
 libdm/libdm-deptree.c                 |    5 ++
 test/shell/lvconvert-raid-takeover.sh |   85 +++++++++++++++++++++++++++++++++
 4 files changed, 140 insertions(+), 21 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 3543a69..b769e34 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2534,11 +2534,7 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
  * Change the user's requested segment type to 
  * the appropriate more-refined one for takeover.
  *
- * raid0 can take over:
- *  raid4
- *
- * raid4 can take over:
- *  raid0 - if there is only one stripe zone
+ *  raid can takeover striped,raid0 if there is only one stripe zone
  */
 #define	ALLOW_NONE		0x0
 #define	ALLOW_STRIPES		0x2
@@ -2575,9 +2571,9 @@ static struct possible_takeover_reshape_type _possible_takeover_reshape_types[]
 	  .current_areas = 1,
 	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
 
-	/* striped,raid0*,raid4,raid5_n <-> striped,raid0*,raid4,raid5_n */
-	{ .current_types  = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID4|SEG_RAID5_N,
-	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID4|SEG_RAID5_N,
+	/* striped,raid0*,raid4,raid5_n,raid6_n_6 <-> striped,raid0*,raid4,raid5_n,raid6_n_6 */
+	{ .current_types  = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6,
+	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6,
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
 
@@ -3061,7 +3057,8 @@ static int _shift_parity_dev(struct lv_segment *seg)
 	return 1;
 }
 
-/* raid45 -> raid0* / striped */
+/* raid456 -> raid0* / striped */
+static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS);
 static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 {
 	int rename_sublvs = 0;
@@ -3084,8 +3081,9 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 
 	if (!yes && yes_no_prompt("Are you sure you want to convert \"%s\" LV %s to \"%s\" "
-				  "type losing all resilience? [y/n]: ",
-				  lvseg_name(seg), display_lvname(lv), new_segtype->name) == 'n') {
+				  "type losing %s resilience? [y/n]: ",
+				  lvseg_name(seg), display_lvname(lv), new_segtype->name,
+				  segtype_is_striped(new_segtype) ? "all" : "some") == 'n') {
 		log_error("Logical volume %s NOT converted to \"%s\"",
 			  display_lvname(lv), new_segtype->name);
 		return 0;
@@ -3135,8 +3133,13 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 		   !_raid0_add_or_remove_metadata_lvs(lv, 0 /* update_and_reload */, allocate_pvs, &removal_lvs))
 		return_0;
 
+	if (segtype_is_raid4(new_segtype)) {
+		if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID5_N)))
+			return_0;
+	} else
+		seg->segtype = new_segtype;
+
 	seg->region_size = region_size;
-	seg->segtype = new_segtype;
 
 	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, &removal_lvs))
 		return_0;
@@ -3150,6 +3153,10 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 			return_0;
 	}
 
+	if (segtype_is_raid4(new_segtype))
+		return _raid45_to_raid54_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count,
+						 1 /* data_copies */, 0, 0, 0, allocate_pvs);
+
 	return 1;
 }
 
@@ -3287,7 +3294,8 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 
 	/* FIXME: restricted to raid4 and raid5_n for the time being... */
 	if (!segtype_is_raid4(new_segtype) &&
-	    !segtype_is_raid5_n(new_segtype)) {
+	    !segtype_is_raid5_n(new_segtype) &&
+	    !segtype_is_raid6_n_6(new_segtype)) {
 		/* Can't convert striped/raid0* to e.g. raid10_offset */
 		log_error("Can't convert %s to %s.", display_lvname(lv), new_segtype->name);
 		return 0;
@@ -3456,7 +3464,9 @@ static int _takeover_from_raid0_to_raid45(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+						      first_seg(lv)->area_count + 2 /* new_image_count */,
+						      3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_to_striped(TAKEOVER_FN_ARGS)
@@ -3504,7 +3514,9 @@ static int _takeover_from_raid0_meta_to_raid45(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid0_meta_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+						      first_seg(lv)->area_count + 2 /* new_image_count */,
+						      3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid0_meta_to_striped(TAKEOVER_FN_ARGS)
@@ -3587,7 +3599,17 @@ static int _takeover_from_raid45_to_raid54(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid45_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	if (seg_is_raid4(first_seg(lv))) {
+		struct segment_type *segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID5_N);
+
+		if (!segtype ||
+		    !_raid45_to_raid54_wrapper(lv, segtype, yes, force, first_seg(lv)->area_count,
+					       1 /* data_copies */, 0, 0, 0, allocate_pvs))
+			return 0;
+	}
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+						      first_seg(lv)->area_count + 1 /* new_image_count */,
+						      3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_striped(TAKEOVER_FN_ARGS)
@@ -3597,22 +3619,26 @@ static int _takeover_from_raid45_to_striped(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid6_to_raid0(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
+						    1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
+						    1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_raid45(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 1,
+						    2 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid6_to_striped(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _raid456_to_raid0_or_striped_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count - 2,
+						    2 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_striped_to_raid0(TAKEOVER_FN_ARGS)
@@ -3649,7 +3675,9 @@ static int _takeover_from_striped_to_raid45(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_striped_to_raid6(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _striped_or_raid0_to_raid45610_wrapper(lv, new_segtype, yes, force,
+						      first_seg(lv)->area_count + 2 /* new_image_count */,
+						      3 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 /*
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 7dfafef..631ffb7 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -543,6 +543,7 @@ static const struct raid_type {
 	{ SEG_TYPE_NAME_RAID5_RA,   1, SEG_RAID5_RA },
 	{ SEG_TYPE_NAME_RAID5_RS,   1, SEG_RAID5_RS },
 	{ SEG_TYPE_NAME_RAID6,      2, SEG_RAID6 },
+	{ SEG_TYPE_NAME_RAID6_N_6,  2, SEG_RAID6_N_6 },
 	{ SEG_TYPE_NAME_RAID6_NC,   2, SEG_RAID6_NC },
 	{ SEG_TYPE_NAME_RAID6_NR,   2, SEG_RAID6_NR },
 	{ SEG_TYPE_NAME_RAID6_ZR,   2, SEG_RAID6_ZR }
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 8a32320..bd6c63d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -52,6 +52,7 @@ enum {
 	SEG_RAID5_RA,
 	SEG_RAID5_LS,
 	SEG_RAID5_RS,
+	SEG_RAID6_N_6,
 	SEG_RAID6_ZR,
 	SEG_RAID6_NR,
 	SEG_RAID6_NC,
@@ -87,6 +88,7 @@ static const struct {
 	{ SEG_RAID5_RA, "raid5_ra"},
 	{ SEG_RAID5_LS, "raid5_ls"},
 	{ SEG_RAID5_RS, "raid5_rs"},
+	{ SEG_RAID6_N_6,"raid6_n_6"},
 	{ SEG_RAID6_ZR, "raid6_zr"},
 	{ SEG_RAID6_NR, "raid6_nr"},
 	{ SEG_RAID6_NC, "raid6_nc"},
@@ -2147,6 +2149,7 @@ static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 		case SEG_RAID5_RA:
 		case SEG_RAID5_LS:
 		case SEG_RAID5_RS:
+		case SEG_RAID6_N_6:
 		case SEG_RAID6_ZR:
 		case SEG_RAID6_NR:
 		case SEG_RAID6_NC:
@@ -2596,6 +2599,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	case SEG_RAID5_RA:
 	case SEG_RAID5_LS:
 	case SEG_RAID5_RS:
+	case SEG_RAID6_N_6:
 	case SEG_RAID6_ZR:
 	case SEG_RAID6_NR:
 	case SEG_RAID6_NC:
@@ -3878,6 +3882,7 @@ int dm_tree_node_add_null_area(struct dm_tree_node *node, uint64_t offset)
 	case SEG_RAID5_RA:
 	case SEG_RAID5_LS:
 	case SEG_RAID5_RS:
+	case SEG_RAID6_N_6:
 	case SEG_RAID6_ZR:
 	case SEG_RAID6_NR:
 	case SEG_RAID6_NC:
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 0b7d326..b45088e 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -231,6 +231,91 @@ check lv_field $vg/$lv1 segtype "striped"
 check lv_field $vg/$lv1 stripes 3
 fsck -fn  /dev/mapper/$vg-$lv1
 
+
+
+
+# Convert striped -> raid6_n_6
+lvconvert -y --ty raid6_n_6 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid6_n_6"
+check lv_field $vg/$lv1 stripes 5
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid6_n_6 -> striped
+lvconvert -y --ty striped $vg/$lv1
+check lv_field $vg/$lv1 segtype "striped"
+check lv_field $vg/$lv1 stripes 3
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert striped -> raid6_n_6
+lvconvert -y --ty raid6_n_6 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid6_n_6"
+check lv_field $vg/$lv1 stripes 5
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid6_n_6 -> raid5_n
+lvconvert -y --ty raid5_n $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid5_n"
+check lv_field $vg/$lv1 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid5_n -> raid6_n_6
+lvconvert -y --ty raid6_n_6 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid6_n_6"
+check lv_field $vg/$lv1 stripes 5
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid6_n_6 -> raid4
+lvconvert -y --ty raid4 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid4"
+check lv_field $vg/$lv1 stripes 4
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid4 -> raid6_n_6
+lvconvert -y --ty raid6_n_6 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid6_n_6"
+check lv_field $vg/$lv1 stripes 5
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid6_n_6 -> raid0
+lvconvert -y --ty raid0 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid0"
+check lv_field $vg/$lv1 stripes 3
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid0 -> raid6_n_6
+lvconvert -y --ty raid6_n_6 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid6_n_6"
+check lv_field $vg/$lv1 stripes 5
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid6_n_6 -> raid0_meta
+lvconvert -y --ty raid0_meta $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid0_meta"
+check lv_field $vg/$lv1 stripes 3
+fsck -fn  /dev/mapper/$vg-$lv1
+
+# Convert raid0_meta -> raid6_n_6
+lvconvert -y --ty raid6_n_6 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid6_n_6"
+check lv_field $vg/$lv1 stripes 5
+fsck -fn  /dev/mapper/$vg-$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn  /dev/mapper/$vg-$lv1
+
 else
 
 not lvcreate -y -aey --type raid4 -i 3 -L 64M -n $lv4 $vg



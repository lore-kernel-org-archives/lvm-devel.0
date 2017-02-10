From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 10 Feb 2017 22:37:25 +0000 (UTC)
Subject: master - lvconvert: add region size checks
Message-ID: <20170210223725.099D560E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28ea66d46d46414d6ab1c452115ff5120f4a9525
Commit:        28ea66d46d46414d6ab1c452115ff5120f4a9525
Parent:        caa2094e33188806137a8fe6d8c6ecce779ecc59
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 10 23:35:53 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 10 23:37:08 2017 +0100

lvconvert: add region size checks

Add:
- region size checks to raid_manip.c types array and supporting functions
- tests to lvconvert-raid-takeover.sh to check bogus
  "lvconvert --type  --regionsize N " requests

Related: rhbz1366296
---
 lib/metadata/raid_manip.c             |   72 +++++++++++++++++++++------------
 test/shell/lvconvert-raid-takeover.sh |    5 ++
 2 files changed, 51 insertions(+), 26 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 3ed8ee3..dbb6128 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2763,6 +2763,7 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 #define	ALLOW_NONE		0x0
 #define	ALLOW_STRIPES		0x2
 #define	ALLOW_STRIPE_SIZE	0x4
+#define	ALLOW_REGION_SIZE	0x8
 
 struct possible_takeover_reshape_type {
 	/* First 2 have to stay... */
@@ -2779,64 +2780,77 @@ struct possible_type {
 };
 
 static struct possible_takeover_reshape_type _possible_takeover_reshape_types[] = {
-	/* striped -> */
+	/* striped -> raid1 */
 	{ .current_types  = SEG_STRIPED_TARGET, /* linear, i.e. seg->area_count = 1 */
 	  .possible_types = SEG_RAID1,
 	  .current_areas = 1,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+	  .options = ALLOW_REGION_SIZE },
+
 	{ .current_types  = SEG_STRIPED_TARGET, /* linear, i.e. seg->area_count = 1 */
 	  .possible_types = SEG_RAID0|SEG_RAID0_META,
 	  .current_areas = 1,
 	  .options = ALLOW_STRIPE_SIZE },
 
-	/* raid0* -> */
+	/* raid0* -> raid1 */
 	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* seg->area_count = 1 */
 	  .possible_types = SEG_RAID1,
 	  .current_areas = 1,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+	  .options = ALLOW_REGION_SIZE },
+
+	/* striped,raid0* <-> striped,raid0* */
+	{ .current_types  = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
+	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE },
 
-	/* striped,raid0*,raid4,raid5_n,raid6_n_6 <-> striped,raid0*,raid4,raid5_n,raid6_n_6 */
-	{ .current_types  = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6,
-	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6,
+	/* striped,raid0* -> raid4,raid5_n,raid6_n_6,raid10_near */
+	{ .current_types  = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
+	  .possible_types = SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6|SEG_RAID10_NEAR,
 	  .current_areas = ~0U,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+	  .options = ALLOW_REGION_SIZE },
 
-	/* striped,raid0* <-> raid10_near */
-	{ .current_types  = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID10_NEAR,
-	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META|SEG_RAID10_NEAR,
+	/* raid4,raid5_n,raid6_n_6,raid10_near -> striped/raid0* */
+	{ .current_types  = SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6|SEG_RAID10_NEAR,
+	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
 	  .current_areas = ~0U,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+	  .options = ALLOW_NONE },
+
+	/* raid4,raid5_n,raid6_n_6 <-> raid4,raid5_n,raid6_n_6 */
+	{ .current_types  = SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6,
+	  .possible_types = SEG_RAID4|SEG_RAID5_N|SEG_RAID6_N_6,
+	  .current_areas = ~0U,
+	  .options = ALLOW_REGION_SIZE },
+
 
 	/* raid5_ls <-> raid6_ls_6 */
 	{ .current_types  = SEG_RAID5_LS|SEG_RAID6_LS_6,
 	  .possible_types = SEG_RAID5_LS|SEG_RAID6_LS_6,
 	  .current_areas = ~0U,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+	  .options = ALLOW_REGION_SIZE },
 
 	/* raid5_rs -> raid6_rs_6 */
 	{ .current_types  = SEG_RAID5_RS|SEG_RAID6_RS_6,
 	  .possible_types = SEG_RAID5_RS|SEG_RAID6_RS_6,
 	  .current_areas = ~0U,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+	  .options = ALLOW_REGION_SIZE },
 
 	/* raid5_ls -> raid6_la_6 */
 	{ .current_types  = SEG_RAID5_LA|SEG_RAID6_LA_6,
 	  .possible_types = SEG_RAID5_LA|SEG_RAID6_LA_6,
 	  .current_areas = ~0U,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+	  .options = ALLOW_REGION_SIZE },
 
 	/* raid5_ls -> raid6_ra_6 */
 	{ .current_types  = SEG_RAID5_RA|SEG_RAID6_RA_6,
 	  .possible_types = SEG_RAID5_RA|SEG_RAID6_RA_6,
 	  .current_areas = ~0U,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
-
+	  .options = ALLOW_REGION_SIZE },
 
 	/* mirror <-> raid1 with arbitrary number of legs */
 	{ .current_types  = SEG_MIRROR|SEG_RAID1,
 	  .possible_types = SEG_MIRROR|SEG_RAID1,
 	  .current_areas = ~0U,
-	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+	  .options = ALLOW_REGION_SIZE },
 
 	/* END */
 	{ .current_types  = 0 }
@@ -4108,7 +4122,7 @@ replaced:
  * Change region size on raid @lv to @region_size if
  * different from current region_size and adjusted region size
  */
-static int _region_size_change_requested(struct logical_volume *lv, int yes, uint32_t region_size,
+static int _region_size_change_requested(struct logical_volume *lv, int yes, const uint32_t region_size,
 					 struct dm_list *allocate_pvs)
 {
 	uint32_t old_region_size;
@@ -4187,7 +4201,7 @@ if (!lv_extend(lv, seg->segtype, seg->area_count - seg->segtype->parity_devs, se
 static int _conversion_options_allowed(const struct lv_segment *seg_from,
 				       const struct segment_type **segtype_to,
 				       uint32_t new_image_count,
-				       int new_data_copies, int region_size,
+				       int new_data_copies, int new_region_size,
 				       int stripes, unsigned new_stripe_size_supplied)
 {
 	int r = 1;
@@ -4214,6 +4228,12 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 		r = 0;
 	}
 
+	if (new_region_size && !(opts & ALLOW_REGION_SIZE)) {
+		if (!_log_prohibited_option(seg_from, *segtype_to, "-R/--regionsize"))
+			stack;
+		r = 0;
+	}
+
 	return r;
 }
 
@@ -4234,13 +4254,13 @@ int lv_raid_convert(struct logical_volume *lv,
 		    const unsigned new_stripes,
 		    const unsigned new_stripe_size_supplied,
 		    const unsigned new_stripe_size,
-		    /* FIXME: workaround with volatile new_region_size until cli validation patches got merged */
-		    uint32_t new_region_size,
+		    const uint32_t new_region_size,
 		    struct dm_list *allocate_pvs)
 {
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t stripes, stripe_size;
 	uint32_t new_image_count = seg->area_count;
+	uint32_t region_size = new_region_size;
 	takeover_fn_t takeover_fn;
 
 	if (!new_segtype) {
@@ -4262,7 +4282,7 @@ int lv_raid_convert(struct logical_volume *lv,
 
 	/* Change RAID region size */
 	/*
-	 * FIXME: workaround with volatile new_region_size until the
+	 * FIXME: workaround with new_region_size until the
 	 *	  cli validation patches got merged when we'll change
 	 *	  the API to have new_region_size_supplied to check for.
 	 */
@@ -4272,7 +4292,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		   seg_is_raid(seg) && !seg_is_any_raid0(seg))
 			return _region_size_change_requested(lv, yes, new_region_size, allocate_pvs);
 	} else
-		new_region_size = seg->region_size ? : get_default_region_size(lv->vg->cmd);
+		region_size = seg->region_size ? : get_default_region_size(lv->vg->cmd);
 
 	/*
 	 * Check acceptible options mirrors, region_size,
@@ -4287,7 +4307,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	/* Exit without doing activation checks if the combination isn't possible */
 	if (_takeover_not_possible(takeover_fn))
 		return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, new_stripes, stripe_size,
-				   new_region_size, allocate_pvs);
+				   region_size, allocate_pvs);
 
 	log_verbose("Converting %s from %s to %s.",
 		    display_lvname(lv), lvseg_name(first_seg(lv)),
@@ -4318,7 +4338,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	}
 
 	return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, new_stripes, stripe_size,
-			   new_region_size, allocate_pvs);
+			   region_size, allocate_pvs);
 }
 
 static int _remove_partial_multi_segment_image(struct logical_volume *lv,
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 257d169..a219829 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -163,6 +163,7 @@ _lvcreate raid4 3 4 64M $vg $lv1
 aux wait_for_sync $vg $lv1
 
 # Convert raid4 -> striped
+not _lvconvert striped striped 3 $vg $lv1 512k
 _lvconvert striped striped 3 $vg $lv1
 
 # Convert striped -> raid4
@@ -195,6 +196,7 @@ _lvconvert raid0_meta raid0_meta 3 $vg $lv1
 _lvconvert raid5 raid5_n 4 $vg $lv1
 
 # Convert raid4 -> raid0_meta
+not _lvconvert raid0_meta raid0_meta 3 $vg $lv1 256k
 _lvconvert raid0_meta raid0_meta 3 $vg $lv1
 
 # Convert raid0_meta -> raid4
@@ -243,12 +245,14 @@ _lvconvert raid0_meta raid0_meta 3 $vg $lv1
 _lvconvert raid6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> striped
+not _lvconvert striped striped 3 $vg $lv1 128k
 _lvconvert striped striped 3 $vg $lv1
 
 # Convert striped -> raid10
 _lvconvert raid10 raid10 6 $vg $lv1
 
 # Convert raid10 -> raid0
+not _lvconvert raid0 raid0 3 $vg $lv1 64k
 _lvconvert raid0 raid0 3 $vg $lv1
 
 # Convert raid0 -> raid10
@@ -261,6 +265,7 @@ _lvconvert raid0_meta raid0_meta 3 $vg $lv1
 _lvconvert raid10 raid10 6 $vg $lv1
 
 # Convert raid10 -> striped
+not _lvconvert striped striped 3 $vg $lv1 256k
 _lvconvert striped striped 3 $vg $lv1
 
 # Clean up



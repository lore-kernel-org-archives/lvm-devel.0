From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat,  4 Feb 2017 23:57:16 +0000 (UTC)
Subject: master - lvconvert: add segtypes raid6_{ls, rs, la, ra}_6 and conversions to/from it
Message-ID: <20170204235716.6E49E60F70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4bbaa3b894f03e4ac21c979ec4e5201120703ad
Commit:        a4bbaa3b894f03e4ac21c979ec4e5201120703ad
Parent:        d8568552e460afe477f1baa7c46da81039f85b15
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sun Feb 5 00:53:36 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sun Feb 5 00:56:27 2017 +0100

lvconvert: add segtypes raid6_{ls,rs,la,ra}_6 and conversions to/from it

Add:
- support for segment types raid6_{ls,rs,la,ra}_6
  (striped raid with dedicated last Q-Syndrome SubLVs)
- conversion support from raid5_{ls,rs,la,ra} to/from raid6_{ls,rs,la,ra}_6
- setting convenient segtypes on conversions from/to raid4/5/6
- related tests to lvconvert-raid-takeover.sh factoring
  out _lvcreate,_lvconvert funxtions

Related: rhbz1366296
---
 WHATS_NEW                             |    1 +
 lib/metadata/raid_manip.c             |  117 ++++++++-----
 lib/metadata/segtype.h                |    4 +
 lib/raid/raid.c                       |    6 +-
 libdm/libdm-deptree.c                 |   21 ++
 test/shell/lvconvert-raid-takeover.sh |  324 +++++++++++++++------------------
 6 files changed, 248 insertions(+), 225 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cfa1179..1c0ef6d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Support raid6_{ls,rs,la,ra}_6 segment types and conversions from/to it.
   Support raid6_n_6 segment type and conversions from/to it.
   Support raid5_n segment type and conversions from/to it.
   Support new internal command _dmeventd_thin_command.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b769e34..736e2ee 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2577,6 +2577,31 @@ static struct possible_takeover_reshape_type _possible_takeover_reshape_types[]
 	  .current_areas = ~0U,
 	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
 
+	/* raid5_ls <-> raid6_ls_6 */
+	{ .current_types  = SEG_RAID5_LS|SEG_RAID6_LS_6,
+	  .possible_types = SEG_RAID5_LS|SEG_RAID6_LS_6,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+
+	/* raid5_rs -> raid6_rs_6 */
+	{ .current_types  = SEG_RAID5_RS|SEG_RAID6_RS_6,
+	  .possible_types = SEG_RAID5_RS|SEG_RAID6_RS_6,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+
+	/* raid5_ls -> raid6_la_6 */
+	{ .current_types  = SEG_RAID5_LA|SEG_RAID6_LA_6,
+	  .possible_types = SEG_RAID5_LA|SEG_RAID6_LA_6,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+
+	/* raid5_ls -> raid6_ra_6 */
+	{ .current_types  = SEG_RAID5_RA|SEG_RAID6_RA_6,
+	  .possible_types = SEG_RAID5_RA|SEG_RAID6_RA_6,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE }, /* FIXME: ALLOW_REGION_SIZE */
+
+
 	/* mirror <-> raid1 with arbitrary number of legs */
 	{ .current_types  = SEG_MIRROR|SEG_RAID1,
 	  .possible_types = SEG_MIRROR|SEG_RAID1,
@@ -3068,14 +3093,6 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 
 	dm_list_init(&removal_lvs);
 
-	if (!seg_is_raid4(seg) &&
-	    !seg_is_raid5_n(seg) &&
-	    !seg_is_raid6_n_6(seg)) {
-		log_error("LV %s has to be of type raid4/raid5_n/raid6_n_6 to allow for this conversion.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	/* Necessary when convering to raid0/striped w/o redundancy? */
 	if (!_raid_in_sync(lv))
 		return 0;
@@ -3254,7 +3271,7 @@ static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 	return 1;
 }
 
-/* Helper: striped/raid0* -> raid4/5/6/10 */
+/* Helper: striped/raid0* -> raid4/5/6/10, raid45 -> raid6 wrapper */
 static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 {
 	uint32_t extents_copied, region_size, seg_len, stripe_size;
@@ -3263,25 +3280,9 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 
 	dm_list_init(&removal_lvs);
 
-	if (!seg_is_striped_target(seg) &&
-	    !seg_is_any_raid0(seg) &&
-	    !seg_is_raid4(seg) &&
-	    !seg_is_any_raid5(seg)) {
-		log_error("Can't convert %s LV %s.", lvseg_name(seg), display_lvname(lv));
-		return 0;
-	}
-
 	if (seg_is_raid10(seg))
 		return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 
-	if (!segtype_is_raid4(new_segtype) &&
-	    !segtype_is_raid5_n(new_segtype) &&
-	    !segtype_is_raid6_n_6(new_segtype)) {
-		/* Can't convert to e.g. raid10_offset */
-		log_error("Can't convert %s to %s.", display_lvname(lv), new_segtype->name);
-		return 0;
-	}
-
 	if (new_data_copies > new_image_count) {
 		log_error("N number of data_copies \"--mirrors N-1\" may not be larger than number of stripes.");
 		return 0;
@@ -3292,15 +3293,6 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 	}
 
-	/* FIXME: restricted to raid4 and raid5_n for the time being... */
-	if (!segtype_is_raid4(new_segtype) &&
-	    !segtype_is_raid5_n(new_segtype) &&
-	    !segtype_is_raid6_n_6(new_segtype)) {
-		/* Can't convert striped/raid0* to e.g. raid10_offset */
-		log_error("Can't convert %s to %s.", display_lvname(lv), new_segtype->name);
-		return 0;
-	}
-
 	/* Archive metadata */
 	if (!archive(lv->vg))
 		return_0;
@@ -3794,30 +3786,65 @@ static int _log_prohibited_option(const struct lv_segment *seg_from,
 static int _set_convenient_raid456_segtype_to(const struct lv_segment *seg_from,
 					      const struct segment_type **segtype)
 {
-	if (seg_is_striped(seg_from) || seg_is_raid4(seg_from)) {
+	size_t len = min(strlen((*segtype)->name), strlen(lvseg_name(seg_from)));
+	const struct segment_type *segtype_sav = *segtype;
+
+	/* Bail out if same RAID level is requested. */
+	if (!strncmp((*segtype)->name, lvseg_name(seg_from), len))
+		return 1;
+
+	/* Striped/raid0 -> raid5/6 */
+	if (seg_is_striped(seg_from) || seg_is_any_raid0(seg_from)) {
 		/* If this is any raid5 conversion request -> enforce raid5_n, because we convert from striped */
 		if (segtype_is_any_raid5(*segtype) &&
 		    !segtype_is_raid5_n(*segtype)) {
-			log_error("Conversion to raid5_n not yet supported.");
-			return 0;
+			if (!(*segtype = get_segtype_from_flag(seg_from->lv->vg->cmd, SEG_RAID5_N)))
+				return_0;
+			goto replaced;
 
 		/* If this is any raid6 conversion request -> enforce raid6_n_6, because we convert from striped */
 		} else if (segtype_is_any_raid6(*segtype) &&
 			   !segtype_is_raid6_n_6(*segtype)) {
-			log_error("Conversion to raid6_n_6 not yet supported.");
-			return 0;
+			if (!(*segtype = get_segtype_from_flag(seg_from->lv->vg->cmd, SEG_RAID6_N_6)))
+				return_0;
+			goto replaced;
 		}
 
-	/* ... and raid6 -> raid5 */
-	} else if ((seg_is_raid6_zr(seg_from) ||
-		    seg_is_raid6_nr(seg_from) ||
-		    seg_is_raid6_nc(seg_from)) &&
+	/* raid4 -> raid5_n */
+	} else if (seg_is_raid4(seg_from) &&
 		   segtype_is_any_raid5(*segtype)) {
-		log_error("Conversion not supported.");
-		return 0;
+		if (!(*segtype = get_segtype_from_flag(seg_from->lv->vg->cmd, SEG_RAID5_N)))
+			return_0;
+		goto replaced;
+
+	/* raid4/raid5_n -> striped/raid0/raid6 */
+	} else if ((seg_is_raid4(seg_from) || seg_is_raid5_n(seg_from)) &&
+		   !segtype_is_striped(*segtype) &&
+		   !segtype_is_any_raid0(*segtype) &&
+		   !segtype_is_raid4(*segtype) &&
+		   !segtype_is_raid5_n(*segtype) &&
+		   !segtype_is_raid6_n_6(*segtype)) {
+		if (!(*segtype = get_segtype_from_flag(seg_from->lv->vg->cmd, SEG_RAID6_N_6)))
+			return_0;
+		goto replaced;
+
+	/* ... and raid6 -> striped/raid0/raid4/raid5_n */
+	} else if (seg_is_raid6_n_6(seg_from) &&
+		   !segtype_is_striped(*segtype) &&
+		   !segtype_is_any_raid0(*segtype) &&
+		   !segtype_is_raid4(*segtype) &&
+		   !segtype_is_raid5_n(*segtype)) {
+		if (!(*segtype = get_segtype_from_flag(seg_from->lv->vg->cmd, SEG_RAID5_N)))
+			return_0;
+		goto replaced;
 	}
 
 	return 1;
+
+replaced:
+	log_warn("Replaced LV type %s with possible type %s.",
+		 segtype_sav->name, (*segtype)->name);
+	return 1;
 }
 
 /* Check allowed conversion from seg_from to *segtype_to */
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index c20149d..e8fd26f 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -132,6 +132,10 @@ struct dev_manager;
 #define segtype_is_raid6_nr(segtype)	((segtype)->flags & SEG_RAID6_NR ? 1 : 0)
 #define segtype_is_raid6_n_6(segtype)	((segtype)->flags & SEG_RAID6_N_6 ? 1 : 0)
 #define segtype_is_raid6_zr(segtype)	((segtype)->flags & SEG_RAID6_ZR ? 1 : 0)
+#define segtype_is_raid6_ls_6(segtype)	((segtype)->flags & SEG_RAID6_LS_6 ? 1 : 0)
+#define segtype_is_raid6_rs_6(segtype)	((segtype)->flags & SEG_RAID6_RS_6 ? 1 : 0)
+#define segtype_is_raid6_la_6(segtype)	((segtype)->flags & SEG_RAID6_LA_6 ? 1 : 0)
+#define segtype_is_raid6_ra_6(segtype)	((segtype)->flags & SEG_RAID6_RA_6 ? 1 : 0)
 #define segtype_is_any_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
 #define segtype_is_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
 #define segtype_is_raid10_near(segtype)	segtype_is_raid10(segtype)
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 631ffb7..c679207 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -546,7 +546,11 @@ static const struct raid_type {
 	{ SEG_TYPE_NAME_RAID6_N_6,  2, SEG_RAID6_N_6 },
 	{ SEG_TYPE_NAME_RAID6_NC,   2, SEG_RAID6_NC },
 	{ SEG_TYPE_NAME_RAID6_NR,   2, SEG_RAID6_NR },
-	{ SEG_TYPE_NAME_RAID6_ZR,   2, SEG_RAID6_ZR }
+	{ SEG_TYPE_NAME_RAID6_ZR,   2, SEG_RAID6_ZR },
+	{ SEG_TYPE_NAME_RAID6_LS_6, 2, SEG_RAID6_LS_6 },
+	{ SEG_TYPE_NAME_RAID6_RS_6, 2, SEG_RAID6_RS_6 },
+	{ SEG_TYPE_NAME_RAID6_LA_6, 2, SEG_RAID6_LA_6 },
+	{ SEG_TYPE_NAME_RAID6_RA_6, 2, SEG_RAID6_RA_6 }
 };
 
 static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index bd6c63d..9570b8a 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -56,6 +56,10 @@ enum {
 	SEG_RAID6_ZR,
 	SEG_RAID6_NR,
 	SEG_RAID6_NC,
+	SEG_RAID6_LS_6,
+	SEG_RAID6_RS_6,
+	SEG_RAID6_LA_6,
+	SEG_RAID6_RA_6,
 };
 
 /* FIXME Add crypt and multipath support */
@@ -92,6 +96,11 @@ static const struct {
 	{ SEG_RAID6_ZR, "raid6_zr"},
 	{ SEG_RAID6_NR, "raid6_nr"},
 	{ SEG_RAID6_NC, "raid6_nc"},
+	{ SEG_RAID6_LS_6, "raid6_ls_6"},
+	{ SEG_RAID6_RS_6, "raid6_rs_6"},
+	{ SEG_RAID6_LA_6, "raid6_la_6"},
+	{ SEG_RAID6_RA_6, "raid6_ra_6"},
+
 
 	/*
 	 * WARNING: Since 'raid' target overloads this 1:1 mapping table
@@ -2153,6 +2162,10 @@ static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 		case SEG_RAID6_ZR:
 		case SEG_RAID6_NR:
 		case SEG_RAID6_NC:
+		case SEG_RAID6_LS_6:
+		case SEG_RAID6_RS_6:
+		case SEG_RAID6_LA_6:
+		case SEG_RAID6_RA_6:
 			if (!area->dev_node) {
 				EMIT_PARAMS(*pos, " -");
 				break;
@@ -2603,6 +2616,10 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	case SEG_RAID6_ZR:
 	case SEG_RAID6_NR:
 	case SEG_RAID6_NC:
+	case SEG_RAID6_LS_6:
+	case SEG_RAID6_RS_6:
+	case SEG_RAID6_LA_6:
+	case SEG_RAID6_RA_6:
 		target_type_is_raid = 1;
 		r = _raid_emit_segment_line(dmt, major, minor, seg, seg_start,
 					    params, paramsize);
@@ -3886,6 +3903,10 @@ int dm_tree_node_add_null_area(struct dm_tree_node *node, uint64_t offset)
 	case SEG_RAID6_ZR:
 	case SEG_RAID6_NR:
 	case SEG_RAID6_NC:
+	case SEG_RAID6_LS_6:
+	case SEG_RAID6_RS_6:
+	case SEG_RAID6_LA_6:
+	case SEG_RAID6_RA_6:
 		break;
 	default:
 		log_error("dm_tree_node_add_null_area() called on an unsupported segment type");
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index b45088e..4565cc8 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -19,7 +19,64 @@ aux have_raid 1 9 0 || skip
 correct_raid4_layout=0
 aux have_raid 1 9 1 && correct_raid4_layout=1
 
-aux prepare_vg 9 288
+aux prepare_vg 6 80
+
+function _lvcreate
+{
+	local level=$1
+	local req_stripes=$2
+	local stripes=$3
+	local size=$4
+	local vg=$5
+	local lv=$6
+
+	lvcreate -y -aey --type $level -i $req_stripes -L $size -n $lv $vg
+	check lv_field $vg/$lv segtype "$level"
+	check lv_field $vg/$lv stripes $stripes
+	echo y | mkfs -t ext4 /dev/mapper/$vg-$lv
+	fsck -fn  /dev/mapper/$vg-$lv
+}
+
+function _lvconvert
+{
+	local req_level=$1
+	local level=$2
+	local stripes=$3
+	local vg=$4
+	local lv=$5
+	local dont_wait=$6
+
+	lvconvert -y --ty $req_level $vg/$lv
+	[ $? -ne 0 ] && return $?
+	check lv_field $vg/$lv segtype "$level"
+	check lv_field $vg/$lv stripes $stripes
+	if [ -z "$dont_wait" ]
+	then
+		fsck -fn  /dev/mapper/$vg-$lv
+		aux wait_for_sync $vg $lv
+	fi
+	fsck -fn  /dev/mapper/$vg-$lv
+}
+
+function _invalid_raid5_conversions
+{
+	local lv=$1
+	local vg=$2
+
+	not _lvconvert striped 4 $vg $lv1
+	not _lvconvert raid0 raid0 4 $vg $lv1
+	not _lvconvert raid0_meta raid0_meta 4 $vg $lv1
+	not _lvconvert raid4 raid4 5 $vg $lv1
+	not _lvconvert raid5_ls raid5_ls 5 $vg $lv1
+	not _lvconvert raid5_rs raid5_rs 5 $vg $lv1
+	not _lvconvert raid5_la raid5_la 5 $vg $lv1
+	not _lvconvert raid5_ra raid5_ra 5 $vg $lv1
+	not _lvconvert raid6_zr raid6_zr 6 $vg $lv1
+	not _lvconvert raid6_nr raid6_nr 6 $vg $lv1
+	not _lvconvert raid6_nc raid6_nc 6 $vg $lv1
+	not _lvconvert raid6_n_6 raid6_n_6 6 $vg $lv1
+	not _lvconvert raid6 raid6_n_6 6 $vg $lv1
+}
 
 # Delay 1st leg so that rebuilding status characters
 #  can be read before resync finished too quick.
@@ -81,240 +138,149 @@ aux wait_for_sync $vg $lv1
 # Clean up
 lvremove --yes $vg/$lv1
 
-# Create 3-way striped
-lvcreate -y -aey --type striped -i 3 -L 64M -n $lv1 $vg
-check lv_field $vg/$lv1 segtype "striped"
-check lv_field $vg/$lv1 stripes 3
-echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
-fsck -fn  /dev/mapper/$vg-$lv1
-
-# Create 3-way raid0
-lvcreate -y -aey --type raid0 -i 3 -L 64M -n $lv2 $vg
-check lv_field $vg/$lv2 segtype "raid0"
-check lv_field $vg/$lv2 stripes 3
-echo y | mkfs -t ext4 /dev/mapper/$vg-$lv2
-fsck -fn  /dev/mapper/$vg-$lv2
-
-# Create 3-way raid0_meta
-lvcreate -y -aey --type raid0_meta -i 3 -L 64M -n $lv3 $vg
-check lv_field $vg/$lv3 segtype "raid0_meta"
-check lv_field $vg/$lv3 stripes 3
-echo y | mkfs -t ext4 /dev/mapper/$vg-$lv3
-fsck -fn  /dev/mapper/$vg-$lv3
 
 if [ $correct_raid4_layout -eq 1 ]
 then
 
-# Create 3-way raid4
-lvcreate -y -aey --type raid4 -i 3 -L 64M -n $lv4 $vg
-check lv_field $vg/$lv4 segtype "raid4"
-check lv_field $vg/$lv4 stripes 4
-echo y | mkfs -t ext4 /dev/mapper/$vg-$lv4
-fsck -fn  /dev/mapper/$vg-$lv4
-aux wait_for_sync $vg $lv4
-fsck -fn  /dev/mapper/$vg-$lv4
+#
+# Start out with raid4
+#
 
-# Convert raid4 -> striped (correct raid4 mapping test!)
-lvconvert -y --ty striped $vg/$lv4
-check lv_field $vg/$lv4 segtype "striped"
-check lv_field $vg/$lv4 stripes 3
-fsck -fn  /dev/mapper/$vg-$lv4
+# Create 3-way striped raid4 (4 legs total)
+_lvcreate raid4 3 4 64M $vg $lv1
+aux wait_for_sync $vg $lv1
 
+# Convert raid4 -> striped
+_lvconvert striped striped 3 $vg $lv1 1
 
 # Convert striped -> raid4
-lvconvert -y --ty raid4 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid4"
-check lv_field $vg/$lv1 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid4 raid4 4 $vg $lv1
 
 # Convert raid4 -> raid5_n
-lvconvert -y --ty raid5_n $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid5_n"
-check lv_field $vg/$lv1 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid5 raid5_n 4 $vg $lv1 1
 
-# Convert raid5 -> striped
-lvconvert -y --ty striped $vg/$lv1
-check lv_field $vg/$lv1 segtype "striped"
-check lv_field $vg/$lv1 stripes 3
-fsck -fn  /dev/mapper/$vg-$lv1
+# Convert raid5_n -> striped
+_lvconvert striped striped 3 $vg $lv1 1
 
 # Convert striped -> raid5_n
-lvconvert -y --ty raid5_n $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid5_n"
-check lv_field $vg/$lv1 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid5_n raid5_n 4 $vg $lv1
 
 # Convert raid5_n -> raid4
-lvconvert -y --ty raid4 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid4"
-check lv_field $vg/$lv1 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
-
-
-# Convert raid0 -> raid4
-lvconvert -y --ty raid4 $vg/$lv2
-check lv_field $vg/$lv2 segtype "raid4"
-check lv_field $vg/$lv2 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv2
-aux wait_for_sync $vg $lv2
-fsck -fn  /dev/mapper/$vg-$lv2
+_lvconvert raid4 raid4 4 $vg $lv1 1
 
 # Convert raid4 -> raid0
-lvconvert -y --ty raid0 $vg/$lv2
-check lv_field $vg/$lv2 segtype "raid0"
-check lv_field $vg/$lv2 stripes 3
-fsck -fn  /dev/mapper/$vg-$lv2
+_lvconvert raid0 raid0 3 $vg $lv1 1
 
 # Convert raid0 -> raid5_n
-lvconvert -y --ty raid5_n $vg/$lv2
-check lv_field $vg/$lv2 segtype "raid5_n"
-check lv_field $vg/$lv2 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv2
-aux wait_for_sync $vg $lv2
-fsck -fn  /dev/mapper/$vg-$lv2
+_lvconvert raid5_n raid5_n 4 $vg $lv1
 
 # Convert raid5_n -> raid0_meta
-lvconvert -y --ty raid0_meta $vg/$lv2
-check lv_field $vg/$lv2 segtype "raid0_meta"
-check lv_field $vg/$lv2 stripes 3
-fsck -fn  /dev/mapper/$vg-$lv2
+_lvconvert raid0_meta raid0_meta 3 $vg $lv1 1
 
 # Convert raid0_meta -> raid5_n
-lvconvert -y --ty raid5_n $vg/$lv2
-check lv_field $vg/$lv2 segtype "raid5_n"
-check lv_field $vg/$lv2 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv2
-aux wait_for_sync $vg $lv2
-fsck -fn  /dev/mapper/$vg-$lv2
-
+_lvconvert raid5 raid5_n 4 $vg $lv1
 
 # Convert raid4 -> raid0_meta
-lvconvert -y --ty raid0_meta $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid0_meta"
-check lv_field $vg/$lv1 stripes 3
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid0_meta raid0_meta 3 $vg $lv1 1
 
 # Convert raid0_meta -> raid4
-lvconvert -y --ty raid4 $vg/$lv1
-fsck -fn  /dev/mapper/$vg-$lv1
-check lv_field $vg/$lv1 segtype "raid4"
-check lv_field $vg/$lv1 stripes 4
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid4 raid4 4 $vg $lv1
 
 # Convert raid4 -> raid0
-lvconvert -y --ty raid0 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid0"
-check lv_field $vg/$lv1 stripes 3
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid0 raid0 3 $vg $lv1 1
 
 # Convert raid0 -> raid4
-lvconvert -y --ty raid4 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid4"
-check lv_field $vg/$lv1 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid4 raid4 4 $vg $lv1
 
 # Convert raid4 -> striped
-lvconvert -y --ty striped $vg/$lv1
-check lv_field $vg/$lv1 segtype "striped"
-check lv_field $vg/$lv1 stripes 3
-fsck -fn  /dev/mapper/$vg-$lv1
-
-
-
+_lvconvert striped striped 3 $vg $lv1 1
 
 # Convert striped -> raid6_n_6
-lvconvert -y --ty raid6_n_6 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid6_n_6"
-check lv_field $vg/$lv1 stripes 5
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid6_n_6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> striped
-lvconvert -y --ty striped $vg/$lv1
-check lv_field $vg/$lv1 segtype "striped"
-check lv_field $vg/$lv1 stripes 3
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert striped striped 3 $vg $lv1 1
 
 # Convert striped -> raid6_n_6
-lvconvert -y --ty raid6_n_6 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid6_n_6"
-check lv_field $vg/$lv1 stripes 5
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid5_n
-lvconvert -y --ty raid5_n $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid5_n"
-check lv_field $vg/$lv1 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid5_n raid5_n 4 $vg $lv1 1
 
 # Convert raid5_n -> raid6_n_6
-lvconvert -y --ty raid6_n_6 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid6_n_6"
-check lv_field $vg/$lv1 stripes 5
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid6_n_6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid4
-lvconvert -y --ty raid4 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid4"
-check lv_field $vg/$lv1 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid4 raid4 4 $vg $lv1 1
 
 # Convert raid4 -> raid6_n_6
-lvconvert -y --ty raid6_n_6 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid6_n_6"
-check lv_field $vg/$lv1 stripes 5
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid0
-lvconvert -y --ty raid0 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid0"
-check lv_field $vg/$lv1 stripes 3
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid0 raid0 3 $vg $lv1 1
 
 # Convert raid0 -> raid6_n_6
-lvconvert -y --ty raid6_n_6 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid6_n_6"
-check lv_field $vg/$lv1 stripes 5
-fsck -fn  /dev/mapper/$vg-$lv1
-aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid6_n_6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid0_meta
-lvconvert -y --ty raid0_meta $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid0_meta"
-check lv_field $vg/$lv1 stripes 3
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid0_meta raid0_meta 3 $vg $lv1 1
 
 # Convert raid0_meta -> raid6_n_6
-lvconvert -y --ty raid6_n_6 $vg/$lv1
-check lv_field $vg/$lv1 segtype "raid6_n_6"
-check lv_field $vg/$lv1 stripes 5
-fsck -fn  /dev/mapper/$vg-$lv1
+_lvconvert raid6 raid6_n_6 5 $vg $lv1
+
+# Clean up
+lvremove -y $vg
+
+# Create + convert 4-way raid5 variations
+_lvcreate raid5 4 5 64M $vg $lv1
 aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+_invalid_raid5_conversions $vg $lv1
+not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
+not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
+not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
+_lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
+_lvconvert raid5_ls raid5_ls 5 $vg $lv1 1
+lvremove -y $vg
+
+_lvcreate raid5_ls 4 5 64M $vg $lv1
+aux wait_for_sync $vg $lv1
+_invalid_raid5_conversions $vg $lv1
+not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
+not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
+not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
+_lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
+_lvconvert raid5_ls raid5_ls 5 $vg $lv1 1
+lvremove -y $vg
+
+_lvcreate raid5_rs 4 5 64M $vg $lv1
+aux wait_for_sync $vg $lv1
+_invalid_raid5_conversions $vg $lv1
+not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
+not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
+not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
+_lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
+_lvconvert raid5_rs raid5_rs 5 $vg $lv1 1
+lvremove -y $vg
+
+_lvcreate raid5_la 4 5 64M $vg $lv1
+aux wait_for_sync $vg $lv1
+_invalid_raid5_conversions $vg $lv1
+not _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
+not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
+not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
+_lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
+_lvconvert raid5_la raid5_la 5 $vg $lv1 1
+lvremove -y $vg
+
+_lvcreate raid5_ra 4 5 64M $vg $lv1
+aux wait_for_sync $vg $lv1
+_invalid_raid5_conversions $vg $lv1
+not _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
+not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
+not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
+_lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
+_lvconvert raid5_ra raid5_ra 5 $vg $lv1 1
+lvremove -y $vg
 
 else
 



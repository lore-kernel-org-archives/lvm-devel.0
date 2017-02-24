From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:28 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063228.39EEA60AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34caf8317243b3b30e6fc858b4440ebf3ffb8810
Commit:        34caf8317243b3b30e6fc858b4440ebf3ffb8810
Parent:        f79bd30a8be0d189c417a76d1ca6b64f70a8832e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 04:36:03 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces the changes to call the reshaping infratructure
from lv_raid_convert().

Changes:
- add reshaping calls from lv_raid_convert()
- add command definitons for reshaping to tools/command-lines.in
- fix raid_rimage_extents()
- add 2 new test scripts lvconvert-raid-reshape-linear_to_striped.sh
  and lvconvert-raid-reshape-striped_to_linear.sh to test
  the linear <-> striped multi-step conversions
- add lvconvert-raid-reshape.sh reshaping tests
- enhance lvconvert-raid-takeover.sh with new raid10 tests

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/config/defaults.h                 |    2 +-
 lib/metadata/raid_manip.c             |   50 +++++++++++++++++++++------------
 test/lib/aux.sh                       |    2 +-
 test/lib/check.sh                     |   13 +++++++-
 test/lib/get.sh                       |    5 +++
 test/shell/lvconvert-raid-takeover.sh |   11 +++++--
 tools/command-lines.in                |   29 +++++++++++++++++++
 7 files changed, 87 insertions(+), 25 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 26bbc69..db78f0c 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -72,7 +72,7 @@
  *	  once the SubLVs split and name shift got enhanced
  */
 #define DEFAULT_RAID1_MAX_IMAGES 10
-#define DEFAULT_RAID_MAX_IMAGES 64
+#define DEFAULT_RAID_MAX_IMAGES 10
 #define DEFAULT_ALLOCATION_STRIPE_ALL_DEVICES 0 /* Don't stripe across all devices if not -i/--stripes given */
 
 #define DEFAULT_RAID_FAULT_POLICY "warn"
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c465bd4..e21e6cc 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1135,7 +1135,7 @@ uint32_t raid_rimage_extents(const struct segment_type *segtype,
 	uint64_t r;
 
 	if (!extents ||
-	    segtype_is_striped_raid(segtype))
+	    !segtype_is_striped_raid(segtype))
 		return extents;
 
 	r = extents;
@@ -2111,7 +2111,6 @@ static int _post_raid_dummy(struct logical_volume *lv, void *data)
  * In case of disk addition, any PVs listed in mandatory
  * @allocate_pvs will be used for allocation of new stripes.
  */
-__attribute__ ((__unused__))
 static int _raid_reshape(struct logical_volume *lv,
 			 const struct segment_type *new_segtype,
 			 int yes, int force,
@@ -2289,7 +2288,6 @@ static int _raid_reshape(struct logical_volume *lv,
  * 2 -> prohibited reshape request
  * 3 -> allowed region size change request
  */
-__attribute__ ((__unused__))
 static int _reshape_requested(const struct logical_volume *lv, const struct segment_type *segtype,
 			      const int data_copies, const uint32_t region_size,
 			      const uint32_t stripes, const uint32_t stripe_size)
@@ -5842,8 +5840,10 @@ int lv_raid_convert(struct logical_volume *lv,
 	uint32_t stripes, stripe_size;
 	uint32_t new_image_count = seg->area_count;
 	uint32_t region_size = new_region_size;
+	uint32_t data_copies = seg->data_copies;
 	takeover_fn_t takeover_fn;
 
+	new_segtype = new_segtype ? : seg->segtype;
 	if (!new_segtype) {
 		log_error(INTERNAL_ERROR "New segtype not specified.");
 		return 0;
@@ -5853,33 +5853,47 @@ int lv_raid_convert(struct logical_volume *lv,
 
 	/* FIXME Ensure caller does *not* set wrong default value! */
 	/* Define new stripe size if not passed in */
-	stripe_size = new_stripe_size ? : seg->stripe_size;
+	stripe_size = new_stripe_size_supplied ? new_stripe_size : seg->stripe_size;
 
 	if (segtype_is_striped(new_segtype))
-		new_image_count = stripes;
+		new_image_count = stripes ? : seg->area_count;
 
-	if (segtype_is_raid(new_segtype) && !_check_max_raid_devices(new_image_count))
+	if (!_check_max_raid_devices(new_image_count))
 		return_0;
 
-	/* Change RAID region size */
+	region_size = new_region_size ? : seg->region_size;
+	region_size = region_size ? : get_default_region_size(lv->vg->cmd);
+
 	/*
-	 * FIXME: workaround with new_region_size until the
-	 *	  cli validation patches got merged when we'll change
-	 *	  the API to have new_region_size_supplied to check for.
+	 * reshape of capable raid type requested
 	 */
-	if (new_region_size) {
-	       if (new_segtype == seg->segtype &&
-	           new_region_size != seg->region_size &&
-		   seg_is_raid(seg) && !seg_is_any_raid0(seg))
-			return _region_size_change_requested(lv, yes, new_region_size);
-	} else
-		region_size = seg->region_size ? : get_default_region_size(lv->vg->cmd);
+	switch (_reshape_requested(lv, new_segtype, data_copies, region_size, stripes, stripe_size)) {
+	case 0:
+		break;
+	case 1:
+		if (!_raid_reshape(lv, new_segtype, yes, force,
+				   data_copies, region_size,
+				   stripes, stripe_size, allocate_pvs)) {
+			log_error("Reshape request failed on LV %s.", display_lvname(lv));
+			return 0;
+		}
+
+		return 1;
+	case 2:
+		log_error("Invalid conversion request on %s.", display_lvname(lv));
+		/* Error if we got here with stripes and/or stripe size change requested */
+		return 0;
+	default:
+		log_error(INTERNAL_ERROR "_reshape_requested failed.");
+		return 0;
+	}
 
 	/*
 	 * Check acceptible options mirrors, region_size,
 	 * stripes and/or stripe_size have been provided.
 	 */
-	if (!_conversion_options_allowed(seg, &new_segtype, yes, 0 /* Takeover */, 0 /*new_data_copies*/, new_region_size,
+	if (!_conversion_options_allowed(seg, &new_segtype, yes,
+					 0 /* Takeover */, 0 /*new_data_copies*/, new_region_size,
 					 new_stripes, new_stripe_size_supplied))
 		return _log_possible_conversion_types(lv, new_segtype);
 	
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9779358..b0e6556 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1317,7 +1317,7 @@ udev_wait() {
 wait_for_sync() {
 	local i
 	for i in {1..100} ; do
-		check in_sync $1 $2 && return
+		check in_sync $1 $2 $3 && return
 		sleep .2
 	done
 
diff --git a/test/lib/check.sh b/test/lib/check.sh
index 916d2df..64812fb 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -178,7 +178,7 @@ linear() {
 			$(lvl $lv -o+devices)
 }
 
-# in_sync <VG> <LV>
+# in_sync <VG> <LV> <ignore 'a'>
 # Works for "mirror" and "raid*"
 in_sync() {
 	local a
@@ -187,8 +187,11 @@ in_sync() {
 	local type
 	local snap=""
 	local lvm_name="$1/$2"
+	local ignore_a="$3"
 	local dm_name=$(echo $lvm_name | sed s:-:--: | sed s:/:-:)
 
+	[ -z "$ignore_a" ] && ignore_a=0
+
 	a=( $(dmsetup status $dm_name) )  || \
 		die "Unable to get sync status of $1"
 
@@ -225,7 +228,7 @@ in_sync() {
 		return 1
 	fi
 
-	[[ ${a[$(($idx - 1))]} =~ a ]] && \
+	[[ ${a[$(($idx - 1))]} =~ a ]] && [ $ignore_a -eq 0 ] && \
 		die "$lvm_name ($type$snap) in-sync, but 'a' characters in health status"
 
 	echo "$lvm_name ($type$snap) is in-sync \"${a[@]}\""
@@ -310,6 +313,12 @@ lv_field() {
 		die "lv_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
+lv_first_seg_field() {
+	local actual=$(get lv_first_seg_field "$1" "$2" "${@:4}")
+	test "$actual" = "$3" || \
+		die "lv_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
+}
+
 lvh_field() {
 	local actual=$(get lvh_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
diff --git a/test/lib/get.sh b/test/lib/get.sh
index f650417..0a8c943 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -42,6 +42,11 @@ lv_field() {
 	trim_ "$r"
 }
 
+lv_first_seg_field() {
+	local r=$(lvs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1" | head -1)
+	trim_ "$r"
+}
+
 lvh_field() {
 	local r=$(lvs -H --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
 	trim_ "$r"
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index aa41dba..5d8f858 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -117,8 +117,7 @@ fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 lvconvert -m 4 -R 128K $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 5
-# FIXME: once lv_raid_chanage_image_count() supports region_size changes
-not check lv_field $vg/$lv1 regionsize "128.00k"
+check lv_field $vg/$lv1 regionsize "128.00k"
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
@@ -258,7 +257,13 @@ _lvconvert raid0 raid0 3 $vg $lv1
 # Convert raid0 -> raid10
 _lvconvert raid10 raid10 6 $vg $lv1
 
-# Convert raid10 -> raid0
+# Convert raid10 -> raid0_meta
+_lvconvert raid0_meta raid0_meta 3 $vg $lv1
+
+# Convert raid0_meta -> raid5
+_lvconvert raid5_n raid5_n 4 $vg $lv1
+
+# Convert raid5_n -> raid0_meta
 _lvconvert raid0_meta raid0_meta 3 $vg $lv1
 
 # Convert raid0_meta -> raid10
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 348e7a4..c3d684e 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -345,6 +345,13 @@ ID: lvconvert_raid_types
 DESC: Convert LV to raid.
 RULE: all not lv_is_locked lv_is_pvmove
 
+lvconvert --type raid LV_raid
+OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+ID: lvconvert_raid_types
+DESC: Convert raid LV to different layout algorithm.
+RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not LV_raid0 LV_raid1
+
 lvconvert --mirrors SNumber LV
 OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog
 OP: PV ...
@@ -352,6 +359,21 @@ ID: lvconvert_raid_types
 DESC: Convert LV to raid1 or mirror, or change number of mirror images.
 RULE: all not lv_is_locked lv_is_pvmove
 
+lvconvert --stripes_long SNumber LV_raid
+OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_raid_types
+DESC: Convert raid LV to change number of stripe images.
+RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not LV_raid0 LV_raid1
+
+lvconvert --stripesize SizeKB LV_raid
+OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+ID: lvconvert_raid_types
+DESC: Convert raid LV to change the stripe size.
+RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not LV_raid0 LV_raid1
+
 lvconvert --regionsize RegionSize LV_raid
 OO: OO_LVCONVERT
 ID: lvconvert_change_region_size
@@ -359,6 +381,13 @@ DESC: Change the region size of an LV.
 RULE: all not lv_is_locked lv_is_pvmove
 RULE: all not LV_raid0
 
+lvconvert LV_mirror_raid
+OO: OO_LVCONVERT
+ID: lvconvert_raid_types
+DESC: Remove out-of-place reshape space
+RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not LV_raid0 LV_raid1
+
 ---
 
 # lvconvert raid-related utilities



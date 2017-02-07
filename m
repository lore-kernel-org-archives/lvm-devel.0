From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  7 Feb 2017 15:52:26 +0000 (UTC)
Subject: master - lvconvert: add support to change RAID region size (fixup)
Message-ID: <20170207155226.64B0E60C49@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46a772fbc4e121f8e9e65d3be022bbace79be1f2
Commit:        46a772fbc4e121f8e9e65d3be022bbace79be1f2
Parent:        91c4bd14d0a6d07366375e86e6cdff0da2e2bdc4
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Feb 7 16:52:04 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Feb 7 16:52:04 2017 +0100

lvconvert: add support to change RAID region size (fixup)

Commit cfb6ef654d3d1f1dd02569a1d5bd2fc252ae2494 introduced
support to change RAID region size.

Add:
- missing conditions to support any types to function with
  it in lv_raid_convert();  temporary workaround used until
  cli validation patches get merged
- tests requesting "-R " to lvconvert-raid-takeover.sh
  involving a cleanup of the script

Related: rhbz1392947
---
 lib/metadata/raid_manip.c             |   24 ++++++++--
 test/shell/lvconvert-raid-takeover.sh |   78 +++++++++++++++++++-------------
 tools/lvconvert.c                     |   12 ++++-
 3 files changed, 75 insertions(+), 39 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0c541fb..6efbc5c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3180,7 +3180,7 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 	} else
 		seg->segtype = new_segtype;
 
-	seg->region_size = region_size;
+	seg->region_size = new_region_size ?: region_size;
 
 	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, &removal_lvs))
 		return_0;
@@ -3430,6 +3430,8 @@ static int _takeover_from_mirrored_to_raid0_meta(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_mirrored_to_raid1(TAKEOVER_FN_ARGS)
 {
+	first_seg(lv)->region_size = new_region_size;
+
 	return _convert_mirror_to_raid1(lv, new_segtype);
 }
 
@@ -3610,7 +3612,8 @@ static int _takeover_from_raid45_to_raid1(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid45_to_raid54(TAKEOVER_FN_ARGS)
 {
-	return _raid45_to_raid54_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count, 2 /* data_copies */, 0, 0, 0, allocate_pvs);
+	return _raid45_to_raid54_wrapper(lv, new_segtype, yes, force, first_seg(lv)->area_count,
+					 2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_raid6(TAKEOVER_FN_ARGS)
@@ -4002,7 +4005,8 @@ int lv_raid_convert(struct logical_volume *lv,
 		    const unsigned new_stripes,
 		    const unsigned new_stripe_size_supplied,
 		    const unsigned new_stripe_size,
-		    const uint32_t new_region_size,
+		    /* FIXME: workaround with volatile new_region_size until cli validation patches got merged */
+		    uint32_t new_region_size,
 		    struct dm_list *allocate_pvs)
 {
 	struct lv_segment *seg = first_seg(lv);
@@ -4028,8 +4032,18 @@ int lv_raid_convert(struct logical_volume *lv,
 		return_0;
 
 	/* Change RAID region size */
-	if (new_region_size && new_region_size != seg->region_size)
-		return _region_size_change_requested(lv, yes, new_region_size);
+	/*
+	 * FIXME: workaround with volatile new_region_size until the
+	 *	  cli validation patches got merged when we'll change
+	 *	  the API to have new_region_size_supplied to check for.
+	 */
+	if (new_region_size) {
+	       if (new_segtype == seg->segtype &&
+	           new_region_size != seg->region_size &&
+		   seg_is_raid(seg) && !seg_is_any_raid0(seg))
+			return _region_size_change_requested(lv, yes, new_region_size);
+	} else
+		new_region_size = seg->region_size ? : get_default_region_size(lv->vg->cmd);
 
 	/*
 	 * Check acceptible options mirrors, region_size,
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 4565cc8..c7b569a 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -7,7 +7,7 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
@@ -44,13 +44,20 @@ function _lvconvert
 	local stripes=$3
 	local vg=$4
 	local lv=$5
-	local dont_wait=$6
+	local region_size=$6
+	local wait_and_check=1
+	local R=""
 
-	lvconvert -y --ty $req_level $vg/$lv
+	[ -n "$region_size" ] && R="-R $region_size"
+	[ "${level:0:7}" = "striped" ] && wait_and_check=0
+	[ "${level:0:5}" = "raid0" ] && wait_and_check=0
+
+
+	lvconvert -y --ty $req_level $R $vg/$lv
 	[ $? -ne 0 ] && return $?
 	check lv_field $vg/$lv segtype "$level"
 	check lv_field $vg/$lv stripes $stripes
-	if [ -z "$dont_wait" ]
+	if [ "$wait_and_check" -eq 1 ]
 	then
 		fsck -fn  /dev/mapper/$vg-$lv
 		aux wait_for_sync $vg $lv
@@ -60,8 +67,8 @@ function _lvconvert
 
 function _invalid_raid5_conversions
 {
-	local lv=$1
-	local vg=$2
+	local vg=$1
+	local lv=$2
 
 	not _lvconvert striped 4 $vg $lv1
 	not _lvconvert raid0 raid0 4 $vg $lv1
@@ -78,14 +85,15 @@ function _invalid_raid5_conversions
 	not _lvconvert raid6 raid6_n_6 6 $vg $lv1
 }
 
-# Delay 1st leg so that rebuilding status characters
+# Delayst leg so that rebuilding status characters
 #  can be read before resync finished too quick.
-# aux delay_dev "$dev1" 0 1
+# aux delay_dev "$dev1" 1
 
 # Create 3-way mirror
-lvcreate --yes -aey --type mirror -m 2 -L 64M -n $lv1 $vg
+lvcreate --yes -aey --type mirror -R 64K -m 2 -L 64M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "mirror"
 check lv_field $vg/$lv1 stripes 3
+check lv_field $vg/$lv1 regionsize "64.00k"
 echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
 aux wait_for_sync $vg $lv1
 fsck -fn  /dev/mapper/$vg-$lv1
@@ -99,15 +107,18 @@ aux wait_for_sync $vg $lv1
 fsck -fn  /dev/mapper/$vg-$lv1
 
 # Takeover 4-way mirror to raid1
-lvconvert --yes --type raid1 $vg/$lv1
+lvconvert --yes --type raid1 -R 64k $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 4
+check lv_field $vg/$lv1 regionsize "64.00k"
 fsck -fn  /dev/mapper/$vg-$lv1
 
 ## Convert 4-way raid1 to 5-way
-lvconvert -m 4 $vg/$lv1
+lvconvert -m 4 -R 128K $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 5
+# FIXME: once lv_raid_chanage_image_count() supports region_size changes
+not check lv_field $vg/$lv1 regionsize "128.00k"
 fsck -fn  /dev/mapper/$vg-$lv1
 aux wait_for_sync $vg $lv1
 fsck -fn  /dev/mapper/$vg-$lv1
@@ -128,9 +139,10 @@ check lv_field $vg/$lv1 stripes 2
 fsck -fn  /dev/mapper/$vg-$lv1
 
 # Convert 2-way raid1 to mirror
-lvconvert --yes --type mirror $vg/$lv1
+lvconvert --yes --type mirror -R 32K $vg/$lv1
 check lv_field $vg/$lv1 segtype "mirror"
 check lv_field $vg/$lv1 stripes 2
+check lv_field $vg/$lv1 regionsize "32.00k"
 aux wait_for_sync $vg $lv1
 fsck -fn  /dev/mapper/$vg-$lv1
 aux wait_for_sync $vg $lv1
@@ -151,79 +163,81 @@ _lvcreate raid4 3 4 64M $vg $lv1
 aux wait_for_sync $vg $lv1
 
 # Convert raid4 -> striped
-_lvconvert striped striped 3 $vg $lv1 1
+_lvconvert striped striped 3 $vg $lv1
 
 # Convert striped -> raid4
-_lvconvert raid4 raid4 4 $vg $lv1
+_lvconvert raid4 raid4 4 $vg $lv1 64k
+check lv_field $vg/$lv1 regionsize "64.00k"
 
 # Convert raid4 -> raid5_n
-_lvconvert raid5 raid5_n 4 $vg $lv1 1
+_lvconvert raid5 raid5_n 4 $vg $lv1 128k
+check lv_field $vg/$lv1 regionsize "128.00k"
 
 # Convert raid5_n -> striped
-_lvconvert striped striped 3 $vg $lv1 1
+_lvconvert striped striped 3 $vg $lv1
 
 # Convert striped -> raid5_n
 _lvconvert raid5_n raid5_n 4 $vg $lv1
 
 # Convert raid5_n -> raid4
-_lvconvert raid4 raid4 4 $vg $lv1 1
+_lvconvert raid4 raid4 4 $vg $lv1
 
 # Convert raid4 -> raid0
-_lvconvert raid0 raid0 3 $vg $lv1 1
+_lvconvert raid0 raid0 3 $vg $lv1
 
 # Convert raid0 -> raid5_n
 _lvconvert raid5_n raid5_n 4 $vg $lv1
 
 # Convert raid5_n -> raid0_meta
-_lvconvert raid0_meta raid0_meta 3 $vg $lv1 1
+_lvconvert raid0_meta raid0_meta 3 $vg $lv1
 
 # Convert raid0_meta -> raid5_n
 _lvconvert raid5 raid5_n 4 $vg $lv1
 
 # Convert raid4 -> raid0_meta
-_lvconvert raid0_meta raid0_meta 3 $vg $lv1 1
+_lvconvert raid0_meta raid0_meta 3 $vg $lv1
 
 # Convert raid0_meta -> raid4
 _lvconvert raid4 raid4 4 $vg $lv1
 
 # Convert raid4 -> raid0
-_lvconvert raid0 raid0 3 $vg $lv1 1
+_lvconvert raid0 raid0 3 $vg $lv1
 
 # Convert raid0 -> raid4
 _lvconvert raid4 raid4 4 $vg $lv1
 
 # Convert raid4 -> striped
-_lvconvert striped striped 3 $vg $lv1 1
+_lvconvert striped striped 3 $vg $lv1
 
 # Convert striped -> raid6_n_6
 _lvconvert raid6_n_6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> striped
-_lvconvert striped striped 3 $vg $lv1 1
+_lvconvert striped striped 3 $vg $lv1
 
 # Convert striped -> raid6_n_6
 _lvconvert raid6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid5_n
-_lvconvert raid5_n raid5_n 4 $vg $lv1 1
+_lvconvert raid5_n raid5_n 4 $vg $lv1
 
 # Convert raid5_n -> raid6_n_6
 _lvconvert raid6_n_6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid4
-_lvconvert raid4 raid4 4 $vg $lv1 1
+_lvconvert raid4 raid4 4 $vg $lv1
 
 # Convert raid4 -> raid6_n_6
 _lvconvert raid6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid0
-_lvconvert raid0 raid0 3 $vg $lv1 1
+_lvconvert raid0 raid0 3 $vg $lv1
 
 # Convert raid0 -> raid6_n_6
 _lvconvert raid6_n_6 raid6_n_6 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid0_meta
-_lvconvert raid0_meta raid0_meta 3 $vg $lv1 1
+_lvconvert raid0_meta raid0_meta 3 $vg $lv1
 
 # Convert raid0_meta -> raid6_n_6
 _lvconvert raid6 raid6_n_6 5 $vg $lv1
@@ -239,7 +253,7 @@ not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
 not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
 not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
 _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
-_lvconvert raid5_ls raid5_ls 5 $vg $lv1 1
+_lvconvert raid5_ls raid5_ls 5 $vg $lv1
 lvremove -y $vg
 
 _lvcreate raid5_ls 4 5 64M $vg $lv1
@@ -249,7 +263,7 @@ not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
 not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
 not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
 _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
-_lvconvert raid5_ls raid5_ls 5 $vg $lv1 1
+_lvconvert raid5_ls raid5_ls 5 $vg $lv1
 lvremove -y $vg
 
 _lvcreate raid5_rs 4 5 64M $vg $lv1
@@ -259,7 +273,7 @@ not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
 not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
 not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
 _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
-_lvconvert raid5_rs raid5_rs 5 $vg $lv1 1
+_lvconvert raid5_rs raid5_rs 5 $vg $lv1
 lvremove -y $vg
 
 _lvcreate raid5_la 4 5 64M $vg $lv1
@@ -269,7 +283,7 @@ not _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
 not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
 not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
 _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
-_lvconvert raid5_la raid5_la 5 $vg $lv1 1
+_lvconvert raid5_la raid5_la 5 $vg $lv1
 lvremove -y $vg
 
 _lvcreate raid5_ra 4 5 64M $vg $lv1
@@ -279,7 +293,7 @@ not _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
 not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
 not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
 _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
-_lvconvert raid5_ra raid5_ra 5 $vg $lv1 1
+_lvconvert raid5_ra raid5_ra 5 $vg $lv1
 lvremove -y $vg
 
 else
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 32e04d6..382f170 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2040,8 +2040,12 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		if (!arg_is_set(cmd, stripes_long_ARG))
 			lp->stripes = 0;
 
+		/*
+		 * FIXME: arg_is_set() workaround for region size until the cli validation patches got merged;
+		 *	 i needs "--type raid*", because lp->region_size isn't set w/o it
+		 */
 		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
-				     lp->region_size, lp->pvh))
+				     arg_is_set(cmd, regionsize_ARG) ? lp->region_size : 0, lp->pvh))
 			return_0;
 
 		log_print_unless_silent("Logical volume %s successfully converted.",
@@ -2108,8 +2112,12 @@ try_new_takeover_or_reshape:
 	if (lp->type_str && lp->type_str[0] && lp->segtype != seg->segtype &&
 	    ((seg_is_raid4(seg) && seg_is_striped(lp) && lp->stripes > 1) ||
 	     (seg_is_striped(seg) && seg->area_count > 1 && seg_is_raid4(lp)))) {
+		/*
+		 * FIXME: arg_is_set() workaround for region size until the cli validation patches got merged;
+		 *	 i needs "--type raid*", because lp->region_size isn't set w/o it
+		 */
 		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
-				     lp->region_size, lp->pvh))
+				     arg_is_set(cmd, regionsize_ARG) ? lp->region_size : 0, lp->pvh))
 			return_0;
 
 		log_print_unless_silent("Logical volume %s successfully converted.",



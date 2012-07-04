From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  4 Jul 2012 04:53:02 +0000 (UTC)
Subject: master - RAID: Fix extending size of RAID 4/5/6 logical volumes.
Message-ID: <20120704045302.ECBDF113F@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8767435ef847831455fadc1f7e8f4d2d94aef0d5
Commit:        8767435ef847831455fadc1f7e8f4d2d94aef0d5
Parent:        bf81d5607a47eb0bf3963be54f4b765b2d24b895
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jun 26 09:44:54 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jun 26 09:44:54 2012 -0500

RAID:  Fix extending size of RAID 4/5/6 logical volumes.

Reducing a RAID 4/5/6 LV or extending it with a different number of
stripes is still not implemented.  This patch covers the "simple" case
where the LV is extended with the same number of stripes as the orginal.
---
 WHATS_NEW                   |    1 +
 lib/metadata/lv_manip.c     |   14 +++++++-
 test/shell/lvresize-raid.sh |   78 +++++++++++++++++++++++++++++++++++++++++++
 tools/lvresize.c            |   10 ++++-
 4 files changed, 100 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2e649b1..02ac14a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Fix extending RAID 4/5/6 logical volumes
   Fix test for PV with unknown VG in process_each_pv to ignore ignored mdas.
   Update man pages with --activate ay option and auto_activation_volume_list.
   Fix _alloc_parallel_area to avoid picking already-full areas for raid devices.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 21508fd..0d89b4a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -697,6 +697,10 @@ static uint32_t _calc_area_multiple(const struct segment_type *segtype,
 	if (segtype_is_striped(segtype))
 		return area_count;
 
+	/* Parity RAID (e.g. RAID 4/5/6) */
+	if (segtype_is_raid(segtype) && segtype->parity_devs)
+		return area_count - segtype->parity_devs;
+
 	/* Mirrored stripes */
 	if (stripes)
 		return stripes;
@@ -829,7 +833,15 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	ah->parity_count = parity_count;
 	ah->region_size = region_size;
 	ah->alloc = alloc;
-	ah->area_multiple = _calc_area_multiple(segtype, area_count, stripes);
+
+	/*
+	 * For the purposes of allocation, area_count and parity_count are
+	 * kept separately.  However, the 'area_count' field in an
+	 * lv_segment includes both; and this is what '_calc_area_multiple'
+	 * is calculated from.  So, we must pass in the total count to get
+	 * a correct area_multiple.
+	 */
+	ah->area_multiple = _calc_area_multiple(segtype, area_count + parity_count, stripes);
 	ah->mirror_logs_separate = find_config_tree_bool(cmd, "allocation/mirror_logs_require_separate_pvs",
 							 DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS);
 
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
new file mode 100644
index 0000000..c6c5dd1
--- /dev/null
+++ b/test/shell/lvresize-raid.sh
@@ -0,0 +1,78 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 5 80
+
+# Extend a 2-way RAID1
+for deactivate in true false; do
+	lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+
+	if $deactivate; then
+		lvchange -an $vg/$lv1
+	fi
+
+	lvresize -l +2 $vg/$lv1
+
+	#check raid_images_contiguous $vg $lv1
+
+	lvremove -ff $vg
+done
+
+# Reduce 2-way RAID1
+for deactivate in true false; do
+	lvcreate --type raid1 -m 1 -l 4 -n $lv1 $vg
+
+	if $deactivate; then
+		lvchange -an $vg/$lv1
+	fi
+
+	should lvresize -l -2 $vg/$lv1
+
+	#check raid_images_contiguous $vg $lv1
+
+	lvremove -ff $vg
+done
+
+# Extend 3-striped RAID 4/5/6
+for i in 4 5 6 ; do
+	for deactivate in true false; do
+		lvcreate --type raid$i -i 3 -l 3 -n $lv1 $vg
+
+		if $deactivate; then
+			lvchange -an $vg/$lv1
+		fi
+
+		lvresize -l +3 $vg/$lv1
+
+		#check raid_images_contiguous $vg $lv1
+
+		lvremove -ff $vg
+	done
+done
+
+# Reduce 3-striped RAID 4/5/6
+for i in 4 5 6 ; do
+	for deactivate in true false; do
+		lvcreate --type raid$i -i 3 -l 6 -n $lv1 $vg
+
+		if $deactivate; then
+			lvchange -an $vg/$lv1
+		fi
+
+		should lvresize -l -3 $vg/$lv1
+
+		#check raid_images_contiguous $vg $lv1
+
+		lvremove -ff $vg
+	done
+done
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 55d1334..64474e0 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -598,11 +598,12 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		 *       and data LV could be any type (i.e. mirror)) */
 		dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments :
 				      lv_is_thin_pool(lv) ? &seg_lv(first_seg(lv), 0)->segments : &lv->segments) {
-			if (!seg_is_striped(seg))
+			if (!seg_is_striped(seg) &&
+			    (!seg_is_raid(seg) || seg_is_mirrored(seg)))
 				continue;
 
 			sz = seg->stripe_size;
-			str = seg->area_count;
+			str = seg->area_count - lp->segtype->parity_devs;
 
 			if ((seg_stripesize && seg_stripesize != sz &&
 			     sz && !lp->stripe_size) ||
@@ -618,6 +619,11 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 		if (!lp->stripes)
 			lp->stripes = seg_stripes;
+		else if (seg_is_raid(first_seg(lv)) &&
+			 (lp->stripes != seg_stripes)) {
+			log_error("Unable to extend \"%s\" segment type with different number of stripes.", first_seg(lv)->segtype->name);
+			return ECMD_FAILED;
+		}
 
 		if (!lp->stripe_size && lp->stripes > 1) {
 			if (seg_stripesize) {



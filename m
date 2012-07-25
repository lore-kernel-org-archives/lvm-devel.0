From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 25 Jul 2012 03:26:27 +0000 (UTC)
Subject: master - RAID: Fix segfault when attempting to replace RAID 4/5/6 device
Message-ID: <20120725032627.5CF3613DB@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5555d2a000ed4e3d5a694896f3dc6a7290543f43
Commit:        5555d2a000ed4e3d5a694896f3dc6a7290543f43
Parent:        407198e17dc805dd9ce0583c8b1dbade71572af6
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jul 24 19:02:06 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jul 24 19:02:06 2012 -0500

RAID: Fix segfault when attempting to replace RAID 4/5/6 device

Commit 8767435ef847831455fadc1f7e8f4d2d94aef0d5 allowed RAID 4/5/6
LV to be extended properly, but introduced a regression in device
replacement - a critical component of fault tolerance.

When only 1 or 2 drives are being replaced, the 'area_count' needed
can be equal to the parity_count.  The 'area_multiple' for RAID 4/5/6
was computed as 'area_count - parity_devs', which could result in
'area_multiple' being 0.  This would ultimately lead to a division by
zero error.  Therefore, in calc_area_multiple, it is important to take
into account the number of areas that are being requested - just as
we already do in _alloc_init.
---
 lib/metadata/lv_manip.c        |   11 ++++++++++-
 test/shell/lvconvert-repair.sh |   26 +++++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0d89b4a..daa90da 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -698,8 +698,17 @@ static uint32_t _calc_area_multiple(const struct segment_type *segtype,
 		return area_count;
 
 	/* Parity RAID (e.g. RAID 4/5/6) */
-	if (segtype_is_raid(segtype) && segtype->parity_devs)
+	if (segtype_is_raid(segtype) && segtype->parity_devs) {
+		/*
+		 * As articulated in _alloc_init, we can tell by
+		 * the area_count whether a replacement drive is
+		 * being allocated; and if this is the case, then
+		 * there is no area_multiple that should be used.
+		 */
+		if (area_count <= segtype->parity_devs)
+			return 1;
 		return area_count - segtype->parity_devs;
+	}
 
 	/* Mirrored stripes */
 	if (stripes)
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 947998c..0aeeffa 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -23,7 +23,7 @@ aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 # fail multiple devices
 
 # 4-way, disk log => 2-way, disk log
-aux prepare_vg 5
+aux prepare_vg 8
 lvcreate -m 3 --ig -L 1 -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 aux disable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
@@ -111,4 +111,28 @@ lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 aux enable_dev "$dev3"
 vgextend $vg "$dev3"
+lvremove -ff $vg
+
+# RAID5 single replace
+lvcreate --type raid5 -i 2 -l 2 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+aux wait_for_sync $vg $lv1
+aux disable_dev "$dev3"
+lvconvert -y --repair $vg/$lv1
+vgreduce --removemissing $vg
+aux enable_dev "$dev3"
+vgextend $vg "$dev3"
+lvremove -ff $vg
+
+# RAID6 double replace
+lvcreate --type raid5 -i 3 -l 2 -n $lv1 $vg \
+    "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+aux wait_for_sync $vg $lv1
+aux disable_dev "$dev4" "$dev5"
+lvconvert -y --repair $vg/$lv1
+vgreduce --removemissing $vg
+aux enable_dev "$dev4"
+aux enable_dev "$dev5"
+vgextend $vg "$dev4" "$dev5"
+lvremove -ff $vg
+
 vgremove -ff $vg



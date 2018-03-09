From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 9 Mar 2018 15:18:28 -0500
Subject: master - raid: support raid5_n convenience type on conversion to raid10
Message-ID: <201803092018.w29KISao000960@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=321b761d3641e38bec125af789e11466aa9407ae
Commit:        321b761d3641e38bec125af789e11466aa9407ae
Parent:        6cb2c35d1654558efc1b37ca44d77f83682446c7
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 9 21:15:41 2018 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 9 21:15:54 2018 +0100

raid: support raid5_n convenience type on conversion to raid10

Fix requesting a conversion on raid5_{ls,rs,la,ra} -> raid10
not offering offering interim convenience type raid5_n.
---
 lib/metadata/raid_manip.c               |    2 +-
 test/shell/lvconvert-raid5_to_raid10.sh |   63 +++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0f56120..7d82a24 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6119,7 +6119,7 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 				return 0;
 			}
 
-			seg_flag = SEG_RAID0_META;
+			seg_flag = seg_is_raid5_n(seg_from) ? SEG_RAID0_META : SEG_RAID5_N;
 
 		} else if (segtype_is_any_raid6(*segtype)) {
 			if (seg_from->area_count < 4) {
diff --git a/test/shell/lvconvert-raid5_to_raid10.sh b/test/shell/lvconvert-raid5_to_raid10.sh
new file mode 100644
index 0000000..cc0e468
--- /dev/null
+++ b/test/shell/lvconvert-raid5_to_raid10.sh
@@ -0,0 +1,63 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+which mkfs.ext4 || skip
+aux have_raid 1 13 2 || skip
+
+aux prepare_vg 6
+
+#
+# Test multi step raid5 -> raid10 conversion
+#
+
+# Create raid5(_ls) LV
+lvcreate -y --type raid5 -i 3 -L 16M -R 256K -n $lv1 $vg
+check lv_field $vg/$lv1 segtype "raid5"
+check lv_field $vg/$lv1 stripes 4
+check lv_field $vg/$lv1 data_stripes 3
+check lv_field $vg/$lv1 region_size "256.00k"
+echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+aux wait_for_sync $vg $lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+# Convert raid5 -> raid10 (first step raid5 -> raid5_n)
+lvconvert -y --ty raid10 $vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+check lv_field $vg/$lv1 segtype "raid5_n"
+check lv_field $vg/$lv1 stripes 4
+check lv_field $vg/$lv1 data_stripes 3
+check lv_field $vg/$lv1 region_size "256.00k"
+aux wait_for_sync $vg $lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+# Convert raid5 -> raid10 (second step raid5_n -> raid0_meta)
+lvconvert -y --ty raid10 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid0_meta"
+check lv_field $vg/$lv1 stripes 3
+check lv_field $vg/$lv1 data_stripes 3
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+
+# Convert raid5 -> raid10 (third + last step raid0_meta -> raid10)
+lvconvert -y --ty raid10 -R 256K $vg/$lv1
+fsck -fn $DM_DEV_DIR/$vg/$lv1
+check lv_field $vg/$lv1 segtype "raid10"
+check lv_field $vg/$lv1 stripes 6
+check lv_field $vg/$lv1 data_stripes 3
+check lv_field $vg/$lv1 region_size "256.00k"
+
+vgremove -ff $vg



From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 25 Jun 2014 16:19:26 +0000 (UTC)
Subject: master - test: Test addition to show incorrect allocator behavior
Message-ID: <20140625161926.DFA6A6111F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f1675b059d65768524398791b2e505b7dfe2497
Commit:        1f1675b059d65768524398791b2e505b7dfe2497
Parent:        e80884cd080cad7e10be4588e3493b9000649426
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Sat Jun 21 15:33:52 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Sat Jun 21 15:33:52 2014 -0500

test:  Test addition to show incorrect allocator behavior

If a RAID LV has images that are spread across more than one PV
and you allocate a new image that requires more than one PV,
parallel_areas is only honored for one segment.  This commit
adds a test for this condition.
---
 test/shell/lvconvert-raid.sh |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 6f17303..8bd56ec 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -202,4 +202,26 @@ for i in {1..3}; do
 	lvremove -ff $vg
 done
 
+# Setup 2-way RAID1 LV to spread across 4 devices.
+# For each image:
+#  - metadata LV + 1 image extent (2 total extents) on one PV
+#  - 2 image extents on the other PV
+# Then attempt allocation of another image from 2 extents on
+# a 5th PV and the remainder of the rest of already used PVs.
+#
+# This should fail because there is insufficient space on the
+# non-parallel PV (i.e. there is not enough space for the image
+# if it doesn't share a PV with another image).
+lvcreate --type raid1 -m 1 -l 3 -n $lv1 $vg \
+    "$dev1:0-1" "$dev2:0-1" "$dev3:0-1" "$dev4:0-1"
+aux wait_for_sync $vg $lv1
+# Should not be enough non-overlapping space.
+not lvconvert -m +1 $vg/$lv1 \
+    "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
+# Should work due to '--alloc anywhere'
+lvconvert -m +1 --alloc anywhere $vg/$lv1 \
+    "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
+lvremove -ff $vg
+
+
 vgremove -ff $vg



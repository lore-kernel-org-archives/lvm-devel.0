From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  9 Oct 2012 10:22:58 +0000 (UTC)
Subject: master - test: split raid tests
Message-ID: <20121009102258.57F94AABF6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93d7d3ed2c16317812e553a25babf5225471e8d4
Commit:        93d7d3ed2c16317812e553a25babf5225471e8d4
Parent:        cdb7502e54aeb464216af271289deec12f15442e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 9 12:17:33 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 9 12:22:26 2012 +0200

test: split raid tests

Separate original raid test and new raid10 test,
so the old could be tested on platforms without raid10 support.

Replace test-unfriendly `ls /dev/mapper`   with  dmsetup ls
---
 test/shell/lvconvert-raid.sh   |   35 +-----------------------
 test/shell/lvconvert-raid10.sh |   56 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 33 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 9c3cff6..7f4dd4b 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -13,11 +13,9 @@
 
 get_image_pvs() {
 	local d
-	local images=""
+	local images
 
-	for d in `ls /dev/mapper/${1}-${2}_?image_*`; do
-		images="$images `basename $d | sed s:-:/:`"
-	done
+	images=`dmsetup ls | grep ${1}-${2}_.image_.* | cut -f1 | sed -e s:-:/:`
 	lvs --noheadings -a -o devices $images | sed s/\(.\)//
 }
 
@@ -222,32 +220,3 @@ for i in 4 5 6; do
 
 	lvremove -ff $vg
 done
-
-# RAID10: Can replace 'copies - 1' devices from each stripe
-# Tests are run on 2-way mirror, 3-way stripe RAID10
-aux target_at_least dm-raid 1 3 1 || skip
-
-lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv1 $vg
-aux wait_for_sync $vg $lv1
-
-# Can replace any single device
-for i in $(get_image_pvs $vg $lv1); do
-	lvconvert --replace $i $vg/$lv1
-	aux wait_for_sync $vg $lv1
-done
-
-# Can't replace adjacent devices
-devices=( $(get_image_pvs $vg $lv1) )
-not lvconvert --replace ${devices[0]} --replace ${devices[1]} $vg/$lv1
-not lvconvert --replace ${devices[2]} --replace ${devices[3]} $vg/$lv1
-not lvconvert --replace ${devices[4]} --replace ${devices[5]} $vg/$lv1
-
-# Can replace non-adjacent devices
-for i in 0 1; do
-	lvconvert \
-		--replace ${devices[$i]} \
-		--replace ${devices[$(($i + 2))]} \
-		--replace ${devices[$(($i + 4))]} \
-		 $vg/$lv1
-	aux wait_for_sync $vg $lv1
-done
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
new file mode 100644
index 0000000..2e4381d
--- /dev/null
+++ b/test/shell/lvconvert-raid10.sh
@@ -0,0 +1,56 @@
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
+get_image_pvs() {
+	local d
+	local images
+
+	images=`dmsetup ls | grep ${1}-${2}_.image_.* | cut -f1 | sed -e s:-:/:`
+	lvs --noheadings -a -o devices $images | sed s/\(.\)//
+}
+
+########################################################
+# MAIN
+########################################################
+# RAID10: Can replace 'copies - 1' devices from each stripe
+# Tests are run on 2-way mirror, 3-way stripe RAID10
+aux target_at_least dm-raid 1 3 1 || skip
+
+# 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
+aux prepare_pvs 9 80
+vgcreate -c n -s 256k $vg $(cat DEVICES)
+
+lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv1 $vg
+aux wait_for_sync $vg $lv1
+
+# Can replace any single device
+for i in $(get_image_pvs $vg $lv1); do
+	lvconvert --replace $i $vg/$lv1
+	aux wait_for_sync $vg $lv1
+done
+
+# Can't replace adjacent devices
+devices=( $(get_image_pvs $vg $lv1) )
+not lvconvert --replace ${devices[0]} --replace ${devices[1]} $vg/$lv1
+not lvconvert --replace ${devices[2]} --replace ${devices[3]} $vg/$lv1
+not lvconvert --replace ${devices[4]} --replace ${devices[5]} $vg/$lv1
+
+# Can replace non-adjacent devices
+for i in 0 1; do
+	lvconvert \
+		--replace ${devices[$i]} \
+		--replace ${devices[$(($i + 2))]} \
+		--replace ${devices[$(($i + 4))]} \
+		 $vg/$lv1
+	aux wait_for_sync $vg $lv1
+done



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Mar 2014 20:56:00 +0000 (UTC)
Subject: master - tests: split raid test
Message-ID: <20140302205600.D7343611B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=33d69162e4b45e7926d4c0e4a425fedb4246088e
Commit:        33d69162e4b45e7926d4c0e4a425fedb4246088e
Parent:        3ff10f5e61df721ea06dc23575932df2d0215c50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 2 19:46:17 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 2 21:27:26 2014 +0100

tests: split raid test

Use separate test file for raid456
Change test for broken kernel which has broken raid456 support.
---
 test/lib/aux.sh                 |    7 ++--
 test/shell/lvconvert-raid.sh    |   40 +-----------------------
 test/shell/lvconvert-raid456.sh |   66 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 71 insertions(+), 42 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index eae01ee..67e046d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -637,7 +637,7 @@ skip_if_mirror_recovery_broken() {
         if test `uname -r` = 3.3.4-5.fc17.x86_64; then skip; fi
 }
 
-skip_if_raid456_replace_broken() {
+raid456_replace_works() {
 # The way kmem_cache aliasing is done in the kernel is broken.
 # It causes RAID 4/5/6 tests to fail.
 #
@@ -666,8 +666,9 @@ skip_if_raid456_replace_broken() {
 # old instance to be preserved and causes a colision (and thus failure) in
 # kmem_cache_create().  I see this regularly in testing the following
 # kernels:
-        if test `uname -r` = 3.10.11-200.fc19.i686; then skip; fi
-        if test `uname -r` = 3.10.11-200.fc19.x86_64; then skip; fi
+	case $(uname -r) in
+	  3.10.11-200.fc19.i686|3.10.11-200.fc19.x86_64) return 1 ;;
+	esac
 }
 
 udev_wait() {
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index a2a7792..2c6a41a 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -24,8 +24,7 @@ get_image_pvs() {
 ########################################################
 aux target_at_least dm-raid 1 2 0 || skip
 
-# 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
-aux prepare_pvs 9 80
+aux prepare_pvs 5
 vgcreate -s 256k $vg $(cat DEVICES)
 
 ###########################################
@@ -203,41 +202,4 @@ for i in {1..3}; do
 	lvremove -ff $vg
 done
 
-aux skip_if_raid456_replace_broken
-
-# RAID 4/5/6 (can replace up to 'parity' devices)
-for i in 4 5 6; do
-	lvcreate --type raid$i -i 3 -l 3 -n $lv1 $vg
-
-	if [ $i -eq 6 ]; then
-		dev_cnt=5
-		limit=2
-	else
-		dev_cnt=4
-		limit=1
-	fi
-
-	for j in {1..3}; do
-	for o in $(seq 0 $i); do
-		replace=""
-
-		devices=( $(get_image_pvs $vg $lv1) )
-
-		for k in $(seq $j); do
-			index=$((($k + $o) % $dev_cnt))
-			replace="$replace --replace ${devices[$index]}"
-		done
-		aux wait_for_sync $vg $lv1
-
-		if [ $j -gt $limit ]; then
-			not lvconvert $replace $vg/$lv1
-		else
-			lvconvert $replace $vg/$lv1
-		fi
-	done
-	done
-
-	lvremove -ff $vg
-done
-
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
new file mode 100644
index 0000000..bf9a823
--- /dev/null
+++ b/test/shell/lvconvert-raid456.sh
@@ -0,0 +1,66 @@
+#!/bin/sh
+# Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
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
+aux raid456_replace_works || skip
+aux target_at_least dm-raid 1 2 0 || skip
+
+aux prepare_pvs 6
+vgcreate -s 256k $vg $(cat DEVICES)
+
+# RAID 4/5/6 (can replace up to 'parity' devices)
+for i in 4 5 6; do
+	lvcreate --type raid$i -i 3 -l 3 -n $lv1 $vg
+
+	if [ $i -eq 6 ]; then
+		dev_cnt=5
+		limit=2
+	else
+		dev_cnt=4
+		limit=1
+	fi
+
+	for j in {1..3}; do
+	for o in $(seq 0 $i); do
+		replace=""
+
+		devices=( $(get_image_pvs $vg $lv1) )
+
+		for k in $(seq $j); do
+			index=$((($k + $o) % $dev_cnt))
+			replace="$replace --replace ${devices[$index]}"
+		done
+		aux wait_for_sync $vg $lv1
+
+		if [ $j -gt $limit ]; then
+			not lvconvert $replace $vg/$lv1
+		else
+			lvconvert $replace $vg/$lv1
+		fi
+	done
+	done
+
+	lvremove -ff $vg
+done
+
+vgremove -ff $vg



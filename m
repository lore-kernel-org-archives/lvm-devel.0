From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:11 +0000 (UTC)
Subject: dev-mornfall-lvmcache - tests: move raid test to separate file
Message-ID: <20130605120511.3773461398@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e9e7421c8ed4d86fe32937881e5020986207d0b3
Commit:        e9e7421c8ed4d86fe32937881e5020986207d0b3
Parent:        274eae592fc0d1787e5794c8d4f6d17c8a595659
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 31 17:35:24 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 31 21:42:32 2013 +0200

tests: move raid test to separate file

---
 test/shell/lvconvert-repair-raid.sh |   42 +++++++++++++++++++++++++++++++++++
 test/shell/lvconvert-repair.sh      |   26 ---------------------
 2 files changed, 42 insertions(+), 26 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
new file mode 100644
index 0000000..f087f32
--- /dev/null
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -0,0 +1,42 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
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
+test -e LOCAL_CLVMD && skip
+
+aux lvmconf 'allocation/maximise_cling = 0'
+aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
+
+aux prepare_vg 8
+aux target_at_least dm-raid 1 1 0
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
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 51bc9de..6bc646a 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -111,30 +111,4 @@ lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 aux enable_dev "$dev3"
 vgextend $vg "$dev3"
-lvremove -ff $vg
-
-if aux target_at_least dm-raid 1 1 0; then
-	# RAID5 single replace
-	lvcreate --type raid5 -i 2 -l 2 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
-	aux wait_for_sync $vg $lv1
-	aux disable_dev "$dev3"
-	lvconvert -y --repair $vg/$lv1
-	vgreduce --removemissing $vg
-	aux enable_dev "$dev3"
-	vgextend $vg "$dev3"
-	lvremove -ff $vg
-
-	# RAID6 double replace
-	lvcreate --type raid5 -i 3 -l 2 -n $lv1 $vg \
-	    "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-	aux wait_for_sync $vg $lv1
-	aux disable_dev "$dev4" "$dev5"
-	lvconvert -y --repair $vg/$lv1
-	vgreduce --removemissing $vg
-	aux enable_dev "$dev4"
-	aux enable_dev "$dev5"
-	vgextend $vg "$dev4" "$dev5"
-	lvremove -ff $vg
-fi
-
 vgremove -ff $vg



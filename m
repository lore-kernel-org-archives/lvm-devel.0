From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  8 Oct 2012 12:49:45 +0000 (UTC)
Subject: master - test: move raid test to separate tests
Message-ID: <20121008124945.DE7961512@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3877ccfe1bdbd0d2690d7488fcea42fac53fcb50
Commit:        3877ccfe1bdbd0d2690d7488fcea42fac53fcb50
Parent:        582a344cd68d663917928edba3cc76510941322d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 8 14:46:44 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 8 14:49:21 2012 +0200

test: move raid test to separate tests

Revert changes to origin lvcreate-large test and use separate
test scripts for raid  - so they can be properly skipped when
kernel doesn't support raid targets.
---
 test/shell/lvcreate-large-raid.sh   |   71 +++++++++++++++++++++++++++++++++++
 test/shell/lvcreate-large-raid10.sh |   40 +++++++++++++++++++
 test/shell/lvcreate-large.sh        |   65 ++++---------------------------
 3 files changed, 120 insertions(+), 56 deletions(-)

diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
new file mode 100644
index 0000000..8768bb3
--- /dev/null
+++ b/test/shell/lvcreate-large-raid.sh
@@ -0,0 +1,71 @@
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
+# 'Exercise some lvcreate diagnostics'
+
+. lib/test
+
+aux target_at_least dm-raid 1 1 0 || skip
+
+aux prepare_vg 5
+
+lvcreate -s -l 20%FREE -n $lv1 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv2 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
+
+#FIXME this should be 1024T
+#check lv_field $vg/$lv size "128.00m"
+
+aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+
+pvcreate $DM_DEV_DIR/$vg/$lv[12345]
+vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv[12345]
+
+# bz837927 START
+
+#
+# Create large RAID LVs
+#
+# We need '--nosync' or our virtual devices won't work
+lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
+check lv_field $vg1/$lv1 size "200.00t"
+lvremove -ff $vg1
+
+for segtype in raid4 raid5 raid6; do
+        lvcreate --type $segtype -i 3 -L 750T -n $lv1 $vg1 --nosync
+        check lv_field $vg1/$lv1 size "750.00t"
+        lvremove -ff $vg1
+done
+
+#
+# Convert large linear to RAID1 (belong in different test script?)
+#
+lvcreate -L 200T -n $lv1 $vg1
+# Need to deactivate or the up-convert will start sync'ing
+lvchange -an $vg1/$lv1
+lvconvert --type raid1 -m 1 $vg1/$lv1
+check lv_field $vg1/$lv1 size "200.00t"
+lvremove -ff $vg1
+
+#
+# Extending large RAID LV (belong in different script?)
+#
+lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
+check lv_field $vg1/$lv1 size "200.00t"
+lvextend -L +200T $vg1/$lv1
+check lv_field $vg1/$lv1 size "400.00t"
+lvremove -ff $vg1
+
+# bz837927 END
+
+lvremove -ff $vg
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
new file mode 100644
index 0000000..c9d4a2a
--- /dev/null
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -0,0 +1,40 @@
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
+# 'Exercise some lvcreate diagnostics'
+
+. lib/test
+
+aux target_at_least dm-raid 1 3 0 || skip
+
+aux prepare_vg 5
+
+lvcreate -s -l 20%FREE -n $lv1 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv2 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
+
+aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+
+pvcreate $DM_DEV_DIR/$vg/$lv[12345]
+vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv[12345]
+
+#
+# Create large RAID LVs
+#
+# We need '--nosync' or our virtual devices won't work
+
+lvcreate --type raid10 -m 1 -i 2 -L 200T -n $lv1 $vg1 --nosync
+check lv_field $vg1/$lv1 size "200.00t"
+lvremove -ff $vg1
+
+lvremove -ff $vg
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index 127b434..b61ccca 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -13,75 +13,28 @@
 
 . lib/test
 
-aux prepare_vg 5
+aux prepare_vg 4
 
-lvcreate -s -l 20%FREE -n $lv1 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv2 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
+lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
 
 #FIXME this should be 1024T
 #check lv_field $vg/$lv size "128.00m"
 
 aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
 
-pvcreate $DM_DEV_DIR/$vg/$lv[12345]
-vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv[12345]
+pvcreate $DM_DEV_DIR/$vg/$lv
+vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv
 
 lvcreate -l 100%FREE -n $lv1 $vg1
-check lv_field $vg1/$lv1 size "1.25p"
+check lv_field $vg1/$lv1 size "1024.00t"
 lvresize -f -l 72%VG $vg1/$lv1
-check lv_field $vg1/$lv1 size "921.60t"
+check lv_field $vg1/$lv1 size "737.28t"
 lvremove -ff $vg1/$lv1
 
 lvcreate -l 100%VG -n $lv1 $vg1
-check lv_field $vg1/$lv1 size "1.25p"
+check lv_field $vg1/$lv1 size "1024.00t"
 lvresize -f -l 72%VG $vg1/$lv1
-check lv_field $vg1/$lv1 size "921.60t"
+check lv_field $vg1/$lv1 size "737.28t"
 lvremove -ff $vg1/$lv1
 
-if aux target_at_least dm-raid 1 1 0; then
-	# bz837927 START
-
-	#
-	# Create large RAID LVs
-	#
-	# We need '--nosync' or our virtual devices won't work
-	lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
-	check lv_field $vg1/$lv1 size "200.00t"
-	lvremove -ff $vg1
-
-	lvcreate --type raid10 -m 1 -i 2 -L 200T -n $lv1 $vg1 --nosync
-	check lv_field $vg1/$lv1 size "200.00t"
-	lvremove -ff $vg1
-
-	for segtype in raid4 raid5 raid6; do
-		lvcreate --type $segtype -i 3 -L 750T -n $lv1 $vg1 --nosync
-		check lv_field $vg1/$lv1 size "750.00t"
-		lvremove -ff $vg1
-	done
-
-	#
-	# Convert large linear to RAID1 (belong in different test script?)
-	#
-	lvcreate -L 200T -n $lv1 $vg1
-	# Need to deactivate or the up-convert will start sync'ing
-	lvchange -an $vg1/$lv1
-	lvconvert --type raid1 -m 1 $vg1/$lv1
-	check lv_field $vg1/$lv1 size "200.00t"
-	lvremove -ff $vg1
-
-	#
-	# Extending large RAID LV (belong in different script?)
-	#
-	lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
-	check lv_field $vg1/$lv1 size "200.00t"
-	lvextend -L +200T $vg1/$lv1
-	check lv_field $vg1/$lv1 size "400.00t"
-	lvremove -ff $vg1
-
-	# bz837927 END
-fi
-
-lvremove -ff $vg
+lvremove -ff $vg/$lv



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jan 2021 15:10:02 +0000 (GMT)
Subject: main - tests: check support for online vdo rename
Message-ID: <20210122151002.8DC41398D000@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cddeaed6e956b181faf665f8af789cb517259bc2
Commit:        cddeaed6e956b181faf665f8af789cb517259bc2
Parent:        8532b1ca97e8b9b4a9250140b5d629169f36df28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 15:07:43 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 22 15:30:37 2021 +0100

tests: check support for online vdo rename

kvdo 6.2.3 module version supports online rename.
Add cache and raid stacked renames.
---
 test/shell/lvcreate-vdo-cache.sh | 17 +-------
 test/shell/lvrename-vdo.sh       | 88 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 90 insertions(+), 15 deletions(-)

diff --git a/test/shell/lvcreate-vdo-cache.sh b/test/shell/lvcreate-vdo-cache.sh
index c31ccccda..6cf84373c 100644
--- a/test/shell/lvcreate-vdo-cache.sh
+++ b/test/shell/lvcreate-vdo-cache.sh
@@ -32,22 +32,9 @@ export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
 
 aux prepare_vg 1 9000
 
-lvcreate --vdo -L4G -V2G --name $lv1 $vg/vpool1
-
+lvcreate --vdo -L4G -V2G --name $lv1 $vg/vpool
 # Test caching VDOPoolLV
-lvcreate -H -L10 $vg/vpool1
-
-# Current VDO target driver cannot handle online rename
-# once this will be supported - update this test
-not lvrename $vg/vpool1 $vg/vpool 2>&1 | tee out
-grep "Cannot rename" out
-
-lvchange -an $vg
-
-# Ofline should work
-lvrename $vg/vpool1 $vg/vpool
-
-lvchange -ay $vg
+lvcreate -H -L10 $vg/vpool
 
 mkfs.ext4 -E nodiscard "$DM_DEV_DIR/$vg/$lv1"
 
diff --git a/test/shell/lvrename-vdo.sh b/test/shell/lvrename-vdo.sh
new file mode 100644
index 000000000..1417d9fe3
--- /dev/null
+++ b/test/shell/lvrename-vdo.sh
@@ -0,0 +1,88 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Check online renaming of VDO devices works
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+#
+# Main
+#
+
+aux have_vdo 6 2 1 || skip
+aux have_cache 1 3 0 || skip
+aux have_raid 1 3 0 || skip
+
+aux prepare_vg 2 5000
+
+lvcreate --vdo -L4G -V2G --name $lv1 $vg/vpool1
+lvrename $vg/vpool1 vpool2
+check lv_exists $vg $lv1 vpool2 vpool2_vdata
+
+lvremove -ff $vg
+
+# With version >= 6.2.3 online rename should work
+if aux have_vdo 6 2 3 ; then
+
+### CACHE ####
+lvcreate --vdo -L4G -V2G --name $lv1 $vg/vpool1
+lvcreate -H -L10 $vg/vpool1
+lvrename $vg/vpool1 $vg/vpool2
+check lv_exists $vg vpool2 vpool2_vdata
+lvremove -ff $vg
+
+### RAID ####
+lvcreate --type raid1 -L4G --nosync --name vpool1 $vg
+lvconvert --yes --type vdo-pool $vg/vpool1
+lvrename $vg/vpool1 $vg/vpool2
+check lv_exists $vg vpool2 vpool2_vdata vpool2_vdata_rimage_0
+lvremove -ff $vg
+
+fi # >= 6.2.3
+
+# Check when VDO target does not support online resize
+aux lvmconf "global/vdo_disabled_features = [ \"online_rename\" ]"
+
+
+### CACHE ####
+lvcreate --vdo -L4G -V2G --name $lv1 $vg/vpool1
+lvcreate -H -L10 $vg/vpool1
+
+# VDO target driver cannot handle online rename
+not lvrename $vg/vpool1 $vg/vpool2 2>&1 | tee out
+grep "Cannot rename" out
+
+# Ofline should work
+lvchange -an $vg
+lvrename $vg/vpool1 $vg/vpool2
+lvchange -ay $vg
+check lv_exists $vg $lv1 vpool2 vpool2_vdata
+lvremove -ff $vg
+
+
+### RAID ####
+lvcreate --type raid1 -L4G --nosync --name vpool1 $vg
+lvconvert --yes --type vdo-pool $vg/vpool1
+not lvrename $vg/vpool1 $vg/vpool2 2>&1 | tee out
+grep "Cannot rename" out
+
+# Ofline should work
+lvchange -an $vg
+lvrename $vg/vpool1 $vg/vpool2
+lvchange -ay $vg
+check lv_exists $vg vpool2 vpool2_vdata vpool2_vdata_rimage_0
+lvremove -ff $vg
+
+vgremove -ff $vg



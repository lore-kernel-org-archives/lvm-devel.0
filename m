From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Sep 2015 15:30:02 +0000 (UTC)
Subject: master - tests: check cache stripe and raid behavior
Message-ID: <20150910153002.22FA960B43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54c982081fa6617c511e2a7d61dbe3b4e9c7d315
Commit:        54c982081fa6617c511e2a7d61dbe3b4e9c7d315
Parent:        a631fa20d0f18d12a8dc564d9b2d53d38e2e4d43
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 16:54:40 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 17:28:47 2015 +0200

tests: check cache stripe and raid behavior

Somehow raid tests landed in plain cache - separte them out
so they properly check for  have_raid.

Check we do not support strip option with cache-pool creation.
---
 test/shell/lvcreate-cache-raid.sh |   34 ++++++++++++++++++++++++++++++++++
 test/shell/lvcreate-cache.sh      |   22 +++++++---------------
 2 files changed, 41 insertions(+), 15 deletions(-)

diff --git a/test/shell/lvcreate-cache-raid.sh b/test/shell/lvcreate-cache-raid.sh
new file mode 100644
index 0000000..1c3c327
--- /dev/null
+++ b/test/shell/lvcreate-cache-raid.sh
@@ -0,0 +1,34 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Exercise creation of cache and raids
+
+. lib/inittest
+
+test -e LOCAL_LVMPOLLD && skip
+
+aux have_cache 1 3 0 || skip
+aux have_raid 1 0 0 || skip
+
+# FIXME: parallel cache metadata allocator is crashing when used value 8000!
+aux prepare_vg 5 80000
+
+aux lvmconf 'global/cache_disabled_features = [ "policy_smq" ]'
+
+# Bug 1110026 & Bug 1095843
+# Create RAID1 origin, then cache pool and cache
+lvcreate -aey -l 2 --type raid1 -m1 -n $lv2 $vg
+lvcreate --cache -l 1 $vg/$lv2
+check lv_exists $vg/${lv2}_corig_rimage_0	# ensure images are properly renamed
+check active $vg ${lv2}_corig
+dmsetup table ${vg}-$lv2 | grep cache		# ensure it is loaded in kernel
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index b921909..fce88f3 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -36,6 +36,8 @@ invalid lvcreate -H -l 1 --name $lv1 $vg
 invalid lvcreate -l 1 --cache $vg
 # Only cached volume could be created
 invalid lvcreate -l 1 --type cache $vg
+# Striping is not supported with cache-pool creation
+invalid lvcreate -l 1 -i 2 --type cache-pool $vg
 # Fails as it needs to see VG content
 fail lvcreate -l 1 --type cache --cachepool $vg/pool1
 fail lvcreate -l 1 --type cache --cachepool pool2 $vg
@@ -142,13 +144,6 @@ lvcreate -aey -l 2 -n $lv1 $vg
 lvcreate --type cache -l 1 $vg/$lv1
 dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 
-# Bug 1110026 & Bug 1095843
-# Create RAID1 origin, then cache pool and cache
-lvcreate -aey -l 2 --type raid1 -m1 -n $lv2 $vg
-lvcreate --cache -l 1 $vg/$lv2
-check lv_exists $vg/${lv2}_corig_rimage_0	# ensure images are properly renamed
-dmsetup table ${vg}-$lv2 | grep cache		# ensure it is loaded in kernel
-
 lvremove -f $vg
 
 
@@ -168,6 +163,8 @@ lvremove -f $vg
 
 # writeable origin and 'default' => writable cache + origin
 lvcreate -an -l1 -n $vg/$lv1
+# do not allow stripping for cache-pool
+fail lvcreate -H -i 2 -l1 -n cpool1 $vg/$lv1
 lvcreate -H -l1 -n cpool1 $vg/$lv1
 check lv_attr_bit perm $vg/cpool1 "w"
 check lv_attr_bit perm $vg/${lv1}_corig "w"
@@ -211,8 +208,9 @@ lvremove -f $vg
 lvcreate --type cache-pool -L10 --chunksize 256 --cachemode writeback $vg/cpool1
 check lv_field $vg/cpool1 chunksize "256.00k"
 check lv_field $vg/cpool1 cachemode "writeback"
-lvcreate -H -L10 -n $lv1 $vg/cpool1
-lvs -a -o+cachemode,chunksize $vg
+# check striping is supported when creating a cached LV
+lvcreate -H -L10 -i 2 -n $lv1 $vg/cpool1
+check lv_field $vg/${lv1}_corig stripes "2" -a
 check lv_field $vg/$lv1 chunksize "256.00k"
 check lv_field $vg/$lv1 cachemode "writeback"
 
@@ -264,10 +262,4 @@ grep "chunk size" out
 # --poolmetadatasize
 # --poolmetadataspare
 
-lvremove -f $vg
-lvcreate -n corigin -m 1 --type raid1 -l 10 $vg
-lvcreate -n cpool -H $vg/corigin -l 10
-check active $vg corigin_corig
-dmsetup table | grep ^$PREFIX | grep corigin_corig
-
 vgremove -ff $vg



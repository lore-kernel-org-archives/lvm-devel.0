From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Oct 2014 08:20:31 +0000 (UTC)
Subject: master - tests: move cache raid to separate file
Message-ID: <20141007082031.64E73602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c59ef732067988b708c7f809719ff887596a1e9f
Commit:        c59ef732067988b708c7f809719ff887596a1e9f
Parent:        9810f8aac7c0e38bd6cb88a45140bb41d52cd5b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 7 10:12:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 7 10:19:33 2014 +0200

tests: move cache raid to separate file

---
 test/shell/lvconvert-cache-raid.sh |   64 ++++++++++++++++++++++++++++++++++++
 test/shell/lvconvert-cache.sh      |   41 -----------------------
 2 files changed, 64 insertions(+), 41 deletions(-)

diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
new file mode 100644
index 0000000..0678846
--- /dev/null
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -0,0 +1,64 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Exercise usage of stacked cache volume using raid volume
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+aux have_raid 1 0 0 || skip
+
+aux prepare_vg 5 80
+
+# Bug 1095843
+# lvcreate RAID1 origin, lvcreate cache-pool, and lvconvert to cache
+lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
+lvconvert --cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
+check lv_exists $vg/${lv1}_corig_rimage_0 # ensure images are properly renamed
+dmsetup table ${vg}-$lv1 | grep cache   # ensure it is loaded in kernel
+lvremove -f $vg
+
+
+# lvcreate RAID1 origin, lvcreate RAID1 cache-pool, and lvconvert to cache
+lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+lvcreate --type raid1 -m 1 -l 2 -n ${lv1}_cachepool $vg
+#should lvs -a $vg/${lv1}_cdata_rimage_0  # ensure images are properly renamed
+lvconvert --yes --type cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
+check lv_exists $vg/${lv1}_corig_rimage_0        # ensure images are properly renamed
+dmsetup table ${vg}-$lv1 | grep cache   # ensure it is loaded in kernel
+lvremove -f $vg
+
+
+lvcreate -n corigin -m 1 --type raid1 -l 10 $vg
+lvcreate -n cpool --type cache $vg/corigin -l 10
+lvconvert --splitmirrors 1 --name split $vg/corigin "$dev1"
+
+lvremove -f $vg
+
+lvcreate -n cpool_meta -m 1 --type raid1 -l 10 $vg
+lvcreate -n cpool -m 1 --type raid1 -l 10 $vg
+lvconvert --yes --type cache-pool --poolmetadata $vg/cpool_meta $vg/cpool
+lvcreate -n corigin --type cache --cachepool $vg/cpool -l 10
+
+lvconvert --repair -y $vg/cpool_cmeta
+lvconvert --repair -y $vg/cpool_cdata
+
+# do not allow reserved names for *new* LVs
+not lvconvert --splitmirrors 1 --name split_cmeta $vg/cpool_cmeta "$dev1"
+not lvconvert --splitmirrors 1 --name split_cdata $vg/cpool_cdata "$dev1"
+
+# but allow manipulating existing LVs with reserved names
+lvconvert --splitmirrors 1 --name split_meta $vg/cpool_cmeta "$dev1"
+lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
+
+
+vgremove -f $vg
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index d2f591f..ae2de35 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -63,26 +63,6 @@ check lv_exists $vg $lv1 ${lv1}_cachepool
 lvremove -f $vg
 
 
-# Bug 1095843
-# lvcreate RAID1 origin, lvcreate cache-pool, and lvconvert to cache
-lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
-lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
-lvconvert --cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
-check lv_exists $vg/${lv1}_corig_rimage_0 # ensure images are properly renamed
-dmsetup table ${vg}-$lv1 | grep cache   # ensure it is loaded in kernel
-lvremove -ff $vg
-
-
-# lvcreate RAID1 origin, lvcreate RAID1 cache-pool, and lvconvert to cache
-lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
-lvcreate --type raid1 -m 1 -l 2 -n ${lv1}_cachepool $vg
-#should lvs -a $vg/${lv1}_cdata_rimage_0  # ensure images are properly renamed
-lvconvert --yes --type cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
-check lv_exists $vg/${lv1}_corig_rimage_0        # ensure images are properly renamed
-dmsetup table ${vg}-$lv1 | grep cache   # ensure it is loaded in kernel
-lvremove -ff $vg
-
-
 lvcreate -n corigin -l 10 $vg
 lvcreate -n pool -l 10 $vg
 lvs -a -o +devices
@@ -90,27 +70,6 @@ fail lvconvert --type cache --cachepool $vg/pool $vg/corigin
 lvconvert --yes --cache --cachepool $vg/pool $vg/corigin
 lvremove -ff $vg
 
-lvcreate -n corigin -m 1 --type raid1 -l 10 $vg
-lvcreate -n cpool --type cache $vg/corigin -l 10
-lvconvert --splitmirrors 1 --name split $vg/corigin $dev1
-
-lvremove -f $vg
-
-lvcreate -n cpool_meta -m 1 --type raid1 -l 10 $vg
-lvcreate -n cpool -m 1 --type raid1 -l 10 $vg
-lvconvert --yes --type cache-pool --poolmetadata $vg/cpool_meta $vg/cpool
-lvcreate -n corigin --type cache --cachepool $vg/cpool -l 10
-
-lvconvert --repair -y $vg/cpool_cmeta
-lvconvert --repair -y $vg/cpool_cdata
-
-# do not allow reserved names for *new* LVs
-not lvconvert --splitmirrors 1 --name split_cmeta $vg/cpool_cmeta $dev1
-not lvconvert --splitmirrors 1 --name split_cdata $vg/cpool_cdata $dev1
-
-# but allow manipulating existing LVs with reserved names
-lvconvert --splitmirrors 1 --name split_meta $vg/cpool_cmeta $dev1
-lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata $dev1
 
 #######################
 # Invalid conversions #



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:23 +0000 (UTC)
Subject: master - tests: new lvcreate functionality
Message-ID: <20141024144123.0E6B960CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1dede6f6b8b2d05e65acfda56ba3ec0d59f7619
Commit:        e1dede6f6b8b2d05e65acfda56ba3ec0d59f7619
Parent:        9642f013a104590b575badc024b887a02c7ad750
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 20 14:56:55 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

tests: new lvcreate functionality

Fixed syntax parsing means that some commands that used to work are now
failing. Particullary this case:

$ invalid lvcreate -l1 --type thin vg/pool
> Needs to fail becase thin type LV needs  --virtualsize

$ invalid lvcreate --type snapshot vg/lv1
> Needs to fail because old-snapshot segment type needs --size

Some reported error messages have been also updated.
---
 test/shell/lvcreate-cache.sh     |  116 +++++++++++++++++++++++++++++---------
 test/shell/lvcreate-thin-snap.sh |   13 +++-
 test/shell/lvcreate-thin.sh      |   26 +++++----
 test/shell/snapshot-usage.sh     |    2 +-
 4 files changed, 116 insertions(+), 41 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 17b8c09..69d0534 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -12,7 +12,7 @@
 # Exercise creation of cache and cache pool volumes
 
 # Full CLI uses  --type
-# Shorthand CLI uses --cache | -H
+# Shorthand CLI uses -H | --cache
 
 . lib/inittest
 
@@ -21,58 +21,75 @@ aux have_cache 1 3 0 || skip
 # FIXME: parallel cache metadata allocator is crashing when used value 8000!
 aux prepare_vg 5 80000
 
+
 #######################
 # Cache_Pool creation #
 #######################
-
-# FIXME: Unsupported yet creation of cache pool and cached volume at once
-# needs some policy to determine cache pool size
+# TODO: Unsupported yet creation of cache pool and cached volume at once
+# TODO: Introduce  --pooldatasize
+# TODO: Policy to determine cache pool size and cache pool name
 invalid lvcreate -H -l 1 $vg
-invalid lvcreate --cache -l 1 $vg
-invalid lvcreate --type cache -l 1 $vg
+invalid lvcreate -H -l 1 --name $lv1 $vg
+invalid lvcreate -l 1 --cache $vg
+# Only cached volume could be created
+invalid lvcreate -l 1 --type cache $vg
+# Fails as it needs to see VG content
+fail lvcreate -l 1 --type cache --cachepool $vg/pool1
+fail lvcreate -l 1 --type cache --cachepool pool2 $vg
+fail lvcreate -l 1 --cache $vg/pool3
+fail lvcreate -l 1 -H --cachepool pool4 $vg
+fail lvcreate -l 1 -H --name $lv2 $vg/pool5
+fail lvcreate -l 1 -H --name $lv3 --cachepool $vg/pool6
+fail lvcreate -l 1 -H --name $vg/$lv4 --cachepool pool7
 
-# Unlike in thin pool case - cache pool and cached volume both need size arg.
+# Unlike in thin pool case - cache pool and cache volume both need size arg.
 # So we require cache pool to exist and need to fail when it's missing.
 #
-# FIXME: introduce  --poolsize to make this command possible to pass
-fail lvcreate -l 1 -H --cachepool $vg/pool3
-fail lvcreate -l 1 -H --cachepool pool4 $vg
-fail lvcreate -l 1 --type cache --cachepool $vg/pool5
-fail lvcreate -l 1 --type cache --cachepool pool6 $vg
-# --cachpool bring implicit --cache
-fail lvcreate -l 1 --cachepool pool7 $vg
+# --cachepool gives implicit --cache
+fail lvcreate -l 1 --cachepool pool8 $vg
+
+# no size specified
+invalid lvcreate --cachepool pool $vg |& tee err
+grep "specify either size or extents" err
 
 # Check nothing has been created yet
 check vg_field $vg lv_count 0
 
-# If the cache pool volume doesn't yet exist -> cache pool creation
-lvcreate -l 1 -H $vg/pool1
-lvcreate -l 1 --type cache $vg/pool2
-
-# With cache-pool we are clear what has to be created
-lvcreate -l 1 --type cache-pool $vg/pool3
-lvcreate -l 1 --type cache-pool --cachepool $vg/pool4
-lvcreate -l 1 --type cache-pool --cachepool pool5 $vg
-lvcreate -l 1 --type cache-pool --name pool6 $vg
-lvcreate -l 1 --type cache-pool --name $vg/pool7
 
+# With --type cache-pool we are clear which segtype has to be created
+lvcreate -l 1 --type cache-pool $vg/pool1
 check lv_field $vg/pool1 segtype "cache-pool"
+lvcreate -l 1 --type cache-pool --name $vg/pool2 $vg
 check lv_field $vg/pool2 segtype "cache-pool"
+lvcreate -l 1 --type cache-pool --cachepool $vg/pool3 $vg
 check lv_field $vg/pool3 segtype "cache-pool"
+lvcreate -l 1 --type cache-pool --cachepool $vg/pool4
 check lv_field $vg/pool4 segtype "cache-pool"
+lvcreate -l 1 --type cache-pool --cachepool pool5 $vg
 check lv_field $vg/pool5 segtype "cache-pool"
+lvcreate -l 1 --type cache-pool --name pool6 $vg
 check lv_field $vg/pool6 segtype "cache-pool"
+lvcreate -l 1 --type cache-pool --name $vg/pool7
 check lv_field $vg/pool7 segtype "cache-pool"
 
 lvremove -f $vg
 
+
 # Validate ambiguous pool name is detected
 invalid lvcreate -l 1 --type cache-pool --cachepool pool1 $vg/pool2
 invalid lvcreate -l 1 --type cache-pool --name pool3 --cachepool pool4 $vg
 invalid lvcreate -l 1 --type cache-pool --name pool6 --cachepool pool6 $vg/pool7
 invalid lvcreate -l 1 --type cache-pool --name pool8 $vg/pool9
+
+# Unsupported with cache & cache pool
+invalid lvcreate --type cache-pool --discards passdown -l1 $vg
+invalid lvcreate -H --discards passdown -l1 $vg
+invalid lvcreate --type cache-pool --virtualsize 1T -l1 $vg
+invalid lvcreate -H --virtualsize 1T -l1 $vg
+
 check vg_field $vg lv_count 0
 
+
 for mode in "" "--cachemode writethrough"
 do
 
@@ -114,6 +131,7 @@ lvremove -f $vg
 
 done
 
+
 # Conversion through lvcreate case
 # Bug 1110026
 # Create origin, then cache pool and cache the origin
@@ -141,14 +159,60 @@ grep "WARNING: Maximum" out
 
 lvremove -f $vg
 
+########################################
+# Cache conversion and r/w permissions #
+########################################
+
+# writeable origin and 'default' => writable cache + origin
+lvcreate -an -l1 -n $vg/$lv1
+lvcreate -H -l1 -n cpool1 $vg/$lv1
+check lv_attr_bit perm $vg/cpool1 "w"
+check lv_attr_bit perm $vg/${lv1}_corig "w"
+check lv_attr_bit perm $vg/$lv1 "w"
+
+# writeable origin and -pr => conversion is not supported
+lvcreate -an -l1 -n $vg/$lv2
+fail lvcreate -H -l1 -pr -n cpool2 $vg/$lv2
+
+# read-only origin and -pr => read-only cache + origin
+lvcreate -an -pr -l1 -n $vg/$lv3
+lvcreate -an -H -l1 -pr -n cpool3 $vg/$lv3
+check lv_attr_bit perm $vg/cpool3 "w"
+check lv_attr_bit perm $vg/${lv3}_corig "r"
+check lv_attr_bit perm $vg/$lv3 "r"
+check inactive $vg $lv3
+check inactive $vg cpool3
+
+# read-only origin and 'default' => read-only cache + origin
+lvcreate -an -pr -l1 -n $vg/$lv4
+lvcreate -H -l1 -n cpool4 $vg/$lv4
+check lv_attr_bit perm $vg/cpool4 "w"
+check lv_attr_bit perm $vg/${lv4}_corig "r"
+check lv_attr_bit perm $vg/$lv4 "r"
+
+# read-only origin and -prw => conversion unsupported
+lvcreate -an -pr -l1 -n $vg/$lv5
+fail lvcreate -H -l1 -prw -n cpool5 $vg/$lv5
+
+# cached volume respects permissions
+lvcreate --type cache-pool -l1 -n $vg/cpool
+lvcreate -H -l1 -pr -n $lv6 $vg/cpool
+check lv_attr_bit perm $vg/cpool "w"
+check lv_attr_bit perm $vg/$lv6 "r"
+
+lvremove -f $vg
+
 
 ##############################
 # Test things that should fail
 ##############################
 
+# Creation of read-only cache pool is not supported
+invalid lvcreate -pr --type cache-pool -l1 -n $vg/cpool
+
 # Atempt to use bigger chunk size then cache pool data size
 fail lvcreate -l 1 --type cache-pool --chunksize 16M $vg 2>out
-grep "is bigger" out
+grep "chunk size" out
 
 # Option testing
 # --chunksize
@@ -158,7 +222,7 @@ grep "is bigger" out
 
 lvremove -f $vg
 lvcreate -n corigin -m 1 --type raid1 -l 10 $vg
-lvcreate -n cpool --type cache $vg/corigin -l 10
+lvcreate -n cpool -H $vg/corigin -l 10
 check active $vg corigin_corig
 dmsetup table | grep ^$PREFIX | grep corigin_corig
 
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 6f29a28..784eb5d 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -41,9 +41,16 @@ lvcreate -K -s $vg/$lv1 -pr --name snap
 fsck -n "$DM_DEV_DIR/$vg/snap"
 lvcreate -K -s $vg/$lv1 --name $lv2
 lvcreate -K -s $vg/$lv1 --name $vg/$lv3
-lvcreate --type snapshot $vg/$lv1
-lvcreate --type snapshot $vg/$lv1 --name $lv4
-lvcreate --type snapshot $vg/$lv1 --name $vg/$lv5
+# old-snapshot without known size is invalid
+invalid lvcreate --type snapshot $vg/$lv1
+invalid lvcreate --type snapshot $vg/$lv1 --name $lv4
+invalid lvcreate --type snapshot $vg/$lv1 --name $vg/$lv5
+# some other ways how to take a thin snapshot
+lvcreate -T $vg/$lv1
+lvcreate --thin $vg/$lv1 --name $lv4
+lvcreate --type thin $vg/$lv1 --name $vg/$lv5
+# virtual size needs thin pool
+fail lvcreate --type thin $vg/$lv1 -V20
 
 # create old-style snapshot
 lvcreate -s -L10M --name oldsnap1 $vg/$lv2
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 16eb1e7..619a40c 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -39,14 +39,14 @@ vgcreate $vg -s 64K $(cat DEVICES)
 lvcreate -l1 -T $vg/pool1
 lvcreate -l1 -T --thinpool $vg/pool2
 lvcreate -l1 -T --thinpool pool3 $vg
-lvcreate -l1 --type thin $vg/pool4
-lvcreate -l1 --type thin --thinpool $vg/pool5
-lvcreate -l1 --type thin --thinpool pool6 $vg
+invalid lvcreate -l1 --type thin $vg/pool4
+invalid lvcreate -l1 --type thin --thinpool $vg/pool5
+invalid lvcreate -l1 --type thin --thinpool pool6 $vg
 lvcreate -l1 --type thin-pool $vg/pool7
 lvcreate -l1 --type thin-pool --thinpool $vg/pool8
 lvcreate -l1 --type thin-pool --thinpool pool9 $vg
 
-lvremove -ff $vg/pool1 $vg/pool2 $vg/pool3 $vg/pool4 $vg/pool5 $vg/pool6 $vg/pool7 $vg/pool8 $vg/pool9
+lvremove -ff $vg/pool1 $vg/pool2 $vg/pool3 $vg/pool7 $vg/pool8 $vg/pool9
 check vg_field $vg lv_count 0
 
 
@@ -56,6 +56,10 @@ invalid lvcreate --type thin-pool -l1 --name pool1 $vg/pool2
 invalid lvcreate --type thin-pool -l1 --name pool3 --thinpool pool4 $vg
 invalid lvcreate --type thin-pool -l1 --name pool5 --thinpool pool6 $vg/pool7
 invalid lvcreate --type thin-pool -l1 --name pool8 --thinpool pool8 $vg/pool9
+
+# no size specified and no origin name give for snapshot
+invalid lvcreate --thinpool pool $vg
+
 check vg_field $vg lv_count 0
 
 lvcreate --type thin-pool -l1 --name pool1 $vg
@@ -76,7 +80,7 @@ lvremove -ff $vg
 
 # Create default pool name
 lvcreate -l1 -T $vg
-lvcreate -l1 --type thin $vg
+invalid lvcreate -l1 --type thin $vg
 lvcreate -l1 --type thin-pool $vg
 
 lvremove -ff $vg
@@ -98,7 +102,7 @@ lvcreate -L4M -V2G --name lvo4 --type thin $vg/pool4
 lvcreate -L4M -V2G --name lvo5 --type thin --thinpool $vg/pool5
 lvcreate -L4M -V2G --name lvo6 --type thin --thinpool pool6 $vg
 
-check lv_exists $vg lvo1 lvo2 lvo3 lvo4 lvo5 lvo6
+check lv_exists $vg lvo1 lvo2 lvo3
 lvremove -ff $vg
 
 
@@ -165,13 +169,13 @@ lvcreate -K -s $vg/lv1 --name snap_lv1
 fsck -n "$DM_DEV_DIR/$vg/snap_lv1"
 lvcreate -s $vg/lv1 --name lv2
 lvcreate -s $vg/lv1 --name $vg/lv3
-lvcreate --type snapshot $vg/lv1 --name lv6
-lvcreate --type snapshot $vg/lv1 --name lv4
-lvcreate --type snapshot $vg/lv1 --name $vg/lv5
+invalid lvcreate --type snapshot $vg/lv1 --name lv6
+invalid lvcreate --type snapshot $vg/lv1 --name lv4
+invalid lvcreate --type snapshot $vg/lv1 --name $vg/lv5
 
 lvdisplay --maps $vg
-check_lv_field_modules_ thin,thin-pool lv1 snap_lv1 lv2 lv3 lv4 lv5 lv6
-check vg_field $vg lv_count 8
+check_lv_field_modules_ thin,thin-pool lv1 snap_lv1 lv2 lv3
+check vg_field $vg lv_count 5
 
 lvremove -ff $vg
 
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index dcf2886..c29d310 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -69,7 +69,7 @@ vgcreate -s 4M $vg $(cat DEVICES)
 lvcreate -aey -l1 -n $lv $vg
 # 100%LV is not supported for snapshot
 fail lvcreate -s -l 100%LV -n snap $vg/$lv |& tee out
-grep 'Please express size as %ORIGIN, %VG, %PVS, or %FREE' out
+grep 'Please express size as %FREE, %ORIGIN, %PVS or %VG' out
 # 100%ORIGIN needs to have enough space for all data and needs to round-up
 lvcreate -s -l 100%ORIGIN -n $lv1 $vg/$lv
 # everything needs to fit



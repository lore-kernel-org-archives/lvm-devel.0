From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:16:16 -0400
Subject: master - tests: change lvcreate syntax to allow lvmlockd
Message-ID: <201805311416.w4VEGGrD031456@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2beb3009bd7e34604dbd4f03c95fb7cd85eb98a6
Commit:        2beb3009bd7e34604dbd4f03c95fb7cd85eb98a6
Parent:        214235367b3500a586fc42232af34bd04ad14078
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 30 16:40:03 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 16:40:03 2018 -0500

tests: change lvcreate syntax to allow lvmlockd

Using the less ambiguous lvcreate syntax for creating a
cache LV allows more tests to run with lvmlockd.
---
 test/shell/lvchange-cache-old.sh      |    4 ++--
 test/shell/lvconvert-cache-raid.sh    |    3 +--
 test/shell/lvcreate-cache-snapshot.sh |    3 +--
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvchange-cache-old.sh b/test/shell/lvchange-cache-old.sh
index cb7915d..992249c 100644
--- a/test/shell/lvchange-cache-old.sh
+++ b/test/shell/lvchange-cache-old.sh
@@ -12,7 +12,7 @@
 
 # Exercise usage of older metadata which are missing some new settings
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -24,7 +24,7 @@ aux prepare_vg 5 80
 
 
 lvcreate -l 10 --type cache-pool $vg/cpool
-lvcreate -l 20 -H -n $lv1 $vg/cpool
+lvcreate -l 20 -H -n $lv1 --cachepool $vg/cpool $vg
 
 vgcfgbackup -f backup $vg
 
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index ec9b1e4..fa49163 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -12,7 +12,6 @@
 
 # Exercise usage of stacked cache volume using raid volume
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -86,7 +85,7 @@ lvremove -f $vg
 
 # Test up/down raid conversion of cache pool data and metadata
 lvcreate --type cache-pool $vg/cpool -l 10
-lvcreate -n corigin -H $vg/cpool -l 20
+lvcreate -H -n corigin --cachepool $vg/cpool -l 20 $vg
 
 lvconvert -y -m +1 --type raid1 $vg/cpool_cmeta
 check lv_field $vg/cpool_cmeta layout "raid,raid1"
diff --git a/test/shell/lvcreate-cache-snapshot.sh b/test/shell/lvcreate-cache-snapshot.sh
index c1be6a2..5d1c5a7 100644
--- a/test/shell/lvcreate-cache-snapshot.sh
+++ b/test/shell/lvcreate-cache-snapshot.sh
@@ -12,7 +12,6 @@
 
 # Exercise creation of snapshot of cached LV
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -25,7 +24,7 @@ aux have_cache 1 5 0 || skip
 aux prepare_vg 2
 
 lvcreate --type cache-pool -L1 $vg/cpool
-lvcreate -H -L4 -n $lv1 $vg/cpool
+lvcreate -H -L4 -n $lv1 --cachepool $vg/cpool $vg
 
 lvcreate -s -L2 -n $lv2 $vg/$lv1
 check lv_field $vg/$lv1 segtype cache



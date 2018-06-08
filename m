From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:39:00 -0400
Subject: master - tests: check proper support of fmt2 with cleaner policy
Message-ID: <201806081239.w58Cd0xt006101@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c93e0932e8d3005d2b0f6e1e66f7fba72f3ac950
Commit:        c93e0932e8d3005d2b0f6e1e66f7fba72f3ac950
Parent:        8b111f28b0cf75951c18f1b7f100e5aa59d4f659
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 8 12:46:47 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:37:31 2018 +0200

tests: check proper support of fmt2 with cleaner policy

---
 test/shell/cache-metadata2.sh |   10 ++++++++++
 test/shell/lvconvert-cache.sh |    5 +++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/shell/cache-metadata2.sh b/test/shell/cache-metadata2.sh
index 684ae67..57c6e23 100644
--- a/test/shell/cache-metadata2.sh
+++ b/test/shell/cache-metadata2.sh
@@ -51,6 +51,11 @@ lvs -a -o+cachemetadataformat $vg
 
 lvremove -f $vg
 
+lvcreate --type cache-pool --cachepolicy cleaner --cachemetadataformat 1 -L1 $vg/cpool
+lvcreate -H -L10 -n $lv1 --cachepool $vg/cpool
+check lv_field $vg/$lv1 cachemetadataformat "1"
+lvremove -f $vg
+
 if [ -z "$META2" ]; then
 # for these test we need kernel with metadata2 support
 
@@ -78,6 +83,11 @@ lvconvert --config 'allocation/cache_metadata_format=1' -y -H --cachepool $vg/cp
 check lv_field $vg/$lv1 cachemetadataformat "1"
 lvremove -f $vg
 
+lvcreate --type cache-pool --cachepolicy cleaner -L1 $vg/cpool
+lvcreate -H -L10 -n $lv1 --cachepool $vg/cpool
+check lv_field $vg/$lv1 cachemetadataformat "2"
+lvremove -f $vg
+
 fi
 #lvs -a -o name,cachemetadataformat,kernelmetadataformat,chunksize,cachepolicy,cachemode $vg
 
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index c3742af..b2a2920 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -106,6 +106,11 @@ fail lvconvert --type cache --cachepool $vg/pool $vg/corigin
 lvconvert --yes --cache --cachepool $vg/pool $vg/corigin
 lvremove -ff $vg
 
+# Check we also support conversion that uses 'cleaner' cache policy
+lvcreate -n corigin -l 10 $vg
+lvcreate -n pool -l 10 $vg
+lvconvert --yes --cache --cachepool $vg/pool $vg/corigin --cachepolicy cleaner
+lvremove -ff $vg
 
 #######################
 # Invalid conversions #



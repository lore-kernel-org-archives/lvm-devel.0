From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 31 Oct 2019 08:17:45 -0400
Subject: stable-2.02 - tests: needs exclusive activation for conversion
Message-ID: <201910311217.x9VCHjAs010793@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b741b3bbac6121f05caa455b31fed0983a30b64
Commit:        8b741b3bbac6121f05caa455b31fed0983a30b64
Parent:        5ee3d6dbdffc47467727d8c89fc91d84aa97189a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 30 09:36:10 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 30 09:36:10 2019 +0100

tests: needs exclusive activation for conversion

For online convertion LVs must be activated localy exclusive as
cache can only work for exclusive activation.
---
 test/shell/lvconvert-cache-thin.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-cache-thin.sh b/test/shell/lvconvert-cache-thin.sh
index 7dda6e6..ad4a03e 100644
--- a/test/shell/lvconvert-cache-thin.sh
+++ b/test/shell/lvconvert-cache-thin.sh
@@ -54,8 +54,8 @@ lvs -a $vg
 lvremove -f $vg
 
 # Check conversion of cached LV works as thin-pool
-lvcreate -L10 -n $lv $vg
-lvcreate -L10 -n $lv1 $vg
+lvcreate -aey -L10 -n $lv $vg
+lvcreate -aey -L10 -n $lv1 $vg
 lvcreate -H -L10 $vg/$lv
 
 # Stack of cache over cache is unsupported ATM



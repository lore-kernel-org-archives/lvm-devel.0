From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 23:03:28 +0000 (UTC)
Subject: master - tests: update test for modified output
Message-ID: <20160623230328.D240460734@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5070e7fcf79a3bcb21982d219c6f8dd484e523ea
Commit:        5070e7fcf79a3bcb21982d219c6f8dd484e523ea
Parent:        fc174f6b74ee1d0fc12cca9fe5c392621acf069f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 23 22:35:51 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 24 00:39:15 2016 +0200

tests: update test for modified output

We now print  vg/lv  for lv resized volume
---
 test/shell/lvextend-percent-extents.sh |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index e2666e9..67c36b2 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -30,8 +30,8 @@ not lvextend -l 10 -L 64m $vg/$lv "$dev1" 2>err
 grep "Please specify either size or extents but not both." err
 
 # 'lvextend accepts no size or extents but one PV - bz154691'
-lvextend $vg/$lv "$dev1" >out
-grep "Logical volume $lv successfully resized" out
+lvextend $vg/$lv "$dev1" | tee out
+grep "Logical volume $vg/$lv successfully resized" out
 check pv_field "$dev1" pv_free "0"
 
 lvremove -f $vg/$lv
@@ -47,8 +47,8 @@ lvremove -f $vg/$lv
 lvcreate -L 64m -n $lv $vg
 
 # 'lvextend accepts no size but extents 100%PVS and two PVs - bz154691'
-lvextend -l +100%PVS $vg/$lv "$dev1" "$dev2" >out
-grep "Logical volume $lv successfully resized" out
+lvextend -l +100%PVS $vg/$lv "$dev1" "$dev2" | tee out
+grep "Logical volume $vg/$lv successfully resized" out
 check pv_field "$dev1" pv_free "0"
 check pv_field "$dev2" pv_free "0"
 
@@ -80,8 +80,8 @@ check lv_field $vg/$lv lv_size "48.00m"
 
 # 'lvextend with partially allocated PVs and extents 100%PVS with PE ranges'
 extend_pvs=$(for i in $(seq 0 6 18); do echo -n "$dev1:$i-$(($i + 2)) "; done)
-lvextend -l +100%PVS $vg/$lv $extend_pvs >out
-grep "Logical volume $lv successfully resized" out
+lvextend -l +100%PVS $vg/$lv $extend_pvs | tee out
+grep "Logical volume $vg/$lv successfully resized" out
 check lv_field $vg/$lv lv_size "72.00m"
 
 # Simple seg_count validation; initially create the LV with half the # of



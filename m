From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Jul 2016 12:42:35 +0000 (UTC)
Subject: master - tests: check thin resize of raid10
Message-ID: <20160722124235.D0C7160FAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7fc1617819236d4d6f8b0ffbcd4980fcc5bc5de6
Commit:        7fc1617819236d4d6f8b0ffbcd4980fcc5bc5de6
Parent:        5bb113c20469aa5027098465ddeaa3c652d4f8e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 22 11:07:54 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 22 14:41:47 2016 +0200

tests: check thin resize of raid10

---
 test/shell/lvextend-thin-raid.sh |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvextend-thin-raid.sh b/test/shell/lvextend-thin-raid.sh
index 7014985..1688ffb 100644
--- a/test/shell/lvextend-thin-raid.sh
+++ b/test/shell/lvextend-thin-raid.sh
@@ -19,7 +19,7 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 aux have_thin 1 0 0 || skip
 aux have_raid 1 3 0 || skip
 
-aux prepare_vg 3
+aux prepare_vg 6
 
 lvcreate --type raid1 -l2 --nosync -n pool $vg
 lvconvert --yes --thinpool $vg/pool "$dev3"
@@ -32,4 +32,20 @@ lvextend -l+3 $vg/pool
 check lv_field $vg/pool seg_size_pe "5"
 check lv_field $vg/pool_tdata seg_size_pe "5" -a
 
+lvremove -f $vg
+
+# check 'raid10' resize works for pool metadata resize
+# https://bugzilla.redhat.com/1075644
+lvcreate --type raid10 -m1 -L5 -i3 --nosync -n pool $vg
+lvcreate --type raid10 -m1 -L3 -i3 --nosync -n meta $vg
+lvconvert --yes --thinpool $vg/pool --poolmetadata $vg/meta
+
+check lv_field $vg/pool_tdata lv_size "6.00m" -a
+check lv_field $vg/pool_tmeta lv_size "3.00m" -a
+
+lvextend --poolmetadatasize +1 --size +1 $vg/pool
+
+check lv_field $vg/pool_tdata lv_size "7.50m" -a
+check lv_field $vg/pool_tmeta lv_size "4.50m" -a
+
 vgremove -ff $vg



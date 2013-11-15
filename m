From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Nov 2013 11:39:45 +0000 (UTC)
Subject: master - tests: used -n for fsck
Message-ID: <20131115113945.8AB10611A2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=803f8ca7146c548c271c04d432a3c68726a0d37d
Commit:        803f8ca7146c548c271c04d432a3c68726a0d37d
Parent:        3716e9535455c5fb012511f820d0525e4aa48bc8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 11 17:19:26 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 12:38:37 2013 +0100

tests: used -n for fsck

---
 test/shell/lvcreate-thin-snap.sh |    4 ++--
 test/shell/lvcreate-thin.sh      |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index a223469..b7511e7 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -37,7 +37,7 @@ mkfs.ext4 $DM_DEV_DIR/$vg/$lv1
 # create thin snapshot of thin LV
 lvcreate -K -s $vg/$lv1 --name snap
 # check snapshot filesystem was properly frozen before snapping
-fsck -p $DM_DEV_DIR/$vg/snap
+fsck -n $DM_DEV_DIR/$vg/snap
 lvcreate -K -s $vg/$lv1 --name $lv2
 lvcreate -K -s $vg/$lv1 --name $vg/$lv3
 lvcreate --type snapshot $vg/$lv1
@@ -59,6 +59,6 @@ lvremove -ff $vg
 lvcreate -L10M --zero n -T $vg/pool -V10M --name $lv1
 mkfs.ext4 $DM_DEV_DIR/$vg/$lv1
 lvcreate -K -s $vg/$lv1 --name snap
-fsck -p $DM_DEV_DIR/$vg/snap
+fsck -n $DM_DEV_DIR/$vg/snap
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index d2e3022..98ab7eb 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -138,7 +138,7 @@ check vg_field $vg lv_count 0
 lvcreate -L10M -V10M -T $vg/pool --name lv1
 mkfs.ext4 $DM_DEV_DIR/$vg/lv1
 lvcreate -K -s $vg/lv1 --name snap_lv1
-fsck -p $DM_DEV_DIR/$vg/snap_lv1
+fsck -n $DM_DEV_DIR/$vg/snap_lv1
 lvcreate -s $vg/lv1 --name lv2
 lvcreate -s $vg/lv1 --name $vg/lv3
 lvcreate --type snapshot $vg/lv1 --name lv6



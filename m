From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 Apr 2016 21:14:03 +0000 (UTC)
Subject: master - tests: use bigger raid size
Message-ID: <20160418211403.020F060E5C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=59b0bd7b6445d0c09568eae4cbf75577ce190803
Commit:        59b0bd7b6445d0c09568eae4cbf75577ce190803
Parent:        88c19d5d7200b4193693f88f42e05646a52b4563
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 18 23:09:17 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 18 23:09:17 2016 +0200

tests: use bigger raid size

To avoid problem with report of array in-sync use for now bigger
raid size 64M.
---
 test/shell/lvconvert-repair-raid.sh |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 41d1cb9..1ef91c4 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -22,8 +22,12 @@ aux lvmconf 'allocation/maximise_cling = 0' \
 
 aux prepare_vg 8
 
+# It's possible small raid arrays do have problems with reporting in-sync.
+# So try bigger size
+RAID_SIZE=64
+
 # RAID5 single replace
-lvcreate --type raid5 -i 2 -l 2 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+lvcreate --type raid5 -i 2 -L $RAID_SIZE -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 aux wait_for_sync $vg $lv1
 aux disable_dev "$dev3"
 lvconvert -y --repair $vg/$lv1
@@ -33,7 +37,7 @@ vgextend $vg "$dev3"
 lvremove -ff $vg
 
 # RAID6 double replace
-lvcreate --type raid6 -i 3 -l 2 -n $lv1 $vg \
+lvcreate --type raid6 -i 3 -L $RAID_SIZE -n $lv1 $vg \
     "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 aux wait_for_sync $vg $lv1
 aux disable_dev "$dev4" "$dev5"



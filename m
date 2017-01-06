From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Jan 2017 22:40:25 +0000 (UTC)
Subject: master - tests: ignore racy test failure
Message-ID: <20170106224025.6180D60506@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15e657f110351ab16af8bd79e1716adce9b75beb
Commit:        15e657f110351ab16af8bd79e1716adce9b75beb
Parent:        d757b2431a56bd5ae45fe863423942d89e14cbf9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 6 23:37:46 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 6 23:39:53 2017 +0100

tests: ignore racy test failure

When test fails here, make it just warning instead of failing whole
test.
---
 test/shell/lvconvert-repair-raid.sh |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index d3ac1da..26bca3d 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -79,12 +79,15 @@ vgextend $vg "$dev3"
 lvremove -ff $vg/$lv1
 
 # Delayed sync to allow for repair during rebuild
-delay 50
+delay 60
 
 # RAID5 single replace during initial sync
 lvcreate --type raid5 -i 2 -L $RAID_SIZE -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 aux disable_dev "$dev3"
-not lvconvert -y --repair $vg/$lv1
+# FIXME: there is quite big sleep on several 'status' read retries
+# so over 3sec - it may actually finish full sync
+# Use 'should' for this test result.
+should not lvconvert -y --repair $vg/$lv1
 aux wait_for_sync $vg $lv1
 lvconvert -y --repair $vg/$lv1
 vgreduce --removemissing $vg



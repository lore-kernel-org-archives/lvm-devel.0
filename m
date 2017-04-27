From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 27 Apr 2017 09:58:26 -0400
Subject: master - test: add -y to raid1 up conversions
Message-ID: <201704271358.v3RDwQ9E001751@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=33afe2ca76e4bddcfa33aafa2fed28d4ca60e08e
Commit:        33afe2ca76e4bddcfa33aafa2fed28d4ca60e08e
Parent:        05164479781486dbe2486c0439d42ed03e4483e8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 27 15:56:58 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 27 15:56:58 2017 +0200

test: add -y to raid1 up conversions

---
 test/shell/lvconvert-raid-allocation.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index b23644c..1a768b6 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -22,8 +22,8 @@ vgcreate -s 256k $vg $(cat DEVICES)
 # Start with linear on 2 PV and ensure that converting to
 # RAID is not allowed to reuse PVs for different images.  (Bug 1113180)
 lvcreate -aey -l 4 -n $lv1 $vg "$dev1:0-1" "$dev2:0-1"
-not lvconvert --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev2"
-not lvconvert --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev3:0-2"
+not lvconvert -y --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev2"
+not lvconvert -y --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev3:0-2"
 lvconvert -y --type raid1 -m 1 $vg/$lv1 "$dev3"
 not lvconvert -m 0 $vg/$lv1
 lvconvert -y -m 0 $vg/$lv1



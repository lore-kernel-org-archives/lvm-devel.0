From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 8 Mar 2017 20:36:21 -0500
Subject: master - test: "lvconvert --repair" after vgreduce
Message-ID: <201703090136.v291aLW9004905@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8daad1166608cd99beca7fb23223a9ed66353e40
Commit:        8daad1166608cd99beca7fb23223a9ed66353e40
Parent:        90ed3d5e8c977d632911746c2faf09f60ddbeacc
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 02:35:57 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 02:35:57 2017 +0100

test: "lvconvert --repair" after vgreduce

Add test for commit 921b496fff51.
---
 test/shell/lvconvert-repair-raid.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 3052f5c..b25d861 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -72,9 +72,10 @@ delay 0
 lvcreate --type raid5 -i 2 -L $RAID_SIZE -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 aux wait_for_sync $vg $lv1
 aux disable_dev "$dev3"
+vgreduce --removemissing -f $vg
 lvconvert -y --repair $vg/$lv1
-vgreduce --removemissing $vg
 aux enable_dev "$dev3"
+pvcreate -yff "$dev3"
 vgextend $vg "$dev3"
 lvremove -ff $vg/$lv1
 



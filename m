From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Mar 2021 11:41:49 +0000 (GMT)
Subject: main - tests: query info instead of table
Message-ID: <20210324114149.ECBFB3857C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=18f2475fa18bfe8b08af830bb8335d41928206fe
Commit:        18f2475fa18bfe8b08af830bb8335d41928206fe
Parent:        8df0a32abb840815c5d210cbdbd1483d483ee729
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 24 00:37:24 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 24 12:22:27 2021 +0100

tests: query info instead of table

No need to access table when we just check presence,
so generate smaller error message about missing device.
---
 test/shell/lvm-on-md.sh | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 22d5b4ca4..9187d44f5 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -93,7 +93,7 @@ not grep "Not using device" out
 not vgchange -ay $vg
 
 # should not show an active lv
-not dmsetup table $vg-$lv1
+not dmsetup info $vg-$lv1
 
 # should not allow updating vg
 not lvcreate -l1 $vg
@@ -107,7 +107,7 @@ test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
 test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 # should not show an active lv
-not dmsetup table $vg-$lv1
+not dmsetup info $vg-$lv1
 
 mdadm --assemble "$mddev" "$dev1" "$dev2"
 aux udev_wait
@@ -130,7 +130,7 @@ test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
 test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 # should not show an active lv
-not dmsetup table $vg-$lv1
+not dmsetup info $vg-$lv1
 
 vgchange -ay $vg
 
@@ -247,7 +247,7 @@ grep "$dev3" out
 not vgchange -ay $vg
 
 # should not show an active lv
-not dmsetup table $vg-$lv1
+not dmsetup info $vg-$lv1
 
 # should not allow updating vg
 not lvcreate -l1 $vg
@@ -261,7 +261,7 @@ test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
 test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 # should not show an active lv
-not dmsetup table $vg-$lv1
+not dmsetup info $vg-$lv1
 
 # start the md dev
 mdadm --assemble "$mddev" "$dev1" "$dev2"
@@ -285,7 +285,7 @@ test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
 test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 # should not show an active lv
-not dmsetup table $vg-$lv1
+not dmsetup info $vg-$lv1
 
 vgchange -ay $vg
 



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Feb 2015 10:05:51 +0000 (UTC)
Subject: master - tests: ensure lv1 goes away first
Message-ID: <20150217100551.0D9E760F15@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=120e1aa4bd13a8b2f49b7d6660f83b0277190774
Commit:        120e1aa4bd13a8b2f49b7d6660f83b0277190774
Parent:        6b4066585f73df7328ea16f6cb3713cd49cf2d2d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 16 10:53:22 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 17 11:05:04 2015 +0100

tests: ensure lv1 goes away first

$lv1 may appear in the table after -pvmove0 which could make -pvmove0
unremovable.
---
 test/shell/pvmove-restart.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 3c4947d..98ff6b4 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -29,8 +29,6 @@ lvextend -l+10 $vg/$lv1 "$dev2"
 # Slowdown writes
 aux delay_dev "$dev3" 0 100
 
-lvs -o+devices $vg
-
 pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" &
 PVMOVE=$!
 # Let's wait a bit till pvmove starts and kill it
@@ -39,8 +37,10 @@ kill -9 $PVMOVE
 wait
 
 # Simulate reboot - forcibly remove related devices
-dmsetup table
-dmsetup ls --exec echo | egrep "$vg-$lv1|$vg-pvmove0" | xargs -r -n 1 dmsetup remove
+
+# First take down $lv1 then it's pvmove0
+dmsetup ls --exec echo | grep "${vg}-$lv1" | xargs -r dmsetup remove
+dmsetup ls --exec echo | grep "${vg}-pvmove0" | xargs -r dmsetup remove
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"



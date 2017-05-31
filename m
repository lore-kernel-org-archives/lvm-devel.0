From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 31 May 2017 08:01:58 -0400
Subject: master - tests: longer delay
Message-ID: <201705311201.v4VC1w1q028671@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=743ffb1962ef272e5023c1ac652c5bcde86ff5fd
Commit:        743ffb1962ef272e5023c1ac652c5bcde86ff5fd
Parent:        42b87c23e2e5745eba0f66328319b541303db3aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 31 13:58:19 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 31 13:59:42 2017 +0200

tests: longer delay

Slower sync a bit more and use bigger raid arrays to
be more sure we will catch raid being sychronized.
---
 test/shell/lvcreate-raid-nosync.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index 1f01f47..bd7ec81 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -35,7 +35,7 @@ _sync() {
 
 # Delay 1st leg so that rebuilding status characters
 #  can be read before resync finished too quick.
-aux delay_dev "$dev1" 0 90 $(get first_extent_sector "$dev1")
+aux delay_dev "$dev1" 0 100 $(get first_extent_sector "$dev1")
 
 # raid0/raid0_meta don't support resynchronization
 for r in raid0 raid0_meta
@@ -58,7 +58,7 @@ lvremove --yes $vg/$lv1
 for r in $segtypes
 do
 	# raid4/5 support resynchronization
-	lvcreate --type $r -Zn -i 3 -l 4 -n $lv1 $vg
+	lvcreate --type $r -Zn -i 3 -L10 -n $lv1 $vg
 	check raid_leg_status $vg $lv1 "aaaa"
 	_sync "AAAA"
 
@@ -77,7 +77,7 @@ _sync "AAAAA"
 not lvcreate --type raid6 --nosync -Zn -i 3 -l 1 -n $lv1 $vg
 
 # raid10 supports resynchronization
-lvcreate --type raid10 -m 1 -Zn -i 3 -l 4 -n $lv1 $vg
+lvcreate --type raid10 -m 1 -Zn -i 3 -L10 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "aaaaaa"
 _sync "AAAAAA"
 



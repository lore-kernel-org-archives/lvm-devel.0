From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Mar 2021 00:00:47 +0000 (GMT)
Subject: main - tests: workaround for some raid targets
Message-ID: <20210317000047.04A2D385481A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e793ff1e185acfdbbbedb85a420d48527cd57c90
Commit:        e793ff1e185acfdbbbedb85a420d48527cd57c90
Parent:        db37905d7f59ac0057f6d50c34d8b1095c64d50f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 16 22:53:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:59:50 2021 +0100

tests: workaround for some raid targets

Problem with some target is that shortly after initialization it
returns incorrect status letters.
---
 test/shell/lvcreate-raid-nosync.sh | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index dcc248e0c..05ab848a1 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -33,6 +33,21 @@ _sync() {
 	aux restore_from_devtable "$dev1"
 }
 
+# Workaround for raid targets returning 'a' shortly after initialization
+# TODO: maybe there is some workaround to be made on lvm side
+_check_raid_in_loop() {
+	local vg=$1
+	local lv=$2
+	local A=$3
+	local B=$(echo $A | tr A a)
+	for i in {1..10} ; do
+		check raid_leg_status $vg $lv ${A} && return 0
+		# Only when there is initial 'a..a' we will wait for a while
+		check raid_leg_status $vg $lv ${B} || break
+		sleep .05
+	done
+	die "Cannot get $A status for $vg/$lv";
+}
 
 # Delay 1st leg so that rebuilding status characters
 #  can be read before resync finished too quick.
@@ -42,7 +57,7 @@ aux delay_dev "$dev1" 0 100 "$(get first_extent_sector "$dev1")"
 for r in raid0 raid0_meta
 do
 	lvcreate --type $r -Zn -i 3 -l 1 -n $lv1 $vg
-	check raid_leg_status $vg $lv1 "AAA"
+	_check_raid_in_loop $vg $lv1 "AAA"
 	lvremove --yes $vg/$lv1
 done
 
@@ -53,7 +68,7 @@ _sync "AAA"
 
 # raid1 supports --nosync
 lvcreate --type raid1 --nosync -Zn -m 2 -l 1 -n $lv1 $vg
-check raid_leg_status $vg $lv1 "AAA"
+_check_raid_in_loop $vg $lv1 "AAA"
 lvremove --yes $vg/$lv1
 
 for r in $segtypes
@@ -65,7 +80,7 @@ do
 
 	# raid4/5 support --nosync
 	lvcreate --type $r -Zn --nosync -i 3 -l 1 -n $lv2 $vg
-	check raid_leg_status $vg $lv2 "AAAA"
+	_check_raid_in_loop $vg $lv2 "AAAA"
 	lvremove --yes $vg
 done
 
@@ -84,6 +99,6 @@ _sync "AAAAAA"
 
 # raid10 supports --nosync
 lvcreate --type raid10 --nosync -m 1 -Zn -i 3 -l 1 -n $lv1 $vg
-check raid_leg_status $vg $lv1 "AAAAAA"
+_check_raid_in_loop $vg $lv1 "AAAAAA"
 
 vgremove -ff $vg



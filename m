From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:50 +0000 (GMT)
Subject: dev-next - tests: use mirror throttling
Message-ID: <20210322153950.B94D9385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6bc11bf724be4ebfd87dc60a172da2b0e4df8d9
Commit:        d6bc11bf724be4ebfd87dc60a172da2b0e4df8d9
Parent:        2dd43a7314ba72b0b899e161261ef5caacbade05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 20 10:14:09 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 10:52:24 2021 +0100

tests: use mirror throttling

With small mirrors its better to throttle speed of mirror in dm-mirror.
---
 test/shell/pvmove-resume-1.sh        | 5 +++--
 test/shell/pvmove-resume-multiseg.sh | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 6b4cbe529..7b9fc0f39 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -20,6 +20,7 @@ SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
+aux throttle_dm_mirror 50 || :
 aux prepare_pvs 4 30
 
 vgcreate -s 128k $vg "$dev1"
@@ -34,9 +35,9 @@ test_pvmove_resume() {
 	lvcreate -an -Zn -l30 -n $lv1 $vg
 	lvcreate -an -Zn -l30 -n $lv1 $vg1
 
-	aux delay_dev "$dev3" 0 1000 "$(get first_extent_sector "$dev3"):"
+	aux delay_dev "$dev3" 0 200 "$(get first_extent_sector "$dev3"):"
 	test -e HAVE_DM_DELAY || { lvremove -f $vg $vg1; return 0; }
-	aux delay_dev "$dev4" 0 1000 "$(get first_extent_sector "$dev4"):"
+	aux delay_dev "$dev4" 0 200 "$(get first_extent_sector "$dev4"):"
 
 	pvmove -i5 "$dev1" &
 	PVMOVE=$!
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 3a92dbaf3..c94706ed1 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -20,6 +20,7 @@ SKIP_WITH_LVMLOCKD=1
 . lib/inittest
 
 aux prepare_pvs 5 30
+aux throttle_dm_mirror 50 || :
 
 vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
 pvcreate --metadatacopies 0 "$dev4" "$dev5"
@@ -33,9 +34,9 @@ test_pvmove_resume() {
 	# next LV on same VG and differetnt PV (we want to test 2 pvmoves per VG)
 	lvcreate -an -Zn -l30 -n $lv2 $vg "$dev3"
 
-	aux delay_dev "$dev4" 0 500 "$(get first_extent_sector "$dev4"):"
+	aux delay_dev "$dev4" 0 200 "$(get first_extent_sector "$dev4"):"
 	test -e HAVE_DM_DELAY || { lvremove -f $vg; return 0; }
-	aux delay_dev "$dev5" 0 500 "$(get first_extent_sector "$dev5"):"
+	aux delay_dev "$dev5" 0 200 "$(get first_extent_sector "$dev5"):"
 
 	pvmove -i5 "$dev1" "$dev4" &
 	PVMOVE=$!



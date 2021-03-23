From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Mar 2021 10:37:16 +0000 (GMT)
Subject: main - tests: try to move more date
Message-ID: <20210323103716.51C3E385BF9E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0b2a037c800c3b8d20ea4d233cd2642611a2d136
Commit:        0b2a037c800c3b8d20ea4d233cd2642611a2d136
Parent:        e8b4306eb018a4a4fc8d7a68780563e929180367
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 10:53:02 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 10:53:02 2021 +0100

tests: try to move more date

Throttling was not helping with race - try to use more data.
---
 test/shell/pvmove-resume-multiseg.sh | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 5a32bc607..b38195a84 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -19,8 +19,8 @@ SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
-aux prepare_pvs 5 30
-aux throttle_dm_mirror || :
+aux prepare_pvs 5 40
+aux throttle_dm_mirror 50 || :
 
 vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
 pvcreate --metadatacopies 0 "$dev4" "$dev5"
@@ -29,10 +29,10 @@ vgextend $vg "$dev4" "$dev5"
 # $1 resume fn
 test_pvmove_resume() {
 	# Create multisegment LV
-	lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
-	lvextend -l+30 $vg/$lv1 "$dev2"
+	lvcreate -an -Zn -l50 -n $lv1 $vg "$dev1"
+	lvextend -l+50 $vg/$lv1 "$dev2"
 	# next LV on same VG and differetnt PV (we want to test 2 pvmoves per VG)
-	lvcreate -an -Zn -l30 -n $lv2 $vg "$dev3"
+	lvcreate -an -Zn -l50 -n $lv2 $vg "$dev3"
 
 	aux delay_dev "$dev4" 0 200 "$(get first_extent_sector "$dev4"):"
 	test -e HAVE_DM_DELAY || { lvremove -f $vg; return 0; }



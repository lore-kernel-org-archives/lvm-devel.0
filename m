From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:41 +0000 (GMT)
Subject: dev-next - tests: reoder killing order
Message-ID: <20210331214941.DDDB53858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ec7992e29fdf3273673f712d6a9f231903b6bf2
Commit:        5ec7992e29fdf3273673f712d6a9f231903b6bf2
Parent:        feb7fef6c8d22d5773b6a5d1d9f2a5a3f52b5b3b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 27 22:33:37 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 27 23:19:08 2021 +0100

tests: reoder killing order

We need to stop pvmove while still in progress,
so restart lvmpolld after pvmoving devices are gone
---
 test/shell/pvmove-resume-multiseg.sh | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 1263d81ed..cdb426b66 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -20,7 +20,7 @@ SKIP_WITH_LVMLOCKD=1
 . lib/inittest
 
 aux prepare_pvs 5 40
-aux throttle_dm_mirror 40 || :
+aux throttle_dm_mirror 60 || :
 
 vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
 pvcreate --metadatacopies 0 "$dev4" "$dev5"
@@ -48,17 +48,17 @@ test_pvmove_resume() {
 	aux wait_pvmove_lv_ready "$vg-pvmove1" 300
 	kill -9 $PVMOVE
 
+	while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
+	while dmsetup status "$vg-$lv2"; do dmsetup remove "$vg-$lv2" || true; done
+	while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
+	while dmsetup status "$vg-pvmove1"; do dmsetup remove "$vg-pvmove1" || true; done
+
 	if test -e LOCAL_LVMPOLLD ; then
 		aux prepare_lvmpolld
 	fi
 
 	wait
 
-	while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
-	while dmsetup status "$vg-$lv2"; do dmsetup remove "$vg-$lv2" || true; done
-	while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
-	while dmsetup status "$vg-pvmove1"; do dmsetup remove "$vg-pvmove1" || true; done
-
 	check lv_attr_bit type $vg/pvmove0 "p"
 	check lv_attr_bit type $vg/pvmove1 "p"
 



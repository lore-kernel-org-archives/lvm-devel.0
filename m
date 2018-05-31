From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:15:44 -0400
Subject: master - tests: enable pvmove-restart with lvmlockd
Message-ID: <201805311415.w4VEFiVQ031392@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27495a355536360404c8b8ee254ccaebb054debc
Commit:        27495a355536360404c8b8ee254ccaebb054debc
Parent:        05ee83579be1f7aa1107de438762d039e0424edf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 30 13:56:06 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 13:56:06 2018 -0500

tests: enable pvmove-restart with lvmlockd

---
 test/shell/pvmove-restart.sh |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index abdcd86..dcf4c37 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -12,13 +12,11 @@
 
 # Check pvmove behavior when it's progress and machine is rebooted
 
-SKIP_WITH_LVMLOCKD=1
-
 . lib/inittest
 
 aux prepare_pvs 3 60
 
-vgcreate -s 128k $vg "$dev1" "$dev2"
+vgcreate $SHARED -s 128k $vg "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"
 
@@ -94,7 +92,7 @@ LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10
 aux wait_pvmove_lv_ready "$vg-pvmove0"
 dmsetup table
 
-pvmove --abort
+pvmove --abort "$dev1"
 
 lvs -a -o+devices $vg
 



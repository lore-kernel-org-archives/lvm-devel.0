From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 3 Jun 2019 11:06:05 -0400
Subject: master - test: Increase latency in pvmove-resume-multiseg
Message-ID: <201906031506.x53F65QX004613@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=669a834981c0bc808d42dbe5097d7beeead982ad
Commit:        669a834981c0bc808d42dbe5097d7beeead982ad
Parent:        a9907bef9980dfe953a812e52760c174472ad0a6
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Jun 3 16:57:49 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Jun 3 16:57:49 2019 +0200

test: Increase latency in pvmove-resume-multiseg

The test was failing consistently on some VMs (F25), and inconsistently
on Rawhide.

With increased latency these failures are no longer reproducible.

Reproducer:

    make check_lvmpolld T=pvmove-resume-multiseg.sh
---
 test/shell/pvmove-resume-multiseg.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 89c2f74..a8e409f 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -33,9 +33,9 @@ test_pvmove_resume() {
 	# next LV on same VG and differetnt PV (we want to test 2 pvmoves per VG)
 	lvcreate -an -Zn -l30 -n $lv2 $vg "$dev3"
 
-	aux delay_dev "$dev4" 0 250 "$(get first_extent_sector "$dev4"):"
+	aux delay_dev "$dev4" 0 500 "$(get first_extent_sector "$dev4"):"
 	test -e HAVE_DM_DELAY || { lvremove -f $vg; return 0; }
-	aux delay_dev "$dev5" 0 250 "$(get first_extent_sector "$dev5"):"
+	aux delay_dev "$dev5" 0 500 "$(get first_extent_sector "$dev5"):"
 
 	pvmove -i5 "$dev1" "$dev4" &
 	PVMOVE=$!



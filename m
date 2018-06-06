From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Jun 2018 17:37:05 -0400
Subject: master - tests: remove -cn option from some commands
Message-ID: <201806062137.w56Lb5bT022737@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=802382e21ff600307f7c16f4651966d9a7c21252
Commit:        802382e21ff600307f7c16f4651966d9a7c21252
Parent:        b7da704566a6542c86cc1fcc186a66aa016b6802
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 6 14:04:19 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 6 14:04:19 2018 -0500

tests: remove -cn option from some commands

---
 test/shell/vgcfgbackup-lvm1.sh |    2 +-
 test/shell/vgchange-usage.sh   |    8 ++++----
 test/shell/vgsplit-usage.sh    |    6 +++---
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/test/shell/vgcfgbackup-lvm1.sh b/test/shell/vgcfgbackup-lvm1.sh
index a148ec1..9b81e28 100644
--- a/test/shell/vgcfgbackup-lvm1.sh
+++ b/test/shell/vgcfgbackup-lvm1.sh
@@ -28,7 +28,7 @@ aux lvmconf "backup/backup = 0"
 # vgcfgbackup correctly stores metadata LVM1 with missing PVs
 
 pvcreate -M1 "${DEVICES[@]}"
-vgcreate $SHARED -M1 -c n "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -M1 "$vg" "${DEVICES[@]}"
 lvcreate -l1 -n $lv1 $vg "$dev1"
 pvremove -ff -y "$dev2"
 not lvcreate -l1 -n $lv1 $vg "$dev3"
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 1885a64..9fe9bc5 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -101,7 +101,7 @@ vgremove -ff $vg
 test -n "$LVM_TEST_LVMLOCKD" && exit 0
 
 # set cluster bit
-vgcreate -cn $vg "$dev1" "$dev2" "$dev3"
+vgcreate $vg "$dev1" "$dev2" "$dev3"
 # check prompt to change cluster bit without giving explicit vg name
 fail vgchange -cy 2>&1 | tee out
 grep "y/n" out
@@ -121,10 +121,10 @@ if test -e LOCAL_CLVMD ; then
 	# check we do not support conversion of just locally active LVs
 	lvchange -an $vg
 	lvchange -ay $vg
-	not vgchange -cn $vg
+	not vgchange $vg
 	lvchange -an $vg
 	lvchange -aey $vg
-	vgchange -cn $vg
+	vgchange $vg
 else
 	# no clvmd is running
 	fail vgchange -cy $vg
@@ -136,7 +136,7 @@ else
 	vgs --ignoreskippedcluster $vg 2>&1 | tee out
 	not grep "Skipping clustered volume group" out
 	# reset back to non-clustered VG with disabled locking
-	vgchange -cn $vg --config 'global{locking_type=0}' $vg
+	vgchange $vg --config 'global{locking_type=0}' $vg
 fi
 check vg_attr_bit cluster $vg "-"
 
diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index a112e86..38f3964 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -96,9 +96,9 @@ grep "Volume group \"$vg2\" exists, but new VG option specified" err
 vgremove $vg1 $vg2
 
 # vgsplit rejects split because clustered given with existing vg
-vgcreate -M$mdatype --clustered n $vg1 "$dev1" "$dev2"
-vgcreate -M$mdatype --clustered n $vg2 "$dev3" "$dev4"
-not vgsplit --clustered n $vg1 $vg2 "$dev1" 2>err
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+vgcreate -M$mdatype $vg2 "$dev3" "$dev4"
+not vgsplit $vg1 $vg2 "$dev1" 2>err
 grep "Volume group \"$vg2\" exists, but new VG option specified" err
 vgremove $vg1 $vg2
 



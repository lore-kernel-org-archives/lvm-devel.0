From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jun 2014 15:54:33 +0000 (UTC)
Subject: master - tests: add get_devs function
Message-ID: <20140605155433.185EB6025E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9196942312cadea3cd4bf850442d556b07ad88d4
Commit:        9196942312cadea3cd4bf850442d556b07ad88d4
Parent:        223bdc5eb2fe69c43e0138bf097c33f1fa83d536
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 4 13:55:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 17:49:34 2014 +0200

tests: add get_devs function

Instead of rereading device list via cat - keep
the list in bash array. (Also solves problem
with spaces in device path)

Move usage of  "$path" out of lvm shell usage,
since we don't support such thing there...
---
 test/lib/utils.sh      |    8 ++++++++
 test/shell/listings.sh |   31 +++++++++++++++----------------
 2 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index b2e82aa..f28b37b 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -186,6 +186,14 @@ kernel_at_least() {
 	test "$minor2" -ge "$3" 2>/dev/null || return 1
 }
 
+get_devs() {
+	local IFS=$IFS_NL
+	DEVICES=( $(<DEVICES) )
+	export DEVICES
+#	local DEVS=( $(<DEVICES) )
+#	eval "$1"'=("${DEVS[@]}")'
+}
+
 prepare_test_vars() {
 	vg="${PREFIX}vg"
 	lv=LV
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 7069707..d916a41 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -16,6 +16,7 @@
 . lib/test
 
 aux prepare_devs 5
+get_devs
 
 # Check there is no PV
 pvscan | tee out
@@ -28,21 +29,22 @@ pvcreate "$dev4"
 pvcreate --metadatacopies 0 "$dev5"
 
 #COMM bz195276 -- pvs doesn't show PVs until a VG is created
-test $(pvs --noheadings $(cat DEVICES) | wc -l) -eq 5
+pvs --noheadings "${DEVICES[@]}"
+test $(pvs --noheadings "${DEVICES[@]}" | wc -l) -eq 5
 pvdisplay
 
 #COMM pvs with segment attributes works even for orphans
-test $(pvs --noheadings -o seg_all,pv_all,lv_all,vg_all $(cat DEVICES) | wc -l) -eq 5
+test $(pvs --noheadings -o seg_all,pv_all,lv_all,vg_all "${DEVICES[@]}" | wc -l) -eq 5
 
-vgcreate $vg $(cat DEVICES)
+vgcreate $vg "${DEVICES[@]}"
 
 check pv_field "$dev1" pv_uuid BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE
 
 #COMM pvs and vgs report mda_count, mda_free (bz202886, bz247444)
-pvs -o +pv_mda_count,pv_mda_free $(cat DEVICES)
+pvs -o +pv_mda_count,pv_mda_free "${DEVICES[@]}"
 for I in "$dev2" "$dev3" "$dev5"; do
-	check pv_field $I pv_mda_count 0
-	check pv_field $I pv_mda_free 0
+	check pv_field "$I" pv_mda_count 0
+	check pv_field "$I" pv_mda_free 0
 done
 vgs -o +vg_mda_count,vg_mda_free $vg
 check vg_field $vg vg_mda_count 2
@@ -64,7 +66,7 @@ lvremove -f $vg/$lv2
 lvcreate -aey -l2 --type mirror -m2 -n $lv3 $vg
 test $(lvs --noheadings $vg | wc -l) -eq 2
 test $(lvs -a --noheadings $vg | wc -l) -eq 6
-dmsetup ls|grep "$PREFIX"|grep -v "LVMTEST.*pv."
+dmsetup ls | grep "$PREFIX" | grep -v "LVMTEST.*pv."
 
 lvcreate -l2 -s $vg/$lv3
 lvcreate -l1 -s -n inval $vg/$lv3
@@ -81,8 +83,8 @@ vgs -o pv_name,vg_name $vg
 vgs -o all $vg
 
 #COMM pvdisplay --maps feature (bz149814)
-pvdisplay $(cat DEVICES) >out
-pvdisplay --maps $(cat DEVICES) >out2
+pvdisplay "${DEVICES[@]}" >out
+pvdisplay --maps "${DEVICES[@]}" >out2
 not diff out out2
 
 aux disable_dev "$dev1"
@@ -108,8 +110,6 @@ invalid lvscan $vg
 
 if aux have_readline; then
 cat <<EOF | lvm
-pvdisplay -c "$dev1"
-pvdisplay -s "$dev1"
 vgdisplay --units k $vg
 vgdisplay -c $vg
 vgdisplay -C $vg
@@ -120,10 +120,6 @@ lvdisplay -C $vg
 lvdisplay -m $vg
 lvdisplay --units g $vg
 EOF
-
-for i in h b s k m g t p e H B S K M G T P E; do
-	echo pvdisplay --units $i "$dev1"
-done | lvm
 else
 pvdisplay -c "$dev1"
 pvdisplay -s "$dev1"
@@ -136,11 +132,14 @@ lvdisplay -c $vg
 lvdisplay -C $vg
 lvdisplay -m $vg
 lvdisplay --units g $vg
+fi
+
+pvdisplay -c "$dev1"
+pvdisplay -s "$dev1"
 
 for i in h b s k m g t p e H B S K M G T P E; do
 	pvdisplay --units $i "$dev1"
 done
-fi
 
 invalid lvdisplay -C -m $vg
 invalid lvdisplay -c -m $vg



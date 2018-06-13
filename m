From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Jun 2018 15:33:30 -0400
Subject: master - tests: remove vgconvert usage
Message-ID: <201806131933.w5DJXUxS017080@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a163d5341a90c1c2f656b0d15c055bbd90333a60
Commit:        a163d5341a90c1c2f656b0d15c055bbd90333a60
Parent:        d067263f51f782661d6faa00b106b872b3e1dc6f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 13 14:16:28 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 13 14:16:28 2018 -0500

tests: remove vgconvert usage

---
 test/shell/metadata.sh       |   38 --------------------------------------
 test/shell/pvcreate-usage.sh |   19 -------------------
 2 files changed, 0 insertions(+), 57 deletions(-)

diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index aae749a..a86bc0b 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -46,41 +46,3 @@ for mdacp in 1 0; do
 	vgremove -f $vg
 done
 not grep "Cached VG .* incorrect PV list" out0
-
-# begin M1 metadata tests
-if test -n "$LVM_TEST_LVM1" ; then
-
-pvcreate -M1 "$dev1" "$dev2" "$dev3"
-pv3_uuid=$(get pv_field "$dev3" pv_uuid)
-vgcreate $SHARED -M1 $vg "$dev1" "$dev2" "$dev3"
-pvchange --uuid "$dev1"
-
-# verify pe_start of all M1 PVs
-pv_align="128.00k"
-check pv_field "$dev1" pe_start $pv_align
-check pv_field "$dev2" pe_start $pv_align
-check pv_field "$dev3" pe_start $pv_align
-
-pvs --units k -o name,pe_start,vg_mda_size,vg_name "${DEVICES[@]}"
-
-# upgrade from v1 to v2 metadata
-vgconvert -M2 $vg
-
-# verify pe_start of all M2 PVs
-check pv_field "$dev1" pe_start $pv_align
-check pv_field "$dev2" pe_start $pv_align
-check pv_field "$dev3" pe_start $pv_align
-
-pvs --units k -o name,pe_start,vg_mda_size,vg_name "${DEVICES[@]}"
-
-# create backup and then restore $dev3
-vgcfgbackup -f "$TESTDIR/bak-%s" "$vg"
-pvcreate -ff -y --restorefile "$TESTDIR/bak-$vg" --uuid "$pv3_uuid" "$dev3"
-vgcfgrestore -f "$TESTDIR/bak-$vg" "$vg"
-
-# verify pe_start of $dev3
-check pv_field "$dev3" pe_start $pv_align
-
-fi
-# end M1 metadata tests
-
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 4ece05f..0a6f1ea 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -143,25 +143,6 @@ pvcreate --metadatasize 128k --metadatacopies 2 --dataalignmentoffset 7s "$dev1"
 check pv_field "$dev1" pv_mda_count 2
 # FIXME: compare start of 2nd mda with and without --dataalignmentoffset
 
-#COMM 'pv with LVM1 compatible data alignment can be convereted'
-#compatible == LVM1_PE_ALIGN == 64k
-if test -n "$LVM_TEST_LVM1" ; then
-pvcreate --dataalignment 256k "$dev1"
-vgcreate $SHARED -s 1m $vg "$dev1"
-vgconvert -M1 $vg
-vgconvert -M2 $vg
-check pv_field "$dev1" pe_start 256.00k
-vgremove $vg
-fi
-
-#COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
-if test -n "$LVM_TEST_LVM1" ; then
-pvcreate --dataalignment 10k "$dev1"
-vgcreate $SHARED -s 1m $vg "$dev1"
-not vgconvert -M1 $vg
-vgremove $vg
-fi
-
 #COMM 'vgcfgrestore allows pe_start=0'
 #basically it produces nonsense, but it tests vgcfgrestore,
 #not that final cfg is usable...



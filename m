From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:25 +0000 (GMT)
Subject: main - tests: add test for merging
Message-ID: <20210315101425.3858F3858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4a74d1008e114d5976a235b3a6f793181bc5745
Commit:        b4a74d1008e114d5976a235b3a6f793181bc5745
Parent:        800a93d4ac78e2736c43cb2cf8099cf68b68b341
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 14 22:48:20 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

tests: add test for merging

Check we handle mething of thin snapshot that is itself thick snapshot
origin.
Also use  lvpoll to better wait for finish of merging.
---
 test/shell/snapshot-merge-thin.sh | 35 ++++++++++++++++++++++++++++++++---
 1 file changed, 32 insertions(+), 3 deletions(-)

diff --git a/test/shell/snapshot-merge-thin.sh b/test/shell/snapshot-merge-thin.sh
index 26fae904d..447a93167 100644
--- a/test/shell/snapshot-merge-thin.sh
+++ b/test/shell/snapshot-merge-thin.sh
@@ -21,21 +21,50 @@ aux have_thin 1 0 0 || skip
 
 aux prepare_vg 2
 
+lvcreate -T -L1 -V1 -n $lv1 $vg/pool "$dev1"
+lvcreate -s -n $lv2 $vg/$lv1
+
+# Take also thick snapshot of thin snapshot
+lvcreate -s -L1 -n $lv3 $vg/$lv2
+
+sleep 10 < "$DM_DEV_DIR/$vg/$lv1" >/dev/null 2>&1 &
+PID_SLEEP=$!
+
+# initiated merge that cannot proceed, but there is no need to retry
+lvconvert --config 'activation/retry_deactivation=0' --merge $vg/$lv2
+
+kill $PID_SLEEP
+wait
+
+# Remove everything
+lvremove --yes $vg
+
+# No LV left in VG
+check  vg_field $vg  lv_count "0"
+
+
+# Create again pool with thin and thick snapshot
 lvcreate -T -L1 -V1 -n $lv1 $vg/pool "$dev1"
 lvcreate -s -n $lv2 -L2 $vg/$lv1 "$dev2"
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1 oflag=direct
 
+lvs -a -o+lv_merging,lv_merge_failed $vg
+aux delay_dev "$dev1" 0 100 "$(get first_extent_sector "$dev1"):"
+
 # Initiate background merge
 lvconvert -b --merge $vg/$lv2
 
 # Query status of snapshot immediatelly after start
 # - may hit race of checking already in-progress merge
-lvs -a -o+lv_merging,lv_merge_failed $vg
+#lvs -a -o+lv_merging,lv_merge_failed $vg
+check lv_field $vg/$lv1 lv_merging "merging"
 
-sleep 1
+lvm lvpoll -i 1 --polloperation merge $vg/$lv1
 
 # Here should be everything already merged
-lvs -a -o+lv_merging,lv_merge_failed $vg
+#lvs -a -o+lv_merging,lv_merge_failed $vg
+# check we see thin filled 100%  (1MiB written to 1MiB LV)
+check lv_field $vg/$lv1 data_percent "100.00"
 
 # -real must not exist for  $vg/$lv1
 not dmsetup info ${vg}-${lv1}-real 2>&1 | tee out



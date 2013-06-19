From: Petr Rockai <prockai@redhat.com>
Date: Wed, 19 Jun 2013 11:24:35 +0200
Subject: [PATCH 5/9] test: Fix fallout from pv_read changes.
In-Reply-To: <1371633879-8879-1-git-send-email-prockai@redhat.com>
References: <1371633879-8879-1-git-send-email-prockai@redhat.com>
Message-ID: <1371633879-8879-5-git-send-email-prockai@redhat.com>
	(sfid-20130619_112441_564586_698D5CAA)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 test/shell/pv-duplicate.sh          |  2 +-
 test/shell/pvcreate-operation-md.sh | 35 +++++++++++++++++++++--------------
 2 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/test/shell/pv-duplicate.sh b/test/shell/pv-duplicate.sh
index 6b9f309..40d1f68 100644
--- a/test/shell/pv-duplicate.sh
+++ b/test/shell/pv-duplicate.sh
@@ -21,5 +21,5 @@ vgcreate --metadatasize 128k $vg1 "$dev1"
 dd if="$dev1" of="$dev2" bs=256K count=1
 dd if="$dev1" of="$dev3" bs=256K count=1
 
-pvs "$dev1"
+pvs "$dev3"
 vgs $vg1
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 5e2a28d..9cad745 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -58,21 +58,24 @@ test -b "$mddev" && skip
 mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
 trap 'cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
 test -b "$mddev" || skip
+cp -LR "$mddev" "$DM_DEV_DIR" # so that LVM/DM can see the device
+lvmdev="$DM_DEV_DIR/md_lvm_test0"
 
 # Test alignment of PV on MD without any MD-aware or topology-aware detection
 # - should treat $mddev just like any other block device
 pv_align="1.00m"
 pvcreate --metadatasize 128k \
     --config 'devices {md_chunk_alignment=0 data_alignment_detection=0 data_alignment_offset_detection=0}' \
-    "$mddev"
-check pv_field "$mddev" pe_start $pv_align
+    "$lvmdev"
+
+check pv_field "$lvmdev" pe_start $pv_align
 
 # Test md_chunk_alignment independent of topology-aware detection
 pv_align="1.00m"
 pvcreate --metadatasize 128k \
     --config 'devices {data_alignment_detection=0 data_alignment_offset_detection=0}' \
-    "$mddev"
-check pv_field "$mddev" pe_start $pv_align
+    "$lvmdev"
+check pv_field "$lvmdev" pe_start $pv_align
 
 
 # Test newer topology-aware alignment detection
@@ -81,8 +84,8 @@ if kernel_at_least 2 6 33 ; then
     pv_align="1.00m"
     # optimal_io_size=131072, minimum_io_size=65536
     pvcreate --metadatasize 128k \
-	--config 'devices { md_chunk_alignment=0 }' "$mddev"
-    check pv_field "$mddev" pe_start $pv_align
+	--config 'devices { md_chunk_alignment=0 }' "$lvmdev"
+    check pv_field "$lvmdev" pe_start $pv_align
 fi
 
 # partition MD array directly, depends on blkext in Linux >= 2.6.28
@@ -91,9 +94,10 @@ if kernel_at_least 2 6 28 ; then
     sfdisk "$mddev" <<EOF
 ,,83
 EOF
+    pvscan
     # make sure partition on MD is _not_ removed
     # - tests partition -> parent lookup via sysfs paths
-    not pvcreate --metadatasize 128k "$mddev"
+    not pvcreate --metadatasize 128k "$lvmdev"
 
     # verify alignment_offset is accounted for in pe_start
     # - topology infrastructure is available in Linux >= 2.6.31
@@ -109,6 +113,8 @@ EOF
     # wait here for created device node on tmpfs
     aux udev_wait "$mddev_p"
     test -b "$mddev_p" || skip
+    cp -LR "$mddev_p" "$DM_DEV_DIR"
+    lvmdev_p="$DM_DEV_DIR/$base_mddev_p"
 
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
     # but reliable alignment_offset support requires kernel.org Linux >= 2.6.33
@@ -120,9 +126,9 @@ EOF
     if [ $alignment_offset -gt 0 ]; then
         # default alignment is 1M, add alignment_offset
 	pv_align=$((1048576+$alignment_offset))B
-	pvcreate --metadatasize 128k "$mddev_p"
-	check pv_field "$mddev_p" pe_start $pv_align --units b
-	pvremove "$mddev_p"
+	pvcreate --metadatasize 128k "$lvmdev_p"
+	check pv_field "$lvmdev_p" pe_start $pv_align --units b
+	pvremove "$lvmdev_p"
     fi
 fi
 
@@ -140,12 +146,13 @@ if kernel_at_least 2 6 33 ; then
     # optimal_io_size=2097152, minimum_io_size=1048576
     pv_align="2.00m"
     pvcreate --metadatasize 128k \
-	--config 'devices { md_chunk_alignment=0 }' "$mddev"
-    check pv_field "$mddev" pe_start $pv_align
+	--config 'devices { md_chunk_alignment=0 }' "$lvmdev"
+    pvscan # Something is seriously broken.
+    check pv_field "$lvmdev" pe_start $pv_align
 
     # now verify pe_start alignment override using --dataalignment
     pv_align="192.00k"
     pvcreate --dataalignment 64k --metadatasize 128k \
-	--config 'devices { md_chunk_alignment=0 }' "$mddev"
-    check pv_field "$mddev" pe_start $pv_align
+	--config 'devices { md_chunk_alignment=0 }' "$lvmdev"
+    check pv_field "$lvmdev" pe_start $pv_align
 fi
-- 
1.8.2



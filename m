From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Sep 2020 21:46:53 +0000 (GMT)
Subject: master - tests: use aux wrapper and add more notes
Message-ID: <20200922214653.D7C5839450F9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3869c9c4f630f33ef1b7e8c4e7e08968e6ef3c09
Commit:        3869c9c4f630f33ef1b7e8c4e7e08968e6ef3c09
Parent:        e280f56dd3fa1419c37c486ae651b000f26cfeca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 16:27:21 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 23:43:26 2020 +0200

tests: use aux wrapper and add more notes

This test seems to be hitting some corner case in handling
out-of-metadata space condintion in thin-pool.

Add few more aid notes and functionality.

Also add missing '|| true' with now direct-IO dd command.
---
 test/shell/thin-flags.sh | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index df139b211..91bcad12e 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -47,7 +47,7 @@ lvchange -an $vg
 
 # Overfill data area
 lvchange -ay $vg
-dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=1M count=2 oflag=direct
+dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=1M count=2 oflag=direct || true
 check lv_attr_bit health $vg/pool "D"
 # TODO use spaces ??
 check lv_field $vg/pool lv_health_status "out_of_data"
@@ -67,8 +67,15 @@ lvchange -an $vg
 aux lvmconf 'global/thin_check_executable = ""'
 
 # Prepare some fake metadata prefilled to ~100%
-lvcreate -L2 -n $lv1 $vg # tmp for metadata
-aux prepare_thin_metadata 490 1 | tee data
+lvcreate -L2 -n $lv1 $vg "$dev2" # tmp for metadata
+
+VOLS=490
+aux thin_restore_needs_more_volumes || VOLS=445
+aux prepare_thin_metadata $VOLS 1 | tee data
+
+# Note: we like want to test BOTH sizes (445 & 490) as ATM it gives
+# different errors (5.9-rc5 kernel does not handle it as expected by this test)
+
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata
@@ -78,13 +85,15 @@ lvchange -ay $vg
 
 lvchange -ay $vg/$lv2
 # Provisiong and last free bits in metadata
-dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=32K count=1 oflag=direct
+dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=1M count=1 oflag=direct || true
 
 check lv_attr_bit health $vg/pool "M"
 # TODO - use spaces ??
 check lv_field $vg/pool lv_health_status "metadata_read_only"
 check lv_attr_bit health $vg/$lv2 "-"
 
+lvs -ao+seg_pe_ranges $vg
+
 # needs_check needs newer version
 if aux have_thin 1 16 0 ; then
 	check lv_attr_bit state $vg/pool "c"



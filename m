From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:11 +0000 (GMT)
Subject: stable-2.02 - tests: use aux wrapper and add more notes
Message-ID: <20201016191211.84DD5396EC9D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d76b5f43083cd0667c3f55b5dd72edd134144a3d
Commit:        d76b5f43083cd0667c3f55b5dd72edd134144a3d
Parent:        de1b894337759c574f5e1cf11dcd40ef765d6ad2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 16:27:21 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

tests: use aux wrapper and add more notes

This test seems to be hitting some corner case in handling
out-of-metadata space condintion in thin-pool.

Add few more aid notes and functionality.

Also add missing '|| true' with now direct-IO dd command.
---
 test/shell/thin-flags.sh | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index df139b211..78a4b2cd7 100644
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
@@ -78,13 +85,18 @@ lvchange -ay $vg
 
 lvchange -ay $vg/$lv2
 # Provisiong and last free bits in metadata
-dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=32K count=1 oflag=direct
+dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=1M count=1 oflag=direct || true
 
 check lv_attr_bit health $vg/pool "M"
 # TODO - use spaces ??
 check lv_field $vg/pool lv_health_status "metadata_read_only"
 check lv_attr_bit health $vg/$lv2 "-"
 
+not lvcreate -s $vg/$lv2
+not lvcreate -V10 -n $lv3 $vg/pool
+
+lvs -ao+seg_pe_ranges $vg
+
 # needs_check needs newer version
 if aux have_thin 1 16 0 ; then
 	check lv_attr_bit state $vg/pool "c"



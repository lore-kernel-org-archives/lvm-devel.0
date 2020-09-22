From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Sep 2020 21:46:51 +0000 (GMT)
Subject: master - tests: update test
Message-ID: <20200922214651.96FE1385780B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=adead83dc2763a12f2f0e711793b5fd8c446b3f9
Commit:        adead83dc2763a12f2f0e711793b5fd8c446b3f9
Parent:        cbed63eeb9d06958a42721dcd2093ff80582f47d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 23:26:28 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 23:28:43 2020 +0200

tests: update test

Shorten running time of the test.
Fix some issues in invoked resizing script to it returns
correct return code and dmeventd can be a little bit quicker
in this test.
---
 test/shell/vdo-autoumount-dmeventd.sh | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/test/shell/vdo-autoumount-dmeventd.sh b/test/shell/vdo-autoumount-dmeventd.sh
index 0d0747a32..e0449ffe8 100644
--- a/test/shell/vdo-autoumount-dmeventd.sh
+++ b/test/shell/vdo-autoumount-dmeventd.sh
@@ -42,19 +42,21 @@ export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
 aux have_vdo 6 2 0 || skip
 
 # Simple implementation of umount when lvextend fails
+# Script enforces failin exit, so dmeventd tries several times
+# repeatedly to invoke this for given percentage
 cat <<- EOF >testcmd.sh
 #!/bin/sh
 
 echo "VDO Pool: \$DMEVENTD_VDO_POOL"
 
 "$TESTDIR/lib/lvextend" --use-policies \$1 || {
-	umount "$mntdir"  || true
-	return 0
+	umount "$mntdir" && exit 0
+	touch $PWD/TRIED_UMOUNT
 }
 test "\$($TESTDIR/lib/lvs -o selected -S "data_percent>=$PERCENT" --noheadings \$1)" -eq 0 || {
-	umount "$mntdir"  || true
-	return 0
+	echo "Percentage still above $PERCENT"
 }
+exit 1
 EOF
 chmod +x testcmd.sh
 # Show prepared script
@@ -63,7 +65,7 @@ cat testcmd.sh
 # Use autoextend percent 0 - so extension fails and triggers umount...
 aux lvmconf "activation/vdo_pool_autoextend_percent = 0" \
 	    "activation/vdo_pool_autoextend_threshold = $PERCENT" \
-	    "dmeventd/vdo_command = \"/$PWD/testcmd.sh\"" \
+	    "dmeventd/vdo_command = \"$PWD/testcmd.sh\"" \
             "allocation/vdo_slab_size_mb = 128"
 
 aux prepare_dmeventd
@@ -92,7 +94,7 @@ PID_SLEEP=$!
 
 lvs -a $vg
 # Fill pool above 95%  (to cause 'forced lazy umount)
-dd if=/dev/urandom of="$mntdir/file$$" bs=256K count=200 conv=fdatasync
+dd if=/dev/urandom of="$mntdir/file$$" bs=256K count=200 oflag=direct
 
 lvs -a $vg
 
@@ -100,9 +102,11 @@ lvs -a $vg
 # In the worst case check only happens every 10 seconds :(
 for i in $(seq 1 12) ; do
 	is_lv_opened_ "$vg/$lv1" || break
+	test ! -f "TRIED_UMOUNT" || continue  # finish loop quickly
 	sleep 1
 done
 
+rm -f "TRIED_UMOUNT"
 test "$i" -eq 12 || die "$mntdir should NOT have been unmounted by dmeventd!"
 
 lvs -a $vg
@@ -119,3 +123,5 @@ for i in $(seq 1 12) ; do
 	test "$i" -lt 12 || die "$mntdir should have been unmounted by dmeventd!"
 	sleep 1
 done
+
+# vgremove is managed through cleanup_mounted_and_teardown()



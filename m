From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Apr 2015 18:29:36 +0000 (UTC)
Subject: master - tests: fix md raid test on real /dev
Message-ID: <20150423182936.C33AE60FFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de0ce46361d65af7fb58699e4aba0b649551a6a8
Commit:        de0ce46361d65af7fb58699e4aba0b649551a6a8
Parent:        88534625282e8d533ae439ed308a285da10e3ef0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 23 20:26:19 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 23 20:28:44 2015 +0200

tests: fix md raid test on real /dev

Zero raid signatures when raid is stopped - so signatures
are not requiring wipe when pvcreate follows.

Handle real /dev
---
 test/shell/lvmetad-pvscan-md.sh     |   20 +++++++++++++-------
 test/shell/pvcreate-operation-md.sh |   16 +++++++++-------
 2 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
index 653d18a..ff86fdd 100644
--- a/test/shell/lvmetad-pvscan-md.sh
+++ b/test/shell/lvmetad-pvscan-md.sh
@@ -38,6 +38,8 @@ cleanup_md() {
     # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
     aux udev_wait
     mdadm --stop "$mddev" || true
+    # also remove singnatures
+    mdadm --zero-superblock "$dev1" "$dev2" || true
     aux udev_wait
     if [ -b "$mddev" ]; then
         # mdadm doesn't always cleanup the device node
@@ -53,25 +55,29 @@ cleanup_md_and_teardown() {
 
 # create 2 disk MD raid0 array (stripe_width=128K)
 test -b "$mddev" && skip
-mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
 trap 'cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
+mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
 test -b "$mddev" || skip
-cp -LR "$mddev" "$DM_DEV_DIR" # so that LVM/DM can see the device
-lvmdev="$DM_DEV_DIR/md_lvm_test0"
-
+if test "$DM_DEV_DIR" != "/dev" ; then
+	cp -LR "$mddev" "$DM_DEV_DIR" # so that LVM/DM can see the device
+	pvdev="$DM_DEV_DIR/md_lvm_test0"
+else
+	pvdev=$(readlink -f "$mddev")
+fi
 # TODO end MD-creation code
 
 # maj=$(($(stat -L --printf=0x%t "$dev2")))
 # min=$(($(stat -L --printf=0x%T "$dev2")))
 
-pvcreate $lvmdev
+pvcreate "$pvdev"
 
-pvscan --cache "$lvmdev"
+pvscan --cache "$pvdev"
 
 # ensure that lvmetad can only see the toplevel MD device
 pvscan --cache "$dev1" 2>&1 | grep "not found"
 pvscan --cache "$dev2" 2>&1 | grep "not found"
 
-pvs | grep $lvmdev
+pvs | tee out
+grep "$pvdev" out
 pvs | not grep "$dev1"
 pvs | not grep "$dev2"
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 87117d1..ec15c5d 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -40,6 +40,7 @@ cleanup_md() {
     # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
     aux udev_wait
     mdadm --stop "$mddev" || true
+    mdadm --zero-superblock "$dev1" "$dev2" || true
     aux udev_wait
     if [ -b "$mddev" ]; then
         # mdadm doesn't always cleanup the device node
@@ -55,10 +56,10 @@ cleanup_md_and_teardown() {
 
 # create 2 disk MD raid0 array (stripe_width=128K)
 test -b "$mddev" && skip
-mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
 trap 'cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
+mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
 test -b "$mddev" || skip
-cp -LR "$mddev" "$DM_DEV_DIR" # so that LVM/DM can see the device
+test "$DM_DEV_DIR" != "/dev" && cp -LR "$mddev" "$DM_DEV_DIR" # so that LVM/DM can see the device
 lvmdev="$DM_DEV_DIR/md_lvm_test0"
 
 # Test alignment of PV on MD without any MD-aware or topology-aware detection
@@ -113,7 +114,7 @@ EOF
     # wait here for created device node on tmpfs
     aux udev_wait "$mddev_p"
     test -b "$mddev_p" || skip
-    cp -LR "$mddev_p" "$DM_DEV_DIR"
+    test "$DM_DEV_DIR" != "/dev" && cp -LR "$mddev_p" "$DM_DEV_DIR"
     lvmdev_p="$DM_DEV_DIR/$base_mddev_p"
 
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
@@ -132,13 +133,14 @@ EOF
     fi
 fi
 
-# make sure we're clean for another test
-test -b "$mddev" && cleanup_md
-dd if=/dev/zero of="$dev1" bs=512 count=1
-dd if=/dev/zero of="$dev2" bs=512 count=1
 
 # Test newer topology-aware alignment detection w/ --dataalignment override
 if kernel_at_least 2 6 33 ; then
+    # make sure we're clean for another test
+    test -b "$mddev" && cleanup_md
+    dd if=/dev/zero of="$dev1" bs=512 count=1
+    dd if=/dev/zero of="$dev2" bs=512 count=1
+
     pvcreate -f "$dev1"
     pvcreate -f "$dev2"
 



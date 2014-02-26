From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Feb 2014 09:29:05 +0000 (UTC)
Subject: master - tests: improve read-only test for snapshot
Message-ID: <20140226092905.3EDF36019B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aef60160112832b2773b128e30668d4fe3dda707
Commit:        aef60160112832b2773b128e30668d4fe3dda707
Parent:        2b044452e30accf9ee026fc62ccea219bb4c7be4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 26 10:19:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 26 10:19:46 2014 +0100

tests: improve read-only test for snapshot

Switch to use ext2 to make it usable on older systems.
Previous test has not been able to catching problem.

Multiple tests are now put in.

FIXME: validate what is doing kernel target when
the header is undeleted and same chunk size is used.

It seems snapshot target successfully resumes and
just complains COW is not big enough:

kernel: dm-8: rw=0, want=40, limit=24
kernel: attempt to access beyond end of device

When chunk size is different it fails instantly.

For checking this with lvm2 and this test case use this patch:

--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -769,7 +769,7 @@ static int _read_activation_params(struct
lvcreate_params *lp,
        lp->permission = arg_uint_value(cmd, permission_ARG,
                                        LVM_READ | LVM_WRITE);

-       if (lp->snapshot) {
+       if (0 && lp->snapshot) {
                /* Snapshot has to zero COW header */
                lp->zero = 1;
                lp->wipe_signatures = 0;

---
and switch to use  -c 4 for both snapshots
---
 test/shell/snapshot-usage.sh |   39 ++++++++++++++++++++++++++++-----------
 1 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 62a70e0..bf78ac5 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -13,6 +13,9 @@
 
 . lib/test
 
+MKFS=mkfs.ext2
+which $MKFS || skip
+
 fill() {
 	dd if=/dev/zero of="$DM_DEV_DIR/$vg1/lvol0" bs=$1 count=1
 }
@@ -110,6 +113,31 @@ lvextend -l+33 $vg1/lvol1
 check lv_field $vg1/lvol1 size "28.00k"
 
 fill 20K
+lvremove -f $vg1
+
+# Check snapshot really deletes COW header for read-only snapshot
+# Test needs special relation between chunk size and extent size
+# This test expects extent size 1K
+aux lvmconf "allocation/wipe_signatures_when_zeroing_new_lvs = 1"
+lvcreate -aey -L4 -n $lv $vg1
+lvcreate -c 8 -s -L1 -n snap $vg1/$lv
+# Populate snapshot
+#dd if=/dev/urandom of="$DM_DEV_DIR/$vg1/$lv" bs=4096 count=10
+$MKFS "$DM_DEV_DIR/$vg1/$lv"
+lvremove -f $vg1/snap
+
+# Undeleted header would trigger attempt to access
+# beyond end of COW device
+# Fails to create when chunk size is different
+lvcreate -s -pr -l12 -n snap $vg1/$lv
+
+# When header is undelete, fails to read snapshot without read errors
+#dd if="$DM_DEV_DIR/$vg1/snap" of=/dev/null bs=1M count=2
+fsck -n "$DM_DEV_DIR/$vg1/snap"
+
+# This would trigger read of weird percentage for undeleted header
+check lv_field $vg1/snap data_percent "0.00"
+
 vgremove -ff $vg1
 
 # Can't test >= 16T devices on 32bit
@@ -131,15 +159,4 @@ vgremove -ff $vg1
 
 fi
 
-lvremove -f $vg
-
-# Check snapshot really deletes COW header for read-only snapshot
-aux lvmconf "allocation/wipe_signatures_when_zeroing_new_lvs = 1"
-lvcreate -L10 -n $lv1 $vg
-lvcreate -s -L10 -n snap $vg/$lv1
-# Populate snapshot with some filesystem signatures
-mkfs.ext4 "$DM_DEV_DIR/$vg/snap"
-lvremove -f $vg/snap
-lvcreate -s -pr -l12 -n snap $vg/$lv1
-
 vgremove -ff $vg



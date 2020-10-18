From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:33 +0000 (GMT)
Subject: stable-2.02 - tests: check pool metadata are zeroed
Message-ID: <20201018210233.D52123858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc5eb1d70f2b910a0b45b27cb82fced77f0a4047
Commit:        cc5eb1d70f2b910a0b45b27cb82fced77f0a4047
Parent:        a46fdf5426596db41b08530ea2a0d4c8d8895ad8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 24 14:42:11 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:28:13 2020 +0200

tests: check pool metadata are zeroed

---
 test/lib/aux.sh             |  1 +
 test/shell/lvcreate-thin.sh | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0ab4cabaf..728e6dc0e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1303,6 +1303,7 @@ activation/udev_sync = 1
 activation/verify_udev_operations = $LVM_VERIFY_UDEV
 activation/raid_region_size = 512
 allocation/wipe_signatures_when_zeroing_new_lvs = 0
+allocation/zero_metadata = 0
 backup/archive = 0
 backup/backup = 0
 devices/cache_dir = "$TESTDIR/etc"
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 8e04c9e64..7c91b3413 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -237,4 +237,25 @@ not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4
 not lvcreate -T mirpool -L4M --alloc anywhere -m1 $vg
 not lvcreate --thinpool mirpool -L4M --alloc anywhere -m1 $vg
 
+
+# Check pool metadata volume is zeroed, when zero_metadata is enabled.
+# 1st. ensure 8megs of both PVs will have some non-0 data
+lvcreate -L8m -n $lv1 $vg "$dev1"
+lvextend -L+8m $vg/$lv1 "$dev2"
+dd if=/dev/urandom of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=16 oflag=direct conv=fdatasync
+lvremove -ff $vg/$lv1
+
+lvcreate -l1 --poolmetadatasize 4m --conf 'allocation/zero_metadata=1' -vvvv -T $vg/pool
+lvchange -an $vg
+# component activation to check device was zeroed
+lvchange -y -ay $vg/pool_tmeta
+dd if="$DM_DEV_DIR/$vg/pool_tmeta" of=file bs=1M count=3 skip=1 iflag=direct conv=fdatasync
+
+md5sum -b file | tee out
+# md5sum of 3M of zeros
+grep d1dd210d6b1312cb342b56d02bd5e651 out
+lvchange -an $vg
+lvremove -ff $vg
+
+
 vgremove -ff $vg



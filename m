From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Jun 2020 13:02:50 +0000 (GMT)
Subject: master - tests: check pool metadata are zeroed
Message-ID: <20200624130250.A06CE3939C28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3f32f9811e01c8953d201c7c9b563561ad856130
Commit:        3f32f9811e01c8953d201c7c9b563561ad856130
Parent:        094d6f80ddb6d8a1c64977dfaae4073827063fe3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 24 14:42:11 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:01:03 2020 +0200

tests: check pool metadata are zeroed

---
 test/lib/aux.sh             |  1 +
 test/shell/lvcreate-thin.sh | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e40da9592..17e7935ee 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1234,6 +1234,7 @@ activation/verify_udev_operations = $LVM_VERIFY_UDEV
 activation/raid_region_size = 512
 allocation/wipe_signatures_when_zeroing_new_lvs = 0
 allocation/vdo_slab_size_mb = 128
+allocation/zero_metadata = 0
 backup/archive = 0
 backup/backup = 0
 devices/cache_dir = "$TESTDIR/etc"
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 9ca7f1141..c073eaf24 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -248,4 +248,25 @@ not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4
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



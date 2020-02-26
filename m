From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 Feb 2020 07:30:57 -0500
Subject: master - tests: validate vdo slab_size
Message-ID: <202002261230.01QCUvNI001080@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9532bb577a82df454254ab65002f4be5bcc65060
Commit:        9532bb577a82df454254ab65002f4be5bcc65060
Parent:        d02d7bc560ef27d2a0e66d40f96519379d320735
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 26 13:26:46 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 26 13:29:21 2020 +0100

tests: validate vdo slab_size

New vdoformat can print this size - so check we pass proper bit count
matching preset value.
---
 WHATS_NEW                  |  1 +
 test/lib/aux.sh            |  1 +
 test/shell/lvcreate-vdo.sh | 13 ++++++++-----
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 30f1391..664df61 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.09 - 
 ====================================
+  Fix formating of vdopool (vdo_slab_size_mb was smaller by 2 bits).
   Fix showing of a dm kernel error when uncaching a volume with cachevol.
 
 Version 2.03.08 - 11th February 2020
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a9d1fe4..83a88a6 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1233,6 +1233,7 @@ activation/udev_sync = 1
 activation/verify_udev_operations = $LVM_VERIFY_UDEV
 activation/raid_region_size = 512
 allocation/wipe_signatures_when_zeroing_new_lvs = 0
+allocation/vdo_slab_size_mb = 128
 backup/archive = 0
 backup/backup = 0
 devices/cache_dir = "$TESTDIR/etc"
diff --git a/test/shell/lvcreate-vdo.sh b/test/shell/lvcreate-vdo.sh
index 64377cd..d66e353 100644
--- a/test/shell/lvcreate-vdo.sh
+++ b/test/shell/lvcreate-vdo.sh
@@ -34,14 +34,17 @@ get_devs
 #	'allocation/vdo_physical_threads = 0' \
 #	'allocation/vdo_cpu_threads = 1'
 
-aux lvmconf 'allocation/vdo_slab_size_mb = 128'
-
-
 vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
 
 # Create VDO device  (vdo-pool is ATM internal volume type)
-lvcreate --type vdo -L4G -n $lv1 $vg/$lv2
-check lv_field $vg/$lv1 size "1.24g"
+lvcreate --type vdo -L4G -n $lv1 $vg/$lv2 >out 2>&1
+# new vdoformat prints some more info
+if grep "data slabs" out ; then
+	# check we have match vdo_slab_size_mb == 128MB (aux.sh)
+	grep "each 128 MB" out
+fi
+
+check lv_field $vg/$lv1 size "<1.24g"
 check lv_field $vg/${lv2} size "4.00g"
 check lv_field $vg/${lv2}_vdata size "4.00g"
 lvremove -ff $vg




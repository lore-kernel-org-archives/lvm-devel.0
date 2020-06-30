From: David Teigland <teigland@sourceware.org>
Date: Tue, 30 Jun 2020 21:44:00 +0000 (GMT)
Subject: master - integrity: add initial size to metadata size
Message-ID: <20200630214400.0DA3A3858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad773511c59aea239592c014a2dab4161ed92214
Commit:        ad773511c59aea239592c014a2dab4161ed92214
Parent:        3f32f9811e01c8953d201c7c9b563561ad856130
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 30 12:52:27 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 30 16:43:05 2020 -0500

integrity: add initial size to metadata size

The metadata device size needs to include space for
the dm-integrity "initial_sectors" which hold journals.
---
 lib/metadata/integrity_manip.c | 28 +++++++++++++++++++++++++++-
 test/shell/integrity-large.sh  | 20 +++++++++++---------
 2 files changed, 38 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index b622743f0..3322a2101 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -28,6 +28,7 @@
 #define DEFAULT_BLOCK_SIZE 512
 
 #define ONE_MB_IN_BYTES 1048576
+#define ONE_GB_IN_BYTES 1073741824
 
 int lv_is_integrity_origin(const struct logical_volume *lv)
 {
@@ -45,10 +46,35 @@ int lv_is_integrity_origin(const struct logical_volume *lv)
 /*
  * Every 500M of data needs 4M of metadata.
  * (From trial and error testing.)
+ *
+ * plus some initial space for journals.
+ * (again from trial and error testing.)
  */
 static uint64_t _lv_size_bytes_to_integrity_meta_bytes(uint64_t lv_size_bytes)
 {
-	return ((lv_size_bytes / (500 * ONE_MB_IN_BYTES)) + 1) * (4 * ONE_MB_IN_BYTES);
+	uint64_t meta_bytes;
+	uint64_t initial_bytes;
+
+	/* Every 500M of data needs 4M of metadata. */
+	meta_bytes = ((lv_size_bytes / (500 * ONE_MB_IN_BYTES)) + 1) * (4 * ONE_MB_IN_BYTES);
+
+	/*
+	 * initial space used for journals
+	 * lv_size <= 512M -> 4M
+	 * lv_size <= 1G   -> 8M
+	 * lv_size <= 4G   -> 32M
+	 * lv_size > 4G    -> 64M
+	 */
+	if (lv_size_bytes <= (512 * ONE_MB_IN_BYTES))
+		initial_bytes = 4 * ONE_MB_IN_BYTES;
+	else if (lv_size_bytes <= ONE_GB_IN_BYTES)
+		initial_bytes = 8 * ONE_MB_IN_BYTES;
+	else if (lv_size_bytes <= (4ULL * ONE_GB_IN_BYTES))
+		initial_bytes = 32 * ONE_MB_IN_BYTES;
+	else if (lv_size_bytes > (4ULL * ONE_GB_IN_BYTES))
+		initial_bytes = 64 * ONE_MB_IN_BYTES;
+
+	return meta_bytes + initial_bytes;
 }
 
 /*
diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
index 1df9e6b53..06b0e03db 100644
--- a/test/shell/integrity-large.sh
+++ b/test/shell/integrity-large.sh
@@ -23,7 +23,7 @@ mnt="mnt"
 mkdir -p $mnt
 
 # raid1 LV needs to be extended to 512MB to test imeta being exended
-aux prepare_devs 4 600
+aux prepare_devs 4 632
 
 printf "%0.sA" {1..16384} >> fileA
 printf "%0.sB" {1..16384} >> fileB
@@ -131,8 +131,8 @@ _verify_data_on_lv
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
-check lv_field $vg/${lv1}_rimage_0_imeta size "8.00m"
-check lv_field $vg/${lv1}_rimage_1_imeta size "8.00m"
+check lv_field $vg/${lv1}_rimage_0_imeta size "12.00m"
+check lv_field $vg/${lv1}_rimage_1_imeta size "12.00m"
 
 # provide space to extend the images onto new devs
 vgextend $vg "$dev3" "$dev4"
@@ -153,33 +153,35 @@ lvconvert --raidintegrity y $vg/$lv1
 _wait_recalc $vg/${lv1}_rimage_0
 _wait_recalc $vg/${lv1}_rimage_1
 lvs -a -o+devices $vg
-check lv_field $vg/${lv1}_rimage_0_imeta size "12.00m"
-check lv_field $vg/${lv1}_rimage_1_imeta size "12.00m"
+check lv_field $vg/${lv1}_rimage_0_imeta size "20.00m"
+check lv_field $vg/${lv1}_rimage_1_imeta size "20.00m"
 
 lvchange -an $vg/$lv1
 lvremove $vg/$lv1
 
 # this succeeds because dev1,dev2 can hold rmeta+rimage
 lvcreate --type raid1 -n $lv1 -L 592M -an $vg "$dev1" "$dev2"
+lvs -a -o+devices $vg
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
 
 # this fails because dev1,dev2 can hold rmeta+rimage, but not imeta
 # and we require imeta to be on same devs as rmeta/rimeta
-not lvcreate --type raid1 --raidintegrity y -n $lv1 -L 592M -an $vg "$dev1" "$dev2"
+not lvcreate --type raid1 --raidintegrity y -n $lv1 -L 624M -an $vg "$dev1" "$dev2"
 lvs -a -o+devices $vg
-lvremove $vg/$lv1
 
 # this can allocate from more devs so there's enough space for imeta to
 # be allocated in the vg, but lvcreate fails because rmeta+rimage are
 # allocated from dev1,dev2, we restrict imeta to being allocated on the
 # same devs as rmeta/rimage, and dev1,dev2 can't fit imeta.
-not lvcreate --type raid1 --raidintegrity y -n $lv1 -L 592M -an $vg
+not lvcreate --type raid1 --raidintegrity y -n $lv1 -L 624M -an $vg
 lvs -a -o+devices $vg
 
 # counterintuitively, increasing the size will allow lvcreate to succeed
 # because rmeta+rimage are pushed to being allocated on dev1,dev2,dev3,dev4
 # which means imeta is now free to be allocated from dev3,dev4 which have
 # plenty of space
-lvcreate --type raid1 --raidintegrity y -n $lv1 -L 600M -an $vg
+lvcreate --type raid1 --raidintegrity y -n $lv1 -L 640M -an $vg
 lvs -a -o+devices $vg
 
 vgremove -ff $vg



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:05:05 +0000 (GMT)
Subject: main - tests: fsadm 300m xfs
Message-ID: <20220907130505.57A40385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e295610d42904e41f295e58b02e0c0577c26c702
Commit:        e295610d42904e41f295e58b02e0c0577c26c702
Parent:        570dbad52718f558fb679a5f5ed87b101bfb39c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 31 12:22:59 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: fsadm 300m xfs

---
 test/shell/fsadm-crypt.sh   | 28 +++++++++++++++-------------
 test/shell/fsadm-renamed.sh |  8 ++++----
 test/shell/fsadm.sh         |  8 ++++----
 3 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 2004db957..3b0c46aca 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -20,7 +20,7 @@ export LVM_TEST_PREFER_BRD=0
 
 . lib/inittest
 
-aux prepare_vg 1 300
+aux prepare_vg 1 1300
 
 # set to "skip" to avoid testing given fs and test warning result
 # i.e. check_reiserfs=skip
@@ -200,8 +200,8 @@ check_missing cryptsetup || skip
 
 vgchange -s 128k
 lvcreate -n $lv1 -L25M $vg
-lvcreate -n ${lv1}bar -L35M $vg
-lvcreate -n ${lv1}plain -L35M $vg
+lvcreate -n ${lv1}bar -L335M $vg
+lvcreate -n ${lv1}plain -L335M $vg
 create_crypt_device
 trap 'cleanup_mounted_and_teardown' EXIT
 
@@ -266,9 +266,9 @@ test_ext3_small_shrink() {
 }
 
 test_xfs_resize() {
-	mkfs.xfs -l internal,size=1536b -f "$3"
+	mkfs.xfs -f "$3"
 
-	fsadm --lvresize resize $1 30M
+	fsadm --lvresize resize $1 330M
 	# Fails - not enough space for 4M fs
 	lvresize -L+10M -r $1
 	not lvreduce -L10M -r $1
@@ -281,7 +281,7 @@ test_xfs_resize() {
 }
 
 test_xfs_small_shrink() {
-	mkfs.xfs -l internal,size=1536b -f "$3"
+	mkfs.xfs -f "$3"
 
 	not lvresize -L-1 -r $1
 	fscheck_xfs "$3"
@@ -345,7 +345,7 @@ test_ext3_inactive() {
 
 test_xfs_inactive() {
 	crypt_open "$2" $PWD2 "$4"
-	mkfs.xfs -l internal,size=1536b -f "$3"
+	mkfs.xfs -f "$3"
 	crypt_close "$4"
 
 	not fsadm --lvresize resize $1 30M
@@ -426,7 +426,7 @@ test_ext3_plain() {
 }
 
 test_xfs_plain() {
-	mkfs.xfs -l internal,size=1536b -f "$3"
+	mkfs.xfs -f "$3"
 
 	not fsadm --lvresize resize $1 30M
 	not lvresize -L+10M -r $1
@@ -434,7 +434,7 @@ test_xfs_plain() {
 	fscheck_xfs "$3"
 
 	lvresize -f -L+10M $1
-	fsadm --cryptresize resize $3 40M
+	fsadm --cryptresize resize $3 345M
 	# no shrink support in xfs
 	not fsadm --cryptresize resize $3 35M
 	fscheck_xfs "$3"
@@ -446,7 +446,7 @@ test_xfs_plain() {
 	crypt_open_plain "$2" $PWD3 "$4"
 	fscheck_xfs "$3"
 
-	lvresize -f -L35M $1
+	lvresize -f -L320M $1
 }
 
 test_reiserfs_plain() {
@@ -492,7 +492,7 @@ test_ext3_detached() {
 }
 
 test_xfs_detached() {
-	mkfs.xfs -l internal,size=1536b -f "$3"
+	mkfs.xfs -f "$3"
 
 	not fsadm --lvresize resize $1 30M
 	not lvresize -L+10M -r $1
@@ -560,8 +560,10 @@ if check_missing ext3; then
 fi
 
 if check_missing xfs; then
+	lvresize -f -L310M $vg_lv
+	cryptsetup resize $CRYPT_NAME
 	test_xfs_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize -f -L25M $vg_lv
+	lvresize -f -L325M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	test_xfs_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
@@ -570,7 +572,7 @@ if check_missing xfs; then
 	test_xfs_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
-	lvresize -f -L100M $vg_lv
+	lvresize -f -L310M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 	test_xfs_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
 	lvresize -f -L25M $vg_lv
diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index 50c6d3ee5..5e2e2ed78 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux prepare_vg 1 80
+aux prepare_vg 1 700
 
 vg_lv=$vg/$lv1
 vg_lv_ren=${vg_lv}_renamed
@@ -63,11 +63,11 @@ if not which "$i" ; then
 	continue
 fi
 
-lvcreate -n $lv1 -L20M $vg
+lvcreate -n $lv1 -L300M $vg
 
 case "$i" in
 *ext3)		MKFS_ARGS="-b1024 -j" ;;
-*xfs)		MKFS_ARGS="-l internal,size=1700b -f" ;;
+*xfs)		MKFS_ARGS="-l internal,size=64m -f" ;;
 *reiserfs)	MKFS_ARGS="-s 513 -f" ;;
 esac
 
@@ -97,7 +97,7 @@ fail lvresize -y -L+10M -r $vg_lv_ren
 # fails on unknown mountpoint  (FIXME: umount)
 not umount "$dev_vg_lv"
 
-lvcreate -L20 -n $lv1 $vg
+lvcreate -L300 -n $lv1 $vg
 "$i" $MKFS_ARGS "$dev_vg_lv"
 
 aux udev_wait
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index c5b3774c2..fea86813d 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux prepare_vg 1 100
+aux prepare_vg 1 400
 
 # set to "skip" to avoid testing given fs and test warning result
 # i.e. check_reiserfs=skip
@@ -179,10 +179,10 @@ if check_missing ext3; then
 fi
 
 if check_missing xfs; then
-	mkfs.xfs -l internal,size=2000b -f "$dev_vg_lv"
+	lvresize -L 300M $vg_lv
+	mkfs.xfs -l internal -f "$dev_vg_lv"
 
-	fsadm --lvresize resize $vg_lv 30M
-	# Fails - not enough space for 4M fs
+	fsadm --lvresize resize $vg_lv 320M
 	lvresize -L+10M -r $vg_lv
 	not lvreduce -L10M -r $vg_lv
 


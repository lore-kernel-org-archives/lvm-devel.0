From: Ondrej Kozina <okozina@sourceware.org>
Date: Wed, 11 Oct 2017 08:40:24 -0400
Subject: master - test: update fsadm-crypt to pass with legacy cryptsetup
Message-ID: <201710111240.v9BCeOPQ020772@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=71261ae3747f3810a1cf279098e149bc0f8dd833
Commit:        71261ae3747f3810a1cf279098e149bc0f8dd833
Parent:        f5beb58561e85d80e43a5e38011d6894db803f28
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Oct 10 17:44:11 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Oct 11 14:39:33 2017 +0200

test: update fsadm-crypt to pass with legacy cryptsetup

---
 test/shell/fsadm-crypt.sh |   97 ++++++++++++++++++++++++++-------------------
 1 files changed, 56 insertions(+), 41 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 348b0ce..bd2c686 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -37,6 +37,10 @@ CRYPT_NAME_PLAIN="$PREFIX-tcryptp"
 CRYPT_DEV_PLAIN="$DM_DEV_DIR/mapper/$CRYPT_NAME_PLAIN"
 
 FORMAT_PARAMS="-i1"
+PWD1="93R4P4pIqAH8"
+PWD2="mymJeD8ivEhE"
+PWD3="ocMakf3fAcQO"
+SKIP_DETACHED=
 
 which cryptsetup || check_cryptsetup=${check_cryptsetup:-cryptsetup}
 
@@ -67,7 +71,7 @@ export LVM_BINARY
 test ! -d "$mount_dir" && mkdir "$mount_dir"
 
 crypt_close() {
-	cryptsetup close "$1"
+	cryptsetup remove "$1"
 	if [ "$?" -eq 0 -a -n "$DROP_SYMLINK" ]; then
 		rm -f "$DM_DEV_DIR/mapper/$1"
 	fi
@@ -133,7 +137,7 @@ crypt_open() {
 	echo "$2" | cryptsetup luksOpen "$1" "$3"
 	test -L "$DM_DEV_DIR/mapper/$3" || {
 		kname=$(get_crypt_kname $3)
-		ln -s "$DM_DEV_DIR/$kname" "$3"
+		ln -s "/dev/$kname" "$DM_DEV_DIR/mapper/$3"
 		DROP_SYMLINK=1
 	}
 }
@@ -144,10 +148,10 @@ crypt_open() {
 # $4 header
 crypt_open_detached() {
 	local kname=
-	echo "$2" | cryptsetup luksOpen --header "$4" "$1" "$3"
+	echo "$2" | cryptsetup luksOpen --header "$4" "$1" "$3" || return $?
 	test -L "$DM_DEV_DIR/mapper/$3" || {
 		kname=$(get_crypt_kname $3)
-		ln -s "$DM_DEV_DIR/$kname" "$3"
+		ln -s "/dev/$kname" "$DM_DEV_DIR/mapper/$3"
 		DROP_SYMLINK=1
 	}
 }
@@ -157,10 +161,10 @@ crypt_open_detached() {
 # $3 name
 crypt_open_plain() {
 	local kname=
-	echo "$2" | cryptsetup open --type plain "$1" "$3"
+	echo "$2" | cryptsetup create "$3" "$1"
 	test -L "$DM_DEV_DIR/mapper/$3" || {
 		kname=$(get_crypt_kname $3)
-		ln -s "$DM_DEV_DIR/$kname" "$3"
+		ln -s "/dev/$kname" "$DM_DEV_DIR/mapper/$3"
 		DROP_SYMLINK=1
 	}
 }
@@ -169,12 +173,19 @@ crypt_open_plain() {
 # $2 type
 create_crypt_device()
 {
-	crypt_format "$dev_vg_lv" "aaa"
-	crypt_open "$dev_vg_lv" "aaa" "$CRYPT_NAME"
+	crypt_format "$dev_vg_lv" $PWD1
+	crypt_open "$dev_vg_lv" $PWD1 "$CRYPT_NAME"
 
-	crypt_format "$dev_vg_lv2" "bbb"
+	crypt_format "$dev_vg_lv2" $PWD2
+
+	if crypt_open_detached "$dev_vg_lv3" "$PWD2" "$PREFIX-test" "$dev_vg_lv2"; then
+		crypt_close "$PREFIX-test"
+	else
+		SKIP_DETACHED=1
+	fi
 }
 
+which lsblk > /dev/null || skip
 check_missing cryptsetup || skip
 
 # Test for block sizes != 1024 (rhbz #480022)
@@ -261,7 +272,7 @@ test_reiserfs_resize() {
 # $3 active dm-crypt device (/dev/mapper/some_name )
 # $4 active dm-crypt name ( some_name )
 test_ext2_inactive() {
-	crypt_open "$2" "bbb" "$4"
+	crypt_open "$2" $PWD2 "$4"
 	mkfs.ext2 -b4096 -j "$3"
 	crypt_close "$4"
 
@@ -269,13 +280,13 @@ test_ext2_inactive() {
 	not lvresize -L+10M -r $1
 	not lvreduce -L10M -r $1
 
-	crypt_open "$2" "bbb" "$4"
+	crypt_open "$2" $PWD2 "$4"
 	fscheck_ext3 "$3"
 	crypt_close "$4"
 }
 
 test_ext3_inactive() {
-	crypt_open "$2" "bbb" "$4"
+	crypt_open "$2" $PWD2 "$4"
 	mkfs.ext3 -b4096 -j "$3"
 	crypt_close "$4"
 
@@ -283,13 +294,13 @@ test_ext3_inactive() {
 	not lvresize -L+10M -r $1
 	not lvreduce -L10M -r $1
 
-	crypt_open "$2" "bbb" "$4"
+	crypt_open "$2" $PWD2 "$4"
 	fscheck_ext3 "$3"
 	crypt_close "$4"
 }
 
 test_xfs_inactive() {
-	crypt_open "$2" "bbb" "$4"
+	crypt_open "$2" $PWD2 "$4"
 	mkfs.xfs -l internal,size=1000b -f "$3"
 	crypt_close "$4"
 
@@ -297,13 +308,13 @@ test_xfs_inactive() {
 	not lvresize -L+10M -r $1
 	not lvreduce -L10M -r $1
 
-	crypt_open "$2" "bbb" "$4"
+	crypt_open "$2" $PWD2 "$4"
 	fscheck_xfs "$3"
 	crypt_close "$4"
 }
 
 test_reiserfs_inactive() {
-	crypt_open "$2" "bbb" "$4"
+	crypt_open "$2" $PWD2 "$4"
 	mkfs.reiserfs -s 513 -f "$3"
 	crypt_close "$4"
 
@@ -311,7 +322,7 @@ test_reiserfs_inactive() {
 	not lvresize -L+10M -r $1
 	not lvreduce -L10M -r $1
 
-	crypt_open "$2" "bbb" "$4"
+	crypt_open "$2" $PWD2 "$4"
 	fscheck_reiserfs "$3"
 	crypt_close "$4"
 }
@@ -341,7 +352,7 @@ test_ext2_plain() {
 	not fsadm --lvresize resize $1 30M
 	not lvresize -L+10M -r $1
 	not lvreduce -L10M -r $1
-	crypt_open_plain "$2" "ccc" "$4"
+	crypt_open_plain "$2" $PWD3 "$4"
 	fscheck_ext3 "$3"
 }
 
@@ -366,7 +377,7 @@ test_ext3_plain() {
 	not fsadm --lvresize resize $1 30M
 	not lvresize -L+10M -r $1
 	not lvreduce -L10M -r $1
-	crypt_open_plain "$2" "ccc" "$4"
+	crypt_open_plain "$2" $PWD3 "$4"
 	fscheck_ext3 "$3"
 }
 
@@ -388,7 +399,7 @@ test_xfs_plain() {
 	not fsadm --lvresize resize $1 30M
 	not lvresize -L+10M -r $1
 	not lvreduce -L10M -r $1
-	crypt_open_plain "$2" "ccc" "$4"
+	crypt_open_plain "$2" $PWD3 "$4"
 	fscheck_xfs "$3"
 
 	lvresize -f -L35M $1
@@ -410,7 +421,7 @@ test_reiserfs_plain() {
 	not fsadm --lvresize resize $1 30M
 	not lvresize -L+10M -r $1
 	not lvreduce -L10M -r $1
-	crypt_open_plain "$2" "ccc" "$4"
+	crypt_open_plain "$2" $PWD3 "$4"
 	fscheck_reiserfs "$3"
 }
 
@@ -462,15 +473,16 @@ if check_missing ext2; then
 	cryptsetup resize $CRYPT_NAME
 
 	test_ext2_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
-	lvresize -f -L35M $vg_lv2
 
-	crypt_open_plain "$dev_vg_lv3" "ccc" "$CRYPT_NAME_PLAIN"
+	crypt_open_plain "$dev_vg_lv3" $PWD3 "$CRYPT_NAME_PLAIN"
 	test_ext2_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
-	crypt_open_detached "$dev_vg_lv3" "bbb" "$CRYPT_NAME2" "$dev_vg_lv2"
-	test_ext2_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
-	crypt_close "$CRYPT_NAME2"
+	if [ -z "$SKIP_DETACHED" ]; then
+		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
+		test_ext2_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+		crypt_close "$CRYPT_NAME2"
+	fi
 fi
 
 if check_missing ext3; then
@@ -479,15 +491,16 @@ if check_missing ext3; then
 	cryptsetup resize $CRYPT_NAME
 
 	test_ext3_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
-	lvresize -f -L35M $vg_lv2
 
-	crypt_open_plain "$dev_vg_lv3" "ccc" "$CRYPT_NAME_PLAIN"
+	crypt_open_plain "$dev_vg_lv3" $PWD3 "$CRYPT_NAME_PLAIN"
 	test_ext3_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
-	crypt_open_detached "$dev_vg_lv3" "bbb" "$CRYPT_NAME2" "$dev_vg_lv2"
-	test_ext3_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
-	crypt_close "$CRYPT_NAME2"
+	if [ -z "$SKIP_DETACHED" ]; then
+		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
+		test_ext3_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+		crypt_close "$CRYPT_NAME2"
+	fi
 fi
 
 if check_missing xfs; then
@@ -496,15 +509,16 @@ if check_missing xfs; then
 	cryptsetup resize $CRYPT_NAME
 
 	test_xfs_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
-	lvresize -f -L35M $vg_lv2
 
-	crypt_open_plain "$dev_vg_lv3" "ccc" "$CRYPT_NAME_PLAIN"
+	crypt_open_plain "$dev_vg_lv3" $PWD3 "$CRYPT_NAME_PLAIN"
 	test_xfs_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
-	crypt_open_detached "$dev_vg_lv3" "bbb" "$CRYPT_NAME2" "$dev_vg_lv2"
-	test_xfs_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
-	crypt_close "$CRYPT_NAME2"
+	if [ -z "$SKIP_DETACHED" ]; then
+		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
+		test_xfs_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+		crypt_close "$CRYPT_NAME2"
+	fi
 fi
 
 if check_missing reiserfs; then
@@ -513,15 +527,16 @@ if check_missing reiserfs; then
 	cryptsetup resize $CRYPT_NAME
 
 	test_reiserfs_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
-	lvresize -f -L35M $vg_lv2
 
-	crypt_open_plain "$dev_vg_lv3" "ccc" "$CRYPT_NAME_PLAIN"
+	crypt_open_plain "$dev_vg_lv3" $PWD3 "$CRYPT_NAME_PLAIN"
 	test_reiserfs_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
-	crypt_open_detached "$dev_vg_lv3" "bbb" "$CRYPT_NAME2" "$dev_vg_lv2"
-	test_reiserfs_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
-	crypt_close "$CRYPT_NAME2"
+	if [ -z "$SKIP_DETACHED" ]; then
+		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
+		test_reiserfs_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+		crypt_close "$CRYPT_NAME2"
+	fi
 fi
 
 crypt_close "$CRYPT_NAME"



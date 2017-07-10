From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:27:39 -0400
Subject: master - tests: replace legacy code
Message-ID: <201707101227.v6ACRdfU021675@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38917ee51c4024e9562cba18bc4ed98188f6818c
Commit:        38917ee51c4024e9562cba18bc4ed98188f6818c
Parent:        d606891e4ae82ac1841d76d01e9425ca67ae9fa1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 10:38:55 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: replace legacy code

Use $(..) instead of legacy `..`.
---
 test/shell/aa-lvmlockd-sanlock-prepare.sh          |    2 +-
 test/shell/dumpconfig.sh                           |    2 +-
 .../shell/lvconvert-raid-takeover-alloc-failure.sh |    4 ++--
 test/shell/lvconvert-raid.sh                       |    4 ++--
 test/shell/lvconvert-raid10.sh                     |    2 +-
 test/shell/lvconvert-raid456.sh                    |    2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/test/shell/aa-lvmlockd-sanlock-prepare.sh b/test/shell/aa-lvmlockd-sanlock-prepare.sh
index 6060927..4d0f9fd 100644
--- a/test/shell/aa-lvmlockd-sanlock-prepare.sh
+++ b/test/shell/aa-lvmlockd-sanlock-prepare.sh
@@ -33,7 +33,7 @@ dmsetup remove GL_DEV || true
 rm -f "$GL_FILE"
 dd if=/dev/zero of="$GL_FILE" bs=$((1024*1024)) count=1024 2> /dev/null
 GL_LOOP=$(losetup -f "$GL_FILE" --show)
-echo "0 `blockdev --getsize $GL_LOOP` linear $GL_LOOP 0" | dmsetup create GL_DEV
+echo "0 $(blockdev --getsize $GL_LOOP linear $GL_LOOP 0)" | dmsetup create GL_DEV
 
 aux prepare_sanlock
 aux prepare_lvmlockd
diff --git a/test/shell/dumpconfig.sh b/test/shell/dumpconfig.sh
index 062def9..ae4028c 100644
--- a/test/shell/dumpconfig.sh
+++ b/test/shell/dumpconfig.sh
@@ -17,7 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 
 flatten() {
 	cat > flatten.config
-	for s in `egrep '^[a-z]+ {$' flatten.config | sed -e s,{$,,`; do
+	for s in $(grep -E '^[a-z]+ {$' flatten.config | sed -e 's,{$,,'); do
 		sed -e "/^$s/,/^}/p;d" flatten.config | sed -e '1d;$d' | sed -e "s,^[ \t]*,$s/,";
 	done
 }
diff --git a/test/shell/lvconvert-raid-takeover-alloc-failure.sh b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
index 969ce27..e0e36cc 100644
--- a/test/shell/lvconvert-raid-takeover-alloc-failure.sh
+++ b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
@@ -25,7 +25,7 @@ function check_sub_lvs
 	local lv=$2
 	local end=$3
 
-	for s in `seq 0 $end`
+	for s in $(seq 0 "$end")
 	do
 		check lv_exists $vg ${lv}_rmeta_$s
 		check lv_exists $vg ${lv}_rimage_$s
@@ -39,7 +39,7 @@ function check_no_sub_lvs
 	local start=$3
 	local end=$4
 
-	for s in `seq $start $end`
+	for s in $(seq "$start" "$end")
 	do
 		check lv_not_exists $vg ${lv}_rmeta_$s
 		check lv_not_exists $vg ${lv}_rimage_$s
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 8b4ebf4..0e7b9f2 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -23,7 +23,7 @@ get_image_pvs() {
 	local d
 	local images
 
-	images=`dmsetup ls | grep ${1}-${2}_.image_.* | cut -f1 | sed -e s:-:/:`
+	images=$(dmsetup ls | grep "${1}-${2}_.image_.*" | cut -f1 | sed -e s:-:/:)
 	lvs --noheadings -a -o devices "$images" | sed s/\(.\)//
 }
 
@@ -162,7 +162,7 @@ lvconvert --splitmirrors 1 --trackchanges $vg/$lv1
 check lv_exists $vg $lv1
 check linear $vg ${lv1}_rimage_2
 fsck.ext4 -fn "$DM_DEV_DIR/mapper/$vg-${lv1}_rimage_2"
-dd of="$DM_DEV_DIR/$vg/$lv1" if=/dev/zero bs=512 oflag=direct count=`blockdev --getsz "$DM_DEV_DIR/$vg/$lv1"`
+dd of="$DM_DEV_DIR/$vg/$lv1" if=/dev/zero bs=512 oflag=direct count="$(blockdev --getsz "$DM_DEV_DIR/$vg/$lv1")"
 not fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv1"
 fsck.ext4 -fn "$DM_DEV_DIR/mapper/$vg-${lv1}_rimage_2"
 # FIXME: needed on tiny loop but not on real block backend ?
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index ec27fca..f4ccc5a 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -19,7 +19,7 @@ get_image_pvs() {
 	local d
 	local images
 
-	images=`dmsetup ls | grep ${1}-${2}_.image_.* | cut -f1 | sed -e s:-:/:`
+	images=$(dmsetup ls | grep "${1}-${2}_.image_.*" | cut -f1 | sed -e s:-:/:)
 	lvs --noheadings -a -o devices $images | sed s/\(.\)//
 }
 
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index 43fe503..5797403 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -19,7 +19,7 @@ get_image_pvs() {
 	local d
 	local images
 
-	images=`dmsetup ls | grep ${1}-${2}_.image_.* | cut -f1 | sed -e s:-:/:`
+	images=$(dmsetup ls | grep "${1}-${2}_.image_.*" | cut -f1 | sed -e s:-:/:)
 	lvs --noheadings -a -o devices $images | sed s/\(.\)//
 }
 



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:04:13 +0000 (GMT)
Subject: main - tests: remove local setting of LVM_BINARY
Message-ID: <20210223140413.076BF389364B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e43b5f1e3c8b445577b9aebea9afecbe0e9ab9c7
Commit:        e43b5f1e3c8b445577b9aebea9afecbe0e9ab9c7
Parent:        646e3280ddf5e73040e12122b8a7a2fad52668a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 14:42:47 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:56:47 2021 +0100

tests: remove local setting of LVM_BINARY

To better test actually fsadm in test suite - avoid setting
LVM_BINARY locally - since test setup already modifies
PATH to find test's lvm binary as the 1st. in path.
---
 test/shell/fsadm-crypt.sh   | 3 ---
 test/shell/fsadm-renamed.sh | 3 ---
 test/shell/fsadm.sh         | 3 ---
 test/shell/lvresize-full.sh | 2 --
 4 files changed, 11 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 4b8fc4e2d..2004db957 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -76,9 +76,6 @@ dev_vg_lv="$DM_DEV_DIR/$vg_lv"
 dev_vg_lv2="$DM_DEV_DIR/$vg_lv2"
 dev_vg_lv3="$DM_DEV_DIR/$vg_lv3"
 mount_dir="mnt"
-# for recursive call
-LVM_BINARY=$(which lvm)
-export LVM_BINARY
 
 test ! -d "$mount_dir" && mkdir "$mount_dir"
 
diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index 321893925..50c6d3ee5 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -27,9 +27,6 @@ dev_vg_lv_ren="$DM_DEV_DIR/$vg_lv_ren"
 mount_dir="mnt"
 mount_space_dir="mnt space dir"
 mount_dolar_dir="mnt \$SPACE dir"
-# for recursive call
-LVM_BINARY=$(which lvm)
-export LVM_BINARY
 
 test ! -d "$mount_dir" && mkdir "$mount_dir"
 test ! -d "$mount_space_dir" && mkdir "$mount_space_dir"
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 67f9660e6..987b1a1a9 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -45,9 +45,6 @@ dev_vg_lv="$DM_DEV_DIR/$vg_lv"
 dev_vg_lv2="$DM_DEV_DIR/$vg_lv2"
 mount_dir="mnt"
 mount_space_dir="mnt space dir"
-# for recursive call
-LVM_BINARY=$(which lvm)
-export LVM_BINARY
 
 test ! -d "$mount_dir" && mkdir "$mount_dir"
 test ! -d "$mount_space_dir" && mkdir "$mount_space_dir"
diff --git a/test/shell/lvresize-full.sh b/test/shell/lvresize-full.sh
index 3cab52275..dcf93a7b2 100644
--- a/test/shell/lvresize-full.sh
+++ b/test/shell/lvresize-full.sh
@@ -21,8 +21,6 @@ SKIP_WITH_LVMPOLLD=1
 FSCK=${FSCK-fsck}
 MKFS=${MKFS-mkfs.ext3}
 RESIZEFS=${RESIZEFS-resize2fs}
-LVM_BINARY=$(which lvm)
-export LVM_BINARY
 
 which $FSCK || skip
 which $MKFS || skip



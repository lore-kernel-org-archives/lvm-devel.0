From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:26:56 -0400
Subject: master - tests: avoid masking return values
Message-ID: <201707101226.v6ACQudL021611@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d4345220cc85a803b8c029adb472fc4d9f580659
Commit:        d4345220cc85a803b8c029adb472fc4d9f580659
Parent:        146bfb2417de3e6cd719b5aef900bf927a39a0cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 19:30:19 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: avoid masking return values

Declare and assign separately to avoid masking return values.
---
 test/shell/fsadm-renamed.sh |    3 ++-
 test/shell/fsadm.sh         |    3 ++-
 test/shell/lvresize-full.sh |    3 ++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index ed7b743..7f3a9fd 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -28,7 +28,8 @@ mount_dir="mnt"
 mount_space_dir="mnt space dir"
 mount_dolar_dir="mnt \$SPACE dir"
 # for recursive call
-export LVM_BINARY=$(which lvm)
+LVM_BINARY=$(which lvm)
+export LVM_BINARY
 
 test ! -d "$mount_dir" && mkdir "$mount_dir"
 test ! -d "$mount_space_dir" && mkdir "$mount_space_dir"
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 351a179..fed7eb4 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -45,7 +45,8 @@ dev_vg_lv2="$DM_DEV_DIR/$vg_lv2"
 mount_dir="mnt"
 mount_space_dir="mnt space dir"
 # for recursive call
-export LVM_BINARY=$(which lvm)
+LVM_BINARY=$(which lvm)
+export LVM_BINARY
 
 test ! -d "$mount_dir" && mkdir "$mount_dir"
 test ! -d "$mount_space_dir" && mkdir "$mount_space_dir"
diff --git a/test/shell/lvresize-full.sh b/test/shell/lvresize-full.sh
index b518bb7..c497781 100644
--- a/test/shell/lvresize-full.sh
+++ b/test/shell/lvresize-full.sh
@@ -21,7 +21,8 @@ SKIP_WITH_LVMPOLLD=1
 FSCK=${FSCK-fsck}
 MKFS=${MKFS-mkfs.ext3}
 RESIZEFS=${RESIZEFS-resize2fs}
-export LVM_BINARY=$(which lvm)
+LVM_BINARY=$(which lvm)
+export LVM_BINARY
 
 which $FSCK || skip
 which $MKFS || skip



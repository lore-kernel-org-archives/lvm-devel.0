From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Sep 2022 20:38:30 +0000 (GMT)
Subject: main - tests: skip new lvresize tests when missing new libblkid
Message-ID: <20220913203830.539F13858407@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bf386411b87047e37e394b3c46c336507c80bd68
Commit:        bf386411b87047e37e394b3c46c336507c80bd68
Parent:        264827cb98458f7100456eeebf7fdde8dcbc0ad4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 13 15:37:10 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 13 15:37:10 2022 -0500

tests: skip new lvresize tests when missing new libblkid

---
 test/shell/fsadm-crypt-fsresize.sh | 7 +++++++
 test/shell/lvresize-fs-crypt.sh    | 7 +++++++
 test/shell/lvresize-fs.sh          | 6 ++++++
 3 files changed, 20 insertions(+)

diff --git a/test/shell/fsadm-crypt-fsresize.sh b/test/shell/fsadm-crypt-fsresize.sh
index 009350800..65f555b29 100644
--- a/test/shell/fsadm-crypt-fsresize.sh
+++ b/test/shell/fsadm-crypt-fsresize.sh
@@ -22,6 +22,13 @@ export LVM_TEST_PREFER_BRD=0
 
 aux prepare_vg 1 300
 
+# Tests require a libblkid version that shows FSLASTBLOCK
+lvcreate -n $lv1 -L 100 $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep FSLASTBLOCK || skip
+lvchange -an $vg
+lvremove $vg/$lv1
+
 # set to "skip" to avoid testing given fs and test warning result
 # i.e. check_reiserfs=skip
 check_ext2=
diff --git a/test/shell/lvresize-fs-crypt.sh b/test/shell/lvresize-fs-crypt.sh
index 19c4e7d8e..0fbb2716e 100644
--- a/test/shell/lvresize-fs-crypt.sh
+++ b/test/shell/lvresize-fs-crypt.sh
@@ -17,6 +17,13 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_vg 3 256
 
+# Tests require a libblkid version that shows FSLASTBLOCK
+lvcreate -n $lv1 -L 300 $vg
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep FSLASTBLOCK || skip
+lvchange -an $vg
+lvremove $vg/$lv1
+
 mount_dir="mnt_lvresize_cr"
 mkdir -p "$mount_dir"
 
diff --git a/test/shell/lvresize-fs.sh b/test/shell/lvresize-fs.sh
index b65e980b7..e4d315b95 100644
--- a/test/shell/lvresize-fs.sh
+++ b/test/shell/lvresize-fs.sh
@@ -28,6 +28,12 @@ aux prepare_vg 3 256
 mount_dir="mnt_lvresize_fs"
 mkdir -p "$mount_dir"
 
+# Tests require a libblkid version that shows FSLASTBLOCK
+lvcreate -n $lv1 -L 300 $vg
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep FSLASTBLOCK || skip
+lvchange -an $vg
+lvremove $vg/$lv1
 
 #
 # lvextend, no fs


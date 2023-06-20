From: David Teigland <teigland@sourceware.org>
Date: Tue, 20 Jun 2023 18:13:50 +0000 (GMT)
Subject: main - tests: lvresize fs mounted multiple times
Message-ID: <20230620181350.BA0A43858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1dbb86f8c7cd95cb484a5b3c465b847f35d2b760
Commit:        1dbb86f8c7cd95cb484a5b3c465b847f35d2b760
Parent:        7c3eca833ff7878d6d32198ed76380c91fdc15fc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 20 13:13:06 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 20 13:13:06 2023 -0500

tests: lvresize fs mounted multiple times

---
 test/shell/lvresize-fs.sh | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/test/shell/lvresize-fs.sh b/test/shell/lvresize-fs.sh
index cf93a4222..d2c4ac707 100644
--- a/test/shell/lvresize-fs.sh
+++ b/test/shell/lvresize-fs.sh
@@ -38,6 +38,8 @@ mkdir -p "$mount_dir"
 mount_dir_space="other mnt dir"
 mkdir -p "$mount_dir_space"
 
+mount_dir_2="mnt_lvresize_fs_2"
+mkdir -p "$mount_dir_2"
 
 # Test combinations of the following:
 # lvreduce / lvextend
@@ -207,6 +209,47 @@ umount "$mount_dir_space"
 lvremove -f $vg/$lv3
 
 
+#################################
+#
+# lvextend, ext4, multiple mounts
+#
+#################################
+
+# Use one instance of ext4 for series of lvextend tests:
+lvcreate -n $lv -L 32M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir_2"
+
+# lvextend, ext4, active, mounted twice, -r
+lvextend -r -L+8M $vg/$lv
+check lv_field $vg/$lv lv_size "40.00m"
+
+workaround_
+
+lvrename $vg/$lv $vg/$lv2
+not lvextend -r -L+8M $vg/$lv2
+not lvreduce -r -L-8M $vg/$lv2
+umount "$mount_dir"
+umount "$mount_dir_2"
+lvextend -r -L+8M $vg/$lv2
+
+mount "$DM_DEV_DIR/$vg/$lv2" "$mount_dir"
+mount --bind "$mount_dir" "$mount_dir_2"
+lvextend -r -L+8M $vg/$lv2
+check lv_field $vg/$lv2 lv_size "56.00m"
+lvrename $vg/$lv2 $vg/$lv3
+not lvextend -r -L+8M $vg/$lv3
+not lvreduce -r -L-8M $vg/$lv3
+umount "$mount_dir"
+umount "$mount_dir_2"
+mount "$DM_DEV_DIR/$vg/$lv3" "$mount_dir"
+lvextend -r -L+8M $vg/$lv3
+lvreduce -r -y -L-8M $vg/$lv3
+umount "$mount_dir"
+
+lvremove -f $vg/$lv3
+
 #####################################
 #
 # Now let do some unmounted tests


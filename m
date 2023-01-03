From: David Teigland <teigland@sourceware.org>
Date: Tue,  3 Jan 2023 20:36:34 +0000 (GMT)
Subject: main - tests: lvresize-fs-crypt using helper only for crypt dev
Message-ID: <20230103203634.118B13858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2580f007f0aaa3bf22c43295caa2c60c6142494f
Commit:        2580f007f0aaa3bf22c43295caa2c60c6142494f
Parent:        81acde7ffdf9fbe522ada16f89e429d9f729dc0c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 3 14:35:26 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 3 14:35:26 2023 -0600

tests: lvresize-fs-crypt using helper only for crypt dev

---
 test/shell/lvresize-fs-crypt.sh | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/test/shell/lvresize-fs-crypt.sh b/test/shell/lvresize-fs-crypt.sh
index e7b8b9426..61a6de022 100644
--- a/test/shell/lvresize-fs-crypt.sh
+++ b/test/shell/lvresize-fs-crypt.sh
@@ -135,6 +135,31 @@ cryptsetup close $cr
 lvchange -an $vg/$lv
 lvremove $vg/$lv
 
+# lvresize uses helper only for crypt dev resize
+# because the fs was resized separately beforehand
+lvcreate -n $lv -L 456M $vg
+echo 93R4P4pIqAH8 | cryptsetup luksFormat -i1 --type luks1 "$DM_DEV_DIR/$vg/$lv"
+echo 93R4P4pIqAH8 | cryptsetup luksOpen "$DM_DEV_DIR/$vg/$lv" $cr
+mkfs.ext4 /dev/mapper/$cr
+mount /dev/mapper/$cr "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# resize only the fs (to 256M), not the crypt dev or LV
+umount "$mount_dir"
+resize2fs /dev/mapper/$cr 262144k
+mount /dev/mapper/$cr "$mount_dir"
+# this lvresize will not resize the fs (which is already reduced
+# to smaller than the requested LV size), but lvresize will use
+# the helper to resize the crypt dev before resizing the LV.
+lvresize -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "356.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+umount "$mount_dir"
+cryptsetup close $cr
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
 # test with LUKS2?
 
 vgremove -ff $vg


From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu,  9 Feb 2023 20:40:46 +0000 (GMT)
Subject: rhel-9.2.0 - tests: lvresize-fs-crypt using helper only for crypt dev
Message-ID: <20230209204046.AE0F83858C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=380e3855fbc661eed490665cf1e3d05e985da189
Commit:        380e3855fbc661eed490665cf1e3d05e985da189
Parent:        611b768134fe39ddfb2eec99eb5417e7e001d8cd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 3 14:35:26 2023 -0600
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Feb 9 16:28:32 2023 +0100

tests: lvresize-fs-crypt using helper only for crypt dev

(cherry picked from commit 2580f007f0aaa3bf22c43295caa2c60c6142494f)
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


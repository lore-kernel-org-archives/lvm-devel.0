From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:16 +0000 (GMT)
Subject: main - tests: update lvextend tests
Message-ID: <20230506204616.88D913858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa19f2aa3d93b48c5e58a897f26de38b8080d483
Commit:        aa19f2aa3d93b48c5e58a897f26de38b8080d483
Parent:        6e8ede833ba4b974f7e2acf8c7e36eaba9661fe8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 5 01:43:29 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 22:43:22 2023 +0200

tests: update lvextend tests

Make test faster by agregating sets of operation to work on a single
created filesystem yet checking all the variants of extension and reduction.

Split 'xfs' part into separate test and convert it for use of the
minimal size 300M nowdays required by mkfs.xfs.
---
 test/shell/lvresize-fs.sh  | 1158 ++++++++++----------------------------------
 test/shell/lvresize-xfs.sh |  301 ++++++++++++
 2 files changed, 562 insertions(+), 897 deletions(-)

diff --git a/test/shell/lvresize-fs.sh b/test/shell/lvresize-fs.sh
index de234aad5..cf93a4222 100644
--- a/test/shell/lvresize-fs.sh
+++ b/test/shell/lvresize-fs.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2007-2016 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2023 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -15,17 +15,22 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux prepare_vg 3 256
+aux prepare_vg 2 100
 
-which mkfs.xfs || skip
+which mkfs.ext4 || skip
+which resize2fs || skip
 
-# Test combinations of the following:
-# lvreduce / lvextend
-# no fs / ext4 / xfs
-# each --fs opt / no --fs opt / --resizefs
-# active / inactive
-# mounted / unmounted
-# fs size less than, equal to or greater than reduced lv size
+#
+# Workaroudn for kernel bug fixed with:
+#    a408f33e895e455f16cf964cb5cd4979b658db7b
+# refreshing DM device - using fsfreeze with suspend
+#
+workaround_() {
+	blkid -p "$DM_DEV_DIR/$vg/$lv" >/dev/null || {
+		dmsetup suspend $vg-$lv
+		dmsetup resume $vg-$lv
+	}
+}
 
 mount_dir="mnt_lvresize_fs"
 mkdir -p "$mount_dir"
@@ -33,690 +38,378 @@ mkdir -p "$mount_dir"
 mount_dir_space="other mnt dir"
 mkdir -p "$mount_dir_space"
 
-# Tests require a libblkid version that shows FSLASTBLOCK
-lvcreate -n $lv1 -L 300 $vg
-mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep FSLASTBLOCK || skip
-lvchange -an $vg
-lvremove $vg/$lv1
 
+# Test combinations of the following:
+# lvreduce / lvextend
+# no fs / ext4
+# each --fs opt / no --fs opt / --resizefs
+# active / inactive
+# mounted / unmounted
+# fs size less than, equal to or greater than reduced lv size
+
+
+###################
 #
 # lvextend, no fs
 #
+###################
 
 # lvextend, no fs, active, no --fs
-lvcreate -n $lv -L 256M $vg
-aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvextend, no fs, inactive, no --fs
-lvcreate -n $lv -L 256M $vg
-aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
-lvchange -an $vg/$lv
-lvextend -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-lvremove $vg/$lv
+lvcreate -n $lv -L 10M $vg
+lvextend -L+20M $vg/$lv
+check lv_field $vg/$lv lv_size "30.00m"
 
 # lvextend, no fs, active, --fs resize fails with no fs found
-lvcreate -n $lv -L 256M $vg
-aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
-not lvextend -L+200M --fs resize $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
+not lvextend -L+20M --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "30.00m"
+
 lvchange -an $vg/$lv
-lvremove $vg/$lv
 
 # lvextend, no fs, inactive, --fs resize error requires active lv
-lvcreate -n $lv -L 256M $vg
-aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
+not lvextend -L+20M --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "30.00m"
+
+# lvextend, no fs, inactive, no --fs
+lvextend -L+30M $vg/$lv
+check lv_field $vg/$lv lv_size "60.00m"
+
+lvremove -f $vg
+
+
+###################
+#
+# lvreduce, no fs
+#
+###################
+
+# lvreduce, no fs, active, no --fs setting is same as --fs checksize
+lvcreate -n $lv -L 50M $vg
+lvreduce -L-10M $vg/$lv
+check lv_field $vg/$lv lv_size "40.00m"
 lvchange -an $vg/$lv
-not lvextend -L+200M --fs resize $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
-lvremove $vg/$lv
 
+# lvreduce, no fs, inactive, no --fs setting is same as --fs checksize
+not lvreduce -L-10M $vg/$lv
+lvreduce --fs checksize -L-10M $vg/$lv
+check lv_field $vg/$lv lv_size "30.00m"
+
+# lvreduce, no fs, inactive, --fs ignore
+lvreduce -L-10M --fs ignore $vg/$lv
+check lv_field $vg/$lv lv_size "20.00m"
+
+# lvreduce, no fs, active, --fs resize requires fs to be found
+lvchange -ay $vg/$lv
+not lvreduce -L-10M --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "20.00m"
+
+lvremove -f $vg/$lv
+
+
+#################
 #
 # lvextend, ext4
 #
+#################
 
-# lvextend, ext4, active, mounted, no --fs setting is same as --fs ignore
-lvcreate -n $lv -L 256M $vg
+# Use one instance of ext4 for series of lvextend tests:
+lvcreate -n $lv -L 20M $vg
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+
+# --fs tests require a libblkid version that shows FSLASTBLOCK
+# so exit 0 test here, if the feature is not present
+blkid -p "$DM_DEV_DIR/$vg/$lv" | grep FSLASTBLOCK || exit 0
+
+
+# lvextend, ext4, active, mounted, no --fs setting is same as --fs ignore
 df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=8 oflag=direct
+lvextend -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "30.00m"
 # with no --fs used, the fs size should be the same
 df --output=size "$mount_dir" |tee df2
 diff df1 df2
 resize2fs "$DM_DEV_DIR/$vg/$lv"
 df --output=size "$mount_dir" |tee df3
 not diff df2 df3
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvextend, ext4, inactive, --fs ignore
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-lvchange -an $vg/$lv
-lvextend --fs ignore -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-lvremove $vg/$lv
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=10 oflag=direct
+# keep mounted fs
 
 # lvextend, ext4, active, mounted, --fs ignore
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 df --output=size "$mount_dir" |tee df1
-lvextend --fs ignore -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+lvextend --fs ignore -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "40.00m"
 df --output=size "$mount_dir" |tee df2
 diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+# keep mounted fs
 
 # lvextend, ext4, active, mounted, --fs resize
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --fs resize -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+lvextend --fs resize -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "50.00m"
 df --output=size "$mount_dir" |tee df2
 not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+# keep mounted fs
+
+workaround_
 
 # lvextend, ext4, active, mounted, --resizefs (same as --fs resize)
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --resizefs -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+lvextend --resizefs -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "60.00m"
 df --output=size "$mount_dir" |tee df2
 not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+# keep mounted fs
 
-# lvextend, ext4, active, mounted, --fs resize --fsmode manage (same as --fs resize)
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --fs resize --fsmode manage -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-df --output=size "$mount_dir" |tee df2
-not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+workaround_
 
-# lvextend, ext4, active, mounted, --fs resize --fsmode offline
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+# lvextend, ext4, active, mounted, --fs resize --fsmode manage (same as --fs resize)
 df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --fs resize --fsmode offline -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-# fsmode offline leaves fs unmounted 
-df -a | tee dfa
-not grep "$mount_dir" dfa
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+lvextend --fs resize --fsmode manage -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "70.00m"
 df --output=size "$mount_dir" |tee df2
 not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+dd if=/dev/zero of="$mount_dir/zeros3" bs=1M count=10 oflag=direct
+# keep mounted fs
 
-# lvextend, ext4, active, mounted, --fs resize --fsmode nochange
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --fs resize --fsmode nochange -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-df --output=size "$mount_dir" |tee df2
-not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+workaround_
 
 # lvextend, ext4, active, mounted, --fs resize_fsadm
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --fs resize_fsadm -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+lvextend --fs resize_fsadm -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "80.00m"
 df --output=size "$mount_dir" |tee df2
 not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+# keep mounted fs
 
-# lvextend, ext4, active, unmounted, --fs resize --fsmode nochange
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvextend --fs resize --fsmode nochange -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
-not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+workaround_
 
-# lvextend, ext4, active, unmounted, --fs resize
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvextend --fs resize -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
-not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvextend, ext4, active, unmounted, --fs resize_fsadm
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+# lvextend, ext4, active, mounted, --fs resize --fsmode nochange
 df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvextend --fs resize_fsadm -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+lvextend --fs resize --fsmode nochange -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "90.00m"
 df --output=size "$mount_dir" |tee df2
 not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+# keep mounted fs
 
 # lvextend|lvreduce, ext4, active, mounted, --fs resize, renamed LV
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 lvrename $vg/$lv $vg/$lv2
 not lvextend --fs resize -L+32M $vg/$lv2
 not lvreduce --fs resize -L-32M $vg/$lv2
 umount "$mount_dir"
-lvchange -an $vg/$lv2
-lvremove $vg/$lv2
 
 # lvextend|lvreduce, ext4, active, mounted, mount dir with space, --fs resize, renamed LV
-lvcreate -n $lv -L 256M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir_space"
-lvrename $vg/$lv $vg/$lv2
-not lvextend --fs resize -L+32M $vg/$lv2
-not lvreduce --fs resize -L-32M $vg/$lv2
+mount "$DM_DEV_DIR/$vg/$lv2" "$mount_dir_space"
+lvrename $vg/$lv2 $vg/$lv3
+not lvextend --fs resize -L+32M $vg/$lv3
+not lvreduce --fs resize -L-32M $vg/$lv3
 umount "$mount_dir_space"
-lvchange -an $vg/$lv2
-lvremove $vg/$lv2
 
+lvremove -f $vg/$lv3
 
+
+#####################################
 #
-# lvextend, xfs
+# Now let do some unmounted tests
 #
+#####################################
 
-# lvextend, xfs, active, mounted, no --fs setting is same as --fs ignore
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-# with no --fs used, the fs size should be the same
-df --output=size "$mount_dir" |tee df2
-diff df1 df2
-xfs_growfs "$DM_DEV_DIR/$vg/$lv"
-df --output=size "$mount_dir" |tee df3
-not diff df2 df3
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvextend, xfs, inactive, --fs ignore
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-lvchange -an $vg/$lv
-lvextend --fs ignore -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-lvremove $vg/$lv
-
-# lvextend, xfs, active, mounted, --fs ignore
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-lvextend --fs ignore -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-df --output=size "$mount_dir" |tee df2
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvextend, xfs, active, mounted, --fs resize
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --fs resize -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-df --output=size "$mount_dir" |tee df2
-not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvextend, xfs, active, mounted, --resizefs (same as --fs resize)
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --resizefs -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-df --output=size "$mount_dir" |tee df2
-not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+# prepare new ext4 setup
+lvcreate -n $lv -L 15M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
 
-# lvextend, xfs, active, mounted, --fs resize --fsmode manage (same as --fs resize)
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --fs resize --fsmode manage -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-df --output=size "$mount_dir" |tee df2
-not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
+# lvextend, ext4, inactive, --fs ignore
 lvchange -an $vg/$lv
-lvremove $vg/$lv
+lvextend --fs ignore -L+5M $vg/$lv
+check lv_field $vg/$lv lv_size "20.00m"
+lvchange -ay $vg/$lv
 
-# lvextend, xfs, active, mounted, --fs resize --fsmode offline
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+# lvextend, ext4, active, mounted, --fs resize --fsmode offline
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-# xfs_growfs requires the fs to be mounted, so extending the lv is
-# succeeds, then the xfs extend fails because it cannot be done unmounted
-not lvextend --fs resize --fsmode offline -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=8 oflag=direct
+lvextend --fs resize --fsmode offline -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "30.00m"
+# fsmode offline leaves fs unmounted
 df -a | tee dfa
-grep "$mount_dir" dfa
-df --output=size "$mount_dir" |tee df2
-# fs not extended so fs size not changed
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvextend, xfs, active, mounted, --fs resize --fsmode nochange
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --fs resize --fsmode nochange -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-df --output=size "$mount_dir" |tee df2
-not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvextend, xfs, active, mounted, --fs resize_fsadm
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+not grep "$mount_dir" dfa
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-lvextend --fs resize_fsadm -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
 df --output=size "$mount_dir" |tee df2
 not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=10 oflag=direct
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
-# lvextend, xfs, active, unmounted, --fs resize --fsmode nochange
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+# lvextend, ext4, active, unmounted, --fs resize --fsmode nochange
 df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-# xfs_growfs requires the fs to be mounted to grow, so --fsmode nochange
-# with an unmounted fs fails
-not lvextend --fs resize --fsmode nochange -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+lvextend --fs resize --fsmode nochange -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "40.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 df --output=size "$mount_dir" |tee df2
-# fs not extended so fs size not changed
-diff df1 df2
+not diff df1 df2
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
-# lvextend, xfs, active, unmounted, --fs resize
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-# --yes needed because mount changes are required and plain "resize"
-# fsopt did not specify if the user wants to change mount state
-lvextend --yes --fs resize -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+# lvextend, ext4, active, unmounted, --fs resize
+lvextend --fs resize -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "50.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 df --output=size "$mount_dir" |tee df2
 not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
-# lvextend, xfs, active, unmounted, --fs resize_fsadm
-lvcreate -n $lv -L 256M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df1
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
-umount "$mount_dir"
-lvextend --fs resize_fsadm -L+200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+# lvextend, ext4, active, unmounted, --fs resize_fsadm
+lvextend --fs resize_fsadm -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "60.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 df --output=size "$mount_dir" |tee df2
 not diff df1 df2
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
 
-#
-# lvreduce, no fs
-#
-
-# lvreduce, no fs, active, no --fs setting is same as --fs checksize
-lvcreate -n $lv -L 456M $vg
-aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
-lvreduce -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, no fs, inactive, no --fs setting is same as --fs checksize
-lvcreate -n $lv -L 456M $vg
-aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
-lvchange -an $vg/$lv
-not lvreduce -L-200M $vg/$lv
-lvreduce --fs checksize -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
-lvremove $vg/$lv
-
-# lvreduce, no fs, active, --fs resize requires fs to be found
-lvcreate -n $lv -L 456M $vg
-aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
-not lvreduce -L-200M --fs resize $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, no fs, inactive, --fs ignore
-lvcreate -n $lv -L 456M $vg
-aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
-lvchange -an $vg/$lv
-lvreduce -L-200M --fs ignore $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+lvremove -f $vg/$lv
 
 
+####################################################################
 #
 # lvreduce, ext4, no --fs setting and the equivalent --fs checksize
 # i.e. fs is not resized
 #
+####################################################################
 
 # lvreduce, ext4, active, mounted, no --fs setting is same as --fs checksize
 # fs smaller than the reduced size
-lvcreate -n $lv -L 200M $vg
+lvcreate -n $lv -L 20M $vg
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
+lvextend -L+25M $vg/$lv
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=10 oflag=direct
 df --output=size "$mount_dir" |tee df1
-# fs is 200M, reduced size is 216M, so no fs reduce is needed
+# fs is 20M, reduced size is 27M, so no fs reduce is needed
 # todo: check that resize2fs was not run?
-lvreduce -L216M $vg/$lv
-check lv_field $vg/$lv lv_size "216.00m"
+lvreduce -L27M $vg/$lv
+check lv_field $vg/$lv lv_size "27.00m"
 df --output=size "$mount_dir" |tee df2
 # fs size unchanged
 diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+# keep fs mounted
 
 # lvreduce, ext4, active, mounted, no --fs setting is same as --fs checksize
 # fs equal to the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-# fs is 200M, reduced size is 200M, so no fs reduce is needed
-# todo: check that resize2fs was not run?
-lvreduce -L200M $vg/$lv
-check lv_field $vg/$lv lv_size "200.00m"
+lvreduce -L20M $vg/$lv
+check lv_field $vg/$lv lv_size "20.00m"
 df --output=size "$mount_dir" |tee df2
 # fs size unchanged
 diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+# keep fs mounted
 
 # lvreduce, ext4, active, mounted, no --fs setting is same as --fs checksize
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
 # lvreduce fails because fs needs to be reduced and checksize does not resize
-not lvreduce -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce -L-18M $vg/$lv
+check lv_field $vg/$lv lv_size "20.00m"
 df --output=size "$mount_dir" |tee df2
 # fs size unchanged
 diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+# keep fs mounted
 
 # lvreduce, ext4, active, mounted, no --fs setting is same as --fs checksize
 # fs larger than the reduced size, fs is using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=300 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-# lvreduce fails because fs needs to be reduced and checksize does not resize
-not lvreduce -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce -L-5M $vg/$lv
+check lv_field $vg/$lv lv_size "20.00m"
 df --output=size "$mount_dir" |tee df2
 # fs size unchanged
 diff df1 df2
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
+lvremove -f $vg/$lv
+
+
+############################################################
+#
 # repeat lvreduce tests with unmounted instead of mounted fs
+#
+############################################################
 
 # lvreduce, ext4, active, unmounted, no --fs setting is same as --fs checksize
 # fs smaller than the reduced size
-lvcreate -n $lv -L 200M $vg
+lvcreate -n $lv -L 20M $vg
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
+lvextend -L+25M $vg/$lv
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=10 oflag=direct
 df --output=size "$mount_dir" |tee df1
 umount "$mount_dir"
-# fs is 200M, reduced size is 216M, so no fs reduce is needed
-lvreduce -L216M $vg/$lv
-check lv_field $vg/$lv lv_size "216.00m"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+# fs is 20M, reduced size is 27M, so no fs reduce is needed
+lvreduce -L27M $vg/$lv
+check lv_field $vg/$lv lv_size "27.00m"
 
 # lvreduce, ext4, active, unmounted, no --fs setting is same as --fs checksize
 # fs equal to the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
-# fs is 200M, reduced size is 200M, so no fs reduce is needed
-lvreduce -L200M $vg/$lv
-check lv_field $vg/$lv lv_size "200.00m"
+# fs is 20M, reduced size is 20M, so no fs reduce is needed
+lvreduce -L20M $vg/$lv
+check lv_field $vg/$lv lv_size "20.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 df --output=size "$mount_dir" |tee df2
 # fs size unchanged
 diff df1 df2
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+
 
 # lvreduce, ext4, active, unmounted, no --fs setting is same as --fs checksize
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
 # lvreduce fails because fs needs to be reduced and checksize does not resize
-not lvreduce -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+not lvreduce -L-5M $vg/$lv
 
-# lvreduce, ext4, active, unmounted, no --fs setting is same as --fs checksize
-# fs larger than the reduced size, fs is using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=300 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
+# lvreduce, ext4, active, unmounted, no --fs setting is same as --fs checksize
+# fs larger than the reduced size, fs is using reduced space
 # lvreduce fails because fs needs to be reduced and checksize does not resize
-not lvreduce -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce -L-10M $vg/$lv
+
+check lv_field $vg/$lv lv_size "20.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 df --output=size "$mount_dir" |tee df2
 # fs size unchanged
 diff df1 df2
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
+lvremove -f $vg
+
+
+#########################################################################
+#
 # repeat a couple prev lvreduce that had no --fs setting,
 # now using --fs checksize to verify it's the same as using no --fs set
+#
+#########################################################################
 
 # lvreduce, ext4, active, mounted, --fs checksize (same as no --fs set)
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
+lvcreate -n $lv -L 100M $vg
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=20 oflag=direct
 df --output=size "$mount_dir" |tee df1
 # lvreduce fails because fs needs to be reduced and checksize does not resize
-not lvreduce --fs checksize -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce --fs checksize -L-50M $vg/$lv
+check lv_field $vg/$lv lv_size "100.00m"
 df --output=size "$mount_dir" |tee df2
 # fs size unchanged
 diff df1 df2
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
 # lvreduce, ext4, active, unmounted, --fs checksize (same as no --fs set)
 # fs smaller than the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
+lvextend -L+50M $vg/$lv
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
 df --output=size "$mount_dir" |tee df1
 umount "$mount_dir"
-# fs is 200M, reduced size is 216M, so no fs reduce is needed
-lvreduce --fs checksize -L216M $vg/$lv
-check lv_field $vg/$lv lv_size "216.00m"
+
+# fs is 100M, reduced size is 120M, so no fs reduce is needed
+lvreduce --fs checksize -L120M $vg/$lv
+check lv_field $vg/$lv lv_size "120.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 df --output=size "$mount_dir" |tee df2
 # fs size unchanged
 diff df1 df2
 umount "$mount_dir"
 lvchange -an $vg/$lv
-lvremove $vg/$lv
 
 # lvreduce with inactive and no --fs setting fails because
 # default behavior is fs checksize which activates the LV
@@ -724,497 +417,168 @@ lvremove $vg/$lv
 
 # lvreduce, ext4, inactive, no --fs setting same as --fs checksize
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
-lvchange -an $vg/$lv
 # lvreduce fails because default is --fs checksize which sees the fs
-not lvreduce -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-lvremove $vg/$lv
+not lvreduce -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "120.00m"
 
+lvremove -f $vg/$lv
+
+
+#################################
 #
 # lvreduce, ext4, --fs resize*
 #
-
-# lvreduce, ext4, active, mounted, --fs resize
-# fs smaller than the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-# fs is 200M, reduced size is 216M, so no fs reduce is needed
-lvreduce -L216M $vg/$lv
-check lv_field $vg/$lv lv_size "216.00m"
-ls -l $mount_dir/zeros1
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, ext4, active, mounted, --fs resize
-# fs equal to the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-# fs is 200M, reduced size is 200M, so no fs reduce is needed
-lvreduce -L200M $vg/$lv
-check lv_field $vg/$lv lv_size "200.00m"
-ls -l $mount_dir/zeros1
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+#################################
 
 # lvreduce, ext4, active, mounted, --fs resize
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
+lvcreate -n $lv -L 50M $vg
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=10 oflag=direct
 df --output=size "$mount_dir" |tee df1
 # lvreduce runs resize2fs to shrink the fs
-lvreduce --yes --fs resize -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
+lvreduce --yes --fs resize -L-20M $vg/$lv
+check lv_field $vg/$lv lv_size "30.00m"
 ls -l $mount_dir/zeros1
 df --output=size "$mount_dir" |tee df2
 # fs size is changed
 not diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
 # lvreduce, ext4, active, mounted, --fs resize
 # fs larger than the reduced size, fs is using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=300 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
 # lvreduce runs resize2fs to shrink the fs but resize2fs fails
 # the fs is not remounted after resize2fs fails because the
 # resize failure might leave the fs in an unknown state
-not lvreduce --yes --fs resize -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce --yes --fs resize -L-15M $vg/$lv
+check lv_field $vg/$lv lv_size "30.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 ls -l $mount_dir/zeros1
-ls -l $mount_dir/zeros2
-df --output=size "$mount_dir" |tee df2
+df --output=size "$mount_dir" |tee df3
 # fs size is unchanged
-diff df1 df2
+diff df2 df3
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
-# repeat with unmounted instead of mounted
+lvremove -f $vg/$lv
 
-# lvreduce, ext4, active, unmounted, --fs resize
-# fs smaller than the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
-# fs is 200M, reduced size is 216M, so no fs reduce is needed
-lvreduce -L216M $vg/$lv
-check lv_field $vg/$lv lv_size "216.00m"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-ls -l $mount_dir/zeros1
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
-# lvreduce, ext4, active, unmounted, --fs resize
-# fs equal to the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
-# fs is 200M, reduced size is 200M, so no fs reduce is needed
-lvreduce -L200M $vg/$lv
-check lv_field $vg/$lv lv_size "200.00m"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-ls -l $mount_dir/zeros1
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+############################################
+#
+# repeat with unmounted instead of mounted
+#
+############################################
 
 # lvreduce, ext4, active, unmounted, --fs resize
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
+lvcreate -n $lv -L 50M $vg
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=10 oflag=direct
 df --output=size "$mount_dir" |tee df1
 umount "$mount_dir"
 # lvreduce runs resize2fs to shrink the fs
-lvreduce --fs resize -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
+lvreduce --fs resize -L-20M $vg/$lv
+check lv_field $vg/$lv lv_size "30.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 ls -l $mount_dir/zeros1
 df --output=size "$mount_dir" |tee df2
 # fs size is changed
 not diff df1 df2
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
 # lvreduce, ext4, active, unmounted, --fs resize
 # fs larger than the reduced size, fs is using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=300 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
 # lvreduce runs resize2fs to shrink the fs but resize2fs fails
-not lvreduce --yes --fs resize -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce --yes --fs resize -L-10M $vg/$lv
+check lv_field $vg/$lv lv_size "30.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
 ls -l $mount_dir/zeros1
-df --output=size "$mount_dir" |tee df2
+df --output=size "$mount_dir" |tee df3
 # fs size is unchanged
-diff df1 df2
+diff df2 df3
 umount "$mount_dir"
 lvchange -an $vg/$lv
 lvremove $vg/$lv
 
+
+##################################################################
+#
 # repeat resizes that shrink the fs, replacing --fs resize with
 # --fs resize --fsmode nochange|offline, --fs resize_fsadm.
 # while mounted and unmounted
+#
+##################################################################
 
 # lvreduce, ext4, active, mounted, --fs resize --fsmode nochange
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
+lvcreate -n $lv -L 90M $vg
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=10 oflag=direct
 df --output=size "$mount_dir" |tee df1
 # lvreduce needs to unmount to run resize2fs but fsmode nochange doesn't let it
-not lvreduce --fs resize --fsmode nochange -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce --fs resize --fsmode nochange -L-10M $vg/$lv
+check lv_field $vg/$lv lv_size "90.00m"
 df --output=size "$mount_dir" |tee df2
 # fs size is unchanged
 diff df1 df2
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
 # lvreduce, ext4, active, unmounted, --fs resize --fsmode nochange
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
 # lvreduce runs resize2fs to shrink the fs
-lvreduce --fs resize --fsmode nochange -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
+lvreduce --fs resize --fsmode nochange -L-10M $vg/$lv
+check lv_field $vg/$lv lv_size "80.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
+df --output=size "$mount_dir" |tee df3
 # fs size is changed
-not diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+not diff df2 df3
+# keep fs mounted
 
 # lvreduce, ext4, active, mounted, --fs resize --fsmode offline
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
 # lvreduce runs resize2fs to shrink the fs
 # fsmode offline leaves the fs unmounted
-lvreduce --fs resize --fsmode offline -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
+lvreduce --fs resize --fsmode offline -L-10M $vg/$lv
+check lv_field $vg/$lv lv_size "70.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
+df --output=size "$mount_dir" |tee df4
 # fs size is changed
-not diff df1 df2
+not diff df3 df4
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
 # lvreduce, ext4, active, unmounted, --fs resize --fsmode offline
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
 # lvreduce runs resize2fs to shrink the fs
-lvreduce --fs resize --fsmode offline -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
+lvreduce --fs resize --fsmode offline -L-10M $vg/$lv
+check lv_field $vg/$lv lv_size "60.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
+df --output=size "$mount_dir" |tee df5
 # fs size is changed
-not diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
+not diff df4 df5
+# keep fs mounted
 
 # lvreduce, ext4, active, mounted, --fs resize_fsadm
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
 # lvreduce runs resize2fs to shrink the fs
-lvreduce --yes --fs resize_fsadm -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
+lvreduce --yes --fs resize_fsadm -L-10M $vg/$lv
+check lv_field $vg/$lv lv_size "50.00m"
 ls -l $mount_dir/zeros1
-df --output=size "$mount_dir" |tee df2
+df --output=size "$mount_dir" |tee df6
 # fs size is changed
-not diff df1 df2
+not diff df5 df6
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
 # lvreduce, ext4, active, unmounted, --fs resize_fsadm
 # fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
 # lvreduce runs resize2fs to shrink the fs
-lvreduce --fs resize_fsadm -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "256.00m"
+lvreduce --fs resize_fsadm -L-10M $vg/$lv
+check lv_field $vg/$lv lv_size "40.00m"
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
+df --output=size "$mount_dir" |tee df7
 # fs size is changed
-not diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-#
-# lvreduce, xfs (xfs does not support shrinking)
-#
-
-# lvreduce, xfs, active, mounted, no --fs setting is same as --fs checksize
-# fs smaller than the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-# fs is 200M, reduced size is 216M, so no fs reduce is needed
-lvreduce -L216M $vg/$lv
-check lv_field $vg/$lv lv_size "216.00m"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, xfs, active, mounted, no --fs setting is same as --fs checksize
-# fs equal to the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-# fs is 200M, reduced size is 200M, so no fs reduce is needed
-lvreduce -L200M $vg/$lv
-check lv_field $vg/$lv lv_size "200.00m"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, xfs, active, mounted, no --fs setting is same as --fs checksize
-# fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-# lvreduce fails because fs needs to be reduced
-not lvreduce -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, xfs, active, unmounted, no --fs setting is same as --fs checksize
-# fs smaller than the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
-# fs is 200M, reduced size is 216M, so no fs reduce is needed
-lvreduce -L216M $vg/$lv
-check lv_field $vg/$lv lv_size "216.00m"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, xfs, active, mounted, --fs resize
-# fs smaller than the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-# fs is 200M, reduced size is 216M, so no fs reduce is needed
-lvreduce -L216M $vg/$lv
-check lv_field $vg/$lv lv_size "216.00m"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, xfs, active, mounted, --fs resize
-# fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-# lvreduce fails because xfs cannot shrink
-not lvreduce --yes --fs resize -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, xfs, active, unmounted, --fs resize*
-# fs larger than the reduced size, fs not using reduced space
-lvcreate -n $lv -L 456M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
-# lvreduce fails because xfs cannot shrink
-not lvreduce --yes --fs resize -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-not lvreduce --yes --fs resize --fsmode manage -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-not lvreduce --yes --fs resize --fsmode nochange -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-not lvreduce --yes --fs resize --fsmode offline -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-not lvreduce --yes --fs resize_fsadm -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-not lvreduce --yes --resizefs -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, xfs, inactive, no --fs setting is same as --fs checksize
-# fs equal to the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
-lvchange -an $vg/$lv
-# no fs reduce is needed
-lvreduce --fs checksize -L200M $vg/$lv
-check lv_field $vg/$lv lv_size "200.00m"
-lvchange -ay $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
-umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
-
-# lvreduce, xfs, inactive, no fs setting is same as --fs checksize
-# fs smaller than the reduced size
-lvcreate -n $lv -L 200M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-lvextend -L+256M $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
-df --output=size "$mount_dir" |tee df1
-umount "$mount_dir"
-lvchange -an $vg/$lv
-# fs is 200M, reduced size is 216M, so no fs reduce is needed
-lvreduce --fs checksize -L216M $vg/$lv
-check lv_field $vg/$lv lv_size "216.00m"
-lvchange -ay $vg/$lv
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-df --output=size "$mount_dir" |tee df2
-# fs size unchanged
-diff df1 df2
+not diff df6 df7
 umount "$mount_dir"
-lvchange -an $vg/$lv
-lvremove $vg/$lv
 
-# lvreduce, xfs, inactive, no --fs setting is same as --fs checksize
-# fs larger than the reduced size
-lvcreate -n $lv -L 456M $vg
-mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
-mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
-dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
-umount "$mount_dir"
-lvchange -an $vg/$lv
-# lvreduce fails because fs needs to be reduced
-not lvreduce -L-200M $vg/$lv
-check lv_field $vg/$lv lv_size "456.00m"
-lvremove $vg/$lv
 
 vgremove -ff $vg
diff --git a/test/shell/lvresize-xfs.sh b/test/shell/lvresize-xfs.sh
new file mode 100644
index 000000000..0a3b89012
--- /dev/null
+++ b/test/shell/lvresize-xfs.sh
@@ -0,0 +1,301 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_vg 1 500
+
+which mkfs.xfs || skip
+which xfs_growfs || skip
+
+mount_dir="mnt_lvresize_fs"
+mkdir -p "$mount_dir"
+
+mount_dir_space="other mnt dir"
+mkdir -p "$mount_dir_space"
+
+
+# Test combinations of the following:
+# lvreduce / lvextend
+# xfs
+# each --fs opt / no --fs opt / --resizefs
+# active / inactive
+# mounted / unmounted
+# fs size less than, equal to or greater than reduced lv size
+
+#################
+#
+# lvextend, xfs
+#
+#################
+
+# lvextend, xfs, active, mounted, no --fs setting is same as --fs ignore
+lvcreate -n $lv -L 300M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=10 oflag=direct
+lvextend -L+20M $vg/$lv
+check lv_field $vg/$lv lv_size "320.00m"
+# with no --fs used, the fs size should be the same
+df --output=size "$mount_dir" |tee df2
+diff df1 df2
+xfs_growfs "$DM_DEV_DIR/$vg/$lv"
+df --output=size "$mount_dir" |tee df3
+not diff df2 df3
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=20 oflag=direct
+# keep it mounted
+
+# lvextend, xfs, active, mounted, --fs ignore
+df --output=size "$mount_dir" |tee df1
+lvextend --fs ignore -L+20 $vg/$lv
+check lv_field $vg/$lv lv_size "340.00m"
+df --output=size "$mount_dir" |tee df2
+diff df1 df2
+
+# lvextend, xfs, active, mounted, --fs resize
+lvextend --fs resize -L+20M $vg/$lv
+check lv_field $vg/$lv lv_size "360.00m"
+df --output=size "$mount_dir" |tee df3
+not diff df2 df3
+
+# lvextend, xfs, active, mounted, --resizefs (same as --fs resize)
+lvextend --resizefs -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "370.00m"
+df --output=size "$mount_dir" |tee df4
+not diff df3 df4
+
+# lvextend, xfs, active, mounted, --fs resize --fsmode manage (same as --fs resize)
+lvextend --fs resize --fsmode manage -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "380.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+
+umount "$mount_dir"
+lvchange -an $vg/$lv
+
+# lvextend, xfs, inactive, --fs ignore
+lvextend --fs ignore -L+20M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+
+lvremove -f $vg/$lv
+
+####################
+# start with new fs 
+####################
+
+# lvextend, xfs, active, mounted, --fs resize --fsmode offline
+lvcreate -n $lv -L 300M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir_space"
+df --output=size "$mount_dir_space" |tee df1
+dd if=/dev/zero of="$mount_dir_space/zeros1" bs=1M count=20 oflag=direct
+# xfs_growfs requires the fs to be mounted, so extending the lv is
+# succeeds, then the xfs extend fails because it cannot be done unmounted
+not lvextend --fs resize --fsmode offline -L+20M $vg/$lv
+check lv_field $vg/$lv lv_size "320.00m"
+df -a | tee dfa
+grep "$mount_dir_space" dfa
+df --output=size "$mount_dir_space" |tee df2
+# fs not extended so fs size not changed
+diff df1 df2
+
+# lvextend, xfs, active, mounted, --fs resize --fsmode nochange
+lvextend --fs resize --fsmode nochange -L+20M $vg/$lv
+check lv_field $vg/$lv lv_size "340.00m"
+df --output=size "$mount_dir_space" |tee df2
+not diff df1 df2
+
+# lvextend, xfs, active, mounted, --fs resize_fsadm
+lvextend --fs resize_fsadm -L+20M $vg/$lv
+check lv_field $vg/$lv lv_size "360.00m"
+df --output=size "$mount_dir_space" |tee df3
+not diff df2 df3
+umount "$mount_dir_space"
+
+# lvextend, xfs, active, unmounted, --fs resize --fsmode nochange
+# xfs_growfs requires the fs to be mounted to grow, so --fsmode nochange
+# with an unmounted fs fails
+not lvextend --fs resize --fsmode nochange -L+20M $vg/$lv
+check lv_field $vg/$lv lv_size "380.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir_space"
+df --output=size "$mount_dir_space" |tee df4
+# fs not extended so fs size not changed
+diff df3 df4
+umount "$mount_dir_space"
+
+# lvextend, xfs, active, unmounted, --fs resize
+# --yes needed because mount changes are required and plain "resize"
+# fsopt did not specify if the user wants to change mount state
+lvextend --yes --fs resize -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "390.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir_space"
+df --output=size "$mount_dir_space" |tee df5
+not diff df4 df5
+umount "$mount_dir_space"
+
+# lvextend, xfs, active, unmounted, --fs resize_fsadm
+lvextend --fs resize_fsadm -L+10M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir_space"
+df --output=size "$mount_dir_space" |tee df6
+not diff df5 df6
+umount "$mount_dir_space"
+lvremove -f $vg/$lv
+
+
+#################################################
+#
+# lvreduce, xfs (xfs does not support shrinking)
+#
+##################################################
+
+# lvreduce, xfs, active, mounted, no --fs setting is same as --fs checksize
+# fs smaller than the reduced size
+lvcreate -n $lv -L 300M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+100M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=20 oflag=direct
+df --output=size "$mount_dir" |tee df1
+# fs is 300M, reduced size is 326M, so no fs reduce is needed
+lvreduce -L326M $vg/$lv
+check lv_field $vg/$lv lv_size "326.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+
+# lvreduce, xfs, inactive, no fs setting is same as --fs checksize
+# fs smaller than the reduced size
+# fs is 200M, reduced size is 216M, so no fs reduce is needed
+lvreduce --fs checksize -L316M $vg/$lv
+check lv_field $vg/$lv lv_size "316.00m"
+lvchange -ay $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+
+# lvreduce, xfs, active, mounted, no --fs setting is same as --fs checksize
+# fs equal to the reduced size
+# fs is 300M, reduced size is 300M, so no fs reduce is needed
+lvreduce -L300M $vg/$lv
+check lv_field $vg/$lv lv_size "300.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+
+# lvreduce, xfs, active, unmounted, no --fs setting is same as --fs checksize
+# fs smaller than the reduced size
+lvextend -L+100M $vg/$lv
+umount "$mount_dir"
+# fs is 300M, reduced size is 316M, so no fs reduce is needed
+lvreduce -L356M $vg/$lv
+check lv_field $vg/$lv lv_size "356.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+
+# lvreduce, xfs, active, mounted, --fs resize
+# fs smaller than the reduced size
+# fs is 300M, reduced size is 316M, so no fs reduce is needed
+lvreduce -L316M $vg/$lv
+check lv_field $vg/$lv lv_size "316.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+
+
+# lvreduce, xfs, inactive, no --fs setting is same as --fs checksize
+# fs equal to the reduced size
+# fs is 300M, reduced size is 300M, so no fs reduce is needed
+lvreduce --fs checksize -L300M $vg/$lv
+check lv_field $vg/$lv lv_size "300.00m"
+lvchange -ay $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+
+lvremove -f $vg/$lv
+
+
+##########################################################
+#
+# lvreduce bigger xfs size (xfs does not support shrinking)
+#
+##########################################################
+
+# lvreduce, xfs, active, mounted, no --fs setting is same as --fs checksize
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 400M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=20 oflag=direct
+df --output=size "$mount_dir" |tee df1
+# lvreduce fails because fs needs to be reduced
+not lvreduce -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+# keep fs mounted
+
+# lvreduce, xfs, active, mounted, --fs resize
+# fs larger than the reduced size, fs not using reduced space
+# lvreduce fails because xfs cannot shrink
+not lvreduce --yes --fs resize -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+
+# lvreduce, xfs, active, unmounted, --fs resize*
+# fs larger than the reduced size, fs not using reduced space
+# lvreduce fails because xfs cannot shrink
+not lvreduce --yes --fs resize -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+not lvreduce --yes --fs resize --fsmode manage -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+not lvreduce --yes --fs resize --fsmode nochange -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+not lvreduce --yes --fs resize --fsmode offline -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+not lvreduce --yes --fs resize_fsadm -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+not lvreduce --yes --resizefs -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+
+# lvreduce, xfs, inactive, no --fs setting is same as --fs checksize
+# fs larger than the reduced size
+# lvreduce fails because fs needs to be reduced
+not lvreduce -L-100M $vg/$lv
+check lv_field $vg/$lv lv_size "400.00m"
+
+vgremove -f $vg


From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Nov 2018 06:23:48 -0500
Subject: master - tests: updates
Message-ID: <201811081123.wA8BNmIG013987@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d4de3cfa4dd16512ac68f637ed7f484b7461edb9
Commit:        d4de3cfa4dd16512ac68f637ed7f484b7461edb9
Parent:        f86f01a3a15115d0ad808a14a1ca5665451cce1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 8 10:21:13 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 8 12:22:18 2018 +0100

tests: updates

---
 test/shell/cache-single-options.sh |   27 +++++++++---------
 test/shell/cache-single-thin.sh    |    4 ++-
 test/shell/cache-single-types.sh   |   37 +++++++++++++------------
 test/shell/cache-single-usage.sh   |   53 ++++++++++++++++++-----------------
 test/shell/writecache.sh           |    8 +++--
 5 files changed, 68 insertions(+), 61 deletions(-)

diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
index f8dde12..38d5a4a 100644
--- a/test/shell/cache-single-options.sh
+++ b/test/shell/cache-single-options.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -16,12 +16,14 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_cache 1 3 0 || skip
+which mkfs.xfs || skip
+
 mount_dir="mnt"
-mkdir -p $mount_dir
+mkdir -p "$mount_dir"
 
 # generate random data
-dmesg > pattern1
-ps aux >> pattern1
+dd if=/dev/urandom of=pattern1 bs=512K count=1
 
 aux prepare_devs 5 64
 
@@ -40,10 +42,10 @@ mkfs_mount_umount()
 	lvchange -ay $vg/$lvt
 
 	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lvt"
-	mount "$DM_DEV_DIR/$vg/$lvt" $mount_dir
-	cp pattern1 $mount_dir/pattern1
-	dd if=/dev/zero of=$mount_dir/zeros2M bs=1M count=2 oflag=sync
-	umount $mount_dir
+	mount "$DM_DEV_DIR/$vg/$lvt" "$mount_dir"
+	cp pattern1 "$mount_dir/pattern1"
+	dd if=/dev/zero of="$mount_dir/zeros2M" bs=1M count=2 conv=fdatasync
+	umount "$mount_dir"
 
 	lvchange -an $vg/$lvt
 }
@@ -54,10 +56,10 @@ mount_umount()
 
 	lvchange -ay $vg/$lvt
 
-	mount "$DM_DEV_DIR/$vg/$lvt" $mount_dir
-	diff pattern1 $mount_dir/pattern1
-	dd if=$mount_dir/zeros2M of=/dev/null bs=1M count=2
-	umount $mount_dir
+	mount "$DM_DEV_DIR/$vg/$lvt" "$mount_dir"
+	diff pattern1 "$mount_dir/pattern1"
+	dd if="$mount_dir/zeros2M" of=/dev/null bs=1M count=2 conv=fdatasync
+	umount "$mount_dir"
 
 	lvchange -an $vg/$lvt
 }
@@ -266,4 +268,3 @@ check lv_field $vg/$lv3 segtype cache-pool
 
 
 vgremove -ff $vg
-
diff --git a/test/shell/cache-single-thin.sh b/test/shell/cache-single-thin.sh
index 25c232f..0a94326 100644
--- a/test/shell/cache-single-thin.sh
+++ b/test/shell/cache-single-thin.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -16,6 +16,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_cache 1 3 0 || skip
+
 aux prepare_devs 5 80
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
diff --git a/test/shell/cache-single-types.sh b/test/shell/cache-single-types.sh
index 472970a..d3bd5eb 100644
--- a/test/shell/cache-single-types.sh
+++ b/test/shell/cache-single-types.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -16,12 +16,14 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_cache 1 3 0 || skip
+which mkfs.xfs || skip
+
 mount_dir="mnt"
-mkdir -p $mount_dir
+mkdir -p "$mount_dir"
 
 # generate random data
-dmesg > pattern1
-ps aux >> pattern1
+dd if=/dev/urandom of=pattern1 bs=512K count=1
 
 aux prepare_devs 4 64
 
@@ -37,11 +39,11 @@ lvchange -ay $vg/$lv1
 
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
 
-cp pattern1 $mount_dir/pattern1
+cp pattern1 "$mount_dir/pattern1"
 
-umount $mount_dir
+umount "$mount_dir"
 lvchange -an $vg/$lv1
 
 lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
@@ -53,15 +55,15 @@ grep raid1 out
 
 lvchange -ay $vg/$lv1
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
 
-diff pattern1 $mount_dir/pattern1
+diff pattern1 "$mount_dir/pattern1"
 
-cp pattern1 $mount_dir/pattern1b
+cp pattern1 "$mount_dir/pattern1b"
 
-ls -l $mount_dir
+ls -l "$mount_dir"
 
-umount $mount_dir
+umount "$mount_dir"
 
 lvchange -an $vg/$lv1
 
@@ -73,16 +75,15 @@ check lv_field $vg/$lv2 segtype raid1
 lvchange -ay $vg/$lv1
 lvchange -ay $vg/$lv2
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
 
-ls -l $mount_dir
+ls -l "$mount_dir"
 
-diff pattern1 $mount_dir/pattern1
-diff pattern1 $mount_dir/pattern1b
+diff pattern1 "$mount_dir/pattern1"
+diff pattern1 "$mount_dir/pattern1b"
 
-umount $mount_dir
+umount "$mount_dir"
 lvchange -an $vg/$lv1
 lvchange -an $vg/$lv2
 
 vgremove -ff $vg
-
diff --git a/test/shell/cache-single-usage.sh b/test/shell/cache-single-usage.sh
index 9636932..63be718 100644
--- a/test/shell/cache-single-usage.sh
+++ b/test/shell/cache-single-usage.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -16,12 +16,14 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_cache 1 3 0 || skip
+which mkfs.xfs || skip
+
 mount_dir="mnt"
-mkdir -p $mount_dir
+mkdir -p "$mount_dir"
 
 # generate random data
-dmesg > pattern1
-ps aux >> pattern1
+dd if=/dev/urandom of=pattern1 bs=512K count=1
 
 aux prepare_devs 2 64
 
@@ -39,11 +41,11 @@ lvchange -ay $vg/$lv1
 
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
 
-cp pattern1 $mount_dir/pattern1
+cp pattern1 "$mount_dir/pattern1"
 
-umount $mount_dir
+umount "$mount_dir"
 lvchange -an $vg/$lv1
 
 lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
@@ -55,15 +57,15 @@ grep linear out
 
 lvchange -ay $vg/$lv1
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
 
-diff pattern1 $mount_dir/pattern1
+diff pattern1 "$mount_dir/pattern1"
 
-cp pattern1 $mount_dir/pattern1b
+cp pattern1 "$mount_dir/pattern1b"
 
-ls -l $mount_dir
+ls -l "$mount_dir"
 
-umount $mount_dir
+umount "$mount_dir"
 
 lvchange -an $vg/$lv1
 
@@ -75,14 +77,14 @@ check lv_field $vg/$lv2 segtype linear
 lvchange -ay $vg/$lv1
 lvchange -ay $vg/$lv2
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
 
-ls -l $mount_dir
+ls -l "$mount_dir"
 
-diff pattern1 $mount_dir/pattern1
-diff pattern1 $mount_dir/pattern1b
+diff pattern1 "$mount_dir/pattern1"
+diff pattern1 "$mount_dir/pattern1b"
 
-umount $mount_dir
+umount "$mount_dir"
 lvchange -an $vg/$lv1
 lvchange -an $vg/$lv2
 
@@ -99,12 +101,12 @@ lvchange -ay $vg/$lv1
 
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
 
-cp pattern1 $mount_dir/pattern1
-ls -l $mount_dir
+cp pattern1 "$mount_dir/pattern1"
+ls -l "$mount_dir"
 
-umount $mount_dir
+umount "$mount_dir"
 lvchange -an $vg/$lv1
 
 lvconvert --splitcache $vg/$lv1
@@ -115,15 +117,14 @@ check lv_field $vg/$lv2 segtype linear
 lvchange -ay $vg/$lv1
 lvchange -ay $vg/$lv2
 
-mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
 
-ls -l $mount_dir
+ls -l "$mount_dir"
 
-diff pattern1 $mount_dir/pattern1
+diff pattern1 "$mount_dir/pattern1"
 
-umount $mount_dir
+umount "$mount_dir"
 lvchange -an $vg/$lv1
 lvchange -an $vg/$lv2
 
 vgremove -ff $vg
-
diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index 19cc93b..ce77cfe 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -16,12 +16,14 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_writecache 1 0 0 || skip
+which mkfs.xfs || skip
+
 mount_dir="mnt"
 mkdir -p $mount_dir
 
 # generate random data
-dmesg > pattern1
-ps aux >> pattern1
+dd if=/dev/urandom of=pattern1 bs=512K count=1
 
 aux prepare_devs 2 64
 



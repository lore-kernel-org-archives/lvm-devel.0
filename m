From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  7 Oct 2010 16:06:39 +0200
Subject: [PATCH 9/9] Testing script for fsadm and lvresize functionality
In-Reply-To: <cover.1286460218.git.zkabelac@redhat.com>
References: <cover.1286460218.git.zkabelac@redhat.com>
Message-ID: <220928b6f0ac05acbef9233bd55d13df2ac36cd5.1286460218.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Script checks for precence of tools for ext3,xfs,reiserfs and executes
only those tests which are available. In case we do not want to check
some of them - 'skip' needs to be added for given fs type.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-fsadm.sh |  119 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 108 insertions(+), 11 deletions(-)

diff --git a/test/t-fsadm.sh b/test/t-fsadm.sh
index 6cff7c5..b89e457 100644
--- a/test/t-fsadm.sh
+++ b/test/t-fsadm.sh
@@ -1,5 +1,5 @@
 #!/bin/bash
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,17 +9,114 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+test_description='Exercise fsadm filesystem resize'
+
 . ./test-utils.sh
 
-exit 200
-# doesn't work right now
-aux prepare_pvs 2
-aux pvcreate --metadatacopies 0 $dev1
-vgcreate -cn $vg $devs
+aux prepare_vg 1 100
+
+# set to "skip" to avoid testing given fs and test warning result
+# i.e. check_reiserfs=skip
+check_ext3=
+check_xfs=
+check_reiserfs=
+
+which mkfs.ext3 || check_ext3=${check_ext3:=mkfs.ext3}
+which fsck.ext3 || check_ext3=${check_ext3:=fsck.ext3}
+which mkfs.xfs || check_xfs=${check_xfs:=mkfs.xfs}
+which xfs_check || check_xfs=${check_xfs:=xfs_check}
+which mkfs.reiserfs || check_reiserfs=${check_reiserfs:=mkfs.reiserfs}
+which reiserfsck || check_reiserfs=${check_reiserfs:=reiserfsck}
+
+vg_lv="$vg/$lv1"
+dev_vg_lv="$DM_DEV_DIR/$vg_lv"
+mount_dir="$TESTDIR/mnt"
+
+test ! -d $mount_dir && mkdir $mount_dir
+
+cleanup_mounted_and_teardown()
+{
+	umount $mount_dir || true
+	teardown
+}
+
+fscheck_ext3()
+{
+	fsck.ext3 -p -F -f $dev_vg_lv
+}
+
+fscheck_xfs()
+{
+	xfs_check $dev_vg_lv
+}
+
+fscheck_reiserfs()
+{
+	reiserfsck --check -p -f $dev_vg_lv </dev/null
+}
+
+check_missing()
+{
+	eval local t=$\check_$1
+	test -z "$t" && return 0
+	test "$t" = skip && return 1
+	# trick for warning test
+	echo "TEST ""WARNING: fsadm skips $1 tests, $t tool is missing"
+	return 1
+}
 
 # Test for block sizes != 1024 (rhbz #480022)
-lvcreate -n$lv1 -L 64M $vg
-mke2fs -b4096 -j $DM_DEV_DIR/$vg/$lv1
-e2fsck -f -y $DM_DEV_DIR/$vg/$lv1
-fsadm --lvresize resize $DM_DEV_DIR/$vg/$lv1 128M
-vgremove -ff $vg
+lvcreate -n $lv1 -L20M $vg
+trap 'aux cleanup_mounted_and_teardown' EXIT
+
+if check_missing ext3; then
+	mkfs.ext3 -b4096 -j $dev_vg_lv
+
+	fsadm --lvresize resize $vg_lv 30M
+	# Fails - not enough space for 4M fs
+	not fsadm --lvresize resize $dev_vg_lv 4M
+	lvresize -L+10M -r $vg_lv
+	lvreduce -L10M -r $vg_lv
+
+	fscheck_ext3
+	mount $dev_vg_lv $mount_dir
+	not fsadm --lvresize resize $vg_lv 9M
+	lvresize -L+20M -r -n $vg_lv
+	umount $mount_dir
+	fscheck_ext3
+
+	lvresize -f -L20M $vg_lv
+fi
+
+if check_missing xfs; then
+	mkfs.xfs -l internal,size=1000b -f $dev_vg_lv
+
+	fsadm --lvresize resize $vg_lv 30M
+	# Fails - not enough space for 4M fs
+	lvresize -L+10M -r $vg_lv
+	not lvreduce -L10M -r $vg_lv
+
+	fscheck_xfs
+	mount $dev_vg_lv $mount_dir
+	lvresize -L+10M -r -n $vg_lv
+	umount $mount_dir
+	fscheck_xfs
+
+	lvresize -f -L20M $vg_lv
+fi
+
+if check_missing reiserfs; then
+	mkfs.reiserfs -s 513 -f $dev_vg_lv
+
+	fsadm --lvresize resize $vg_lv 30M
+	lvresize -L+10M -r $vg_lv
+	fsadm --lvresize -y resize $vg_lv 10M
+
+	fscheck_reiserfs
+	mount $dev_vg_lv $mount_dir
+
+	not fsadm -y --lvresize resize $vg_lv 20M
+	umount $mount_dir
+
+	lvresize -f -L20M $vg_lv
+fi
-- 
1.7.3.1



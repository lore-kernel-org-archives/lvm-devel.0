From: David Teigland <teigland@sourceware.org>
Date: Tue,  2 Feb 2021 19:52:46 +0000 (GMT)
Subject: main - writecache: let block_size setting override device block sizes
Message-ID: <20210202195246.1D2AC388701B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8454ce66c511438ef0d9da3d3b0bac2a5a3d8f2b
Commit:        8454ce66c511438ef0d9da3d3b0bac2a5a3d8f2b
Parent:        bee9f4efdd8195f383f026290b741314cdc42439
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 12 14:41:38 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 2 13:52:31 2021 -0600

writecache: let block_size setting override device block sizes

In cases where lvconvert does not detect a fs block size on the
device, it falls back to choosing a writecache block size based
on the device's LBS and PBS (tries to match those.)

If the user specifies a writecache block size on the command
line (--cachesettings block_size=4096|512), lvconvert currently
fails and reports an error if the user-specified value does not
match the value lvconvert would have chosen based on LBS and PBS.

The purpose of allowing a user-specified value on the command line
is to override what lvconvert would otherwise do, so change this
to just print a warning that the user value does not match the
value that would be chosen based on the LBS/PBS, and then take
the user-specified value as the writecache block size.
---
 test/shell/writecache-blocksize.sh | 38 ++++++++++++++++++++++++++++++++++++++
 tools/lvconvert.c                  |  6 +++---
 2 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/test/shell/writecache-blocksize.sh b/test/shell/writecache-blocksize.sh
index 3685fdd05..74f8c2ae5 100644
--- a/test/shell/writecache-blocksize.sh
+++ b/test/shell/writecache-blocksize.sh
@@ -184,3 +184,41 @@ _check_env "4096" "4096"
 _run_test 4096 ""
 
 aux cleanup_scsi_debug_dev
+
+
+# scsi_debug devices with 512 LBS 512 PBS
+aux prepare_scsi_debug_dev 256 || skip
+aux prepare_devs 2 64
+
+_check_env "512" "512"
+
+vgcreate $SHARED $vg "$dev1"
+vgextend $vg "$dev2"
+lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+lvconvert --yes --type writecache --cachevol $lv2 --cachesettings "block_size=4096" $vg/$lv1
+lvchange -ay $vg/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1" |tee out
+grep "sectsz=4096" out
+_add_new_data_to_mnt
+blockdev --getss "$DM_DEV_DIR/$vg/$lv1" |tee out
+grep 4096 out
+blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
+_add_more_data_to_mnt
+_verify_data_on_mnt
+lvconvert --splitcache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+blockdev --getss "$DM_DEV_DIR/$vg/$lv1"
+blockdev --getpbsz "$DM_DEV_DIR/$vg/$lv1"
+_verify_data_on_mnt
+_verify_more_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+lvchange -an $vg/$lv2
+_verify_data_on_lv
+lvremove $vg/$lv1
+lvremove $vg/$lv2
+vgremove $vg
+
+aux cleanup_scsi_debug_dev
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e37172a5e..3457cd08a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -6015,9 +6015,9 @@ skip_fs:
 		}
 
 		if (block_size_setting && (block_size_setting != block_size)) {
-			log_error("Cannot use writecache block size %u with unknown file system block size, logical block size %u, physical block size %u.",
-				  block_size_setting, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
-			goto bad;
+			log_warn("WARNING: writecache block size %u does not match device block sizes, logical %u physical %u",
+				 block_size_setting, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
+			block_size = block_size_setting;
 		}
 
 		if (block_size != 512) {



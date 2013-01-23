From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 23 Jan 2013 13:51:50 +0000 (UTC)
Subject: master - blkdeactivate: fix handling of nested mountpoints and mangled mount paths.
Message-ID: <20130123135150.9F7C212C4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f7da1caf8deaf50e0597ec377fb035ea3de1ac36
Commit:        f7da1caf8deaf50e0597ec377fb035ea3de1ac36
Parent:        8bcc1da2f3f8e5f62af7b9e3a0967f7d1a60b582
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 23 14:45:41 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 23 14:45:41 2013 +0100

blkdeactivate: fix handling of nested mountpoints and mangled mount paths.

If there was a nested mountpoint inside an existing mount path,
blkdeactivate could fail to unmount such a mountpoint as it
needs to deactivate the deepest path first and continue upwards.

For example the simplest reproducer:

[root at rhel6-a ~]# lsblk
NAME                        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                           8:0    0    4G  0 disk
|-vg-lvol0 (dm-2)           253:2    0   32M  0 lvm  /mnt/a
`-vg-lvol1 (dm-3)           253:3    0   32M  0 lvm  /mnt/a/b

Before this patch:

[root at rhel6-a ~]# blkdeactivate -u
Deactivating block devices:
  UMOUNT: unmounting vg-lvol0 (dm-2) mounted on /mnt/a
umount: /mnt/a: device is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
  UMOUNT: unmounting vg-lvol1 (dm-3) mounted on /mnt/a/b
  LVM: deactivating Logical Volume vg/lvol1

(deactivation of vg/lvol0 is skipped as /mnt/a that is on lvol0
can't be unmounted - it still has /mnt/a/b as nested mountpoint!)

With this patch applied:

[root at rhel6-a ~]# blkdeactivate -u
Deactivating block devices:
  UMOUNT: unmounting vg-lvol1 (dm-3) mounted on /mnt/a/b
  UMOUNT: unmounting vg-lvol0 (dm-2) mounted on /mnt/a
  LVM: deactivating Logical Volume vg/lvol0
  LVM: deactivating Logical Volume vg/lvol1

===

Also, this patch contains a fix for processing mangled mount paths:

[root at rhel6-a ~]# lsblk
NAME                        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                           8:0    0    4G  0 disk
`-vg-lvol0 (dm-2)           253:2    0   32M  0 lvm  /mnt/x y z

[root at rhel6-a ~]# lsblk -r
vg-lvol0 253:2 0 32M 0 lvm /mnt/x\x20y\x20z

(the mount path is mangled with \xNN that is visible in raw
lsblk output only and which is used in blkdeactive as well)

Before this patch:

[root at rhel6-a ~]# blkdeactivate -u
Deactivating block devices:
  umount: /mnt/x\x20y\x20z: not found

After this patch applied:

[root at rhel6-a ~]# blkdeactivate -u
Deactivating block devices:
  UMOUNT: unmounting vg-lvol0 (dm-2) mounted on /mnt/x\x20y\x20z
  LVM: deactivating Logical Volume vg/lvol0
---
 WHATS_NEW                   |    1 +
 scripts/blkdeactivate.sh.in |   30 ++++++++++++++++++++++++------
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 11afee7..eb8a4a0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix blkdeactivate to handle nested mountpoints and mangled mount paths.
   Set locales with LC_ALL instead of lower priority LANG variable.
   Fix a crash-inducing race condition in lvmetad.
   Add log/debug_classes to lvm.conf to control debug log messages.
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 740bac5..849c61d 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -39,6 +39,7 @@ LVM="@sbindir@/lvm"
 LSBLK="/bin/lsblk -r --noheadings -o TYPE,KNAME,NAME,MOUNTPOINT"
 LSBLK_VARS="local devtype local kname local name local mnt"
 LSBLK_READ="read -r devtype kname name mnt"
+SORT_MNT="/bin/sort -r -k 4"
 
 # Do not unmount mounted devices by default.
 DO_UMOUNT=0
@@ -122,9 +123,11 @@ is_top_level_device() {
 device_umount () {
 	test -z "$mnt" && return 0;
 
+	test "$devtype" != "lvm" && test "${kname:0:3}" != "dm-" && return 0
+
 	if test -z "${SKIP_UMOUNT_LIST["$mnt"]}" -a "$DO_UMOUNT" -eq "1"; then
 		echo "  UMOUNT: unmounting $name ($kname) mounted on $mnt"
-		$UMOUNT "$mnt" || add_device_to_skip_list
+		$UMOUNT "$(printf $mnt)" || add_device_to_skip_list
 	else
 		echo "  [SKIP]: unmount of $name ($kname) mounted on $mnt"
 		add_device_to_skip_list
@@ -142,9 +145,6 @@ deactivate_holders () {
 		# check if the device not on the skip list already
 		test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
 
-		# try to unmount it if mounted
-		device_umount || return 1
-
 		# try to deactivate the holder
 		test $skip -eq 1 && skip=0 && continue
 		deactivate || return 1
@@ -226,7 +226,16 @@ deactivate_all() {
 	echo "Deactivating block devices:"
 
 	if test $# -eq 0; then
-		# Deactivate all devices
+		#######################
+		# Process all devices #
+		#######################
+
+		# Unmount all relevant mountpoints first
+		while $LSBLK_READ; do
+			device_umount
+		done <<< "`$LSBLK | $SORT_MNT`"
+
+		# Do deactivate
 		while $LSBLK_READ; do
 			# 'disk' is@the bottom already and it's a real device
 			test "$devtype" = "disk" && continue
@@ -249,8 +258,17 @@ deactivate_all() {
 			deactivate || skip=1
 		done <<< "`$LSBLK -s`"
 	else
-		# Deactivate only specified devices
+		##################################
+		# Process only specified devices #
+		##################################
+
 		while test $# -ne 0; do
+			# Unmount all relevant mountpoints first
+			while $LSBLK_READ; do
+				device_umount
+			done <<< "`$LSBLK $1 | $SORT_MNT`"
+
+			# Do deactivate
 			# Single dm device tree deactivation.
 			if test -b "$1"; then
 				$LSBLK_READ <<< "`$LSBLK --nodeps $1`"



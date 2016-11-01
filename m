From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  1 Nov 2016 15:53:52 +0000 (UTC)
Subject: master - blkdeactivate: deactivate dev stack if dev on top already unmounted
Message-ID: <20161101155352.8F7E160E3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4585785613320f2400b5645a47375308f1ee5289
Commit:        4585785613320f2400b5645a47375308f1ee5289
Parent:        a9651adc84210d88828f9c3c82a0f382a899a650
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 1 16:41:30 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 1 16:52:51 2016 +0100

blkdeactivate: deactivate dev stack if dev on top already unmounted

If blkdeactivate finds out that the device on top of device stack
is already unmounted, it still proceeds with device stack deactivation
underneath now.

This situation can happen if blkdeactivate is started and the mount
point is unmounted in parallel by chance (so when blkdeactivate
gets the the actual umount call, the device is not mounted anymore).
Before, the blkdeactivate added such device to skip list which caused
all the stack underneath to be skipped too on deactivation. Now, we
proceed just as if blkdeactivate did the umount itself.

For example, in the example below, the vg-lvol0 is mounted on /mnt/test
when blkdeactivate is called, but it gets unmounted in parallel later
on when blkdeactivate gets to the actual umount call.

Before this patch (vg-lvol0 underneath not deactivated):

  $ blkdeactivate -u
  Deactivating block devices:
    [UMOUNT]: unmounting vg-lvol0 (dm-2) mounted on /mnt/test... skipping

With this patch applied (vg-lvol0 underneath still deactivated):

  $ blkdeactivate -u
  Deactivating block devices:
    [UMOUNT]: unmounting vg-lvol0 (dm-2) mounted on /mnt/test... already unmounted
    [LVM]: deactivating Logical Volume vg/lvol0... done
---
 WHATS_NEW                   |    1 +
 scripts/blkdeactivate.sh.in |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 49af38a..311f3b6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.167 - 
 ======================================
+  Fix blkdeactivate to deactivate dev stack if dev on top already unmounted.
   Prevent non-synced raid1 repair unless --force
   Prevent raid4 creation/conversion on non-supporting kernels
   Add direct striped -> raid4 conversion
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 50ea2d1..443af9c 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -34,6 +34,7 @@ TOOL=blkdeactivate
 DEV_DIR='/dev'
 SYS_BLK_DIR='/sys/block'
 
+MOUNTPOINT="/bin/mountpoint"
 UMOUNT="/bin/umount"
 DMSETUP="@sbindir@/dmsetup"
 LVM="@sbindir@/lvm"
@@ -157,9 +158,11 @@ device_umount_one() {
 		echo -n "  [UMOUNT]: unmounting $name ($kname) mounted on $mnt... "
 		if eval $UMOUNT $UMOUNT_OPTS "$(printf "%s" "$mnt")" $OUT $ERR; then
 			echo "done"
-		else
+		elif $MOUNTPOINT -q "$mnt"; then
 			echo "skipping"
 			add_device_to_skip_list
+		else
+			echo "already unmounted"
 		fi
 	else
 		echo "  [SKIP]: unmount of $name ($kname) mounted on $mnt"



From: Saso Slavicic <saso.linux@astim.si>
Date: Thu, 7 Aug 2014 10:30:51 +0200
Subject: [PATCH] blkdeactivate should deactivate loop devices
Message-ID: <001501cfb219$e61b7780$b2526680$@astim.si>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

When mapping a disk image with kpartx for example, blkdeactivate will
deactivate dm mappings when shutting down, but loop device will not be
deactivated. This can lead to errors (unable to unmount filesystem) on
shutdown if the administrator forgets to unmap the disk image before
shutdown. Since blkdeactivate already goes half-way (with dm mappings), I
thought to add support to deactivate the underlying loop device as well.

blkdeactivate: deactivate loop devices

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -34,6 +34,7 @@ SYS_BLK_DIR='/sys/block'
 
 UMOUNT="/bin/umount"
 DMSETUP="@sbindir@/dmsetup"
+LOSETUP="@sbindir@/losetup"
 LVM="@sbindir@/lvm"
 
 if $UMOUNT --help | grep -- "--all-targets" >$DEV_DIR/null; then
@@ -44,6 +45,7 @@ else
 	FINDMNT_READ="read -r mnt"
 fi
 DMSETUP_OPTS=""
+LOSETUP_OPTS=""
 LVM_OPTS=""
 
 LSBLK="/bin/lsblk -r --noheadings -o TYPE,KNAME,NAME,MOUNTPOINT"
@@ -204,6 +206,23 @@ deactivate_dm () {
 	fi
 }
 
+deactivate_loop () {
+	local name=$(printf $name)
+	test -b "$DEV_DIR/$name" || return 0
+	$LOSETUP "$DEV_DIR/$name" &> $DEV_DIR/null || return 0
+	test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
+
+	deactivate_holders "$DEV_DIR/$name" || return 1
+
+	echo -n "  [LOOP]: deactivating $devtype device $name ($kname)... "
+	if eval $LOSETUP $LOSETUP_OPTS -d "$DEV_DIR/$name" $OUT $ERR; then
+		echo "done"
+	else
+		echo "skipping"
+		add_device_to_skip_list
+	fi
+}
+
 deactivate_lvm () {
 	local DM_VG_NAME; local DM_LV_NAME; local DM_LV_LAYER
 
@@ -263,6 +282,8 @@ deactivate () {
 
######################################################################
 	if test "$devtype" = "lvm"; then
 		deactivate_lvm
+	elif test "$devtype" = "loop"; then
+		deactivate_loop
 	elif test "${kname:0:3}" = "dm-"; then
 		deactivate_dm
 	fi
@@ -379,6 +400,7 @@ set_env() {
 		unset OUT
 		UMOUNT_OPTS+="-v"
 		DMSETUP_OPTS+="-vvvv"
+		LOSETUP_OPTS+="-v"
 		LVM_OPTS+="-vvvv"
 	else
 		OUT="1>$DEV_DIR/null"



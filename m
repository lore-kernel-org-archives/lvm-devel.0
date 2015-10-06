From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  6 Oct 2015 11:26:48 +0000 (UTC)
Subject: master - blkdeactivate: recognize and deactivate MD devices too
Message-ID: <20151006112648.E895B61025@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f7a94a03e8ff61213844fd510e8af127475b501
Commit:        5f7a94a03e8ff61213844fd510e8af127475b501
Parent:        df59db6048a6be79acf231b98fd560b11cce7c7c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 6 13:25:37 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 6 13:25:41 2015 +0200

blkdeactivate: recognize and deactivate MD devices too

---
 WHATS_NEW_DM                |    1 +
 man/blkdeactivate.8.in      |   10 ++++++----
 scripts/blkdeactivate.sh.in |   33 +++++++++++++++++++++++++++++++++
 3 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c1c48ea..e89ead0 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Add support for recognition and deactivation of MD devices to blkdeactivate.
   Move target status functions out of libdm-deptree.
   Correct use of max_write_behind parameter when generating raid target line.
   Fix dm-event systemd service to make sure it is executed before mounting.
diff --git a/man/blkdeactivate.8.in b/man/blkdeactivate.8.in
index 990be4a..2eb4c6f 100644
--- a/man/blkdeactivate.8.in
+++ b/man/blkdeactivate.8.in
@@ -14,10 +14,11 @@ blkdeactivate \(em utility to deactivate block devices
 blkdeactivate utility deactivates block devices. If a device
 is mounted, the utility can unmount it automatically before
 trying to deactivate. The utility currently supports
-device-mapper devices, including LVM volumes.
-LVM volumes are handled directly using the \fBlvm\fP(8) command.
-Other device-mapper based devices are handled using the
-\fBdmsetup\fP(8) command.
+device-mapper devices (DM), including LVM volumes and
+software RAID MD devices. LVM volumes are handled directly
+using the \fBlvm\fP(8) command, the rest of device-mapper
+based devices are handled using the \fBdmsetup\fP(8) command.
+MD devices are handled using the \fBmdadm\fP(8) command.
 .SH OPTIONS
 .TP
 .BR \-d ", " \-\-dmoption \ \fIdm_options\fP
@@ -88,4 +89,5 @@ of device-mapper devices in case the deactivation fails and force removal.
 .BR dmsetup (8),
 .BR lsblk (8),
 .BR lvm (8),
+.BR mdadm (8),
 .BR umount (8)
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 993f151..dc1a006 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -37,6 +37,7 @@ SYS_BLK_DIR='/sys/block'
 UMOUNT="/bin/umount"
 DMSETUP="@sbindir@/dmsetup"
 LVM="@sbindir@/lvm"
+MDADM="@sbindir@/mdadm"
 
 if $UMOUNT --help | grep -- "--all-targets" >$DEV_DIR/null; then
 	UMOUNT_OPTS="--all-targets "
@@ -47,6 +48,7 @@ else
 fi
 DMSETUP_OPTS=""
 LVM_OPTS=""
+MDADM_OPTS=""
 
 LSBLK="/bin/lsblk -r --noheadings -o TYPE,KNAME,NAME,MOUNTPOINT"
 LSBLK_VARS="local devtype local kname local name local mnt"
@@ -259,6 +261,28 @@ deactivate_lvm () {
 	fi
 }
 
+deactivate_md () {
+	local name=$(printf $name)
+	test -b "$DEV_DIR/$name" || return 0
+	test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
+
+	# Skip MD device deactivation if MD tools missing.
+	test $MDADM_AVAILABLE -eq 0 && {
+		add_device_to_skip_list
+		return 1
+	}
+
+	deactivate_holders "$DEV_DIR/$name" || return 1
+
+	echo -n "  [MD]: deactivating $devtype device $kname... "
+	if eval $MDADM $MDADM_OPTS -S "$name" $OUT $ERR; then
+		echo "done"
+	else
+		echo "skipping"
+		add_device_to_skip_list
+	fi
+}
+
 deactivate () {
 	######################################################################
 	# DEACTIVATION HOOKS FOR NEW DEVICE TYPES GO HERE!                   #
@@ -277,6 +301,8 @@ deactivate () {
 		deactivate_lvm
 	elif test "${kname:0:3}" = "dm-"; then
 		deactivate_dm
+	elif test "${kname:0:2}" = "md"; then
+		deactivate_md
 	fi
 }
 
@@ -392,6 +418,7 @@ set_env() {
 		UMOUNT_OPTS+="-v"
 		DMSETUP_OPTS+="-vvvv"
 		LVM_OPTS+="-vvvv"
+		MDADM_OPTS+="-vv"
 	else
 		OUT="1>$DEV_DIR/null"
 	fi
@@ -401,6 +428,12 @@ set_env() {
 	else
 		LVM_AVAILABLE=0
 	fi
+
+	if test -f $MDADM; then
+		MDADM_AVAILABLE=1
+	else
+		MDADM_AVAILABLE=0
+	fi
 }
 
 while test $# -ne 0; do



From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Oct 2012 12:46:29 +0000 (UTC)
Subject: master - scripts: introduce blkdeactivate
Message-ID: <20121012124629.C95CCA0D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c698ee14bbb1310cf2383c8977d14a8e29139f8c
Commit:        c698ee14bbb1310cf2383c8977d14a8e29139f8c
Parent:        f8781ea6a0567940f3dd3de78870be3ae880d909
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 12 14:37:57 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 12 14:44:24 2012 +0200

scripts: introduce blkdeactivate

blkdeactivate - utility to deactivate block devices

Traverses the tree of block devices and tries to deactivate them.
Currently, it supports device-mapper-based devices together with LVM.
See man/blkdeactivate.8 for more info.

It is targeted for use during shutdown to properly deactivate the
whole block device stack - systemd and init scripts are provided as
well. However, it might be used directly on command line too.

Please, see the commentary at the top of the blkdeactivate script
for dependencies and versions of other utilities required.
---
 configure.in                                       |   13 +
 man/Makefile.in                                    |   10 +-
 man/blkdeactivate.8.in                             |   72 +++++
 scripts/Makefile.in                                |   10 +
 scripts/blk_availability_init_red_hat.in           |   58 ++++
 .../blk_availability_systemd_red_hat.service.in    |   14 +
 scripts/blkdeactivate.sh.in                        |  313 ++++++++++++++++++++
 7 files changed, 488 insertions(+), 2 deletions(-)

diff --git a/configure.in b/configure.in
index eb20908..75e0d84 100644
--- a/configure.in
+++ b/configure.in
@@ -44,6 +44,7 @@ case "$host_os" in
 		SELINUX=yes
 		CLUSTER=internal
 		FSADM=yes
+		BLKDEACTIVATE=yes
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
@@ -59,6 +60,7 @@ case "$host_os" in
 		SELINUX=no
 		CLUSTER=none
 		FSADM=no
+		BLKDEACTIVATE=no
 		;;
 esac
 
@@ -1081,6 +1083,13 @@ AC_ARG_ENABLE(fsadm, AC_HELP_STRING([--disable-fsadm], [disable fsadm]),
 AC_MSG_RESULT($FSADM)
 
 ################################################################################
+dnl -- Enable blkdeactivate
+AC_MSG_CHECKING(whether to install blkdeactivate)
+AC_ARG_ENABLE(blkdeactivate, AC_HELP_STRING([--disable-blkdeactivate], [disable blkdeactivate]),
+	      BLKDEACTIVATE=$enableval)
+AC_MSG_RESULT($BLKDEACTIVATE)
+
+################################################################################
 dnl -- enable dmeventd handling
 AC_MSG_CHECKING(whether to use dmeventd)
 AC_ARG_ENABLE(dmeventd, AC_HELP_STRING([--enable-dmeventd],
@@ -1531,6 +1540,7 @@ AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
 AC_SUBST(FSADM)
+AC_SUBST(BLKDEACTIVATE)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
 AC_SUBST(INTL)
@@ -1645,6 +1655,9 @@ man/Makefile
 po/Makefile
 python/Makefile
 python/setup.py
+scripts/blkdeactivate.sh
+scripts/blk_availability_init_red_hat
+scripts/blk_availability_systemd_red_hat.service
 scripts/clvmd_init_red_hat
 scripts/cmirrord_init_red_hat
 scripts/lvm2_lvmetad_init_red_hat
diff --git a/man/Makefile.in b/man/Makefile.in
index c132a3f..8be34c3 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -22,6 +22,12 @@ else
 FSADMMAN =
 endif
 
+ifeq ("@BLKDEACTIVATE@", "yes")
+BLKDEACTIVATEMAN = blkdeactivate.8
+else
+BLKDEACTIVATEMAN =
+endif
+
 ifeq ("@DMEVENTD@", "yes")
 DMEVENTDMAN = dmeventd.8
 else
@@ -42,7 +48,7 @@ MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(LVMETAD)
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(BLKDEACTIVATEMAN) $(LVMETAD)
 
 ifneq ("@CLVMD@", "none")
   MAN8CLUSTER=clvmd.8
@@ -57,7 +63,7 @@ MAN8DM=dmsetup.8 $(DMEVENTDMAN)
 MAN5DIR=$(mandir)/man5
 MAN8DIR=$(mandir)/man8
 
-CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(DMEVENTDMAN) $(MAN8DM)
+CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(MAN8DM)
 DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8
 
 include $(top_builddir)/make.tmpl
diff --git a/man/blkdeactivate.8.in b/man/blkdeactivate.8.in
new file mode 100644
index 0000000..6e566c8
--- /dev/null
+++ b/man/blkdeactivate.8.in
@@ -0,0 +1,72 @@
+.TH "BLKDEACTIVATE" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.SH "NAME"
+blkdeactivate \- utility to deactivate block devices
+.SH SYNOPSIS
+.B blkdeactivate
+.RI [ options ]
+.RI [ device... ]
+.sp
+.SH DESCRIPTION
+blkdeactivate utility deactivates block devices. If a device
+is mounted, the utility can unmount it automatically before
+trying to deactivate. The utility currently supports
+\fIdevice-mapper\fP devices, including \fILVM\fP volumes.
+LVM volumes are handled directly using the \fIlvm\fP command.
+Other device-mapper based devices are handled using the
+\fIdmsetup\fP command.
+.SH OPTIONS
+.IP "\fB\-h, \-\-help\fP"
+Display the help text.
+.IP "\fB\-u, \-\-umount\fP"
+Unmount a mounted device before trying to deactivate it.
+Without this option used, a device that is mounted is not deactivated.
+.IP "\fB\-d, \-\-dmoption\fP \fIdm_options\fP"
+Comma separated list of device-mapper specific options.
+.IP "\fB\-l, \-\-lvmoption\fP \fIlvm_options\fP"
+Comma separated list of LVM specific options.
+.SH DM_OPTIONS
+.IP "\fBretry\fP"
+Retry removal several times in case of failure.
+.IP "\fBforce\fP"
+Force device removal. See \fBdmsetup\fP(8) for more information.
+.SH LVM_OPTIONS
+.IP "\fBretry\fP"
+Retry removal several times in case of failure.
+.IP "\fBwholevg\fP"
+Deactivate the whole LVM Volume Group when processing a Logical Volume.
+Deactivating Volume Group as a whole takes less time than deactivating
+each Logical Volume separately.
+
+.SH EXAMPLES
+.sp
+Deactivate all supported block devices found in the system. If a device
+is mounted, skip its deactivation.
+.sp
+.B blkdeactivate
+
+Deactivate all supported block devices found in the system. If a device
+is mounted, unmount it first if possible.
+.sp
+.B blkdeactivate \-u
+
+Deactivate supplied device together with all its holders. If any of the
+devices processed is mounted, unmount it first if possible.
+.sp
+.B blkdeactivate \-u /dev/vg/lvol0
+
+Deactivate all supported block devices found in the system. Retry deactivation
+of device-mapper devices in case the deactivation fails. Deactivate the whole
+Volume Group at once when processing an LVM Logical Volume.
+.sp
+.B blkdeactivate \-u -d retry -l wholevg
+
+Deactivate all supported block devices found in the system. Retry deactivation
+of device-mapper devices in case the deactivation fails and force removal.
+.sp
+.B blkdeactivate -d force,retry
+
+.SH SEE ALSO
+.BR lsblk (8)
+.BR umount (8)
+.BR dmsetup (8)
+.BR lvm (8)
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index df13c3d..91e2e94 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -38,6 +38,10 @@ ifeq ("@FSADM@", "yes")
 	SCRIPTS += fsadm.sh
 endif
 
+ifeq ("@BLKDEACTIVATE@", "yes")
+	SCRIPTS += blkdeactivate.sh
+endif
+
 OCF_SCRIPTS =
 ifeq ("@OCF@", "yes")
         OCF_SCRIPTS += VolumeGroup.ocf
@@ -74,6 +78,9 @@ endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
 	$(INSTALL_SCRIPT) cmirrord_init_red_hat $(initdir)/cmirrord
 endif
+ifeq ("@BLKDEACTIVATE@", "yes")
+	$(INSTALL_SCRIPT) blk_availability_init_red_hat $(initdir)/blk-availability
+endif
 
 lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS)
 	$(CC) -o $@ $(OBJECTS) $(LDFLAGS) $(LVMLIBS)
@@ -94,6 +101,9 @@ ifeq ("@BUILD_DMEVENTD@", "yes")
 	$(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_unit_dir)/dm-event.service
 	$(INSTALL_DATA) lvm2_monitoring_systemd_red_hat.service $(systemd_unit_dir)/lvm2-monitor.service
 endif
+ifeq ("@BLKDEACTIVATE@", "yes")
+	$(INSTALL_DATA) blk_availability_systemd_red_hat.service $(systemd_unit_dir)/blk-availability.service
+endif
 ifeq ("@BUILD_LVMETAD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.socket $(systemd_unit_dir)/lvm2-lvmetad.socket
 	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmetad.service
diff --git a/scripts/blk_availability_init_red_hat.in b/scripts/blk_availability_init_red_hat.in
new file mode 100644
index 0000000..b6c4a67
--- /dev/null
+++ b/scripts/blk_availability_init_red_hat.in
@@ -0,0 +1,58 @@
+#!/bin/bash
+#
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+#
+# This file is part of LVM2.
+# It is required for the proper handling of failures of LVM2 mirror
+# devices that were created using the -m option of lvcreate.
+#
+#
+# chkconfig: 12345 10 80
+# description: Controls availability of block devices
+#
+# For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
+#	       
+### BEGIN INIT INFO
+# Provides: blk-availability
+# Required-Start:
+# Required-Stop:
+# Default-Start: 1 2 3 4 5
+# Default-Stop: 0 6
+# Short-Description: Availability of block devices
+### END INIT INFO
+
+. /etc/init.d/functions
+
+sbindir=@sbindir@
+script=blkdeactivate
+options="-u -l wholevg"
+
+LOCK_FILE="/var/lock/subsys/$script"
+
+
+rtrn=1
+
+case "$1" in
+  start)
+	touch $LOCK_FILE
+	;;
+
+  stop)
+	action "Stopping blk-availability" $sbindir/$script $options
+	rm -f $LOCK_FILE
+	;;
+
+  status)
+	;;
+  *)
+	echo $"Usage: $0 {start|stop|status}"
+	;;
+esac
diff --git a/scripts/blk_availability_systemd_red_hat.service.in b/scripts/blk_availability_systemd_red_hat.service.in
new file mode 100644
index 0000000..fef919b
--- /dev/null
+++ b/scripts/blk_availability_systemd_red_hat.service.in
@@ -0,0 +1,14 @@
+[Unit]
+Description=Availability of block devices
+After=lvm2-activation.service lvm2-lvmetad.service iscsi.service iscsid.service
+DefaultDependencies=no
+Conflicts=shutdown.target
+
+[Service]
+Type=oneshot
+ExecStart=/usr/bin/true
+ExecStop=@sbindir@/blkdeactivate -u -l wholevg
+RemainAfterExit=yes
+
+[Install]
+WantedBy=sysinit.target
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
new file mode 100644
index 0000000..031f5f6
--- /dev/null
+++ b/scripts/blkdeactivate.sh.in
@@ -0,0 +1,313 @@
+#!/bin/bash
+#
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+#
+# Author: Peter Rajnoha <prajnoha@redhat.com>
+#
+# Script for deactivating block devices
+#
+# Requires:
+#   bash >= 4.0 (associative array support)
+#   lsblk >= 2.22 (lsblk -s support)
+#   umount
+#   dmsetup >= 1.02.68 (--retry option support)
+#   lvm >= 2.2.89 (activation/retry_deactivation config support)
+#
+
+#set -x
+shopt -s dotglob nullglob
+
+TOOL=blkdeactivate
+
+DEV_DIR='/dev'
+SYS_BLK_DIR='/sys/block'
+
+UMOUNT="/bin/umount"
+DMSETUP="@sbindir@/dmsetup"
+LVM="@sbindir@/lvm"
+
+LSBLK="/bin/lsblk -r --noheadings -o TYPE,KNAME,NAME,MOUNTPOINT"
+LSBLK_VARS="local devtype local kname local name local mnt"
+LSBLK_READ="read -r devtype kname name mnt"
+
+# Do not unmount mounted devices by default.
+DO_UMOUNT=0
+
+# Deactivate each LV separately by default (not the whole VG).
+LVM_DO_WHOLE_VG=0
+# Do not retry LV deactivation by default.
+LVM_CONFIG="activation{retry_deactivation=0}"
+
+#
+# List of device names and/or VGs to be skipped.
+# Device name is the KNAME from lsblk output.
+#
+# If deactivation of any device fails, it's automatically
+# added to the SKIP_DEVICE_LIST (also a particular VG
+# added to the SKIP_VG_LIST for a device that is an LV).
+#
+# These lists provide device tree pruning to skip
+# particular device/VG deactivation that failed already.
+# (lists are associative arrays!)
+#
+declare -A SKIP_DEVICE_LIST=()
+declare -A SKIP_VG_LIST=()
+
+#
+# List of mountpoints to be skipped. Any device that is mounted on the mountpoint
+# listed here will be added to SKIP_DEVICE_LIST (and SKIP_VG_LIST) automatically.
+# (list is an associative array!)
+#
+declare -A SKIP_UMOUNT_LIST=(["/"]=1 ["/boot"]=1 \
+                             ["/lib"]=1 ["/lib64"]=1 \
+                             ["/bin"]=1 ["/sbin"]=1 \
+                             ["/usr"]=1 \
+                             ["/usr/lib"]=1 ["/usr/lib64"]=1 \
+                             ["/usr/sbin"]=1 ["/usr/bin"]=1)
+# Bash can't properly handle '[' and ']' used as a subscript
+# within the '()'initialization - it needs to be done separately!
+SKIP_UMOUNT_LIST["[SWAP]"]=1
+
+usage() {
+	echo "${TOOL}: Utility to deactivate block devices"
+	echo
+	echo "  ${TOOL} [options] [device...]"
+	echo "    - Deactivate block device tree."
+	echo "      If devices are specified, deactivate only supplied devices and their holders."
+	echo
+	echo "  Options:"
+	echo "    -h | --help                  Show this help message"
+	echo "    -d | --dmoption  DM_OPTIONS  Comma separated DM specific options"
+	echo "    -l | --lvmoption LVM_OPTIONS Comma separated LVM specific options"
+	echo "    -u | --umount                Unmount the device if mounted"
+	echo
+	echo "  Device specific options:"
+	echo "    DM_OPTIONS:"
+	echo "      retry    retry removal several times in case of failure"
+	echo "      force    force device removal"
+	echo "    LVM_OPTIONS:"
+	echo "      retry    retry removal several times in case of failure"
+	echo "      wholevg  deactivate the whole VG when processing an LV"
+
+	exit
+}
+
+add_device_to_skip_list() {
+	SKIP_DEVICE_LIST+=(["$kname"]=1)
+	return 1
+}
+
+add_vg_to_skip_list() {
+	SKIP_VG_LIST+=(["$DM_VG_NAME"]=1)
+	return 1
+}
+
+is_top_level_device() {
+	# top level devices do not have any holders, that is
+	# the SYS_BLK_DIR/<device_name>/holders dir is empty
+	files="`echo $SYS_BLK_DIR/$kname/holders/*`"
+	test -z "$files"
+}
+
+device_umount () {
+	test -z "$mnt" && return 0;
+
+	if test -z "${SKIP_UMOUNT_LIST["$mnt"]}" -a "$DO_UMOUNT" -eq "1"; then
+		echo "  UMOUNT: unmounting $name ($kname) mounted on $mnt"
+		$UMOUNT "$mnt" || add_device_to_skip_list
+	else
+		echo "  [SKIP]: unmount of $name ($kname) mounted on $mnt"
+		add_device_to_skip_list
+	fi
+}
+
+deactivate_holders () {
+	local skip=1; $LSBLK_VARS
+
+	# Get holders for the device - either a mount or another device.
+	# First line on the lsblk output is the device itself - skip it for
+	# the deactivate call as this device is already being deactivated.
+	while $LSBLK_READ; do
+		test -e $SYS_BLK_DIR/$kname || continue
+		# check if the device not on the skip list already
+		test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
+
+		# try to unmount it if mounted
+		device_umount || return 1
+
+		# try to deactivate the holder
+		test $skip -eq 1 && skip=0 && continue
+		deactivate || return 1
+	done <<< "`$LSBLK $1`"
+}
+
+deactivate_dm () {
+	local name=$(printf $name)
+	test -b "$DEV_DIR/mapper/$name" || return 0
+	test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
+
+	deactivate_holders "$DEV_DIR/mapper/$name" || return 1
+
+	echo "  DM: deactivating $devtype device $name ($kname)"
+	$DMSETUP $DMSETUP_OPTS remove "$name" || add_device_to_skip_list
+}
+
+deactivate_lvm () {
+	local DM_VG_NAME; local DM_LV_NAME; local DM_LV_LAYER
+
+	eval $($DMSETUP splitname --nameprefixes --noheadings --rows "$name" LVM)
+	test -b "$DEV_DIR/$DM_VG_NAME/$DM_LV_NAME" || return 0
+	test -z ${SKIP_VG_LIST["$DM_VG_NAME"]} || return 1
+
+	# Deactivating only the LV specified
+	test $LVM_DO_WHOLE_VG -eq 0 && {
+		deactivate_holders "$DEV_DIR/$DM_VG_NAME/$DM_LV_NAME" || {
+			add_device_to_skip_list
+			return 1
+		}
+
+		echo "  LVM: deactivating Logical Volume $DM_VG_NAME/$DM_LV_NAME"
+		$LVM lvchange --config "log{prefix=\"\"} $LVM_CONFIG" -aln $DM_VG_NAME/$DM_LV_NAME || {
+			add_device_to_skip_list
+			return 1
+		}
+		return 0
+	}
+
+	# Deactivating the whole VG the LV is part of
+	lv_list=$($LVM vgs --config "$LVM_CONFIG" --noheadings --rows -o lv_name $DM_VG_NAME)
+	for lv in $lv_list; do
+		test -b "$DEV_DIR/$DM_VG_NAME/$lv" || continue
+		deactivate_holders "$DEV_DIR/$DM_VG_NAME/$lv" || {
+			add_vg_to_skip_list
+			return 1
+		}
+	done
+
+	echo "  LVM: deactivating Volume Group $DM_VG_NAME"
+	$LVM vgchange --config "log{prefix=\"    \"} $LVM_CONFIG" -aln $DM_VG_NAME || add_vg_to_skip_list
+}
+
+deactivate () {
+	######################################################################
+	# DEACTIVATION HOOKS FOR NEW DEVICE TYPES GO HERE!                   #
+	#                                                                    #
+	# Identify a new device type either by inspecting the TYPE provided  #
+	# by lsblk directly ($devtype) or by any other mean that is suitable #
+	# e.g. the KNAME provided by lsblk ($kname). See $LSBLK_VARS for     #
+	# complete list of variables that may be used. Then call a           #
+	# device-specific deactivation function that handles the exact type. #
+	#                                                                    #
+        # This device-specific function will certainly need to call          #
+	# deactivate_holders first to recursively deactivate any existing    #
+	# holders it might have before deactivating the device it processes. #
+	######################################################################
+	if test "$devtype" = "lvm"; then
+		deactivate_lvm
+	elif test "${kname:0:3}" = "dm-"; then
+		deactivate_dm
+	fi
+}
+
+deactivate_all() {
+	$LSBLK_VARS
+	skip=0
+
+	echo "Deactivating block devices:"
+
+	if test $# -eq 0; then
+		# Deactivate all devices
+		while $LSBLK_READ; do
+			# 'disk' is@the bottom already and it's a real device
+			test "$devtype" = "disk" && continue
+
+			# if deactivation of any device fails, skip processing
+			# any subsequent devices within its subtree as the
+			# top-level device could not be deactivated anyway
+			test $skip -eq 1 && {
+				# reset 'skip' on top level device
+				is_top_level_device && skip=0 || continue
+			}
+
+			# check if the device is not on the skip list already
+			test -z ${SKIP_DEVICE_LIST["$kname"]} || continue
+
+			# try to deactivate top-level device, set 'skip=1'
+			# if it fails to do so - this will cause all the
+			# device's subtree to be skipped when processing
+			# devices further in this loop
+			deactivate || skip=1
+		done <<< "`$LSBLK -s`"
+	else
+		# Deactivate only specified devices
+		while test $# -ne 0; do
+			# Single dm device tree deactivation.
+			if test -b "$1"; then
+				$LSBLK_READ <<< "`$LSBLK --nodeps $1`"
+
+				# check if the device is not on the skip list already
+				test -z ${SKIP_DEVICE_LIST["$kname"]} || continue
+
+				deactivate
+			else
+				echo "$1: device not found"
+				return 1
+			fi
+			shift
+		done;
+	fi
+}
+
+get_dmopts() {
+	ORIG_IFS=$IFS; IFS=','
+
+	for opt in $1; do
+		case $opt in
+			"") ;;
+			"retry") DMSETUP_OPTS+="--retry " ;;
+			"force") DMSETUP_OPTS+="--force " ;;
+			*) echo "$opt: unknown DM option"
+		esac
+	done
+
+	IFS=$ORIG_IFS
+}
+
+get_lvmopts() {
+	ORIG_IFS=$IFS; IFS=','
+
+	for opt in $1; do
+		case "$opt" in
+			"") ;;
+			"retry") LVM_CONFIG="activation{retry_deactivation=1}" ;;
+			"wholevg") LVM_DO_WHOLE_VG=1 ;;
+			*) echo "$opt: unknown LVM option"
+		esac
+	done
+
+	IFS=$ORIG_IFS
+}
+
+while test $# -ne 0; do
+	case "$1" in
+		"") ;;
+		"-h"|"--help") usage ;;
+		"-d"|"--dmopts") get_dmopts "$2" ; shift ;;
+		"-l"|"--lvmopts") get_lvmopts "$2" ; shift ;;
+		"-u"|"--umount") DO_UMOUNT=1 ;;
+		*) break ;;
+	esac
+	shift
+done
+
+deactivate_all "$@"



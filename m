From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 13 Aug 2013 15:52:21 +0000 (UTC)
Subject: master - blkdeactivate: change the way blkdeactivate reports status
Message-ID: <20130813155221.290A360DBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a854398764968fe2847ba6cbfec7650a7ca04b37
Commit:        a854398764968fe2847ba6cbfec7650a7ca04b37
Parent:        32148369d12750dbf85cfd5c21a8bc7f9e6b5ec5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 13 17:17:25 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 13 17:51:23 2013 +0200

blkdeactivate: change the way blkdeactivate reports status

The blkdeactivate now suppresses error messages from external
tools that are called. Instead, only a summary message "done"
or "skipped" is issued by blkdeactivate as any error in calling
the external tool (e.g. unmounting or deactivating a device) causes
the device to be skipped and the blkdeactivate continues with the
next device in the tree.

Add new -e/--errors switch to display any error messages from
external tools.

Also, suppress any output given by the external tools and add
new -v/--verbose switch to display it including the verbose
output of the tools called (this will enable error reporting
as well).

Also add blkdeactivate -vv for even more debug (the script's debug).
---
 WHATS_NEW                   |    3 +
 man/blkdeactivate.8.in      |    7 +++
 scripts/blkdeactivate.sh.in |  102 ++++++++++++++++++++++++++++++++-----------
 3 files changed, 86 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 66cf20e..dd90726 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.101 - 
 ===================================
+  Add blkdeactivate -v/--verbose for debug output from external tools used.
+  Add blkdeactivate -e/--errors for error messages from external tools used.
+  Suppress messages from external tools called in blkdeactivate by default.
 
 Version 2.02.100 - 13th August 2013
 ===================================
diff --git a/man/blkdeactivate.8.in b/man/blkdeactivate.8.in
index 6e566c8..f6713f3 100644
--- a/man/blkdeactivate.8.in
+++ b/man/blkdeactivate.8.in
@@ -15,11 +15,18 @@ LVM volumes are handled directly using the \fIlvm\fP command.
 Other device-mapper based devices are handled using the
 \fIdmsetup\fP command.
 .SH OPTIONS
+.IP "\fB\-e, \-\-errors\fP"
+Show errors reported from tools called by blkdeactivate.
+Without this option, any error messages from these external tools
+are suppressed and the blkdeactivate itself provides only a summary
+message about device being skipped or not.
 .IP "\fB\-h, \-\-help\fP"
 Display the help text.
 .IP "\fB\-u, \-\-umount\fP"
 Unmount a mounted device before trying to deactivate it.
 Without this option used, a device that is mounted is not deactivated.
+.IP "\fB\-v, \-\-verbose\fP"
+Run in verbose mode.
 .IP "\fB\-d, \-\-dmoption\fP \fIdm_options\fP"
 Comma separated list of device-mapper specific options.
 .IP "\fB\-l, \-\-lvmoption\fP \fIlvm_options\fP"
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index be00c24..48f9fe3 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2013 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -36,11 +36,20 @@ UMOUNT="/bin/umount"
 DMSETUP="@sbindir@/dmsetup"
 LVM="@sbindir@/lvm"
 
+UMOUNT_OPTS=""
+DMSETUP_OPTS=""
+LVM_OPTS=""
+
 LSBLK="/bin/lsblk -r --noheadings -o TYPE,KNAME,NAME,MOUNTPOINT"
 LSBLK_VARS="local devtype local kname local name local mnt"
 LSBLK_READ="read -r devtype kname name mnt"
 SORT_MNT="/bin/sort -r -u -k 4"
 
+# Do not show tool errors by default (only done/skipping summary
+# message provided by this script) and no verbose mode by default.
+ERRORS=0
+VERBOSE=0
+
 # Do not unmount mounted devices by default.
 DO_UMOUNT=0
 
@@ -72,6 +81,7 @@ declare -A SKIP_VG_LIST=()
 declare -A SKIP_UMOUNT_LIST=(["/"]=1 ["/boot"]=1 \
                              ["/lib"]=1 ["/lib64"]=1 \
                              ["/bin"]=1 ["/sbin"]=1 \
+                             ["/var"]=1 ["/var/log"]=1 \
                              ["/usr"]=1 \
                              ["/usr/lib"]=1 ["/usr/lib64"]=1 \
                              ["/usr/sbin"]=1 ["/usr/bin"]=1)
@@ -87,10 +97,12 @@ usage() {
 	echo "      If devices are specified, deactivate only supplied devices and their holders."
 	echo
 	echo "  Options:"
+	echo "    -e | --errors                Show errors reported from tools"
 	echo "    -h | --help                  Show this help message"
 	echo "    -d | --dmoption  DM_OPTIONS  Comma separated DM specific options"
 	echo "    -l | --lvmoption LVM_OPTIONS Comma separated LVM specific options"
 	echo "    -u | --umount                Unmount the device if mounted"
+	echo "    -v | --verbose               Verbose mode (also implies -e)"
 	echo
 	echo "  Device specific options:"
 	echo "    DM_OPTIONS:"
@@ -126,8 +138,13 @@ device_umount () {
 	test "$devtype" != "lvm" && test "${kname:0:3}" != "dm-" && return 0
 
 	if test -z "${SKIP_UMOUNT_LIST["$mnt"]}" -a "$DO_UMOUNT" -eq "1"; then
-		echo "  UMOUNT: unmounting $name ($kname) mounted on $mnt"
-		$UMOUNT "$(printf $mnt)" || add_device_to_skip_list
+		echo -n "  [UMOUNT]: unmounting $name ($kname) mounted on $mnt... "
+		if eval $UMOUNT $UMOUNT_OPTS "$(printf $mnt)" $OUT $ERR; then
+			echo "done"
+		else
+			echo "skipping"
+			add_device_to_skip_list
+		fi
 	else
 		echo "  [SKIP]: unmount of $name ($kname) mounted on $mnt"
 		add_device_to_skip_list
@@ -158,44 +175,56 @@ deactivate_dm () {
 
 	deactivate_holders "$DEV_DIR/mapper/$name" || return 1
 
-	echo "  DM: deactivating $devtype device $name ($kname)"
-	$DMSETUP $DMSETUP_OPTS remove "$name" || add_device_to_skip_list
+	echo -n "  [DM]: deactivating $devtype device $name ($kname)... "
+	if eval $DMSETUP $DMSETUP_OPTS remove "$name" $OUT $ERR; then
+		echo "done"
+	else
+		echo "skipping"
+		add_device_to_skip_list
+	fi
 }
 
 deactivate_lvm () {
 	local DM_VG_NAME; local DM_LV_NAME; local DM_LV_LAYER
 
-	eval $($DMSETUP splitname --nameprefixes --noheadings --rows "$name" LVM)
+	eval $(eval $DMSETUP splitname --nameprefixes --noheadings --rows "$name" LVM $ERR)
 	test -b "$DEV_DIR/$DM_VG_NAME/$DM_LV_NAME" || return 0
 	test -z ${SKIP_VG_LIST["$DM_VG_NAME"]} || return 1
 
-	# Deactivating only the LV specified
-	test $LVM_DO_WHOLE_VG -eq 0 && {
+	if test $LVM_DO_WHOLE_VG -eq 0; then
+		# Deactivating only the LV specified
 		deactivate_holders "$DEV_DIR/$DM_VG_NAME/$DM_LV_NAME" || {
 			add_device_to_skip_list
 			return 1
 		}
 
-		echo "  LVM: deactivating Logical Volume $DM_VG_NAME/$DM_LV_NAME"
-		$LVM lvchange --config "log{prefix=\"\"} $LVM_CONFIG" -aln $DM_VG_NAME/$DM_LV_NAME || {
+		echo -n "  [LVM]: deactivating Logical Volume $DM_VG_NAME/$DM_LV_NAME... "
+		if eval $LVM lvchange $LVM_OPTS --config \'log{prefix=\"\"} $LVM_CONFIG\' -aln $DM_VG_NAME/$DM_LV_NAME $OUT $ERR; then
+			echo "done"
+		else
+			echo "skipping"
 			add_device_to_skip_list
-			return 1
-		}
-		return 0
-	}
-
-	# Deactivating the whole VG the LV is part of
-	lv_list=$($LVM vgs --config "$LVM_CONFIG" --noheadings --rows -o lv_name $DM_VG_NAME)
-	for lv in $lv_list; do
-		test -b "$DEV_DIR/$DM_VG_NAME/$lv" || continue
-		deactivate_holders "$DEV_DIR/$DM_VG_NAME/$lv" || {
-			add_vg_to_skip_list
-			return 1
-		}
-	done
+		fi
 
-	echo "  LVM: deactivating Volume Group $DM_VG_NAME"
-	$LVM vgchange --config "log{prefix=\"    \"} $LVM_CONFIG" -aln $DM_VG_NAME || add_vg_to_skip_list
+	else
+		# Deactivating the whole VG the LV is part of
+		lv_list=$(eval $LVM vgs --config "$LVM_CONFIG" --noheadings --rows -o lv_name $DM_VG_NAME $ERR)
+		for lv in $lv_list; do
+			test -b "$DEV_DIR/$DM_VG_NAME/$lv" || continue
+			deactivate_holders "$DEV_DIR/$DM_VG_NAME/$lv" || {
+				add_vg_to_skip_list
+				return 1
+			}
+		done
+
+		echo -n "  [LVM]: deactivating Volume Group $DM_VG_NAME... "
+		if eval $LVM vgchange $LVM_OPTS --config \'log{prefix=\"    \"} $LVM_CONFIG\' -aln $DM_VG_NAME $OUT $ERR; then
+			echo "done"
+		else
+			echo "skipping"
+			add_vg_to_skip_list
+		fi
+	fi
 }
 
 deactivate () {
@@ -316,16 +345,37 @@ get_lvmopts() {
 	IFS=$ORIG_IFS
 }
 
+set_env() {
+	if test "$ERRORS" -eq "1"; then
+		unset ERR
+	else
+		ERR="2>$DEV_DIR/null"
+	fi
+
+	if test "$VERBOSE" -eq "1"; then
+		unset OUT
+		UMOUNT_OPTS+="-v"
+		DMSETUP_OPTS+="-vvvv"
+		LVM_OPTS+="-vvvv"
+	else
+		OUT="1>$DEV_DIR/null"
+	fi
+}
+
 while test $# -ne 0; do
 	case "$1" in
 		"") ;;
+		"-e"|"--errors") ERRORS=1 ;;
 		"-h"|"--help") usage ;;
 		"-d"|"--dmoption ") get_dmopts "$2" ; shift ;;
 		"-l"|"--lvmoption ") get_lvmopts "$2" ; shift ;;
 		"-u"|"--umount") DO_UMOUNT=1 ;;
+		"-v"|"--verbose") VERBOSE=1 ; ERRORS=1 ;;
+		"-vv") VERBOSE=1 ; ERRORS=1 ; set -x ;;
 		*) break ;;
 	esac
 	shift
 done
 
+set_env
 deactivate_all "$@"



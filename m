From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu,  9 Apr 2020 13:30:06 +0000 (GMT)
Subject: master - blkdeactivate: add support for VDO in blkdeactivate script
Message-ID: <20200409133006.E30A6385DC12@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0dd905c959a8f36ea627027336b6d5dafb015001
Commit:        0dd905c959a8f36ea627027336b6d5dafb015001
Parent:        e10f20bc23088a2f9f7529f8f2b40d9c1fcb54c6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 9 15:23:58 2020 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 9 15:29:29 2020 +0200

blkdeactivate: add support for VDO in blkdeactivate script

Make it possible to tear down VDO volumes with blkdeactivate if VDO is
part of a device stack (and if VDO binary is installed). Also, support
optional -o|--vdooptions configfile=file.
---
 WHATS_NEW_DM                |  1 +
 man/blkdeactivate.8_main    | 11 +++++++++++
 scripts/blkdeactivate.sh.in | 48 ++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 59 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ef0461fad..3ec9c3c15 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.173 - 
 ==================================
+  Add support for VDO in blkdeactivate script.
 
 Version 1.02.171 - 26th March 2020
 ==================================
diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index f3c19a8c3..06af52e52 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -9,6 +9,7 @@ blkdeactivate \(em utility to deactivate block devices
 .RB [ -l \  \fIlvm_options\fP ]
 .RB [ -m \  \fImpath_options\fP ]
 .RB [ -r \  \fImdraid_options\fP ]
+.RB [ -o \  \fIvdo_options\fP ]
 .RB [ -u ]
 .RB [ -v ]
 .RI [ device ]
@@ -70,6 +71,15 @@ Comma-separated list of MD RAID specific options:
 Wait MD device's resync, recovery or reshape action to complete
 before deactivation.
 .RE
+
+.TP
+.BR -o ", " --vdooptions \ \fIvdo_options\fP
+Comma-separated list of VDO specific options:
+.RS
+.IP \fIconfigfile=file\fP
+Use specified VDO configuration file.
+.RE
+
 .TP
 .BR -u ", " --umount
 Unmount a mounted device before trying to deactivate it.
@@ -120,4 +130,5 @@ of a device-mapper device fails, retry it and force removal.
 .BR lvm (8),
 .BR mdadm (8),
 .BR multipathd (8),
+.BR vdo (8),
 .BR umount (8)
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index a4b8a8fb5..57b3e58bf 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2012-2017 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2020 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -38,6 +38,7 @@ MDADM="/sbin/mdadm"
 MOUNTPOINT="/bin/mountpoint"
 MPATHD="/sbin/multipathd"
 UMOUNT="/bin/umount"
+VDO="/bin/vdo"
 
 sbindir="@SBINDIR@"
 DMSETUP="$sbindir/dmsetup"
@@ -54,6 +55,7 @@ DMSETUP_OPTS=""
 LVM_OPTS=""
 MDADM_OPTS=""
 MPATHD_OPTS=""
+VDO_OPTS=""
 
 LSBLK="/bin/lsblk -r --noheadings -o TYPE,KNAME,NAME,MOUNTPOINT"
 LSBLK_VARS="local devtype local kname local name local mnt"
@@ -124,6 +126,7 @@ usage() {
 	echo "    -l | --lvmoptions    LVM_OPTIONS    Comma separated LVM specific options"
 	echo "    -m | --mpathoptions  MPATH_OPTIONS  Comma separated DM-multipath specific options"
 	echo "    -r | --mdraidoptions MDRAID_OPTIONS Comma separated MD RAID specific options"
+        echo "    -o | --vdooptions    VDO_OPTIONS    Comma separated VDO specific options"
 	echo "    -u | --umount                       Unmount the device if mounted"
 	echo "    -v | --verbose                      Verbose mode (also implies -e)"
 	echo
@@ -138,6 +141,8 @@ usage() {
 	echo "      wait            wait for resync, recovery or reshape to complete first"
 	echo "    MPATH_OPTIONS:"
 	echo "      disablequeueing disable queueing on all DM-multipath devices first"
+        echo "    VDO_OPTIONS:"
+        echo "      configfile=file use specified VDO configuration file"
 
 	exit
 }
@@ -319,6 +324,23 @@ deactivate_md () {
 	fi
 }
 
+deactivate_vdo() {
+        local xname
+        xname=$(printf "%s" "$name")
+        test -b "$DEV_DIR/mapper/$xname" || return 0
+        test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
+
+        deactivate_holders "$DEV_DIR/mapper/$xname" || return 1
+
+        echo -n "  [VDO]: deactivating VDO volume $xname... "
+        if eval "$VDO" stop $VDO_OPTS --name="$xname" "$OUT" "$ERR"; then
+                echo "done"
+        else
+                echo "skipping"
+                add_device_to_skip_list
+        fi
+}
+
 deactivate () {
 	######################################################################
 	# DEACTIVATION HOOKS FOR NEW DEVICE TYPES GO HERE!                   #
@@ -335,6 +357,8 @@ deactivate () {
 	######################################################################
 	if test "$devtype" = "lvm"; then
 		deactivate_lvm
+        elif test "$devtype" = "vdo"; then
+                deactivate_vdo
 	elif test "${kname:0:3}" = "dm-"; then
 		deactivate_dm
 	elif test "${kname:0:2}" = "md"; then
@@ -479,6 +503,20 @@ get_mpathopts() {
 	IFS=$ORIG_IFS
 }
 
+get_vdoopts() {
+        ORIG_IFS=$IFS; IFS=','
+
+        for opt in $1; do
+                case "$opt" in
+                        "") ;;
+                        configfile=*) tmp=${opt#*=}; VDO_OPTS+="--confFile=${tmp%%,*} " ;;
+                        *) echo "$opt: unknown VDO option"
+                esac
+        done
+
+        IFS=$ORIG_IFS
+}
+
 set_env() {
 	if test "$ERRORS" -eq "1"; then
 		unset ERR
@@ -493,6 +531,7 @@ set_env() {
 		LVM_OPTS+="-vvvv"
 		MDADM_OPTS+="-vv"
 		MPATHD_OPTS+="-v 3"
+                VDO_OPTS+="--verbose "
 	else
 		OUT="1>$DEV_DIR/null"
 	fi
@@ -509,6 +548,12 @@ set_env() {
 		MDADM_AVAILABLE=0
 	fi
 
+        if test -f $VDO; then
+                VDO_AVAILABLE=1
+        else
+                VDO_AVAILABLE=0
+        fi
+
 	MPATHD_RUNNING=0
 	test "$MPATHD_DO_DISABLEQUEUEING" -eq 1 && {
 		if test -f "$MPATHD"; then
@@ -528,6 +573,7 @@ while test $# -ne 0; do
 		"-l"|"--lvmoptions") get_lvmopts "$2" ; shift ;;
 		"-m"|"--mpathoptions") get_mpathopts "$2" ; shift ;;
 		"-r"|"--mdraidoptions") get_mdraidopts "$2"; shift ;;
+                "-o"|"--vdooptions") get_vdoopts "$2"; shift ;;
 		"-u"|"--umount") DO_UMOUNT=1 ;;
 		"-v"|"--verbose") VERBOSE=1 ; ERRORS=1 ;;
 		"-vv") VERBOSE=1 ; ERRORS=1 ; set -x ;;




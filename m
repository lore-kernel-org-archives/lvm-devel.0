From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:34 -0400
Subject: master - blkdeactivate: double quote
Message-ID: <201706292025.v5TKPYJS025675@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=45861557b5b531f828f4d6ed3d0b104144d2d5f8
Commit:        45861557b5b531f828f4d6ed3d0b104144d2d5f8
Parent:        bd359aec86756e2eaa62880855f0c0ff412b6df1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 16:33:00 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

blkdeactivate: double quote

Using double quote to prevent globbing and word splitting.
---
 scripts/blkdeactivate.sh.in |   66 +++++++++++++++++++++---------------------
 1 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 5c1ab82..a497414 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2012-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2017 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -41,7 +41,7 @@ LVM="@sbindir@/lvm"
 MDADM="@sbindir@/mdadm"
 MPATHD="/sbin/multipathd"
 
-if $UMOUNT --help | grep -- "--all-targets" >$DEV_DIR/null; then
+if "$UMOUNT" --help | grep -- "--all-targets" >"$DEV_DIR/null"; then
 	UMOUNT_OPTS="--all-targets "
 else
 	UMOUNT_OPTS=""
@@ -156,9 +156,9 @@ device_umount_one() {
 
 	if test -z "${SKIP_UMOUNT_LIST["$mnt"]}" -a "$DO_UMOUNT" -eq "1"; then
 		echo -n "  [UMOUNT]: unmounting $name ($kname) mounted on $mnt... "
-		if eval $UMOUNT $UMOUNT_OPTS "$(printf "%s" "$mnt")" $OUT $ERR; then
+		if eval "$UMOUNT" $UMOUNT_OPTS "$(printf "%s" "$mnt")" "$OUT" "$ERR"; then
 			echo "done"
-		elif $MOUNTPOINT -q "$mnt"; then
+		elif "$MOUNTPOINT" -q "$mnt"; then
 			echo "skipping"
 			add_device_to_skip_list
 		else
@@ -182,7 +182,7 @@ device_umount() {
 	else
 		while $FINDMNT_READ; do
 			device_umount_one || return 1
-		done <<< "$($FINDMNT $DEV_DIR/$kname)"
+		done <<< "$($FINDMNT "$DEV_DIR/$kname")"
 	fi
 
 }
@@ -194,25 +194,25 @@ deactivate_holders () {
 	# First line on the lsblk output is the device itself - skip it for
 	# the deactivate call as this device is already being deactivated.
 	while $LSBLK_READ; do
-		test -e $SYS_BLK_DIR/$kname || continue
+		test -e "$SYS_BLK_DIR/$kname" || continue
 		# check if the device not on the skip list already
-		test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
+		test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 
 		# try to deactivate the holder
-		test $skip -eq 1 && skip=0 && continue
+		test "$skip" -eq 1 && skip=0 && continue
 		deactivate || return 1
-	done <<< "$($LSBLK $1)"
+	done <<< "$($LSBLK "$1")"
 }
 
 deactivate_dm () {
 	local name=$(printf "%s" "$name")
 	test -b "$DEV_DIR/mapper/$name" || return 0
-	test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
+	test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 
 	deactivate_holders "$DEV_DIR/mapper/$name" || return 1
 
 	echo -n "  [DM]: deactivating $devtype device $name ($kname)... "
-	if eval $DMSETUP $DMSETUP_OPTS remove "$name" $OUT $ERR; then
+	if eval "$DMSETUP" $DMSETUP_OPTS remove "$name" "$OUT" "$ERR"; then
 		echo "done"
 	else
 		echo "skipping"
@@ -223,13 +223,13 @@ deactivate_dm () {
 deactivate_lvm () {
 	local DM_VG_NAME; local DM_LV_NAME; local DM_LV_LAYER
 
-	eval $(eval $DMSETUP splitname --nameprefixes --noheadings --rows "$name" LVM $ERR)
+	eval "$(eval "$DMSETUP" splitname --nameprefixes --noheadings --rows "$name" LVM "$ERR")"
 	test -b "$DEV_DIR/$DM_VG_NAME/$DM_LV_NAME" || return 0
-	test -z ${SKIP_VG_LIST["$DM_VG_NAME"]} || return 1
+	test -z "${SKIP_VG_LIST["$DM_VG_NAME"]}" || return 1
 
-	if test $LVM_DO_WHOLE_VG -eq 0; then
+	if test "$LVM_DO_WHOLE_VG" -eq 0; then
 		# Skip LVM device deactivation if LVM tools missing.
-		test $LVM_AVAILABLE -eq 0 && {
+		test "$LVM_AVAILABLE" -eq 0 && {
 			add_device_to_skip_list
 			return 1
 		}
@@ -240,7 +240,7 @@ deactivate_lvm () {
 		}
 
 		echo -n "  [LVM]: deactivating Logical Volume $DM_VG_NAME/$DM_LV_NAME... "
-		if eval $LVM lvchange $LVM_OPTS --config \'log{prefix=\"\"} $LVM_CONFIG\' -aln $DM_VG_NAME/$DM_LV_NAME $OUT $ERR; then
+		if eval "$LVM" lvchange $LVM_OPTS --config \'log{prefix=\"\"} $LVM_CONFIG\' -aln "$DM_VG_NAME/$DM_LV_NAME" "$OUT" "$ERR"; then
 			echo "done"
 		else
 			echo "skipping"
@@ -249,12 +249,12 @@ deactivate_lvm () {
 
 	else
 		# Skip LVM VG deactivation if LVM tools missing.
-		test $LVM_AVAILABLE -eq 0 && {
+		test "$LVM_AVAILABLE" -eq 0 && {
 			add_vg_to_skip_list
 			return 1
 		}
 		# Deactivating the whole VG the LV is part of
-		lv_list=$(eval $LVM vgs --config "$LVM_CONFIG" --noheadings --rows -o lv_name $DM_VG_NAME $ERR)
+		lv_list=$(eval "$LVM" vgs --config "$LVM_CONFIG" --noheadings --rows -o lv_name "$DM_VG_NAME" "$ERR")
 		for lv in $lv_list; do
 			test -b "$DEV_DIR/$DM_VG_NAME/$lv" || continue
 			deactivate_holders "$DEV_DIR/$DM_VG_NAME/$lv" || {
@@ -264,7 +264,7 @@ deactivate_lvm () {
 		done
 
 		echo -n "  [LVM]: deactivating Volume Group $DM_VG_NAME... "
-		if eval $LVM vgchange $LVM_OPTS --config \'log{prefix=\"    \"} $LVM_CONFIG\' -aln $DM_VG_NAME $OUT $ERR; then
+		if eval "$LVM" vgchange $LVM_OPTS --config \'log{prefix=\"    \"} $LVM_CONFIG\' -aln "$DM_VG_NAME" "$OUT" "$ERR"; then
 			echo "done"
 		else
 			echo "skipping"
@@ -276,10 +276,10 @@ deactivate_lvm () {
 deactivate_md () {
 	local name=$(printf "%s" "$name")
 	test -b "$DEV_DIR/$name" || return 0
-	test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
+	test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 
 	# Skip MD device deactivation if MD tools missing.
-	test $MDADM_AVAILABLE -eq 0 && {
+	test "$MDADM_AVAILABLE" -eq 0 && {
 		add_device_to_skip_list
 		return 1
 	}
@@ -287,7 +287,7 @@ deactivate_md () {
 	deactivate_holders "$DEV_DIR/$name" || return 1
 
 	echo -n "  [MD]: deactivating $devtype device $kname... "
-	if eval $MDADM $MDADM_OPTS -S "$name" $OUT $ERR; then
+	if eval "$MDADM" $MDADM_OPTS -S "$name" "$OUT" "$ERR"; then
 		echo "done"
 	else
 		echo "skipping"
@@ -324,9 +324,9 @@ deactivate_all() {
 
 	echo "Deactivating block devices:"
 
-	test $MPATHD_RUNNING -eq 1 && {
+	test "$MPATHD_RUNNING" -eq 1 && {
 		echo -n "  [DM]: disabling queueing on all multipath devices... "
-		eval $MPATHD $MPATHD_OPTS disablequeueing maps $ERR | grep '^ok$' >$DEV_DIR/null && echo "done" || echo "failed"
+		eval "$MPATHD" $MPATHD_OPTS disablequeueing maps "$ERR" | grep '^ok$' >"$DEV_DIR/null" && echo "done" || echo "failed"
 	}
 
 	if test $# -eq 0; then
@@ -347,13 +347,13 @@ deactivate_all() {
 			# if deactivation of any device fails, skip processing
 			# any subsequent devices within its subtree as the
 			# top-level device could not be deactivated anyway
-			test $skip -eq 1 && {
+			test "$skip" -eq 1 && {
 				# reset 'skip' on top level device
 				is_top_level_device && skip=0 || continue
 			}
 
 			# check if the device is not on the skip list already
-			test -z ${SKIP_DEVICE_LIST["$kname"]} || continue
+			test -z "${SKIP_DEVICE_LIST["$kname"]}" || continue
 
 			# try to deactivate top-level device, set 'skip=1'
 			# if it fails to do so - this will cause all the
@@ -370,15 +370,15 @@ deactivate_all() {
 			# Unmount all relevant mountpoints first
 			while $LSBLK_READ; do
 				device_umount
-			done <<< "$($LSBLK $1 | $SORT_MNT)"
+			done <<< "$($LSBLK "$1" | $SORT_MNT)"
 
 			# Do deactivate
 			# Single dm device tree deactivation.
 			if test -b "$1"; then
-				$LSBLK_READ <<< "$($LSBLK --nodeps $1)"
+				$LSBLK_READ <<< "$($LSBLK --nodeps "$1")"
 
 				# check if the device is not on the skip list already
-				test -z ${SKIP_DEVICE_LIST["$kname"]} || {
+				test -z "${SKIP_DEVICE_LIST["$kname"]}" || {
 					shift
 					continue
 				}
@@ -455,7 +455,7 @@ set_env() {
 		OUT="1>$DEV_DIR/null"
 	fi
 
-	if test -f $LVM; then
+	if test -f "$LVM"; then
 		LVM_AVAILABLE=1
 	else
 		LVM_AVAILABLE=0
@@ -468,9 +468,9 @@ set_env() {
 	fi
 
 	MPATHD_RUNNING=0
-	test $MPATHD_DO_DISABLEQUEUEING -eq 1 && {
-		if test -f $MPATHD; then
-			if eval $MPATHD show daemon $ERR | grep "running" >$DEV_DIR/null; then
+	test "$MPATHD_DO_DISABLEQUEUEING" -eq 1 && {
+		if test -f "$MPATHD"; then
+			if eval "$MPATHD" show daemon "$ERR" | grep "running" >"$DEV_DIR/null"; then
 				MPATHD_RUNNING=1
 			fi
 		fi



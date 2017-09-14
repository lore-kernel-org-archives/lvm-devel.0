From: Zhang Huan <zhanghuan@huayun.com>
Date: Thu, 14 Sep 2017 15:37:16 +0800
Subject: [Patch review 0/1] introduce lvm forcevg option to forcibly deactivate the whole vg
Message-ID: <64076DFF-B489-4F67-A0EB-F0F41DFBD314@huayun.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

commit 92ded9af9809dd0f4233bacaafab3e7942a6afff
Author: Huan Zhang <zhanghuan@chinac.com>
Date:   Thu Sep 14 15:25:05 2017 +0800

    introduce lvm forcevg option to forcibly deactivate the whole vg
    
    the primary job of this option is to flush in-flight io and
    replace the lv dm table with 'error' target(using dmsetup wipe_table)
    as soon as possible. so it will not deactivate holders and not try to
    lvchange first before wipe_table. it's supposed to be used in
    'lvmlockctl --kill vgname' to force deactivate vg and drop locks before
    sanlock watchdog reset host.
    
    Signed-off-by: Zhang Huan <zhanghuan@huayun.com>

diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index 9a0e84e..b0ae114 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -50,6 +50,15 @@ Retry removal several times in case of failure.
 Deactivate the whole LVM Volume Group when processing a Logical Volume.
 Deactivating the Volume Group as a whole is quicker than deactivating
 each Logical Volume separately.
+.IP \fIforcevg\fP
+Forcibly deactivate the whole LVM Volume Group as soon as possible.
+The primary job of this option is to flush the in-flight io and
+then replace the lv dm table with 'error' target. (using dmsetup
+wipe_table). After that, it's safe to do drop locks.
+Disablequeueing if lv setup on multipath device.
+This option is usually used in sanlock('lvmlockctl --kill')
+fence procedure to avoid host reset.
+Any other options(e.g. -d retry|force, -u) will be ignored.
 .RE
 .TP
 .BR -m ", " --mpathoption \ \fImpath_options\fP
@@ -99,6 +108,12 @@ Volume Group at once when processing an LVM Logical Volume.
 .B blkdeactivate -u -d retry -l wholevg
 .BR
 .P
+Force deactivate the whole vg.
+.BR
+#
+.B blkdeactivate -l forcevg testvg
+.BR
+.P
 Deactivate all supported block devices found in the system. If the deactivation
 of a device-mapper device fails, retry it and force removal.
 .BR
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 969eace..f7296f2 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -68,6 +68,8 @@ DO_UMOUNT=0
 
 # Deactivate each LV separately by default (not the whole VG).
 LVM_DO_WHOLE_VG=0
+# Force deactivate the whole VG
+LVM_DO_FORCE_VG=0
 # Do not retry LV deactivation by default.
 LVM_CONFIG="activation{retry_deactivation=0}"
 
@@ -128,6 +130,7 @@ usage() {
 	echo "    LVM_OPTIONS:"
 	echo "      retry           retry removal several times in case of failure"
 	echo "      wholevg         deactivate the whole VG when processing an LV"
+	echo "      forcevg         force deactivate(wipe_table) the whole VG"
 	echo "    MPATH_OPTIONS:"
 	echo "      disablequeueing disable queueing on all DM-multipath devices first"
 
@@ -275,6 +278,89 @@ deactivate_lvm () {
 	fi
 }
 
+
+is_top_level_lv() {
+	is_top_level_device && return 0
+	skip=1
+	while $LSBLK_READ; do
+		# First line self device
+		test "$skip" -eq 1 && skip=0 && continue
+
+		# not top device but top lv in this VG, return 0
+		test "$devtype" != "lvm" && return 0
+		test ${name:0:${#DM_VG_NAME}+1} != $DM_VG_NAME"-" && return 0
+		test ${name:0:${#DM_VG_NAME}+2} = $DM_VG_NAME"--" && return 0
+		# the same vg, hidden lv
+		test ${name:0:${#DM_VG_NAME}+1} = $DM_VG_NAME"-" && return 1
+	done <<< "$($LSBLK $DEV_DIR/$kname)"
+}
+
+deactivate_vg () {
+	local VG_NAME; local LV_NAME;
+	local DM_VG_NAME; local DM_LV_NAME;
+	local LVS;
+	local skip_disablequeue=0
+
+	VG_NAME=$name
+	DM_VG_NAME=${name/-/--}
+	test -z "${SKIP_VG_LIST["$DM_VG_NAME"]}" || return 1
+	test "$LVM_AVAILABLE" -eq 0 && {
+		add_device_to_skip_list
+		return 1
+	}
+
+	LVS=()
+	while $LSBLK_READ; do
+		test "$devtype" != "lvm" && continue
+		test ${name:0:${#DM_VG_NAME}+1} != $DM_VG_NAME"-" && continue
+		# vg name may contain '-' character, DM and LSBLK print as '--'
+		test ${name:0:${#DM_VG_NAME}+2} = $DM_VG_NAME"--" && continue
+		DM_LV_NAME=${name:${#DM_VG_NAME}+1:${#name}}
+		# skip lvmlock
+		test "$DM_LV_NAME" = "lvmlock" && continue
+		is_top_level_lv || continue
+		LVS=(${LVS[@]} $DM_LV_NAME)
+	done <<< "$($LSBLK -s)"
+
+	for DM_LV_NAME in ${LVS[@]}; do
+		LV_NAME=${DM_LV_NAME/--/-}
+		DEV_PATH=$DEV_DIR/$VG_NAME/$LV_NAME
+
+		if ! test -b $DEV_DIR/$VG_NAME/$LV_NAME; then
+			found_dm_dev=0
+			while $LSBLK_READ; do
+				if test $name = $DM_VG_NAME"-"$DM_LV_NAME; then
+					DEV_PATH="$DEV_DIR/$kname"
+					found_dm_dev=1
+				fi
+			done <<< "$($LSBLK -s)"
+			# device may have deactivated right now
+			# for example: deactivate lv will deactivate it's snaps together.
+			test $found_dm_dev -eq 0 && continue;
+		fi
+
+		# disablequeueing for mpath, do it only once for the whole vg
+		while $LSBLK_READ; do
+			if test $devtype = 'mpath' && test $skip_disablequeue -ne 1; then
+				echo -n "  [DM]: disabling queueing on multipath device $name... "
+				eval "$MPATHD" $MPATHD_OPTS disablequeueing map $name "$ERR" | grep '^ok$' >"$DEV_DIR/null" && echo "done" || echo "failed"
+				skip_disablequeue=1
+			fi
+		done <<< "$($LSBLK -s $DEV_PATH)"
+
+		echo -n "  [LVM]: force deactivating Logical Volume $VG_NAME/$LV_NAME... "
+		# sanlock only give us a short time to drop locks before reset host,
+		# so the primary job is to flush inflight io and replace dm table with 'error' target(wipe_table).
+		# skip try to lvchange first because it may hang for a long time for bad device.
+		if eval "$DMSETUP" $DMSETUP_OPTS wipe_table "$DM_VG_NAME"-"$DM_LV_NAME" "$OUT" "$ERR"; then
+			echo "wipe table done"
+		else
+			echo "wipe table failed" && return 1
+		fi
+	done
+}
+
+
 deactivate_md () {
 	local name
 
@@ -313,7 +399,9 @@ deactivate () {
 	# deactivate_holders first to recursively deactivate any existing    #
 	# holders it might have before deactivating the device it processes. #
 	######################################################################
-	if test "$devtype" = "lvm"; then
+	if test "$devtype" = "vg"; then
+		deactivate_vg
+	elif test "$devtype" = "lvm"; then
 		deactivate_lvm
 	elif test "${kname:0:3}" = "dm-"; then
 		deactivate_dm
@@ -375,14 +463,17 @@ deactivate_all() {
 		##################################
 
 		while test $# -ne 0; do
-			# Unmount all relevant mountpoints first
-			while $LSBLK_READ; do
-				device_umount
-			done <<< "$($LSBLK "$1" | $SORT_MNT)"
+			# Force deactivate the whole vg
+			if test $LVM_DO_FORCE_VG -ne 0; then
+				$LSBLK_READ <<< "vg $1 $1"
+				deactivate || return 1
+			elif -b "$1"; then
+				# Single dm device tree deactivation.
+				# Unmount all relevant mountpoints first
+				while $LSBLK_READ; do
+					device_umount
+				done <<< "$($LSBLK "$1" | $SORT_MNT)"
 
-			# Do deactivate
-			# Single dm device tree deactivation.
-			if test -b "$1"; then
 				$LSBLK_READ <<< "$($LSBLK --nodeps "$1")"
 
 				# check if the device is not on the skip list already
@@ -424,6 +515,7 @@ get_lvmopts() {
 			"") ;;
 			"retry") LVM_CONFIG="activation{retry_deactivation=1}" ;;
 			"wholevg") LVM_DO_WHOLE_VG=1 ;;
+			"forcevg") LVM_DO_FORCE_VG=1 ;;
 			*) echo "$opt: unknown LVM option"
 		esac
 	done




From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 25 Feb 2021 19:04:50 +0800
Subject: [PATCH LVM2 v1 1/2] blkdeactive: Introduce option "forcevg" to forcibly deactivate VG
Message-ID: <20210225110451.175956-1-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Zhang Huan <zhanghuan@huayun.com>

This patch introduces new option "forcevg" for LVM, the main purpose is
to flush in-flight I/O operations and replace the LV's device mapper
table with 'error' target, this is accomplished by using command
"dmsetup wipe_table".

To handle the failure as soon as possible, it will not deactivate
holders and not try to use command "lvchange", thus can speed up
wiping table.

This option is supposed to be used by "lvmlockctl" command to forcibly
deactivate volume group, this can avoid watchdog reset when detect
drive failures.

Signed-off-by: Zhang Huan <zhanghuan@huayun.com>
[Refactored changes and commit log]
Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 man/blkdeactivate.8_main    | 17 +++++++++++
 scripts/blkdeactivate.sh.in | 71 +++++++++++++++++++++++++++++++++++++++------
 2 files changed, 79 insertions(+), 9 deletions(-)

diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index f3c19a8..33f410c 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -51,6 +51,17 @@ Retry removal several times in case of failure.
 Deactivate the whole LVM Volume Group when processing a Logical Volume.
 Deactivating the Volume Group as a whole is quicker than deactivating
 each Logical Volume separately.
+.IP \fIforcevg\fP
+Forcibly deactivate the whole LVM Volume Group as soon as possible.
+The primary job of this option is to flush the in-flight I/O operation
+and then replace the LV's device-mapper table with 'error' target.
+This is accomplished by using command "dmsetup wipe_table". After that,
+any applications on the host cannot access the device anymore, so even
+the LV's lock is expired, it's safe for without data corruption and can
+avoid watchdog resetting.
+This option is usually used for sanlock's fence procedure to avoid host
+reset. When this option is used, any other options
+(e.g. "-d retry|force", "-u") will be ignored.
 .RE
 .TP
 .BR -m ", " --mpathoptions \ \fImpath_options\fP
@@ -108,6 +119,12 @@ Volume Group at once when processing an LVM Logical Volume.
 .B blkdeactivate -u -d retry -l wholevg
 .BR
 .P
+Forcibly deactivate the whole vg.
+.BR
+#
+.B blkdeactivate -l forcevg testvg
+.BR
+.P
 Deactivate all supported block devices found in the system. If the deactivation
 of a device-mapper device fails, retry it and force removal.
 .BR
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index a4b8a8f..833e3f3 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -70,6 +70,8 @@ DO_UMOUNT=0
 
 # Deactivate each LV separately by default (not the whole VG).
 LVM_DO_WHOLE_VG=0
+# Forcily deactivate the whole VG by wiping DM table
+LVM_DO_FORCE_VG=0
 # Do not retry LV deactivation by default.
 LVM_CONFIG="activation{retry_deactivation=0}"
 
@@ -134,6 +136,7 @@ usage() {
 	echo "    LVM_OPTIONS:"
 	echo "      retry           retry removal several times in case of failure"
 	echo "      wholevg         deactivate the whole VG when processing an LV"
+	echo "      forcevg         force deactivate (wipe_table) the whole VG"
 	echo "    MDRAID_OPTIONS:"
 	echo "      wait            wait for resync, recovery or reshape to complete first"
 	echo "    MPATH_OPTIONS:"
@@ -282,6 +285,50 @@ deactivate_lvm () {
 	fi
 }
 
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
+	# The lock manager (e.g. sanlock) only give a short time to handle failure
+	# before reset host, so replace DM table with 'error' target.
+	# The reason for not using command "lvchange" ahead if because it may hang
+	# for a long time for the failed device.
+	echo -n "  [LVM]: force deactivating Logical Volumes for $VG_NAME... "
+	"$DMSETUP" info -c -S "uuid=~LVM && vgname=$VG_NAME && lv_layer=\"\"" \
+		-o name --noheadings | xargs "$DMSETUP" wipe_table
+	if [ "$?" = "0" ]; then
+		echo "wipe table done"
+	else
+		echo "wipe table failed" && return 1
+	fi
+}
+
 deactivate_md () {
 	local xname
 	xname=$(printf "%s" "$name")
@@ -333,7 +380,9 @@ deactivate () {
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
@@ -395,14 +444,17 @@ deactivate_all() {
 		##################################
 
 		while test $# -ne 0; do
-			# Unmount all relevant mountpoints first
-			while $LSBLK_READ; do
-				device_umount
-			done <<< "$($LSBLK "$1" | $SORT_MNT)"
-
-			# Do deactivate
-			# Single dm device tree deactivation.
-			if test -b "$1"; then
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
+
 				$LSBLK_READ <<< "$($LSBLK --nodeps "$1")"
 
 				# check if the device is not on the skip list already
@@ -444,6 +496,7 @@ get_lvmopts() {
 			"") ;;
 			"retry") LVM_CONFIG="activation{retry_deactivation=1}" ;;
 			"wholevg") LVM_DO_WHOLE_VG=1 ;;
+			"forcevg") LVM_DO_FORCE_VG=1 ;;
 			*) echo "$opt: unknown LVM option"
 		esac
 	done
-- 
1.8.3.1



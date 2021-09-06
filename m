From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  6 Sep 2021 13:25:11 +0000 (GMT)
Subject: main - vdo: more lvm_import_vdo fixes
Message-ID: <20210906132511.857A03858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89595a366554191c3df1a18e1f82b79c450a21ad
Commit:        89595a366554191c3df1a18e1f82b79c450a21ad
Parent:        3287d37f440ca272b52f900fc60ee5effcf73697
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 6 15:06:32 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 6 15:19:51 2021 +0200

vdo: more lvm_import_vdo fixes

Do not call 'dmsetup info' for non-dm devices.

Better handling for VGNAME and LVNAME - so when convering LV as
backend device automatically recognize it and reuse LV name for VDOLV.

Add prompt for final confirmation before actual conversion is started
(once confirmed, lvm2 commands no longer prompts to avoid leaving
conversion in the middle of its process.)
---
 scripts/lvm_import_vdo.sh | 48 ++++++++++++++++++++++++++++++++++------
 test/shell/vdo-convert.sh | 56 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 97 insertions(+), 7 deletions(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 685821f13..39a320c84 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -50,6 +50,7 @@ DM_DEV_DIR="${DM_DEV_DIR:-/dev}"
 DEVICENAME=""
 DEVMAJOR=0
 DEVMINOR=0
+PROMPTING=""
 
 DRY=0
 VERB=""
@@ -57,7 +58,8 @@ FORCE=""
 YES=""
 
 # default name for converted VG and its VDO LV
-NAME="vdovg/vdolvol"
+DEFAULT_NAME="vdovg/vdolvol"
+NAME=""
 
 # help message
 tool_usage() {
@@ -100,6 +102,7 @@ dry() {
 cleanup() {
 	trap '' 2
 
+	test -z "$PROMPTING" || echo "No"
 	rm -rf "$TEMPDIR"
 	# error exit status for break
 	exit "${1:-1}"
@@ -175,7 +178,9 @@ detect_lv_() {
 		;;
 	esac
 
-	DEV="$("$DMSETUP" info -c -j "$DEVMAJOR" -m "$DEVMINOR" -o uuid,name --noheadings --nameprefixes --separator ' ' 2>/dev/null)"
+	test "$DEVMAJOR" != "$(grep device-mapper /proc/devices | cut -f1 -d' ')" && return
+
+	DEV="$("$DMSETUP" info -c -j "$DEVMAJOR" -m "$DEVMINOR" -o uuid,name --noheadings --nameprefixes --separator ' ')"
 	case "$DEV" in
 	Device*)  ;; # no devices
 	*)	eval "$DEV" ;;
@@ -244,15 +249,31 @@ convert2lvm_() {
 	detect_lv_ "$DEVICE"
 	case "$DM_UUID" in
 		LVM-*)	eval "$("$DMSETUP" splitname --nameprefixes --noheadings --separator ' ' "$DM_NAME")"
-			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ]  ; then
+			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ] ; then
 				VGNAME=$DM_VG_NAME
-				LVNAME=$DM_LV_NAME
+				verbose "Using existing volume group name $VGNAME."
+				test -n "$LVNAME" || LVNAME=$DM_LV_NAME
 			elif test "$VGNAME" != "$DM_VG_NAME" ; then
-				error "Volume group name \"$VGNAME\" does not match name \"$DM_VG_NAME\" for device \"$DEVICE\"."
+				error "Volume group name \"$VGNAME\" does not match name \"$DM_VG_NAME\" for VDO device \"$DEVICE\"."
 			fi
 			;;
-		*) IS_LV=0
-			# Check $VGNANE does not already exists
+		*)	IS_LV=0
+			# Check if we need to generate unused $VGNANE
+			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ] ; then
+				VGNAME=${DEFAULT_NAME%/*}
+				# Find largest matching VG name to our 'default' vgname
+				LASTVGNAME=$(LC_ALL=C "$LVM" vgs -oname -O-name --noheadings -S name=~${VGNAME} | grep -E "$VGNAME[0-9]? ?" | head -1)
+				if test -n "$LASTVGNAME" ; then
+					LASTVGNAME=${LASTVGNAME#*${VGNAME}}
+					# If the number is becoming too high, try some random number
+					test "$LASTVGNAME" -gt 99999999 2>/dev/null && LASTVGNAME=$RANDOM
+					# Generate new unused VG name
+					VGNAME="${VGNAME}$(( ${LASTVGNAME} + 1 ))"
+					verbose "Selected unused volume group name $VGNAME."
+				fi
+			fi
+			# New VG is created, LV name should be always unused.
+			test -n "$LVNAME" || LVNAME=${DEFAULT_NAME#*/}
 			"$LVM" vgs "$VGNAME" >/dev/null 2>&1 && error "Cannot use already existing volume group name \"$VGNAME\"."
 			;;
 	esac
@@ -328,6 +349,19 @@ EOF
 )
 	verbose "VDO conversion paramaters: $PARAMS"
 
+	# If user has not provided '--yes', prompt before conversion
+	if test -z "$YES" ; then
+		PROMPTING=yes
+		echo -n "Convert VDO device \"$DEVICE\" to VDO LV \"$VGNAME/$LVNAME\"? [y|N]: "
+		read -n 1 -s ANSWER
+		case "${ANSWER:0:1}" in
+			y|Y )  echo "Yes" ;;
+			* )    echo "No" ; PROMPTING=""; exit ;;
+		esac
+		PROMPTING=""
+		YES="-y" # From now, now prompting
+	fi
+
 	verbose "Stopping VDO volume."
 	dry "$VDO" stop $VDOCONF --name "$VDONAME"
 
diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
index 493f415d4..632f86a36 100644
--- a/test/shell/vdo-convert.sh
+++ b/test/shell/vdo-convert.sh
@@ -122,3 +122,59 @@ fsck -n "$DM_DEV_DIR/$vg1/$lv2"
 
 vgremove -f $vg1
 
+aux teardown_devs
+
+
+# Check with some real non-DM device from system
+# this needs to dropping DM_DEV_DIR
+
+aux prepare_loop 60000 || skip
+
+test -f LOOP
+LOOP=$(< LOOP)
+
+aux extend_filter "a|$LOOP|"
+aux extend_devices "$LOOP"
+
+#
+# Unfortunatelly generates this in syslog:
+#
+# vdo-start-by-dev at loop0.service: Main process exited, code=exited, status=1/FAILURE
+# vdo-start-by-dev@loop0.service: Failed with result 'exit-code'.
+# Failed to start Start VDO volume backed by loop0.
+#
+# TODO:  Could be handled by:
+#
+# systemctl mask vdo-start-by-dev@
+# systemctl unmask vdo-start-by-dev@
+#
+# automate...
+#
+vdo create $VDOCONF --name "$VDONAME" --device="$LOOP" --vdoLogicalSize=23G \
+	--blockMapCacheSize 192 \
+	--blockMapPeriod 2048 \
+	--emulate512 disabled \
+	--indexMem 0.5 \
+	--maxDiscardSize 10 \
+	--sparseIndex disabled \
+	--vdoAckThreads 2 \
+	--vdoBioRotationInterval 8 \
+	--vdoBioThreads 2 \
+	--vdoCpuThreads 5 \
+	--vdoHashZoneThreads 3 \
+	--vdoLogicalThreads 3 \
+	--writePolicy async-unsafe
+
+# Get VDO table line
+dmsetup table "$VDONAME" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee vdo-orig
+
+DM_DEV_DIR= lvm_import_vdo -y --name $vg/$lv "$LOOP"
+lvs -a $vg
+
+dmsetup table "$vg-${lv}_vpool-vpool" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee new-vdo-lv
+
+# Check there is a match between VDO and LV managed volume
+# (when differentiating parameters are deleted first)
+diff -u vdo-orig new-vdo-lv || die "Found mismatching VDO table lines!"
+
+check lv_field $vg/$lv size "23.00g"



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 31 Aug 2021 20:06:10 +0000 (GMT)
Subject: main - vdo: fixes
Message-ID: <20210831200610.5CF1F385840A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ae157a0f67e984ef3037d19d62b84a3b0201c84
Commit:        1ae157a0f67e984ef3037d19d62b84a3b0201c84
Parent:        419c93c87358ad311aa78dcd6fd8298325356df4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 31 20:52:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 31 22:05:47 2021 +0200

vdo: fixes

Better identify VDO device with major:minor.
Handle different LV name from originally converted origin LV.
Improve --dry-run handling.
---
 WHATS_NEW                 |  4 +++
 scripts/lvm_import_vdo.sh | 70 +++++++++++++++++++++++++++++++++++------------
 test/shell/vdo-convert.sh | 28 ++++++++++++++-----
 3 files changed, 78 insertions(+), 24 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ea434e2c6..90fe1b676 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.03.14 - 
 ==================================
+  Improve lvm_import_vdo script.
+  Support VDO LV with lvcreate -ky.
+  Fix lvconvert for VDO LV bigger then 2T.
+  Create VDO LVs automatically without zeroing.
   Rename vdoimport to lvm_import_vdo.
 
 Version 2.03.13 - 11th August 2021
diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 7e24b49d7..ae2892949 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -41,10 +41,15 @@ BLOCKDEV="blockdev"
 READLINK="readlink"
 READLINK_E="-e"
 MKDIR="mkdir"
+DMSETUP="dmsetup"
 
 TEMPDIR="${TMPDIR:-/tmp}/${TOOL}_${RANDOM}$$"
 DM_DEV_DIR="${DM_DEV_DIR:-/dev}"
 
+DEVICENAME=""
+DEVMAJOR=0
+DEVMINOR=0
+
 DRY=0
 VERB=""
 FORCE=""
@@ -147,8 +152,6 @@ get_largest_extent_size_() {
 # dereference device name if it is symbolic link
 detect_lv_() {
 	local DEVICE=$1
-	local MAJOR
-	local MINOR
 	local SYSVOLUME
 	local MAJORMINOR
 
@@ -161,17 +164,21 @@ detect_lv_() {
 	  /dev/dm-[0-9]*)
 		read -r <"/sys/block/${RDEVICE#/dev/}/dm/name" SYSVOLUME 2>&1 && DEVICE="$DM_DEV_DIR/mapper/$SYSVOLUME"
 		read -r <"/sys/block/${RDEVICE#/dev/}/dev" MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$DEVICE\"."
-		MAJOR=${MAJORMINOR%%:*}
-		MINOR=${MAJORMINOR##*:}
+		DEVMAJOR=${MAJORMINOR%%:*}
+		DEVMINOR=${MAJORMINOR##*:}
 		;;
 	  *)
-		STAT=$(stat --format "MAJOR=\$((0x%t)) MINOR=\$((0x%T))" "$RDEVICE")
+		STAT=$(stat --format "DEVMAJOR=\$((0x%t)) DEVMINOR=\$((0x%T))" "$RDEVICE")
 		test -n "$STAT" || error "Cannot get major:minor for \"$DEVICE\"."
 		eval "$STAT"
 		;;
 	esac
 
-	eval "$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o uuid,name --noheadings --nameprefixes --separator ' ')"
+	DEV="$("$DMSETUP" info -c -j "$DEVMAJOR" -m "$DEVMINOR" -o uuid,name --noheadings --nameprefixes --separator ' ' 2>/dev/null)"
+	case "$DEV" in
+	Device*)  ;; # no devices
+	*)	eval "$DEV" ;;
+	esac
 }
 
 # parse yaml config files into 'prefix_yaml_part_names=("value")' strings
@@ -226,20 +233,26 @@ convert2lvm_() {
 	local TRVDONAME
 	local EXTENTSZ
 	local IS_LV=1
+	local FOUND=""
+	local MAJOR=0
+	local MINOR=0
+	local DM_VG_NAME
+	local DM_LV_NAME
 
 	DM_UUID=""
 	detect_lv_ "$DEVICE"
 	case "$DM_UUID" in
-		LVM-*)	eval "$(dmsetup splitname --nameprefixes --noheadings --separator ' ' "$DM_NAME")"
+		LVM-*)	eval "$("$DMSETUP" splitname --nameprefixes --noheadings --separator ' ' "$DM_NAME")"
 			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ]  ; then
 				VGNAME=$DM_VG_NAME
+				LVNAME=$DM_LV_NAME
 			elif test "$VGNAME" != "$DM_VG_NAME" ; then
 				error "Volume group name \"$VGNAME\" does not match name \"$DM_VG_NAME\" for device \"$DEVICE\"."
 			fi
 			;;
 		*) IS_LV=0
 			# Check $VGNANE does not already exists
-			"$LVM" vgs "$VGNAME" && error "Cannot use already existing volume group name \"$VGNAME\"."
+			"$LVM" vgs "$VGNAME" >/dev/null 2>&1 && error "Cannot use already existing volume group name \"$VGNAME\"."
 			;;
 	esac
 
@@ -247,15 +260,37 @@ convert2lvm_() {
 
 	"$MKDIR" -p -m 0000 "$TEMPDIR" || error "Failed to create $TEMPDIR."
 
+	# TODO: might use directly  /etc/vdoconf.yml (avoding need of 'vdo' manager)
 	verbose "Getting YAML VDO configuration."
 	"$VDO" printConfigFile $VDOCONF >"$TEMPDIR/vdoconf.yml"
 
-	VDONAME=$(awk -v DNAME="$DEVICE" '/.*VDOService$/ {VNAME=substr($1, 0, length($1) - 1)} /[[:space:]]*device:/ { if ($2 ~ DNAME) {print VNAME}}' "$TEMPDIR/vdoconf.yml")
+	# Check list of devices in VDO configure file for their major:minor
+	# and match with given $DEVICE devmajor:devminor
+	for i in $(awk '/.*device:/ {print $2}' "$TEMPDIR/vdoconf.yml") ; do
+		local DEV
+		DEV=$("$READLINK" $READLINK_E "$i") || continue
+		STAT=$(stat --format "MAJOR=\$((0x%t)) MINOR=\$((0x%T))" "$DEV" 2>/dev/null) || continue
+		eval "$STAT"
+		test "$MAJOR" = "$DEVMAJOR" && test "$MINOR" = "$DEVMINOR" && {
+			test -z "$FOUND" || error "VDO configuration contains duplicate entries $FOUND and $i"
+			FOUND=$i
+		}
+	done
+
+	test -n "$FOUND" || error "Can't find matching device in vdo configuration file."
+	verbose "Found matching device $FOUND  $MAJOR:$MINOR"
+
+	VDONAME=$(awk -v DNAME="$FOUND" '/.*VDOService$/ {VNAME=substr($1, 0, length($1) - 1)} /[[:space:]]*device:/ { if ($2 ~ DNAME) {print VNAME}}' "$TEMPDIR/vdoconf.yml")
 	TRVDONAME=$(echo "$VDONAME" | tr '-' '_')
 
 	# When VDO volume is 'active', check it's not mounted/being used
-	eval "$(dmsetup info -c -o open  "$VDONAME" --noheadings --nameprefixes || true)"
-	test "${DM_OPEN:-0}" -eq 0 || error "Cannot converted VDO volume \"$VDONAME\" which is in use!"
+	DM_OPEN="$("$DMSETUP" info -c -o open  "$VDONAME" --noheadings --nameprefixes 2>/dev/null || true)"
+	case "$DM_OPEN" in
+	Device*) ;; # no devices
+	*) 	eval "$DM_OPEN"
+		test "${DM_OPEN:-0}" -eq 0 || error "Cannot converted VDO volume \"$VDONAME\" which is in use!"
+		;;
+	esac
 
 	#parse_yaml_ "$TEMPDIR/vdoconf.yml" _
 	eval "$(parse_yaml_ "$TEMPDIR/vdoconf.yml" _ | grep "$TRVDONAME" | sed -e "s/_config_vdos_$TRVDONAME/vdo/g")"
@@ -263,8 +298,7 @@ convert2lvm_() {
 	vdo_logicalSize=$(get_kb_size_with_unit_ "$vdo_logicalSize")
 	vdo_physicalSize=$(get_kb_size_with_unit_ "$vdo_physicalSize")
 
-	verbose "Going to convert physical sized VDO device $vdo_physicalSize KiB."
-	verbose "With logical volume of size $vdo_logicalSize KiB."
+	verbose "Converted VDO device has logical/physical size $vdo_logicalSize/$vdo_physicalSize KiB."
 
 	PARAMS=$(cat <<EOF
 allocation {
@@ -313,7 +347,7 @@ EOF
 
 		pvfree=$(( pvfree / 1024 - 2048 ))	# to KiB
 	else
-		pvfree=$("$LVM" lvs -o size --units b --nosuffix --noheadings "$VGNAME/$LVNAME")
+		pvfree=$("$LVM" lvs -o size --units b --nosuffix --noheadings "$DM_VG_NAME/$DM_LV_NAME")
 		pvfree=$(( pvfree / 1024 ))		# to KiB
 	fi
 
@@ -334,11 +368,11 @@ EOF
 		vg_extent_size=$(( vg_extent_size / 1024 ))
 
 		test "$vg_extent_size" -le "$EXTENTSZ" || {
-			error "Please vgchange extent_size to at most $EXTENTSZ KiB or extend and align virtual size on $vg_extent_size KiB."
+			error "Please vgchange extent_size to@most $EXTENTSZ KiB or extend and align virtual size of VDO device on $vg_extent_size KiB."
 		}
 		verbose "Renaming existing LV to be used as _vdata volume for VDO pool LV."
-		dry "$LVM" lvrename $YES $VERB "$VGNAME/$LVNAME" "$VGNAME/${LVNAME}_vpool" || {
-			error "Rename of LV \"$VGNAME/$LVNAME\" failed, while VDO header has been already moved!"
+		dry "$LVM" lvrename $YES $VERB "$VGNAME/$DM_LV_NAME" "$VGNAME/${LVNAME}_vpool" || {
+			error "Rename of LV \"$VGNAME/$DM_LV_NAME\" failed, while VDO header has been already moved!"
 		}
 	fi
 
@@ -372,5 +406,7 @@ do
 	shift
 done
 
+test -n "$DEVICENAME" || error "Device name is not specified. (see: $TOOL --help)"
+
 # do conversion
 convert2lvm_ "$DEVICENAME"
diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
index 2d16c973f..493f415d4 100644
--- a/test/shell/vdo-convert.sh
+++ b/test/shell/vdo-convert.sh
@@ -61,22 +61,36 @@ lvm_import_vdo --dry-run -y -v --name $lv1 "$DM_DEV_DIR/$vg/$lv1"
 
 lvm_import_vdo -y --name $lv1 "$DM_DEV_DIR/$vg/$lv1"
 
-# ATM needed - since we do not call 'vdo convert' in this case
-vdo remove $VDOCONF --force --name "$VDONAME" || true
+# ensure VDO device is not left in config file
+vdo remove $VDOCONF --force --name "$VDONAME" 2>/dev/null || true
+
+lvremove -f $vg
+
+
+# Test user can specify different VDO LV name (so the original LV is renamed)
+lvcreate -y -L5G -n $lv1 $vg
+
+vdo create $VDOCONF --name "$VDONAME" --device="$DM_DEV_DIR/$vg/$lv1" --vdoLogicalSize=10G
+
+lvm_import_vdo -y --name $vg/$lv2 "$DM_DEV_DIR/$vg/$lv1"
+
+check lv_exists $vg $lv2
+check lv_not_exists $vg $lv1
 
 vgremove -f $vg
 
+# ensure VDO device is not left in config file
+vdo remove $VDOCONF --force --name "$VDONAME" 2>/dev/null || true
+
 aux wipefs_a "$dev1"
 
 # prepare 'unused' $vg2
 vgcreate $vg2 "$dev2"
 
 #
-# Check conversion of VDO volume on  non-LV device
+# Check conversion of VDO volume on non-LV device and with >2T size
 #
-vdo create $VDOCONF --name "$VDONAME" --device="$dev1" --vdoLogicalSize=31G
-
-mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
+vdo create $VDOCONF --name "$VDONAME" --device="$dev1" --vdoLogicalSize=3T
 
 # Fail with an already existing volume group $vg2
 not lvm_import_vdo --dry-run -y -v --name $vg2/$lv1 "$dev1" |& tee err
@@ -87,7 +101,7 @@ vdo stop $VDOCONF --name "$VDONAME"
 
 lvm_import_vdo -y -v --name $vg/$lv1 "$dev1"
 
-fsck -n "$DM_DEV_DIR/$vg/$lv1"
+check lv_field $vg/$lv1 size "3.00t"
 
 vgremove -f $vg
 



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jul 2021 12:59:21 +0000 (GMT)
Subject: main - vdo: add vdoimport support
Message-ID: <20210709125921.616DF3987018@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed48cb26a31e8e5a12d82d96d8bec6bfc4d5b218
Commit:        ed48cb26a31e8e5a12d82d96d8bec6bfc4d5b218
Parent:        3a92d633a5a23377aa0d5d4ed5a01db8ca14cf69
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 9 14:44:07 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 9 14:57:59 2021 +0200

vdo: add vdoimport support

Add tool 'vdoimport' to support easy conversion of an existing VDO manager managed
VDO volumes into lvm2 managed VDO LV.

When physical converted volume is already a logical volume, conversion
happens with the VG itself, just with validation for extent_size, so
the virtually sized logical VDO volume size can be expressed in extents.

Example of basic simple usage:

vdoimport --name vg/vdolv  /dev/mapper/vdophysicalvolume
---
 WHATS_NEW                 |   1 +
 configure                 |  25 +++
 configure.ac              |  15 ++
 include/configure.h.in    |   3 +
 man/Makefile.in           |   7 +-
 scripts/Makefile.in       |   4 +
 scripts/vdoimport.sh      | 376 ++++++++++++++++++++++++++++++++++++++++++++++
 spec/packages.inc         |   1 +
 test/Makefile.in          |   1 +
 test/shell/vdo-convert.sh | 110 ++++++++++++++
 10 files changed, 542 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8f6dad27a..810411914 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.13 - 
 ===============================
+  Add vdoimport tool to support conversion of VDO volumes.
   Support configurable allocation/vdo_pool_header_size.
   Fix handling of lvconvert --type vdo-pool --virtualsize.
   Simplified handling of archive() and backup() internal calls.
diff --git a/configure b/configure
index 3a9888528..c2d2cff5b 100755
--- a/configure
+++ b/configure
@@ -643,6 +643,8 @@ WRITE_INSTALL
 WRITECACHE
 VDO_LIB
 VDO_INCLUDE
+VDOIMPORT_PATH
+VDOIMPORT
 VDO
 VALGRIND_POOL
 USRSBINDIR
@@ -969,6 +971,7 @@ enable_dbus_service
 enable_pkgconfig
 enable_write_install
 enable_fsadm
+enable_vdoimport
 enable_blkdeactivate
 enable_dmeventd
 enable_selinux
@@ -1707,6 +1710,7 @@ Optional Features:
   --enable-pkgconfig      install pkgconfig support
   --enable-write_install  install user writable files
   --disable-fsadm         disable fsadm
+  --disable-vdoimport     disable vdoimport
   --disable-blkdeactivate disable blkdeactivate
   --enable-dmeventd       enable the device-mapper event daemon
   --disable-selinux       disable selinux support
@@ -3139,6 +3143,7 @@ case "$host_os" in
 		DM_IOCTLS=yes
 		SELINUX=yes
 		FSADM=yes
+		VDOIMPORT=yes
 		BLKDEACTIVATE=yes
 		;;
 	darwin*)
@@ -3152,6 +3157,7 @@ case "$host_os" in
 		DM_IOCTLS=no
 		SELINUX=no
 		FSADM=no
+		VDOIMPORT=no
 		BLKDEACTIVATE=no
 		;;
 	*)
@@ -12544,6 +12550,18 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $FSADM" >&5
 $as_echo "$FSADM" >&6; }
 
+
+################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install vdoimport" >&5
+$as_echo_n "checking whether to install vdoimport... " >&6; }
+# Check whether --enable-vdoimport was given.
+if test "${enable_vdoimport+set}" = set; then :
+  enableval=$enable_vdoimport; VDOIMPORT=$enableval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $VDOIMPORT" >&5
+$as_echo "$VDOIMPORT" >&6; }
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install blkdeactivate" >&5
 $as_echo_n "checking whether to install blkdeactivate... " >&6; }
@@ -14030,6 +14048,13 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
+VDOIMPORT_PATH="$SBINDIR/vdoimport"
+
+cat >>confdefs.h <<_ACEOF
+#define VDOIMPORT_PATH "$VDOIMPORT_PATH"
+_ACEOF
+
+
 ################################################################################
 if test "$BUILD_DMEVENTD" = yes; then
 
diff --git a/configure.ac b/configure.ac
index 40acc49c2..a20633e21 100644
--- a/configure.ac
+++ b/configure.ac
@@ -46,6 +46,7 @@ case "$host_os" in
 		DM_IOCTLS=yes
 		SELINUX=yes
 		FSADM=yes
+		VDOIMPORT=yes
 		BLKDEACTIVATE=yes
 		;;
 	darwin*)
@@ -59,6 +60,7 @@ case "$host_os" in
 		DM_IOCTLS=no
 		SELINUX=no
 		FSADM=no
+		VDOIMPORT=no
 		BLKDEACTIVATE=no
 		;;
 	*)
@@ -1311,6 +1313,14 @@ AC_ARG_ENABLE(fsadm, AC_HELP_STRING([--disable-fsadm], [disable fsadm]),
 	      FSADM=$enableval)
 AC_MSG_RESULT($FSADM)
 
+
+################################################################################
+dnl -- Enable vdoimport
+AC_MSG_CHECKING(whether to install vdoimport)
+AC_ARG_ENABLE(vdoimport, AC_HELP_STRING([--disable-vdoimport], [disable vdoimport]),
+	      VDOIMPORT=$enableval)
+AC_MSG_RESULT($VDOIMPORT)
+
 ################################################################################
 dnl -- Enable blkdeactivate
 AC_MSG_CHECKING(whether to install blkdeactivate)
@@ -1666,6 +1676,9 @@ USRSBINDIR="$(eval echo $(eval echo $usrsbindir))"
 FSADM_PATH="$SBINDIR/fsadm"
 AC_DEFINE_UNQUOTED(FSADM_PATH, ["$FSADM_PATH"], [Path to fsadm binary.])
 
+VDOIMPORT_PATH="$SBINDIR/vdoimport"
+AC_DEFINE_UNQUOTED(VDOIMPORT_PATH, ["$VDOIMPORT_PATH"], [Path to vdoimport binary.])
+
 ################################################################################
 dnl -- dmeventd pidfile and executable path
 if test "$BUILD_DMEVENTD" = yes; then
@@ -1902,6 +1915,8 @@ AC_SUBST(SILENT_RULES)
 AC_SUBST(USRSBINDIR)
 AC_SUBST(VALGRIND_POOL)
 AC_SUBST(VDO)
+AC_SUBST(VDOIMPORT)
+AC_SUBST(VDOIMPORT_PATH)
 AC_SUBST(VDO_FORMAT_CMD)
 AC_SUBST(VDO_INCLUDE)
 AC_SUBST(VDO_LIB)
diff --git a/include/configure.h.in b/include/configure.h.in
index 08f696167..55d18bd4f 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -687,6 +687,9 @@
 /* Enable a valgrind aware build of pool */
 #undef VALGRIND_POOL
 
+/* Path to vdoimport binary. */
+#undef VDOIMPORT_PATH
+
 /* The path to 'vdoformat', if available. */
 #undef VDO_FORMAT_CMD
 
diff --git a/man/Makefile.in b/man/Makefile.in
index 29afc776b..d60a92cde 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -23,6 +23,7 @@ else
 endif
 
 FSADMMAN = fsadm.8
+VDOIMPORTMAN = vdoimport.8
 BLKDEACTIVATEMAN = blkdeactivate.8
 DMEVENTDMAN = dmeventd.8
 DMFILEMAPDMAN = dmfilemapd.8
@@ -50,7 +51,7 @@ MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
 ifeq (,$(findstring $(MAKECMDGOALS), distclean all_man install_all_man))
   MAN7 += lvmcache.7 lvmthin.7 lvmvdo.7
-  MAN8+=$(FSADMMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN)
+  MAN8+=$(FSADMMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN) $(VDOIMPORTMAN)
   MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(DMFILEMAPDMAN)
   MAN8CLUSTER+=$(CMIRRORDMAN)
 else
@@ -58,6 +59,10 @@ else
     MAN8+=$(FSADMMAN)
   endif
 
+  ifeq ("@VDOIMPORT@", "yes")
+    MAN8+=$(VDOIMPORTMAN)
+  endif
+
   ifeq ("@BUILD_LVMDBUSD@", "yes")
     MAN8+=$(LVMDBUSDMAN)
   endif
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index e8f674282..1fe88ca90 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -31,6 +31,10 @@ ifeq ("@FSADM@", "yes")
 	LVM_SCRIPTS += fsadm.sh
 endif
 
+ifeq ("@VDOIMPORT@", "yes")
+	LVM_SCRIPTS += vdoimport.sh
+endif
+
 ifeq ("@BLKDEACTIVATE@", "yes")
 	DM_SCRIPTS += blkdeactivate.sh
 endif
diff --git a/scripts/vdoimport.sh b/scripts/vdoimport.sh
new file mode 100755
index 000000000..ef9659103
--- /dev/null
+++ b/scripts/vdoimport.sh
@@ -0,0 +1,376 @@
+#!/bin/bash
+#
+# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+#
+# Author: Zdenek Kabelac <zkabelac@redhat.com>
+#
+# Script for converting VDO volumes to lvm2 VDO LVs
+#
+# Needed utilities:
+#  lvm, dmsetup,
+#  vdo, vdo2lvm,
+#  grep, awk, sed, blockdev, readlink, mkdir
+#
+# Conversion is using  'vdo convert' support from VDO manager to move
+# existing VDO header by 2M which makes space to place in PV header
+# and VG metadata area, and then create VDOPOOL LV and VDO LV in such VG.
+#
+
+set -euE -o pipefail
+
+TOOL=vdoimport
+
+_SAVEPATH=$PATH
+PATH="/sbin:/usr/sbin:/bin:/usr/sbin:$PATH"
+
+# user may override lvm location by setting LVM_BINARY
+LVM=${LVM_BINARY:-lvm}
+VDO=${VDO_BINARY:-vdo}
+VDOCONF=${VDOCONF:-}
+BLOCKDEV="blockdev"
+READLINK="readlink"
+READLINK_E="-e"
+MKDIR="mkdir"
+
+TEMPDIR="${TMPDIR:-/tmp}/${TOOL}_${RANDOM}$$"
+DM_DEV_DIR="${DM_DEV_DIR:-/dev}"
+
+DRY=0
+VERB=""
+FORCE=""
+YES=""
+
+# default name for converted VG and its VDO LV
+NAME="vdovg/vdolvol"
+
+# help message
+tool_usage() {
+	echo "${TOOL}: Utility to convert VDO volume to VDO LV."
+	echo
+	echo "	${TOOL} [options] <vdo_device_path>"
+	echo
+	echo "	Options:"
+	echo "	  -f | --force	      Bypass sanity checks"
+	echo "	  -h | --help	      Show this help message"
+	echo "	  -n | --name	      Specifies VG/LV name for converted VDO volume"
+	echo "	  -v | --verbose      Be verbose"
+	echo "	  -y | --yes	      Answer \"yes\" at any prompts"
+	echo "	       --dry-run      Print commands without running them"
+
+	exit
+}
+
+verbose() {
+	test -z "$VERB" || echo "$TOOL:" "$@"
+}
+
+# Support multi-line error messages
+error() {
+	for i in "$@" ;  do
+		echo "$TOOL: $i" >&2
+	done
+	cleanup 1
+}
+
+dry() {
+	if [ "$DRY" -ne 0 ]; then
+		verbose "Dry execution" "$@"
+		return 0
+	fi
+	verbose "Executing" "$@"
+	"$@"
+}
+
+cleanup() {
+	trap '' 2
+
+	rm -rf "$TEMPDIR"
+	# error exit status for break
+	exit "${1:-1}"
+}
+
+get_enabled_value_() {
+	case "$1" in
+	enabled) echo "1" ;;
+	*) echo "0" ;;
+	esac
+}
+
+get_kb_size_with_unit_() {
+	case "$1" in
+	*[kK]) echo $(( ${1%[kK]} )) ;;
+	*[mM]) echo $(( ${1%[mM]} * 1024 )) ;;
+	*[gG]) echo $(( ${1%[gG]} * 1024 * 1024 )) ;;
+	*[tT]) echo $(( ${1%[tT]} * 1024 * 1024 * 1024 )) ;;
+	*[pP]) echo $(( ${1%[pP]} * 1024 * 1024 * 1024 * 1024 )) ;;
+	esac
+}
+
+get_mb_size_with_unit_() {
+	case "$1" in
+	*[mM]) echo $(( ${1%[mM]} )) ;;
+	*[gG]) echo $(( ${1%[gG]} * 1024 )) ;;
+	*[tT]) echo $(( ${1%[tT]} * 1024 * 1024 )) ;;
+	*[pP]) echo $(( ${1%[pP]} * 1024 * 1024 * 1024 )) ;;
+	esac
+}
+
+# Figure out largest possible extent size usable for VG
+# $1   physical size
+# $2   logical size
+get_largest_extent_size_() {
+	local max=4
+	local i
+	local d
+
+	for i in 8 16 32 64 128 256 512 1024 2048 4096 ; do
+		d=$(( $1 / i ))
+		test $(( d * i )) -eq "$1" || break
+		d=$(( $2 / i ))
+		test $(( d * i )) -eq "$2" || break
+		max=$i
+	done
+	echo "$max"
+}
+
+# detect LV on the given device
+# dereference device name if it is symbolic link
+detect_lv_() {
+	local DEVICE=$1
+	local MAJOR
+	local MINOR
+	local SYSVOLUME
+	local MAJORMINOR
+
+	DEVICE=${1/#"${DM_DEV_DIR}/"/}
+	DEVICE=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$DEVICE")
+	test -n "$DEVICE" || error "Cannot get readlink \"$1\"."
+	RDEVICE=$DEVICE
+	case "$RDEVICE" in
+	  # hardcoded /dev  since udev does not create these entries elsewhere
+	  /dev/dm-[0-9]*)
+		read -r <"/sys/block/${RDEVICE#/dev/}/dm/name" SYSVOLUME 2>&1 && DEVICE="$DM_DEV_DIR/mapper/$SYSVOLUME"
+		read -r <"/sys/block/${RDEVICE#/dev/}/dev" MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$DEVICE\"."
+		MAJOR=${MAJORMINOR%%:*}
+		MINOR=${MAJORMINOR##*:}
+		;;
+	  *)
+		STAT=$(stat --format "MAJOR=\$((0x%t)) MINOR=\$((0x%T))" "$RDEVICE")
+		test -n "$STAT" || error "Cannot get major:minor for \"$DEVICE\"."
+		eval "$STAT"
+		;;
+	esac
+
+	eval "$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o uuid,name --noheadings --nameprefixes --separator ' ')"
+}
+
+# parse yaml config files into 'prefix_yaml_part_names=("value")' strings
+parse_yaml_() {
+	local yaml_file=$1
+	local prefix=$2
+	local s
+	local w
+	local fs
+
+	s='[[:space:]]*'
+	w='[a-zA-Z0-9_.-]*'
+	fs="$(echo @|tr @ '\034')"
+
+	(
+	    sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
+		-e 's/\$/\\\$/g' \
+		-e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
+		-e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
+		-e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
+
+	    awk -F"$fs" '{
+		indent = length($1)/2;
+		if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
+		vname[indent] = $2;
+		for (i in vname) {if (i > indent) {delete vname[i]}}
+		    if (length($3) > 0) {
+			vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
+			printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1], $3);
+		    }
+		}' |
+
+	    sed -e 's/_=/+=/g' |
+
+	    awk 'BEGIN {
+		    FS="=";
+		    OFS="="
+		}
+		/(-|\.).*=/ {
+		    gsub("-|\\.", "_", $1)
+		}
+		{ print }'
+	) < "$yaml_file"
+}
+
+# convert existing VDO volume into lvm2 volume
+convert2lvm_() {
+	local DEVICE=$1
+	local VGNAME=${NAME%/*}
+	local LVNAME=${NAME#*/}
+	local VDONAME
+	local TRVDONAME
+	local EXTENTSZ
+	local IS_LV=1
+
+	DM_UUID=""
+	detect_lv_ "$DEVICE"
+	case "$DM_UUID" in
+		LVM-*)	eval "$(dmsetup splitname --nameprefixes --noheadings --separator ' ' "$DM_NAME")"
+			if [ -z "$VGNAME" ] || [ "$VGNAME" = "$LVNAME" ]  ; then
+				VGNAME=$DM_VG_NAME
+			elif test "$VGNAME" != "$DM_VG_NAME" ; then
+				error "Volume group name \"$VGNAME\" does not match name \"$DM_VG_NAME\" for device \"$DEVICE\"."
+			fi
+			;;
+		*) IS_LV=0
+			# Check $VGNANE does not already exists
+			"$LVM" vgs "$VGNAME" && error "Cannot use already existing volume group name \"$VGNAME\"."
+			;;
+	esac
+
+	verbose "Checked whether device $1 is already LV ($IS_LV)."
+
+	"$MKDIR" -p -m 0000 "$TEMPDIR" || error "Failed to create $TEMPDIR."
+
+	verbose "Getting YAML VDO configuration."
+	"$VDO" printConfigFile $VDOCONF >"$TEMPDIR/vdoconf.yml"
+
+	VDONAME=$(awk -v DNAME="$DEVICE" '/.*VDOService$/ {VNAME=substr($1, 0, length($1) - 1)} /[[:space:]]*device:/ { if ($2 ~ DNAME) {print VNAME}}' "$TEMPDIR/vdoconf.yml")
+	TRVDONAME=$(echo "$VDONAME" | tr '-' '_')
+
+	# When VDO volume is 'active', check it's not mounted/being used
+	eval "$(dmsetup info -c -o open  "$VDONAME" --noheadings --nameprefixes || true)"
+	test "${DM_OPEN:-0}" -eq 0 || error "Cannot converted VDO volume \"$VDONAME\" which is in use!"
+
+	#parse_yaml_ "$TEMPDIR/vdoconf.yml" _
+	eval "$(parse_yaml_ "$TEMPDIR/vdoconf.yml" _ | grep "$TRVDONAME" | sed -e "s/_config_vdos_$TRVDONAME/vdo/g")"
+
+	vdo_logicalSize=$(get_kb_size_with_unit_ "$vdo_logicalSize")
+	vdo_physicalSize=$(get_kb_size_with_unit_ "$vdo_physicalSize")
+
+	verbose "Going to convert physical sized VDO device $vdo_physicalSize KiB."
+	verbose "With logical volume of size $vdo_logicalSize KiB."
+
+	PARAMS=$(cat <<EOF
+allocation {
+	vdo_use_compression = $(get_enabled_value_ "$vdo_compression")
+	vdo_use_deduplication = $(get_enabled_value_ "$vdo_deduplication")
+	vdo_use_metadata_hints=1
+	vdo_minimum_io_size = $vdo_logicalBlockSize
+	vdo_block_map_cache_size_mb = $(get_mb_size_with_unit_ "$vdo_blockMapCacheSize")
+	vdo_block_map_period = $vdo_blockMapPeriod
+	vdo_check_point_frequency = $vdo_indexCfreq
+	vdo_use_sparse_index = $(get_enabled_value_ "$vdo_indexSparse")
+	vdo_index_memory_size_mb = $(awk "BEGIN {print $vdo_indexMemory * 1024}")
+	vdo_slab_size_mb = $(get_mb_size_with_unit_ "$vdo_blockMapCacheSize")
+	vdo_ack_threads = $vdo_ackThreads
+	vdo_bio_threads = $vdo_bioThreads
+	vdo_bio_rotation = $vdo_bioRotationInterval
+	vdo_cpu_threads = $vdo_cpuThreads
+	vdo_hash_zone_threads = $vdo_hashZoneThreads
+	vdo_logical_threads = $vdo_logicalThreads
+	vdo_physical_threads = $vdo_physicalThreads
+	vdo_write_policy = $vdo_writePolicy
+	vdo_max_discard = $(( $(get_kb_size_with_unit_ "$vdo_maxDiscardSize") * 1024 ))
+	vdo_pool_header_size = 0
+}
+EOF
+)
+	verbose "VDO conversion paramaters: $PARAMS"
+
+	verbose "Stopping VDO volume."
+	dry "$VDO" stop $VDOCONF --name "$VDONAME"
+
+	if [ "$IS_LV" = "0" ]; then
+		verbose "Moving VDO header by 2MiB."
+		dry "$VDO" convert $VDOCONF --force --name "$VDONAME"
+
+		dry "$LVM" pvcreate $YES --dataalignment 2M "$DEVICE" || {
+			error "Creation of PV on \"$DEVICE\" failed, while VDO header has been already moved!"
+		}
+
+		# Obtain free space in this new PV
+		# after 'vdo convert/vdo2lvm' call there is +2M free space at the front of the device
+		case "$DRY" in
+		0) pvfree=$("$LVM" pvs -o devsize --units b --nosuffix --noheadings "$DEVICE") ;;
+		*) pvfree=$("$BLOCKDEV" --getsize64 "$DEVICE") ;;
+		esac
+
+		pvfree=$(( pvfree / 1024 - 2048 ))	# to KiB
+	else
+		pvfree=$("$LVM" lvs -o size --units b --nosuffix --noheadings "$VGNAME/$LVNAME")
+		pvfree=$(( pvfree / 1024 ))		# to KiB
+	fi
+
+	# select largest possible extent size that can exactly express both sizes
+	EXTENTSZ=$(get_largest_extent_size_ "$pvfree" "$vdo_logicalSize")
+
+	if [ "$IS_LV" = "0" ]; then
+		verbose "Creating VG \"${NAME%/*}\" with extent size $EXTENTSZ KiB."
+		dry "$LVM" vgcreate $YES $VERB -s "${EXTENTSZ}k" "$VGNAME" "$DEVICE" || {
+			error "Creation of VG \"$VGNAME\" failed, while VDO header has been already moved!"
+		}
+
+		verbose "Creating VDO pool data LV from all extents in volume group $VGNAME."
+		dry "$LVM" lvcreate -Zn -Wn $YES $VERB -l100%VG -n "${LVNAME}_vpool" "$VGNAME"
+	else
+		# validate existing  VG extent_size can express virtual VDO size
+		vg_extent_size=$("$LVM" vgs -o vg_extent_size --units b --nosuffix --noheadings "$VGNAME" || true)
+		vg_extent_size=$(( vg_extent_size / 1024 ))
+
+		test "$vg_extent_size" -le "$EXTENTSZ" || {
+			error "Please vgchange extent_size to@most $EXTENTSZ KiB or extend and align virtual size on $vg_extent_size KiB."
+		}
+		verbose "Renaming existing LV to be used as _vdata volume for VDO pool LV."
+		dry "$LVM" lvrename $YES $VERB "$VGNAME/$LVNAME" "$VGNAME/${LVNAME}_vpool" || {
+			error "Rename of LV \"$VGNAME/$LVNAME\" failed, while VDO header has been already moved!"
+		}
+	fi
+
+	verbose "Converting to VDO pool."
+	dry "$LVM" lvconvert $YES $VERB $FORCE --config "$PARAMS" -Zn -V "${vdo_logicalSize}k" -n "$LVNAME" --type vdo-pool "$VGNAME/${LVNAME}_vpool"
+
+	rm -fr "$TEMPDIR"
+}
+
+#############################
+# start point of this script
+# - parsing parameters
+#############################
+trap "cleanup 2" 2
+
+test "$#" -eq 0 && tool_usage
+
+while [ "$#" -ne 0 ]
+do
+	 case "$1" in
+	  "") ;;
+	  "-f"|"--force"  ) FORCE="-f" ;;
+	  "-h"|"--help"   ) tool_usage ;;
+	  "-n"|"--name"   ) shift; NAME=$1 ;;
+	  "-v"|"--verbose") VERB="-v" ;;
+	  "-y"|"--yes"    ) YES="-y" ;;
+	  "--dry-run"     ) DRY="1" ;;
+	  "-*") error "Wrong argument \"$1\". (see: $TOOL --help)" ;;
+	  *) DEVICENAME=$1 ;;  # device name does not start with '-'
+	esac
+	shift
+done
+
+# do conversion
+convert2lvm_ "$DEVICENAME"
diff --git a/spec/packages.inc b/spec/packages.inc
index 71aaeea7a..bf693a4ce 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -70,6 +70,7 @@ fi
 %{_sbindir}/vgdisplay
 %{_sbindir}/vgexport
 %{_sbindir}/vgextend
+%{_sbindir}/vdoimport
 %{_sbindir}/vgimport
 %{_sbindir}/vgimportclone
 %{_sbindir}/vgimportdevices
diff --git a/test/Makefile.in b/test/Makefile.in
index 5f35c30b8..093054087 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -368,6 +368,7 @@ LIB = $(addprefix lib/, $(LIB_SECURETEST) $(LIB_DMSECURETEST) $(LIB_SHARED) $(LI
 	$(Q) $(LN_S) -f $(abs_top_srcdir)/conf/lvmdbusd.profile lib/
 	$(Q) $(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
 	$(Q) $(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
+	$(Q) $(LN_S) -f $(abs_top_srcdir)/scripts/vdoimport.sh lib/vdoimport
 	@test "$(srcdir)" = . || \
 		for i in $(LIB_LVMLOCKD_CONF) $(LIB_MKE2FS_CONF); do \
 			test -n "$(Q)" || echo "$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/"; \
diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
new file mode 100644
index 000000000..538147b8d
--- /dev/null
+++ b/test/shell/vdo-convert.sh
@@ -0,0 +1,110 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test conversion of VDO volumes made by vdo manager into VDO LV.
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+# Use local for this test vdo configuratoin
+VDOCONF="-f vdotestconf.yml"
+#VDOCONF=""
+export VDOCONF
+VDONAME="${PREFIX}-TESTVDO"
+
+# VDO automatically starts dmeventd
+aux prepare_dmeventd
+
+#
+# Main
+#
+which vdo || skip
+which mkfs.ext4 || skip
+export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
+
+aux have_vdo 6 2 0 || skip
+
+aux prepare_devs 2 10000
+
+aux extend_filter_LVMTEST
+
+
+#
+#  Check conversion of VDO volume made on some LV
+#
+#  In this case we do not need to move any VDO headers.
+#
+vgcreate $vg "$dev1"
+
+lvcreate -L5G -n $lv1 $vg
+
+vdo create $VDOCONF --name "$VDONAME" --device="$DM_DEV_DIR/$vg/$lv1" --vdoLogicalSize=10G
+
+mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
+
+# Different VG name fails
+not vdoimport -y -v --name $vg1/$lv1 "$DM_DEV_DIR/$vg/$lv1"
+
+# Try just dry run and observe logging
+vdoimport --dry-run -y -v --name $lv1 "$DM_DEV_DIR/$vg/$lv1"
+
+vdoimport -y --name $lv1 "$DM_DEV_DIR/$vg/$lv1"
+
+# ATM needed - since we do not call 'vdo convert' in this case
+vdo remove $VDOCONF --force --name "$VDONAME" || true
+
+vgremove -f $vg
+
+aux wipefs_a "$dev1"
+
+# prepare 'unused' $vg2
+vgcreate $vg2 "$dev2"
+
+#
+# Check conversion of VDO volume on  non-LV device
+#
+vdo create $VDOCONF --name "$VDONAME" --device="$dev1" --vdoLogicalSize=31G
+
+mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
+
+# Fail with an already existing volume group $vg2
+not vdoimport --dry-run -y -v --name $vg2/$lv1 "$dev1" |& tee err
+grep "already existing volume group" err
+
+# User can also convert already stopped VDO volume
+vdo stop $VDOCONF --name "$VDONAME"
+
+vdoimport -y -v --name $vg/$lv1 "$dev1"
+
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+
+vgremove -f $vg
+
+
+#
+# Try once again with different vgname/lvname and sizes
+#
+aux teardown_devs
+aux prepare_devs 1 23456
+
+vdo create $VDOCONF --name "$VDONAME" --device="$dev1" --vdoLogicalSize=23G
+
+mkfs -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
+
+vdoimport -y -v --name $vg1/$lv2 "$dev1"
+
+fsck -n "$DM_DEV_DIR/$vg1/$lv2"
+
+vgremove -f $vg1
+



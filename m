From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 May 2017 09:13:44 -0400
Subject: master - fsadm: enhance detection of already mounted volumes
Message-ID: <201705221313.v4MDDieN030330@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e04e0483f033d131f52a86b7f28300a761c3634
Commit:        9e04e0483f033d131f52a86b7f28300a761c3634
Parent:        2b7ac2bfb3461073486a7b296a76ef26b0d5d733
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 10 15:32:48 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 22 15:11:21 2017 +0200

fsadm: enhance detection of already mounted volumes

Add more validation to catch mainly renamed devices, where
filesystem utils are not able to handle devices properly,
as they are not addressed by major:minor by rather via some
symbolic path names which can change over time via rename operation.
---
 WHATS_NEW        |    1 +
 scripts/fsadm.sh |  119 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 112 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 07c2602..82397a9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Extend validation of filesystems resized by fsadm.
   Enhance lvconvert automatic settings of possible (raid) LV types.
   Allow lvchange to change properties on a thin pool data sub LV.
   Fix lvcreate extent percentage calculation for mirrors.
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 831b3ca..bd54a26 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -75,8 +75,9 @@ BLOCKCOUNT=
 MOUNTPOINT=
 MOUNTED=
 REMOUNT=
-PROCMOUNTS="/proc/mounts"
-PROCSELFMOUNTINFO="/proc/self/mountinfo"
+PROCDIR="/proc"
+PROCMOUNTS="$PROCDIR/mounts"
+PROCSELFMOUNTINFO="$PROCDIR/self/mountinfo"
 NULL="$DM_DEV_DIR/null"
 
 IFS_OLD=$IFS
@@ -113,8 +114,11 @@ verbose() {
 	test -n "$VERB" && echo "$TOOL: $@" || true
 }
 
+# Support multi-line error messages
 error() {
-	echo "$TOOL: $@" >&2
+	for i in "$@" ;  do
+		echo "$TOOL: $i" >&2
+	done
 	cleanup 1
 }
 
@@ -178,6 +182,17 @@ decode_size() {
 	fi
 }
 
+decode_major_minor() {
+	# 0x00000fff00  mask MAJOR
+	# 0xfffff000ff  mask MINOR
+
+	#MINOR=$(( $1 / 1048576 ))
+	#MAJOR=$(( ($1 - ${MINOR} * 1048576) / 256 ))
+	#MINOR=$(( $1 - ${MINOR} * 1048576 - ${MAJOR} * 256 + ${MINOR} * 256))
+
+	echo "$(( ( $1 >> 8 ) & 4095 )):$(( ( ( $1 >> 12 ) & 268435200 ) | ( $1 & 255 ) ))"
+}
+
 # detect filesystem on the given device
 # dereference device name if it is symbolic link
 detect_fs() {
@@ -210,23 +225,92 @@ detect_fs() {
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\"."
 }
 
-detect_mounted_with_proc_self_mountinfo() {
-	MOUNTED=$("$GREP" "^[0-9]* [0-9]* $MAJORMINOR " "$PROCSELFMOUNTINFO")
 
-	# extract 5th field which is mount point
+# Check that passed mounted MAJOR:MINOR is not matching $MAJOR:MINOR of resized $VOLUME
+validate_mounted_major_minor() {
+	test "$1" = "$MAJORMINOR" || {
+		local REFNAME=$(dmsetup info -c -j "${1%%:*}" -m "${1##*:}" -o name --noheadings 2>/dev/null)
+		local CURNAME=$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o name --noheadings 2>/dev/null)
+		error "Cannot ${CHECK+CHECK}${RESIZE+RESIZE} device \"$VOLUME\" without umounting filesystem $MOUNTED first." \
+		      "Mounted filesystem is using device $CURNAME, but referenced device is $REFNAME." \
+		      "Filesystem utilities currently do not support renamed devices."
+	}
+}
+
+# ATM fsresize & fsck tools are not able to work properly
+# when mounted device has changed its name.
+# So whenever such device no longer exists with original name
+# abort further command processing
+check_valid_mounted_device() {
+	local MOUNTEDMAJORMINOR
+	local VOL=$("$READLINK" $READLINK_E "$1")
+	local CURNAME=$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o name --noheadings)
+	local SUGGEST="Possibly device \"$1\" has been renamed to \"$CURNAME\"?"
+
+	# more confused, device is not DM....
+	test -n "$CURNAME" || SUGGEST="Mounted volume is not a device mapper device???"
+
+	test -n "$VOL" ||
+		error "Cannot access device \"$1\" referenced by mounted filesystem \"$MOUNTED\"." \
+		"$SUGGEST" \
+		"Filesystem utilities currently do not support renamed devices."
+
+	case "$VOL" in
+	  # hardcoded /dev  since udev does not create these entries elsewhere
+	  /dev/dm-[0-9]*)
+		read </sys/block/${VOL#/dev/}/dev MOUNTEDMAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
+		;;
+	  *)
+		STAT=$(stat --format "MOUNTEDMAJORMINOR=\$((0x%t)):\$((0x%T))" "$VOL")
+		test -n "$STAT" || error "Cannot get major:minor for \"$VOLUME\"."
+		eval "$STAT"
+		;;
+	esac
+
+	validate_mounted_major_minor "$MOUNTEDMAJORMINOR"
+}
+
+detect_mounted_with_proc_self_mountinfo() {
+	# Check self mountinfo
+	# grab major:minor mounted_device mount_point
+	MOUNTED=$("$GREP" "^[0-9]* [0-9]* $MAJORMINOR " "$PROCSELFMOUNTINFO" 2>/dev/null | head -1)
+
+	# If device is opened and not yet found as self mounted
+	# check all other mountinfos (since it can be mounted in cgroups)
+	# Use 'find' to not fail on to long list of args with too many pids
+	# only 1st. line is needed
+	test -z "$MOUNTED" &&
+		test $(dmsetup info -c --noheading -o open -j "$MAJOR" -m "$MINOR") -gt 0 &&
+		MOUNTED=$(find "$PROCDIR" -maxdepth 2 -name mountinfo -print0 |  xargs -0 "$GREP" "^[0-9]* [0-9]* $MAJORMINOR " 2>/dev/null | head -1 2>/dev/null)
+
+	# TODO: for performance compare with sed and stop with 1st. match:
+	# sed -n "/$MAJORMINOR/ {;p;q;}"
+
+	# extract 2nd field after ' - ' separator as mouted device
+	MOUNTDEV=$(echo ${MOUNTED##* - } | cut -d ' ' -f 2)
+	MOUNTDEV=$(echo -n -e ${MOUNTDEV})
+
+	# extract 5th field as mount point
 	# echo -e translates \040 to spaces
-	MOUNTED=$(echo ${MOUNTED} | cut -d " " -f 5)
+	MOUNTED=$(echo ${MOUNTED} | cut -d ' ' -f 5)
 	MOUNTED=$(echo -n -e ${MOUNTED})
 
-	test -n "$MOUNTED"
+	test -n "$MOUNTED" || return 1   # Not seen mounted anywhere
+
+	check_valid_mounted_device "$MOUNTDEV"
 }
 
+# With older systems without /proc/*/mountinfo we may need to check
+# every mount point as cannot easily depend on the name of mounted
+# device (which could have been renamed).
+# We need to visit every mount point and check it's major minor
 detect_mounted_with_proc_mounts() {
 	MOUNTED=$("$GREP" "^$VOLUME[ \t]" "$PROCMOUNTS")
 
 	# for empty string try again with real volume name
 	test -z "$MOUNTED" && MOUNTED=$("$GREP" "^$RVOLUME[ \t]" "$PROCMOUNTS")
 
+	MOUNTDEV=$(echo -n -e ${MOUNTED%% *})
 	# cut device name prefix and trim everything past mountpoint
 	# echo translates \040 to spaces
 	MOUNTED=${MOUNTED#* }
@@ -234,13 +318,32 @@ detect_mounted_with_proc_mounts() {
 
 	# for systems with different device names - check also mount output
 	if test -z "$MOUNTED" ; then
+		# will not work with spaces in paths
 		MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$VOLUME[ \t]")
 		test -z "$MOUNTED" && MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$RVOLUME[ \t]")
+		MOUNTDEV=${MOUNTED%% on *}
 		MOUNTED=${MOUNTED##* on }
 		MOUNTED=${MOUNTED% type *} # allow type in the mount name
 	fi
 
-	test -n "$MOUNTED"
+	if test -n "$MOUNTED" ; then
+		check_valid_mounted_device "$MOUNTDEV"
+		return 0  # mounted
+	fi
+
+	# If still nothing found and volume is in use
+	# check every known mount point against MAJOR:MINOR
+	if test $(dmsetup info -c --noheading -o open -j "$MAJOR" -m "$MINOR") -gt 0 ; then
+		while IFS=$'\n' read -r i ; do
+			MOUNTDEV=$(echo -n -e ${i%% *})
+			MOUNTED=${i#* }
+			MOUNTED=$(echo -n -e ${MOUNTED%% *})
+			STAT=$(stat --format "%d" $MOUNTED)
+			validate_mounted_major_minor $(decode_major_minor "$STAT")
+		done < "$PROCMOUNTS"
+	fi
+
+	return 1  # nothing is mounted
 }
 
 # check if the given device is already mounted and where



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Oct 2020 23:43:22 +0000 (GMT)
Subject: master - fsadm: use NULL
Message-ID: <20201023234322.E2C9E3858003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73ef86ae3fd51c921c3437a8c3da474e2861d217
Commit:        73ef86ae3fd51c921c3437a8c3da474e2861d217
Parent:        6226512ad2d6fd30a4b55da6a4d4c370fa7fad09
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 24 00:40:34 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 24 01:42:16 2020 +0200

fsadm: use NULL

Use consistently $NULL as in other places.
---
 scripts/fsadm.sh | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 28ca6709f..b84412d92 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -233,8 +233,8 @@ validate_mounted_major_minor() {
 	test "$1" = "$MAJORMINOR" || {
 		local REFNAME
 		local CURNAME
-		REFNAME=$(dmsetup info -c -j "${1%%:*}" -m "${1##*:}" -o name --noheadings 2>/dev/null)
-		CURNAME=$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o name --noheadings 2>/dev/null)
+		REFNAME=$(dmsetup info -c -j "${1%%:*}" -m "${1##*:}" -o name --noheadings 2>"$NULL")
+		CURNAME=$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o name --noheadings 2>"$NULL")
 		error "Cannot ${CHECK+CHECK}${RESIZE+RESIZE} device \"$VOLUME\" without umounting filesystem $MOUNTED first." \
 		      "Mounted filesystem is using device $CURNAME, but referenced device is $REFNAME." \
 		      "Filesystem utilities currently do not support renamed devices."
@@ -279,7 +279,7 @@ check_valid_mounted_device() {
 detect_mounted_with_proc_self_mountinfo() {
 	# Check self mountinfo
 	# grab major:minor mounted_device mount_point
-	MOUNTED=$("$GREP" "^[0-9]* [0-9]* $MAJORMINOR " "$PROCSELFMOUNTINFO" 2>/dev/null | head -1)
+	MOUNTED=$("$GREP" "^[0-9]* [0-9]* $MAJORMINOR " "$PROCSELFMOUNTINFO" 2>"$NULL" | head -1)
 
 	# If device is opened and not yet found as self mounted
 	# check all other mountinfos (since it can be mounted in cgroups)
@@ -287,7 +287,7 @@ detect_mounted_with_proc_self_mountinfo() {
 	# only 1st. line is needed
 	test -z "$MOUNTED" &&
 		test "$(dmsetup info -c --noheading -o open -j "$MAJOR" -m "$MINOR")" -gt 0 &&
-		MOUNTED=$(find "$PROCDIR" -maxdepth 2 -name mountinfo -print0 |  xargs -0 "$GREP" "^[0-9]* [0-9]* $MAJORMINOR " 2>/dev/null | head -1 2>/dev/null)
+		MOUNTED=$(find "$PROCDIR" -maxdepth 2 -name mountinfo -print0 |  xargs -0 "$GREP" "^[0-9]* [0-9]* $MAJORMINOR " 2>"$NULL" | head -1 2>"$NULL")
 
 	# TODO: for performance compare with sed and stop with 1st. match:
 	# sed -n "/$MAJORMINOR/ {;p;q;}"
@@ -532,7 +532,7 @@ detect_luks_device() {
 	CRYPT_NAME=""
 	CRYPT_DATA_OFFSET=""
 
-	_LUKS_VERSION=$("$CRYPTSETUP" luksDump "$VOLUME" 2> /dev/null | "$GREP" "Version:")
+	_LUKS_VERSION=$("$CRYPTSETUP" luksDump "$VOLUME" 2>"$NULL" | "$GREP" "Version:")
 
 	if [ -z "$_LUKS_VERSION" ]; then
 		verbose "Failed to parse LUKS version on volume \"$VOLUME\""
@@ -541,7 +541,7 @@ detect_luks_device() {
 
 	_LUKS_VERSION=${_LUKS_VERSION//[Version:[:space:]]/}
 
-	_LUKS_UUID=$("$CRYPTSETUP" luksDump "$VOLUME" 2> /dev/null | "$GREP" "UUID:")
+	_LUKS_UUID=$("$CRYPTSETUP" luksDump "$VOLUME" 2>"$NULL" | "$GREP" "UUID:")
 
 	if [ -z "$_LUKS_UUID" ]; then
 		verbose "Failed to parse LUKS UUID on volume \"$VOLUME\""
@@ -612,9 +612,9 @@ detect_crypt_device() {
 	local L_NEWSIZE
 	local TMP
 
-	which "$CRYPTSETUP" > /dev/null 2>&1 || error "$CRYPTSETUP utility required to resize crypt device"
+	which "$CRYPTSETUP" >"$NULL" 2>&1 || error "$CRYPTSETUP utility required to resize crypt device"
 
-	CRYPT_TYPE=$("$CRYPTSETUP" status "$1" 2> /dev/null | "$GREP" "type:")
+	CRYPT_TYPE=$("$CRYPTSETUP" status "$1" 2>"$NULL" | "$GREP" "type:")
 
 	test -n "$CRYPT_TYPE" || error "$CRYPTSETUP failed to detect device type on $1."
 
@@ -674,7 +674,7 @@ resize() {
 	  "reiserfs") resize_reiser $NEWSIZE ;;
 	  "xfs") resize_xfs $NEWSIZE ;;
 	  "crypto_LUKS")
-		which "$CRYPTSETUP" > /dev/null 2>&1 || error "$CRYPTSETUP utility required to resize LUKS volume"
+		which "$CRYPTSETUP" >"$NULL" 2>&1 || error "$CRYPTSETUP utility required to resize LUKS volume"
 		resize_luks $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;
 	esac || error "Resize $FSTYPE failed."
@@ -746,7 +746,7 @@ check() {
 		  *) dry "$FSCK" $FORCE -p "$VOLUME" ;;
 		esac ;;
 	  "crypto_LUKS")
-		which "$CRYPTSETUP" > /dev/null 2>&1 || error "$CRYPTSETUP utility required."
+		which "$CRYPTSETUP" >"$NULL" 2>&1 || error "$CRYPTSETUP utility required."
 		check_luks ;;
 	  *)
 		error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;



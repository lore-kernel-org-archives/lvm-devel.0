From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:36:07 -0500
Subject: master - shellcheck: fsadm cleanup
Message-ID: <201711072036.vA7Ka7vn007681@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d45a9c0f5b2c5c7d5098abc056174fa09f88cc58
Commit:        d45a9c0f5b2c5c7d5098abc056174fa09f88cc58
Parent:        0f0baec1f36d712e9611ea31bde0ad904aa08f33
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 5 18:22:02 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:26:11 2017 +0100

shellcheck: fsadm cleanup

Use some more "" for bash vars
---
 scripts/fsadm.sh |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 4f402ce..a09b915 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -532,7 +532,7 @@ detect_luks_device() {
 	CRYPT_NAME=""
 	CRYPT_DATA_OFFSET=""
 
-	_LUKS_VERSION=$($CRYPTSETUP luksDump $VOLUME 2> /dev/null | $GREP "Version:")
+	_LUKS_VERSION=$("$CRYPTSETUP" luksDump "$VOLUME" 2> /dev/null | "$GREP" "Version:")
 
 	if [ -z "$_LUKS_VERSION" ]; then
 		verbose "Failed to parse LUKS version on volume \"$VOLUME\""
@@ -541,7 +541,7 @@ detect_luks_device() {
 
 	_LUKS_VERSION=${_LUKS_VERSION//[Version:[:space:]]/}
 
-	_LUKS_UUID=$($CRYPTSETUP luksDump $VOLUME 2> /dev/null | $GREP "UUID:")
+	_LUKS_UUID=$("$CRYPTSETUP" luksDump "$VOLUME" 2> /dev/null | "$GREP" "UUID:")
 
 	if [ -z "$_LUKS_UUID" ]; then
 		verbose "Failed to parse LUKS UUID on volume \"$VOLUME\""
@@ -551,10 +551,10 @@ detect_luks_device() {
 	_LUKS_UUID="CRYPT-LUKS$_LUKS_VERSION-${_LUKS_UUID//[UID:[:space:]-]/}-"
 
 	CRYPT_NAME=$(dmsetup info -c --noheadings -S "UUID=~^$_LUKS_UUID&&segments=1&&devnos_used='$MAJOR:$MINOR'" -o name)
-	test -z "$CRYPT_NAME" || CRYPT_DATA_OFFSET=$(dmsetup table $CRYPT_NAME | cut -d ' ' -f 8)
+	test -z "$CRYPT_NAME" || CRYPT_DATA_OFFSET=$(dmsetup table "$CRYPT_NAME" | cut -d ' ' -f 8)
 
 	# LUKS device must be active and mapped over volume where detected
-	if [ -z "$CRYPT_NAME" -o -z "$CRYPT_DATA_OFFSET" ]; then
+	if [ -z "$CRYPT_NAME" ] || [ -z "$CRYPT_DATA_OFFSET" ]; then
 		error "Can not find active LUKS device. Unlock \"$VOLUME\" volume first."
 	fi
 }
@@ -599,7 +599,7 @@ resize_luks() {
 	fi
 
 	# resize LUKS device
-	dry $CRYPTSETUP resize $NAME --size $L_NEWBLOCKCOUNT || error "Failed to resize active LUKS device"
+	dry "$CRYPTSETUP" resize "$NAME" --size $L_NEWBLOCKCOUNT || error "Failed to resize active LUKS device"
 
 	if [ $SHRINK -eq 0 ]; then
 		# grow fs on top of LUKS device
@@ -612,9 +612,9 @@ detect_crypt_device() {
 	local L_NEWSIZE
 	local TMP
 
-	which $CRYPTSETUP > /dev/null 2>&1 || error "$CRYPTSETUP utility required to resize crypt device"
+	which "$CRYPTSETUP" > /dev/null 2>&1 || error "$CRYPTSETUP utility required to resize crypt device"
 
-	CRYPT_TYPE=$($CRYPTSETUP status $1 2> /dev/null | $GREP "type:")
+	CRYPT_TYPE=$("$CRYPTSETUP" status "$1" 2> /dev/null | "$GREP" "type:")
 
 	test -n "$CRYPT_TYPE" || error "$CRYPTSETUP failed to detect device type on $1."
 
@@ -651,7 +651,7 @@ detect_crypt_device() {
 #  (on direct user request only)
 #################################
 resize_crypt() {
-	dry $CRYPTSETUP resize "$1" --size $CRYPT_RESIZE_BLOCKS || error "$CRYPTSETUP failed to resize device $1"
+	dry "$CRYPTSETUP" resize "$1" --size $CRYPT_RESIZE_BLOCKS || error "$CRYPTSETUP failed to resize device $1"
 }
 
 ####################
@@ -674,7 +674,7 @@ resize() {
 	  "reiserfs") resize_reiser $NEWSIZE ;;
 	  "xfs") resize_xfs $NEWSIZE ;;
 	  "crypto_LUKS")
-		which $CRYPTSETUP > /dev/null 2>&1 || error "$CRYPTSETUP utility required to resize LUKS volume"
+		which "$CRYPTSETUP" > /dev/null 2>&1 || error "$CRYPTSETUP utility required to resize LUKS volume"
 		resize_luks $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;
 	esac || error "Resize $FSTYPE failed."
@@ -746,7 +746,7 @@ check() {
 		  *) dry "$FSCK" $FORCE -p "$VOLUME" ;;
 		esac ;;
 	  "crypto_LUKS")
-		which $CRYPTSETUP > /dev/null 2>&1 || error "$CRYPTSETUP utility required."
+		which "$CRYPTSETUP" > /dev/null 2>&1 || error "$CRYPTSETUP utility required."
 		check_luks ;;
 	  *)
 		error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;



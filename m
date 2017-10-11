From: Ondrej Kozina <okozina@sourceware.org>
Date: Wed, 11 Oct 2017 08:40:16 -0400
Subject: master - fsadm: implement 'check' for a fs on top of LUKS
Message-ID: <201710111240.v9BCeGiD020750@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5beb58561e85d80e43a5e38011d6894db803f28
Commit:        f5beb58561e85d80e43a5e38011d6894db803f28
Parent:        c795a3b37f042d30bc706f73c67ff09c30addca6
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Oct 11 11:17:36 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Oct 11 14:39:22 2017 +0200

fsadm: implement 'check' for a fs on top of LUKS

---
 scripts/fsadm.sh |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 6210eb2..a68c7b8 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -534,7 +534,7 @@ detect_luks_device() {
 
 	_LUKS_VERSION=$($CRYPTSETUP luksDump $VOLUME 2> /dev/null | $GREP "Version:")
 
-	if [ -z $_LUKS_VERSION ]; then
+	if [ -z "$_LUKS_VERSION" ]; then
 		verbose "Failed to parse LUKS version on volume \"$VOLUME\""
 		return
 	fi
@@ -543,7 +543,7 @@ detect_luks_device() {
 
 	_LUKS_UUID=$($CRYPTSETUP luksDump $VOLUME 2> /dev/null | $GREP "UUID:")
 
-	if [ -z $_LUKS_UUID ]; then
+	if [ -z "$_LUKS_UUID" ]; then
 		verbose "Failed to parse LUKS UUID on volume \"$VOLUME\""
 		return
 	fi
@@ -552,6 +552,11 @@ detect_luks_device() {
 
 	CRYPT_NAME=$(dmsetup info -c --noheadings -S "UUID=~^$_LUKS_UUID&&segments=1&&devnos_used='$MAJOR:$MINOR'" -o name)
 	test -z "$CRYPT_NAME" || CRYPT_DATA_OFFSET=$(dmsetup table $CRYPT_NAME | cut -d ' ' -f 8)
+
+	# LUKS device must be active and mapped over volume where detected
+	if [ -z "$CRYPT_NAME" -o -z "$CRYPT_DATA_OFFSET" ]; then
+		error "Can not find active LUKS device. Unlock \"$VOLUME\" volume first."
+	fi
 }
 
 ######################################
@@ -566,11 +571,6 @@ resize_luks() {
 
 	detect_luks_device
 
-	# LUKS device must be active and mapped over volume where detected
-	if [ -z "$CRYPT_NAME" -o -z "$CRYPT_DATA_OFFSET" ]; then
-		error "Can not find active LUKS device. Unlock \"$VOLUME\" volume first."
-	fi
-
 	NAME=$CRYPT_NAME
 
 	verbose "Found active LUKS device \"$NAME\" for volume \"$VOLUME\""
@@ -682,6 +682,12 @@ diff_dates() {
          echo $(( $("$DATE" -u -d"$1" +%s 2>"$NULL") - $("$DATE" -u -d"$2" +%s 2>"$NULL") ))
 }
 
+check_luks() {
+	detect_luks_device
+
+	check "$DM_DEV_DIR/mapper/$CRYPT_NAME"
+}
+
 ###################
 # Check filesystem
 ###################
@@ -731,6 +737,9 @@ check() {
 		  *i*) dry "$FSCK" $YES $FORCE "$VOLUME" ;;
 		  *) dry "$FSCK" $FORCE -p "$VOLUME" ;;
 		esac ;;
+	  "crypto_LUKS")
+		which $CRYPTSETUP > /dev/null 2>&1 || error "$CRYPTSETUP utility required."
+		check_luks ;;
 	  *)
 		error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;
 	esac



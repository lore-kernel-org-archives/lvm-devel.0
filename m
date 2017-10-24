From: Ondrej Kozina <okozina@sourceware.org>
Date: Tue, 24 Oct 2017 07:43:02 -0400
Subject: master - fsadm: rename local variables to avoid confusion
Message-ID: <201710241143.v9OBh2bK031250@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9916d8fa9ad82eeb63c85b1b74879c8da56f74a0
Commit:        9916d8fa9ad82eeb63c85b1b74879c8da56f74a0
Parent:        213cea3aaa19dffef6e922e914225d21f05589f2
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Oct 23 18:11:32 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 24 13:41:09 2017 +0200

fsadm: rename local variables to avoid confusion

---
 scripts/fsadm.sh |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 3614cd2..25bddba 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -526,8 +526,8 @@ resize_xfs() {
 # 1) look for LUKS device with well-known UUID format (CRYPT-LUKS[12]-<uuid>-<dmname>)
 # 2) the dm-crypt device has to be on top of original device (dont't support detached LUKS headers)
 detect_luks_device() {
-	local _LUKS_VERSION=
-	local _LUKS_UUID=
+	local _LUKS_VERSION
+	local _LUKS_UUID
 
 	CRYPT_NAME=""
 	CRYPT_DATA_OFFSET=""
@@ -564,9 +564,9 @@ detect_luks_device() {
 # - LUKS must be active for fs resize
 ######################################
 resize_luks() {
-	local NEWFSIZE=
-	local NEWCBLOCKCOUNT=
-	local NAME=""
+	local L_NEWSIZE
+	local L_NEWBLOCKCOUNT
+	local NAME
 	local SHRINK=0
 
 	detect_luks_device
@@ -585,25 +585,25 @@ resize_luks() {
 		error "New size is smaller than minimum ($(((CRYPT_DATA_OFFSET + 1) * 512)) bytes) for LUKS device $VOLUME"
 	fi
 
-	NEWCBLOCKCOUNT=$((NEWBLOCKCOUNT - CRYPT_DATA_OFFSET))
-	NEWFSIZE=$(( NEWCBLOCKCOUNT * 512))
+	L_NEWBLOCKCOUNT=$((NEWBLOCKCOUNT - CRYPT_DATA_OFFSET))
+	L_NEWSIZE=$(( L_NEWBLOCKCOUNT * 512))
 
 	VOLUME="$DM_DEV_DIR/mapper/$NAME"
 	detect_device_size
 
-	test "$DEVSIZE" -le "$NEWFSIZE" || SHRINK=1
+	test "$DEVSIZE" -le "$L_NEWSIZE" || SHRINK=1
 
 	if [ $SHRINK -eq 1 ]; then
 		# shrink fs on LUKS device first
-		resize "$DM_DEV_DIR/mapper/$NAME" "$NEWFSIZE"b
+		resize "$DM_DEV_DIR/mapper/$NAME" "$L_NEWSIZE"b
 	fi
 
 	# resize LUKS device
-	dry $CRYPTSETUP resize $NAME --size $NEWCBLOCKCOUNT || error "Failed to resize active LUKS device"
+	dry $CRYPTSETUP resize $NAME --size $L_NEWBLOCKCOUNT || error "Failed to resize active LUKS device"
 
 	if [ $SHRINK -eq 0 ]; then
 		# grow fs on top of LUKS device
-		resize "$DM_DEV_DIR/mapper/$NAME" "$NEWFSIZE"b
+		resize "$DM_DEV_DIR/mapper/$NAME" "$L_NEWSIZE"b
 	fi
 }
 



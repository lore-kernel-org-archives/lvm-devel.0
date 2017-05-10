From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 May 2017 09:41:31 -0400
Subject: master - fsadm: fix test of subshell return value
Message-ID: <201705101341.v4ADfV2F005117@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1107d483a26a5735de7d740fd3182d2e58960f63
Commit:        1107d483a26a5735de7d740fd3182d2e58960f63
Parent:        455a4de090f10f98ac2932a2540a30b7fdc34f61
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 9 20:52:15 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 10 15:40:29 2017 +0200

fsadm: fix test of subshell return value

Subshell is not returning error code value upward thus
error results in this case were actually ignored.
Also add dots to moved error messages.
---
 WHATS_NEW        |    1 +
 scripts/fsadm.sh |   18 ++++++++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0b9fab9..79b6c67 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Properly handle subshell return codes in fsadm.
   Disallow cachepool creation with policy cleaner and mode writeback.
 
 Version 2.02.171 - 3rd May 2017
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 26be102..0d6c503 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -183,7 +183,8 @@ decode_size() {
 detect_fs() {
 	VOLUME_ORIG=$1
 	VOLUME=${1/#"${DM_DEV_DIR}/"/}
-	VOLUME=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$VOLUME") || error "Cannot get readlink \"$1\""
+	VOLUME=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$VOLUME")
+	test -n "$VOLUME" || error "Cannot get readlink \"$1\"."
 	RVOLUME=$VOLUME
 	case "$RVOLUME" in
           # hardcoded /dev  since udev does not create these entries elsewhere
@@ -192,7 +193,8 @@ detect_fs() {
 		read </sys/block/${RVOLUME#/dev/}/dev MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\""
 		;;
 	  *)
-		STAT=$(stat --format "MAJOR=%t MINOR=%T" ${RVOLUME}) || error "Cannot get major:minor for \"$VOLUME\""
+		STAT=$(stat --format "MAJOR=%t MINOR=%T" ${RVOLUME})
+		test -n "$STAT" || error "Cannot get major:minor for \"$VOLUME\"."
 		eval $STAT
 		MAJOR=$((0x${MAJOR}))
 		MINOR=$((0x${MINOR}))
@@ -201,7 +203,8 @@ detect_fs() {
 	esac
 	# use null device as cache file to be sure about the result
 	# not using option '-o value' to be compatible with older version of blkid
-	FSTYPE=$("$BLKID" -c "$NULL" -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
+	FSTYPE=$("$BLKID" -c "$NULL" -s TYPE "$VOLUME")
+	test -n "$FSTYPE" || error "Cannot get FSTYPE of \"$VOLUME\"."
 	FSTYPE=${FSTYPE##*TYPE=\"} # cut quotation marks
 	FSTYPE=${FSTYPE%%\"*}
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
@@ -257,10 +260,13 @@ detect_device_size() {
 	# check if blockdev supports getsize64
 	"$BLOCKDEV" 2>&1 | "$GREP" getsize64 >"$NULL"
 	if test $? -eq 0; then
-		DEVSIZE=$("$BLOCKDEV" --getsize64 "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
+		DEVSIZE=$("$BLOCKDEV" --getsize64 "$VOLUME")
+		test -n "$DEVSIZE" || error "Cannot read size of device \"$VOLUME\"."
 	else
-		DEVSIZE=$("$BLOCKDEV" --getsize "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
-		SSSIZE=$("$BLOCKDEV" --getss "$VOLUME") || error "Cannot block size read device \"$VOLUME\""
+		DEVSIZE=$("$BLOCKDEV" --getsize "$VOLUME")
+		test -n "$DEVSIZE" || error "Cannot read size of device \"$VOLUME\"."
+		SSSIZE=$("$BLOCKDEV" --getss "$VOLUME")
+		test -n "$SSSIZE" || error "Cannot read sector size of device \"$VOLUME\"."
 		DEVSIZE=$(($DEVSIZE * $SSSIZE))
 	fi
 }



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  6 Sep 2021 13:25:10 +0000 (GMT)
Subject: main - vdo: better message for missing device
Message-ID: <20210906132510.657513858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3287d37f440ca272b52f900fc60ee5effcf73697
Commit:        3287d37f440ca272b52f900fc60ee5effcf73697
Parent:        8d5b7de54f21ce5e34d533599f9d5a42f2977cd5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 1 15:46:04 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 6 15:19:51 2021 +0200

vdo: better message for missing device

Show readable message when passed device cannot be accessed.
And use STAT shell var wrapper to call 'stat' command.
---
 scripts/lvm_import_vdo.sh | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 65d2eee38..685821f13 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -19,7 +19,7 @@
 # Needed utilities:
 #  lvm, dmsetup,
 #  vdo,
-#  grep, awk, sed, blockdev, readlink, mkdir
+#  grep, awk, sed, blockdev, readlink, stat, mkdir
 #
 # Conversion is using  'vdo convert' support from VDO manager to move
 # existing VDO header by 2M which makes space to place in PV header
@@ -40,6 +40,7 @@ VDOCONF=${VDOCONF:-}
 BLOCKDEV="blockdev"
 READLINK="readlink"
 READLINK_E="-e"
+STAT="stat"
 MKDIR="mkdir"
 DMSETUP="dmsetup"
 
@@ -156,8 +157,8 @@ detect_lv_() {
 	local MAJORMINOR
 
 	DEVICE=${1/#"${DM_DEV_DIR}/"/}
-	DEVICE=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$DEVICE")
-	test -n "$DEVICE" || error "Cannot get readlink \"$1\"."
+	DEVICE=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$DEVICE" || true)
+	test -n "$DEVICE" || error "Readlink cannot access device \"$1\"."
 	RDEVICE=$DEVICE
 	case "$RDEVICE" in
 	  # hardcoded /dev  since udev does not create these entries elsewhere
@@ -168,9 +169,9 @@ detect_lv_() {
 		DEVMINOR=${MAJORMINOR##*:}
 		;;
 	  *)
-		STAT=$(stat --format "DEVMAJOR=\$((0x%t)) DEVMINOR=\$((0x%T))" "$RDEVICE")
-		test -n "$STAT" || error "Cannot get major:minor for \"$DEVICE\"."
-		eval "$STAT"
+		RSTAT=$("$STAT" --format "DEVMAJOR=\$((0x%t)) DEVMINOR=\$((0x%T))" "$RDEVICE" || true)
+		test -n "$RSTAT" || error "Cannot get major:minor for \"$DEVICE\"."
+		eval "$RSTAT"
 		;;
 	esac
 
@@ -269,8 +270,8 @@ convert2lvm_() {
 	for i in $(awk '/.*device:/ {print $2}' "$TEMPDIR/vdoconf.yml") ; do
 		local DEV
 		DEV=$("$READLINK" $READLINK_E "$i") || continue
-		STAT=$(stat --format "MAJOR=\$((0x%t)) MINOR=\$((0x%T))" "$DEV" 2>/dev/null) || continue
-		eval "$STAT"
+		RSTAT=$("$STAT" --format "MAJOR=\$((0x%t)) MINOR=\$((0x%T))" "$DEV" 2>/dev/null) || continue
+		eval "$RSTAT"
 		test "$MAJOR" = "$DEVMAJOR" && test "$MINOR" = "$DEVMINOR" && {
 			test -z "$FOUND" || error "VDO configuration contains duplicate entries $FOUND and $i"
 			FOUND=$i
@@ -287,7 +288,7 @@ convert2lvm_() {
 	DM_OPEN="$("$DMSETUP" info -c -o open  "$VDONAME" --noheadings --nameprefixes 2>/dev/null || true)"
 	case "$DM_OPEN" in
 	Device*) ;; # no devices
-	*) 	eval "$DM_OPEN"
+	*)	eval "$DM_OPEN"
 		test "${DM_OPEN:-0}" -eq 0 || error "Cannot converted VDO volume \"$VDONAME\" which is in use!"
 		;;
 	esac



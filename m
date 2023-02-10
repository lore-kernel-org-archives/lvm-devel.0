From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:27 +0000 (GMT)
Subject: main - lvresize_fs_helper: cleanup shellcheck warns
Message-ID: <20230210165327.40F91385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=35e1f15e0386341617c5810c481a2c8d227026d1
Commit:        35e1f15e0386341617c5810c481a2c8d227026d1
Parent:        b681b774dcacd35d08f16d8952ec99d1e85433d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 9 16:22:11 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

lvresize_fs_helper: cleanup shellcheck warns

Use commands directly in 'if cmd; then'.
Use shell vars in $(( )) in recommended way.
---
 scripts/lvresize_fs_helper.sh | 54 +++++++++++++++----------------------------
 1 file changed, 19 insertions(+), 35 deletions(-)

diff --git a/scripts/lvresize_fs_helper.sh b/scripts/lvresize_fs_helper.sh
index f531dd447..90b1a9782 100755
--- a/scripts/lvresize_fs_helper.sh
+++ b/scripts/lvresize_fs_helper.sh
@@ -30,8 +30,7 @@ RESIZEFS_FAILED=0
 fsextend() {
 	if [ "$DO_UNMOUNT" -eq 1 ]; then
 		logmsg "unmount ${MOUNTDIR}"
-		umount "$MOUNTDIR"
-		if [ $? -eq 0 ]; then
+		if umount "$MOUNTDIR"; then
 			logmsg "unmount done"
 		else
 			logmsg "unmount failed"
@@ -41,8 +40,7 @@ fsextend() {
 
 	if [ "$DO_FSCK" -eq 1 ]; then
 		logmsg "e2fsck ${DEVPATH}"
-		e2fsck -f -p "$DEVPATH"
-		if [ $? -eq 0 ]; then
+		if e2fsck -f -p "$DEVPATH"; then
 			logmsg "e2fsck done"
 		else
 			logmsg "e2fsck failed"
@@ -52,8 +50,7 @@ fsextend() {
 	
 	if [ "$DO_CRYPTRESIZE" -eq 1 ]; then
 		logmsg "cryptsetup resize ${DEVPATH}"
-		cryptsetup resize "$DEVPATH"
-		if [ $? -eq 0 ]; then
+		if cryptsetup resize "$DEVPATH"; then
 			logmsg "cryptsetup done"
 		else
 			logmsg "cryptsetup failed"
@@ -63,8 +60,7 @@ fsextend() {
 
 	if [ "$DO_MOUNT" -eq 1 ]; then
 		logmsg "mount ${DEVPATH} ${TMPDIR}"
-		mount -t "$FSTYPE" "$DEVPATH" "$TMPDIR"
-		if [ $? -eq 0 ]; then
+		if mount -t "$FSTYPE" "$DEVPATH" "$TMPDIR"; then
 			logmsg "mount done"
 			TMP_MOUNT_DONE=1
 		else
@@ -75,8 +71,7 @@ fsextend() {
 
 	if [[ "$FSTYPE" == "ext"* ]]; then
 		logmsg "resize2fs ${DEVPATH}"
-		resize2fs "$DEVPATH"
-		if [ $? -eq 0 ]; then
+		if resize2fs "$DEVPATH"; then
 			logmsg "resize2fs done"
 		else
 			logmsg "resize2fs failed"
@@ -84,8 +79,7 @@ fsextend() {
 		fi
 	elif [[ "$FSTYPE" == "xfs" ]]; then
 		logmsg "xfs_growfs ${DEVPATH}"
-		xfs_growfs "$DEVPATH"
-		if [ $? -eq 0 ]; then
+		if xfs_growfs "$DEVPATH"; then
 			logmsg "xfs_growfs done"
 		else
 			logmsg "xfs_growfs failed"
@@ -96,8 +90,7 @@ fsextend() {
 	# If the fs was temporarily mounted, now unmount it.
 	if [ $TMP_MOUNT_DONE -eq 1 ]; then
 		logmsg "cleanup unmount ${TMPDIR}"
-		umount "$TMPDIR"
-		if [ $? -eq 0 ]; then
+		if umount "$TMPDIR"; then
 			logmsg "cleanup unmount done"
 			TMP_MOUNT_DONE=0
 			rmdir "$TMPDIR"
@@ -111,8 +104,7 @@ fsextend() {
 	# Not considered a command failure if this fails.
 	if [[ $DO_UNMOUNT -eq 1 && $REMOUNT -eq 1 ]]; then
 		logmsg "remount ${DEVPATH} ${MOUNTDIR}"
-		mount -t "$FSTYPE" "$DEVPATH" "$MOUNTDIR"
-		if [ $? -eq 0 ]; then
+		if mount -t "$FSTYPE" "$DEVPATH" "$MOUNTDIR"; then
 			logmsg "remount done"
 		else
 			logmsg "remount failed"
@@ -130,8 +122,7 @@ fsextend() {
 fsreduce() {
 	if [ "$DO_UNMOUNT" -eq 1 ]; then
 		logmsg "unmount ${MOUNTDIR}"
-		umount "$MOUNTDIR"
-		if [ $? -eq 0 ]; then
+		if umount "$MOUNTDIR"; then
 			logmsg "unmount done"
 		else
 			logmsg "unmount failed"
@@ -141,8 +132,7 @@ fsreduce() {
 
 	if [ "$DO_FSCK" -eq 1 ]; then
 		logmsg "e2fsck ${DEVPATH}"
-		e2fsck -f -p "$DEVPATH"
-		if [ $? -eq 0 ]; then
+		if e2fsck -f -p "$DEVPATH"; then
 			logmsg "e2fsck done"
 		else
 			logmsg "e2fsck failed"
@@ -152,8 +142,7 @@ fsreduce() {
 	
 	if [ "$DO_MOUNT" -eq 1 ]; then
 		logmsg "mount ${DEVPATH} ${TMPDIR}"
-		mount -t "$FSTYPE" "$DEVPATH" "$TMPDIR"
-		if [ $? -eq 0 ]; then
+		if mount -t "$FSTYPE" "$DEVPATH" "$TMPDIR"; then
 			logmsg "mount done"
 			TMP_MOUNT_DONE=1
 		else
@@ -163,10 +152,9 @@ fsreduce() {
 	fi
 
 	if [[ "$FSTYPE" == "ext"* ]]; then
-		NEWSIZEKB=$(($NEWSIZEBYTES/1024))
+		NEWSIZEKB=$(( NEWSIZEBYTES / 1024 ))
 		logmsg "resize2fs ${DEVPATH} ${NEWSIZEKB}k"
-		resize2fs "$DEVPATH" "$NEWSIZEKB"k
-		if [ $? -eq 0 ]; then
+		if resize2fs "$DEVPATH" "$NEWSIZEKB"k; then
 			logmsg "resize2fs done"
 		else
 			logmsg "resize2fs failed"
@@ -178,8 +166,7 @@ fsreduce() {
 	# If the fs was temporarily mounted, now unmount it.
 	if [ $TMP_MOUNT_DONE -eq 1 ]; then
 		logmsg "cleanup unmount ${TMPDIR}"
-		umount "$TMPDIR"
-		if [ $? -eq 0 ]; then
+		if umount "$TMPDIR"; then
 			logmsg "cleanup unmount done"
 			TMP_MOUNT_DONE=0
 			rmdir "$TMPDIR"
@@ -195,10 +182,9 @@ fsreduce() {
 	fi
 
 	if [ "$DO_CRYPTRESIZE" -eq 1 ]; then
-		NEWSIZESECTORS=$(($NEWSIZEBYTES/512))
+		NEWSIZESECTORS=$(( NEWSIZEBYTES / 512 ))
 		logmsg "cryptsetup resize ${NEWSIZESECTORS} sectors ${DEVPATH}"
-		cryptsetup resize --size "$NEWSIZESECTORS" "$DEVPATH"
-		if [ $? -eq 0 ]; then
+		if cryptsetup resize --size "$NEWSIZESECTORS" "$DEVPATH"; then
 			logmsg "cryptsetup done"
 		else
 			logmsg "cryptsetup failed"
@@ -210,8 +196,7 @@ fsreduce() {
 	# Not considered a command failure if this fails.
 	if [[ $DO_UNMOUNT -eq 1 && $REMOUNT -eq 1 ]]; then
 		logmsg "remount ${DEVPATH} ${MOUNTDIR}"
-		mount -t "$FSTYPE" "$DEVPATH" "$MOUNTDIR"
-		if [ $? -eq 0 ]; then
+		if mount -t "$FSTYPE" "$DEVPATH" "$MOUNTDIR"; then
 			logmsg "remount done"
 		else
 			logmsg "remount failed"
@@ -222,10 +207,9 @@ fsreduce() {
 }
 
 cryptresize() {
-	NEWSIZESECTORS=$(($NEWSIZEBYTES/512))
+	NEWSIZESECTORS=$(( NEWSIZEBYTES / 512 ))
 	logmsg "cryptsetup resize ${NEWSIZESECTORS} sectors ${DEVPATH}"
-	cryptsetup resize --size "$NEWSIZESECTORS" "$DEVPATH"
-	if [ $? -eq 0 ]; then
+	if cryptsetup resize --size "$NEWSIZESECTORS" "$DEVPATH"; then
 		logmsg "cryptsetup done"
 	else
 		logmsg "cryptsetup failed"


From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  1 Nov 2010 13:53:51 +0100
Subject: [PATCH 1/3] Return different error value for check of mounted fs
In-Reply-To: <cover.1288614451.git.zkabelac@redhat.com>
References: <cover.1288614451.git.zkabelac@redhat.com>
Message-ID: <d5541aaab6f0aa438a3f38617ece5bc5c29847b9.1288614451.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch modifies returns different error value for check requested
for mounted filesystem if such operation is not supported.

Also makes a more consistent  'break'  behavior and return exit code 2
for break inside the fsadm script.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/fsadm.sh |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)
 mode change 100644 => 100755 scripts/fsadm.sh

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
old mode 100644
new mode 100755
index 945089a..9cee3c2
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -23,6 +23,11 @@
 # reiserfs: resize_reiserfs, reiserfstune
 # xfs: xfs_growfs, xfs_info
 #
+# Return values:
+#   0 success
+#   1 error
+#   2 break detected
+#   3 unsupported online filesystem check for given mounted fs
 
 TOOL=fsadm
 
@@ -127,6 +132,8 @@ cleanup() {
 	IFS=$IFS_OLD
 	trap 2
 
+	test "$1" -eq 2 && verbose "Break detected"
+
 	if [ "$DO_LVRESIZE" -eq 2 ]; then
 		# start LVRESIZE with the filesystem modification flag
 		# and allow recursive call of fsadm
@@ -382,7 +389,6 @@ resize() {
 	# if the size parameter is missing use device size
 	#if [ -n "$NEWSIZE" -a $NEWSIZE <
 	test -z "$NEWSIZE" && NEWSIZE=${DEVSIZE}b
-	trap cleanup 2
 	IFS=$NL
 	case "$FSTYPE" in
 	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
@@ -399,7 +405,10 @@ resize() {
 ###################
 check() {
 	detect_fs "$1"
-	detect_mounted && error "Cannot fsck device \"$VOLUME\", filesystem is mounted on $MOUNTED"
+	if detect_mounted ; then
+		verbose "Skipping filesystem check for device \"$VOLUME\" as the filesystem is mounted on $MOUNTED";
+		cleanup 3
+	fi
 	case "$FSTYPE" in
 	  "xfs") dry $XFS_CHECK "$VOLUME" ;;
 	  *)    # check if executed from interactive shell environment
@@ -414,6 +423,7 @@ check() {
 # start point of this script
 # - parsing parameters
 #############################
+trap "cleanup 2" 2
 
 # test if we are not invoked recursively
 test -n "$FSADM_RUNNING" && exit 0
-- 
1.7.3.2



From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:25 +0200
Subject: [PATCH 11/16] fsadm: remove -y (YES) option
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-12-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There is some confusion in using -y (YES) and -f (FORCE) options in
fsadm. In some cases we are asked for yes/no question which can be
override by -f option, but not by -y option. Usually most of the questions
tools ask for are yes/no and it can be overridden by forcing it with -f
(e.g. fsck.(extN|xfs), lvm and others...) so it make sense to get rid of
-y option and use only -f instead.

Also I do not think it is wise to use -y option in fsck.extN since
people using fsadm would probably not know how it works, so we should
NOT provide them with that option, but rather let them use "real" fsck
instead (and let them read man page if needed). Also running fsck with
-y when you have corrupted file system is probably not a good idea from
multiple reasons. This is also fixed by this commit.

This commit removes '-y' option and use '-f' instead. With exception of
fsck.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 man/fsadm.8.in   |    5 +----
 scripts/fsadm.sh |   23 +++++++++++------------
 2 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/man/fsadm.8.in b/man/fsadm.8.in
index 62fbb1a..591f575 100644
--- a/man/fsadm.8.in
+++ b/man/fsadm.8.in
@@ -126,14 +126,11 @@ Be more verbose.
 Unmount ext2/ext3/ext4 filesystem before doing resize.
 .TP
 .BR \-f ", " \-\-force
-Bypass some sanity checks.
+Force all commands without asking questions.
 .TP
 .BR \-n ", " \-\-dry\-run
 Print commands without running them.
 .TP
-.BR \-y ", " \-\-yes
-Answer "yes" at any prompts.
-.TP
 .B \-c ", " \-\-config\fP  \fIpath\fP
 Specify the path to the configuration file. If not provided, default
 location will be used. The default locations are
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index bafafb7..5c22763 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -63,7 +63,7 @@ DF=df
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
 
-YES=${_FSADM_YES}
+FORCE=${_FSADM_FORCE}
 DRY=0
 VERB=
 FORCE=
@@ -190,9 +190,8 @@ tool_usage() {
 	echo "    -h | --help           Show this help message"
 	echo "    -v | --verbose        Be verbose"
 	echo "    -e | --ext-offline    unmount filesystem before ext2/ext3/ext4 resize"
-	echo "    -f | --force          Bypass sanity checks"
+	echo "    -f | --force          Force all commands without asking questions"
 	echo "    -n | --dry-run        Print commands without running them"
-	echo "    -y | --yes            Answer \"yes\" at any prompts"
 	echo "    -c | --config path    Specify the path to the configuration file"
 	echo
 	exit
@@ -460,8 +459,9 @@ temp_umount() {
 yes_no() {
 	echo -n "$@? [Y|n] "
 
-	if [ -n "$YES" ]; then
-		echo y ; return 0
+	if [ -n "$FORCE" ]; then
+		echo y
+		return 0
 	fi
 
 	while read -r -s -n 1 ANS ; do
@@ -512,7 +512,7 @@ resize_ext() {
 	if [ -z "$MOUNTED" ] || [ "$REMOUNT" ]; then
 		# Forced fsck -f for umounted extX filesystem.
 		case "$-" in
-		  *i*) dry "$FSCK" "$YES" -f "$VOLUME" ;;
+		  *i*) dry "$FSCK" -f "$VOLUME" ;;
 		  *) dry "$FSCK" -f -p "$VOLUME" ;;
 		esac
 	fi
@@ -539,7 +539,7 @@ resize_reiser() {
 	validate_parsing "$TUNE_REISER"
 	decode_size $1 $BLOCKSIZE
 	verbose "Resizing \"$VOLUME\" $BLOCKCOUNT -> $NEWBLOCKCOUNT blocks ($NEWSIZE KiB, bs: $NEWBLOCKCOUNT)"
-	if [ -n "$YES" ]; then
+	if [ -n "$FORCE" ]; then
 		echo y | dry "$RESIZE_REISER" -s "${NEWSIZE}K" "$VOLUME"
 	else
 		dry "$RESIZE_REISER" -s "${NEWSIZE}K" "$VOLUME"
@@ -587,7 +587,7 @@ make_ext() {
 	fstyp="$2"
 	bsize=4
 
-	if [ "$YES" ]; then
+	if [ "$FORCE" ]; then
 		force="-F"
 	fi
 
@@ -602,7 +602,7 @@ generic_make_fs() {
 	fstyp=$2
 	bsize=4096
 
-	if [ "$YES" ]; then
+	if [ "$FORCE" ]; then
 		force="-f"
 	fi
 
@@ -726,7 +726,7 @@ resize() {
 	# resize the logical volume, but also the file system (if present)
 	# by calling fsadm recursively with --resize-fs-only argument.
 	# To be able to do this we should set some appropriate variables.
-	export _FSADM_YES=$YES
+	export _FSADM_FORCE=$FORCE
 	export FSADM_RESIZE_RECURSE=1
 	unset FSADM_RUNNING
 
@@ -1327,7 +1327,7 @@ check() {
 	  "xfs") dry "$XFS_CHECK" "$VOLUME" ;;
 	  *)    # check if executed from interactive shell environment
 		case "$-" in
-		  *i*) dry "$FSCK" "$YES" "$FORCE" "$VOLUME" ;;
+		  *i*) dry "$FSCK" "$FORCE" "$VOLUME" ;;
 		  *) dry "$FSCK" "$FORCE" -p "$VOLUME" ;;
 		esac
 	esac
@@ -1387,7 +1387,6 @@ do
 	  "-f"|"--force") FORCE="-f" ;;
 	  "-e"|"--ext-offline") EXTOFF=1 ;;
 	  "-o"|"--resize-fs-only") RESIZE_FS_ONLY=1 ;;
-	  "-y"|"--yes") YES="-y" ;;
 	  "-l"|"--lvresize") ;;
 	  "-c"|"--config") CONFIG=$2; shift 1 ;;
 	  "check") COMMAND=$1; shift; ARGS="$@"; break ;;
-- 
1.7.4.4



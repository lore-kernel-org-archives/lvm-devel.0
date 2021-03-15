From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:21 +0000 (GMT)
Subject: main - shellcheck: avoid assign warnings
Message-ID: <20210315101421.C37C93858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e5e957e3308a6a03503b6ded290dc975494204e5
Commit:        e5e957e3308a6a03503b6ded290dc975494204e5
Parent:        8a92f7070941172e1671cf6b0fd1296776daefb7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 15 10:49:47 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

shellcheck: avoid assign warnings

Shellcheck seems to be happier when assigning variables with quotes.
---
 scripts/fsadm.sh                      | 54 +++++++++++++++++------------------
 scripts/lvmdump.sh.in                 | 36 +++++++++++------------
 test/lib/aux.sh                       |  4 +--
 test/lib/utils.sh                     |  2 +-
 test/shell/lvcreate-cache-no-tools.sh |  4 +--
 5 files changed, 50 insertions(+), 50 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 4f59cee13..d98833c3a 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -31,34 +31,34 @@
 
 set -euE -o pipefail
 
-TOOL=fsadm
+TOOL="fsadm"
 
 _SAVEPATH=$PATH
 PATH="/sbin:/usr/sbin:/bin:/usr/sbin:$PATH"
 
 # utilities
-TUNE_EXT=tune2fs
-RESIZE_EXT=resize2fs
-TUNE_REISER=reiserfstune
-RESIZE_REISER=resize_reiserfs
-TUNE_XFS=xfs_info
-RESIZE_XFS=xfs_growfs
-
-MOUNT=mount
-UMOUNT=umount
-MKDIR=mkdir
-RMDIR=rmdir
-BLOCKDEV=blockdev
-BLKID=blkid
-DATE=date
-GREP=grep
-READLINK=readlink
+TUNE_EXT="tune2fs"
+RESIZE_EXT="resize2fs"
+TUNE_REISER="reiserfstune"
+RESIZE_REISER="resize_reiserfs"
+TUNE_XFS="xfs_info"
+RESIZE_XFS="xfs_growfs"
+
+MOUNT="mount"
+UMOUNT="umount"
+MKDIR="mkdir"
+RMDIR="rmdir"
+BLOCKDEV="blockdev"
+BLKID="blkid"
+DATE="date"
+GREP="grep"
+READLINK="readlink"
 READLINK_E="-e"
-FSCK=fsck
-XFS_CHECK=xfs_check
+FSCK="fsck"
+XFS_CHECK="xfs_check"
 # XFS_REPAIR -n is used when XFS_CHECK is not found
-XFS_REPAIR=xfs_repair
-CRYPTSETUP=cryptsetup
+XFS_REPAIR="xfs_repair"
+CRYPTSETUP="cryptsetup"
 
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY:-lvm}
@@ -69,8 +69,8 @@ VERB=
 FORCE=
 EXTOFF=${_FSADM_EXTOFF:-0}
 DO_LVRESIZE=0
-FSTYPE=unknown
-VOLUME=unknown
+FSTYPE="unknown"
+VOLUME="unknown"
 TEMPDIR="${TMPDIR:-/tmp}/${TOOL}_${RANDOM}$$/m"
 DM_DEV_DIR="${DM_DEV_DIR:-/dev}"
 BLOCKSIZE=
@@ -321,10 +321,10 @@ detect_mounted_with_proc_self_mountinfo() {
 # device (which could have been renamed).
 # We need to visit every mount point and check it's major minor
 detect_mounted_with_proc_mounts() {
-	MOUNTED=$("$GREP" "^$VOLUME[ \\t]" "$PROCMOUNTS")
+	MOUNTED=$("$GREP" "^${VOLUME}[ \\t]" "$PROCMOUNTS")
 
 	# for empty string try again with real volume name
-	test -z "$MOUNTED" && MOUNTED=$("$GREP" "^$RVOLUME[ \\t]" "$PROCMOUNTS")
+	test -z "$MOUNTED" && MOUNTED=$("$GREP" "^${RVOLUME}[ \\t]" "$PROCMOUNTS")
 
 	MOUNTDEV=$(echo -n -e "${MOUNTED%% *}")
 	# cut device name prefix and trim everything past mountpoint
@@ -335,8 +335,8 @@ detect_mounted_with_proc_mounts() {
 	# for systems with different device names - check also mount output
 	if test -z "$MOUNTED" ; then
 		# will not work with spaces in paths
-		MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$VOLUME[ \\t]")
-		test -z "$MOUNTED" && MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$RVOLUME[ \\t]")
+		MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^${VOLUME}[ \\t]")
+		test -z "$MOUNTED" && MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^${RVOLUME}[ \\t]")
 		MOUNTDEV=${MOUNTED%% on *}
 		MOUNTED=${MOUNTED##* on }
 		MOUNTED=${MOUNTED% type *} # allow type in the mount name
diff --git a/scripts/lvmdump.sh.in b/scripts/lvmdump.sh.in
index 24e395661..8507151d8 100644
--- a/scripts/lvmdump.sh.in
+++ b/scripts/lvmdump.sh.in
@@ -18,24 +18,24 @@
 
 # following external commands are used throughout the script
 # echo and test are internal in bash at least
-MKDIR=mkdir # need -p
-TAR=tar # need czf
-RM=rm # need -rf
-CP=cp
-TAIL=tail # we need -n
-LS=ls # need -la
-PS=ps # need alx
-SED=sed
-DD=dd
-CUT=cut
-GREP=grep
-DATE=date
-BASENAME=basename
-UDEVADM=udevadm
-UNAME=uname
-TR=tr
-SOCAT=socat # either socat or nc is needed for dumping lvmetad state
-NC=nc
+MKDIR="mkdir" # need -p
+TAR="tar" # need czf
+RM="rm" # need -rf
+CP="cp"
+TAIL="tail" # we need -n
+LS="ls" # need -la
+PS="ps" # need alx
+SED="sed"
+DD="dd"
+CUT="cut"
+GREP="grep"
+DATE="date"
+BASENAME="basename"
+UDEVADM="udevadm"
+UNAME="uname"
+TR="tr"
+SOCAT="socat" # either socat or nc is needed for dumping lvmetad state
+NC="nc"
 
 if test "@ODIRECT@" = yes; then
     DDFLAGS='iflag=direct oflag=direct'
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2e6191d70..53975301a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -807,7 +807,7 @@ wait_md_create() {
 	local md=$1
 
 	while :; do
-		if ! grep `basename $md` /proc/mdstat; then
+		if ! grep "$(basename $md)" /proc/mdstat; then
 			echo "$md not ready"
 			cat /proc/mdstat
 			sleep 2
@@ -1365,7 +1365,7 @@ EOF
 			echo "$s {"
 			local k
 			for k in $(grep ^"$s"/ "$config_values" | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
-				grep "^$k[ \t=]" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
+				grep "^${k}[ \t=]" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
 			done
 			echo "}"
 			echo
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 9da9a966e..400cacd0c 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -267,7 +267,7 @@ get_devs() {
 
 prepare_test_vars() {
 	vg="${PREFIX}vg"
-	lv=LV
+	lv="LV"
 
 	for i in {1..16}; do
 		eval "lv$i=\"LV$i\""
diff --git a/test/shell/lvcreate-cache-no-tools.sh b/test/shell/lvcreate-cache-no-tools.sh
index bbab0fef3..2e4ee4623 100644
--- a/test/shell/lvcreate-cache-no-tools.sh
+++ b/test/shell/lvcreate-cache-no-tools.sh
@@ -20,9 +20,9 @@ SKIP_WITH_LVMPOLLD=1
 if test -e LOCAL_CLVMD ; then
 # In cluster, the error from activation is logged in clvmd
 # so we can only check resulting state of activation
-	GREP=echo
+	GREP="echo"
 else
-	GREP=grep
+	GREP="grep"
 fi
 
 make_fake_() {



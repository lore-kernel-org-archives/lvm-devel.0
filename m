From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  7 Oct 2010 16:06:36 +0200
Subject: [PATCH 6/9] Fix problem with fscking of mounted filesystem
In-Reply-To: <cover.1286460218.git.zkabelac@redhat.com>
References: <cover.1286460218.git.zkabelac@redhat.com>
Message-ID: <d1625c45c8e5f047113bc2f2af784e11e5e81249.1286460218.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix for RH bz #638050.

Update the way how fsadm detects mounted filesystem.
With udev /dev/dm-XXX paths are now returned - but mount or /proc/mounts
prints names in form of /dev/mapper/vg-lv - so the match was not found.

Current solution uses same trick as mount and detects vg-lv name through
/sys where available - this should be reasonable safe.

Instead of calling mount without parameter to get actual mount table,
switch to use /proc/mounts directly. (Not really sure, maybe we want to
use /proc/self/mounts?)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/fsadm.sh |   28 +++++++++++++++++++++-------
 1 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 73b6779..2ee24c9 100644
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -66,6 +66,7 @@ BLOCKCOUNT=
 MOUNTPOINT=
 MOUNTED=
 REMOUNT=
+PROCMOUNTS="/proc/mounts"
 
 IFS_OLD=$IFS
 # without bash $'\n'
@@ -165,10 +166,15 @@ decode_size() {
 # detect filesystem on the given device
 # dereference device name if it is symbolic link
 detect_fs() {
-        VOLUME=${1#/dev/}
+	VOLUME_ORIG=$1
+	VOLUME=${1#/dev/}
 	VOLUME=$($READLINK $READLINK_E "/dev/$VOLUME") || error "Cannot get readlink $1"
-	# strip newline from volume name
-	VOLUME=${VOLUME%%$NL}
+	RVOLUME=$VOLUME
+	case "$RVOLUME" in
+	  /dev/dm-[0-9]*)
+		read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="/dev/mapper/$SYSVOLUME"
+		;;
+	esac
 	# use /dev/null as cache file to be sure about the result
 	# not using option '-o value' to be compatible with older version of blkid
 	FSTYPE=$($BLKID -c /dev/null -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
@@ -178,11 +184,19 @@ detect_fs() {
 }
 
 # check if the given device is already mounted and where
+# FIXME: resolve swap usage and device stacking
 detect_mounted()  {
-	$MOUNT >/dev/null || error "Cannot detect mounted device $VOLUME"
-	MOUNTED=$($MOUNT | $GREP "$VOLUME")
-	MOUNTED=${MOUNTED##* on }
-	MOUNTED=${MOUNTED% type *} # allow type in the mount name
+	test -e $PROCMOUNTS || error "Cannot detect mounted device $VOLUME"
+
+	MOUNTED=$($GREP ^"$VOLUME" $PROCMOUNTS)
+
+	# for empty string try again with real volume name
+	test -z "$MOUNTED" && MOUNTED=$($GREP ^"$RVOLUME" $PROCMOUNTS)
+
+	# cut device name prefix and trim everything past mountpoint
+	# echo translates \040 to spaces
+	MOUNTED=${MOUNTED#* }
+	MOUNTED=$(echo -n -e ${MOUNTED%% *})
 	test -n "$MOUNTED"
 }
 
-- 
1.7.3.1



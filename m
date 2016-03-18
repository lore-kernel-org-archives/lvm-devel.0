From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 18 Mar 2016 12:45:27 +0000 (UTC)
Subject: master - fsadm: if available, use /proc/self/mountinfo to detect mounted volume
Message-ID: <20160318124527.0D90C609D2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2879eff86edb944874c7a1bf580b851286c4da46
Commit:        2879eff86edb944874c7a1bf580b851286c4da46
Parent:        464ebe04db33ac105f5278dbbb244a9f84d582f8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 18 13:42:06 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 18 13:42:06 2016 +0100

fsadm: if available, use /proc/self/mountinfo to detect mounted volume

The /proc/self/mountinfo is not bound to device names like /proc/mounts
and it uses major:minor pairs instead.

This fixes a situation in which a volume is mounted and then renamed
later on - that makes /proc/mounts unreliable when detecting mounted
volumes.

See also https://bugzilla.redhat.com/show_bug.cgi?id=1196910.
---
 WHATS_NEW        |    1 +
 scripts/fsadm.sh |   29 +++++++++++++++++++++++++----
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d49e935..96023c8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.147 - 
 ==================================
+  If available, use /proc/self/mountinfo to detect mounted volume in fsadm.
   Fix resize of stacked raid thin data volume (2.02.141).
   Fix test for lvremove failure in lvconvert --uncache (2.02.146).
 
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index fc85988..4dee15c 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -76,6 +76,7 @@ MOUNTPOINT=
 MOUNTED=
 REMOUNT=
 PROCMOUNTS="/proc/mounts"
+PROCSELFMOUNTINFO="/proc/self/mountinfo"
 NULL="$DM_DEV_DIR/null"
 
 IFS_OLD=$IFS
@@ -188,6 +189,7 @@ detect_fs() {
           # hardcoded /dev  since udev does not create these entries elsewhere
 	  /dev/dm-[0-9]*)
 		read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
+		read </sys/block/${RVOLUME#/dev/}/dev MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\""
 		;;
 	esac
 	# use null device as cache file to be sure about the result
@@ -198,11 +200,18 @@ detect_fs() {
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 }
 
-# check if the given device is already mounted and where
-# FIXME: resolve swap usage and device stacking
-detect_mounted()  {
-	test -e "$PROCMOUNTS" || error "Cannot detect mounted device \"$VOLUME\""
+detect_mounted_with_proc_self_mountinfo()  {
+	MOUNTED=$("$GREP" "^[0-9]* [0-9]* $MAJORMINOR " "$PROCSELFMOUNTINFO")
+
+	# extract 5th field which is mount point
+	# echo -e translates \040 to spaces
+	MOUNTED=$(echo ${MOUNTED} | cut -d " " -f 5)
+	MOUNTED=$(echo -n -e ${MOUNTED})
+
+	test -n "$MOUNTED"
+}
 
+detect_mounted_with_proc_mounts()  {
 	MOUNTED=$("$GREP" "^$VOLUME[ \t]" "$PROCMOUNTS")
 
 	# for empty string try again with real volume name
@@ -224,6 +233,18 @@ detect_mounted()  {
 	test -n "$MOUNTED"
 }
 
+# check if the given device is already mounted and where
+# FIXME: resolve swap usage and device stacking
+detect_mounted()  {
+	if test -e "$PROCSELFMOUNTINFO"; then
+		detect_mounted_with_proc_self_mountinfo
+	elif test -e "$PROCMOUNTS"; then
+		detect_mounted_with_proc_mounts
+	else
+		error "Cannot detect mounted device \"$VOLUME\""
+	fi
+}
+
 # get the full size of device in bytes
 detect_device_size() {
 	# check if blockdev supports getsize64



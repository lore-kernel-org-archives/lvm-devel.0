From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 18 Mar 2016 15:06:03 +0000 (UTC)
Subject: master - fsadm: for now, fallback to using /proc/mounts if we're using non-standard /dev layout
Message-ID: <20160318150603.9A36E60FB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c88fa77ab022f36bcad5751cc30cd8328bc09dc
Commit:        0c88fa77ab022f36bcad5751cc30cd8328bc09dc
Parent:        2879eff86edb944874c7a1bf580b851286c4da46
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 18 15:55:36 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 18 15:55:36 2016 +0100

fsadm: for now, fallback to using /proc/mounts if we're using non-standard /dev layout

If we're using non-standard /dev layout so we can't get the dm-X name,
we can't also look at the /sys/blocl/dm-X/dev to get the major:minor
pair.

That is this part of the script exactly:

VOLUME=${1/#"${DM_DEV_DIR}/"/}
VOLUME=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$VOLUME") || error "Cannot get readlink \"$1\""
RVOLUME=$VOLUME

case "$RVOLUME" in
  # hardcoded /dev  since udev does not create these entries elsewhere
  /dev/dm-[0-9]*)
        read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
        read </sys/block/${RVOLUME#/dev/}/dev MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\""
        ;;
  esac

So if we're not using usual /dev/mapper/name --> /dev/dm-X symlinks, we
won't get the dm-X name and also we won't get the major:minor pair.

This is just a temporary workaround until I find a quick, sane and compatible
way to get the dm-X name and/or major:minor pair with minimal or no deps on
any external utilities, also keeping in mind to not trigger automounts
(e.g. not using "stat").
---
 scripts/fsadm.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 4dee15c..63bedb1 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -236,7 +236,7 @@ detect_mounted_with_proc_mounts()  {
 # check if the given device is already mounted and where
 # FIXME: resolve swap usage and device stacking
 detect_mounted()  {
-	if test -e "$PROCSELFMOUNTINFO"; then
+	if test -e "$PROCSELFMOUNTINFO" && test -n "${MAJORMINOR}"; then
 		detect_mounted_with_proc_self_mountinfo
 	elif test -e "$PROCMOUNTS"; then
 		detect_mounted_with_proc_mounts



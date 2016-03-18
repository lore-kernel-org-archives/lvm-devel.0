From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 18 Mar 2016 16:14:18 +0000 (UTC)
Subject: master - fsadm: for now, fallback to using /proc/mounts if we're using non-standard /dev layout
Message-ID: <20160318161418.C5D8D610CC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b48753fa51016b5502b4d4c6c8242b1537694b1
Commit:        8b48753fa51016b5502b4d4c6c8242b1537694b1
Parent:        2879eff86edb944874c7a1bf580b851286c4da46
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 18 15:55:36 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 18 17:13:03 2016 +0100

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
 scripts/fsadm.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 4dee15c..6ad5199 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -191,6 +191,14 @@ detect_fs() {
 		read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
 		read </sys/block/${RVOLUME#/dev/}/dev MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\""
 		;;
+	  *)
+		STAT=$(stat --format "MAJOR=%t MINOR=%T" ${RVOLUME}) || error "Cannot get major:minor for \"$VOLUME\""
+		eval $STAT
+		MAJOR=$((0x${MAJOR}))
+		MINOR=$((0x${MINOR}))
+		MAJORMINOR=${MAJOR}:${MINOR}
+		echo "MAJOR:MINOR $MAJORMINOR" >> /a.log
+		;;
 	esac
 	# use null device as cache file to be sure about the result
 	# not using option '-o value' to be compatible with older version of blkid



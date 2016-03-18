From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 18 Mar 2016 16:18:10 +0000 (UTC)
Subject: master - fsadm: use stat to get major:minor pair for non-standard /dev layouts
Message-ID: <20160318161810.D0D6B61C66@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=301f8a40025d180796ee2ce607c38d32932c2a60
Commit:        301f8a40025d180796ee2ce607c38d32932c2a60
Parent:        2879eff86edb944874c7a1bf580b851286c4da46
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 18 15:55:36 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 18 17:16:18 2016 +0100

fsadm: use stat to get major:minor pair for non-standard /dev layouts

If we're using non-standard /dev layout so we can't get the dm-X name
easily, we can't also look at the /sys/blocl/dm-X/dev to get the major:minor
pair. Use "stat" in this case even though it triggers automounts
(but there's no better way for now).
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



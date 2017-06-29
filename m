From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:21 -0400
Subject: master - fsadm: add -r to read
Message-ID: <201706292025.v5TKPLtr025646@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c6a5964ce96e869028394fb31060d2e2c44c2ab1
Commit:        c6a5964ce96e869028394fb31060d2e2c44c2ab1
Parent:        afded3e532546744793f2f483b2c86dfb4f05f9a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 16:07:33 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

fsadm: add -r to read

read without -r will mangle backslashes
---
 scripts/fsadm.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 0b248e1..0db24ad 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -204,8 +204,8 @@ detect_fs() {
 	case "$RVOLUME" in
 	  # hardcoded /dev  since udev does not create these entries elsewhere
 	  /dev/dm-[0-9]*)
-		read <"/sys/block/${RVOLUME#/dev/}/dm/name" SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
-		read <"/sys/block/${RVOLUME#/dev/}/dev" MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
+		read -r <"/sys/block/${RVOLUME#/dev/}/dm/name" SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
+		read -r <"/sys/block/${RVOLUME#/dev/}/dev" MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
 		MAJOR=${MAJORMINOR%%:*}
 		MINOR=${MAJORMINOR##*:}
 		;;
@@ -262,7 +262,7 @@ check_valid_mounted_device() {
 	case "$VOL" in
 	  # hardcoded /dev  since udev does not create these entries elsewhere
 	  /dev/dm-[0-9]*)
-		read <"/sys/block/${VOL#/dev/}/dev" MOUNTEDMAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
+		read -r <"/sys/block/${VOL#/dev/}/dev" MOUNTEDMAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
 		;;
 	  *)
 		STAT=$(stat --format "MOUNTEDMAJORMINOR=\$((0x%t)):\$((0x%T))" "$VOL")



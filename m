From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 May 2017 09:41:32 -0400
Subject: master - fsadm: all path define MAJOR MINOR
Message-ID: <201705101341.v4ADfWGd005127@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1a9ae0aa5fe337935091320b6f27fb053381ff5
Commit:        a1a9ae0aa5fe337935091320b6f27fb053381ff5
Parent:        8ea33b633a1d856a4347f6ecf98a50c1d2b60d76
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 10 15:23:54 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 10 15:40:32 2017 +0200

fsadm: all path define MAJOR MINOR

---
 scripts/fsadm.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 5574143..534aac1 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -191,6 +191,8 @@ detect_fs() {
 	  /dev/dm-[0-9]*)
 		read </sys/block/${RVOLUME#/dev/}/dm/name SYSVOLUME 2>&1 && VOLUME="$DM_DEV_DIR/mapper/$SYSVOLUME"
 		read </sys/block/${RVOLUME#/dev/}/dev MAJORMINOR 2>&1 || error "Cannot get major:minor for \"$VOLUME\"."
+		MAJOR=${MAJORMINOR%%:*}
+		MINOR=${MAJORMINOR##*:}
 		;;
 	  *)
 		STAT=$(stat --format "MAJOR=\$((0x%t)) MINOR=\$((0x%T))" ${RVOLUME})



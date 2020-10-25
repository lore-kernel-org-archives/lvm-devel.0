From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 25 Oct 2020 20:46:05 +0000 (GMT)
Subject: stable-2.02 - fsadm: fix bash artihmetic
Message-ID: <20201025204605.411883857802@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50ac89448fef4fc223e52f5a843b0709111006cb
Commit:        50ac89448fef4fc223e52f5a843b0709111006cb
Parent:        a12574303d282779327bc93283edc72fd1b0772e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 21:44:36 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 21:45:49 2020 +0100

fsadm: fix bash artihmetic

These shell vars needs to be without "".
---
 scripts/fsadm.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index e20401be1..9b95d318d 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -383,7 +383,7 @@ detect_device_size() {
 		test -n "$DEVSIZE" || error "Cannot read size of device \"$VOLUME\"."
 		SSSIZE=$("$BLOCKDEV" --getss "$VOLUME" || true)
 		test -n "$SSSIZE" || error "Cannot read sector size of device \"$VOLUME\"."
-		DEVSIZE=$(("$DEVSIZE" * "$SSSIZE"))
+		DEVSIZE=$(( $DEVSIZE * $SSSIZE ))
 	fi
 }
 



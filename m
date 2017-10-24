From: Ondrej Kozina <okozina@sourceware.org>
Date: Tue, 24 Oct 2017 07:42:55 -0400
Subject: master - fsadm: fix bug in LUKS grow/shrink decision branch
Message-ID: <201710241142.v9OBgt9A031230@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af781897fa7d124c073c1763f47adac3d7186907
Commit:        af781897fa7d124c073c1763f47adac3d7186907
Parent:        6df7917581eea9eef3cf5144a870df9207be15df
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Oct 23 15:41:16 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 24 13:40:54 2017 +0200

fsadm: fix bug in LUKS grow/shrink decision branch

---
 scripts/fsadm.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 3d0fdcd..3614cd2 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -591,7 +591,7 @@ resize_luks() {
 	VOLUME="$DM_DEV_DIR/mapper/$NAME"
 	detect_device_size
 
-	test "$DEVSIZE" -le "$NEWSIZE" || SHRINK=1
+	test "$DEVSIZE" -le "$NEWFSIZE" || SHRINK=1
 
 	if [ $SHRINK -eq 1 ]; then
 		# shrink fs on LUKS device first



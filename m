From: Ondrej Kozina <okozina@sourceware.org>
Date: Wed, 11 Oct 2017 08:40:16 -0400
Subject: master - fsadm: respect DM_DEV_DIR variable
Message-ID: <201710111240.v9BCeGEv020749@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74fd0dd6c49b1669a7e54b6c2fc9152c908fb2c6
Commit:        74fd0dd6c49b1669a7e54b6c2fc9152c908fb2c6
Parent:        e02e5b0c5bb3b61a21f4fe2be7f35d2f30054a10
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Oct 10 17:43:45 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Oct 11 14:39:07 2017 +0200

fsadm: respect DM_DEV_DIR variable

---
 scripts/fsadm.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index a0a75b6..e86d266 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -584,14 +584,14 @@ resize_luks() {
 	NEWCBLOCKCOUNT=$((NEWBLOCKCOUNT - CRYPT_DATA_OFFSET))
 	NEWFSIZE=$(( NEWCBLOCKCOUNT * 512))
 
-	VOLUME="/dev/mapper/$NAME"
+	VOLUME="$DM_DEV_DIR/mapper/$NAME"
 	detect_device_size
 
 	test "$DEVSIZE" -le "$NEWSIZE" || SHRINK=1
 
 	if [ $SHRINK -eq 1 ]; then
 		# shrink fs on LUKS device first
-		resize "/dev/mapper/$NAME" "$NEWFSIZE"b
+		resize "$DM_DEV_DIR/mapper/$NAME" "$NEWFSIZE"b
 	fi
 
 	# resize LUKS device
@@ -599,7 +599,7 @@ resize_luks() {
 
 	if [ $SHRINK -eq 0 ]; then
 		# grow fs on top of LUKS device
-		resize "/dev/mapper/$NAME" "$NEWFSIZE"b
+		resize "$DM_DEV_DIR/mapper/$NAME" "$NEWFSIZE"b
 	fi
 }
 



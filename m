From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 15:42:39 +0200
Subject: [PATCH v3 06/18] fsadm: Fsck extN before resize only if it is not mounted
In-Reply-To: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317130971-24173-7-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index d4901d1..f43d72e 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -415,8 +415,9 @@ resize_ext() {
 	decode_size $1 $BLOCKSIZE
 	FSFORCE=$FORCE
 
+	detect_mounted
 	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
-		detect_mounted && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
+		[ "$MOUNTED" ] && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
 		REMOUNT=$MOUNTED
 	fi
 
-- 
1.7.4.4



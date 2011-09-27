From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 15:42:43 +0200
Subject: [PATCH v3 10/18] fsadm: Umount ext2 file system prior resize
In-Reply-To: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317130971-24173-11-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

ext2 does NOT support online resize, so we should attempt to umount the
file system first.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 0a2c8cc..7220f98 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -417,6 +417,11 @@ resize_ext() {
 	decode_size $1 $BLOCKSIZE
 	FSFORCE=$FORCE
 
+	# ext2 does NOT support online resize
+	if [ "$FSTYPE" == "ext2" ]; then
+		EXTOFF=1
+	fi
+
 	detect_mounted
 	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
 		[ "$MOUNTED" ] && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
-- 
1.7.4.4



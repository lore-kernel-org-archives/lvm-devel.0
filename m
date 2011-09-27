From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 15:42:40 +0200
Subject: [PATCH v3 07/18] fsadm: Only use readlink if link is provided
In-Reply-To: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317130971-24173-8-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index f43d72e..2d5c6f9 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -301,8 +301,10 @@ decode_size() {
 # dereference device name if it is symbolic link
 detect_fs() {
 	VOLUME_ORIG="$1"
-	VOLUME=${1/#"${DM_DEV_DIR}/"/}
-	VOLUME=$("$READLINK" "$READLINK_E" "$DM_DEV_DIR/$VOLUME") || error "Cannot get readlink \"$1\""
+	VOLUME=${DM_DEV_DIR}/${1/#"${DM_DEV_DIR}/"/}
+	if [ -h "$VOLUME" ]; then
+		VOLUME=$("$READLINK" "$READLINK_E" "$VOLUME") || error "Cannot get readlink \"$VOLUME\""
+	fi
 	RVOLUME=$VOLUME
 	case "$RVOLUME" in
           # hardcoded /dev  since udev does not create these entries elsewhere
-- 
1.7.4.4



From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  7 Oct 2010 16:06:31 +0200
Subject: [PATCH 1/9] can not -> cannot
In-Reply-To: <cover.1286460218.git.zkabelac@redhat.com>
References: <cover.1286460218.git.zkabelac@redhat.com>
Message-ID: <861d38d6b6c496394ff681449b22a6e94902db95.1286460218.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/fsadm.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 64d3184..aa6b2d9 100644
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -228,7 +228,7 @@ yes_no() {
 
 try_umount() {
 	yes_no "Do you want to unmount \"$MOUNTED\"" && dry $UMOUNT "$MOUNTED" && return 0
-	error "Can not proceed with mounted filesystem \"$MOUNTED\""
+	error "Cannot proceed with mounted filesystem \"$MOUNTED\""
 }
 
 validate_parsing() {
@@ -290,7 +290,7 @@ resize_reiser() {
 ########################
 # Resize XFS filesystem
 # - mounted for upsize
-# - can not downsize
+# - cannot downsize
 ########################
 resize_xfs() {
 	detect_mounted
@@ -379,7 +379,7 @@ resize() {
 ###################
 check() {
 	detect_fs "$1"
-	detect_mounted && error "Can not fsck device \"$VOLUME\", filesystem mounted on $MOUNTED"
+	detect_mounted && error "Cannot fsck device \"$VOLUME\", filesystem is mounted on $MOUNTED"
 	case "$FSTYPE" in
 	  "xfs") dry $XFS_CHECK "$VOLUME" ;;
 	  *) dry $FSCK $YES "$VOLUME" ;;
-- 
1.7.3.1



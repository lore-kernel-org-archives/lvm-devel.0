From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  7 Oct 2010 16:06:38 +0200
Subject: [PATCH 8/9] Support for noninteractive shell invocation of fsadm
In-Reply-To: <cover.1286460218.git.zkabelac@redhat.com>
References: <cover.1286460218.git.zkabelac@redhat.com>
Message-ID: <dfe64b97a9bc4e8932cdf78168e5f1ef68ee8f36.1286460218.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

try to distinguish between the case of  using interactive shell and non
interactive running - different combinations of  '-y' and '-p' option
needs to be used.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/fsadm.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 79bac51..945089a 100644
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -402,7 +402,11 @@ check() {
 	detect_mounted && error "Cannot fsck device \"$VOLUME\", filesystem is mounted on $MOUNTED"
 	case "$FSTYPE" in
 	  "xfs") dry $XFS_CHECK "$VOLUME" ;;
-	  *) dry $FSCK $YES "$VOLUME" ;;
+	  *)    # check if executed from interactive shell environment
+		case "$-" in
+		  *i*) dry $FSCK $YES $FORCE "$VOLUME" ;;
+		  *) dry $FSCK $FORCE -p "$VOLUME" ;;
+		esac
 	esac
 }
 
-- 
1.7.3.1



From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  7 Oct 2010 16:06:33 +0200
Subject: [PATCH 3/9] Fix dry run exec
In-Reply-To: <cover.1286460218.git.zkabelac@redhat.com>
References: <cover.1286460218.git.zkabelac@redhat.com>
Message-ID: <b9ecbf65c4f32feec92f805b281db26c36b94a0e.1286460218.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dangerous bug - as user which gives -n/--dry-run flag
could end up with modified lv size but with unresized filesystem.

So make sure recursive exec of lvresize tool has 'dry' prefix.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/fsadm.sh |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 2c6a21b..05b6382 100644
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -126,10 +126,13 @@ cleanup() {
 	IFS=$IFS_OLD
 	trap 2
 
-	# start LVRESIZE with the filesystem modification flag
-	# and allow recursive call of fsadm
-	unset FSADM_RUNNING
-	test "$DO_LVRESIZE" -eq 2 && exec $LVM lvresize $VERB -r -L$(( $NEWSIZE / 1048576 )) $VOLUME
+	if [ "$DO_LVRESIZE" -eq 2 ]; then
+		# start LVRESIZE with the filesystem modification flag
+		# and allow recursive call of fsadm
+		unset FSADM_RUNNING
+		dry exec $LVM lvresize $VERB $FORCE -r -L${NEWSIZE}b $VOLUME_ORIG
+	fi
+        
 	# error exit status for break
 	exit ${1:-1}
 }
-- 
1.7.3.1



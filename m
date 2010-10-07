From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  7 Oct 2010 16:06:34 +0200
Subject: [PATCH 4/9] Support for passing Yes flag recursively.
In-Reply-To: <cover.1286460218.git.zkabelac@redhat.com>
References: <cover.1286460218.git.zkabelac@redhat.com>
Message-ID: <1517be85bedd1a6fa2ff1decdb6e3e49f77cd7c1.1286460218.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/fsadm.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 05b6382..1393bc6 100644
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -52,7 +52,7 @@ XFS_CHECK=xfs_check
 # user may override lvm location by setting LVM_BINARY
 LVM=${LVM_BINARY-lvm}
 
-YES=
+YES=${_FSADM_YES}
 DRY=0
 VERB=
 FORCE=
@@ -129,6 +129,8 @@ cleanup() {
 	if [ "$DO_LVRESIZE" -eq 2 ]; then
 		# start LVRESIZE with the filesystem modification flag
 		# and allow recursive call of fsadm
+		_FSADM_YES=$YES
+		export _FSADM_YES
 		unset FSADM_RUNNING
 		dry exec $LVM lvresize $VERB $FORCE -r -L${NEWSIZE}b $VOLUME_ORIG
 	fi
-- 
1.7.3.1



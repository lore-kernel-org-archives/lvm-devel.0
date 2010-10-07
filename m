From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  7 Oct 2010 16:06:35 +0200
Subject: [PATCH 5/9] Fix wrong default value setting for lvm
In-Reply-To: <cover.1286460218.git.zkabelac@redhat.com>
References: <cover.1286460218.git.zkabelac@redhat.com>
Message-ID: <562eb00c58152985355ebb23f10a64adf2426612.1286460218.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/fsadm.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 1393bc6..73b6779 100644
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -50,7 +50,7 @@ FSCK=fsck
 XFS_CHECK=xfs_check
 
 # user may override lvm location by setting LVM_BINARY
-LVM=${LVM_BINARY-lvm}
+LVM=${LVM_BINARY:-lvm}
 
 YES=${_FSADM_YES}
 DRY=0
-- 
1.7.3.1



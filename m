From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:25:39 -0400
Subject: master - tests: raise min size for XFS
Message-ID: <201805121625.w4CGPdqa007788@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2be14e2d5fc3136257034a8bc194d2127a7c2d3
Commit:        e2be14e2d5fc3136257034a8bc194d2127a7c2d3
Parent:        6740c78e838b0b2322097de307fb41f1eeb60839
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 15:56:46 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 17:48:31 2018 +0200

tests: raise min size for XFS

Seems XFS now requires at least 1605 blocks.
---
 test/shell/fsadm-renamed.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index e88846a..beec6be 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -70,7 +70,7 @@ lvcreate -n $lv1 -L20M $vg
 
 case "$i" in
 *ext3)		MKFS_ARGS="-b1024 -j" ;;
-*xfs)		MKFS_ARGS="-l internal,size=1000b -f" ;;
+*xfs)		MKFS_ARGS="-l internal,size=1700b -f" ;;
 *reiserfs)	MKFS_ARGS="-s 513 -f" ;;
 esac
 



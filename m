From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 May 2017 10:20:06 -0400
Subject: master - tests: missed to export lvm binary for fsadm
Message-ID: <201705301420.v4UEK6pU026930@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=58289ceadd3076cd5e4e18cff0e128c7855df9d6
Commit:        58289ceadd3076cd5e4e18cff0e128c7855df9d6
Parent:        de663f48a15bf8934b616c8dd7f736e3d2b65b2d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 30 12:59:21 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 30 16:19:01 2017 +0200

tests: missed to export lvm binary for fsadm

---
 test/shell/lvresize-full.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvresize-full.sh b/test/shell/lvresize-full.sh
index 17ee6aa..3eef11a 100644
--- a/test/shell/lvresize-full.sh
+++ b/test/shell/lvresize-full.sh
@@ -20,6 +20,7 @@ SKIP_WITH_LVMPOLLD=1
 FSCK=${FSCK-fsck}
 MKFS=${MKFS-mkfs.ext3}
 RESIZEFS=${RESIZEFS-resize2fs}
+export LVM_BINARY=$(which lvm)
 
 which $FSCK || skip
 which $MKFS || skip



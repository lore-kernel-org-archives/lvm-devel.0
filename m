From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:38:56 -0400
Subject: master - tests: assign path
Message-ID: <201707101238.v6ACcuxT023874@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dafeb0274acae432054faf729510133780db9439
Commit:        dafeb0274acae432054faf729510133780db9439
Parent:        f818a83a1dea3d67ad4bc710ed0552a7175b38d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 9 15:54:43 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: assign path

---
 test/shell/lvconvert-repair-mirror.sh |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-repair-mirror.sh b/test/shell/lvconvert-repair-mirror.sh
index dcd8d07..0277221 100644
--- a/test/shell/lvconvert-repair-mirror.sh
+++ b/test/shell/lvconvert-repair-mirror.sh
@@ -13,12 +13,10 @@
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
-MKFS=mkfs.ext3
-MOUNT_DIR=mnt
-
 . lib/inittest
 
-which "$MKFS" || skp
+MOUNT_DIR=mnt
+MKFS=$(which mkfs.ext3) || skip
 
 cleanup_mounted_and_teardown()
 {



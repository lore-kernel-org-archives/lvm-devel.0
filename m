From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 13 Sep 2020 22:16:48 +0000 (GMT)
Subject: master - tests: protect this test for another kernel
Message-ID: <20200913221648.887A939518AD@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=18a60c634094273b92182734ceb2013817c497ab
Commit:        18a60c634094273b92182734ceb2013817c497ab
Parent:        9c0d11ecc952ff32b3b5746478d9c76de761775e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 19:08:24 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 00:15:14 2020 +0200

tests: protect this test for another kernel

Thisi 3.10.0-862 kernel also dies with this test.
---
 test/shell/lvconvert-raid-reshape-stripes-load-reload.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 59e147436..b79561fbb 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -22,7 +22,7 @@ which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
 case "$(uname -r)" in
-  5.[89]*) die "Cannot run this test on unfixed kernel." ;;
+  5.[89]*|3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
 esac
 
 mount_dir="mnt"



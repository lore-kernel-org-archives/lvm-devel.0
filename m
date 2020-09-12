From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 Sep 2020 11:24:51 +0000 (GMT)
Subject: master - tests: change skip to die for upstream crash
Message-ID: <20200912112451.498F3388E828@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17dbb24f7c9715b33a3b35cfa06c1c25657fddd9
Commit:        17dbb24f7c9715b33a3b35cfa06c1c25657fddd9
Parent:        7bd015861d7426f39e4a143236f1b991faa2bcf5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 09:46:43 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 12 13:24:03 2020 +0200

tests: change skip to die for upstream crash

So the failing test is not lost from sight.
---
 test/shell/lvconvert-raid-reshape-stripes-load-reload.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 1afeff46b..59e147436 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -22,7 +22,7 @@ which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
 case "$(uname -r)" in
-  5.[89]*) skip "Unfixed kernel" ;;
+  5.[89]*) die "Cannot run this test on unfixed kernel." ;;
 esac
 
 mount_dir="mnt"



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Mar 2021 00:00:45 +0000 (GMT)
Subject: main - tests: no further fixes likely to be expected
Message-ID: <20210317000045.D705E386181D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db37905d7f59ac0057f6d50c34d8b1095c64d50f
Commit:        db37905d7f59ac0057f6d50c34d8b1095c64d50f
Parent:        87659256f043ba7a76716cb8c97c350d723209db
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 16 21:40:30 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:59:50 2021 +0100

tests: no further fixes likely to be expected

Skip tests for these kernels.
---
 test/shell/lvconvert-raid-reshape-stripes-load-fail.sh   | 2 +-
 test/shell/lvconvert-raid-reshape-stripes-load-reload.sh | 3 ++-
 test/shell/lvconvert-raid-reshape-stripes-load.sh        | 2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index 220cd365c..da9d34798 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -18,7 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 # Test reshaping under io load
 
 case "$(uname -r)" in
-  3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+  3.10.0-862*) skip "Cannot run this test on unfixed kernel." ;;
 esac
 
 which mkfs.ext4 || skip
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 3023782dd..3b6150909 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -22,7 +22,8 @@ which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
 case "$(uname -r)" in
-  5.[891]*|3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+  5.[891]*) die "Cannot run this test on unfixed kernel." ;;
+  3.10.0-862*) skip "Cannot run this test on unfixed kernel." ;;
   4.18.0-*.el8*)
     REL="$(uname -r)"
     REL="${REL#4.18.0-}"
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index 6184e9d64..68ab8b92b 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 case "$(uname -r)" in
-  3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+  3.10.0-862*) skip "Cannot run this test on unfixed kernel." ;;
 esac
 
 # Test reshaping under io load



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 Sep 2020 11:24:50 +0000 (GMT)
Subject: master - tests: skip test on failing kernel
Message-ID: <20200912112450.264EE3870907@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7bd015861d7426f39e4a143236f1b991faa2bcf5
Commit:        7bd015861d7426f39e4a143236f1b991faa2bcf5
Parent:        a940979ff78e06b24a6a059e5da3a35b7e4ab16d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 09:46:21 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 12 13:24:03 2020 +0200

tests: skip test on failing kernel

---
 test/shell/lvconvert-raid-reshape-stripes-load-fail.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index 656e49818..220cd365c 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -17,6 +17,10 @@ SKIP_WITH_LVMPOLLD=1
 
 # Test reshaping under io load
 
+case "$(uname -r)" in
+  3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+esac
+
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 



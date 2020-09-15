From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:21 +0000 (GMT)
Subject: master - tests: skip kernel for this test
Message-ID: <20200915212121.E678F3983A76@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf4fed37617c71f6fd3f00f80beafb4737d53ced
Commit:        cf4fed37617c71f6fd3f00f80beafb4737d53ced
Parent:        d0ccb2521ba4f34455078f87f46cc41f5761ffc0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 14 21:23:16 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 23:07:06 2020 +0200

tests: skip kernel for this test

Kills this kernel ATM
---
 test/shell/lvconvert-raid-reshape-stripes-load.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index ad8f37351..6184e9d64 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -15,6 +15,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+case "$(uname -r)" in
+  3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+esac
+
 # Test reshaping under io load
 
 which mkfs.ext4 || skip



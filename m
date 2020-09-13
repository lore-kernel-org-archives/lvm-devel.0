From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 13 Sep 2020 22:16:46 +0000 (GMT)
Subject: master - tests: raise needed target version
Message-ID: <20200913221646.4569D3865491@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1005fd7b067320d03067229912bf4844d1a54836
Commit:        1005fd7b067320d03067229912bf4844d1a54836
Parent:        57e1e037b63426a5fd73641bcc7078d80b66c50b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 19:09:41 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 00:15:14 2020 +0200

tests: raise needed target version

Require higher version to avoid early bugs.
---
 test/shell/lvconvert-raid-reshape-load.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index 8fcbf545f..14b5dfdde 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -18,7 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 # Test reshaping under io load
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 2 || skip
+aux have_raid 1 14 0 || skip
 
 mount_dir="mnt"
 



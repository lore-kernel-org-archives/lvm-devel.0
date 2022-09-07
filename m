From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:53 +0000 (GMT)
Subject: main - tests: skip this test for 5.19
Message-ID: <20220907130453.F277D385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a92a526a0bd4f5c9f89a535ee8904143441f38e
Commit:        8a92a526a0bd4f5c9f89a535ee8904143441f38e
Parent:        15ad2b8e5585b89bc3f09a53567f17eb70f45714
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 7 14:54:39 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: skip this test for 5.19

mdraid has some breakage - so 5.19 is crashing
(possibly even some more older version - that can be added as well)
Test seems to pass with 6.0-rc kernel.
---
 test/shell/lvconvert-raid-reshape-load.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index 14b5dfdde..29b8e4ca4 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -15,6 +15,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+case "$(uname -r)" in
+5.19*) skip "Skippen test that kills this kernel" ;;
+esac
+
 # Test reshaping under io load
 
 which mkfs.ext4 || skip


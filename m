From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 21:41:38 +0000 (GMT)
Subject: master - tests: skip this test for current 5.8 5.9 kernels
Message-ID: <20200901214138.67ECE385E005@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a06700017bd2d97ff96854f7acbe4b1c74c2ab3
Commit:        9a06700017bd2d97ff96854f7acbe4b1c74c2ab3
Parent:        fa1290f40e17c82030d23c21af1f318688631759
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 1 23:14:47 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 23:40:24 2020 +0200

tests: skip this test for current 5.8 5.9 kernels

Kernel is hitting not yet fixed kernel bug.
Skip the test to avoid killing testing machine.
---
 test/shell/lvconvert-raid-reshape-stripes-load-reload.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index a38d9287b..414445244 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -21,6 +21,10 @@ which md5sum || skip
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
+case "$(uname -r)" in
+  5.[89]*) skip "Unfixed kernel" ;;
+esac
+
 mount_dir="mnt"
 
 cleanup_mounted_and_teardown()



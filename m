From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 14:05:31 +0000 (GMT)
Subject: main - tests: avoid killing test machines with kernel bug
Message-ID: <20210201140531.6AB34386F448@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6e8a32e4fd424ef599549ac1036ce795a8ae3837
Commit:        6e8a32e4fd424ef599549ac1036ce795a8ae3837
Parent:        bfafd2b4e962b8b6bce3355843dec47b4842ed12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 15:02:38 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 15:02:38 2021 +0100

tests: avoid killing test machines with kernel bug

Bug 1916891  still applies:

https://bugzilla.redhat.com/show_bug.cgi?id=1916891
---
 test/shell/lvconvert-raid-reshape-stripes-load-reload.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index b79561fbb..3920da1a5 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -22,7 +22,7 @@ which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
 case "$(uname -r)" in
-  5.[89]*|3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+  5.[891]*|3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
 esac
 
 mount_dir="mnt"



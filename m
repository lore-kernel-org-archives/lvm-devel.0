From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 17 Feb 2021 12:29:17 +0000 (GMT)
Subject: main - tests: Skip test killing kernel
Message-ID: <20210217122917.39534385042E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3cba07125457b82045f41bfafc67733c0dad89a2
Commit:        3cba07125457b82045f41bfafc67733c0dad89a2
Parent:        26a09c84c9498b187eec776150cd1eeafeda6ce7
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Feb 17 13:26:06 2021 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Feb 17 13:28:56 2021 +0100

tests: Skip test killing kernel

Bug 1916891
---
 test/shell/lvconvert-raid-reshape-stripes-load-reload.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 3920da1a5..6fe34250a 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -22,7 +22,7 @@ which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
 case "$(uname -r)" in
-  5.[891]*|3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+  5.[891]*|3.10.0-862*|4.18.0-283.el8) die "Cannot run this test on unfixed kernel." ;;
 esac
 
 mount_dir="mnt"



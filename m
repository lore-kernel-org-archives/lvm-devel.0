From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 10 Mar 2021 15:31:19 +0000 (GMT)
Subject: main - tests: Skip test killing kernel
Message-ID: <20210310153119.CC6483835407@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d4293b579df61b5eb96dfcce5a7ec8f2116e9561
Commit:        d4293b579df61b5eb96dfcce5a7ec8f2116e9561
Parent:        6097dfb9ad2faae1c28295b35e1fba82cb4b6f8b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 10 15:50:35 2021 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 10 16:31:04 2021 +0100

tests: Skip test killing kernel

Fix the pattern and for now skip all RHEL-8.4 kernels

Bug 1916891
---
 test/shell/lvconvert-raid-reshape-stripes-load-reload.sh | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 6fe34250a..3023782dd 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -22,7 +22,11 @@ which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
 case "$(uname -r)" in
-  5.[891]*|3.10.0-862*|4.18.0-283.el8) die "Cannot run this test on unfixed kernel." ;;
+  5.[891]*|3.10.0-862*) die "Cannot run this test on unfixed kernel." ;;
+  4.18.0-*.el8*)
+    REL="$(uname -r)"
+    REL="${REL#4.18.0-}"
+    [[ "${REL%%.*}" -lt 283 ]] || die "Cannot run this test on unfixed kernel." ;;
 esac
 
 mount_dir="mnt"



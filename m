From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:59 +0000 (GMT)
Subject: main - tests: safety first...
Message-ID: <20230216231059.0D4153858C78@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=13b216fbdf038dc83d31c43026aa53d281ab3942
Commit:        13b216fbdf038dc83d31c43026aa53d281ab3942
Parent:        1788b4b3aa129b9bfbb977be263455680b6dc128
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 14:21:17 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:08:50 2023 +0100

tests: safety first...

---
 test/shell/lvconvert-raid-reshape.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index e55ab7ab9..abea0ff10 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -17,6 +17,10 @@ LVM_SKIP_LARGE_TESTS=0
 
 . lib/inittest
 
+case "$(uname -r)" in
+5.19*) skip "Skippen test that kills this kernel" ;;
+esac
+
 which mkfs.ext4 || skip
 aux have_raid 1 14 0 || skip
 


From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:23 +0000 (GMT)
Subject: stable-2.02 - tests: avoid killing test machines with kernel bug
Message-ID: <20210217120123.1F23D3896839@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86cd2c630944f0db3429f05cdee967b273f3dff7
Commit:        86cd2c630944f0db3429f05cdee967b273f3dff7
Parent:        8bc7bb2dbf7126d9e6ba92d4bc8ccbd6dc026965
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 15:02:38 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 12:09:16 2021 +0100

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



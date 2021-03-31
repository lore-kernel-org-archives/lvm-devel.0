From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:48:59 +0000 (GMT)
Subject: dev-next - tests: increase required version
Message-ID: <20210331214859.85FA13857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14a3c34983fa8ab99773a47f1ee8bdd02d84feef
Commit:        14a3c34983fa8ab99773a47f1ee8bdd02d84feef
Parent:        d0644fb2c346414ae138369557bbd898d5feac6f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 14:39:13 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 14:39:13 2021 +0100

tests: increase required version

Seems like version 1.13.2 remains crashing kernel - so increase
the required version for this reshaping test.
---
 test/shell/lvconvert-raid-reshape-stripes-load-reload.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 1e2ad0fb4..2dde4d014 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -19,7 +19,7 @@ SKIP_WITH_LVMPOLLD=1
 
 which md5sum || skip
 which mkfs.ext4 || skip
-aux have_raid 1 13 2 || skip
+aux have_raid 1 14 || skip
 
 mount_dir="mnt"
 



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Nov 2019 06:38:36 -0500
Subject: master - tests: reduce amount of written date
Message-ID: <83782.119111506382900339@us-mta-57.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=496c368528c20b02d12be19b8fe359b9f0c2cea6
Commit:        496c368528c20b02d12be19b8fe359b9f0c2cea6
Parent:        dccc50f6f60390b18e5387cd38647209f36fa998
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 15 12:36:39 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 12:37:44 2019 +0100

tests: reduce amount of written date

Since we reduced created LV to 4M - dd also just 4M.
---
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 185bb57..a38d928 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -56,7 +56,7 @@ mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
 
 echo 3 >/proc/sys/vm/drop_caches
 # FIXME: This is filling up ram disk. Use sane amount of data please! Rate limit the data written!
-dd if=/dev/urandom of="$mount_dir/random" bs=1M count=50 conv=fdatasync
+dd if=/dev/urandom of="$mount_dir/random" bs=1M count=4 conv=fdatasync
 checksum_ "$mount_dir/random" >MD5
 
 # FIXME: wait_for_sync - is this really testing anything under load?




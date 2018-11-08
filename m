From: David Teigland <teigland@sourceware.org>
Date: Thu, 8 Nov 2018 10:33:48 -0500
Subject: master - tests: fix dd option in cache-single-options
Message-ID: <201811081533.wA8FXmPW021297@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c5fbd5fac7de820f7b4106a070b993a1565c112
Commit:        8c5fbd5fac7de820f7b4106a070b993a1565c112
Parent:        d4de3cfa4dd16512ac68f637ed7f484b7461edb9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 8 09:33:09 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 8 09:33:09 2018 -0600

tests: fix dd option in cache-single-options

---
 test/shell/cache-single-options.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
index 38d5a4a..4eb4d1c 100644
--- a/test/shell/cache-single-options.sh
+++ b/test/shell/cache-single-options.sh
@@ -58,7 +58,7 @@ mount_umount()
 
 	mount "$DM_DEV_DIR/$vg/$lvt" "$mount_dir"
 	diff pattern1 "$mount_dir/pattern1"
-	dd if="$mount_dir/zeros2M" of=/dev/null bs=1M count=2 conv=fdatasync
+	dd if="$mount_dir/zeros2M" of=/dev/null bs=1M count=2
 	umount "$mount_dir"
 
 	lvchange -an $vg/$lvt



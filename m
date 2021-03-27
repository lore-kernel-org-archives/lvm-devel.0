From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 27 Mar 2021 22:19:44 +0000 (GMT)
Subject: main - tests: fight with losetup creation error
Message-ID: <20210327221944.87D4D3857C48@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=feb7fef6c8d22d5773b6a5d1d9f2a5a3f52b5b3b
Commit:        feb7fef6c8d22d5773b6a5d1d9f2a5a3f52b5b3b
Parent:        1f7bd719d0d31a5dd5886dfcf783f6c2e80cb2e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 27 21:59:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 27 23:19:08 2021 +0100

tests: fight with losetup creation error

Try losetup few times in loop if we can succeed.
---
 test/shell/allow-mixed-block-sizes.sh | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
index a094338cb..171942e4b 100644
--- a/test/shell/allow-mixed-block-sizes.sh
+++ b/test/shell/allow-mixed-block-sizes.sh
@@ -19,9 +19,20 @@ which fallocate || skip
 
 fallocate -l 2M loopa
 fallocate -l 2M loopb
-sync
-LOOP1=$(losetup -f loopa --sector-size 4096 --show)
-LOOP2=$(losetup -f loopb --show)
+
+# Fight a weird occasional race in losetup usage:
+#
+# losetup: loopa: failed to set up loop device: Resource temporarily unavailable
+# 	loop0: detected capacity change from 0 to 4096
+# 	loop_set_block_size: loop0 () has still dirty pages (nrpages=2)
+for i in {1..5} ; do
+	LOOP1=$(losetup -f loopa --sector-size 4096 --show || true)
+	test -n "$LOOP1" && break
+done
+for i in {1..5} ; do
+	LOOP2=$(losetup -f loopb --show || true)
+	test -n "$LOOP2" && break
+done
 
 # prepare devX mapping so it works for real & fake dev dir
 d=1



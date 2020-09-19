From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 22:39:04 +0000 (GMT)
Subject: master - tests: fix cleanup for unbound variables
Message-ID: <20200919223904.B2961396E43E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc9bb534ff1bfaa8790b871a7ecd2d75bd0824f6
Commit:        bc9bb534ff1bfaa8790b871a7ecd2d75bd0824f6
Parent:        f507a2564c6e4933263b75319f6984104cc5c896
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 20 00:32:26 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 20 00:37:21 2020 +0200

tests: fix cleanup for unbound variables

When loop can't handle sector-size option - failure caused double fail
for access of unbound variable
Also fix expression for 'rm' and remove loops after loop release.
---
 test/shell/integrity-blocksize.sh | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index c28212d3c..329a2f73f 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -23,12 +23,13 @@ cleanup_mounted_and_teardown()
 {
 	umount "$mnt" || true
 	vgremove -ff $vg1 $vg2 || true
-	losetup -d $LOOP1 || true
-	losetup -d $LOOP2 || true
-	losetup -d $LOOP3 || true
-	losetup -d $LOOP4 || true
 
-	rm -f loop{abcd}
+	test -n "${LOOP1-}" && { losetup -d "$LOOP1" || true ; }
+	test -n "${LOOP2-}" && { losetup -d "$LOOP2" || true ; }
+	test -n "${LOOP3-}" && { losetup -d "$LOOP3" || true ; }
+	test -n "${LOOP4-}" && { losetup -d "$LOOP4" || true ; }
+
+	rm -f loop[abcd]
 	aux teardown
 }
 
@@ -57,10 +58,10 @@ dd if=/dev/zero of=loopb bs=1M count=64 oflag=sync
 dd if=/dev/zero of=loopc bs=1M count=64 oflag=sync
 dd if=/dev/zero of=loopd bs=1M count=64 oflag=sync
 
-LOOP1=$(losetup -f loopa --show)
-LOOP2=$(losetup -f loopb --show)
-LOOP3=$(losetup -f loopc --sector-size 4096 --show)
-LOOP4=$(losetup -f loopd --sector-size 4096 --show)
+LOOP1=$(losetup -f loopa --show) || skip "Cannot find free loop device"
+LOOP2=$(losetup -f loopb --show) || skip "Cannot find free loop device"
+LOOP3=$(losetup -f loopc --sector-size 4096 --show) || skip "Loop cannot handle --sector-size 4096"
+LOOP4=$(losetup -f loopd --sector-size 4096 --show) || skip "Loop cannot handle --sector-size 4096"
 
 echo $LOOP1
 echo $LOOP2



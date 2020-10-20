From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 20:34:05 +0000 (GMT)
Subject: master - tests: extend area covered by error target
Message-ID: <20201020203405.B6853385782B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2bdad28d1d1ad337a6c876c235797dbf6907886
Commit:        d2bdad28d1d1ad337a6c876c235797dbf6907886
Parent:        b50134dc14296bf9bee96f3b4021ba5b123d54c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 6 15:45:19 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 19 16:53:18 2020 +0200

tests: extend area covered by error target

Since 'BLKZEROOUT' streams out more block at once, at can easily
zero-out larger set of blocks after 1st. failing one.

So the test is adapted to fully 'hide' swap header under error target.
---
 test/shell/lvcreate-signature-wiping.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index 18d7a2f7e..4893d9a66 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -43,7 +43,7 @@ test_blkid_ || skip
 lvremove -f $vg/$lv1
 
 # Zeroing stops the command when there is a failure (write error in this case)
-aux error_dev "$dev1" "$(get first_extent_sector "$dev1"):2"
+aux error_dev "$dev1" "$(get first_extent_sector "$dev1"):8"
 not lvcreate -l1 -n $lv1 $vg 2>&1 | tee out
 grep "Failed to initialize" out
 aux enable_dev "$dev1"



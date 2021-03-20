From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 20 Mar 2021 09:53:08 +0000 (GMT)
Subject: main - tests: slow down device more
Message-ID: <20210320095308.0DC4C3858009@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2dd43a7314ba72b0b899e161261ef5caacbade05
Commit:        2dd43a7314ba72b0b899e161261ef5caacbade05
Parent:        94c4af232c6118191ac2c81a4130e6f83823f510
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 20 09:58:50 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 10:52:24 2021 +0100

tests: slow down device more

Make the race with too fast merging less likely to occure.
---
 test/shell/snapshot-merge-thin.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/snapshot-merge-thin.sh b/test/shell/snapshot-merge-thin.sh
index 447a93167..4e4577ca9 100644
--- a/test/shell/snapshot-merge-thin.sh
+++ b/test/shell/snapshot-merge-thin.sh
@@ -49,7 +49,7 @@ lvcreate -s -n $lv2 -L2 $vg/$lv1 "$dev2"
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1 oflag=direct
 
 lvs -a -o+lv_merging,lv_merge_failed $vg
-aux delay_dev "$dev1" 0 100 "$(get first_extent_sector "$dev1"):"
+aux delay_dev "$dev1" 0 400 "$(get first_extent_sector "$dev1"):"
 
 # Initiate background merge
 lvconvert -b --merge $vg/$lv2



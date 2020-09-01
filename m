From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:01:58 +0000 (GMT)
Subject: master - tests: filefrag needs to support -e
Message-ID: <20200901170158.7F74A38708C3@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2fbc578cfa0bde161b7583978537d2023e5d6e0c
Commit:        2fbc578cfa0bde161b7583978537d2023e5d6e0c
Parent:        ef389603ddd1239c79f688bac0bb7b27a568df6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 15:33:57 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:48 2020 +0200

tests: filefrag needs to support -e

Skip on systems with 'too old' filefrag without -e support
---
 test/shell/lvm-conf-error.sh | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/test/shell/lvm-conf-error.sh b/test/shell/lvm-conf-error.sh
index 17b7dad97..01461c174 100644
--- a/test/shell/lvm-conf-error.sh
+++ b/test/shell/lvm-conf-error.sh
@@ -29,9 +29,11 @@ mount "$DM_DEV_DIR/$vg/$lv1" mnt
 cp etc/lvm.conf mnt
 
 # Figure where the file is placed in filesystem
-filefrag -e mnt/lvm.conf | tee frags
+filefrag -e mnt/lvm.conf | tee frags || rm -f frags
 umount mnt
 
+test -s frags || skip
+
 # 1st. sector for filesystem
 first_extent_sector=$(get first_extent_sector "$dev1")
 



From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 18 Mar 2020 17:04:15 +0000 (GMT)
Subject: master - test: Fix previous commit
Message-ID: <20200318170415.730703877027@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6b93dc24e293bb06403f914ed5c03f9afa1a8ee
Commit:        e6b93dc24e293bb06403f914ed5c03f9afa1a8ee
Parent:        fc32787c1b7f867008f30444a20ba154e0cdc39c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 18 18:03:12 2020 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 18 18:03:12 2020 +0100

test: Fix previous commit

---
 test/shell/writecache.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index a7a2d9564..8852e93f4 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -160,11 +160,11 @@ mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
 
 diff pattern1 $mount_dir/pattern1
 diff pattern1 $mount_dir/pattern1.after
+fi
 
 umount $mount_dir
 lvchange -an $vg/$lv1
 lvremove $vg/$lv1
-fi
 
 vgremove -ff $vg
 



